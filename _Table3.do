

************************************************************************************
* Table 3 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/Table3.log" , replace
noi di c(current_time)


use				"${int_data}/TFPsrilanka", clear
append using 	"${int_data}/TFPghana"

capture tab wave, gen(waveD)

compress
		
********* 
** Control variables


gen 	interact = .
local 	counter = 0

forvalue country = 1/2 {
	forvalue wave = 3/9 {
		local counter = `counter' + 1
		replace interact = `counter' if country == `country' & wave == `wave'
	}
}

tab interact, gen(cy)
	
recode 	ghindustry(. = 0)
recode  slindustry (. = 0)

tab		ghindustry, gen(indgh)	
tab		slindustry, gen(indsl)	

keep	if y!= . & k != . & m != . & l != . & ln_TFP_BB != . & ln_TFP_GNR != .



***********************
** Generate table

gen		table_descriptor = ""
gen		col1			= "&"
gen		table_bb_sl		= ""
gen		col2			= "&"
gen		table_gnr_sl	= ""
gen		col3			= "&"
gen 	table_yl_sl		= ""
gen		col4			= "&"
gen		table_bb_gh		= ""
gen		col5			= "&"
gen		table_gnr_gh 	= ""
gen		col6			= "&"
gen		table_yl_gh 	= ""
gen		colend		= "\\"

replace table_descriptor = "Treatment effect: Revenue" 	if _n == 1
replace table_descriptor = "\midrule Treatment effect: TFP" if _n == 2
replace table_descriptor = "Treatment effect: Capital" 		if _n == 3
replace table_descriptor = "Treatment effect: Materials" 	if _n == 4
replace table_descriptor = "Treatment effect: Labour" 		if _n == 5
replace table_descriptor = "\midrule Contribution: TFP" 	if _n == 6
replace table_descriptor = "Contribution: Capital" 			if _n == 7
replace table_descriptor = "Contribution: Materials" 		if _n == 8
replace table_descriptor = "Contribution: Labour" 			if _n == 9

********************************************************************************
** 									Sri Lanka
********************************************************************************


eststo: reghdfe k 			treated if country == 1, absorb(interact slindustry) cluster(sheno)
global	ate_k = _b[treated]

eststo: reghdfe m			treated if country == 1, absorb(interact slindustry) cluster(sheno)
global	ate_m = _b[treated]

eststo: reghdfe l 			treated if country == 1, absorb(interact slindustry) cluster(sheno)
global	ate_l = _b[treated]

eststo: reghdfe y 			treated if country == 1, absorb(interact slindustry) cluster(sheno)
global	ate_y = _b[treated]




********************************************************************************
** A) 	Blundell-Bond decomposition: Sri Lanka

global 	BetaK 	= .1196006
global 	BetaL 	= .1334667
global 	BetaM 	= .4159893 

eststo: reghdfe ln_TFP_BB 	treated if country == 1, absorb(interact slindustry) cluster(sheno)
global	ate_tfp = _b[treated]


***

global	contribution_tfp = $ate_tfp / $ate_y
global	contribution_k 	 = $ate_k * $BetaK / $ate_y
global	contribution_m 	 = $ate_m * $BetaM / $ate_y
global	contribution_l 	 = $ate_l * $BetaL / $ate_y
global	contribution_sum = $contribution_tfp + $contribution_k + $contribution_m + $contribution_l

di	$contribution_tfp
di	$contribution_k
di	$contribution_m
di	$contribution_l
di	$contribution_sum

replace table_bb_sl = "$ate_y" 				if _n == 1
replace table_bb_sl = "$ate_tfp" 			if _n == 2
replace table_bb_sl = "$ate_k" 				if _n == 3
replace table_bb_sl = "$ate_m" 				if _n == 4
replace table_bb_sl = "$ate_l" 				if _n == 5
replace table_bb_sl = "$contribution_tfp" 	if _n == 6
replace table_bb_sl = "$contribution_k" 	if _n == 7
replace table_bb_sl = "$contribution_m" 	if _n == 8
replace table_bb_sl = "$contribution_l" 	if _n == 9


********************************************************************************
** B) 	GNR decomposition: Sri Lanka

global 	BetaK 	= .2791774  
global 	BetaL 	= .1623919 
global 	BetaM 	= .5107306   

eststo: reghdfe ln_TFP_GNR 	treated if country == 1, absorb(interact slindustry) cluster(sheno)
global	ate_tfp = _b[treated]

***

global	contribution_tfp = $ate_tfp / $ate_y
global	contribution_k 	 = $ate_k * $BetaK / $ate_y
global	contribution_m 	 = $ate_m * $BetaM / $ate_y
global	contribution_l 	 = $ate_l * $BetaL / $ate_y
global	contribution_sum = $contribution_tfp + $contribution_k + $contribution_m + $contribution_l

di	$contribution_tfp
di	$contribution_k
di	$contribution_m
di	$contribution_l
di	$contribution_sum

replace table_gnr_sl = "$ate_y" 			if _n == 1
replace table_gnr_sl = "$ate_tfp" 			if _n == 2
replace table_gnr_sl = "$ate_k" 			if _n == 3
replace table_gnr_sl = "$ate_m" 			if _n == 4
replace table_gnr_sl = "$ate_l" 			if _n == 5
replace table_gnr_sl = "$contribution_tfp" 	if _n == 6
replace table_gnr_sl = "$contribution_k" 	if _n == 7
replace table_gnr_sl = "$contribution_m" 	if _n == 8
replace table_gnr_sl = "$contribution_l" 	if _n == 9


********************************************************************************
** C) 	Labour productivity decomposition: Sri Lanka

reghdfe 	yl treated kl ml l if country == 1, absorb(interact slindustry) cluster(sheno)
global		ate_tfp = _b[treated]
global		BetaK 	= _b[kl]
global		BetaM 	= _b[ml]
global		BetaTemp = _b[l]
global		BetaL	 = 1 + $BetaTemp - $BetaK - $BetaM

***

global	contribution_tfp = $ate_tfp / $ate_y
global	contribution_k 	 = $ate_k * $BetaK / $ate_y
global	contribution_m 	 = $ate_m * $BetaM / $ate_y
global	contribution_l 	 = $ate_l * $BetaL / $ate_y
global	contribution_sum = $contribution_tfp + $contribution_k + $contribution_m + $contribution_l

di	$contribution_tfp
di	$contribution_k
di	$contribution_m
di	$contribution_l
di	$contribution_sum

replace table_yl_sl = "$ate_y" 				if _n == 1
replace table_yl_sl = "$ate_tfp" 			if _n == 2
replace table_yl_sl = "$ate_k" 				if _n == 3
replace table_yl_sl = "$ate_m" 				if _n == 4
replace table_yl_sl = "$ate_l" 				if _n == 5
replace table_yl_sl = "$contribution_tfp" 	if _n == 6
replace table_yl_sl = "$contribution_k" 	if _n == 7
replace table_yl_sl = "$contribution_m" 	if _n == 8
replace table_yl_sl = "$contribution_l" 	if _n == 9



********************************************************************************
** 									Ghana
********************************************************************************


eststo: reghdfe k 			treated if country == 2, absorb(interact ghindustry) cluster(sheno)
global	ate_k = _b[treated]

eststo: reghdfe m			treated if country == 2, absorb(interact ghindustry) cluster(sheno)
global	ate_m = _b[treated]

eststo: reghdfe l 			treated if country == 2, absorb(interact ghindustry) cluster(sheno)
global	ate_l = _b[treated]

eststo: reghdfe y 			treated if country == 2, absorb(interact ghindustry) cluster(sheno)
global	ate_y = _b[treated]



********************************************************************************
** A) 	Blundell-Bond decomposition: Ghana

global 	BetaK 	= .2281318
global 	BetaL 	= .20091
global 	BetaM 	= .3935342 

eststo: reghdfe ln_TFP_BB 	treated if country == 2, absorb(interact ghindustry) cluster(sheno)
global	ate_tfp = _b[treated]



***

global	contribution_tfp = $ate_tfp / $ate_y
global	contribution_k 	 = $ate_k * $BetaK / $ate_y
global	contribution_m 	 = $ate_m * $BetaM / $ate_y
global	contribution_l 	 = $ate_l * $BetaL / $ate_y
global	contribution_sum = $contribution_tfp + $contribution_k + $contribution_m + $contribution_l

di	$contribution_tfp
di	$contribution_k
di	$contribution_m
di	$contribution_l
di	$contribution_sum

replace table_bb_gh = "$ate_y" 				if _n == 1
replace table_bb_gh = "$ate_tfp" 			if _n == 2
replace table_bb_gh = "$ate_k" 				if _n == 3
replace table_bb_gh = "$ate_m" 				if _n == 4
replace table_bb_gh = "$ate_l" 				if _n == 5
replace table_bb_gh = "$contribution_tfp" 	if _n == 6
replace table_bb_gh = "$contribution_k" 	if _n == 7
replace table_bb_gh = "$contribution_m" 	if _n == 8
replace table_bb_gh = "$contribution_l" 	if _n == 9



********************************************************************************
** B) 	GNR decomposition: Ghana

global 	BetaK 	= .2265271               
global 	BetaL 	= .2170854       
global 	BetaM 	= .3911806

eststo: reghdfe ln_TFP_GNR 	treated if country == 2, absorb(interact ghindustry) cluster(sheno)
global	ate_tfp = _b[treated]



***

global	contribution_tfp = $ate_tfp / $ate_y
global	contribution_k 	 = $ate_k * $BetaK / $ate_y
global	contribution_m 	 = $ate_m * $BetaM / $ate_y
global	contribution_l 	 = $ate_l * $BetaL / $ate_y
global	contribution_sum = $contribution_tfp + $contribution_k + $contribution_m + $contribution_l

di	$contribution_tfp
di	$contribution_k
di	$contribution_m
di	$contribution_l
di	$contribution_sum


replace table_gnr_gh = "$ate_y" 			if _n == 1
replace table_gnr_gh = "$ate_tfp" 			if _n == 2
replace table_gnr_gh = "$ate_k" 			if _n == 3
replace table_gnr_gh = "$ate_m" 			if _n == 4
replace table_gnr_gh = "$ate_l" 			if _n == 5
replace table_gnr_gh = "$contribution_tfp" 	if _n == 6
replace table_gnr_gh = "$contribution_k" 	if _n == 7
replace table_gnr_gh = "$contribution_m" 	if _n == 8
replace table_gnr_gh = "$contribution_l" 	if _n == 9



********************************************************************************
** C) 	Labour productivity decomposition: Ghana

reghdfe 	yl treated kl ml l if country == 2, absorb(interact ghindustry) cluster(sheno)
global		ate_tfp = _b[treated]
global		BetaK 	= _b[kl]
global		BetaM 	= _b[ml]
global		BetaTemp = _b[l]
global		BetaL	 = 1 + $BetaTemp - $BetaK - $BetaM


***

global	contribution_tfp = $ate_tfp / $ate_y
global	contribution_k 	 = $ate_k * $BetaK / $ate_y
global	contribution_m 	 = $ate_m * $BetaM / $ate_y
global	contribution_l 	 = $ate_l * $BetaL / $ate_y
global	contribution_sum = $contribution_tfp + $contribution_k + $contribution_m + $contribution_l

di	$contribution_tfp
di	$contribution_k
di	$contribution_m
di	$contribution_l
di	$contribution_sum


replace table_yl_gh = "$ate_y" 				if _n == 1
replace table_yl_gh = "$ate_tfp" 			if _n == 2
replace table_yl_gh = "$ate_k" 				if _n == 3
replace table_yl_gh = "$ate_m" 				if _n == 4
replace table_yl_gh = "$ate_l" 				if _n == 5
replace table_yl_gh = "$contribution_tfp" 	if _n == 6
replace table_yl_gh = "$contribution_k" 	if _n == 7
replace table_yl_gh = "$contribution_m" 	if _n == 8
replace table_yl_gh = "$contribution_l" 	if _n == 9

preserve

	keep	table_descriptor col1 table_bb_sl col2 table_gnr_sl col3 table_yl_sl col4	///
			table_bb_gh	col5 table_gnr_gh col6 table_yl_gh colend
			
	keep	if table_descriptor != ""		

	foreach var of varlist table_bb_sl table_gnr_sl table_yl_sl table_bb_gh table_gnr_gh table_yl_gh {

			destring `var', replace
			tostring `var', format(%4.3f) replace force
			replace  `var' = "" if `var' == "."
	}
	
	
	outsheet using "${tabdir}/Table3_body.tex", nonames nolabel noquote delimiter("") replace

restore

   
** CLOSE LOG
noi di c(current_time)
cap log close