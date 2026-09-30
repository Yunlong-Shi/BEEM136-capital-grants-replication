

************************************************************************************
* Figure A.1 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/FigureA1.log" , replace
noi di c(current_time)

version 13
	   			


**** ROUND 7 *************************************

use "${datadir}/SLMSround7.dta", clear

gen		margin1 = gm3_3f /1000 - 1
gen		margin2 = gm3_3g /1000 - 1

replace margin1 = gt3_3e / 1000 - 1 if gt3_3e != .
replace margin2 = gt3_3f / 1000 - 1 if gt3_3f != .

replace margin1 = gs3_3e / 1000 - 1 if gs3_3e != .
replace margin2 = gs3_3f / 1000 - 1 if gs3_3f != .

gen		margin3 = gt3_3h /1000 - 1 	if gt3_3h != .


**** Adding a wave indicator - somewhat messy code but necessary
gen wave=7

**** Define keeplist
keep 	wave sheno margin*

save "${datadir}/markup_data_7", replace



**** ROUND 8 *************************************

use "${datadir}/SLMSround8.dta", clear

gen		margin1 = hm3_3f_1 /1000 - 1
gen		margin2 = hm3_3g_1 /1000 - 1

replace margin1 = ht3_3e1 / 1000 - 1 if ht3_3e1 != .
replace margin2 = ht3_3f1 / 1000 - 1 if ht3_3f1 != .

replace margin1 = hs3_3e_1 / 1000 - 1 if hs3_3e_1 != .
replace margin2 = hs3_3f_1 / 1000 - 1 if hs3_3f_1 != .

gen		margin3 = ht3_3g1 /1000 - 1

gen		share1 = hm3_3f_2
replace share1 = ht3_3e2 if ht3_3e1 != .
replace share1 = hs3_3e_2 if hs3_3e_1 != .

gen		share2 = hm3_3g_2
replace share2 = ht3_3f2 if ht3_3f1 != .
replace share2 = hs3_3f_2 if hs3_3f_1 != .

gen		share3 = ht3_3g2


**** Adding a wave indicator - somewhat messy code but necessary
gen wave=8

**** Define keeplist
keep 	wave sheno margin* share*

save "${datadir}/markup_data_8.dta", replace



***************************************************
**** Append all waves

use 	"${datadir}/markup_data_7", clear
append 	using "${datadir}/markup_data_8"

cap	drop _merge

save	"${datadir}/markup_data", replace


**** Merge with master data
use "${datadir}/$SLfile", clear

cap drop _merge

merge 1:1 sheno wave using "${datadir}/markup_data"
keep  if _merge == 3



***************************************************
**** Clean margins data

foreach var of varlist margin* {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t




**********************
** Margins for all firms: First product

reghdfe margin1 treated if insample, absorb(wave) cluster(sheno)

sort 	margin1

cumul 	margin1 	if treated == 0 & insample, gen(CDF_margin1_0)
cumul 	margin1 	if treated == 1 & insample, gen(CDF_margin1_1)

twoway 	(line CDF_margin1_0 margin1, lpattern(dash)) ///
		(line CDF_margin1_1 margin1, lpattern(solid) ///
			xtitle("Margin from main product") ytitle("Empirical CDF") ///
			legend(label(1 "control") label(2 "treated")) ///
							graphregion(fcolor(white) lcolor(white)))
graph export "${graphdir}/FigureA1.pdf", replace							

ranksum margin1 if insample, by(treated) exact
	// p = 0.0988

** CLOSE LOG
noi di c(current_time)
cap log close
		   	
	
