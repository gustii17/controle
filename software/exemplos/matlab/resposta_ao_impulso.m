clc;
clear;

% Construct the transfer function
num=[1 0]; % s 
den=[1 12 32]; % s^2 + 12s + 32 
G=tf(num,den)
% Impulse response
impulse(G)
% Construct the input ramp
t=0:0.1:10;
alpha=1; %inclinação
ramp=alpha*t; % r(t) = at

% Simulate and plot the output
[y,t]=lsim(G,ramp,t) %resposta temporal de G para ramp
figure; plot(t,y)