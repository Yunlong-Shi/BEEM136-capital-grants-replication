

************************************************************************************
* Table A.20 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/TableA20.log" , replace
noi di c(current_time)


use "${int_data}/TFPsrilanka.dta", clear

label var cash 			"Dummy: Cash treatment"		
label var equip			"Dummy: Equipment treatment"

tab		slindustry, gen(indgh)	
tab 	wave, gen(cy)
	
	
********************************************************************************
**		PANEL A) Blundell-Bond pooled without ANCOVA controls	


eststo clear

eststo: reghdfe ln_TFP_BB cash equip, absorb(wave slindustry) cluster(sheno)
		global 	FirmCount = e(N_clust)

eststo: qreg2 ln_TFP_BB cash equip cy* ind* ind*, cluster(sheno) q(0.2)
		estadd scalar N_clust = $FirmCount
		
eststo: qreg2 ln_TFP_BB cash equip cy* ind* ind*, cluster(sheno) q(0.4)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 ln_TFP_BB cash equip cy* ind* ind*, cluster(sheno) q(0.5)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 ln_TFP_BB cash equip cy* ind* ind*, cluster(sheno) q(0.6)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 ln_TFP_BB cash equip cy* ind* ind*, cluster(sheno) q(0.8)
		estadd scalar N_clust = $FirmCount
		

global 	sub1 "OLS\\\vphantom{()}"
global 	sub2 "Quantile\\(0.2)"
global 	sub3 "Quantile\\(0.4)"
global 	sub4 "Quantile\\(0.5)"
global 	sub5 "Quantile\\(0.6)"
global 	sub6 "Quantile\\(0.8)"

label 	var treated "Dummy: Treated"

esttab 	 using "Table_A20_A.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(cash equip) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(N N_clust, ///
						fmt(%4.0fc %4.0fc) ///
						labels("Observations" "Microenterprises")) ///
		   replace 		
	
	

********************************************************************************
**		PANEL B) GNR pooled without ANCOVA controls	


eststo clear

eststo: reghdfe ln_TFP_GNR cash equip, absorb(wave slindustry) cluster(sheno)
		global 	FirmCount = e(N_clust)

eststo: qreg2 ln_TFP_GNR cash equip cy* ind* ind*, cluster(sheno) q(0.2)
		estadd scalar N_clust = $FirmCount
		
eststo: qreg2 ln_TFP_GNR cash equip cy* ind* ind*, cluster(sheno) q(0.4)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 ln_TFP_GNR cash equip cy* ind* ind*, cluster(sheno) q(0.5)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 ln_TFP_GNR cash equip cy* ind* ind*, cluster(sheno) q(0.6)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 ln_TFP_GNR cash equip cy* ind* ind*, cluster(sheno) q(0.8)
		estadd scalar N_clust = $FirmCount
		

global 	sub1 "OLS\\\vphantom{()}"
global 	sub2 "Quantile\\(0.2)"
global 	sub3 "Quantile\\(0.4)"
global 	sub4 "Quantile\\(0.5)"
global 	sub5 "Quantile\\(0.6)"
global 	sub6 "Quantile\\(0.8)"

label 	var treated "Dummy: Treated"

esttab 	 using "Table_A20_B.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(cash equip) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(N N_clust, ///
						fmt(%4.0fc %4.0fc) ///
						labels("Observations" "Microenterprises")) ///
		   replace 		
	
		

	
********************************************************************************
**		PANEL C) Labor productivity pooled without ANCOVA controls	


eststo clear

eststo: reghdfe yl cash equip kl ml l, absorb(wave slindustry) cluster(sheno)
		global 	FirmCount = e(N_clust)

eststo: qreg2 yl cash equip kl ml l cy*, cluster(sheno) q(0.2)
		estadd scalar N_clust = $FirmCount
		
eststo: qreg2 yl cash equip kl ml l  cy*, cluster(sheno) q(0.4)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 yl cash equip kl ml l  cy*, cluster(sheno) q(0.5)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 yl cash equip kl ml l  cy*, cluster(sheno) q(0.6)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 yl cash equip kl ml l  cy*, cluster(sheno) q(0.8)
		estadd scalar N_clust = $FirmCount


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

esttab 	 using "Table_A20_C.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(cash equip kl ml l) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(N N_clust, ///
						fmt(%4.0fc %4.0fc) ///
						labels("Observations" "Microenterprises")) ///
		   replace 		

		   
** CLOSE LOG
noi di c(current_time)
cap log close
		   