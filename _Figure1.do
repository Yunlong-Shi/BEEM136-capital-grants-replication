
************************************************************************************
* Figure 1 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/Figure1.log" , replace
noi di c(current_time)


capture program drop SimulateDistributionTestSL

program define SimulateDistributionTestSL, rclass
		* Must treat 227 of 385 firms...

		capture drop MyRand
		capture drop MyTreatever
		capture drop MyBigTreatever
		
		gen MyRand = uniform() 	if TargetFirm

		sort 	TargetFirm district MyRand
				
		gen 	MyTreatever = 0
		
		by 	TargetFirm district: ///
			replace MyTreatever = (_n <= 76) if TargetFirm == 1 & district == 13
		
		by 	TargetFirm district: ///
			replace MyTreatever = (_n <= 75) if TargetFirm == 1 & district == 31

		by 	TargetFirm district: ///
			replace MyTreatever = (_n <= 76) if TargetFirm == 1 & district == 32
			
		replace MyTreatever 	= . 	if MyRand == .
		egen 	MyBigTreatever 	= sum(MyTreatever), by(sheno)

		ranksum ln_TFP if insample & wave > 3, by(MyBigTreatever)

		return 	scalar MyP 	= 2 * normal(r(z))
	end

	
global reps = 100000

********************************************************************************
***							SRI LANKA
********************************************************************************


** BLUNDELL-BOND

use "${int_data}/TFPsrilanka.dta", clear

gen ln_TFP = ln_TFP_BB
gen insample = 1

** FOR MENTION IN THE PAPER ITSELF... **

su 	ln_TFP if insample & wave == 1, de
global 	Dispersion90_10 	= r(p90) - r(p10)
global 	Dispersion75_25 	= r(p75) - r(p25)

display "90-10 difference in log points: " $Dispersion90_10
display "90-10 ratio: " exp($Dispersion90_10)

display "75-25 difference in log points: " $Dispersion75_25
display "75-25 ratio: " exp($Dispersion75_25)


** Now produce two CDFs -- one pooled; one disaggregating by treatment.

cumul 	ln_TFP 	if treated == 0 & insample & wave > 3, gen(CDF_ln_TFP_0)
cumul 	ln_TFP 	if treated == 1 & insample & wave > 3, gen(CDF_ln_TFP_1)

sort 	ln_TFP

twoway 	(line CDF_ln_TFP_0 ln_TFP if treated == 0 & insample & wave > 3, lpattern(dash)) ///
		(line CDF_ln_TFP_1 ln_TFP if treated == 1 & insample & wave > 3, lpattern(solid) ///
			xtitle("Log TFP") ytitle("Empirical CDF") xscale(range(-2(1)2)) ///
			legend(label(1 "control") label(2 "treated")) ///
							graphregion(fcolor(white) lcolor(white)))
graph export "${graphdir}/Figure1_BB_SL.pdf", replace


** First, rank-sum test without standard error adjustment.

ranksum ln_TFP if insample & wave > 3, by(treatever)
global 	RanksumP 	= 2 * normal(r(z))

display $RanksumP


** Now we run a rerandomisation, stratified by district and extent of tsunami effect.

* First, a district fix...

replace district = 31 			if sheno == 443

* And we then arbitrarily assign one firm to a district 
* (necessary for computational reasons; will not make a meaningful difference)
replace district = 31 			if sheno == 375

bysort sheno insample: 	gen 	TargetFirm 	= (_n == 1 & treatever != . & insample == 1)
	
preserve
		
	set seed 1234
	
	keep if insample

	simulate MyP = r(MyP), reps($reps): 	SimulateDistributionTestSL

	gen 	MyReject = (MyP < $RanksumP)
	su 		MyReject

	display $RanksumP

	cumul MyP, gen(ECDF_P)
	sort MyP
	twoway (line ECDF_P MyP, xline($RanksumP, lcolor(red)))


restore


** GANDHI-NAVARRO-RIVERS

use "${int_data}/TFPsrilanka.dta", clear

gen ln_TFP = ln_TFP_GNR
gen insample = 1

su 	ln_TFP if insample & wave == 1, de
global 	Dispersion90_10 	= r(p90) - r(p10)
global 	Dispersion75_25 	= r(p75) - r(p25)

display "90-10 difference in log points: " $Dispersion90_10
display "90-10 ratio: " exp($Dispersion90_10)

display "75-25 difference in log points: " $Dispersion75_25
display "75-25 ratio: " exp($Dispersion75_25)


** Now produce two CDFs -- one pooled; one disaggregating by treatment.

cumul 	ln_TFP 	if treated == 0 & insample & wave > 3, gen(CDF_ln_TFP_0)
cumul 	ln_TFP 	if treated == 1 & insample & wave > 3, gen(CDF_ln_TFP_1)

sort 	ln_TFP

twoway 	(line CDF_ln_TFP_0 ln_TFP if treated == 0 & insample & wave > 3, lpattern(dash)) ///
		(line CDF_ln_TFP_1 ln_TFP if treated == 1 & insample & wave > 3, lpattern(solid) ///
			xtitle("Log TFP") ytitle("Empirical CDF") ///
			legend(label(1 "control") label(2 "treated")) ///
							graphregion(fcolor(white) lcolor(white)))
graph export "${graphdir}/Figure1_GNR_SL.pdf", replace


** First, rank-sum test 

ranksum ln_TFP if insample & wave > 3, by(treatever)
global 	RanksumP 	= 2 * normal(r(z))

display $RanksumP


** Now we run a rerandomisation, stratified by district and extent of tsunami effect.

