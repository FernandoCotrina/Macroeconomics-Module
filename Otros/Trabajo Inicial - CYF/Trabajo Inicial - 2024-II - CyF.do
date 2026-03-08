clear all
cd "G:\Mi unidad\TRABAJOS\Trabajos - CYF\Trabajo 1\data"

use pwt1001.dta

	*Extracción de datos de Estados Unidos, Perú y España

keep if countrycode=="USA" | countrycode=="PER" | countrycode=="ESP"
save "COUNTRY.dta", replace
browse

*Podemos empezar con las preguntas

******************************************************************************************

	* 1) Grafique la serie de tiempo para el capital share de cada uno de los países.
clear all
use COUNTRY.dta
	
**Primero calculamos el Capital Share
gen cptsh = 1-labsh

*Podemos empezar a graficar	

**Gráfica para Estados Unidos
twoway (line cptsh year if countrycode == "USA", lcolor(blue)), ///
       title("Participación del Capital en Estados Unidos") ///
       ytitle("Capital Share") xtitle("Año")

**Gráfica para Perú
twoway (line cptsh year if countrycode == "PER", lcolor(red)), ///
       title("Participación del Capital en Perú") ///
       ytitle("Capital Share") xtitle("Año")

**Gráfica para España
twoway (line cptsh year if countrycode == "ESP", lcolor(orange)), ///
       title("Participación del Capital en España") ///
       ytitle("Capital Share") xtitle("Año")

**Gráfica de los tres países juntos
twoway (line cptsh year if countrycode == "USA", lcolor(blue)) ///
       (line cptsh year if countrycode == "PER", lcolor(red)) ///
       (line cptsh year if countrycode == "ESP", lcolor(orange)), ///
       title("Comparación del Capital Share: USA, Perú y España") ///
       legend(order(1 "USA" 2 "Perú" 3 "España")) ///
       ytitle("Capital Share") xtitle("Año")

graph export "labor_share.png", as(png) replace
	   
******************************************************************************************

	* 2) Obtener la serie stock de capital percápita y grafique la serie de tiempo para 
	*    cada uno de los países.
clear all
use COUNTRY.dta

**Primero obtenemos la serie stock de capital per cápita para cada país
gen cptpc = cn/pop

*Podemos empezar a graficar	

**Gráfica para Estados Unidos
twoway (line cptpc year if countrycode == "USA", lcolor(blue)), ///
       title("Capital per cápita de Estados Unidos") ///
       ytitle("Capital per cápita") xtitle("Año")

**Gráfica para Perú
twoway (line cptpc year if countrycode == "PER", lcolor(red)), ///
       title("Capital per cápita de Perú") ///
       ytitle("Capital per cápita") xtitle("Año")

**Gráfica para España
twoway (line cptpc year if countrycode == "ESP", lcolor(orange)), ///
       title("Capital per cápita de España") ///
       ytitle("Capital per cápita") xtitle("Año")

**Gráfica de los tres países juntos
twoway (line cptpc year if countrycode == "USA", lcolor(blue)) ///
       (line cptpc year if countrycode == "PER", lcolor(red)) ///
       (line cptpc year if countrycode == "ESP", lcolor(orange)), ///
       title("Comparación del Capital per cápita: USA, Perú y España") ///
       legend(order(1 "USA" 2 "Perú" 3 "España")) ///
       ytitle("Capital per cápita") xtitle("Año")
	   
graph export "capital_per_capita.png", as(png) replace

******************************************************************************************

	* 3) Obtenga la serie stock de producto per cápita (gdppc = rgdpe/pop) y grafique
	*	 la serie de tiempo para cada uno de los países. Esta serie debe partir desde el
	*	 mínimo hasta el último año disponible en común de los 3 países asignados.
clear all
use COUNTRY.dta

**Primero obtenemos la serie producto per cápita para cada país
gen gdppc = rgdpe/pop

*Podemos empezar a graficar	

