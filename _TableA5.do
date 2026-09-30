
************************************************************************************
* Table A.5 from Janes, Koelle and Quinn, 2025
************************************************************************************

cap log close
log using "$log/TableA5.log" , replace
noi di c(current_time)


use "${datadir}/${GHfile}", clear

* Partial out
do "${maindir}/GHpartialout.do"

	
eststo clear

* OLS without the lagged dependent...

eststo Est1: reg lnY lnK lnL lnM, cluster(sheno)
		estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]
		
		quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
		
		
		estadd scalar CRSp 		= r(p)
		estadd scalar N_g 		= e(N_clust)


* OLS with the lagged dependent...

eststo Est2: reg lnY lnK lnL lnM l.lnY, cluster(sheno)
		estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]
		
		quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
		
		estadd scalar CRSp 		= r(p)
		estadd scalar N_g 		= e(N_clust)


* FE without the lagged dependent...

eststo Est3: reghdfe lnY lnK lnL lnM, cluster(sheno) absorb(sheno)
		estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]
		
		quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
		
		estadd scalar CRSp 		= r(p)
		estadd scalar N_g 		= e(N_clust)

* FE with the lagged dependent...

eststo Est4: reghdfe lnY lnK lnL lnM l.lnY, cluster(sheno) absorb(sheno)
		estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]
		
		quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
		
		estadd scalar CRSp 		= r(p)
		estadd scalar N_g 		= e(N_clust)


* Blundell-Bond with longer lags...

global 	LagY	= "3 6"	
global 	LagK 	= "3 6"
global  LagLab 	= "2 6"
global 	LagM 	= "2 6"

