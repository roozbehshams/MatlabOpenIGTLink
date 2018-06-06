
igtlConnection = igtlConnect('127.0.0.1',18944);
sender = OpenIGTLinkMessageSender(igtlConnection);
pause(2)

for t=0:100
    
  % An arbitrary movement in 3D space
  Amp = 30;
  t_x = (Amp*sin(0.1*t+pi/3));
  t_y = 2*(Amp*cos(0.1*t));
  t_z = t/2000 * Amp * 4
  matrix = [ 1 0 0 t_x; 0 1 0 t_y; 0 0 1 t_z; 0 0 0 1 ];
  
  % An arbitrary message
  msg = num2str(mod(t,2)+1)
  
  % Sending the messages
  sender.igtlSendStringMessage('CMD_RESULT', msg);
  sender.igtlSendTransformMessage('ProbeToRefrence', matrix);
  
  pause(0.03)

end

igtlDisconnect(igtlConnection);


%% Slicer script:
% Create an IGTLink server and:
%{
getNode("IGTLCon*").SetCheckCRC(0)

layoutManager = slicer.app.layoutManager()
layoutManager.setLayout(4)  # 3D only

threeDWidget = layoutManager.threeDWidget(0)
threeDView = threeDWidget.threeDView()
threeDView.resetFocalPoint()

threeDController = threeDWidget.threeDController()
threeDController.spinView(True)
threeDView.setAnimationIntervalMs(5)
threeDView.setSpinIncrement(1)

%}