* First, a district fix...

replace district = 31 			if sheno == 443

* And we then arbitrarily assign one firm to a district 
* (necessary for computational reasons; will not make a meaningful difference)
replace district = 31 			if sheno == 375

bysort sheno insample: 	gen 	TargetFirm 	= (_n == 1 & treatever != . & insample == 1)

	
preserve
		
	set seed 1234
	
	keep if insample

	simulate MyP = r(MyP), reps($reps): 	SimulateDistributionTestSL

	gen 	MyReject = (MyP < $RanksumP)
	su 		MyReject

	display $RanksumP

	cumul MyP, gen(ECDF_P)
	sort MyP
	twoway (line ECDF_P MyP, xline($RanksumP, lcolor(red)))


restore


********************************************************************************
***							GHANA
********************************************************************************



capture program drop SimulateDistributionTestGhana
program define SimulateDistributionTestGhana, rclass

		capture drop MyRand
		capture drop MyTreatever
		capture drop MyBigTreatever

		bysort sheno: 	gen MyRand = uniform() 	if _n == 1
		sort 	groupnum MyRand	
		by 		groupnum: gen MyTreatever = (_n <= 2)

		replace MyTreatever 	= . 	if MyRand == .

		egen 	MyBigTreatever 	= sum(MyTreatever), by(sheno)
		
		ranksum ln_TFP if insample & wave > 4, by(MyBigTreatever)

		return 	scalar MyP 	= 2 * normal(r(z))
	end



** BLUNDELL-BOND

use "${int_data}/TFPghana.dta", clear

gen ln_TFP = ln_TFP_BB	
gen insample = 1

su 	ln_TFP if insample & wave == 2, de
global 	Dispersion90_10 	= r(p90) - r(p10)
global 	Dispersion75_25 	= r(p75) - r(p25)

display "90-10 difference in log points: " $Dispersion90_10
display "90-10 ratio: " exp($Dispersion90_10)

display "75-25 difference in log points: " $Dispersion75_25
display "75-25 ratio: " exp($Dispersion75_25)


** Now produce two CDFs -- one pooled; one disaggregating by treatment.

cumul 	ln_TFP 	if treated == 0 & insample & wave > 3, gen(CDF_ln_TFP_0)
cumul 	ln_TFP 	if treated == 1 & insample & wave > 3, gen(CDF_ln_TFP_1)

sort 	ln_TFP

twoway 	(line CDF_ln_TFP_0 ln_TFP if treated == 0 & insample & wave > 3, lpattern(dash)) ///
		(line CDF_ln_TFP_1 ln_TFP if treated == 1 & insample & wave > 3, lpattern(solid) ///
			xtitle("Log TFP") ytitle("Empirical CDF") ///
			legend(label(1 "control") label(2 "treated")) ///
							graphregion(fcolor(white) lcolor(white)))
graph export "${graphdir}/Figure1_BB_GH.pdf", replace

** First, rank-sum test 

ranksum ln_TFP if insample & wave > 3, by(treated)
global 	RanksumP 	= 2 * normal(r(z))

display $RanksumP


** Rank-sum test with standard error adjustment to allow for clustering
	
preserve
		
	set seed 1234

	simulate MyP = r(MyP), reps($reps): 	SimulateDistributionTestGhana

	gen 	MyReject = (MyP < $RanksumP)
	su 		MyReject

	display $RanksumP

	cumul MyP, gen(ECDF_P)
	sort MyP
	twoway (line ECDF_P MyP, xline($RanksumP, lcolor(red)))

restore



** GANDHI-NAVARRO-RIVERS

use "${int_data}/TFPghana.dta", clear

gen ln_TFP = ln_TFP_GNR	
gen insample = 1
	
su 	ln_TFP if insample & wave == 2, de
global 	Dispersion90_10 	= r(p90) - r(p10)
global 	Dispersion75_25 	= r(p75) - r(p25)

display "90-10 difference in log points: " $Dispersion90_10
display "90-10 ratio: " exp($Dispersion90_10)

display "75-25 difference in log points: " $Dispersion75_25
display "75-25 ratio: " exp($Dispersion75_25)


** Now produce two CDFs -- one pooled; one disaggregating by treatment.

cumul 	ln_TFP 	if treated == 0 & insample & wave > 3, gen(CDF_ln_TFP_0)
cumul 	ln_TFP 	if treated == 1 & insample & wave > 3, gen(CDF_ln_TFP_1)

sort 	ln_TFP

twoway 	(line CDF_ln_TFP_0 ln_TFP, lpattern(dash)) ///
		(line CDF_ln_TFP_1 ln_TFP, lpattern(solid) ///
			xtitle("Log TFP") ytitle("Empirical CDF") ///
			legend(label(1 "control") label(2 "treated")) ///
							graphregion(fcolor(white) lcolor(white)))
graph export "${graphdir}/Figure1_GNR_GH.pdf", replace

** First, rank-sum test 

ranksum ln_TFP if insample & wave > 3, by(treated)
global 	RanksumP 	= 2 * normal(r(z))

display $RanksumP


** Rank-sum test with standard error adjustment to allow for clustering
	
preserve
		
	set seed 1234

	simulate MyP = r(MyP), reps($reps): 	SimulateDistributionTestGhana

	gen 	MyReject = (MyP < $RanksumP)
	su 		MyReject

	display $RanksumP

	cumul MyP, gen(ECDF_P)
	sort MyP
	twoway (line ECDF_P MyP, xline($RanksumP, lcolor(red)))

restore


** CLOSE LOG
noi di c(current_time)
cap log close