%Fan and Peltier Control added Stepper
%B.Long
%12/9/2019

clear all; clc;
a = arduino();

stepper_enable_pin = 'D2';
stepper_direction_pin = 'D3';
stepper_PWM_pin = 'D9';
fan_PWM_pin = 'D5';
peltier_PWM_pin = 'D6';
Reservoir_thermocouple = 'A0';
Heatsink_thermocouple = 'A1';


%% demonstration during presentation
% Stepper motor movement using PWM
tic
Stepper_PWM_percent = .9;
writePWMDutyCycle(a, 'D9', Stepper_PWM_percent);
% Fan PWM
Fan_PWM_percent = .990;
writePWMDutyCycle(a, 'D5', Fan_PWM_percent);
pause(2.5)

for i = 1:5
    writeDigitalPin(a,'D3',0);
    writeDigitalPin(a,'D2',0);
    pause(.8)
    writeDigitalPin(a,'D2',1);
    pause(.4)
    writeDigitalPin(a,'D3',1);
    writeDigitalPin(a,'D2',0);
    pause(.8)
    writeDigitalPin(a,'D2',1);
    pause(.4)
    Fan_PWM_percent = Fan_PWM_percent-.1;
    writePWMDutyCycle(a, 'D5', Fan_PWM_percent);
end

writeDigitalPin(a,'D2',1);
pause(4.5)
Fan_PWM_percent = .0;
writePWMDutyCycle(a, 'D5', Fan_PWM_percent);
toc

%% stepper direction on pin A3
%low = reverse
writeDigitalPin(a,'D3',0);
%%
%high = forward
writeDigitalPin(a,'D3',1);

%% enable and disable stepper on pin A2
%high = disabled
%low = enabled
writeDigitalPin(a,'D2',1);

%% rotate +180/-180
for i = 1:15
    writeDigitalPin(a,'D3',0);
    writeDigitalPin(a,'D2',0);
    pause(.9)
    writeDigitalPin(a,'D2',1);
    pause(.5)
    writeDigitalPin(a,'D3',1);
    writeDigitalPin(a,'D2',0);
    pause(.9)
    writeDigitalPin(a,'D2',1);
    pause(.5)
end
writeDigitalPin(a,'D2',1);
display('done');

%% Stepper motor movement using PWM
Stepper_PWM_percent = .0;
writePWMDutyCycle(a, 'D9', Stepper_PWM_percent);

%% Fan on off
%low = reverse
writeDigitalPin(a,'D11',0);

%% Fan PWM
Fan_PWM_percent = .0;
writePWMDutyCycle(a, 'D5', Fan_PWM_percent);
% test_Fan_PWM = Fan_PWM_percent;

%% Peltier PWM
Peltier_PWM_percent = .0;
writePWMDutyCycle(a, 'D6', Peltier_PWM_percent);
% test_Peltier_PWM = Peltier_PWM_percent;
%
%% This is a script that will plot Arduino analogRead values in real time
%Modified from http://billwaa.wordpress.com/2013/07/10/matlab-real-time-serial-data-logger/
%The code from that site takes data from Serial
%User Defined Properties
warning off;
clear data;
close all;

test_Peltier_PWM = Peltier_PWM_percent;
test_Fan_PWM = Fan_PWM_percent;

plotTitle = cat(2,'SLAC Clamshell Temp Testing; 400W; Peltier PWM= '...
    ,num2str(test_Peltier_PWM*100),'%; Fan Speed PWM= '...
    ,num2str(test_Fan_PWM*100),'%');  % plot title
xLabel = 'Elapsed Time (s)';     % x-axis label
yLabel = 'Temperature (C)';      % y-axis label
legend1 = 'Sample Reservoir Temp Sensor';
legend2 = 'Heatsink Temp Sensor';
plotGrid = 'on';                 % 'off' to turn off grid
delay = .1;                     % make sure sample faster than resolution
count = 0;
tic
%Data matrix initial conditions
data(1,1)=toc;                                      %time
data(2,1)=(readVoltage(a,'A0')-1.2)/.005;           %reservoir temp
data(3,1)=(readVoltage(a,'A1')-1.2)/.005;           %heatsink temp


%Set up Plot
plotGraph = plot(data(1,1),data(2,1),'-b' );        % every AnalogRead needs to be on its own Plotgraph
hold on                                             %hold on makes sure all of the channels are plotted
plotGraph1 = plot(data(1,1),data(3,1),'-r');
title(plotTitle,'FontSize',15);
xlabel(xLabel,'FontSize',15);
ylabel(yLabel,'FontSize',15);
legend(legend1,legend2);
grid(plotGrid);

