
************************************************************************************
* Table A.4 from Janes, Koelle and Quinn, 2025
************************************************************************************


cap log close
log using "$log/TableA4.log" , replace
noi di c(current_time)


use "${datadir}/${SLfile}", clear

* Partial out
do "${maindir}/SLpartialout.do"


*** APPENDIX TABLE SEPARATING BY TREATMENT ***

global 	LagY	= "2 3"
global 	LagK 	= "3 4"
global  LagLab 	= "1 2"
global 	LagM 	= "2 3"

cap 	drop treatever
cap 	drop ln_k
cap 	drop ln_em
cap 	drop ln_totlabor
cap 	drop ln_realrev

ren		lnK	ln_k
ren		lnM	ln_em
ren		lnL	ln_totlabor
ren		lnY	ln_realrev

gen 	trade 	= (firmtype == 3)
gen 	treatever = trade

gen 	ln_k_treat 		= ln_k * (trade == 1)
gen 	ln_k_control 	= ln_k * (trade == 0)

gen 	ln_n_treat 		= ln_totlabor * (trade == 1)
gen 	ln_n_control 	= ln_totlabor * (trade == 0)

gen 	ln_m_treat 		= ln_em * (trade == 1)
gen 	ln_m_control 	= ln_em * (trade == 0)


** First, we run the whole thing disaggregated...

eststo clear

eststo: xi: xtabond2 ln_realrev ln_k_treat ln_k_control ln_n_treat ln_n_control ///
	ln_m_treat ln_m_control l.ln_realrev treatever, ///
	gmm(l.ln_realrev, laglimits($LagY)) ///
	gmm(ln_k_treat, laglimits($LagK)) ///
	gmm(ln_k_control, laglimits($LagK)) ///
	gmm(ln_n_treat, laglimits($LagLab)) ///
	gmm(ln_n_control, laglimits($LagLab)) ///
	gmm(ln_m_treat, laglimits($LagM)) ///
	gmm(ln_m_control, laglimits($LagM)) ///
	iv(treatever, equation(level)) robust twostep artests(3) 
	
	test 	(ln_k_treat == ln_k_control) (ln_n_treat == ln_n_control) (ln_m_treat == ln_m_control)
	estadd scalar TreatmentEqual 	= r(p)

	
** Now we run it disaggregating capital...	
	
eststo: xi: xtabond2 ln_realrev ln_k_treat ln_k_control ln_totlabor ln_em treatever l.ln_realrev, ///
	gmm(l.ln_realrev, laglimits($LagY)) ///
	gmm(ln_k_treat, laglimits($LagK)) ///
	gmm(ln_k_control, laglimits($LagK)) ///
	gmm(ln_totlabor, laglimits($LagLab)) ///
	gmm(ln_em, laglimits($LagM)) ///
	iv(treatever, equation(level)) robust twostep artests(3) 

	test _b[ln_k_treat] == _b[ln_k_control]
	estadd scalar TreatmentEqual 	= r(p)


** Now we run it disaggregating labour...	

eststo: xi: xtabond2 ln_realrev ln_k ln_em ln_n_treat ln_n_control ///
	treatever l.ln_realrev, ///
	gmm(l.ln_realrev, laglimits($LagY)) ///
	gmm(ln_k, laglimits($LagK)) ///
	gmm(ln_m_treat, laglimits($LagM)) ///
	gmm(ln_m_control, laglimits($LagM)) ///	
	gmm(ln_totlabor, laglimits($LagLab)) ///
	iv(treatever, equation(level)) robust twostep artests(3)
	
	test 	_b[ln_n_treat] == _b[ln_n_control]
	estadd scalar TreatmentEqual 	= r(p)
	

** Now we run it disaggregating materials...	
	
eststo: xi: xtabond2 ln_realrev ln_k ln_m_treat ln_m_control ///
	ln_totlabor treatever l.ln_realrev, ///
	gmm(l.ln_realrev, laglimits($LagY)) ///
	gmm(ln_k, laglimits($LagK)) ///
	gmm(ln_m_treat, laglimits($LagM)) ///
	gmm(ln_m_control, laglimits($LagM)) ///	
	gmm(ln_totlabor, laglimits($LagLab)) ///
	iv(treatever, equation(level)) robust twostep artests(3) 

	test 	_b[ln_m_treat] == _b[ln_m_control]
	estadd scalar TreatmentEqual 	= r(p)
	

