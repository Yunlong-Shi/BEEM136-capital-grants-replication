

************************************************************************************
* Figure A.3 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/FigureA3.log" , replace
noi di c(current_time)

version 13
	
********************************************************************************
**** Distribution of unit values (regardless of item)
********************************************************************************

use		"${datadir}/Unitvalues.dta", clear


sum productvalue if wave == 1, d

sum productvalue if treated == 0 & wave > 1, d
sum productvalue if treated == 1 & wave > 1, d


* Count of large-ticket purchases
count if productvalue > 4000 & productvalue < . & treated == 0 & wave > 1
		// 44
count if productvalue > 4000 & productvalue < . & treated == 1 & wave > 1	
		// 107
		
* Number of firms with large-ticket purchases
codebook sheno if productvalue > 4000 & productvalue < . & treated == 0 & wave > 1
	// 29 firms out of 158 = 18%
	
codebook sheno if productvalue > 4000 & productvalue < . & treated == 1 & wave > 1
	// 75 firms out of 227 = 33%
	
* Count of # firms with such items at baseline

codebook sheno if productvalue > 4000 & productvalue < . & wave == 1
	// 189 firms
codebook sheno if wave == 1	
	
	
* Regression
reghdfe productvalue treated, absorb(wave) cluster(sheno)		
	
* Graph
gen		ln_productvalue = ln(productvalue)
sort 	ln_productvalue

cumul 	ln_productvalue 	if treated == 0 & insample & wave > 1, gen(CDF_pv_0)
cumul 	ln_productvalue		if treated == 1 & insample & wave > 1, gen(CDF_pv_1)

sort 	ln_productvalue

twoway 	(line CDF_pv_0 ln_productvalue, lpattern(dash)) ///
		(line CDF_pv_1 ln_productvalue, lpattern(solid) ///
			xtitle("Unit value of asset purchases (log scale)") ytitle("Empirical CDF") ///
			legend(label(1 "control") label(2 "treated")) ///
							graphregion(fcolor(white) lcolor(white)))

graph export "${graphdir}/FigureA3.pdf", replace
	

* Wilcoxon rank-sum test
ranksum productvalue if wave > 1, by(treated)
	// p = 0.0067	


** CLOSE LOG
noi di c(current_time)
cap log close
		