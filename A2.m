%% Assignment 2 - Part 1
clc; clear;
%% Problem 1 - Open-loop analysis

V_a = 580;  % [km/h]

A = [-0.322 0.052 0.028 -1.12 0.002;...
    0 0 1 -0.001 0;...
    -10.6 0 -2.87 0.46 -0.65;...
    6.87 0 -0.04 -0.32 -0.02;...
    0 0 0 0 -7.5];

B = [0 0 0 0 7.5]';

C = [eye(4,5)];

D = [0 0 0 0]';

%% c) Dutch-roll natural frequency and relative damping ratio
format long
damp(A)


%% Problem 2 - 
z_aMax= 30;          %degrees
e_rollMax = 15;      %degrees
z_rollDamp = 0.707;  %Damping factor for transfer function Phi/Phi_c(s)

a_phi1=  2.87;
a_phi2= -0.65;


k_pPhi = (z_aMax/e_rollMax)*sign(a_phi2);

omeg_NatRoll = sqrt(k_pPhi*a_phi2);

k_dPhi = (2*z_rollDamp*omeg_NatRoll - a_phi1)/(a_phi2);

%k_iPhi = [-20:0.1:20];
k_iPhi = 0;

TF=tf([a_phi2*k_dPhi],[1,(a_phi1+a_phi2*k_dPhi),(a_phi2*k_pPhi),0]);

%%
rlocus(TF,k_iPhi)
title('Root Locus')

%% Open-Loop (no integrator)
TF2=tf([a_phi2],[1,(a_phi1+a_phi2*k_dPhi),(a_phi2*k_pPhi)]);
%% Closed (w. integrator), but no Evan..
%k_iPhi=0;
TF3=tf([a_phi2, a_phi2*(k_iPhi/k_pPhi)],[1,(a_phi1+a_phi2*k_dPhi),(a_phi2*k_pPhi), a_phi2*k_iPhi]);

%% Course Hold:
V_a=580;            % [km/h]
V_g=V_a*(1000/(60*60));            % Under assumtions of no wind
g=9.81;             % Gravity Constant

d=1.5;              % Disturbance/bias 1.5[degrees]

Fact=10;             % Usually between 5-10
z_courseDamp= 0.8;    % Course damping factor (Up to us)(Bigger = more BW)
omeg_NatPsi = (1/Fact)*omeg_NatRoll; % Natural frequency (To be chosen)

k_pPsi = 2*z_courseDamp*omeg_NatPsi*(V_g/g);
k_iPsi = omeg_NatPsi^2*(V_g/g);

% Course Control Input:

t=[0:60:1000-60*3];           % Time and time-steps of 5 sec
CourseRef=[0,5,15,15,20,18,(18+15),28,17, 10*ones(1,5)];

CCI=[t' CourseRef'];
%% 2 d)
CS=Course_States;

plot(CS.time,CS.data, 'r'); hold on; grid on;
stairs(CCI(:,1),CCI(:,2), 'b');
title('Course for simplified model', 'FontSize', 14)
xlabel('time [s]','FontSize', 12)
ylabel('Course [degrees]','FontSize', 12)
legend('Simplified model','Course Ref')


%% 2 e)
AI1=Aileron_Inputs;
AI2=Aileron_Inputs2e;
CCM=Course_CompleteModel;

plot(CS.time,CS.data, 'r'); hold on; grid on;
plot(CCM.time,CCM.data, 'b');
stairs(CCI(:,1),CCI(:,2), 'g');

title('Simplified vs true dynamics', 'FontSize', 14)
xlabel('time [s]','FontSize', 12)
ylabel('Course [degrees]','FontSize', 12)
legend('Simplified model','True dynamics', 'Course Ref')

%% Aileron Inputs
plot(AI1.time,AI1.data, 'm'); hold on; grid on;
plot(AI2.time,AI2.data, 'g');
title('Aileron Inputs for simplified and true dynamics', 'FontSize', 14)
xlabel('time [s]','FontSize', 12)
ylabel('Aileron [degrees]','FontSize', 12)
legend('Aileron Inputs - Simplified','Aileron Inputs - True dyn.')

%% 2f)
k_fPsi=100000000000;
CCMWIND=Course_CompleteModelWindup;

plot(CCMWIND.time, CCMWIND.data, 'b'); hold on; grid on;
plot(CCM.time, CCM.data, 'r');
stairs(CCI(:,1),CCI(:,2), 'g');
title('Course with and without anti-windup', 'FontSize', 14)
xlabel('time [s]','FontSize', 12)
ylabel('Course [degrees]','FontSize', 12)
legend('True dyn. w. anti-windup - 2f)','True dyn. - 2e)', 'Course Ref')