**Gráfica para Estados Unidos
twoway (line gdppc year if countrycode == "USA", lcolor(blue)), ///
       title("Producto per cápita de Estados Unidos") ///
       ytitle("Producto per cápita") xtitle("Año")

**Gráfica para Perú
twoway (line gdppc year if countrycode == "PER", lcolor(red)), ///
       title("Producto per cápita de Perú") ///
       ytitle("Producto per cápita") xtitle("Año")

**Gráfica para España
twoway (line gdppc year if countrycode == "ESP", lcolor(orange)), ///
       title("Producto per cápita de España") ///
       ytitle("Producto per cápita") xtitle("Año")

**Gráfica de los tres países juntos
twoway (line gdppc year if countrycode == "USA", lcolor(blue)) ///
       (line gdppc year if countrycode == "PER", lcolor(red)) ///
       (line gdppc year if countrycode == "ESP", lcolor(orange)), ///
       title("Comparación del Producto per cápita: USA, Perú y España") ///
       legend(order(1 "USA" 2 "Perú" 3 "España")) ///
       ytitle("Producto per cápita") xtitle("Año")
	   
graph export "producto_per_capita.png", as(png) replace

******************************************************************************************

	* 4)  Complete la siguiente tabla siguiendo el modelo de Solow para cada país
clear all
use COUNTRY.dta	

**Primero calculamos el residuo de Solow
gen cptsh = 1-labsh
gen TFP = rgdpe / (cn^(cptsh) * emp^(labsh)) 

    * Generar los periodos 
    gen period = ""
    replace period = "1950-1959" if year >= 1950 & year <= 1959
    replace period = "1960-1969" if year >= 1960 & year <= 1969
    replace period = "1970-1979" if year >= 1970 & year <= 1979
	replace period = "1980-1989" if year >= 1980 & year <= 1989
    replace period = "1990-1999" if year >= 1990 & year <= 1999
    replace period = "2000-2009" if year >= 2000 & year <= 2009
    replace period = "2010-2019" if year >= 2010 & year <= 2019

    * Calcular promedios por periodo
    bysort countrycode period: egen α = mean(cptsh)
	bysort countrycode period: egen β = mean(labsh) // Saber que β = 1 - α
    bysort countrycode period: egen Y = mean(rgdpe)
    bysort countrycode period: egen K = mean(cn)
    bysort countrycode period: egen N = mean(emp)
    bysort countrycode period: egen z = mean(TFP)

	*Eliminamos data no importante
    drop if missing(period)
    duplicates drop countrycode period, force

    *Mantener solo las variables de interés
    keep country period α β Y K N z	

**Ponemos los datos en tres cuadros distintos	

preserve
    keep if country == "United States"
	display "Tabla 1: Datos de Estados Unidos"
    list country period α β Y K N z, clean
restore

preserve
    keep if country == "Peru"
	display "Tabla 2: Datos de Perú"
    list country period α β Y K N z, clean
restore

preserve
    keep if country == "Spain"
	display "Tabla 3: Datos de España"
    list country period α β Y K N z, clean
restore
	

******************************************************************************************

	* 5) Calcule el valor relativo, a USA, de las siguientes variables: producto per
	*	 cápita, stock de capital per c´apita y productividad total de los factores; 	
	*	 para Perú y el país asignado.
clear all
use COUNTRY.dta

**Primero calculamos el producto per cápita, capital per cápita y la TFP
gen gdppc = rgdpe / pop
gen cptpc = cn / pop
gen cptsh = 1 - labsh
gen z = rgdpe / (cn^cptsh * emp^labsh)

	*Guardamos los valores de Estados Unidos en variables separadas:
	gen Ypc_USA = gdppc if countrycode == "USA"
	gen Kpc_USA = cptpc if countrycode == "USA"
	gen Zpc_USA = z if countrycode == "USA"

	*Ponemos los valores de USA a todos los países por cada año
	bysort year: egen product_USA = mean(Ypc_USA)
	bysort year: egen capital_USA = mean(Kpc_USA)
	bysort year: egen tfp_USA = mean(Zpc_USA)

	*Eliminamos data inservible
	drop if countrycode == "USA"

