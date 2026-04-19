
%criando um resposta ao degral
clc; %limpa o terminal
clear; %limpa as variaveis armazenadas
num=1
den=[1 2]
model=tf(num,den) % criar a função transferencia
step(model) %resposta ao degral