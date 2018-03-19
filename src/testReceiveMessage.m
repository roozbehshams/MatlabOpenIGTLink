function testReceiveMessage()
igtlConnection = igtlConnect('127.0.0.1',18944);
receiver = OpenIGTLinkMessageReceiver(igtlConnection, @onRxStringMessage, @onRxTransformMessage, @onRxNDArrayMessage);

    for i=1:10
        receiver.readMessage();
    end
    
    igtlDisconnect(igtlConnection);

end

function onRxStringMessage(deviceName, message)
  disp('received  STRING message');
  disp(deviceName);
  disp(message);
end

function onRxTransformMessage(deviceName, transform)
  disp('received  TRANSFORM message');
  disp(deviceName);
  disp( transform );
end

function onRxNDArrayMessage()
end