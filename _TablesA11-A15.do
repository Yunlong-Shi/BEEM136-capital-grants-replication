


************************************************************************************
* Tables A.11 to A.15 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/TablesA11-A15.log" , replace
noi di c(current_time)


use "${int_data}/TFPpooled.dta", clear



********************************************************************************
***								SRI LANKA
********************************************************************************

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


***********************************
*** Merge in depreciated capital

cap drop _merge
merge 1:1 sheno wave using "${datadir}\SLMS_capital_with_depreciation.dta"
drop  if _merge == 2
drop  _merge


***********************************
** Winsorize labor before dividing by it ...

foreach var of varlist totlabor {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t


** Make capital and expenses real-valued 

gen	expenses = exp(ln_em)
gen klevel   = exp(ln_k)

foreach x of varlist expenses klevel a_equip {

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

gen		ln_k_d5 = ln(fk_total_d5 + a_equip)
gen		ln_k_d10 = ln(fk_total_d10 + a_equip)
gen		ln_k_d15 = ln(fk_total_d15 + a_equip)
gen		ln_k_d20 = ln(fk_total_d20 + a_equip)
gen		ln_k_d25 = ln(fk_total_d25 + a_equip)

gen		ln_k2  	= ln(fk_total)
gen		ln_k2_d5 = ln(fk_total_d5)
gen		ln_k2_d10 = ln(fk_total_d10)
gen		ln_k2_d15 = ln(fk_total_d15)
gen		ln_k2_d20 = ln(fk_total_d20)
gen		ln_k2_d25 = ln(fk_total_d25)


** Generate labor productivity

gen	yl = log(realrev/totlabor)
gen	ml = log(exp(ln_em)/totlabor)

** Winsorize everything else...

foreach var of varlist  ln_k ln_k_d5 ln_k_d10 ln_k_d15 ln_k_d20 ln_k_d25 ///
						ln_k2 ln_k2_d5 ln_k2_d10 ln_k2_d15 ln_k2_d20 ln_k2_d25 ///						
						yl ml ln_em ln_totlabor {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t

xtset sheno wave


********************************************************************************
*** Get estimated production function coefficients for this capital measure
********************************************************************************


foreach kvar in ln_k_d5 ln_k_d10 ln_k_d15 ln_k_d20 ln_k_d25 ///
				ln_k2 ln_k2_d5 ln_k2_d10 ln_k2_d15 ln_k2_d20 ln_k2_d25 ///
				{
	
	* Preserve cleaned data for next iteration of loop
	preserve
	
		keep if ln_k != .		
		cap drop ln_k
		gen ln_k = `kvar'	


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

		** Capital/labour ratio
		
		gen	kl = ln_k - ln_totlabor


		** And I should winsorise this...

		foreach var of varlist ln_TFP_BB ln_TFP_GNR kl {
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

		keep	sheno wave country ln_TFP_BB ln_TFP_GNR yl kl ml y k m l ///
				treated cash equip slindustry female


		** Now that we have the data and TFP in, let's switch directory to output

		save	"${int_data}/TFPsrilankaDepreciation_`kvar'.dta", replace

	restore
}


********************************************************************************
***									GHANA
********************************************************************************

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
gen	ml = lnM_raw - lnL_raw


** Gen depreciated capital

gen		ln_k_d5 = ln(k_d5 + inventories1)
gen		ln_k_d10 = ln(k_d10 + inventories1)
gen		ln_k_d15 = ln(k_d15 + inventories1)
gen		ln_k_d20 = ln(k_d20 + inventories1)
gen		ln_k_d25 = ln(k_d25 + inventories1)

gen		ln_k2  	= ln(fk_total)
gen		ln_k2_d5 = ln(k_d5)
gen		ln_k2_d10 = ln(k_d10)
gen		ln_k2_d15 = ln(k_d15)
gen		ln_k2_d20 = ln(k_d20)
gen		ln_k2_d25 = ln(k_d25)

ren		lnK_raw ln_k1


** Start by winsorizing capital...

foreach var of varlist  ln_k_d5 ln_k_d10 ln_k_d15 ln_k_d20 ln_k_d25 ///
					  {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t



foreach kvar in ln_k_d5 ln_k_d10 ln_k_d15 ln_k_d20 ln_k_d25 ///
				{
	
	* Preserve cleaned data for next iteration of loop
	preserve
	
		keep if ln_k1 != .	
		cap drop ln_k
		gen ln_k = `kvar'	

		** Calculate BB TFP

		global 	BetaK 	= .2281318
		global 	BetaL 	= .20091
		global 	BetaM 	= .3935342 

		gen 	ln_TFP_BB 	= lnY_raw - $BetaK * ln_k - $BetaL * lnL_raw - $BetaM * lnM_raw 

		** Calculate GNR TFP 

		global 	BetaK 	= .2265271               
		global 	BetaL 	= .2170854       
		global 	BetaM 	= .3911806

		gen 	ln_TFP_GNR 	= lnY_raw - $BetaK * ln_k - $BetaL * lnL_raw - $BetaM * lnM_raw 

		gen kl 				= ln_k - lnL_raw

		
		** And I should winsorise this...

		foreach var of varlist ln_TFP_BB ln_TFP_GNR kl {
				winsor 	`var', gen(`var'_t) p(0.01)
				replace `var' = `var'_t
				su		`var' if insample & wave > 3
				replace `var' = `var' - r(mean)	
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
		ren		ln_k			k

		keep	sheno wave country ln_TFP_BB ln_TFP_GNR yl kl ml y k m l ///
				treated cash equip ghindustry female attrited


		** Now that we have the data and TFP in, let's switch directory to output

		save	"${int_data}/TFPghanaDepreciation_`kvar'.dta", replace

	restore
	
}



********************************************************************************
***								Pool and analyse
********************************************************************************

local tt = 10

foreach kvar in ln_k_d5 ln_k_d10 ln_k_d15 ln_k_d20 ln_k_d25 ///
				{
			
	local tt = `tt' + 1		
			
	use				"${int_data}/TFPsrilankaDepreciation_`kvar'", clear
	append using 	"${int_data}/TFPghanaDepreciation_`kvar'"

	capture tab wave, gen(waveD)

	label define lcountry 1 "Sri Lanka" 2 "Ghana"
	label values country lcountry

			
	********* 
	** Regression


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


	global 	sub1 "OLS\\\vphantom{()}"
	global 	sub2 "Quantile\\(0.2)"
	global 	sub3 "Quantile\\(0.4)"
	global 	sub4 "Quantile\\(0.5)"
	global 	sub5 "Quantile\\(0.6)"
	global 	sub6 "Quantile\\(0.8)"

	label 	var treated "Dummy: Treated"
	label 	var kl 		"Log(Capital/labour)"
	label 	var ml 		"Log(Materials/labour)"
	label 	var l		"Log labour"

	
	********************************************************************************
	**		1) Blundell-Bond pooled with ANCOVA controls	

	eststo clear

	eststo clear

	eststo: reghdfe ln_TFP_BB treated, absorb(interact ghindustry slindustry) cluster(sheno)
			global 	FirmCount = e(N_clust)

	eststo: qreg2 ln_TFP_BB treated cy* ind* ind*, cluster(sheno) q(0.2)
			estadd scalar N_clust = $FirmCount
			
	eststo: qreg2 ln_TFP_BB treated cy* ind* ind*, cluster(sheno) q(0.4)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 ln_TFP_BB treated cy* ind* ind*, cluster(sheno) q(0.5)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 ln_TFP_BB treated cy* ind* ind*, cluster(sheno) q(0.6)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 ln_TFP_BB treated cy* ind* ind*, cluster(sheno) q(0.8)
			estadd scalar N_clust = $FirmCount



	global 	sub1 "ANCOVA\\\vphantom{()}"

	label 	var treated "Dummy: Treated"

	esttab 	 using "Table_A`tt'_A.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
			   label noconstant booktabs collabels(none) ///
			   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
			   keep(treated) ///
			   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
			   noobs stats(N N_clust, ///
							fmt(%4.0fc %4.0fc) ///
							labels("Observations" "Microenterprises")) ///
			   replace 		
			
		

			
	********************************************************************************
	**		2) GNR pooled with ANCOVA controls	

	eststo clear

	eststo: reghdfe ln_TFP_GNR treated, absorb(interact ghindustry slindustry) cluster(sheno)
			global 	FirmCount = e(N_clust)

	eststo: qreg2 ln_TFP_GNR treated cy* ind* ind*, cluster(sheno) q(0.2)
			estadd scalar N_clust = $FirmCount
			
	eststo: qreg2 ln_TFP_GNR treated cy* ind* ind*, cluster(sheno) q(0.4)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 ln_TFP_GNR treated cy* ind* ind*, cluster(sheno) q(0.5)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 ln_TFP_GNR treated cy* ind* ind*, cluster(sheno) q(0.6)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 ln_TFP_GNR treated cy* ind* ind*, cluster(sheno) q(0.8)
			estadd scalar N_clust = $FirmCount



	global 	sub1 "ANCOVA\\\vphantom{()}"

	label 	var treated "Dummy: Treated"

	esttab 	 using "Table_A`tt'_B.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
			   label noconstant booktabs collabels(none) ///
			   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
			   keep(treated) ///
			   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
			   noobs stats(N N_clust, ///
							fmt(%4.0fc %4.0fc) ///
							labels("Observations" "Microenterprises")) ///
			   replace 		
			
		
			
		
	********************************************************************************
	**		3) Labor productivity pooled with ANCOVA controls	

		
	eststo clear

	eststo: reghdfe yl treated kl ml l, absorb(interact slindustry ghindustry) cluster(sheno)
			global 	FirmCount = e(N_clust)

	eststo: qreg2 yl treated kl ml l cy*, cluster(sheno) q(0.2)
			estadd scalar N_clust = $FirmCount
			
	eststo: qreg2 yl treated kl ml l  cy*, cluster(sheno) q(0.4)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 yl treated kl ml l  cy*, cluster(sheno) q(0.5)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 yl treated kl ml l  cy*, cluster(sheno) q(0.6)
			estadd scalar N_clust = $FirmCount

	eststo: qreg2 yl treated kl ml l  cy*, cluster(sheno) q(0.8)
			estadd scalar N_clust = $FirmCount



	global 	sub1 "ANCOVA\\\vphantom{()}"

	label 	var treated "Dummy: Treated"

	esttab 	 using "Table_A`tt'_C.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
			   label noconstant booktabs collabels(none) ///
			   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
			   keep(treated kl ml l) ///
			   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
			   noobs stats(N N_clust, ///
							fmt(%4.0fc %4.0fc) ///
							labels("Observations" "Microenterprises")) ///
			   replace 		
	
}	
	


** CLOSE LOG
noi di c(current_time)
cap log close