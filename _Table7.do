
************************************************************************************
* Table 7 from Janes, Koelle and Quinn, 2024
************************************************************************************


cap log close
log using "$log/Table7.log" , replace
noi di c(current_time)


use "${datadir}/${SLfile}", clear


** Trim like in the DMW paper

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

replace insample = 0 if sample2 != 1
keep if insample == 1

** Balanced data

replace fk_total_tech = . 		if fk_total == .
replace k_tools_tech = . 		if k_tools == .
replace k_machinery_tech = . 	if k_machinery == .
replace k_vehicles_tech = . 	if k_vehicles == .
replace k_otherassets_tech = . 	if k_otherassets == .

gen	yl = log(realrev/totlabor)
gen	ml = log(exp(ln_em)/totlabor)


** Winsorize category-wise

foreach var of varlist fk_* k_* ln_k ln_totlabor ln_em ln_realrev inventories yl ml {

		winsor 	`var', gen(`var'_t) p(0.01)
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

** Core vs non-core

gen 	k_core 		= k_tools + k_machinery + k_furnite
gen 	k_noncore	= k_vehicles + k_otherassets

** Logs

gen 	ln_k_tech   	= ln(1+fk_total_tech)
gen 	ln_k_nontech   	= ln(1+fk_total_nontech)
gen 	ln_k_core   	= ln(1+k_core)
gen 	ln_k_noncore 	= ln(1+k_noncore)

gen 	share_tech 		= exp(ln_k_tech)/exp(ln_k)
gen 	share_noncore	= exp(ln_k_noncore)/exp(ln_k)


** Calculate BB TFP

global 	BetaK 	= .1196006
global 	BetaL 	= .1334667
global 	BetaM 	= .4159893 

gen 	ln_TFP_BB 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


** Calculate GNR TFP 

global 	BetaK 	= .2791774  
global 	BetaL 	= .1623919 
global 	BetaM 	= .5107306  

gen 	ln_TFP_GNR 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


** Winsorizing...

foreach var of varlist ln_TFP_BB ln_TFP_GNR {
		forvalue wave = 1/9 {
			cap  	drop `var'_t
			winsor 	`var' if wave == `wave', gen(`var'_t) p(0.01) 
			replace `var' = `var'_t if wave == `wave'
			su		`var' if insample & wave == `wave'
			replace `var' = `var' - r(mean)	if wave == `wave'
		}
	}
drop *_t


** Calculate base variables for ANCOVA

foreach var of varlist ln_TFP_BB ln_TFP_GNR yl {
	gen 	`var'_base 			= `var' 		if wave ==1
	egen 	`var'_pre 			= mode(`var'_base), by(sheno)
	gen 	`var'_pre_missing 	= (`var'_pre == .) 	
	replace `var'_pre 			= 0 	if `var'_pre == .
}


** Wave and industry dummies

keep if insample

capture tab wave, gen(waveD)
gen		lln_realrev = L.ln_realrev

do		"${maindir}/slindustry.do"
tab		slindustry, gen(indsl)
	
********************************************************************************
**		ACDE with interaction: Blundell Bond
********************************************************************************

eststo clear

* Repeat ATE regression
eststo: reghdfe ln_TFP_BB treated, absorb(wave slindustry) cluster(sheno)
		global 	FirmCount = e(N_clust)

********************************
** Tech capital log amount

* ACDE

cap		drop A
cap		drop Mediator
global  Outcomes ln_TFP_BB		
gen 	A = treated
gen 	Mediator = ln_k_tech

foreach y of varlist $Outcomes ///
{

	* First, the ATE...
	reghdfe `y' A , cluster(sheno) absorb(wave slindustry)  
	global 	ATE = _b[A]
	
	* Second, descriptives on the mediator...
	reghdfe Mediator A , cluster(sheno) absorb(wave slindustry)  
	reghdfe `y' Mediator , cluster(sheno) absorb(wave slindustry)  
	
	* De-mean the mediator
	qui sum Mediator if e(sample)
	replace Mediator = Mediator - `r(mean)'
	
	* Third, calculate the ACDE...
	capture drop AxM
	gen 	AxM 	= A * Mediator
	
	reghdfe `y' A  Mediator AxM , cluster(sheno) absorb(wave slindustry)  
	//reghdfe `y' A Mediator , cluster(sheno) absorb(wave slindustry)  
	
	capture drop Yhat
	predict Yhat	
	matrix MyEsts = e(b)	
	replace Yhat 	= Yhat - MyEsts[1, 2] * Mediator - MyEsts[1, 3] * AxM
	//replace Yhat 	= Yhat - MyEsts[1, 2] * Mediator
	
	capture drop Yresid
	gen 	Yresid = `y' - Yhat

	eststo: reghdfe Yresid A , cluster(sheno) absorb(wave slindustry)  
	global 	ACDE = _b[A]
	
	global 	ProportionExplained 	= 100 - 100 * $ACDE / $ATE
	
	display "Proportion explained by mediator:" $ProportionExplained
	
	estadd local MediatorProp =	strofreal($ProportionExplained, "%9.1f")
	
}		




********************************
** Non-essential capital log amount

* ACDE

cap		drop A
cap		drop Mediator
global  Outcomes ln_TFP_BB		
gen 	A = treated
gen 	Mediator = ln_k_noncore

foreach y of varlist $Outcomes ///
{

	* First, the ATE...
	reghdfe `y' A , cluster(sheno) absorb(wave slindustry)  
	global 	ATE = _b[A]
	
	* Second, descriptives on the mediator...
	reghdfe Mediator A , cluster(sheno) absorb(wave slindustry)  
	reghdfe `y' Mediator , cluster(sheno) absorb(wave slindustry)  
	
	* De-mean the mediator
	qui sum Mediator if e(sample)
	replace Mediator = Mediator - `r(mean)'
	
	* Third, calculate the ACDE...
	capture drop AxM
	gen 	AxM 	= A * Mediator
	
	reghdfe `y' A  Mediator AxM , cluster(sheno) absorb(wave slindustry)  
	//reghdfe `y' A Mediator , cluster(sheno) absorb(wave slindustry)  
	
	capture drop Yhat
	predict Yhat	
	matrix MyEsts = e(b)	
	replace Yhat 	= Yhat - MyEsts[1, 2] * Mediator - MyEsts[1, 3] * AxM
	//replace Yhat 	= Yhat - MyEsts[1, 2] * Mediator
	
	capture drop Yresid
	gen 	Yresid = `y' - Yhat

	eststo: reghdfe Yresid A , cluster(sheno) absorb(wave slindustry)  
	global 	ACDE = _b[A]
	
	global 	ProportionExplained 	= 100 - 100 * $ACDE / $ATE
	
	display "Proportion explained by mediator:" $ProportionExplained
	
	estadd local MediatorProp =	strofreal($ProportionExplained, "%9.1f")
	
}		



********************************
** Tech capital share

* ACDE

cap		drop A
cap		drop Mediator
global  Outcomes ln_TFP_BB		
gen 	A = treated
gen 	Mediator = share_tech

foreach y of varlist $Outcomes ///
{

	* First, the ATE...
	reghdfe `y' A , cluster(sheno) absorb(wave slindustry)  
	global 	ATE = _b[A]
	
	* Second, descriptives on the mediator...
	reghdfe Mediator A , cluster(sheno) absorb(wave slindustry)  
	reghdfe `y' Mediator , cluster(sheno) absorb(wave slindustry)  
	
	* De-mean the mediator
	qui sum Mediator if e(sample)
	replace Mediator = Mediator - `r(mean)'
	
	* Third, calculate the ACDE...
	capture drop AxM
	gen 	AxM 	= A * Mediator
	
	reghdfe `y' A  Mediator AxM , cluster(sheno) absorb(wave slindustry)  
	//reghdfe `y' A Mediator , cluster(sheno) absorb(wave slindustry)  
	
	capture drop Yhat
	predict Yhat	
	matrix MyEsts = e(b)	
	replace Yhat 	= Yhat - MyEsts[1, 2] * Mediator - MyEsts[1, 3] * AxM
	//replace Yhat 	= Yhat - MyEsts[1, 2] * Mediator
	
	capture drop Yresid
	gen 	Yresid = `y' - Yhat

	eststo: reghdfe Yresid A , cluster(sheno) absorb(wave slindustry)  
	global 	ACDE = _b[A]
	
	global 	ProportionExplained 	= 100 - 100 * $ACDE / $ATE
	
	display "Proportion explained by mediator:" $ProportionExplained
	
	estadd local MediatorProp =	strofreal($ProportionExplained, "%9.1f")
	
}		


********************************
** Non-essential capital share

* ACDE

cap		drop A
cap		drop Mediator
global  Outcomes ln_TFP_BB		
gen 	A = treated
gen 	Mediator = share_noncore

foreach y of varlist $Outcomes ///
{

	* First, the ATE...
	reghdfe `y' A , cluster(sheno) absorb(wave slindustry)  
	global 	ATE = _b[A]
	
	* Second, descriptives on the mediator...
	reghdfe Mediator A , cluster(sheno) absorb(wave slindustry)  
	reghdfe `y' Mediator , cluster(sheno) absorb(wave slindustry)  
	
	* De-mean the mediator
	qui sum Mediator if e(sample)
	replace Mediator = Mediator - `r(mean)'
	
	* Third, calculate the ACDE...
	capture drop AxM
	gen 	AxM 	= A * Mediator
	
	reghdfe `y' A  Mediator AxM , cluster(sheno) absorb(wave slindustry)  
	//reghdfe `y' A Mediator , cluster(sheno) absorb(wave slindustry)  
	
	capture drop Yhat
	predict Yhat	
	matrix MyEsts = e(b)	
	replace Yhat 	= Yhat - MyEsts[1, 2] * Mediator - MyEsts[1, 3] * AxM
	//replace Yhat 	= Yhat - MyEsts[1, 2] * Mediator
	
	capture drop Yresid
	gen 	Yresid = `y' - Yhat

	eststo: reghdfe Yresid A , cluster(sheno) absorb(wave slindustry)  
	global 	ACDE = _b[A]
	
	global 	ProportionExplained 	= 100 - 100 * $ACDE / $ATE
	
	display "Proportion explained by mediator:" $ProportionExplained
	
	estadd local MediatorProp =	strofreal($ProportionExplained, "%9.1f")
	
}		

label var treated 	"Average Treatment Effect (ATE)"
label var Mediator 	"Average Controlled Direct Effect"

///esttab   , 
esttab using "Table7.tex" , replace ///
	keep() nocons ///
	order(`orderr') ///
	collabels(none) ///
	eqlabels(none) ///
	varlabels(treated "Average Treatment Effect (ATE)" A "Average Controlled Direct Effect (ACDE)")   ///		
	modelwidth()	///
	compress ///
	cells(b(star fmt(2)) se(par fmt(3))) starlevels( * 0.10 ** 0.05 *** 0.01)  nogap   ///
	mtitles( ) ///
	stats( N MediatorProp , fmt(0 2 2 2) ///
	labels( "Observations" "Explained by mediator (\%)"  )) 
	


   
** CLOSE LOG
noi di c(current_time)
cap log close
