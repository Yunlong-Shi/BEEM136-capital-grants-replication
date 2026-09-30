
************************************************************************************
* Table 4 from Janes, Koelle and Quinn, 2025
************************************************************************************


cap log close
log using "$log/Table4.log" , replace
noi di c(current_time)


use "${datadir}/${SLfile}", clear
append 	using "${datadir}/SLMS_Waves1213.dta"

xtset sheno wave

		   			
					
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



** Fill in treatment status for waves 12 and 13
egen 	EverEvertreated = sum(treatever), by(sheno)
replace EverEvertreated = 1 if EverEvertreated > 0 & EverEvertreated != .

replace treated = EverEvertreated if wave == 12 | wave == 13




** Balanced data

replace fk_total_tech = . 		if fk_total == .
replace k_tools_tech = . 		if k_tools == .
replace k_machinery_tech = . 	if k_machinery == .
replace k_vehicles_tech = . 	if k_vehicles == .
replace k_otherassets_tech = . 	if k_otherassets == .



** Make capital and expenses real-valued 

gen	expenses = exp(ln_em)
gen klevel   = exp(ln_k)

foreach x of varlist expenses klevel {

	cap replace `x'=`x'*187.4/187.3 if wave==2 /*base March05, w2 June05*/
	cap replace `x'=`x'*187.4/187.3 if wave==3 /*w3 Sept05*/
	cap replace `x'=`x'*187.4/195.6 if wave==4 /*w4 Dec05*/
	cap replace `x'=`x'*187.4/194.9 if wave==5 /*w5 March06*/
	cap replace `x'=`x'*187.4/207.3 if wave==6 /*w6 June06*/
	cap replace `x'=`x'*187.4/208.8 if wave==7 /*w7 Sept06*/
	cap replace `x'=`x'*187.4/230.6 if wave==8 /*w8 Dec06*/
	cap replace `x'=`x'*187.4/231.2 if wave==9 /*w9 March07*/
	cap replace `x'=`x'*187.4/255.0 if wave==10 /*w10 Sept07*/
	cap replace `x'=`x'*187.4/296.0 if wave==11 /*w11 March08*/
}

replace ln_em = ln(expenses)
replace ln_k  = ln(klevel)



** Core vs non-core

gen k_core 		= k_tools + k_machinery + k_furnite
gen k_noncore	= k_vehicles + k_otherassets




** Winsorize category-wise within each wave

forvalue wave = 1/11 {
	foreach var of varlist fk_* k_* em {
		cap winsor 	`var' 			if wave == `wave', gen(`var'_t) p(0.01) highonly
		cap replace `var' = `var'_t if wave == `wave'
	}	
	drop *_t
}

forvalue wave = 12/13 {
	foreach var of varlist fk_* k_* em {
		cap winsor 	`var' 			if wave == `wave', gen(`var'_t) p(0.01) highonly
		cap replace `var' = `var'_t if wave == `wave'
	}	
	drop *_t
}

** And now create non-tech variables

gen 	fk_total_nontech  = fk_total -  fk_total_tech
gen		k_furnite_tech = 0 if k_furnite != .

gen 	k_tools_nontech 	= k_tools - k_tools_tec
gen		k_machinery_nontech = k_machinery - k_machinery_tech
gen		k_furnite_nontech 	= k_furnite
gen		k_vehicles_nontech	= k_vehicles - k_vehicles_tech
gen		k_otherassets_nontech = k_otherassets - k_otherassets_tech


gen		mytotalK = fk_total + inventories


** Also create productivity

foreach var of varlist ln_realrev ln_k ln_totlabor ln_em inventories {
		cap winsor 	`var', gen(`var'_t) p(0.01)
		cap replace `var' = `var'_t
	}
drop *_t

* Blundell-Bond

global 	BetaK 	= .1196006
global 	BetaL 	= .1334667
global 	BetaM 	= .4159893 

gen 	ln_TFP 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 

* GNR

global 	BetaK 	= .2791774  
global 	BetaL 	= .1623919 
global 	BetaM 	= .5107306   


gen 	ln_TFP_GNR 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 



** Winsorize category-wise within each wave

