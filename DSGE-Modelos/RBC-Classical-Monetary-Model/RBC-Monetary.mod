%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Classical Monetary Model - Gali (Chapter 2)               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "C:\dynare\6.2\matlab" // Para poder iniciar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variables Endógenas
var y, c, n, w_p, pi, i, m_p, r, a;

% Variables Exógenas
varexo e_a, e_i;

% Parámetros

parameters sigma, psi, rho, alpha, phi_pi, phi_a, eta, phi_i;

sigma = 1;
psi = 1;
rho = 0.9;
alpha = 0.33;
phi_pi = 1.5;
phi_a = 0.9;
eta = 4;
phi_i = 0.8;


% Modelo

model;
w_p = sigma*c + psi*n;                 % Oferta de trabajo
c = c(+1)- (1/sigma)*(r);              % Ecuación de Euler
w_p = a - alpha*n;                     % Demanda de trabajo
y = c;                                 % Equilibrio en el mercado de bienes
y = a + (1-alpha)*n;                   % Función de producción
a = phi_a*a(-1) + e_a;                 % Ley de movimiento de la productividad
%i = phi_pi*pi + e_i;                  % Regla de política monetaria sin persistencia 
i = phi_i*i(-1)+phi_pi*pi + e_i;       % Regla de política monetaria con persistencia
m_p = y - eta*i;                       % Demanda de dinero
r = i - pi(+1);                        % Ecuación de Fisher
end;

% Valores iniciales

initval;
y=0;
c=0;
n=0;
w_p=0;
pi=0;
a=0;
i=0;
m_p=0;
r=0;
end;

% Solución

steady;
resid;
check;

% Shocks a la Economía

shocks;
var e_a = 1; %e_a-(0,1)
var e_i = 0;
end;

% Simulación

steady;
stoch_simul(order=1);