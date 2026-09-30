

************************************************************************************
* SETTING UP THE DO-FILE
************************************************************************************

//cd "$datadir\Sri Lanka Individual Waves"


* Merge the consolidated wave dataset into the Master
*use "${datadir}\SLMS_master_withcapital_techcapital.dta", clear

use "${datadir}/${SLfile}"
capture drop _merge
sort	sheno wave




** NEW: Depreciated stocks, while still nominal additions and subtractions

sort sheno wave
xtset sheno wave

local dlist 	= "0.016952 0.034511 0.052732 0.071682 0.091440"
local dlabels 	= "5 10 15 20 25"

local counter = 0

foreach d of local dlabels {

	local counter = `counter' + 1

	local depreciation: word `counter' of `dlist'
	*di "`depreciation'"
	*di "`d'"
	
	foreach x in tools machinery vehicles site furnite otherassets ///
				 tools_tech machinery_tech vehicles_tech otherassets_tech ///
				 {	 
		
		gen k_`x'_d`d' = kt_`x' if wave == 1
		
		forvalue w = 2/9 {
			replace k_`x'_d`d' = (1 - `depreciation') * L.k_`x'_d`d' + knt_`x' + krt_`x' -kdt_`x' - kst_`x' if wave == `w'
		}

	/*----replacing coding errors----*/
		
		replace k_`x'_d`d'=. if sheno==298  & wave==6
		replace k_`x'_d`d'=. if sheno==298  & wave==7
		replace k_`x'_d`d'=. if sheno==298  & wave==8
		replace k_`x'_d`d'=. if sheno==298  & wave==9
		replace k_`x'_d`d'=. if sheno==321  & wave==6
		replace k_`x'_d`d'=. if sheno==321  & wave==7
		replace k_`x'_d`d'=. if sheno==321  & wave==8
		replace k_`x'_d`d'=. if sheno==321  & wave==9
		replace k_`x'_d`d'=. if sheno==388  & wave==5
		replace k_`x'_d`d'=. if sheno==388  & wave==6
		replace k_`x'_d`d'=. if sheno==388  & wave==7
		replace k_`x'_d`d'=. if sheno==388  & wave==8
		replace k_`x'_d`d'=. if sheno==388  & wave==9
		
		replace k_`x'_d`d' = . if k_`x'_d`d' < 0

	} 
	
	* Do stuff within each depreciation rate
	
	recode k_tools_tech_d`d' (. = 0) 		if k_tools_d`d' != .
	recode k_machinery_tech_d`d' (. = 0) 	if k_machinery_d`d' != .
	recode k_vehicles_tech_d`d' (. = 0) 	if k_vehicles_d`d' != .
	recode k_otherassets_tech_d`d' (. = 0) 	if k_otherassets_d`d' != .

	gen  fk_total_d`d' 		= k_tools_d`d' + k_machinery_d`d' + k_furnite_d`d' + k_vehicles_d`d' + k_otherassets_d`d'
	gen  fk_total_tech_d`d' = k_tools_tech_d`d' + k_machinery_tech_d`d' + k_vehicles_tech_d`d' + k_otherassets_tech_d`d'	
}

keep	sheno wave *_d5 *_d10 *_d15 *_d20 *_d25


save "${datadir}\SLMS_capital_with_depreciation.dta", replace
