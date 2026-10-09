clear; close all; clc

load Data_IPM.mat

% inverter parameters
fs=fs_min;            % [Hz] - switching frequency
Ts=1/fs;            % [s]  - sampling time
Vdc=Vdc_max;            % [V]  - DC-link voltage
Imax= I_max;            % [A] -Inverter current rating

%motor parameters 
Ld = Ld_nom;
Lq = Lq_nom;
ld= ld_nom;
lq = lq_nom;
lambda_m=F_m;


% current control calibration
wb=0.1*fs_min*2*pi;        % current control bandwidth

kpd=wb*ld;           % proportional gain
kid=0.05*kpd*wb;      % integral gain

kpq=wb*lq;           % proportional gain
kiq=0.05*kpq*wb;

enc_offset=rand*2*pi;

%% test1
% From no load condition up to the maximum torque 

% set the manual torque switch to the upper switch in order to have a ramp
% torque reference from 0 to the maximum torque required in the operating cycle
% set the manual current switch to the upper switch in order to ensure the 
% current references come from the LUT
% The motor works as a torque generator so the speed is imposed by the
% load. In this configuration set the speed from 0 to the base one with a
% slope that allows you to reach the base speed inside the simulation time


% test2
% FW point @ T= 40Nm , 11483 RPM -

% set the manual torque switch to the lower one in order to have as a torque
% reference a constant of magnitude 40Nm
% set the manual current switch to the lower one in order to manually
% impose the current references based on the torque coutours and flux maps
% set the speed with a ramp from 0 to 11483 RPM again with a slope that ensure
% to reach the desired final speed within the end of the simulation
 
%From voltage constraint I find the rated flux at a certain speed
w_FW_point_m = 11483;
w_FW_point = w_FW_point_m*2*pi*p/60;
rated_flux_FW_point= V_max/w_FW_point;

Id_FW_point = -219.6;
Iq_FW_point = 54.9;
Fd_FW =interp2(Id,Iq,Fd,Id_FW_point,Iq_FW_point);
Fq_FW =interp2(Id,Iq,Fq,Id_FW_point,Iq_FW_point);
F_FW = norm([Fd_FW,Fq_FW]);   %<rated_flux
V = w_FW_point*F_FW ;         %<Vmax 

% Such current ensure the torque required at the FW_point and at the w of 
% the FW_point satisfies the inverter voltage constraint

