%% Parte 1
%***********************************************
%* Trabajo Final - Crecimiento y Fluctuaciones *
%***********************************************
%***********************************************
%**   Prof: Cristian Adderly Maravi Meneses   **
%**    Asist: Valerie Lucía Hinsbe Vilela     **
%***********************************************
%**		   		  Integrantes				  **
%***********************************************
%**		  Cordova Ramos, Evelyn Abigail		  **
%**       Cotrina Lejabo, José Fernando       **
%** 	Gonzaga Vargas, Carlos Guillermo      **
%**     Serrano Saldarriaga, Samuel Gerardo   **
%**		    Pulache Ramos, Abraham Joel		  **

file= 'G:\Mi unidad\Trabajos\Trabajos Crecimiento y Fluctuaciones\TRABAJO CYF\TRABAJO FINAL CYF\pwt1001.xlsx';
[data, text, raw] = xlsread(file);

% Variables de interés
varNames = {'year', 'countrycode', 'csh_c','pop', 'rgdpe', 'rconna', 'csh_i', 'cn', 'irr','delta','avh','emp','labsh','csh_g'};
varIndices = [];
for x = 1:numel(varNames)
    varIndex = find(strcmp(text(1, :), varNames{x}));
    varIndices = [varIndices, varIndex];
end

% Filtrar data para España
countrycodeCol = find(strcmp(text(1, :), 'countrycode'));
usaRows = strcmp(raw(2:end, countrycodeCol), 'ESP');

fEsp = raw([false; usaRows], varIndices);
Esp = cell2table(fEsp, 'VariableNames', varNames);

% Variables Macroeconómicas
Esp.Properties.VariableNames{'rgdpe'} = 'PIB'; % PIB Real
Esp.Properties.VariableNames{'rconna'} = 'Consumo'; % Consumo Real
Esp.Properties.VariableNames{'avh'} = 'Horas'; % Horas Trabajadas
Esp.Inversion = Esp.csh_i .* Esp.PIB; % Inversión Real
Esp.GastoGobierno = Esp.csh_g .* Esp.PIB; % Gasto Gubernamental
Esp.Productividad = Esp.PIB ./ Esp.Horas; % Productividad

% Gráficas de Series
figure; plot(Esp.year, Esp.PIB, 'b'); title('Crecimiento del PIB en España (1950 - 2019)'); xlabel('Año');
figure; plot(Esp.year, Esp.Consumo, 'r'); title('Crecimiento del Consumo en España (1950 - 2019)'); xlabel('Año');
figure; plot(Esp.year, Esp.Inversion, 'g'); title('Crecimiento de la Inversion en España (1950 - 2019)'); xlabel('Año');
figure; plot(Esp.year, Esp.GastoGobierno, 'y'); title('Crecimiento del Gasto de Gobierno en España (1950 - 2019)'); xlabel('Año');
figure; plot(Esp.year, Esp.Productividad, 'c'); title('Crecimiento de la Productividad en España (1950 - 2019)'); xlabel('Año');

% --- Gráfico Combinado con Hitos Históricos ---
figure;
hold on; 

% Graficar series principales
plot(Esp.year, Esp.PIB, 'b', 'LineWidth', 1.5, 'DisplayName', 'PIB'); 
plot(Esp.year, Esp.Consumo, 'r', 'LineWidth', 1.5, 'DisplayName', 'Consumo'); 
plot(Esp.year, Esp.Inversion, 'g', 'LineWidth', 1.5, 'DisplayName', 'Inversión'); 

% Etiquetas
xline(1959, '--k', 'Plan de Estabilización', 'LabelVerticalAlignment', 'top', 'HandleVisibility', 'off');
xline(1973, '--k', 'Crisis del Petróleo I', 'LabelVerticalAlignment', 'top', 'HandleVisibility', 'off');
xline(1979, '--k', 'Crisis del Petróleo II', 'LabelVerticalAlignment', 'top', 'HandleVisibility', 'off');
xline(1986, '--k', 'Ingreso CEE (UE)', 'LabelVerticalAlignment', 'top', 'HandleVisibility', 'off');
xline(2008, '--k', 'Crisis Financiera Global', 'LabelVerticalAlignment', 'top', 'HandleVisibility', 'off');
xline(2014, '--k', 'Retoma del Crecimiento', 'LabelVerticalAlignment', 'top', 'HandleVisibility', 'off');

hold off;

title('Evolución Macroeconómica de España (1950 - 2019)');
xlabel('Año');
ylabel('en Millones de USD');
legend('Location', 'northwest');

%% Estimación de variables logarítmicas y filtro HP

