
*** DATA PREPARATION FOR GHANA REPLICATION ***
**********************************************

************************************************************************************
* Importing from Wave sheets
************************************************************************************

    use "$datadir/GhanaBaselineSingle_la.dta", clear
	keep income_3* SHENO
	destring income_3*, replace force
	egen M = rowtotal(income_3a income_3b income_3d income_3e), missing
	gen wave = 1
	save "${maindir}/Results/IntData/wave1.dta", replace

**** Getting expenditure variables out of the wave sheets
forval i=2/6 {
    use "$datadir/GhanaRound`i'Single_la.dta", clear
	keep income_3* SHENO
	destring income_3*, replace force
	egen M = rowtotal(income_3a income_3b income_3d income_3e), missing
	gen wave = `i'
	save "${maindir}/Results/IntData/wave`i'.dta", replace
  }

 * Append into one
 use "${maindir}/Results/IntData/wave1.dta", clear
 append using "${maindir}/Results/IntData/wave2.dta"
 append using "${maindir}/Results/IntData/wave3.dta"
 append using "${maindir}/Results/IntData/wave4.dta"
 append using "${maindir}/Results/IntData/wave5.dta"
 append using "${maindir}/Results/IntData/wave6.dta"
 
 ren SHENO sheno
 keep sheno wave M
 destring(sheno), replace
 duplicates drop sheno wave, force
save "${maindir}/Results/IntData/wavesformerge.dta", replace

* Merge into the main analysis dataset
use "$datadir/ReplicationDataGhanaJDE.dta", clear
xtset, clear
merge 1:1 sheno wave using "${maindir}/Results/IntData/wavesformerge.dta", keep (master match)

  
************************************************************************************
* SOME VARIABLES + DATA PREP
************************************************************************************

**** Renaming variables to match the Sri Lanka Data
gen L =  hourslastweek + totalworkerhours
ren finalsales Y
ren realfinalprof Yprof
ren totalK K
gen insample = 1 if trimgroup !=1

ren 	OtherCapital_OwnedFixed fk_total

**** Calculate difference in capital stock and apply depreciation
xtset sheno wave

gen   lfktotal   = L.fk_total
gen	  investment = fk_total - L.fk_total

sort sheno wave

local dlist 	= "0.016952 0.034511 0.052732 0.071682 0.091440"
local dlabels 	= "5 10 15 20 25"

local counter = 0

foreach d of local dlabels {

	local counter = `counter' + 1

	local depreciation: word `counter' of `dlist'
	*di "`depreciation'"
	*di "`d'"

	gen k_d`d' = fk_total if wave == 1
		
		forvalue w = 2/9 {
			replace k_d`d' = (1 - `depreciation') * L.k_d`d' + investment if wave == `w'
		}
}

*** Logs and dealing with zeros
for var Y Yprof M K L : gen lX = ln(X)

/*
 * This generates a dummy if an input is zero
 for var Y Yprof M K L: gen zero_X = 1 if X == 0
 for var Y Yprof M K L: replace zero_X = 0 if zero_X == .
 * This replaces the log of an input with 1 if the input is zero, it can be shown that if the dummy is included, then estimation is unbiased
 for var Y Yprof M K L: replace lX = 1 if zero_X == 1
 for var Y Yprof M K L: replace X = 1 if zero_X == 1
 */

*** Other bits
tab wave, gen(waved)

save "$datadir/${GHfile}", replace
