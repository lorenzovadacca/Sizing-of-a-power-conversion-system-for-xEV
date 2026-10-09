


%import of simulink data
time=out.tout*1000;  % [ms]
T_ref=out.Tref;
T = out.T;
RPM = out.RPM;
id_sim = out.idq(:,1);
iq_sim = out.idq(:,2);
i_dc = out.idc;
Pmech = out.Pmech./1000;  %[kW]

time_start=0;    %from 0 to 500ms
time_stop=500;

SetPlot('large');
figure(1)
subplot(2,2,1)
plot(time,T);
hold on;
plot(time,T_ref);

axis([time_start time_stop -50 150])
ax=gca;
ax.FontSize=14;
h=legend('T','$T_{ref}$','Orientation','Vertical');
h.FontSize=10;
ylabel('Torque (Nm)')
xlabel('Time (ms)')

subplot(2,2,2)
plot(time,RPM)
plot(time,w_base_mech*ones(size(time)),'--')
axis([time_start time_stop -10 w_base_mech*1.1])
ax=gca;
ax.FontSize=14;
h=legend('$RPM$','Base speed','Orientation','Vertical');
h.FontSize=10;
ylabel('RPM')
xlabel('Time (ms)')

subplot(2,2,3)
plot(time,id_sim,time,iq_sim)
ax=gca;
ax.FontSize=14;
h=legend('$id$','$iq$','Orientation','Vertical');
h.FontSize=10;
ylabel('Current(A)')
xlabel('Time (ms)')
xaxis([time_start time_stop])

subplot(2,2,4)
plot(time,Pmech,time,out.idc)
ax=gca;
ax.FontSize=14;
h=legend('$Pmech (kW)$','$idc (A)$','Orientation','Vertical');
h.FontSize=10;
xlabel('Time (ms)')
xaxis([time_start time_stop])
