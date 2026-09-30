
************************************************************************************
* Table A.9 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/TableA9.log" , replace
noi di c(current_time)


use "${int_data}/TFPpooled.dta", clear

	
********************************************************************************
**		Translog pooled without ANCOVA controls	


eststo clear

eststo: reghdfe ln_TFP_TL treated, absorb(interact ghindustry slindustry) cluster(sheno)
		global 	FirmCount = e(N_clust)

eststo: qreg2 ln_TFP_TL treated cy* ind* ind*, cluster(sheno) q(0.2)
		estadd scalar N_clust = $FirmCount
		
eststo: qreg2 ln_TFP_TL treated cy* ind* ind*, cluster(sheno) q(0.4)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 ln_TFP_TL treated cy* ind* ind*, cluster(sheno) q(0.5)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 ln_TFP_TL treated cy* ind* ind*, cluster(sheno) q(0.6)
		estadd scalar N_clust = $FirmCount

eststo: qreg2 ln_TFP_TL treated cy* ind* ind*, cluster(sheno) q(0.8)
		estadd scalar N_clust = $FirmCount
		

global 	sub1 "OLS\\\vphantom{()}"
global 	sub2 "Quantile\\(0.2)"
global 	sub3 "Quantile\\(0.4)"
global 	sub4 "Quantile\\(0.5)"
global 	sub5 "Quantile\\(0.6)"
global 	sub6 "Quantile\\(0.8)"

label 	var treated "Dummy: Treated"

esttab 	 using "Table_A9.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)   ///
		   keep(treated) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}", notitles) /// 
		   noobs stats(N N_clust, ///
						fmt(%4.0fc %4.0fc) ///
						labels("Observations" "Microenterprises")) ///
		   addnotes(\begin{tabular}{p{0.8\textwidth}}  ///
		   $ \mbox{} $\\ ///
		   \textit{Note}: This table reports the robustness to functional form of the effect of treatment on TFP at different moments of the distribution, for microenterprises in Ghana and Sri Lanka. TFP is estimated using a translog functional form and via OLS. Regressions include wave-times-survey fixed effects, and control for baseline TFP. *, ** and *** denote significance at the 10, 5 and 1 per cent levels. ///
		   \end{tabular}) ///		   
		   replace 		
	
		   
** CLOSE LOG
noi di c(current_time)
cap log close
		   