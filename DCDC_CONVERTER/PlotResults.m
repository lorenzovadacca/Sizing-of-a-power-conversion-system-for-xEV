% clc
% clear
% This script is called whenever the simulink file is runned.
% If I want to use it to plot already saved simulink data I have to run
% simulation , save the data from the command window.Then I can just load 
%this data and plot what I need.

%import of simulink data
time=out.tout*1000;  % [ms]
i_in=out.i_in;
io=out.io;
vdc=out.vdc;
vdc_ref = out.vdc_ref;
iLoad = out.iLoad;

close all;

time_start=0;    %from 0 to 200ms
time_stop=200;

SetPlot('large');
figure(1)
subplot(2,1,1)
plot(time,i_in);
hold on;
plot(time,io);
plot(time,iLoad,'g--')
axis([time_start time_stop -50 500])
ax=gca;
ax.FontSize=14;
h=legend('$i_{in}$','$i_o$','$i_{load}$','Orientation','Vertical');
h.FontSize=14;
ylabel('Current (A)')
title('Input,output and load current');

subplot(2,1,2)
plot(time,vdc,time,vdc_ref)
axis([time_start time_stop 150 450])
ax=gca;
ax.FontSize=14;
h=legend('$v_{dc}$','$v_{dc-ref}$','Orientation','Vertical');
h.FontSize=14;
title('Output voltage');
ylabel('Voltage (V)')
xlabel('Time (ms)')
