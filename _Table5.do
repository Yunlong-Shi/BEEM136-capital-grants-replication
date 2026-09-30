
************************************************************************************
* Table 5 from Janes, Koelle and Quinn, 2022
************************************************************************************

cap log close
log using "$log/Table5.log" , replace
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
* Regression evidence on use of capital
************************************************************************************

** Baseline categories

foreach var of varlist inventories fk_total k_core k_noncore fk_total_tech fk_total_nontech {
	gen 	`var'_base 			= `var' 		if wave ==1
	egen 	`var'_pre 			= mode(`var'_base), by(sheno)
	gen 	`var'_pre_missing 	= (`var'_pre == .) 	
	replace `var'_pre 			= 0 	if `var'_pre == .
}



** All assets
eststo clear

	
eststo: reghdfe inventories treated inventories_pre inventories_pre_missing if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum inventories if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe fk_total treated fk_total_pre fk_total_pre_missing if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum fk_total if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
				
eststo: reghdfe k_core treated k_core_pre k_core_pre_missing if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum k_core if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
			
eststo: reghdfe k_noncore treated k_noncore_pre k_noncore_pre_missing if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)	
		qui sum k_noncore if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
			
eststo: reghdfe fk_total_nontech treated fk_total_nontech_pre fk_total_nontech_pre_missing if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum fk_total_nontech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
				
eststo: reghdfe fk_total_tech treated fk_total_tech_pre fk_total_tech_pre_missing if insample, absorb(wave ) cluster(sheno)
		global 	FirmCount = e(N_clust)
		qui sum fk_total_tech if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)		

				
label 	var treated "Dummy: Treated"		
		
global 	sub1 "Inventories"
global 	sub2 "Fixed \\ capital"
global 	sub3 "Machines, tools \\ \& furniture"
global 	sub4 "Vehicles \\ \& other durables"
global 	sub5 "Low-tech \\ capital"
global 	sub6 "High-tech \\ capital"


label 	var treated "Dummy: Treated"

esttab 	using "Table5.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treated) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(basevalue N N_clust, ///
						fmt(%9.0fc %9.0fc %9.0fc) ///
						labels("Control mean" "Observations" "Microenterprises")) ///						
	addnotes(\begin{tabular}{p{0.7\textwidth}}                     $ \mbox{} $\\                     \textit{Note}:  This table breaks down the effect on grants on different categories of capital.  Fixed capital is broken down by functional category in columns (3) and (4) following the DMW questionnaire, and into technology components in columns (5) and (6) based on our coding. All specifications control for wave dummies and baseline values of the dependent variable. *, ** and *** denote significance at the 10, 5 and 1 per cent levels.                       \end{tabular}) ///
		   replace 		
		   
	
   
** CLOSE LOG
noi di c(current_time)
cap log close

