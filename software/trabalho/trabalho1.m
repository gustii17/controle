clc
clear
close all

%-------------------------------------------------------
% DEFINIÇÕES GERAIS
%-------------------------------------------------------
tmax = 20;
dt = 0.1; %Intervalo de tempo
tl = 0:dt:tmax; % meu passo de tempo
degrau = ones(size(tl)); %criando um vetor de 1s, com o mesmo tamanho que t

%-------------------------------------------------------
% DEFINIÇÕES FISICAS
%-------------------------------------------------------
%definindo parametors

%gerando meu E
k = 10; %fator de escala
rng(570754); % Define a semente como 
E = k*rand(); % Gera um número aleatório

%calculando os parametros
a = 1.5*(1+ 0.1*E);
b = 3*(1+0.1*E);
v = 10*(1+0.1*E);

%condições
%para as condições iniciais, eu vou ter que tratar o meu gamaP antes de o
%meu sinal entrar no sistema, e o meu Teta como fator de escala.
gamaP = 0;
thetaP = 0;
xP = 0; 
yP = 0;

X_init = [xP; yP; thetaP];




%-------------------------------------------------------
% TAREFA 1
%-------------------------------------------------------

%defina o degral
graus_max = 9.9;
guidao = graus_max*pi/180;

%-------------------%
% SITEMA NÃO LINEAR %
%-------------------%

%definindo nosso degrau em radianos
gama = @(t) guidao;

%criando minha função não linear
[t, espace_state] = ode45(@(t, x)Bicicleta(t, x, a, b, v, gama), [0 tmax], X_init);


x_non_linear = espace_state(:, 1);
y_non_linear = espace_state(:,2);
theta_non_linear = espace_state(:, 3);




%-------------------%
% SISTEMA LINEAR    %
%------------------- %

%montando nosso modelo linearizado
A = [0 0 0; 0 0 v; 0 0 0];
B = [-v *a/b; 0; v/b];
C = [0 0 1];
D = 0;

%criando o meu sistema linearizado
% Cria um objeto LIT e exibe. converte modelos dinamicos em espaço de estados
Sys_linearizado=ss(A,B,C,D);


%resposta ao degral
Gama_l = (guidao*degrau); % amplitude do degral
%nesse cado, como tenho que passar pelo meu sistema a diferença, então, eu subtraio do gamaP
deltaGama = Gama_l - gamaP;

[DeltaTeta, tl, linear_espace_state] = lsim(Sys_linearizado, deltaGama, tl);
% simula a resposta natural de sistemas a uma entrada
x_linear = linear_espace_state(:, 1);  %Não da pra usar x e y, descobri o porquê
y_linear = linear_espace_state(:,2);    %...
theta_linear = linear_espace_state(:, 3);
% obtendo o angulo normal, pois a saida do meu sistema é teta - tetaP

%Comparação de modelo não linar com linear



fprintf('---------------------------------\n');
fprintf('TAREFA 1 - Achar o dregral maximo\n');
fprintf('---------------------------------\n');
fprintf(['\nTemos que adortar alguma metrica para verificar ' ...
    'se nossa aproximação é boa. \nVamos adotar uma proximação tal que se' ...
    'colocassemos um degral teriamos no maximo 1% de erro após 20 segundos\n'])
fprintf('então, mudamos o degral e chegamos a um valor maximo de ')
Error = abs((theta_non_linear(end) - DeltaTeta(end))/(theta_non_linear(end)))  * 100;
fprintf(['\n\nO degral maximo que cumpri esse requisito tem amplitude de %.2f graus,' ...
    ' \ncom erro de %.3f%%\n\n'], graus_max, Error)
fprintf('Na figura 1, você podera ver a resposta do angulo em radianos dos dois modelos ao degral no tempo, \ne na segunda a trajetoria do modelo não linear ao degrau.\n\n ')

