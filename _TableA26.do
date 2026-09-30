
************************************************************************************
* Table A.26 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/TableA26.log" , replace
noi di c(current_time)


use "${int_data}/TFPsrilanka.dta", clear

merge 1:1 sheno wave using "${datadir}/SLMS_customers_data.dta", keepusing(location)
keep  if _merge == 3
drop  _merge

*** Location
sort 	sheno wave
replace location = location[_n-1] if location == . & sheno == sheno[_n-1]
gen		home = 1 if location == 10 | location == 9
replace home = 0 if home == .

gen treatedhome = treated * home
gen treatedout  = treated * (1 - home)


label var treatedhome 	"Treated \times business at home"		
label var treatedout	"Treated \times business in other location"
label var home			"Business at home"

tab		slindustry, gen(indgh)	
tab 	wave, gen(cy)
	
	
********************************************************************************
**		PANEL A) Blundell-Bond pooled without ANCOVA controls	


eststo clear

eststo: reghdfe ln_TFP_BB treatedhome treatedout home, absorb(wave slindustry) cluster(sheno)
		global 	FirmCount = e(N_clust)

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)				
						
		
eststo: qreg2 ln_TFP_BB treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.2)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)				
						
		
eststo: qreg2 ln_TFP_BB treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.4)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)				
						
		
eststo: qreg2 ln_TFP_BB treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.5)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)				
				
		
eststo: qreg2 ln_TFP_BB treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.6)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)				
				
		
eststo: qreg2 ln_TFP_BB treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.8)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)				
				
		

global 	sub1 "OLS\\\vphantom{()}"
global 	sub2 "Quantile\\(0.2)"
global 	sub3 "Quantile\\(0.4)"
global 	sub4 "Quantile\\(0.5)"
global 	sub5 "Quantile\\(0.6)"
global 	sub6 "Quantile\\(0.8)"

label 	var treated "Dummy: Treated"

esttab 	 using "Table_A26_A.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treatedhome treatedout home) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(N N_clust BlankRow TreatEqual TreatEqual0, ///
						fmt(%4.0fc %4.0fc %4.0fc %4.2fc %4.2fc) ///
						labels("Observations" "Microenterprises" " " "Treatments equal ($ p$)" "Treatments zero ($ p$)")) ///
		   replace 		
	
	

********************************************************************************
**		PANEL B) GNR pooled without ANCOVA controls	


eststo clear

eststo: reghdfe ln_TFP_GNR treatedhome treatedout home, absorb(wave slindustry) cluster(sheno)
		global 	FirmCount = e(N_clust)

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)				
		
eststo: qreg2 ln_TFP_GNR treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.2)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)		
		
eststo: qreg2 ln_TFP_GNR treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.4)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		
eststo: qreg2 ln_TFP_GNR treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.5)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		
eststo: qreg2 ln_TFP_GNR treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.6)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		
eststo: qreg2 ln_TFP_GNR treatedhome treatedout home cy* ind* ind*, cluster(sheno) q(0.8)
		estadd scalar N_clust = $FirmCount
		
		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		
		
global 	sub1 "OLS\\\vphantom{()}"
global 	sub2 "Quantile\\(0.2)"
global 	sub3 "Quantile\\(0.4)"
global 	sub4 "Quantile\\(0.5)"
global 	sub5 "Quantile\\(0.6)"
global 	sub6 "Quantile\\(0.8)"

label 	var treated "Dummy: Treated"

esttab 	 using "Table_A26_B.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treatedhome treatedout home) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(N N_clust BlankRow TreatEqual TreatEqual0, ///
						fmt(%4.0fc %4.0fc %4.0fc %4.2fc %4.2fc) ///
						labels("Observations" "Microenterprises" " " "Treatments equal ($ p$)" "Treatments zero ($ p$)")) ///
		   replace 		
	
		

	
********************************************************************************
**		PANEL C) Labor productivity pooled without ANCOVA controls	


eststo clear

eststo: reghdfe yl treatedhome treatedout home kl ml l, absorb(wave slindustry) cluster(sheno)
		global 	FirmCount = e(N_clust)

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		
eststo: qreg2 yl treatedhome treatedout home kl ml l cy*, cluster(sheno) q(0.2)
		estadd scalar N_clust = $FirmCount
		
		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		
eststo: qreg2 yl treatedhome treatedout home kl ml l  cy*, cluster(sheno) q(0.4)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		
eststo: qreg2 yl treatedhome treatedout home kl ml l  cy*, cluster(sheno) q(0.5)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		
eststo: qreg2 yl treatedhome treatedout home kl ml l  cy*, cluster(sheno) q(0.6)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		
eststo: qreg2 yl treatedhome treatedout home kl ml l  cy*, cluster(sheno) q(0.8)
		estadd scalar N_clust = $FirmCount

		test (treatedhome == treatedout)
		estadd scalar TreatEqual 	= r(p)
		
		test (treatedhome == treatedout == 0)
		estadd scalar TreatEqual0 	= r(p)	
		

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

esttab 	 using "Table_A26_C.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treatedhome treatedout home kl ml l) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(N N_clust BlankRow TreatEqual TreatEqual0, ///
						fmt(%4.0fc %4.0fc %4.0fc %4.2fc %4.2fc) ///
						labels("Observations" "Microenterprises" " " "Treatments equal ($ p$)" "Treatments zero ($ p$)")) ///
						drop(kl ml l) ///
		   replace 		

		   
** CLOSE LOG
noi di c(current_time)
cap log close
		   