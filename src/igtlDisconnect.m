function igtlDisconnect(igtlConnection)
% igtlDisconnect  Disconnect from the OpenIGTLink server
%
%   igtlDisconnect(igtlConnection)
%
%   igtlConnection: connection returned by igtlConnect(...)
%

if ~isempty(igtlConnection.socket)
    fclose(igtlConnection.socket);
end