% Cálculo de Logaritmos de las Variables
lnVars = {'PIB', 'Consumo', 'Inversion', 'Horas', 'Productividad', 'GastoGobierno'};
for i = 1:numel(lnVars)
    Esp.(['ln_', lnVars{i}]) = log(Esp.(lnVars{i}));
end

% Aplicación del Filtro HP a las Variables Logarítmicas
hpVars = cellfun(@(x) ['HP_', x], lnVars, 'UniformOutput', false);
for i = 1:numel(lnVars)
    [trend, ~] = hpfilter(Esp.(['ln_', lnVars{i}]), 'Smoothing', 100); 
    Esp.(hpVars{i}) = trend;
end

% Cálculo de Desviaciones Cíclicas (Diferencias entre Ln y HP)
diffVars = cellfun(@(x) ['D_', x], lnVars, 'UniformOutput', false);
for i = 1:numel(lnVars)
    Esp.(diffVars{i}) = Esp.(['ln_', lnVars{i}]) - Esp.(hpVars{i});
end

% Gráfica de Series Ln y HP
variables = {'ln_PIB', 'ln_Consumo', 'ln_Inversion', 'ln_Horas', 'ln_Productividad', 'ln_GastoGobierno'};
hpVariables = {'HP_PIB', 'HP_Consumo', 'HP_Inversion', 'HP_Horas', 'HP_Productividad', 'HP_GastoGobierno'};
figure;
for i = 1:numel(variables)
    subplot(3, 2, i);
    plot(Esp.year, Esp.(variables{i}), 'k-', 'LineWidth', 1.5);
    hold on;
    plot(Esp.year, Esp.(hpVariables{i}), 'r--', 'LineWidth', 1.5);
    hold off;
    title(strrep(variables{i}, 'ln_', '')); % Cambiar el título
    xlabel('Año');
    ylabel('Valor');
    legend('ln', 'HP', 'Location', 'best');
end
sgtitle('Series Económicas vs HP');

% Gráfico de desviaciones respecto a la tendencia
variables = {'D_PIB', 'D_Consumo', 'D_Inversion', 'D_Horas', 'D_Productividad', 'D_GastoGobierno'};
colors = {'b', 'r', 'g', 'm', 'c', 'y'};