%plot sem normalização
%figure(1)
%hold on
%plot(t, theta_non_linear, '-')
%plot(tl, DeltaTeta)
%legend('Non linear Theta', 'Linear Theta')
%hold off

%plot normalizado
figure(1)
hold on
plot(t, mod(theta_non_linear, pi), '-')
plot(tl, mod(DeltaTeta, pi))
legend('Non linear Theta', 'Linear Theta')
xlabel('Tempo (segundos)')
ylabel('Teta(radianos)')
hold off


figure(2)
hold on
plot(x_non_linear, y_non_linear)
legend('Trajetória não linear')
xlabel('eixo x')
ylabel('eixo y')
daspect([1 1 1])
hold of

%-------------------------------------------------------
% TAREFA 2
%-------------------------------------------------------

fprintf('\n\n\n----------------------------------------\n');
fprintf('TAREFA 2 - ANALISAR FUNÇÃO TRANSFERENCIA\n');
fprintf('-----------------------------------------\n');


%-------------------------%
% 1. DERIVANDO A FUNÇÃO G(s) %
%-------------------------%
fprintf('1.\n\n')
fprintf('\nfunção transferencia derifada do nosso espaço de estados: ');
%convertendo meu sistema em entrada e saida
[num2,den2] = ss2tf(A,B,C,D);
Gs=tf(num2,den2)
fprintf('\nnote que é um sistema integrativo\n');

fprintf('-----------------------------------------------------------\n');


%------------------------------%
% 2. ESCOLHA A AMPLITUDE DO DEGRAL%
%------------------------------%
fprintf('2.\n\n')
%escolha a porcentagem da amplitude maxima
porc = 70;

fprintf(['Da questão 1, obtemos nosso maior degrau permitido: %.2f\n' ...
         'então, para que nos obtemos uma entrada segura, poderiamos pegar uma porcentagem dele, por exemplo: %.2f%%\n'], graus_max, porc)
Gama = ((guidao*porc/100)*degrau); 
deltaGama = Gama - gamaP;

[DeltaTeta tl] = lsim(Sys_linearizado, deltaGama, tl);
teta = DeltaTeta + thetaP; 

figure(3)
hold on
plot(tl, teta)
legend('Theta malha aberta')
xlabel('Tempo (segundos)')
ylabel('Teta (radianos)')
hold off
fprintf('obs: na primeira questão plotamos o teta normalizado para o valor no intervalo  [pi -pi], \nmas para diferenciar nessa plotamos o valor absoluto\n');

fprintf('-----------------------------------------------------------\n\n');


%------------------------------%
% 3. METRICAS TRANSIENTES      %
%------------------------------%
fprintf('3.\n\n')
%metricas normais
fprintf('Como o sistema é integrativo, não vamos ter algumas metricas transientes:\n')
fprintf('valor em regime permanente: ele sempre aumenta\n')
fprintf('ganho: não tem ganho dc finito\n')
fprintf('sobressinal percentual: não tem sobressinal\n')
fprintf('tempo de subida: não para de subir\n')
fprintf('tempo de assentamento: não tem assentamento\n')

%erros
fprintf('\n\nMas ainda poderiamos ver outras metricas: sedo o sistema de tipo 2\n')
fprintf('kp = infinito -> Ess = 0\n')
fprintf('kv = 3.3 -> Ess = 0.303\n')
fprintf('ka = 0 -> Ess = infinito\n')
%infos = stepinfo(Gs);

fprintf('-----------------------------------------------------------\n\n');

%------------------------------%
% 4. MAPA DE POSOS E ZEROS     %
%------------------------------%
fprintf('4.\n\n')


figure(4)
hold on
h=pzplot(Gs); grid on
hold of

fprintf(['o sistema so contem um polo no centro, (0,0), o que o caracteriza como um sistema integrador\n' ...
    'Por seu polo no centro, ele é um sistema que não é amortecido, tendendo ao infinito, e por isso não tem metricas transientes\n' ...
    'assim, ele é instavel, visto que para uma entrada finita, (degral), ele tem uma saida infinita (rampa)\n '])


