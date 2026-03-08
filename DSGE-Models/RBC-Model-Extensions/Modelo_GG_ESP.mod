%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Modelo con Gastos de Gobierno                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "C:\dynare\6.2\matlab" // Para poder iniciar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var y, c, k, i, h, w, z, g;
varexo e, u;

parameters theta, delta, beta, rho, sigma_e, g_bar, lambda, sigma_u, A;

theta = 0.42209;
delta = 0.05193;
beta  = 0.9635;
rho   = 0.97895;
sigma_e = 0.22188;
g_bar = 0.13258;
lambda = 0.97753;
sigma_u = 0.04329;
A  = 3.56788;

model;
(c*A)/(1-h) = (1-theta)*y/h;                          % Condición Intratemporal
c(+1)/(beta*c) = 1 + theta*y(+1)/k - delta;           % Ecuación de Euler
c + i + g = y;                                        % Regla de Contabilidad
y = z*(k(-1)^theta)*(h^(1-theta));                    % Función de producción
k = i + (1-delta)*k(-1);                              % Ley de acumulación de capital
z = exp(rho*log(z(-1)) + e);                          % Evolución del proceso tecnológico
g = exp((1-lambda)*log(g_bar)+lambda*log(g(-1))+u);   % Evolución del gasto gubernamental
w = y/h;                                              % Demanda de trabajo
end;

initval;
z = 1;
g = 0.13181;
y = 0.63800705;
c = 0.39820331;
h = 0.20604665;
k = 2.9984216;
w = 3.09642034;
u = 0;
end;

shocks;
var u; stderr sigma_u;
var e; stderr sigma_e; %% Se puede quitar, para el caso 2 del Modelo - Tabla 3
end;

stoch_simul(order=1, irf=200);