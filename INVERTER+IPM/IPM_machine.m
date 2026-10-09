%% CLEAN SECTION
clc

clear all
close all

load Data11.mat


%% MOTOR CHARACTERISTICS
%Looking at the current matrices we notice the row 256 of iq is null and
%the coloumn 256 for id is null. If I plot the corresponding flux entries 
%in those position I can evaluate the flux obtained with the contribute of
%only one of the 2 currents.

%plotting of the 3D flux maps
figure
subplot(1,2,1)
mesh(Id,Iq,Fd),hold on
plot3(Id(256,:),Iq(256,:),Fd(256,:),'k','LineWidth',3)  %to visualize lambdad(id!=0, iq=0)

xlabel('$i_d$ (A)', 'FontSize', 15 , 'Interpreter', 'latex');ylabel('$i_q$ (A)','FontSize', 15 ,'interpreter','latex');zlabel('\lambda_d (Vs)');
view(3)
subplot(1,2,2)
mesh(Id,Iq,Fq)
xlabel('$i_d$ (A)','FontSize', 15,'interpreter','latex');ylabel('$i_q$ (A)','FontSize', 15,'interpreter','latex');zlabel('\lambda_q (Vs)');
view(3)


% Find the value of the flux for the provided currents (p.25 Lecture09)
F_m = interp2(Id,Iq,Fd,0,0);
F_q_zero_curr = interp2(Id,Iq,Fq,0,0);
%For zero currents I have a flux on the d direction -->this means 
% SPM or IPM because for PM-SyR I would have obtained  a negative flux in 
% the q axis, while for a SyR I would not have found any flux both in d 
% and q axis due to the lack of PMs.

%number of pole pairs
pole_pairs = p;

%stator resistance 
Rs;

%MTPA and MTPV trajectory
figure
T=1.5*p*(Fd.*Iq-Fq.*Id);
[c1,h1]=contour(Id,Iq,T,'r','LevelStep',10);
set(gca,'DataAspectRatio',[1 1 1])
hold on,grid on
plot(id_KtMax,iq_KtMax,'b',id_KvMax,iq_KvMax,'k')
legend('T','MTPA','MTPV')
xlabel('i_d (A)');ylabel('i_q (A)');

%MTPA and MTPV are in the second quadrant -->IPM machine(p.33 Lecture11)


%%  INDUCTANCES

%Definition of apparent and differential inductances p.26 L09
%To evaluate the apparent inductance, according to the magnetic model we
%have to remove from the total flux the one which comes from the magnet.
%What we get are differential inductances superimposed with the apparent
%ones in the first quasi linear trait and Ld much lower than Lq as expected
Ld = (Fd(256,256:end)-F_m)./Id(256,256:end);
Lq = (Fq(256:end,256)-F_q_zero_curr)./Iq(256:end,256); 
ld = diff(Fd(256,256:end))./diff(Id(256,256:end)); 
lq = diff(Fq(256:end,256))./diff(Iq(256:end,256));

%diff fuction reduces the length of 1
Id_der = Id(256,256:end-1);
Iq_der = Iq(256:end-1,256);

% Plot the apparent and differential inductances on varying the current
%Aware of the symmetry wrt the current axis we do our consideration only 
% for positive currents

figure
subplot(211) 
plot(Id(256,256:end),Fd(256,256:end)),hold on
coeff = polyfit(Id(256,256:end),Fd(256,256:end),1);
y = polyval(coeff,Id(256,256:end));
plot(Id(256,256:end),y,'r--')
xline(200,'--')
xlabel('$i_d$ (A)', 'FontSize', 15 , 'Interpreter', 'latex')
legend('Fd real','Fd approx')
title('Flux on d axis')

subplot(212)
plot(Id(256,256:end),Ld),hold on,zoom on,grid on
plot(Id_der,ld)
xline(200,'--')
xlabel('$i_d$ (A)', 'FontSize', 15 , 'Interpreter', 'latex')
legend('Ld','ld')

figure
subplot(211) 
plot(Iq(256:end,256),Fq(256:end,256)),hold on
coeff = polyfit(Iq(256:end,256),Fq(256:end,256),1);
y = polyval(coeff,Iq(256:end,256));
plot(Iq(256:end,256),y,'r--')
xline(200,'--')
xlabel('$i_q$ (A)', 'FontSize', 15 , 'Interpreter', 'latex')
legend('Fq real','Fq approx')
title('Flux on q axis')

subplot(212)
plot(Iq(256:end,256),Lq),hold on,zoom on,grid on
plot(Iq_der,lq)
xline(200,'--')
xlabel('$i_q$ (A)', 'FontSize', 15 , 'Interpreter', 'latex')
legend('Lq','lq','nominal point')

%Nominal value (good trade off between linear trait and saturation region)
%differential inductance d
ld_nom  =1.10e-4;
%apparent inductance d
Ld_nom = 1.21e-4

%differential inductance q
lq_nom  =3.45e-4;
%apparent inductance q
Lq_nom = 4.94e-4