fprintf('-----------------------------------------------------------\n\n');

%------------------------------------------------------%
% 5. matriz de contolabilidade e observabilidade       %
%------------------------------------------------------%
fprintf('5.\n\n')
%para entendimento, veja: https://www.youtube.com/watch?v=4WBH2E32LzU 



%A matriz de confiabilidade é calculada da seguinte forma
%Mc = [B AB (A^2)B ... (A^n-1)B]
%ela nos da informações sobre se é possivel controlar o sistema, ou seja,
%se é possivel, eu partido
%se uma condição inicial, chegar a qualquer outra condição do meu sistema;

fprintf('Matriz de confiabilidade:\n ')
% Matriz de Controlabilidade
Mc = ctrb(A, B)

%Ja a matriz de obsrvabilidade é calculada da seguinte forma:
%Mo = [C; CA; C(A^2); ....; C(A^n-1)]
%ela nos da a informação de que, se eu tiver o conjunto de saidas do meu
%sistema, eu consigo saber qual seria as condições inicias do mesmo. E,
%portanto, tambem saberia toda a dinamica do meu sistema.
fprintf('\nMatriz de observabilidade:\n ')
% Matriz de Observabilidade
Mo = obsv(A, C)

% Checagem de Posto
n = length(A) % Número de estados
PMc = rank(Mc) %posto MC
PMo = rank(Mo) %posto Mo


fprintf(['A matriz de controlabilidade me fornece a informação se o sistema pode ser controlado, para que ele seja\n' ...
        'totalmente controlado, o posto dele tem que ser completo, ou seja, Rank(MC) = rank(A). Entretanto, é observado\n' ...
        'que o posto de A = %i e o posto de Mc = %i, o que nos intui que o sistema não é totalmente controlavel, ou seja, eu \n' ...
        'não conseguiria controlar x, y, e teta livremente, um seria dependente dois outros. Mas, ainda assim, pelo posto ser 2,\n' ...
        ' eu conseguiria controlar dois desses tres estados, então ainda conseguimos o nosso objetivo de controlar o teta, visto \n' ...
        'também por que ele depende somente da entrada.\n\n'], n, PMc)

fprintf(['A matriz de observabilidade me fornece a correlação entre a entrada e os estados iniciais. ou seja, se a partir da saida eu consigo\n' ...
        'calcular as condições iniciais do sistema. Para isso, o posto tem que ser completo, ou seja, Rank(MC) = rank(A). Entretanto, é observado\n' ...
        'que o posto de A = %i e o posto de Mo = %i, o que nos intui que o sistema não é totalmente observavel, ou seja, atravez do conecimento\n' ...
        'sobre a dinamica do sistema, e da saida do sistema, eu so conseguiria reconstruir um dos estados inicis. Como a saida esta em função do teta, e o teta\n' ...
        'não depende de nenhum outro estado, então o estado que eu consigo observar é o teta. Em termos do nosso objetivo, isso parece favoravel, visto que, mesmo\n' ...
        'eu não conseguindo ter uma noção de todos os estados, como o teta é o unico que importa para a minha realimentação, eu consigo observar a dinamica importante do sistema.\n'], n, PMo)

fprintf('\n-----------------------------------------------------------\n\n');
%------------------------------%
%  SIMULAÇÃO                   %
%------------------------------%

%----------------------
%interludio
tmax = 100;
dt = 0.1;
tl = 0:dt:tmax; 
degrau = ones(size(tl)); 
figure(5)
hold on
ki = 15;
kp = 0.17* ki;
Controlador = tf([kp ki],[1 0]);
T=feedback(Controlador*Gs,1);
h=pzplot(T); grid on
hold off
%np = nyquistplot(Gs);
%sisotool(Gs)
%---------------

%Entradas para o sistema linear e não linear
k_amp = pi/3;
U = tl; %k_amp * sin(tl); 
U_non_linear = @(t) t; %k_amp * sin(t);