foreach var of varlist ln_TFP ln_TFP_GNR {
	forvalue wave = 1/13 {
		winsor 	`var'			if wave == `wave', gen(`var'_t) p(0.01)
		replace `var' = `var'_t if wave == `wave'
		drop *_t
	}
		su		`var' if insample & wave > 2
		replace `var' = `var' - r(mean)	
}

su 		ln_TFP if insample
replace ln_TFP 	= ln_TFP 	- r(mean)

gen 	TFP 	= exp(ln_TFP)




** Baseline categories

foreach var of varlist inventories fk_total k_core k_noncore fk_total_tech fk_total_nontech ///
					   em k_tools k_machinery k_furnite k_vehicles k_otherassets expenses {
	gen 	`var'_base 			= `var' 		if wave ==1
	egen 	`var'_pre 			= mode(`var'_base), by(sheno)
	gen 	`var'_pre_missing 	= (`var'_pre == .) 	
	replace `var'_pre 			= 0 	if `var'_pre == .
}				



************************************************************************************
* REGRESSION EVIDENCE ON CAPITAL AND OTHER THINGS OVER TIME
************************************************************************************
	
* Year since treatment	
gen 	treaty1 = 0 
replace treaty1 = 1 if treated == 1 & treatmentround == 1 & wave >= 2 & wave <= 5	
replace treaty1 = 1 if treated == 1 & treatmentround == 2 & wave >= 4 & wave <= 7	
		
gen 	treaty2 = 0 
replace treaty2 = 1 if treated == 1 & treatmentround == 1 & wave >= 6 & wave <= 9	
replace treaty2 = 1 if treated == 1 & treatmentround == 2 & wave >= 8 & wave <= 10	

gen 	treaty3 = 0 
replace treaty3 = 1 if treated == 1 & treatmentround == 1 & wave >= 10 & wave <= 11
replace treaty3 = 1 if treated == 1 & treatmentround == 2 & wave >= 11 & wave <= 11	

gen 	treaty4 = 0 
replace treaty4 = 1 if treated == 1 & wave >= 12 & wave <= 13


foreach var of varlist ln_TFP {
	gen 	`var'_base 			= `var' 		if wave ==1
	egen 	`var'_pre 			= mode(`var'_base), by(sheno)
	gen 	`var'_pre_missing 	= (`var'_pre == .) 	
	replace `var'_pre 			= 0 	if `var'_pre == .
}

* Do industry, and fill in for waves 12/13
do "${maindir}/slindustry.do"

egen 	FillIndustry = mode(slindustry) if wave > 6, by(sheno)
replace slindustry   = FillIndustry if wave == 12 | wave == 13



******************
** Annual dummies: 
	
eststo clear
	
eststo: reghdfe ln_TFP treaty1 treaty2 treaty3 treaty4 ln_TFP_pre ln_TFP_pre_missing if EverInSample, absorb(wave slindustry) cluster(sheno)
//eststo: reghdfe ln_TFP treaty1 treaty2 treaty3 treaty4 if EverInSample, absorb(wave slindustry) cluster(sheno)

		global 	FirmCount = e(N_clust)
		
		qui sum ln_TFP if insample == 1 & treatever == 0 & wave == 1
		estadd scalar basevalue = r(mean)

		qui sum ln_TFP if insample == 1 & treatever == 0 & wave == 10 | wave == 11
		estadd scalar endvalue = r(mean)
		
		test 	treaty1 = treaty2
		estadd 	scalar testy1 = r(p)
		test 	treaty1 = treaty3	
		estadd 	scalar testy2 = r(p)		
		test 	treaty1 = treaty4	
		estadd 	scalar testy3 = r(p)

	
eststo: reghdfe fk_total treaty1 treaty2 treaty3 treaty4 fk_total_pre fk_total_pre_missing if EverInSample, absorb(wave slindustry) cluster(sheno)
//eststo: reghdfe fk_total treaty1 treaty2 treaty3 treaty4 if EverInSample, absorb(wave slindustry) cluster(sheno)

		global 	FirmCount = e(N_clust)
		
		qui sum fk_total if insample == 1 & treatever == 0 & wave == 1
		estadd scalar basevalue = r(mean)

		qui sum fk_total if insample == 1 & treatever == 0 & wave == 10 | wave == 11
		estadd scalar endvalue = r(mean)
		
		test 	treaty1 = treaty2
		estadd 	scalar testy1 = r(p)
		test 	treaty1 = treaty3	
		estadd 	scalar testy2 = r(p)		
		test 	treaty1 = treaty4	
		estadd 	scalar testy3 = r(p)


