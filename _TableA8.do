
************************************************************************************
* Table A.8 from Janes, Koelle and Quinn, 2025
************************************************************************************


cap log close
log using "$log/TableA8.log" , replace
noi di c(current_time)


********************************************************************************
***								SRI LANKA
********************************************************************************

clear

use "${datadir}/${SLfile}", clear
xtset sheno wave

keep	if insample


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

keep	if sample2

** Generate cash and equip pooled

drop 	cash
gen 	cash  = cash10k  + cash20k
drop 	equip
gen 	equip = inkind10k + inkind20k


** Winsorize labor before dividing by it ...

foreach var of varlist totlabor {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t


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
	cap replace `x'=`x'*187.4/326.6 if wave==12 /*w12 inferred from Science rep data*/
	cap replace `x'=`x'*187.4/342.5 if wave==13 /*w13 inferred from Science rep data*/
}

replace ln_em = ln(expenses)
replace ln_k  = ln(klevel)


** Generate labor productivity

gen	yl = log(realrev/totlabor)
gen kl = log(exp(ln_k)/totlabor)
gen	ml = log(exp(ln_em)/totlabor)


** Winsorize everything else...

foreach var of varlist yl kl ml ln_k ln_em ln_totlabor {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t

xtset sheno wave


** Calculate TFP 1-9. Coefficients from Table A.2

global 	BetaK 	= .09
global 	BetaL 	= .22
global 	BetaM 	= .62 

gen 	ln_TFP_1 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


global 	BetaK 	= .03  
global 	BetaL 	= .14    
global 	BetaM 	= .42 

gen 	ln_TFP_2 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


global 	BetaK 	= .13  
global 	BetaL 	= .11   
global 	BetaM 	= .39 

gen 	ln_TFP_3 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


global 	BetaK 	= .11  
global 	BetaL 	= .10   
global 	BetaM 	= .37

gen 	ln_TFP_4 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


global 	BetaK 	= .07  
global 	BetaL 	= .26  
global 	BetaM 	= .53

gen 	ln_TFP_5 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


global 	BetaK 	= .07  
global 	BetaL 	= .13  
global 	BetaM 	= .62

gen 	ln_TFP_6 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


global 	BetaK 	= .11
global 	BetaL 	= .11  
global 	BetaM 	= .53

gen 	ln_TFP_7 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 

global 	BetaK 	= .15  
global 	BetaL 	= .19  
global 	BetaM 	= .46

gen 	ln_TFP_8 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


global 	BetaK 	= .07 
global 	BetaL 	= .25  
global 	BetaM 	= .65

gen 	ln_TFP_9 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


** Winsorize...

foreach var of varlist ln_TFP_* {
		forvalue wave = 1/9 {
			cap  	drop `var'_t
			winsor 	`var' if wave == `wave', gen(`var'_t) p(0.01) 
			replace `var' = `var'_t if wave == `wave'
			su		`var' if insample & wave == `wave'
			replace `var' = `var' - r(mean)	if wave == `wave'
		}
	}
drop *_t







***************************************
*** Keep key outcomes and save to a dataset


gen		country = 1
ren		ln_totlabor l

do		"${maindir}/slindustry.do"

ren		ln_realrev 		y
ren		ln_em 			m
ren		ln_k			k

*keep	sheno wave country ln_TFP_* treated cash equip slindustry female district treatever
keep	sheno wave country ln_TFP_* treated cash equip slindustry female treatever

** Now that we have the data and TFP in, let's switch directory to output

save	"${int_data}/TFPsrilanka_Appendix.dta", replace



********************************************************************************
***								GHANA
********************************************************************************


clear


use "${datadir}/${GHfile}", clear


keep	if insample == 1 & trimgroup != 1


egen  numid = group(sheno)
xtset numid wave

ren		atreat treated
gen 	cash  = cashtreat * treated
gen 	equip = equiptreat * treated

** Rename raw variables before partialling out

ren	lK	lnK_raw
ren	lL	lnL_raw
ren lM	lnM_raw
ren lY  lnY_raw


** Winsorize labour before dividing with it...

foreach var of varlist lnL_raw {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t


** Generate labor productviting

gen	yl = lnY_raw - lnL_raw
gen kl = lnK_raw - lnL_raw
gen	ml = lnM_raw - lnL_raw


** Winsorize everything else...

foreach var of varlist yl kl ml lnK_raw lnM_raw {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t

* Coefficients from Table A.5

global 	BetaK 	= .11 
global 	BetaL 	= .17  
global 	BetaM 	= .64

gen 	ln_TFP_1 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


global 	BetaK 	= .05 
global 	BetaL 	= .13  
global 	BetaM 	= .46

gen 	ln_TFP_2 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


global 	BetaK 	= .09
global 	BetaL 	= .11  
global 	BetaM 	= .45

gen 	ln_TFP_3 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


global 	BetaK 	= .09 
global 	BetaL 	= .09  
global 	BetaM 	= .43

gen 	ln_TFP_4 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 

global 	BetaK 	= .41 
global 	BetaL 	= .25  
global 	BetaM 	= .40

gen 	ln_TFP_5 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


global 	BetaK 	= .20 
global 	BetaL 	= .12  
global 	BetaM 	= .40

gen 	ln_TFP_6 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


global 	BetaK 	= .23 
global 	BetaL 	= .24  
global 	BetaM 	= .41

gen 	ln_TFP_7 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


global 	BetaK 	= .11 
global 	BetaL 	= .20  
global 	BetaM 	= .56

gen 	ln_TFP_8 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


global 	BetaK 	= .09 
global 	BetaL 	= .19  
global 	BetaM 	= .66

gen 	ln_TFP_9 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 



** Winsorize...

foreach var of varlist ln_TFP_* {
		forvalue wave = 2/6 {
			cap  	drop `var'_t
			winsor 	`var' if wave == `wave', gen(`var'_t) p(0.01) 
			replace `var' = `var'_t if wave == `wave'
			su		`var' if insample & wave == `wave'
			replace `var' = `var' - r(mean)	if wave == `wave'
		}
	}
drop *_t



***************************************
*** Keep key outcomes and save to a dataset


replace sheno 	= numid + 1000
gen		country = 2
ren		lnL_raw l

gen		ghindustry = .
replace ghindustry = 1 if sector_food == 1
replace ghindustry = 2 if sector_const == 1
replace ghindustry = 3 if sector_beauty == 1
replace ghindustry = 4 if sector_manuf == 1
replace ghindustry = 5 if sector_sewing == 1
replace ghindustry = 6 if sector_repair == 1
replace ghindustry = 7 if sector_trade == 1 | sector_other == 1

ren		lnY_raw 		y
ren		lnM_raw			m
ren		lnK_raw			k

keep	sheno wave country ln_TFP_*	treated cash equip ghindustry female attrited groupnum
		

** Now that we have the data and TFP in, let's switch directory to output


save	"${int_data}/TFPghana_Appendix.dta", replace



********************************************************************************
***								Pool and analyse
********************************************************************************

use				"${int_data}/TFPsrilanka_Appendix", clear
append using 	"${int_data}/TFPghana_Appendix"

capture tab wave, gen(waveD)

label define lcountry 1 "Sri Lanka" 2 "Ghana"
label values country lcountry


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

label var treated "Treated"

**** Loop


forvalue mm = 1/9 {
	
	di as error "Model `mm'"
		
	eststo clear
	
	eststo: reghdfe ln_TFP_`mm' treated, absorb(interact ghindustry slindustry) cluster(sheno)
			global 	FirmCount = e(N_clust)

	eststo: qreg2 ln_TFP_`mm' treated cy* ind* ind*, cluster(sheno) q(0.2)
			estadd scalar N_clust = $FirmCount
			
	eststo: qreg2 ln_TFP_`mm' treated cy* ind* ind*, cluster(sheno) q(0.4)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 ln_TFP_`mm' treated cy* ind* ind*, cluster(sheno) q(0.5)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 ln_TFP_`mm' treated cy* ind* ind*, cluster(sheno) q(0.6)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 ln_TFP_`mm' treated cy* ind* ind*, cluster(sheno) q(0.8)
			estadd scalar N_clust = $FirmCount	
			

esttab 	 using "Table_A8_Col`mm'.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)  ///
		   keep(treated) noobs replace
			
	
}



** CLOSE LOG
noi di c(current_time)
cap log close