***********************************************
* Trabajo Final - Crecimiento y Fluctuaciones *
***********************************************
***********************************************
**   Prof: Cristian Adderly Maravi Meneses   **
**    Asist: Valerie Lucía Hinsbe Vilela     **
***********************************************
**				  Integrantes				 **
***********************************************
**		  Cordova Ramos, Evelyn Abigail		 **
** 		  Cotrina Lejabo, José Fernando      **
** 		Gonzaga Vargas, Carlos Guillermo     **
**     Serrano Saldarriaga, Samuel Gerardo   **
**		Pulache Ramos, Abraham Joel			 **
***********************************************

/////////////////////////////////////////////
//     Calibración de parámetros y modelos //
/////////////////////////////////////////////

clear all
set more off

// Cambia el directorio de trabajo al lugar donde está la base de datos
cd "C:\Users\José Cotrina Lejabo\OneDrive\Escritorio\sd-capcha\UDEP\2024\CICLO VI\CRECIMIENTO Y FLUCTUACIONES\Trabajos\TRABAJO CYF\TRABAJO FINAL CYF"

// Cargar la base de datos
use "pwt1001.dta", clear
keep if countrycode == "ESP"

// Configuración de series de tiempo
tsset year

// Selección de variables necesarias
keep year countrycode rgdpna rconna csh_i csh_g irr avh emp pop rnna labsh

/****************************************************************
*                 MODELO ESTÁNDAR Y EXTENDIDO                  *
****************************************************************/

// Renombramos las variables para mayor claridad
rename rgdpna Y       // Producto Interno Bruto
rename csh_i I_Y      // Inversión como proporción del PIB
rename irr r          // Tasa de interés real
rename pop N          // Población total
rename rnna K         // Capital total
rename csh_g G_Y      // Gasto gubernamental como proporción del PIB

// Generar nuevas variables para ambos modelos

gen G = G_Y * Y             // Gasto gubernamental
gen I = I_Y * Y             // Inversión total
gen C = rconna - G        // Consumo

/****************************************************************
*               CÁLCULO DE VARIABLES PER CÁPITA                *
****************************************************************/

gen h = avh / (365 * 24)  // Horas trabajadas como fracción del año
gen y = Y / N             // Producto per cápita
gen i = I / N             // Inversión per cápita
gen k = K / N             // Capital per cápita
gen g = G / N             // Gasto gubernamental per cápita
gen c = C / N         // Consumo per cápita

/****************************************************************
*                   CALIBRACIÓN DE PARÁMETROS                  *
****************************************************************/

// Theta (participación del capital)
gen θ = r*(K/Y)
format θ %9.5f

gen labs = 1 - θ		    // Labor Share
format labs %9.5f

// Delta (tasa de depreciación)
gen δ = i / k
format δ %9.5f

// Beta (tasa de descuento)
gen β = k / (θ * y  +  (1 - δ) * k)
format β %9.5f

// Productividad total de los factores (A)
gen A1 = (1 - θ) * (y / c) * ((1 - h) / h)
format A1 %9.5f

/****************************************************************
*       DINÁMICA ESTOCÁSTICA: RESIDUO DE SOLOW Y ARIMA         *
****************************************************************/

// Residuo de Solow: incluye parte determinística y estocástica
gen lnz = ln(Y) - θ*ln(K) - (1-θ)*ln(emp*h)

// Estimación de la parte estocástica del residuo
reg lnz year, r
predict lngamma, residual

// Modelo ARIMA para dinámica estocástica
arima lngamma, ar(1) noconstant
predict shocks, residual

tsline shocks // Para visualizar la variabilidad estocástica en el tiempo.

// Parámetros estocásticos
matrix b = e(b)
local ar1_coef = b[1,1]
gen ρ = `ar1_coef' // Coeficiente AR(1)
format ρ %9.5f

local sigma = e(sigma)
gen σ_e = `sigma' // Desviación estándar del error
format σ_e %9.5f

/****************************************************************
*              DINÁMICA DE GASTOS GUBERNAMENTALES              *
****************************************************************/

gen g_bar = g / y           // Proporción del Gasto Gubernamental sobre PIB
format g_bar %9.5f

gen g_pa = g[_n+1]          // Gasto Gubernamental del siguiente período
gen lng = ln(g)             // Logaritmo del Gasto Gubernamental
gen lng_bar = ln(g_bar)     // Logaritmo de la proporción del Gasto Gubernamental sobre el PIB
gen lng_pa = ln(g_pa)       // Logaritmo del asto Gubernamental en el siguiente período

drop if year == 2019 // Debido a que el año no tiene data posterior

// Regresión para hallar la persistencia del gasto (λ)

reg lng_pa lng, r
local λ_g = _b[lng]
local intercepto_g = _b[_cons]
gen λ = `λ_g'
format λ %9.5f

// Desviación estándar de los errores

gen μ_g = lng_pa - `intercepto_g' - `λ_g' * lng
sum μ_g
gen σ_μ = r(sd)
format σ_μ %9.5f
	
/****************************************************************
*               RESULTADOS Y PARAMETROS FINALES                *
****************************************************************/

collapse (mean) θ labs δ β A1 ρ σ_e λ σ_μ g_bar, by(countrycode)
list θ labs δ β A1 ρ σ_e λ σ_μ g_bar