% For FOC calibration (parameters of the PI regulators) we need the
% differential inductances while motor control simulation I will use the
% apparent inductance

%chat 
%Calibration: Differential inductance is used for calibration because it 
%provides a more precise measurement of the [motor's dynamic and nonlinear 
%properties. This accuracy is essential for fine-tuning the control 
%algorithms to account for varying operating conditions

%Simulation: Apparent inductance is used for motor control simulation 
%because it offers a simplified representation of the motor's inductive
%behavior under steady-state conditions. This simplification enhances
%computational efficiency and stability in control algorithm development.


%% OPERATING CYCLE -->INVERTER CONSTRAINT

Tmax = max(Cycle_T)
%Based on the torque map and on the MTPA I find the corresponding dq current

T_KtMax = 1.5*p*(F_m*iq_KtMax-(Lq_nom-Ld_nom)*id_KtMax.*iq_KtMax);

%Torque map ,MTPA and MTPV
T = 1.5*p*(Fd.*Iq - Fq.*Id);

% Assuming a good flux weakening capability means Io=Imax (null torque at
% infinite speed) -->Torque decrease as 1/w so power capability is
% maintained

I_T_max = [-186.6 ,205.8];   % [id, iq]  %ensure a torque of around 124Nm
% (10% higher than the maximum required)
I_max = norm([I_T_max]) 
%base speed is reached when the MTPA trajectory reaches the inverter
%maximum currenet limits and the point where MTPA touches the base speed


% At base speed we have Vmax = flux_max * wbase
%The maximum flux is related to the currents 
rated_flux = norm([interp2(Id,Iq,Fd,I_T_max(1),I_T_max(2)),interp2(Id,Iq,Fq,I_T_max(1),I_T_max(2))])

%In order to include all the cycle points + a tolerance band we opted for 
% a base mechanical speed of 6000rpm 
w_base_mech =6000;
wbase = (6000/60)*2*pi*p;   %[electrical base speed]
V_max  = rated_flux*wbase;  
Vdc_max = V_max*sqrt(3)  %<Vdc rated of the DCDC comverter -->OK

Id_FW = linspace(I_T_max(1),-I_max,1000);   %from MTPA to current on d axis
Iq_FW = sqrt(I_max^2-Id_FW.^2);
Fd_FW = interp2(Id,Iq,Fd,Id_FW,Iq_FW);
Fq_FW = interp2(Id,Iq,Fq,Id_FW,Iq_FW);

delta=atan2(Fq_FW,Fd_FW); 
gamma=atan2(Iq_FW,Id_FW);

F_FW =sqrt(Fd_FW.^2+Fq_FW.^2);
w_FW = (V_max)./F_FW;     %I am neglecting the stator resistance

%equivalent form to compute the torque in FW
Tmaxi=(3/2*p*V_max*I_max*sin(gamma-delta)./w_FW);
T_FW = 1.5*p.*F_FW.*I_max.*sin(gamma-delta);
T_FW = 1.5*p*(Fd_FW.*Iq_FW - Fq_FW.*Id_FW);

figure
[c1,h1] = contour(Id,Iq,T,'r','LevelStep',10),hold on
plot(id_KtMax,iq_KtMax,'b',id_KvMax,iq_KvMax,'g',Id_FW,Iq_FW,'b--')
legend('T','MTPA','MTPV','I_{max}')
xlim([-Inf,0]),ylim([0,Inf])      %to limit the plot inside the 2nd quadrant
xlabel('i_d (A)');ylabel('i_q (A)');

figure
plot(Cycle_n,Cycle_T,'o','MarkerEdgeColor','k','MarkerFaceColor','g'),hold on,grid on
plot(linspace(0,w_base_mech,1000),124*ones(1000,1),'r')  %approximated torque capability in FW
plot(linspace(0,w_base_mech,1000),-124*ones(1000,1),'r')
plot(linspace(w_base_mech,16000,1000),(124.*w_base_mech)./linspace(w_base_mech,16000,1000),'g')
plot(linspace(w_base_mech,16000,1000),(-124.*w_base_mech)./linspace(w_base_mech,16000,1000),'g')
plot(w_FW*p,T_FW,'r')
plot(w_FW*p,-T_FW,'r')
xlabel('n (rpm)'),ylabel('T (Nm)')

figure
subplot(211)
plot(gamma,F_FW,'k'),grid on,zoom on
ylabel('\lambda (Vs)','FontSize',12)
xlabel('\gamma (rad)','FontSize',12)
subplot(212)
plot(gamma,T_FW,'k'),grid on,zoom on
ylabel('max T (Nm)','FontSize',12)
xlabel('\gamma (rad)','FontSize',12)

%Minimum Switching frequency determination p14 L05
RPM_max = max(Cycle_n);

fs_min = 22*RPM_max/60*p  

%modulation minimum frequency index=20+2(safety margin). From the maximum mechanical frequency 
% multiplied by the pole pairs I get the maximum electrical frequency that 
% my inverter must produce


save Data_IPM

 


