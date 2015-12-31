% OpenIGTLink server that executes the received string commands
function receiver = OpenIGTLinkMessageReceiver(sock, onRxStringMsg, onRxTransformMsg, onRxNDArrayMsg)
    global onRxStringMessage onRxTransformMessage onRxNDArrayMessage;
    onRxStringMessage = onRxStringMsg;
    onRxTransformMessage = onRxTransformMsg;
    onRxNDArrayMessage = onRxNDArrayMsg;

    global socket;
    socket = sock;
    
    global timeout;
    timeout = 500;
   
    receiver.readMessage = @readMessage;
end

function [name data] = readMessage()
    global onRxStringMessage onRxTransformMessage onRxNDArrayMessage;

    msg = ReadOpenIGTLinkMessage();
    
    %look at the message type and call appropriate function supplied as
    %arguments
    messageType = char(msg.dataTypeName);
    messageType = deblank(messageType);
    
    if strcmpi(messageType, 'STRING')==1
        [name data] = handleStringMessage(msg, onRxStringMessage );
     elseif (strcmpi(messageType, 'TRANSFORM')==1)
        [name data]=handleTransformMessage(msg, onRxTransformMessage );
     elseif strcmpi(messageType, 'NDARRAY') == 1
         handleNDArrayMessage(msg, onRxNDArrayMessage );
     end        

end

function [name message] = handleStringMessage(msg, onRxStringMessage)
    if (length(msg.body)<5)
        disp('Error: STRING message received with incomplete contents')
        msg.string='';
        return
    end        
    strMsgEncoding=convertFromUint8VectorToUint16(msg.body(1:2));
    if (strMsgEncoding~=3)
        disp(['Warning: STRING message received with unknown encoding ',num2str(strMsgEncoding)])
    end
    strMsgLength=convertFromUint8VectorToUint16(msg.body(3:4));
    msg.string=char(msg.body(5:4+strMsgLength));
    name = msg.deviceName;
    message = msg.string;
    onRxStringMessage(msg.deviceName, msg.string);
end

function [name trans] = handleTransformMessage(msg, onRxTransformMessage)
    transform = diag([1 1 1 1]);
    k=1;
    for i=1:4
        for j=1:3
            transform(j,i) = convertFromUint8VectorToFloat32(msg.body(4*(k-1) +1:4*k));
            k = k+1;
        end
    end
    name = msg.deviceName;
    trans = transform;
    onRxTransformMessage(msg.deviceName , transform);
end

function handleImageMessage(msg, onRxStringMessage)
    body = msg.body;
    i=1;
    
    V = uint8(body(i)); i = i + 1;
    T = uint8(body(i)); i = i + 1;
    S = uint8(body(i)); i = i + 1;
    E = uint8(body(i)); i = i + 1;
    O = uint8(body(i)); i = i + 1;
    
    RI =  convertFromUint8VectorToUint16(body(i:i+1));i = i + 2;
    RJ =  convertFromUint8VectorToUint16(body(i:i+1));i = i + 2;
    RK =  convertFromUint8VectorToUint16(body(i:i+1));i = i + 2;
    
    TX =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    TY =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    TZ =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    
    SX =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    SY =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    SZ =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    
    NX =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    NY =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    NZ =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    
    PX =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    PY =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    PZ =  convertFromUint8VectorToUint16(body(i:i+3));i = i + 4;
    
    DI = convertFromUint8VectorToUint16(body(i:i+1)); i = i + 2;
    DJ = convertFromUint8VectorToUint16(body(i:i+1)); i = i + 2;
    DK = convertFromUint8VectorToUint16(body(i:i+1)); i = i + 2;
    
    DRI = convertFromUint8VectorToUint16(body(i:i+1)); i = i + 2;
    DRJ = convertFromUint8VectorToUint16(body(i:i+1)); i = i + 2;
    DRK = convertFromUint8VectorToUint16(body(i:i+1)); i = i + 2;
    
    IMAGE_DATA = body(i:length(body));
    
    strMsgEncoding=convertFromUint8VectorToUint16(msg.body(1:2));
    if (strMsgEncoding~=3)
        disp(['Warning: STRING message received with unknown encoding ',num2str(strMsgEncoding)])
    end
    strMsgLength=convertFromUint8VectorToUint16(msg.body(3:4));
    msg.string=char(msg.body(5:4+strMsgLength));
    onRxStringMessage(msg.deviceName, msg.string);
