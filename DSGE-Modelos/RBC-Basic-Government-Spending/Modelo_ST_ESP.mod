%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Modelo Estándar                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "C:\dynare\6.2\matlab" // Para poder iniciar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% En primer lugar, definimos las variables endógenas y exógenas:
var y, c, k, i, h, w, z;
varexo e;

% Definimos los parámetros:
parameters theta, delta, beta, rho, sigma_e, A;

% Les damos los valores de la calibración hecha anteriormente:
theta = 0.42209;
delta = 0.05193;
beta  = 0.96350;
rho   = 0.97895;
sigma_e = 0.22188;
A  = 3.56788;

% Definimos las ecuaciones para la resolución del modelo:
model;
(c*A)/(1-h) = (1-theta)*y/h;                          % Condición Intratemporal
c(+1)/(beta*c) = 1 + theta*y(+1)/k - delta;           % Ecuación de Euler
c + i = y;                                            % Regla de Contabilidad
y = z*(k(-1)^theta)*(h^(1-theta));                    % Función de producción
k = i + (1-delta)*k(-1);                              % Ley de acumulación de capital
z = exp(rho*log(z(-1)) + e);                          % Evolución del proceso tecnológico
w = y/h;                                              % Demanda de trabajo
end;

% Para realizar la simulación, es necesario tener un punto de partida sobre el
% cual realizar los shocks. Dicho punto de partida será el estado estacionario
% no estocástico pues representa el punto donde la economía se encuentra en
% equilibrio. Para ello, es necesario calcularlo previamente según los parámetros
% de la economía:

initval;
z = 1;
y = 0.54639174;
k = 2.56785999;
c = 0.41304277;
h = 0.17645916;
w = 3.09642034;
e = 0;
end;

% Estos valores representan el equilibrio en ausencia de shocks estocásticos (e = 0)
% Finalmente, le indicamos al programa cuál es la amplitud (varianza) de los
% shocks de modo que pueda simular un shock que cumpla con dicha condición:

shocks;
var e; stderr sigma_e;
end;

% Al ser nuestro shock muy persistente hacemos una simulación a 200 periodos
stoch_simul(order=1, irf=200);