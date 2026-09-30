
************************************************************************************
* Table A.1 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/TableA1.log" , replace
noi di c(current_time)

************************************************************************************
* SRI LANKA
************************************************************************************

use "${int_data}/TFPsrilanka.dta", clear

gen	ln_TFP = ln_TFP_BB

** Missing inputs and revenue

gen kmiss = 1 if k == .
replace kmiss = 0 if kmiss == .

gen	lmiss = 1 if l == .
recode lmiss( . = 0)

gen mmiss = 1 if m == .
recode mmiss (. = 0)

gen	ymiss = 1 if y == .
recode ymiss (. = 0)

gen anymiss = 1 if ln_TFP == .
recode anymiss (. = 0)

gen	attrit = 0
xtpattern, gen(pattern)
forvalue t = 1/9 {
	local t1 = `t' + 1
	local t2 = `t' + 2
	replace attrit = 1 if substr(pattern,`t1',1) == "." & substr(pattern,`t2',1) == "."  & wave == `t'
}
replace attrit = . if wave == 9

tab1 kmiss lmiss mmiss anymiss attrit		   
		   
label var treated "Dummy: treated"		   

********************************************************************************
*** 				Analyse missings and attrition




eststo clear

gen		lTFP = L.ln_TFP
gen		TFPtreat = lTFP * treated

eststo: reg		kmiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum kmiss  if treatever == 0
		estadd scalar basevalue = r(mean)

eststo: reg		lmiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum lmiss  if treatever == 0
		estadd scalar basevalue = r(mean)		
		
eststo: reg		mmiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum mmiss  if treatever == 0
		estadd scalar basevalue = r(mean)	

eststo: reg		ymiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum ymiss  if treatever == 0
		estadd scalar basevalue = r(mean)			
		
eststo: reg		anymiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum anymiss  if treatever == 0
		estadd scalar basevalue = r(mean)			
		
eststo: reg		attrit lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum attrit  if treatever == 0
		estadd scalar basevalue = r(mean)			
		

global 	sub1 "Capital"
global 	sub2 "Labour"
global 	sub3 "Materials"
global 	sub4 "Output"
global 	sub5 "Any"
global 	sub6 ""


label 	var lTFP "ln(TFP)"
label 	var TFPtreat "ln(TFP) $\times$ treated"



esttab 	using "Table_A1_SL.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treated lTFP TFPtreat) ///
		   mgroups("Missing \ldots" "Attrition", pattern(1 0 0 0 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///		   
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(basevalue N N_clust, ///
						fmt(%9.3fc %9.0fc %9.0fc) ///
						labels("Control mean" "Observations" "Microenterprises")) ///
		   addnotes(\begin{tabular}{p{0.7\textwidth}}  ///
		   $ \mbox{} $\\ ///
		   \textit{Note}: This table tests for patterns of missing TFP data and survey attrition by treatment status and TFP. Time-varying treatment status and TFP      ///
		   refer to the period immediately before the firm attrited. Each regression controls for wave dummies. *, ** and *** denote significance at the 10, 5 and 1 per cent levels. ///
		   \end{tabular}) ///
		   replace 				
				
		




************************************************************************************
* GHANA
************************************************************************************

use "${int_data}/TFPghana.dta", clear

gen	ln_TFP = ln_TFP_BB

xtset 	sheno wave

keep	if wave > 1
	// Wave 1 has all worker hours missing. We therefore take wave2 as the baseline
	// in our data (wave 2 is the second baseline, in fact).

** Make structure like in Sri Lanka: attrited are dropped, dummy in wave before

gen		attrit = 0
replace	attrit = F.attrited
drop	if attrited == 1
drop	attrited
	
	
** Missing inputs and revenue

gen kmiss = 1 if k == .
replace kmiss = 0 if kmiss == .

gen	lmiss = 1 if l == .
recode lmiss( . = 0)

gen mmiss = 1 if m == .
recode mmiss (. = 0)

gen	ymiss = 1 if y == .
recode ymiss (. = 0)

gen anymiss = 1 if ln_TFP == .
recode anymiss (. = 0)

bysort sheno: egen treatever = max(treated)

tab1 kmiss lmiss mmiss anymiss attrit		   
		   
label var treated "Dummy: treated"		   


eststo clear

gen		lTFP = L.ln_TFP
gen		TFPtreat = lTFP * treated

eststo: reg		kmiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum kmiss  if treatever == 0
		estadd scalar basevalue = r(mean)

eststo: reg		lmiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum lmiss  if treatever == 0
		estadd scalar basevalue = r(mean)		
		
eststo: reg		mmiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum mmiss  if treatever == 0
		estadd scalar basevalue = r(mean)	

eststo: reg		ymiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum ymiss  if treatever == 0
		estadd scalar basevalue = r(mean)			
		
eststo: reg		anymiss lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum anymiss  if treatever == 0
		estadd scalar basevalue = r(mean)			
		
eststo: reg		attrit lTFP treated TFPtreat i.wave , cl(sheno)
		qui sum attrit  if treatever == 0
		estadd scalar basevalue = r(mean)			
		

global 	sub1 "Capital"
global 	sub2 "Labour"
global 	sub3 "Materials"
global 	sub4 "Output"
global 	sub5 "Any"
global 	sub6 ""


label 	var lTFP "ln(TFP)"
label 	var TFPtreat "ln(TFP) $\times$ treated"



esttab 	using "Table_A1_GH.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treated lTFP TFPtreat) ///
		   mgroups("Missing \ldots" "Attrition", pattern(1 0 0 0 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///		   
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(basevalue N N_clust, ///
						fmt(%9.3fc %9.0fc %9.0fc) ///
						labels("Control mean" "Observations" "Microenterprises")) ///
		   addnotes(\begin{tabular}{p{0.7\textwidth}}  ///
		   $ \mbox{} $\\ ///
		   \textit{Note}: This table tests for patterns of missing TFP data and survey attrition by treatment status and TFP. Time-varying treatment status and TFP      ///
		   refer to the period immediately before the firm attrited. Each regression controls for wave dummies. *, ** and *** denote significance at the 10, 5 and 1 per cent levels. ///
		   \end{tabular}) ///
		   replace 				
				
		

** CLOSE LOG
noi di c(current_time)
cap log close
