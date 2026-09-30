********************************************************************************
* Table A.10 from Janes, Koelle and Quinn, 2025
********************************************************************************

cap log close
log using "$log/TableA10.log" , replace
noi di c(current_time)


********************************************************************************
***							SRI LANKA
********************************************************************************


**** COLUMN 1: BLUNDELL-BOND ****

cd "${int_data}"

use "${datadir}/${SLfile}", clear
xtset sheno wave

* Partial out
do "${maindir}/SLpartialout.do"

eststo clear

	global 	LagY	= "2 3"
	global 	LagK 	= "3 4"
	global  LagLab 	= "1 2"
	global 	LagM 	= "2 3"

**********************************************
*** TABLE 1: THE FIRST SET OF ESTIMATES... ***

*** COLUMN 1: OUR PREFERRED BLUNDELL-BOND SPECIFICATION... ***

eststo clear

eststo Est3: xtabond2 lnY lnK lnL lnM llnY, ///
						gmm(llnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan
							
		estadd scalar Hansen 	= e(hansenp)
		estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]

		
		
	quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
		
		estadd scalar CRSp 		= r(p)
			
		estadd scalar AR1 = e(ar1p)
		estadd scalar AR2 = e(ar2p)
		estadd scalar Instr = e(j)
	
	ren lnY		lny
	ren	lnK		lnk
	ren lnL		lnl
	ren lnM		lnm		
		
	ren	sheno			plantid
	ren waveD* 			waved*

	keep	wave waved* plantid lny lnk lnl lnm insample

	sort	plantid wave
	
	** 		Now construct the polynomial
	gen		lnk2 = lnk^2
	gen		lnm2 = lnm^2
	gen		lnk3 = lnk^3
	gen 	lnm3 = lnm^3

	gen		lnkm  = lnk*lnm
	gen		lnk2m = lnk2*lnm
	gen 	lnkm2 = lnk*lnm2
	
	** And those needed for translog
	gen		lnl2 = lnl^2
	gen		lnlk = lnl * lnk
	gen		lnlm = lnl * lnm
	gen		llny = L.lny
	
	** 		Now construct lags
	gen		laglnl = L.lnl
	gen		laglnm = L.lnm
	gen		laglnk = L.lnk

	gen		lag2lnl = L2.lnl
	gen		lag2lnm = L2.lnm

	gen		laglnm2 = L.lnm2
	gen		laglnk2 = L.lnk2
	gen		laglnkm = L.lnkm

	gen		laglnm3 = L.lnm3
	gen		laglnk3 = L.lnk3
	gen		laglnk2m = L.lnk2m
	gen		laglnkm2 = L.lnkm2


	
	************************************************************************************
	* TRANSLOG
	************************************************************************************
	
	rename 	lnk lnK
	rename 	lnl lnL
	rename 	lnm lnM	
	
	eststo Est1: reg lny lnK lnL lnM if e(sample), nocons
	eststo Est2: reg lny lnK lnL lnM lnk2 lnm2 lnl2 lnkm lnlk lnlm if e(sample), nocons
	
	eststo Est4: xtabond2 lny lnK lnL lnM lnk2 lnm2 lnl2 lnkm lnlk lnlm llny, ///
						gmm(llny, laglimits($LagY)) ///
						gmm(lnK lnk2 lnkm lnlk lnlm, laglimits($LagK)) ///
						gmm(lnL lnl2, laglimits($LagLab)) ///
						gmm(lnM lnm2, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan



********************************************************************************
***								GHANA
********************************************************************************


clear

cd "${tabdir}"

use "${datadir}/${GHfile}", clear

* Partial out
do "${maindir}/GHpartialout.do"


global 	LagY	= "1 2"	
global 	LagK 	= "2 3"
global  LagLab 	= "1 2"
global 	LagM 	= "2 3"

keep 	if insample

capture tab wave, gen(waveD)

*** COLUMN 3: OUR PREFERRED BLUNDELL-BOND SPECIFICATION - GHANA... ***
eststo Est7: xtabond2 lnY lnK lnL lnM llnY, ///
						gmm(llnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) nodiffsargan
							
		estadd scalar Hansen 	= e(hansenp)
		estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]

		
		
	quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
		
		estadd scalar CRSp 		= r(p)
			
		estadd scalar AR1 = e(ar1p)
		estadd scalar AR2 = e(ar2p)
		estadd scalar Instr = e(j)

	ren lnY		lny
	ren	lnK		lnk
	ren lnL		lnl
	ren lnM		lnm		
	
	ren	sheno			plantid

	keep	wave waveD* plantid numid lny lnk lnl lnm insample

	xtset 	plantid wave
	sort	plantid wave
	
	** 		Now construct the polynomial
	gen		lnk2 = lnk^2
	gen		lnm2 = lnm^2
	gen		lnk3 = lnk^3
	gen 	lnm3 = lnm^3

	gen		lnkm  = lnk*lnm
	gen		lnk2m = lnk2*lnm
	gen 	lnkm2 = lnk*lnm2
	
	** And those needed for translog
	gen		lnl2 = lnl^2
	gen		lnlk = lnl * lnk
	gen		lnlm = lnl * lnm
	gen		llny = L.lny
	
	** 		Now construct lags
	gen		laglnl = L.lnl
	gen		laglnm = L.lnm
	gen		laglnk = L.lnk

	gen		lag2lnl = L2.lnl
	gen		lag2lnm = L2.lnm

	gen		laglnm2 = L.lnm2
	gen		laglnk2 = L.lnk2
	gen		laglnkm = L.lnkm

	gen		laglnm3 = L.lnm3
	gen		laglnk3 = L.lnk3
	gen		laglnk2m = L.lnk2m
	gen		laglnkm2 = L.lnkm2


	
	************************************************************************************
	* TRANSLOG
	************************************************************************************
	
	rename 	lnk lnK
	rename 	lnl lnL
	rename 	lnm lnM	
	
	eststo Est5: reg lny lnK lnL lnM if e(sample), nocons
	eststo Est6: reg lny lnK lnL lnM lnk2 lnm2 lnl2 lnkm lnlk lnlm if e(sample), nocons
	
	eststo Est8: xtabond2 lny lnK lnL lnM lnk2 lnm2 lnl2 lnkm lnlk lnlm llny, ///
						gmm(llny, laglimits(1 1)) ///
						gmm(lnK lnk2 lnkm lnlk lnlm, laglimits(1 1)) ///
						gmm(lnL lnl2, laglimits(1 1)) ///
						gmm(lnM lnm2, laglimits(1 1)) ///
						robust twostep artests(3) nodiffsargan