** Calculamos el valor relativo para el producto per cápita, capital per cápita y la TFP para cada país
gen ry = gdppc / product_USA
gen rk = cptpc / capital_USA
gen rz = z / tfp_USA

	*Guardamos y ordenamos nuestra data
	keep country year ry rk rz
	order country year ry rk rz

** Cuadro por país

preserve
    keep if country == "Peru"
	display "Tabla 4: Valor relativo para Perú"
    list country year ry rk rz, clean
restore

preserve
    keep if country == "Spain"
	display "Tabla 5: Valor relativo para España"
    list country year ry rk rz, clean
restore

	* 6) Grafique las series calculadas en [5.], para cada Perú y el país asignado

** Generamos gráficos para visualizar los resultados

twoway (line ry year if country == "Peru", lcolor(red)) ///
       (line ry year if country == "Spain", lcolor(orange)) ///
       , title("Producto per cápita relativo: Perú y España") ///
       ytitle("Producto per cápita relativo") xtitle("Año") ///
	   legend(label(1 "Perú") label(2 "España"))

graph export "producto_per_capita_relativo.png", as(png) replace	   
	   
twoway (line rk year if country == "Peru", lcolor(red)) ///
       (line rk year if country == "Spain", lcolor(orange)) ///
       , title("Capital per cápita relativo: Perú y España") ///
       ytitle("Capital per cápita relativo") xtitle("Año") ///
	   legend(label(1 "Perú") label(2 "España"))

graph export "capital_per_capita_relativo.png", as(png) replace	   	   
	   
twoway (line rz year if country == "Peru", lcolor(red)) ///
       (line rz year if country == "Spain", lcolor(orange)) ///
       , title("TFP relativo: Perú y España") ///
       ytitle("TFP per cápita relativo") xtitle("Año") ///
	   legend(label(1 "Perú") label(2 "España"))
	   
graph export "tfp_relativo.png", as(png) replace	   
	   
***************************************************************************************** 
 
	* 7) Completar la tabla de tasas de crecimiento
clear all
use COUNTRY.dta

**Hallamos la particiación del capital
gen cptsh = 1 - labsh

**Sacamos el logaritmos a las variables
gen ln_rgdpe = log(rgdpe)
gen ln_cn = log(cn)
gen ln_emp = log(emp)

	*Creamos una variable para el periodo
	gen period = ""
	replace period = "1950-1959" if year >= 1950 & year <= 1960
	replace period = "1960-1969" if year >= 1960 & year <= 1969
	replace period = "1970-1979" if year >= 1970 & year <= 1979
	replace period = "1980-1989" if year >= 1980 & year <= 1989
	replace period = "1990-1999" if year >= 1990 & year <= 1999
	replace period = "2000-2009" if year >= 2000 & year <= 2009
	replace period = "2010-2019" if year >= 2010 & year <= 2019
	
** Ponemos a todas nuestras variables su primer año y último por periodo
bysort countrycode period (year): gen last_year = year[_N]
bysort countrycode period (year): gen first_year = year[1]
	
** Cálculo de las tasas de crecimiento por periodo
bysort countrycode period (year): gen ln_rgdpe_first = ln_rgdpe[1]
bysort countrycode period (year): gen ln_rgdpe_last = ln_rgdpe[_N]
gen gY = (((ln_rgdpe_last - ln_rgdpe_first) / (last_year - first_year))) * 100

bysort countrycode period (year): gen ln_cn_first = ln_cn[1]
bysort countrycode period (year): gen ln_cn_last = ln_cn[_N]
gen gK = (((ln_cn_last - ln_cn_first) / (last_year - first_year))) * 100

