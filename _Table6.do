
************************************************************************************
* Table 6 from Janes, Koelle and Quinn, 2024
*
* Uses extra data extracted from individual SLMS waves and saved in SLMS_customers_data.dta
************************************************************************************

cap log close
log using "$log/Table6.log" , replace
noi di c(current_time)


**** Merge with master data
use "${datadir}/${SLfile}", clear

cap drop _merge

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


merge 1:1 sheno wave using "${datadir}/SLMS_customers_data.dta"
keep  if _merge == 3


***************************************************
**** Clean margins data

replace newproduct 			= 0 if newproduct > 1 & newproduct < .
replace newproduct_sales	= . if newproduct_sales >= 95

foreach var of varlist customers {
		replace `var' = . if `var' > 990
	}

foreach var of varlist customers realrev {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t

replace newproduct_sales = 0 if newproduct == 0

egen		spoilage = rowtotal(Mmtls_wasted Tmtls_wasted Smtls_wasted)
replace 	spoilage = spoilage / mtls_1

egen		turnover = rowtotal(turnedover_*)
replace 	turnover = turnover / mtls_1

foreach var of varlist problem_* {
	recode `var' (1 2 = 1) (3 4 = 0),  gen(vimp_`var')
	recode `var' (1 = 1) (2 3 4 = 0),  gen(imp_`var')
}

recode location (10 11 12 13 14 15 17 = 1) (1 2 3 4 5 6 7 8 9 1 = 0), gen(dedicated_premises)

recode new_business (1 2 = 1) (. = 0)

recode business_changes (2 4 = 1) (1 3 = 0), gen(new_line)
recode business_changes (3 4 = 1) (1 2 = 0), gen(new_location)

gen newbus = 1 if closure == 3
replace newbus = 0 if newbus == .


gen		cooled = 0 if newproduct != .
replace cooled = 1 if 	new_product_name == 3 | ///
						new_product_name == 15 | ///
						new_product_name == 21 | ///
						new_product_name == 226 | ///
						new_product_name == 227 | ///
						new_product_name == 228 

gen		perishable = 0 if newproduct != .
replace perishable = 1 if 	new_product_name == 3 | ///
							new_product_name == 11 | ///
							new_product_name == 15 | ///
							new_product_name == 16 | ///
							new_product_name == 18 | ///
							new_product_name == 19 | ///
							new_product_name == 21 | ///
							new_product_name == 23 | ///
							new_product_name == 25 | ///
							new_product_name == 30 | ///
							new_product_name == 201 | ///
							new_product_name == 202 | /// 
						new_product_name == 226 | ///
						new_product_name == 227 | ///
						new_product_name == 228 


foreach var of varlist customers_1km customers realinv {
	gen 	`var'_base 			= `var' 		if wave ==1
	egen 	`var'_pre 			= mode(`var'_base), by(sheno)
	gen 	`var'_pre_missing 	= (`var'_pre == .) 	
	replace `var'_pre 			= 0 	if `var'_pre == .
}						
	


********************************************************************************
*** Main regression		
		
est clear		
		
eststo: reghdfe customers treated customers_pre customers_pre_missing if insample, absorb(wave) cluster(sheno)
		qui sum customers if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe newproduct treated if insample, absorb(wave) cluster(sheno)
		qui sum newproduct if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe newproduct_sales treated if insample, absorb(wave) cluster(sheno)
		qui sum newproduct_sales if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)

eststo: reghdfe cooled treated if insample, absorb(wave) cluster(sheno)
		qui sum cooled if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe perishable treated if insample, absorb(wave) cluster(sheno)
		qui sum perishable if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe spoilage treated if insample, absorb(wave) cluster(sheno)
		qui sum spoilage if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe new_business treated if insample, absorb(wave) cluster(sheno)
		qui sum new_business if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)
		
eststo: reghdfe new_location treated if insample, absorb(wave) cluster(sheno)
		qui sum new_location if insample == 1 & treatever == 0
		estadd scalar basevalue = r(mean)

global 	sub1 "Customers"
global 	sub2 "New product \\ introduction"
global 	sub3 "New product \\ sales"
global 	sub4 "Refrigerated \\ product"
global 	sub5 "Perishable \\ product"
global 	sub6 "Materials \\ spoilage"
global 	sub7 "New \\ business"
global 	sub8 "New \\ location"

label 	var treated "Dummy: Treated"

esttab using "Table6.tex", cells(b(star fmt(%4.3fc)) se(par(( )) fmt(%4.3fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treated) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}" "\specialcell{$sub7}" "\specialcell{$sub8}", notitles) /// 
		   noobs stats(basevalue N N_clust, ///
						fmt(%4.3fc %4.0fc %4.0fc) ///
						labels("Control mean" "Observations" "Microenterprises")) ///
		   addnotes(\begin{tabular}{p{0.9\textwidth}}  ///
		   $ \mbox{} $\\ ///
		   \textit{Note}: This table reports the effect of treatment on business practices. The first column is estimated using ANCOVA, columns (2) to (8) are estimated using OLS. ///
		   New product introduction and share of sales from new product refer to past three months. Perishable and refrigerated products are coded from the names of new products introduced. ///
		   Materials spoilage is the share of all materials purchased in the past month that were spoiled in the past month. New business and new location refers to business respondent ///
		   was running in the previous survey round, three months ago. *, ** and *** denote significance at the 10, 5 and 1 per cent levels.  ///
		   \end{tabular}) ///
		   replace 


   
** CLOSE LOG
noi di c(current_time)
cap log close

