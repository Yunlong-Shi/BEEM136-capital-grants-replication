
***********************************************************
*** Implements the Wooldridge (2009) estimator
***********************************************************


	ren lnY		lny
	ren	lnK		lnk
	ren lnL		lnl
	ren lnM		lnm		

	
	ren	sheno			plantid

	keep	wave numid plantid lny lnk lnl lnm insample

	sort	numid wave
	
	** 		Now construct the polynomial
	gen		lnk2 = lnk^2
	gen		lnm2 = lnm^2
	gen		lnk3 = lnk^3
	gen 	lnm3 = lnm^3

	gen		lnkm  = lnk*lnm
	gen		lnk2m = lnk2*lnm
	gen 	lnkm2 = lnk*lnm2

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
	* RUN GMM AS PROPER GMM ESTIMATION -- NO IVs, NO DUPLICATES
	************************************************************************************

	rename 	lnk lnK
	rename 	lnl lnL
	rename 	lnm lnM	
	
	qui 		 reg lny lnK lnL lnM lnk2 lnm2 lnkm lnk3 lnm3 lnk2m lnkm2 laglnl laglnm laglnk
	eststo $Estnum: reg lny lnK lnL lnM if e(sample), nocons
	
	global poly 	= "{l1}*lnK + {l2}*lnM + {l3}*lnk2 + {l4}*lnm2 + {l5}*lnkm + {l6}*lnk3 + {l7}*lnm3 + {l8}*lnk2m + {l9}*lnkm2"
	global lagpoly 	= "{l1}*laglnk + {l2}*laglnm + {l3}*laglnk2 + {l4}*laglnm2 + {l5}*laglnkm + {l6}*laglnk3 + {l7}*laglnm3 + {l8}*laglnk2m + {l9}*laglnkm2"

	gmm	(lny - {b0}  - {b1} * lnK - {b2} * lnL - {b3} * lnM - $poly)  ///
		(lny- {b0} - {c0}  - {b1} * lnK - {b2} * lnL - {b3} * lnM - $lagpoly), ///
		instruments(1: lnL lnM lnK lnk2 lnm2 lnkm lnk3 lnm3 lnk2m lnkm2 laglnl laglnm laglnk laglnk2 laglnm2 laglnkm laglnk3 laglnm3 laglnkm2) ///
		instruments(2: lnK laglnl laglnm laglnk laglnk2 laglnm2 laglnkm laglnk3 laglnm3) winitial(unadjusted, independent) ///
		variables(lny lnK lnM lnL laglnl laglnm laglnk) vce(cl plantid)

	estadd scalar N_g 		= e(N_clust): $Estnum

	** still need to fix the standard errors here!!

	mat 	Vold = e(V)
	mat 	bold = e(b)

	mat 	V = Vold[2..4,2..4]
	mat   	b = bold[1,2..4]

	capture program drop mywooldridgefix
	program	mywooldridgefix, eclass
	ereturn repost V = `1'
	ereturn repost b = `2'
	end