eststo Est5: xi: xtabond2 lnY lnK lnL lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						iv(i.wave, equation(level)) robust twostep artests(3) svmat nodiffsargan 
							
		estadd scalar Hansen 	= e(hansenp)
		estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]
		
		quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
		
		estadd scalar CRSp 		= r(p)
			
		estadd scalar AR1 = e(ar1p)
		estadd scalar AR2 = e(ar2p)
		estadd scalar Instr = e(j)


	quietly xi: xtabond2 lnK lnL lnM l.lnY, ///
		gmm(l.lnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		iv(i.wave, equation(level)) robust twostep artests(3) svmat 
		display e(hansenp)
		
		global MyWind 	= e(hansenp)		
		estadd scalar Wind1 = $MyWind: Est5

	quietly xi: xtabond2 lnL lnM l.lnY lnK, ///
		gmm(l.lnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		iv(i.wave, equation(level)) robust twostep artests(3) svmat 
		display e(hansenp)

		global MyWind 	= e(hansenp)		
		estadd scalar Wind2 = $MyWind: Est5
		
	quietly xi: xtabond2 lnM l.lnY lnK lnL, ///
		gmm(l.lnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		iv(i.wave, equation(level)) robust twostep artests(3) svmat 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind3 = $MyWind: Est5
		
	quietly xi: xtabond2 l.lnY lnK lnL lnM i.wave, ///
		gmm(l.lnY, laglimits($LagY)) ///
		gmm(lnK, laglimits($LagK)) ///
		gmm(lnL, laglimits($LagLab)) ///
		gmm(lnM, laglimits($LagM)) ///
		iv(i.wave, equation(level)) robust twostep artests(3) svmat 
		display e(hansenp)
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind4 = $MyWind: Est5


* Blundell-Bond with lagged factors of production...		

global 	LagY	= "2 3"
global 	LagK 	= "3 4"
global  LagLab 	= "1 2"
global 	LagM 	= "2 3"


eststo Est6:	xi: xtabond2 lnY lnK l.lnK lnL l.lnL lnM l.lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
							
		estadd scalar Hansen 	= e(hansenp)
		estadd scalar CRS = (_b[lnK]+_b[l.lnK])/(1-_b[l.lnY]) + (_b[lnL]+_b[l.lnL])/(1-_b[l.lnY]) + (_b[lnM]+_b[l.lnM])/(1-_b[l.lnY])
		
		quietly testnl _b[lnK]/(1-_b[l.lnY]) + _b[lnL]/(1-_b[l.lnY]) + _b[lnM]/(1-_b[l.lnY]) == 1			
		estadd scalar CRSp 		= r(p)
			
		estadd scalar AR1 = e(ar1p)
		estadd scalar AR2 = e(ar2p)
		estadd scalar Instr = e(j)
		
		quietly do "${maindir}/RunMDAR.do"		
		md_ar1_SQ, nx(3) beta(e(b)) cov(e(V))
		
		estadd scalar COMFACp = $MyCOMFACp

		
	quietly 	xi: xtabond2 lnK l.lnK lnL l.lnL lnM l.lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind1 = $MyWind: Est6
		
	quietly 	xi: xtabond2 lnL l.lnL lnM l.lnM l.lnY lnK l.lnK, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind2 = $MyWind: Est6

	quietly 	xi: xtabond2 lnM l.lnM l.lnY lnK l.lnK lnL l.lnL, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind3 = $MyWind: Est6

	quietly 	xi: xtabond2 l.lnY lnK l.lnK lnL l.lnL lnM l.lnM, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind4 = $MyWind: Est6

	quietly 	xi: xtabond2 l.lnK lnK lnL l.lnL lnM l.lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind5 = $MyWind: Est6

	quietly 	xi: xtabond2 l.lnL lnK l.lnK lnL lnM l.lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind6 = $MyWind: Est6

	quietly 	xi: xtabond2 l.lnM lnK l.lnK lnL l.lnL lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind7 = $MyWind: Est6

		

* Blundell-Bond with lagged factors of production and longer lags...		

global 	LagY	= "3 6"	
global 	LagK 	= "3 6"
global  LagLab 	= "2 6"
global 	LagM 	= "2 6"

eststo Est7:	xi: xtabond2 lnY lnK l.lnK lnL l.lnL lnM l.lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
							
		estadd scalar Hansen 	= e(hansenp)
		estadd scalar CRS = (_b[lnK]+_b[l.lnK])/(1-_b[l.lnY]) + (_b[lnL]+_b[l.lnL])/(1-_b[l.lnY]) + (_b[lnM]+_b[l.lnM])/(1-_b[l.lnY])
		
		quietly testnl _b[lnK]/(1-_b[l.lnY]) + _b[lnL]/(1-_b[l.lnY]) + _b[lnM]/(1-_b[l.lnY]) == 1			
		estadd scalar CRSp 		= r(p)
			
		estadd scalar AR1 = e(ar1p)
		estadd scalar AR2 = e(ar2p)
		estadd scalar Instr = e(j)
		
		quietly do "${maindir}/RunMDAR.do"		
		md_ar1_SQ, nx(3) beta(e(b)) cov(e(V))
		
		estadd scalar COMFACp = $MyCOMFACp


	quietly 	xi: xtabond2 lnK l.lnK lnL l.lnL lnM l.lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		
		global MyWind 	= e(hansenp)		
		estadd scalar Wind1 = $MyWind: Est7

	quietly 	xi: xtabond2 lnL l.lnL lnM l.lnM l.lnY lnK l.lnK, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind2 = $MyWind: Est7

	quietly 	xi: xtabond2 lnM l.lnM l.lnY lnK l.lnK lnL l.lnL, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind3 = $MyWind: Est7

	quietly 	xi: xtabond2 l.lnY lnK l.lnK lnL l.lnL lnM l.lnM, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind4 = $MyWind: Est7

	quietly 	xi: xtabond2 l.lnK lnK lnL l.lnL lnM l.lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	

		global MyWind 	= e(hansenp)		
		estadd scalar Wind5 = $MyWind: Est7

	quietly 	xi: xtabond2 l.lnL lnK l.lnK lnL lnM l.lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind6 = $MyWind: Est7

	quietly 	xi: xtabond2 l.lnM lnK l.lnK lnL l.lnL lnM l.lnY, ///
						gmm(l.lnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan 
		display e(hansenp)	
	
		global MyWind 	= e(hansenp)		
		estadd scalar Wind7 = $MyWind: Est7

	
* Wooldridge		
	
preserve	
		
	global  Estnum "Est8"	
		
	do "${maindir}/wooldridge_estimation_gh.do"	

	est restore $Estnum
		
	mywooldridgefix V b

	* Store these altered estimates again
	estimates store $Estnum


restore
		
		
* Ackerberg, Caves and Frazer		
	
preserve	
	
do "${maindir}/acf_estimation_Dec21.do"	

estimates store Est9

restore

** NOW WRITE THE TABLE OUT...

global 	sub1 "OLS\\ (no lag)"
global 	sub2 "OLS\\ (with lag)"
global 	sub3 "FE\\ (no lag)"
global 	sub4 "FE\\ (with lag)"
global 	sub5 "Blundell-Bond\\ (more IVs)"
global 	sub6 "Blundell-Bond\\ (with lags)"
global 	sub7 "Blundell-Bond\\ (lags; more IVs)"
global 	sub8 "Wooldridge"
global 	sub9 "Ackerberg-\\ Caves-Frazer"

label 	var lnK 			"Log capital"
label 	var lnL 	"Log labour"
label 	var lnM 			"Log materials"
label 	var lnY 		"Log revenue"


esttab 	 Est* using "Table_A5.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)  ///
		   keep(lnK lnL lnM L.lnK L.lnL L.lnM L.lnY) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}" "\specialcell{$sub7}" "\specialcell{$sub8}" "\specialcell{$sub9}", lhs("Specification:") notitles) /// 
		   noobs stats(N N_g BlankRow Hansen CRS CRSp AR1 AR2 Instr COMFACp BlankRow BlankRow Wind1 Wind2 Wind3 Wind4 Wind5 Wind6 Wind7, ///
						fmt(%4.0fc %4.0fc %4.2fc %4.2fc %4.2fc %4.2fc %4.2fc %4.2fc %4.0fc %4.2fc %4.2fc %4.2fc %4.2fc %4.2fc %4.2fc ) ///
						labels("Observations" "Microenterprises" " " "Hansen ($ p$-value)" "$\hat{\beta}_k + \hat{\beta}_l + \hat{\beta}_m$" ///
						"Constant returns ($ p$)" "AR(1) ($ p$)" "AR(2) ($ p$)" "Instruments" ///
						"Common factor ($ p$)" " " "\emph{Underidentification ($ p$-values):}" "Log capital" "Log labour" ///
						"Log materials" "L.Log revenue" "L.Log capital" "L.Log labour" "L.Log materials")) ///
			substitute("\_ _") ///
			addnotes(\begin{tabular}{p{\textwidth}}                     $ \mbox{} $\\                    \textit{Note}: Estimators employed are OLS, firm fixed effects, \citet{Blundell1998} System GMM, \citet{wooldridge_estimating_2009} and the \citet{Ackerberg2006} estimator. We report p-values for the \citet{Hansen1982} test of over-identifying restrictions, the \citet{Arellano1991} autocorrelation test, test of common factor restrictions in models with lagged inputs, and the \citet{Windmeijer2018} test of instrument informativeness. Data are from Ghana. Samples are equivalent to the preferred sample in the original study. *, ** and *** denote significance at the 10, 5 and 1 per cent levels.                      \end{tabular}) ///
		   replace 		
		   
erase 	temp1.dta
erase 	temp2.dta
erase 	tempk.dta

** CLOSE LOG
noi di c(current_time)
cap log close		   
