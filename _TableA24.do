
************************************************************************************
* Table A.24 from Janes, Koelle and Quinn, 2024
************************************************************************************

cap log close
log using "$log/TableA24.log" , replace
noi di c(current_time)

use "${datadir}/${SLfile}", clear

** Reduce to insample					
egen 	EverInSample = sum(insample), by(sheno)
replace EverInSample = 1 	if EverInSample > 0 & EverInSample != .
	
keep	if EverInSample == 1	

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


***********************************************************************************
* Regression evidence on use of capital
************************************************************************************

** Baseline categories

foreach var of varlist inventories fk_total k_core k_noncore fk_total_tech fk_total_nontech {
	gen 	`var'_base 			= `var' 		if wave ==1
	egen 	`var'_pre 			= mode(`var'_base), by(sheno)
	gen 	`var'_pre_missing 	= (`var'_pre == .) 	
	replace `var'_pre 			= 0 	if `var'_pre == .
}


** Treatment by year

gen 	treaty1 = 0 
replace treaty1 = 1 if treated == 1 & treatmentround == 1 & wave >= 2 & wave <= 5	
replace treaty1 = 1 if treated == 1 & treatmentround == 2 & wave >= 4 & wave <= 7	
		
gen 	treaty2 = 0 
replace treaty2 = 1 if treated == 1 & treatmentround == 1 & wave >= 6 & wave <= 9	
replace treaty2 = 1 if treated == 1 & treatmentround == 2 & wave >= 8 & wave <= 10	

gen 	treaty3 = 0 
replace treaty3 = 1 if treated == 1 & treatmentround == 1 & wave >= 10 & wave <= 11
replace treaty3 = 1 if treated == 1 & treatmentround == 2 & wave >= 11 & wave <= 11	




** All assets
eststo clear

				
eststo: reghdfe k_core treaty1 treaty2 treaty3 k_core_pre k_core_pre_missing, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
			
		qui sum k_core if insample == 1 & treatever == 0 & wave == 1
		estadd scalar basevalue = r(mean)

		qui sum k_core if insample == 1 & treatever == 0 & wave == 10 | wave == 11
		estadd scalar endvalue = r(mean)
		
		test 	treaty1 = treaty2
		estadd 	scalar testy1 = r(p)
		test 	treaty1 = treaty3	
		estadd 	scalar testy2 = r(p)		
	
	
eststo: reghdfe k_noncore treaty1 treaty2 treaty3 k_noncore_pre k_noncore_pre_missing, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
			
		qui sum k_noncore if insample == 1 & treatever == 0 & wave == 1
		estadd scalar basevalue = r(mean)

		qui sum k_noncore if insample == 1 & treatever == 0 & wave == 10 | wave == 11
		estadd scalar endvalue = r(mean)
		
		test 	treaty1 = treaty2
		estadd 	scalar testy1 = r(p)
		test 	treaty1 = treaty3	
		estadd 	scalar testy2 = r(p)	
			
eststo: reghdfe fk_total_nontech treaty1 treaty2 treaty3 fk_total_nontech_pre fk_total_nontech_pre_missing, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
			
		qui sum fk_total_nontech if insample == 1 & treatever == 0 & wave == 1
		estadd scalar basevalue = r(mean)

		qui sum fk_total_nontech if insample == 1 & treatever == 0 & wave == 10 | wave == 11
		estadd scalar endvalue = r(mean)
		
		test 	treaty1 = treaty2
		estadd 	scalar testy1 = r(p)
		test 	treaty1 = treaty3	
		estadd 	scalar testy2 = r(p)	
				
eststo: reghdfe fk_total_tech treaty1 treaty2 treaty3 fk_total_tech_pre fk_total_tech_pre_missing, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
			
		qui sum fk_total_tech if insample == 1 & treatever == 0 & wave == 1
		estadd scalar basevalue = r(mean)

		qui sum fk_total_tech if insample == 1 & treatever == 0 & wave == 10 | wave == 11
		estadd scalar endvalue = r(mean)
		
		test 	treaty1 = treaty2
		estadd 	scalar testy1 = r(p)
		test 	treaty1 = treaty3	
		estadd 	scalar testy2 = r(p)		

				
		
global 	sub3 "Machines, tools \\ \& furniture"
global 	sub4 "Vehicles \\ \& other durables"
global 	sub5 "Low-tech \\ capital"
global 	sub6 "High-tech \\ capital"

label 	var treaty1 "Dummy: Treated $\times$ Year 1"		
label 	var treaty2 "Dummy: Treated $\times$ Year 2"		
label 	var treaty3 "Dummy: Treated $\times$ Year 3"

esttab 	using "Table_A24.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treaty1 treaty2 treaty3) ///
		   mlabel("\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(basevalue endvalue N N_clust testy1 testy2, ///
						fmt(%9.0fc %9.0fc %9.0fc %9.0fc %9.2fc %9.2fc) ///
						labels("Control mean: baseline" "Control mean: 3 years" "Observations" "Microenterprises" "\addlinespace \midrule p-value: Year 1 = Year 2"  "p-value: Year 1 = Year 3")) ///
		   replace 		
		   
	

	   
** CLOSE LOG
noi di c(current_time)
cap log close
		   	


