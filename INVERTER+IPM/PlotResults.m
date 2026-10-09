


%import of simulink data
time=out.tout*1000;  % [ms]
T_ref=out.Tref;
T = out.T;
RPM = out.RPM;
id_sim = out.idq(:,1);
iq_sim = out.idq(:,2);
Pmech = out.Pmech./1000;


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
axis([time_start time_stop -10 w_FW_point_m*1.1])
ax=gca;
ax.FontSize=14;
h=legend('$RPM$','Base speed','Orientation','Vertical');
h.FontSize=10;
ylabel('RPM')
xlabel('Time (ms)')

subplot(2,2,3)
plot(time,id_sim);hold on
plot(time,iq_sim)
axis([time_start time_stop -250 250])
ax=gca;
ax.FontSize=14;
h=legend('$id$','$iq$','Orientation','Vertical');
h.FontSize=10;
ylabel('Current (A)')
xlabel('Time (ms)')

subplot(2,2,4)
plot(time,Pmech);
axis([time_start time_stop -5 80])
ax=gca;
ax.FontSize=14;
h=legend('$Pmech$','Orientation','Vertical');
h.FontSize=10;
ylabel('Power (kW)')
xlabel('Time (ms)')


%plot(time,id_sim,time,iq_sim,time,norm([id_sim,iq_sim]),time,Imax*ones(size(time)))
%legend('id','iq','|idq|','inv.curr.rating')
