

************************************************************************************
* Table 1 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/Table1.log" , replace
noi di c(current_time)

********************************************************************************
***							SRI LANKA
********************************************************************************


**** COLUMN 1: BLUNDELL-BOND ****

cd "${int_data}"

use "${datadir}/$SLfile", clear
xtset sheno wave

* Partial out
do "${maindir}/SLpartialout.do"


* Estimate

eststo clear

	global 	LagY	= "2 3"
	global 	LagK 	= "3 4"
	global  LagLab 	= "1 2"
	global 	LagM 	= "2 3"
	

**** GENERATE ESTIMATES: TABLE 1, COLUMN 1 ****
	
eststo Est1: xtabond2 lnY lnK lnL lnM llnY, ///
						gmm(llnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan
						
		estadd scalar Hansen 	= e(hansenp)
		estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]

		
		
	quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
		
		estadd scalar CRSp 		= r(p)
			
		estadd scalar AR1 = e(ar1p)
		estadd scalar AR2 = e(ar2p)
		estadd scalar Instr = e(j)

	quietly xi: xtabond2 lnK lnL lnM llnY if insample, ///
		gmm(llnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		robust twostep artests(3) svmat 
		display e(hansenp)

		global MyWind 	= e(hansenp)		
		estadd scalar Wind1 = $MyWind: Est1

	quietly xi: xtabond2 lnL lnM llnY lnK if insample, ///
		gmm(llnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		robust twostep artests(3) svmat 
		display e(hansenp)

		global MyWind 	= e(hansenp)		
		estadd scalar Wind2 = $MyWind: Est1
		
	quietly xi: xtabond2 lnM llnY lnK lnL if insample, ///
		gmm(llnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		robust twostep artests(3) svmat 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind3 = $MyWind: Est1
		
	quietly xi: xtabond2 llnY lnK lnL lnM if insample, ///
		gmm(llnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		robust twostep artests(3) svmat 
		display e(hansenp)
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind4 = $MyWind: Est1

**** COLUMN 2: GANDHI-NAVARRO-RIVERS ****

********
** POINT ESTIMATES

cd "${int_data}"

use "${datadir}/${SLfile}", clear
xtset sheno wave

* Partial out
do "${maindir}/SLpartialout.do"		

** Censor materials shares above 200 %
replace lnM = . if exp(ln_em - ln_realrev) > 2

* Keep only obs with non-zero in all inputs
keep if lnY != . & lnL != . & lnM != . & lnK != . 


* Estimate
cd "${maindir}"
do "RunGNR_CobbDouglas.do"		

sum ielas kelas lelas

cap drop _merge

save "${int_data}/GNR_TFP_SL.dta", replace


********
** BOOTSTRAP

cd "${maindir}"

do DefinePrograms.do
do MyGNRestimationSL.do

simulate K=r(betak) M=r(betam) L=r(betal), reps(1000) seed(12345): MyGNRestimationSL

**** GENERATE ESTIMATES: TABLE 1, COLUMN 2 ****

bstat, stat(.2791774 .5107306 .1623919) n(372)
	// Stats are the means of kelas, ielas and lelas, respectively displayed earlier under "sum ielas kelas lelas"

save "${int_data}/GNR_TFP_SL_bs.dta", replace


********************************************************************************
***								GHANA
********************************************************************************

clear

cd "${tabdir}"

use "${datadir}/${GHfile}", clear

* Partial out
do "${maindir}/GHpartialout.do"



*** COLUMN 3:BLUNDELL-BOND ***

global 	LagY	= "1 2"	
global 	LagK 	= "2 3"
global  LagLab 	= "1 2"
global 	LagM 	= "2 3"

**** GENERATE ESTIMATES: TABLE 1, COLUMN 3 ****

eststo Est3: xtabond2 lnY lnK lnL lnM llnY, ///
						gmm(llnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) nodiffsargan
							
		estadd scalar Hansen 	= e(hansenp)
		estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]

		
		
	quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
		
		estadd scalar CRSp 		= r(p)
			
		estadd scalar AR1 = e(ar1p)
		estadd scalar AR2 = e(ar2p)
		estadd scalar Instr = e(j)

	quietly xi: xtabond2 lnK lnL lnM llnY if insample, ///
		gmm(llnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		robust twostep artests(3) svmat
		display e(hansenp)

		global MyWind 	= e(hansenp)		
		estadd scalar Wind1 = $MyWind: Est3

	quietly xi: xtabond2 lnL lnM llnY lnK if insample, ///
		gmm(llnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		robust twostep artests(3) svmat 
		display e(hansenp)

		global MyWind 	= e(hansenp)		
		estadd scalar Wind2 = $MyWind: Est3
		
	quietly xi: xtabond2 lnM llnY lnK lnL if insample, ///
		gmm(llnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		robust twostep artests(3) svmat 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind3 = $MyWind: Est3
		
	quietly xi: xtabond2 llnY lnK lnL lnM if insample, ///
		gmm(llnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		robust twostep artests(3) svmat 
		display e(hansenp)
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind4 = $MyWind: Est3


**** COLUMN 4: GANDHI-NAVARRO-RIVERS ****

********
** POINT ESTIMATES

cd "${int_data}"

use "${datadir}/${GHfile}", clear
xtset sheno wave

* Partial out
do "${maindir}/GHpartialout.do"		

** Censor materials shares above 200 %
replace lnM = . if exp(lnM_raw - lnY_raw) > 2

* Keep only obs with non-zero in all inputs
keep if lnY != . & lnL != . & lnM != . & lnK != . 

* Estimate
cd "${maindir}"
do "RunGNR_CobbDouglas.do"		

sum ielas kelas lelas

cap drop _merge

save "${int_data}/GNR_TFP_GH.dta", replace


********
** BOOTSTRAP

cd "${maindir}"

do DefinePrograms.do
do MyGNRestimationGH.do

simulate K=r(betak) M=r(betam) L=r(betal), reps(1000) seed(12345): MyGNRestimationSL

**** GENERATE ESTIMATES: TABLE 1, COLUMN 4 ****

bstat, stat(.2265271 .3911806 .2170854) n(770) 
	// Stats are the means of kelas, ielas and lelas, respectively displayed earlier under "sum ielas kelas lelas"

save "${int_data}/GNR_TFP_GH_bs.dta", replace


********************************************************************************
***		Cross-equation tests

*** Get the matrices out

est restore Est1

mat b	= e(b)
mat	V   = e(V)
mat b1 = b[1,1..3]
mat V1 = V[1..3,1..3]


est restore Est3

mat b	= e(b)
mat	V   = e(V)
mat b3 = b[1,1..3]
mat V3 = V[1..3,1..3]



** Test: BB equal across Sri Lanka and Ghana

mat bdiff = b1 - b3
mat Vsum  = V1 + V3
mat Vinv  = syminv(Vsum)
mat Fstat = bdiff * Vinv * bdiff'

global F  		= Fstat[1,1]
global pval1	= chi2tail(3,$F)
di	   $pval1

********************************************
** Table is created by manual copying... ***
********************************************
		   
capture file close myfile
file open myfile using "${tabdir}/Table1_user_message.tex", write replace
file write myfile "NOTE: The tex file for Table 1 is created by manual copying from Table1.log." _n
file close myfile


** CLOSE LOG
noi di c(current_time)
cap log close
