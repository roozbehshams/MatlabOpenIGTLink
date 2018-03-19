% OpenIGTLink server that executes the received string commands
function receiver = OpenIGTLinkMessageReceiver(igtlConnection)
    global socket;
    socket = igtlConnection.socket;    
    global timeout;
    timeout = 0.01;
   
    receiver.readMessage = @readMessage;
end

function [status, messageType, name, data] = readMessage()
    messageType = [];
    name = [];
    data = [];
    [status, msg] = ReadOpenIGTLinkMessage();
    if ~status
        return
    end
    status = false;
    %look at the message type and call appropriate function supplied as
    %arguments
    messageType = char(msg.dataTypeName);
    messageType = deblank(messageType);
    
    if strcmpi(messageType, 'STRING')==1
        [name, data] = handleStringMessage(msg);
     elseif (strcmpi(messageType, 'TRANSFORM')==1)
        [name, data]=handleTransformMessage(msg);
     elseif strcmpi(messageType, 'NDARRAY') == 1
        [name, data]= handleNDArrayMessage(msg);
     elseif strcmpi(messageType, 'POINT') == 1
         [name, data] = handlePointMessage(msg);
    end        
    if ~isempty(name)
        status = true;
    end
end

function [name, message] = handleStringMessage(msg)
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
end

function [name, trans] = handleTransformMessage(msg)
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
end

function handleImageMessage(msg)
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
end

function [name, data] = handleNDArrayMessage(msg)
    %YET NOT implmented, will be available soon
    name = '';
    data = [];
end

function [listName, points] = handlePointMessage(msg)
    sizeOfPoint = 136;
    numPoints = msg.bodySize/sizeOfPoint;
    listName = deblank(msg.deviceName);

    for i=1:numPoints
        pointDataIndexStart = (i-1)*sizeOfPoint;
        points(i).name = deblank(char(msg.body(pointDataIndexStart+1:pointDataIndexStart+64)));
        points(i).group = deblank(char(msg.body(pointDataIndexStart+65:pointDataIndexStart+96)));
        points(i).color = [uint8(msg.body(pointDataIndexStart+97)),uint8(msg.body(pointDataIndexStart+98)),uint8(msg.body(pointDataIndexStart+99)),uint8(msg.body(pointDataIndexStart+100))];
        points(i).x = convertFromUint8VectorToFloat32(msg.body(pointDataIndexStart+101:pointDataIndexStart+104));
        points(i).y = convertFromUint8VectorToFloat32(msg.body(pointDataIndexStart+105:pointDataIndexStart+108));
        points(i).z = convertFromUint8VectorToFloat32(msg.body(pointDataIndexStart+109:pointDataIndexStart+112));
        points(i).diamter = convertFromUint8VectorToFloat32(msg.body(pointDataIndexStart+113:pointDataIndexStart+116));
        points(i).owner = deblank(char(msg.body(pointDataIndexStart+117:pointDataIndexStart+136)));
    end
   % onRxPointMessage(listName, points);
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

function [status, msg]=ReadOpenIGTLinkMessage()
    global timeout;
    status = false;
    msg = [];
    openIGTLinkHeaderLength=58;
    headerData=ReadWithTimeout(openIGTLinkHeaderLength, timeout);
    if (length(headerData)==openIGTLinkHeaderLength)
        msg=ParseOpenIGTLinkMessageHeader(headerData);
        msg.body=ReadWithTimeout(msg.bodySize, timeout);
        if (length(msg.body)==msg.bodySize) %if we did not get correct size of body return empty message
            status = true;
        end    
    else
        return;
        %error('ERROR: Timeout while waiting receiving OpenIGTLink message header')
    end
end    
function data = ReadWithTimeout(requestedDataLength, timeoutSec) %currently does not use timeout will add that later
    global socket;
    requestedDataLength = double(uint32(requestedDataLength));
    data = [];
    tstart=tic;
    timeElapsedSec=toc(tstart);

    while timeElapsedSec<timeoutSec && socket.BytesAvailable<requestedDataLength
        timeElapsedSec=toc(tstart);
    end
    if socket.BytesAvailable<requestedDataLength
        return ;
    else
        try
            data = fread(socket, requestedDataLength, 'uint8');
            data = data';
        catch ex
           error('Error reading data from socket %s\n', ex.message);
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



