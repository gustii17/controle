clc;
clear;



%questão 2
%analisando diferentes zeros
clc;
a = 0;
list = [0 -5 -2 1 2  5];

%criando o grafico
figure(1);
hold on;

for i = 1:6
    %obtendo o a
    a = list(i);
    num = [a 1];
    dem = conv([1 5], [2 5 2]);
    Gs = tf(num, dem); %cirando a função
    
    t = 0:0.1:10; % meu passo de tempo
    degrau = ones(size(t)); %criando um vetor de 1s, com o mesmo tamanho que t
    
    [y t] = lsim(Gs, degrau, t); % simula a resposta natural de sistemas a uma entrada
    plot(t, y)
end
legend('a=1','a=2','a=3','a=4', 'a=5','a=6');
hold off

%questão 3
clear;
clc;

%matrizes
A = [0 1; -4 -5];
B = [0; 1/4];
C = [13 9];
D = [0 0];

%calculo para descobrir minha função transferencia
syms s t;
I = [1 0; 0 1];
As = (s*I - A);
ASI = As^-1;
Y = C * ASI;
Hs = Y * B;
Hs = simplify(Hs);


%questão 4
clear;
syms s t; % simbolos
%funções em laplace
F1 = (s - 10) / ((s + 5)*(s+2));
F2 = 100 / ((s + 1)*(s^2+4*s+13));
F3 = (s+18) / (s*((s+3)^2));
%destransformando
f1 = ilaplace(F1, s, t)
f2 = ilaplace(F2, s, t)
f3 = ilaplace(F3, s, t)

