

************************************************************************************
* Figure A.2 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/FigureA2.log" , replace
noi di c(current_time)

version 13


use 	"${datadir}/${SLfile}", clear
append 	using "${datadir}/SLMS_Waves1213.dta"
		   			
					
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



*****************************************************************************
** INVESTMENT DISTRIBUTION GRAPHS
*****************************************************************************



* Indicators whether we are at treatment vs after it
gen 	attreat = (treated == 1 & wave == 2 & treatmentround == 1)
replace attreat = 1 if (treated == 1 & wave == 4 & treatmentround == 2)
recode  attreat (0 = .) if (wave != 2 & wave != 4) | treatever == 1

gen	    aftertreat = (treated == 1 & attreat == .)
recode  aftertreat (0 = .) if treatever == 1 | wave < 3


* Generate investment variable and winsorize it
gen     invest = D.fk_total
replace invest = 0 if invest < 0

foreach var of varlist invest {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t

* Inverse hyperbolic sign
gen		linvest = asinh(invest)


** Graph for investment UPON treatment
sort 	linvest

cumul 	linvest 	if treated == 0 & insample & attreat == 0, gen(CDF_linvest_0)
cumul 	linvest 	if treated == 1 & insample & attreat == 1, gen(CDF_linvest_1)


twoway 	(line CDF_linvest_0 linvest, lpattern(dash)) ///
		(line CDF_linvest_1 linvest, lpattern(solid) ///
			xtitle("Investment (inverse hyperbolic sine)") ytitle("Empirical CDF") ///
			legend(label(1 "control") label(2 "treated")) ///
							graphregion(fcolor(white) lcolor(white)))
graph export "${graphdir}/FigureA2_b.pdf", replace

ranksum linvest if insample, by(attreat)
	// p = 0.0000
	
cap 	drop CDF*	


** Graph for follow-up investment
sort 	linvest

cumul 	linvest 	if treated == 0 & insample & aftertreat == 0, gen(CDF_linvest_0)
cumul 	linvest 	if treated == 1 & insample & aftertreat == 1, gen(CDF_linvest_1)


twoway 	(line CDF_linvest_0 linvest, lpattern(dash)) ///
		(line CDF_linvest_1 linvest, lpattern(solid) ///
			xtitle("Investment (inverse hyperbolic sine)") ytitle("Empirical CDF") ///
			legend(label(1 "control") label(2 "treated")) ///
							graphregion(fcolor(white) lcolor(white)))
graph export "${graphdir}/FigureA2_a.pdf", replace

ranksum linvest if insample, by(aftertreat)
	// p = 0.576
		

** CLOSE LOG
noi di c(current_time)
cap log close
		   	



