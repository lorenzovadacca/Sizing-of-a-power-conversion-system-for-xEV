clear; close all; clc
load Data11.mat
load Data_DCDC_converter.mat

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
VdcSetpoint=DCDC_vout;  
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