%Simulação do sistema linear
[DeltaTeta tl] = lsim(T, U, tl);
T;


%Gerando função malha fechada sem controlador no sistema não linear

[t_nc, espace_state] = ode45(@(t,x) bike_malha_fechada(t, x, a, b, v, U_non_linear), [0 tmax], X_init);

x = espace_state(:, 1);
y = espace_state(:, 2);
theta_non_linear = espace_state(:, 3);

%Interpolação necessária para os plots
U_nc = interp1(tl, U, t_nc, 'linear', 'extrap');

%Gerando a função de malha fechada + controlador no sistema não linear
controlador_ss = ss(Controlador);
[t_c, espace_state] = malha_fechada_com_controlador(a, b, v, U_non_linear, X_init, controlador_ss, tmax);

x_c = espace_state(:, 1);
y_c = espace_state(:, 2);
theta_non_linear_c = espace_state(:, 3);


%Interpolação necessária para fazer os plots
U_c= interp1(tl, U, t_c, 'linear', 'extrap');



figure(6)
hold on
plot(t_c, theta_non_linear_c, '-')
plot(tl, DeltaTeta)
plot(t_nc, theta_non_linear)
plot(tl, U)
legend('Non linear Theta', "Linar theta", 'Sem controlador', "Desejado")
hold off

figure(7)
hold on
plot(t_c, U_c - theta_non_linear_c, '-')
plot(tl, U - DeltaTeta)
plot(t_nc, U_nc - theta_non_linear)
legend('e\_Non-linear', "e\_Linar", 'Sem controlador')
hold off



figure(8)
hold on
plot3(x, y, t_nc, '-')
plot3(x_c, y_c, t_c, '-')
legend('Sem controlador', 'Com controlador')
daspect([1 1 1])
hold off






function dxdt = controlador_com_bike(t, x, a, b, v, ref,  controlador)
                                   
    X_bike = x(1:3);
    X_ctrl = x(4:end);

    Ac = controlador.A;
    Bc = controlador.B;
    Cc = controlador.C;
    Dc = controlador.D;

    erro = ref(t) - X_bike(3); %Entrada do controlador
    gama = Cc*X_ctrl + Dc*erro; %Saída do controlador

    k = X_bike(3) + atan((a/b)*tan(gama));
    dx1 = v*cos(k);
    dx2 = v*sin(k);
    dx3 = (v/b)*tan(gama);
    dxdt_bike = [dx1; dx2; dx3];
       
    dxdt_ctr = Ac*X_ctrl + Bc*erro;
    
    dxdt = [dxdt_bike(:); dxdt_ctr(:)];
end

function dxdt = bike_malha_fechada(t, x, a, b, v, ref)
    X_bike = x;
    
    erro = ref(t) - X_bike(3); %Entrada
    gama = erro;

    
    k = X_bike(3) + atan((a/b)*tan(gama));
    dx1 = v*cos(k);
    dx2 = v*sin(k);
    dx3 = (v/b)*tan(gama);
    dxdt_bike = [dx1; dx2; dx3];
        
    dxdt = dxdt_bike(:);
end


function [t, estados] = malha_fechada_com_controlador(a, b, v, U, X_bike, controlador, tmax)
    X_bike_inicial = X_bike;
    X_ctr_inicial = zeros(size(controlador.A, 1), 1);

    X_total = [X_bike_inicial; X_ctr_inicial];

    [t, estados_x] = ode45(@(t,x) controlador_com_bike(t, x, a,b,v, U, controlador), [0 tmax], X_total);
    estados = estados_x(:, 1:3);
end

function dxdt = Bicicleta(t, x, a, b, v, gama)
    alfa = atan((b/a)*tan(gama(t)));
    k = x(3) + alfa;
    dx1 = v*cos(k);
    dx2 = v*sin(k);
    dx3 = (v/b)*tan(gama(t));
    dxdt = [dx1; dx2; dx3];
end