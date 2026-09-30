
************************************************************************************
* Table A.23 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/TableA23.log" , replace
noi di c(current_time)

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


***********************************************************************************
* Additional tables
************************************************************************************

	   
*******************
** Generate pre values

foreach var of varlist 	fk_total fk_total_tech fk_total_nontech k_tools k_machinery k_furnite ///
						k_vehicles k_otherassets ///
						k_tools_tech k_machinery_tech k_furnite_tech ///
						k_vehicles_tech k_otherassets_tech ///
						k_tools_nontech k_machinery_nontech k_furnite_nontech ///
						k_vehicles_nontech k_otherassets_nontech ///
						{
	
	* Variable with baseline value...
	gen 	`var'_base 		= `var' 		if wave == 1
	egen 	`var'_pre 		= mode(`var'_base), by(sheno)
	drop	`var'_base
}


*******************
** ANCOVA


** All assets
eststo clear

	
eststo: reghdfe fk_total treated fk_total_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum fk_total if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe k_tools treated k_tools_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_tools if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
				
eststo: reghdfe k_machinery treated k_machinery_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_machinery if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
			
eststo: reghdfe k_furnite treated k_furnite_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)	
		qui sum k_furnite if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
			
eststo: reghdfe k_vehicles treated k_vehicles_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_vehicles if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
				
eststo: reghdfe k_otherassets treated k_otherassets_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_otherassets if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)		
		
		
global 	sub1 "Total"
global 	sub2 "Tools"
global 	sub3 "Machinery"
global 	sub4 "Furniture"
global 	sub5 "Vehicles"
global 	sub6 "Other"

label 	var treated "Dummy: Treated"

esttab 	using "Table_A23_A.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treated) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(basevalue N N_clust, ///
						fmt(%9.0fc %9.0fc %9.0fc) ///
						labels("Control mean" "Observations" "Microenterprises")) ///
		   replace 		
	

** Tech capital	

eststo clear

eststo: reghdfe fk_total_tech treated fk_total_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum fk_total_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe k_tools_tech treated k_tools_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_tools_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
				
eststo: reghdfe k_machinery_tech treated k_machinery_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_machinery_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
			
eststo: reghdfe k_furnite_tech treated k_furnite_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)	
		qui sum k_furnite_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
			
eststo: reghdfe k_vehicles_tech treated k_vehicles_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_vehicles_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
				
eststo: reghdfe k_otherassets_tech treated k_otherassets_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_otherassets_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
				
global 	sub1 "Total"
global 	sub2 "Tools"
global 	sub3 "Machinery"
global 	sub4 "Furniture"
global 	sub5 "Vehicles"
global 	sub6 "Other"

label 	var treated "Dummy: Treated"

esttab 	 using "Table_A23_B.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treated) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(basevalue N N_clust, ///
						fmt(%9.0fc %9.0fc %9.0fc) ///
						labels("Control mean" "Observations" "Microenterprises")) ///
		   replace 		

		   
	

*******************
** Generate pre values

foreach var of varlist 	k_own_total_tech k_own_tools_tech k_own_machinery_tech ///
						k_own_vehicles_tech k_own_otherassets_tech {
	
	* Variable with baseline value...
	gen 	`var'_base 		= `var' 		if wave == 1
	egen 	`var'_pre 		= mode(`var'_base), by(sheno)
	drop	`var'_base
}


eststo clear

eststo: reghdfe k_own_total_tech treated k_own_total_tech_pre  if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_own_total_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe k_own_tools_tech treated k_own_tools_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_own_tools_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
	
eststo: reghdfe k_own_machinery_tech treated k_own_machinery_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_own_machinery_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe k_own_vehicles_tech treated k_own_vehicles_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_own_vehicles_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe k_own_otherassets_tech treated k_own_otherassets_tech_pre if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_own_otherassets_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)				
				
global 	sub1 "Total"
global 	sub2 "Tools"
global 	sub3 "Machinery"
global 	sub4 "Vehicles"
global 	sub5 "Other"

label 	var treated "Dummy: Treated"


esttab 	 using "Table_A23_C.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treated) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(basevalue N N_clust, ///
						fmt(%9.2fc %9.0fc %9.0fc) ///
						labels("Control Mean" "Observations" "Microenterprises")) ///
		   replace 		


	   
** CLOSE LOG
noi di c(current_time)
cap log close
		   	