eststo: reghdfe inventories treaty1 treaty2 treaty3 treaty4 inventories_pre inventories_pre_missing if EverInSample, absorb(wave slindustry) cluster(sheno)
//eststo: reghdfe inventories treaty1 treaty2 treaty3 treaty4 if EverInSample, absorb(wave slindustry) cluster(sheno)

		global 	FirmCount = e(N_clust)
		
		qui sum inventories if insample == 1 & treatever == 0 & wave == 1
		estadd scalar basevalue = r(mean)

		qui sum inventories if insample == 1 & treatever == 0 & wave == 10 | wave == 11
		estadd scalar endvalue = r(mean)
		
		test 	treaty1 = treaty2
		estadd 	scalar testy1 = r(p)
		test 	treaty1 = treaty3	
		estadd 	scalar testy2 = r(p)		
		test 	treaty1 = treaty4	
		estadd 	scalar testy3 = r(p)
	

//eststo: reghdfe em treaty1 treaty2 treaty3 treaty4 if EverInSample, absorb(wave slindustry) cluster(sheno)	
eststo: reghdfe expenses treaty1 treaty2 treaty3 treaty4 expenses_pre expenses_pre_missing if EverInSample, absorb(wave slindustry) cluster(sheno)
		global 	FirmCount = e(N_clust)
		
		qui sum expenses if insample == 1 & treatever == 0 & wave == 1
		estadd scalar basevalue = r(mean)

		qui sum expenses if insample == 1 & treatever == 0 & wave == 10 | wave == 11
		estadd scalar endvalue = r(mean)
		
		test 	treaty1 = treaty2
		estadd 	scalar testy1 = r(p)
		test 	treaty1 = treaty3	
		estadd 	scalar testy2 = r(p)		
		test 	treaty1 = treaty4	
		estadd 	scalar testy3 = r(p)	


*** Create table

label 	var treaty1 "Dummy: Treated $\times$ Year 1"		
label 	var treaty2 "Dummy: Treated $\times$ Year 2"		
label 	var treaty3 "Dummy: Treated $\times$ Year 3"		
label 	var treaty4 "Dummy: Treated $\times$ Years 5-6"		
		
		
		
global 	sub1 "ln(TFP)"
global 	sub2 "Fixed \\ capital"
global 	sub3 "Inventories"
global 	sub4 "Total \\ expenditure"

esttab 	using "Table4.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treaty1 treaty2 treaty3 treaty4) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}", notitles) /// 
		   noobs stats(basevalue endvalue N N_clust testy1 testy2 testy3, ///
						fmt(%9.0fc %9.0fc %9.0fc %9.0fc %9.2fc %9.2fc %9.2fc) ///
						labels("Control mean: baseline" "Control mean: 3 years" "Observations" "Microenterprises" "\addlinespace \midrule p-value: Year 1 = Year 2"  "p-value: Year 1 = Year 3" "p-value: Year 1 = Year 4")) ///
		   addnotes(\begin{tabular}{p{\textwidth}}  ///
		   $ \mbox{} $\\ ///
		   \textit{Note}: This table shows the evolution of effects of capital grants on TFP, assets and materials for up to six years after treatment. TFP is from the preferred ///
		   Blundell-Bond estimator. All other variables are as defined in Table \ref{tab-tech}. In additional, total expenditure in column (8) is total business expenditure in the last month, ///
		   minus the wage bill. Breadown of individual asset items not available in year 5 and 6 surveys. All regressions are ANCOVA and control for wave dummies. *, ** and *** denote significance at the 10, 5 and 1 per cent levels.         ///
		   \end{tabular}) ///
		   replace 		
		   		
   
** CLOSE LOG
noi di c(current_time)
cap log close	
				
