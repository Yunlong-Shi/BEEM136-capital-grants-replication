

************************************************************************************
* Importing from Wave sheets
************************************************************************************

**** Getting expenditure variables out of the wave sheets
use "${datadir}\GhanaBaselineSingle_la.dta", clear
save "${datadir}\GhanaRound1Single_la.dta", replace

forval i=1/6 {
    use "${datadir}\GhanaRound`i'Single_la.dta", clear
	keep income_3* SHENO
	destring income_3*, replace force
	egen M = rowtotal(income_3a income_3b income_3d income_3e), missing
	gen wave = `i'
	save "${datadir}/wave`i'.dta", replace
  }

 * Append into one
 use "${datadir}\wave1.dta", clear
 append using "${datadir}\wave2.dta"
 append using "${datadir}\wave3.dta"
 append using "${datadir}\wave4.dta"
 append using "${datadir}\wave5.dta"
 append using "${datadir}\wave6.dta"
 
 ren SHENO sheno
 keep sheno wave M
 destring(sheno), replace
 duplicates drop sheno wave, force
save "${datadir}\wavesformerge.dta", replace

* Merge into the main analysis dataset
use "${datadir}\ReplicationDataGhanaJDE.dta", clear
xtset, clear
merge 1:1 sheno wave using "${datadir}\wavesformerge.dta", keep (master match)

  
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

save "${datadir}\GhanaReplicationMaster_withdepreciation.dta", replace
