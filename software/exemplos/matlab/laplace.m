%mexendo com simbolos: bom para manipulações algebricas

%limpar as variaveis
clc;
clear;

syms A a t y %criando simbolos
f1 = A* exp(-a*t) %montando uma função a partir de simbolos
F1 = laplace(f1) %passando para laplace
f2 = ilaplace(F1)  %destransformando