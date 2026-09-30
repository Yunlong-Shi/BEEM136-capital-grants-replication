

************************************************************************************
* Figure 2 from Janes, Koelle and Quinn, 2024
************************************************************************************

cap log close
log using "$log/Figure2.log" , replace
noi di c(current_time)

version 13

use "${datadir}/${SLfile}", clear

keep if insample

*---Trimming points---*
tsset sheno wave
gen abschange=prof-L.prof
gen perchange=100*(prof-L.prof)/L.prof

*cuts for top 0.5% (about one observation per wave, on average)
egen xtreme_high=pctile(perchange), p(99.5)
egen xtreme_low=pctile(perchange), p(.5)
egen xtreme_high_abs=pctile(abschange), p(99.5)
egen xtreme_low_abs=pctile(abschange), p(.5)

sum perchange, de

egen minchange=min(perchange), by(sheno)
egen maxchange=max(perchange), by(sheno)

bysort sheno: egen waves = count(prof)

*sample 2 trims the upper .5%, but both percentage and absolute changes
gen sample2=1 if waves>=3 & (perchange <=xtreme_high | perchange==.) & (abschange<=xtreme_high_abs  | abschange==.)

keep if sample2 == 1


** Balanced data

replace fk_total_tech = . 		if fk_total == .
replace k_tools_tech = . 		if k_tools == .
replace k_machinery_tech = . 	if k_machinery == .
replace k_vehicles_tech = . 	if k_vehicles == .
replace k_otherassets_tech = . 	if k_otherassets == .

** Winsorize category-wise

foreach var of varlist fk_* k_* {
		winsor 	`var', gen(`var'_t) p(0.01) highonly
		replace `var' = `var'_t
	}
drop *_t


** And now create non-tech variables

gen 	fk_total_nontech  = fk_total -  fk_total_tech
gen		k_furnite_tech = 0 if k_furnite != .

gen 	k_tools_nontech 	= k_tools - k_tools_tec
gen		k_machinery_nontech = k_machinery - k_machinery_tech
gen		k_furnite_nontech 	= k_furnite
gen		k_vehicles_nontech	= k_vehicles - k_vehicles_tech
gen		k_otherassets_nontech = k_otherassets - k_otherassets_tech


gen		mytotalK = fk_total + inventories


** Core vs non-core

gen k_core 		= k_tools + k_machinery + k_furnite
gen k_noncore	= k_vehicles + k_otherassets


	

*****************************************************************************
** Graph: Asset tenancy over time
*****************************************************************************

gen	k_own_core 		= 1 if k_core > 0
gen k_own_noncore 	= 1 if k_noncore > 0

recode k_own* (. = 0) if fk_total != .

gen	wave_x = .
gen	noncore_t = .
gen noncore_c = .
gen core_t = .
gen core_c = .

forvalue w = 1/9 {
	replace wave_x = `w' if _n == `w'
	
	qui 	sum k_own_noncore 	if wave == `w' 	& treatever == 1
	local	mean = r(mean)
	replace noncore_t = `mean' if _n == `w'

	qui 	sum k_own_noncore 	if wave == `w'  & treatever == 0
	local	mean = r(mean)
	replace noncore_c = `mean' if _n == `w'
	
	qui 	sum k_own_core 		if wave == `w'  & treatever == 1
	local	mean = r(mean)
	replace core_t = `mean' if _n == `w'
	
	qui 	sum k_own_core		if wave == `w'  & treatever== 0
	local	mean = r(mean)
	replace core_c = `mean' if _n == `w'
}


* Graph essential items

graph twoway ///
		(scatter core_t wave_x, msymbol(O) xline(1.5,  lcolor(gs5)  lpattern(dash))) ///
		(scatter core_c wave_x, msymbol(T) xline(3.5,  lcolor(gs5)  lpattern(dash))), ///
		plotregion(fcolor(white) lcolor(white)) ///
		graphregion(fcolor(white) lcolor(white)) ///
		legend(label(1 "Treated firms") label(2 "Control firms")) ymtick(0(0.2)1) ylabel(0(0.2)1) ///
		xlabel(1 2 3 4 5 6 7 8 9) xtitle("Wave") ytitle("Owns tools, machinery, furniture") 

graph export "${graphdir}/Figure2_essential.pdf", replace


* Graph non-essential items

graph twoway ///
		(scatter noncore_t wave_x, msymbol(O) xline(1.5,  lcolor(gs5)  lpattern(dash))) ///
		(scatter noncore_c wave_x,  msymbol(T) xline(3.5,  lcolor(gs5)  lpattern(dash))), ///
		plotregion(fcolor(white) lcolor(white)) ///
		graphregion(fcolor(white) lcolor(white)) ///
		legend(label(1 "Treated firms") label(2 "Control firms")) ymtick(0(0.2)1) ylabel(0(0.2)1) ///
		xlabel(1 2 3 4 5 6 7 8 9) xtitle("Wave") ytitle("Owns vehicles and durables") 

graph export "${graphdir}/Figure2_nonessential.pdf", replace


   
** CLOSE LOG
noi di c(current_time)
cap log close
	
	