bysort countrycode period (year): gen ln_emp_first = ln_emp[1]
bysort countrycode period (year): gen ln_emp_last = ln_emp[_N]
gen gN = (((ln_emp_last - ln_emp_first) / (last_year - first_year))) * 100

** Cálculo de la TFP
bysort countrycode period: egen mlabsh=mean(labsh)
bysort countrycode period: egen mcptsh=mean(cptsh)
gen gz = gY - mcptsh * gK - mlabsh * gN

** Cálculo de la factores de producción por su participación
gen αgK = gK * mcptsh
gen βgN = gN * mlabsh // Saber que β = 1 - α

	*Eliminamos data que no nos sirve
	duplicates drop countrycode period, force
	drop if missing(period)

	*Guardamos y ordenamos nuestra data
	keep country period mcptsh mlabsh gY αgK βgN gz
	order country period mcptsh mlabsh gY αgK βgN gz

** Cuadro por País

preserve
    keep if country == "United States"
	display "Tabla 6: Tasas de Crecimiento Promedio según el Modelo de Solow para Estados Unidos"
    list country period gY αgK βgN gz, clean
restore

preserve
    keep if country == "Peru"
	display "Tabla 7: Tasas de Crecimiento Promedio según el Modelo de Solow para Perú"
    list country period gY αgK βgN gz, clean
restore

preserve
    keep if country == "Spain"
	display "Tabla 8: Tasas de Crecimiento Promedio según el Modelo de Solow para España"
    list country period gY αgK βgN gz, clean
restore

*****************************************************************************************

	* 8) Ahora complete la tabla con el siguiente modelo para cada uno de los países
	*    donde Zt está en términos aumentadoras de trabajo
clear all
use COUNTRY.dta

**Calculamos variables de interés
gen cptsh = 1 - labsh  // Capital share
gen L = avh * emp // Total de horas trabajadas por empleados
gen y = rgdpe / L // Producción por hora
gen KY = cn / rgdpe // Ratio Capital/Producto
gen h = (hc * 1e3) / L // Capital humano por trabajador
gen Z = y/((KY^((cptsh) / (1-cptsh))) *h) // Labor-Augmented TFP

	*Creamos una variable para el periodo
	gen period = ""
	replace period = "1950-1959" if year >= 1950 & year <= 1960
	replace period = "1960-1969" if year >= 1960 & year <= 1969
	replace period = "1970-1979" if year >= 1970 & year <= 1979
	replace period = "1980-1989" if year >= 1980 & year <= 1989
	replace period = "1990-1999" if year >= 1990 & year <= 1999
	replace period = "2000-2009" if year >= 2000 & year <= 2009
	replace period = "2010-2019" if year >= 2010 & year <= 2019

	*Ponemos los valores de la media para cada periodo
	bysort countrycode period: egen mcptsh=mean(cptsh)
	bysort countrycode period: egen mlabsh=mean(labsh)
	bysort countrycode period: egen my=mean(y)
	bysort countrycode period: egen mKY=mean(KY)
	bysort countrycode period: egen mh=mean(h)
	bysort countrycode period: egen mZ=mean(Z)

	*Eliminamos data que no nos sirve
	drop if missing(period)
	duplicates drop countrycode period, force
	
	*Guardamos y ordenamos
	keep country period cptsh mlabsh my mKY mh mZ
	order country period cptsh mlabsh my mKY mh mZ

** Cuadro por país

preserve
    keep if country == "United States"
	display "Tabla 9: Contabilidad de Crecimiento para Estados Unidos"
    list country period cptsh mlabsh my mKY mh mZ, clean
restore

preserve
    keep if country == "Peru"
	display "Tabla 10: Contabilidad de Crecimiento para Perú"
    list country period cptsh mlabsh my mKY mh mZ, clean
restore

preserve
    keep if country == "Spain"
	display "Tabla 11: Contabilidad de Crecimiento para España"
    list country period cptsh mlabsh my mKY mh mZ, clean
restore

*****************************************************************************************
