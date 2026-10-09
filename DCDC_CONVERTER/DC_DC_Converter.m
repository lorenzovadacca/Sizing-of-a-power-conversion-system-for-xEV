clear all;close all;clc
load('Data11.mat')

%% TASK1
% Sizing of the input inductor of the DC-DC converter. Computation of the 
% voltage stress for power devices and define the rated voltage of power devices.
% Computation of the current stress for the power devices and the input
% inductor.
%Power devices include power diodes,power MOSFET and IGBT 

% d (duty cycle)
% convenzione transistor superiore
d = DCDC_vbatt/DCDC_vout
fsw = DCDC_fsw*1000   %[Hz]
Pout = DCDC_Pmax_kW*1000  %[W]


% P_in (input power)
% Dalla P_max con efficienza stimata a 0.95, troviamo P_in
eta = 0.95
P_in = Pout / eta   %[W]

% I_in_rated (input rated current = average inductor current)
I_in_rated = P_in/DCDC_vbatt   %[A]

% dI_in (ripple)
dI_in =  I_in_rated * DCDC_dIbatt/100    %[A]

% Computation of L (inductance)
L = 1/dI_in * (DCDC_vout*(1-d)*d)/fsw

%current stress on L
I_L_avg = I_in_rated
I_L_ripple_rms = dI_in / (2*sqrt(3))
I_L_rms = sqrt(I_L_avg^2 + I_L_ripple_rms^2)

% I_load si trova come P_out/DCDC_vout
I_load = Pout/DCDC_vout   %[A] 

%With reference pag 39 and 38 lecture04, when iL<0 and q =1 D1 is
%conducting while when iL<0 and q = 0 T2 is conducting. Since the request
% is to compute the current stress for a boost converter we are always in 
%these 2 cases. 

%current stress on D1
I_D1_avg= d*I_L_avg
I_D1_rms = sqrt(d)*I_L_rms

%current stress on T2
I_T2_avg = (1-d)*I_L_avg
I_T2_rms = sqrt(1-d)*I_L_rms

%current stress on the output capacitor
% I_Co = I_D1 - I_L
I_Co_avg = 0   %for capacitor charge balance
I_Co_rms = sqrt(I_D1_rms^2 - I_load^2)

%Voltage stress on T1 and D1 (maximum applied voltage at their ends)
V_power_devices = DCDC_vout

%According with this kind of voltage stress and switching frequency we can
%adopt both IGBTs(slower buth higher voltage) or MOSFET(faster but lower max voltage)
% as transistors 

%% TASK2 Design of the DC-DC converter cascaded control.

%Design of the inner current control loop (p.16 es01_dcdc_boostconverter)

%OPEN LOOP approach
%I set the crossover frequency at 1/10 of the switching one (ensure a good
% phase margin) imposing the proportional gain
wc_i = 2*pi*fsw/10
kpi = L*wc_i
% wc_i is approximated as kpi/L since the converter pole occurs at much
% higher frequency

%Then I impose the controller zero at 1/10 of the converter pole (prof
%choice)
%delay introduced by the converter tau_d = 1.5*Ts
tau_d = 1.5/(fsw)
wzi = 1/(10*tau_d)

%Calculate the integral gain 
kii = wzi *kpi

%check of crossover frequency and phase margin
s = tf('s');
HOL_i = zpk(kpi*(s+wzi)/((L*s^2)*(1+s*tau_d)))
bode(HOL_i),zoom on,grid on
%I get wb_i = 11500 rad/s and wc_i = 9100 rad/s and a phase margin of 45.3° 


%Design of the outer voltage control loop 

%First of all we set the crossover frequency at 1/10 of the current, that
%is 1/10 of the switching frequency
%bandwidth loop to ensure the outer loop to be slower
wc_v = 2*pi*fsw/(10*10)


%I compute accordingly the proportional gain since wc_v =kpv/Co
kpv = (DCDC_Co*10^-6)*wc_v

%Then I impose a phase margin of 60 degree by setting wzv
wzv = wc_v/sqrt(3)

%I finally compute the integral gain
kiv = kpv*wzv

% check on crossover frequency
HOL_v = zpk(kpv*(s+wzv))/((DCDC_Co*(10^-6)*s^2))
figure
bode(HOL_v),zoom on,grid on
%I get wb_v = 1700 rad/s and wc_v = 1270 rad/s and a phase margin of 63°

save Data_DCDC_converter
