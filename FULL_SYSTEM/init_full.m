

clear; close all; clc
load Data11.mat
load Data_DCDC_converter.mat
load Data_IPM.mat

%% DCDC CONVERTER
% converter parameters
fs=DCDC_fsw*1000;            % [Hz] - switching frequency
Ts=1/fs;            % [s]  - sampling time
Vbat=DCDC_vbatt;           % [V]  - input battery voltage
Tau_d=1.5*Ts;
TimeEnable=5e-3;

% Converter reactive elements
Lin=L;                  % [H]Input inductor
Co=DCDC_Co*(10^-6);     %[F] Output capacitance

%References
VdcSetpoint= Vdc_max;  
Trise=25e-3;
Iload=I_load;
TimeLoad=0.06;
IinMax=I_in_rated;

% Design of cascaded voltage and current control
% Current control loop gains
fci=fs/10;           %crossover frequency of current control loop
wci=2*pi*fci;
kpi=wci*Lin;        % proportional gain current controller
wzi=(1/Tau_d)/10;   % frequency of controller zero
kii=wzi*kpi;        % integral gain of the current controller

% Voltage control loop gains
fcv=fci/10;            %Crossover frequency of voltage control loop
wcv=2*pi*fcv;
kpv=wcv*Co;         % proportional gain voltage controller
wzv=wcv/sqrt(3);    %zero frequency for a phase margin of 60 electrical degrees
kiv=kpv*wzv;        % integral gain voltage controller

%% IPM MACHINE

% inverter parameters
fs_inv=fs_min;            % [Hz] - switching frequency
Ts_inv=1/fs_inv;            % [s]  - sampling time
Vdc=Vdc_max;            % [V]  - DC-link voltage
Imax= I_max;

% Parameters
Ld= Ld_nom;
Lq = Lq_nom;
ld = ld_nom;
lq = lq_nom;
lambda_m=F_m;


% current control calibration
wb=0.1*fs_min*2*pi;        % current control bandwidth

kpd=wb*ld;           % proportional gain
kid=0.05*kpd*wb;      % integral gain

kpq=wb*lq;           % proportional gain
kiq=0.05*kpq*wb;

enc_offset=rand*2*pi;

%% How to merge the 2 models?

% First of all, set Vdc_setpoint in the DCDC converter subsystem equal to the one 
% associated with the required inverter DC link voltage previously found 
% imposing the rated flux (associate with the maximum torque required) and 
% the imposed base speed
% Then, you have to modify the Iload/Idc to constantly follow the 
% inverter current request. The idea here is to start from the output mechanical 
% power simply multiplying the motor torque with the mechanical speed.
% Then assuming an efficiency of the block inverter +IPM machine of 90%, we 
% are able to determine the DCDC converter output power necessary.
% Finally, we divide such output power for the vdc voltage and we get
% the Idc/Iload , which subtracts to the output current gives the input
% capacitor current. Integrating such current and imposing an initial
% condition for the capacitor voltage I retrieve the output voltage vdc.

%% 
% test
%One point below the base speed
% T=100.6Nm   RPM = 2459

% Being below the base speed we can work on the MTPA 
w_mech = 2459;