figure;
for i = 1:numel(variables)
    subplot(3, 2, i);
    plot(Esp.year, Esp.(variables{i}), 'b-', 'LineWidth', 1.7);
    hold on;
    yline(0, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    hold off;
    
    title(['Componente Cíclico para ', strrep(variables{i}, 'D_', '')]);
    xlabel('Año');
    ylabel('Valor');
end
sgtitle('Componentes Cíclicos');

% Gráfica de Series Ln y HP (una figura por cada variable)
variables = {'ln_PIB', 'ln_Consumo', 'ln_Inversion', 'ln_Horas', 'ln_Productividad', 'ln_GastoGobierno'};
hpVariables = {'HP_PIB', 'HP_Consumo', 'HP_Inversion', 'HP_Horas', 'HP_Productividad', 'HP_GastoGobierno'};

for i = 1:numel(variables)
    figure; % Crear una nueva ventana para cada variable
    plot(Esp.year, Esp.(variables{i}), 'k-', 'LineWidth', 1.5);
    hold on;
    plot(Esp.year, Esp.(hpVariables{i}), 'r--', 'LineWidth', 1.5);
    hold off;
    title(['Evolución del ', strrep(variables{i}, 'ln_', '')]); % Cambiar el título
    xlabel('Año');
    ylabel('Valor');
    legend('ln', 'HP', 'Location', 'best');
end

% Gráfico de desviaciones respecto a la tendencia (una figura por cada variable)
variables = {'D_PIB', 'D_Consumo', 'D_Inversion', 'D_Horas', 'D_Productividad', 'D_GastoGobierno'};
colors = {'b', 'r', 'g', 'm', 'c', 'y'}; % Colores: azul, rojo, verde, magenta, cian, amarillo

for i = 1:numel(variables)
    figure; % Crear una nueva ventana para cada variable
    plot(Esp.year, Esp.(variables{i}), colors{i}, 'LineWidth', 1.7);
    hold on;
    yline(0, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    hold off;
    title(['Componente Cíclico de ', strrep(variables{i}, 'D_', '')]); % Cambiar el título
    xlabel('Año');
    ylabel('Valor');
end

% Gráfico combinado: Logaritmo del PIB, Consumo e Inversión
figure;
variables_ln = {'ln_PIB', 'ln_Consumo', 'ln_Inversion'};
colors = {'b', 'r', 'g'}; % Colores para diferenciar las líneas

for i = 1:numel(variables_ln)
    plot(Esp.year, Esp.(variables_ln{i}), 'Color', colors{i}, 'LineWidth', 1.5);
    hold on;
end

xlabel('Año');
ylabel('Valor');
legend({'PIB', 'Consumo', 'Inversion'}, 'Location', 'best'); % Cambiar la leyenda
title('Evolución de la Tasa de Crecimiento del PIB, Consumo e Inversión');
hold off;

% Gráfico combinado: Desviaciones del PIB, Consumo e Inversión
figure;
variables_dev = {'D_PIB', 'D_Consumo', 'D_Inversion'};

for i = 1:numel(variables_dev)
    plot(Esp.year, Esp.(variables_dev{i}), 'Color', colors{i}, 'LineWidth', 1.5);
    hold on;
end

xlabel('Año');
ylabel('Valor (Desviaciones)');
legend({'PIB', 'Consumo', 'Inversion'}, 'Location', 'best'); % Cambiar la leyenda
title('Evolución del Componente Cíclico del PIB, Consumo e Inversión ');
yline(0, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
hold off;

% Gráfico combinado: Desviaciones del Productividad y Horas
figure;
variables_salario_horas = {'D_PIB','D_Productividad', 'D_Horas'};
colors = {'b', 'm', 'c'};

for i = 1:numel(variables_salario_horas)
    plot(Esp.year, Esp.(variables_salario_horas{i}), 'Color', colors{i}, 'LineWidth', 1.5);
    hold on;
end

xlabel('Año');
ylabel('Valor (Desviaciones)');
legend({'PIB', 'Productividad', 'Horas Trabajadas'}, 'Location', 'best'); % Cambiar la leyenda
title('Evolución del Componente Cíclico de la Productividad y Horas Trabajadas');
yline(0, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
hold off;

% Gráfico combinado: Desviaciones del PIB y Gasto de Gobierno
figure;
variables_pib_gasto = {'D_PIB', 'D_GastoGobierno'};
colors = {'b', 'y'};

for i = 1:numel(variables_pib_gasto)
    plot(Esp.year, Esp.(variables_pib_gasto{i}), 'Color', colors{i}, 'LineWidth', 1.5);
    hold on;
end

xlabel('Año');
ylabel('Valor (Desviaciones)');
legend({'PIB', 'Gasto Gobierno'}, 'Location', 'best'); % Cambiar la leyenda
title('Evolución del Componente Cíclico del PIB y el Gasto de Gobierno');
yline(0, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
hold off;

%% Cálculos
% Matriz de correlación
variables = {'D_PIB', 'D_Consumo', 'D_Inversion', 'D_Horas', 'D_Productividad', 'D_GastoGobierno'};
data = Esp(:, variables);
correlationMatrix = corrcoef(table2array(data), 'rows', 'pairwise');
correlationTable = array2table(correlationMatrix, 'VariableNames', variables, 'RowNames', variables);

disp('Matriz de Correlación:');
disp(correlationTable);

% Volatilidad de las variables
volatilityVars = cellfun(@(x) ['volatility_', x], diffVars, 'UniformOutput', false);
for i = 1:numel(diffVars)
    volatilityVar = std(Esp.(diffVars{i}));
    eval([volatilityVars{i} ' = volatilityVar;']);
end

% Volatilidad relativa al PIB de las variables
relativeVolatilityVars = cellfun(@(x) ['rel_volatility_', x(3:end)], diffVars, 'UniformOutput', false);
volatility_PIB = eval(volatilityVars{1});
for i = 1:numel(diffVars)
    relativeVolatilityVar = eval(volatilityVars{i}) / volatility_PIB;
    eval([relativeVolatilityVars{i} ' = relativeVolatilityVar;']);  
end
% Volatilidad relativa Horas/Productividad
relativeVolatility_Horas_Productividad = volatility_D_Horas / volatility_D_Productividad;

%% Tablas
% Tabla para la volatilidad
disp('Volatility Variables:');
for i = 1:numel(volatilityVars)
    disp([volatilityVars{i} ' = ' num2str(eval(volatilityVars{i}))]);
end
disp(' ');

% Tabla para la volatilidad relativa
disp('Relative Volatility Variables/PIB:');
for i = 1:numel(relativeVolatilityVars)
    disp([relativeVolatilityVars{i} ' = ' num2str(eval(relativeVolatilityVars{i}))]);
end
disp(' ');

% Tabla para la volatilidad relativa Horas/Productividad
disp('Relative Volatility Horas/Productividad:');
disp(['Relative Volatility Horas/Productividad = ' num2str(relativeVolatility_Horas_Productividad)]);
disp(' ');