end

function handleNDArrayMessage(msg, onRxNDArrayMessage)
    %YET NOT implmented, will be available soon
end

%%  Parse OpenIGTLink messag header
% http://openigtlink.org/protocols/v2_header.html    
function parsedMsg=ParseOpenIGTLinkMessageHeader(rawMsg)
    parsedMsg.versionNumber=convertFromUint8VectorToUint16(rawMsg(1:2));
    parsedMsg.dataTypeName=char(rawMsg(3:14));
    parsedMsg.deviceName=char(rawMsg(15:34));
    parsedMsg.timestamp=convertFromUint8VectorToInt64(rawMsg(35:42));
    parsedMsg.bodySize=convertFromUint8VectorToInt64(rawMsg(43:50));
    parsedMsg.bodyCrc=convertFromUint8VectorToInt64(rawMsg(51:58));
end

function msg=ReadOpenIGTLinkMessage()
    global timeout;
    openIGTLinkHeaderLength=58;
    headerData=ReadWithTimeout(openIGTLinkHeaderLength, timeout);
    if (length(headerData)==openIGTLinkHeaderLength)
        msg=ParseOpenIGTLinkMessageHeader(headerData);
        msg.body=ReadWithTimeout(msg.bodySize, timeout);            
    else
        error('ERROR: Timeout while waiting receiving OpenIGTLink message header')
    end
end    
      
function data=ReadWithTimeout(requestedDataLength, timeoutSec)
    import java.net.Socket
    import java.io.*
    import java.net.ServerSocket
    
    global socket;
    
    % preallocate to improve performance
    data=zeros(1,requestedDataLength,'uint8');
    signedDataByte=int8(0);
    bytesRead=0;
    while(bytesRead<requestedDataLength)    
        % Computing (requestedDataLength-bytesRead) is an int64 operation, which may not be available on Matlab R2009 and before
        int64arithmeticsSupported=~isempty(find(strcmp(methods('int64'),'minus')));
        if int64arithmeticsSupported
            % Full 64-bit arithmetics
            bytesToRead=min(socket.inputStream.available, requestedDataLength-bytesRead);
        else
            % Fall back to floating point arithmetics
            bytesToRead=min(socket.inputStream.available, double(requestedDataLength)-double(bytesRead));
        end  
        if (bytesRead==0 && bytesToRead>0)
            % starting to read message header
            tstart=tic;
        end
        for i = bytesRead+1:bytesRead+bytesToRead
            signedDataByte = DataInputStream(socket.inputStream).readByte;
            if signedDataByte>=0
                data(i) = signedDataByte;
            else
                data(i) = bitcmp(-signedDataByte,'uint8')+1;
            end
        end            
        bytesRead=bytesRead+bytesToRead;
        if (bytesRead>0 && bytesRead<requestedDataLength)
            % check if the reading of the header has timed out yet
            timeElapsedSec=toc(tstart);
            if(timeElapsedSec>timeoutSec)
                % timeout, it should not happen
                % remove the unnecessary preallocated elements
                data=data(1:bytesRead);
                break
            end
        end
    end
end


function result=convertFromUint8VectorToUint16(uint8Vector)
  result=int32(uint8Vector(1))*256+int32(uint8Vector(2));
end

function result=convertFromUint8VectorToFloat32(uint8Vector)
    binVal = '';
    for i=1:4
        binVal = strcat(binVal, dec2bin(uint8Vector(i),8));
    end
    q = quantizer('float', [32 8]); % this is IEE 754
    result = bin2num(q, binVal);
end 

function result=convertFromUint8VectorToInt64(uint8Vector)
  multipliers = [256^7 256^6 256^5 256^4 256^3 256^2 256^1 1];
  % Matlab R2009 and earlier versions don't support int64 arithmetics.
  int64arithmeticsSupported=~isempty(find(strcmp(methods('int64'),'mtimes')));
  if int64arithmeticsSupported
    % Full 64-bit arithmetics
    result = sum(int64(uint8Vector).*int64(multipliers));
  else
    % Fall back to floating point arithmetics: compute result with floating
    % point type and convert the end result to int64
    % (it should be precise enough for realistic file sizes)
    result = int64(sum(double(uint8Vector).*multipliers));
  end  
end 

function selectedByte=getNthByte(multibyte, n)
  selectedByte=uint8(mod(floor(multibyte/256^n),256));
end



