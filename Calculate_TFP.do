

********************************************************************************
***								SRI LANKA
********************************************************************************


clear

use "${datadir}/${SLfile}", clear
xtset sheno wave

keep	if insample

** Trim as in De Mel et al...

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

drop waves*
bysort sheno: egen waves = count(prof)

*sample 2 trims the upper .5%, but both percentage and absolute changes
gen sample2=1 if waves>=3 & (perchange <=xtreme_high | perchange==.) & (abschange<=xtreme_high_abs  | abschange==.)

keep	if sample2

** Generate cash and equip pooled
ren cash cash_O
ren equip equip_O
gen 	cash  = cash10k  + cash20k
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


** Calculate BB TFP

global 	BetaK 	= .1196006
global 	BetaL 	= .1334667
global 	BetaM 	= .4159893 

gen 	ln_TFP_BB 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


** Calculate Wooldridge TFP

global 	BetaK 	= .162322  
global 	BetaL 	= .2007715    
global 	BetaM 	= .4474052 

gen 	ln_TFP_W 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 


** Calculate GNR TFP

global 	BetaK 	= .2791774  
global 	BetaL 	= .1623919 
global 	BetaM 	= .5107306   


gen 	ln_TFP_GNR 	= ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em 



** Calculate TL TFP

global BetaK = .4665247 
global BetaL = .4426543
global BetaM = .4477919
global BetaK2 = .0014198
global BetaM2 = .0889316
global BetaL2 = -.031176
global BetaKM = -.0964243 
global BetaKL = .0857979
global BetaLM = -.0853311


gen ln_TFP_TL = ln_realrev - $BetaK * ln_k - $BetaL * ln_totlabor - $BetaM * ln_em ///
- $BetaK2 * ln_k^2 - $BetaL2 * ln_totlabor^2 - $BetaM2 * ln_em^2 ///
- $BetaKL * ln_k * ln_totlabor - $BetaKM * ln_k * ln_em - $BetaLM * ln_totlabor * ln_em


** Winsorizing...

foreach var of varlist ln_TFP_BB ln_TFP_GNR ln_TFP_W ln_TFP_TL {
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

foreach var of varlist ln_TFP_BB ln_TFP_W ln_TFP_GNR ln_TFP_TL yl {
	gen 	`var'_base 			= `var' 		if wave ==1
	egen 	`var'_pre 			= mode(`var'_base), by(sheno)
	gen 	`var'_pre_missing 	= (`var'_pre == .) 	
	replace `var'_pre 			= 0 	if `var'_pre == .
}


***************************************
*** Keep key outcomes and save to a dataset


gen		country = 1
ren		ln_totlabor l

do		slindustry.do

ren		ln_realrev 		y
ren		ln_em 			m
ren		ln_k			k

keep	sheno wave country ln_TFP_BB ln_TFP_W ln_TFP_GNR ln_TFP_GNR ///
		ln_TFP_GNR_pre ln_TFP_GNR_pre_missing yl kl ml y k m l ///
		ln_TFP_BB_pre ln_TFP_BB_pre_missing ln_TFP_W_pre ln_TFP_W_pre_missing ///	
		ln_TFP_TL ln_TFP_TL_pre ln_TFP_TL_pre_missing ///
		yl_pre yl_pre_missing treated cash equip slindustry female treatever district

		
** Now that we have the data and TFP in, let's switch directory to output

save	"${int_data}/TFPsrilanka.dta", replace



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


** Calculate BB TFP

global 	BetaK 	= .2281318
global 	BetaL 	= .20091
global 	BetaM 	= .3935342 

gen 	ln_TFP_BB 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


** Calculate Wooldridge TFP

global 	BetaK 	= .0835558
global 	BetaL 	= .1935293	 
global 	BetaM 	= .5519295

gen 	ln_TFP_W 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


** Calculate GNR TFP 

global 	BetaK 	= .2265271               
global 	BetaL 	= .2170854       
global 	BetaM 	= .3911806


gen 	ln_TFP_GNR 	= lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw 


** Calculate TL TFP
global BetaK =   .0731883
global BetaL =   .9001748
global BetaM =    .4255543 
global BetaK2 =   .0257702
global BetaM2 =   .0955573 
global BetaL2 =   -.0404819 
global BetaKM =  -.0639338
global BetaKL =   .0242368
global BetaLM =  -.0994327


gen ln_TFP_TL = lnY_raw - $BetaK * lnK_raw - $BetaL * lnL_raw - $BetaM * lnM_raw ///
- $BetaK2 * lnK_raw^2 - $BetaL2 * lnL_raw^2 - $BetaM2 * lnM_raw^2 ///
- $BetaKL * lnK_raw * lnL_raw - $BetaKM * lnK_raw * lnM_raw - $BetaLM * lnL_raw * lnM_raw



** Winsorizing...

foreach var of varlist ln_TFP_BB ln_TFP_GNR ln_TFP_W ln_TFP_TL {
		forvalue wave = 2/6 {
			cap  	drop `var'_t
			winsor 	`var' if wave == `wave', gen(`var'_t) p(0.01) 
			replace `var' = `var'_t if wave == `wave'
			su		`var' if insample & wave == `wave'
			replace `var' = `var' - r(mean)	if wave == `wave'
		}
	}
drop *_t


** Calculate base variables for ANCOVA

foreach var of varlist ln_TFP_BB ln_TFP_W ln_TFP_GNR ln_TFP_TL yl {
	gen 	`var'_base 			= `var' 		if wave ==1
	egen 	`var'_pre 			= mode(`var'_base), by(sheno)
	gen 	`var'_pre_missing 	= (`var'_pre == .) 	
	replace `var'_pre 			= 0 	if `var'_pre == .
}

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

keep	sheno wave country ln_TFP_BB ln_TFP_W ln_TFP_GNR ///
		ln_TFP_GNR_pre ln_TFP_GNR_pre_missing yl kl ml y k m l ///
		ln_TFP_BB_pre ln_TFP_BB_pre_missing ln_TFP_W_pre ln_TFP_W_pre_missing ///
		ln_TFP_TL ln_TFP_TL_pre ln_TFP_TL_pre_missing ///
		yl_pre yl_pre_missing ///
		treated cash equip ghindustry female attrited groupnum

//keep 	if ln_TFP_BB != . & ln_TFP_GNR	!= . & yl != . & kl != . & ml != . & l != .
		

** Now that we have the data and TFP in, let's switch directory to output


save	"${int_data}/TFPghana.dta", replace



********************************************************************************
***								Pool and analyse
********************************************************************************

use				"${int_data}/TFPsrilanka", clear
append using 	"${int_data}/TFPghana"

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

save    "${int_data}/TFPpooled.dta", replace
