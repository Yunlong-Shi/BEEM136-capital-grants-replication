

************************************************************************************
* Table A.22 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/TableA22.log" , replace
noi di c(current_time)


********************************************************************************
***	Implement Lee bounds
********************************************************************************

use "${int_data}/TFPpooled.dta", clear

	
*******************************************************************************
**		Lee Bounds: only missing TFP, not missing obs through attrition

reghdfe ln_TFP_BB, absorb(interact slindustry ghindustry) resid(ln_TFP_BB_res)
reghdfe ln_TFP_GNR, absorb(interact slindustry ghindustry) resid(ln_TFP_GNR_res)
reghdfe yl kl ml l, absorb(interact slindustry ghindustry) resid(ln_TFP_yl_res)

reg ln_TFP_BB_res treated, cl(sheno)
reg ln_TFP_GNR_res treated, cl(sheno)
reg ln_TFP_yl_res treated, cl(sheno)

leebounds ln_TFP_BB_res treated 	if wave > 2
leebounds ln_TFP_GNR_res treated 	if wave > 2
leebounds ln_TFP_yl_res treated 	if wave > 2

leebounds ln_TFP_BB treated 	if wave > 2
leebounds ln_TFP_GNR treated 	if wave > 2
leebounds yl treated 			if wave > 2

*******************************************************************************
**		Lee Bounds: also account for missing obs due to attrition

tsfill, full

bys 	sheno: egen country_fill = mode(country)
drop 	if country_fill == 2 & wave > 6

bys 	sheno: egen treated_fill = mean(treated) if wave > 4
replace treated = treated_fill if treated == .

cap drop ln_TFP_miss
gen ln_TFP_miss = (ln_TFP_BB == .)

leebounds ln_TFP_BB_res treated 	if wave > 2
leebounds ln_TFP_GNR_res treated 	if wave > 2
leebounds ln_TFP_yl_res treated 	if wave > 2


leebounds ln_TFP_BB treated 	if wave > 2
leebounds ln_TFP_GNR treated 	if wave > 2
leebounds yl treated 			if wave > 2

********************************************
** Table is created by manual copying... ***
********************************************
		   
capture file close myfile
file open myfile using "TableA22_user_message.tex", write replace
file write myfile "NOTE: The tex file for Table A22 is created by manual copying from Table22.log." _n
file close myfile

** CLOSE LOG
noi di c(current_time)
cap log close		   
