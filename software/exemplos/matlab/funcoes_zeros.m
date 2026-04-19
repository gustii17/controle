%analisando o compostamento de uma função para diferentes zeros

%limpando variaveis e terminal
clc;
clear;

deng=[1 2 9];
alpha=[3, 5, 10];
Ta=tf([1 alpha(1)]*9/alpha(1),deng)
Tb=tf([1 alpha(2)]*9/alpha(2),deng)
Tc=tf([1 alpha(3)]*9/alpha(3),deng)
T=tf(9,deng)
step(T,Ta,Tb,Tc); legend