********************************************************************************
***								TABLE A10
********************************************************************************

global 	sub1 "OLS"
global 	sub2 "OLS Translog"
global 	sub3 "Blundell-Bond"
global 	sub4 "BB Translog"


label 	var lnK 	"Log capital"
label 	var lnL 	"Log labour"
label 	var lnM 	"Log materials"
label 	var lny 	"Log revenue"
label 	var llny 	"L.Log revenue"
label 	var lnk2 	"(Log capital)$^2$"
label 	var lnl2 	"(Log labour)$^2$"
label 	var lnm2 	"(Log materials)$^2$"
label	var lnkm	"(Log capital) $\times$ (Log materials)"
label	var lnlk	"(Log capital) $\times$ (Log labour)"
label	var lnlm	"(Log labour) $\times$ (Log materials)"



esttab 	 Est1 Est2 Est3 Est4 Est5 Est6 Est7 Est8 using "$tabdir/Table_A10.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)  ///
		   keep(lnK lnL lnM lnk2 lnm2 lnl2 lnkm lnlk lnlm llny) ///
		   mgroups("\textbf{Sri Lanka}" "\textbf{Ghana}", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///		   		   
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}", lhs("Specification:") notitles) /// 
		   noobs stats(N N_g BlankRow Hansen CRS CRSp AR1 AR2 Instr, ///
						fmt(%4.0fc %4.0fc %4.2fc %4.2fc %4.2fc %4.2fc %4.2fc %4.2fc %4.0fc %4.2fc %4.2fc %4.2fc %4.2fc %4.2fc %4.2fc ) ///
						labels("Observations" "Microenterprises" " " "Hansen ($ p$-value)" "$\hat{\beta}_k + \hat{\beta}_l + \hat{\beta}_m$" ///
						"Constant returns ($ p$)" "AR(1) ($ p$)" "AR(2) ($ p$)" "Instruments" ///
						" " "\emph{Underidentification ($ p$-values):}")) ///
			substitute("\_ _") ///
		   addnotes(\begin{tabular}{p{0.8\textwidth}}  ///
		   $ \mbox{} $\\ ///
		   \textit{Note}: Estimators employed are \citet{Blundell1998} System GMM and the \citet{wooldridge_estimating_2009} ///
		   implementation of \citet{Ackerberg2006}. All models partial out for wave dummies and post-treatment status (not reported). ///
		   We report p-values for the \citet{Hansen1982} test of over-identifying restrictions, the \citet{Arellano1991} autocorrelation ///
		   test, and the \citet{Windmeijer2018} test of instrument informativeness. Samples are equivalent to the preferred samples ///
		   in the respective original studies. *, ** and *** denote significance at the 10, 5 and 1 per cent levels. ///
		   \end{tabular}) ///
		   replace

** CLOSE LOG
noi di c(current_time)
cap log close
		   		   