** Now we run it disaggregating both materials and capital...
	
eststo: xi: xtabond2 ln_realrev ln_k_treat ln_k_control ln_m_treat ln_m_control ///
	ln_totlabor treatever l.ln_realrev, ///
	gmm(l.ln_realrev, laglimits($LagY)) ///
	gmm(ln_k_treat, laglimits($LagK)) ///
	gmm(ln_k_control, laglimits($LagK)) ///
	gmm(ln_m_treat, laglimits($LagM)) ///
	gmm(ln_m_control, laglimits($LagM)) ///	
	gmm(ln_totlabor, laglimits($LagLab)) ///
	iv(treatever, equation(level)) robust twostep artests(3) 

	test 	(ln_k_treat == ln_k_control) (ln_m_treat == ln_m_control) 
	estadd scalar TreatmentEqual 	= r(p)
		

** NOW WRITE THE TABLE OUT...

global 	sub1 "Splitting\\ all\\factors"
global 	sub2 "Splitting\\ capital\\\vphantom{l}"
global 	sub3 "Splitting\\ labour\\\vphantom{l}"
global 	sub4 "Splitting\\ materials\\\vphantom{l}"
global 	sub5 "Splitting\\ capital \&\\materials"

label 	var ln_k 			"Log capital"
label 	var ln_totlabor 	"Log labour"
label 	var ln_em 			"Log materials"
label 	var ln_realrev 		"Log revenue"

label 	var ln_k_treat 		"Log capital $\times$ Trade"
label 	var ln_k_control	"Log capital $\times$ Non-trade"

label 	var ln_m_treat 		"Log materials $\times$ Trade"
label 	var ln_m_control	"Log materials $\times$ Non-trade"

label 	var ln_n_treat 		"Log labour $\times$ Trade"
label 	var ln_n_control	"Log labour $\times$ Non-trade"

order 	ln_k_treat ln_k_control ln_k ln_n_treat ln_n_control ln_totlabor ln_m_treat ln_m_control ln_em 

gen 	JunkVariable1 = .
gen 	JunkVariable2 = .
gen 	JunkVariable3 = .

label 	var JunkVariable1 " "
label 	var JunkVariable2 " "
label 	var JunkVariable3 " "

esttab 	 using "Table_A4.tex", cells(b(star fmt(%4.2fc)) se(par(( )) fmt(%4.2fc))) /// 
		   label noconstant booktabs collabels(none) ///
	   	   starlevels(* 0.10 ** 0.05 *** 0.01)  ///
		   keep(ln_k_treat ln_k_control ln_k ln_n_treat ln_n_control ln_totlabor ln_m_treat ln_m_control ln_em JunkVariable* L.ln_realrev) ///
		   order(ln_k_treat ln_k_control ln_k JunkVariable1 ln_n_treat ln_n_control ln_totlabor JunkVariable2 ///
				ln_m_treat ln_m_control ln_em JunkVariable3 L.ln_realrev) ///
		   mlabel("\specialcell{$sub1}" "\specialcell{$sub2}" "\specialcell{$sub3}" "\specialcell{$sub4}" "\specialcell{$sub5}" "\specialcell{$sub6}" "\specialcell{$sub7}" "\specialcell{$sub8}", lhs("Specification:") notitles) /// 
		   noobs stats(N N_g BlankRow hansenp BlankRow TreatmentEqual, ///
						fmt(%4.0fc %4.0fc %4.2fc %4.2fc %4.2fc %4.2fc) ///
						labels("Observations" "Microenterprises" " " "Hansen ($ p$-value)" " " "Equality by treatment ($ p$)")) ///
			substitute("\_ _") ///
			addnotes(\begin{tabular}{p{0.6\textwidth}}                     $ \mbox{} $\\                    \textit{Note}: All specification utilise the \citet{Blundell1998} System GMM estimator. We report p-values for the \citet{Hansen1982} test of over-identifying restrictions, and tes for the equality of treatments. Data are from Sri Lanka. Samples are equivalent to the preferred sample in the original study. *, ** and *** denote significance at the 10, 5 and 1 per cent levels.                     \end{tabular}) ///
		   replace 
		

** CLOSE LOG
noi di c(current_time)
cap log close		   