while ishandle(plotGraph) %Loop when Plot is Active will run until plot is closed
    
    count = count + 1;
    data(1,count) = toc;
    data(2,count) = (readVoltage(a,'A0')-1.2)/.005;   %Analog Reservoir Temp
    data(3,count) = (readVoltage(a,'A1')-1.2)/.005;  %Analog Heatsink Temp
    
    set(plotGraph,'XData',data(1,:),'YData',data(2,:));
    hold on;
    set(plotGraph1,'XData',data(1,:),'YData',data(3,:));
    pause(delay);
end

%% Smooth Temperature data
[B,A] = butter(2,.025,'low');           %designs a lowpass filter.
data(4,:) = filtfilt(B,A,data(2,:));    %smoothed reservoir temp
data(5,:) = filtfilt(B,A,data(3,:));    %smoothed heatsink temp

%% save collected and plotted data as jpeg
plotTitle = cat(2,'SLAC Clamshell Temp Testing; 400W; Peltier PWM= '...
    ,num2str(test_Peltier_PWM*100),'%; Fan Speed PWM= '...
    ,num2str(test_Fan_PWM*100),'%');  % plot title
xLabel = 'Elapsed Time (s)';                                    % x-axis label
yLabel = 'Temperature (C)';                                     % y-axis label
legend1 = 'Sample Reservoir Temp Sensor';
legend2 = 'Heatsink Temp Sensor';
legend3 = 'Smoothed Sample Res. Temp';
legend4 = 'Smoothed Heatsink Temp';
legend5 = 'Target Temperature 4[C]';
plotGrid = 'on';                                                % 'off' to turn off grid
plot(data(1,:),data(2,:),'-b','LineWidth',.1);                % every AnalogRead needs to be on its own Plotgraph
hold on;
plot(data(1,:),data(3,:),'-r','LineWidth',.1);            % every AnalogRead needs to be on its own Plotgraph
plot(data(1,:),data(4,:),'color',[0.9100    0.4100    0.1700],'LineWidth',3);            % every AnalogRead needs to be on its own Plotgraph
plot(data(1,:),data(5,:),'-g','LineWidth',3);            % every AnalogRead needs to be on its own Plotgraph
Temp_target = 4.*ones(1,length(data));
plot(data(1,:),Temp_target,'--k','LineWidth',3);            % every AnalogRead needs to be on its own Plotgraph
title(plotTitle,'FontSize',15);
xlabel(xLabel,'FontSize',15);
ylabel(yLabel,'FontSize',15);
legend(legend1,legend2,legend3,legend4,legend5);
grid(plotGrid);

%%

% %User Defined Properties
% serialPort = ‘COM3’; % define COM port #
% plotTitle = ‘Serial Data Log’; % plot title
% xLabel = ‘Elapsed Time (s)’; % x-axis label
% yLabel = ‘Acceleration’; % y-axis label
% plotGrid = ‘on’; % ‘off’ to turn off grid
% min = -1; % set y-min
% max = 4; % set y-max
% scrollWidth = 10; % display period in plot, plot entire data log if 0)
% set(plotGraph,’XData’,time(time > time(count)-scrollWidth),…
% ‘YData’, data(3,time > time(count)-scrollWidth));
% set(plotGraph1,’XData’,time(time > time(count)-scrollWidth),…
% ‘YData’, data(2,time > time(count)-scrollWidth));
% set(plotGraph2,’XData’,time(time > time(count)-scrollWidth),…
% ‘YData’, data(1,time > time(count)-scrollWidth));
%
% axis([time(count)-scrollWidth time(count) min max]);
% else
% set(plotGraph,’XData’,time,’YData’,data(3,:));
% set(plotGraph1,’XData’,time,’YData’,data(2,:));
% set(plotGraph2,’XData’,time,’YData’,data(1,:));
%
% axis([0 time(count) min max]);
% end
%
% %Allow MATLAB to Update Plot
% pause(delay);
% end
% end
%
% %Close Serial COM Port and Delete useless Variables
% fclose(s);
%
% clear count dat delay max min plotGraph plotGraph1 plotGraph2 plotGrid…
% plotTitle s scrollWidth serialPort xLabel yLabel;
%
% disp(‘Session Terminated’);
%
% prompt = ‘Export Data? [Y/N]: ‘;
% str = input(prompt,’s’);
% if str == ‘Y’ || strcmp(str, ‘ Y’) || str == ‘y’ || strcmp(str, ‘ y’)
% %export data
% csvwrite(‘accelData.txt’,data);
% type accelData.txt;
% else
% end
%
% clear str prompt;