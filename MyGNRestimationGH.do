


cap program drop MyGNRestimationGH

program MyGNRestimationGH, rclass

preserve

	**** Load and prepare dataset upon each bootstrap draw
		
	use "${datadir}/${GHfile}", clear
	xtset sheno wave

	* Partial out
	do "${maindir}/GHpartialout.do"		

	** Censor materials shares above 200 %
	replace lnM = . if exp(lnM_raw - lnY_raw) > 2

	* Keep only obs with non-zero in all inputs
	keep if lnY != . & lnL != . & lnM != . & lnK != . 

	
	** Bootstramp sample
	
	bsample, cl(sheno) idcluster(bsid)	
		
	**********************************************
	*** GNR

	ren  sheno sheno_orig
	ren  numid sheno
	
	gen 	id 		= bsid
	gen 	time 	= wave

	** Use this second block to implement with partialling...

	gen 	yg 		= lnY
	gen 	l 		= lnL
	gen 	k 		= lnK
	gen 	i 		= lnM
	gen 	si 		= lnM - lnY

	* Generate lags in advance to condition on same sample

	tset id time
	gen l_1=L.l
	gen k_1=L.k
	gen l_2=L2.l
	gen k_2=L2.k


	/************************************************************/
	/**  The code below runs the share regression using a      **/ 
	/**  a (log)polynomial approximation.  This step     	   **/
	/**  recovers the output elasticity of flexible inputs 	   **/
	/**                                                        **/
	/**  The initial values are set using an OLS regression    **/
	/**  of shares (si) on a polynomial in inputs.  If the     **/
	/**  non-linear least squares procedure (nl) fails to      **/
	/**  converge, the initial values can be changed.	   **/
	/************************************************************/

	regress si l k i if si~=. & l~=. & k~=. & i~=. & l_1!=. & k_1!=.
	matrix test = e(b)
	predict crap if si~=. & l~=. & k~=. & i~=. & l_1!=. & k_1!=.
	replace crap = crap - _b[_cons]
	egen mcrap = min(crap)
	scalar ncrap=mcrap
	drop crap mcrap
	scalar ncrap=-ncrap + 0.1

	nl ( si = ln({g0=ncrap}) ) ///
		if si~=. & l~=. & k~=. & i~=. & l_1!=. & k_1!=., iter(100)

	gen test = e(converge)
	if test ~= 1 exit

	 
	predict ielas if l~=. & k~=. & si~=. & i~=. & l_1!=. & k_1!=.
	predict eg if l~=. & k~=. & si~=. & i~=. & l_1!=. & k_1!=., resid
	replace eg=-eg
	egen mexp_eg=mean(exp(eg))
	replace ielas=ielas-ln(mexp_eg)
	replace ielas=exp(ielas)
	mat beta=e(b)
	svmat double beta
	ren beta1 g0

	sum ielas

	gen gl = 0
	gen gk = 0
	gen gi = 0

	foreach var of varlist g0-gi {
		egen s`var'=mean(`var')
		drop `var'
		ren s`var' `var'
		replace `var' = `var' / mexp_eg
	}	
*	clear matrix

	gen gll 	= 0
	gen glk 	= 0
	gen gli 	= 0
	gen gkk 	= 0
	gen gki 	= 0
	gen gii 	= 0
	gen glki 	= 0


	gen integ_G_I = g0+gl*l+gk*k+ gi*i / 2

	replace integ_G_I=integ_G_I*i 
	gen vg = yg - eg - integ_G_I

	gen vg_1=L.vg


	/************************************************************/
	/**  Now to recover the remaining coefficients associated  **/
	/**  with capital and labor (the constant of the PDE)      **/
	/**                                                        **/
	/**  The initial values are set using an OLS regression    **/
	/**  of vg on log capital and loglabor                     **/
	/************************************************************/

	* Create initial values for Cobb-Douglas...
	reg vg l k
	matrix test2 		= e(b)
	matrix test3_CD 	= test2[1,1..2]
	matrix test3_CD[1,1] = test2[1,"l"]
	matrix test3_CD[1,2] = test2[1,"k"]
	matrix drop test2


	** Now, run the model restricting to Cobb-Douglas...

	* DefinePrograms cut out here
	
	gmm gmm_prod_CobbDouglas if vg!=. & l!=. & k!=. & vg_1!=. & l_1!=. & k_1!=., ///
		one  nequations(2) parameters(al ak) from(test3_CD) winitial(identity) rhs(vg l k vg_1 l_1 k_1) conv_maxiter(100)


	mat beta=e(b)
	svmat double beta
	ren beta1 al
	ren beta2 ak

	foreach var of varlist al ak {
		egen s`var'=mean(`var')
		drop `var'
		ren s`var' `var'
	}	

	/************************************************************/
	/**  Generate productivity in logs and levels, and compute **/
	/**  the output elasticities of labor and capital.         **/
	/************************************************************/

	gen logomega=vg-al*l-ak*k
	gen omega=exp(logomega)

	gen lelas=gl*i + al if ielas != .
	gen kelas=gk*i + ak if ielas != .

	/************************************************************/
	/**  End of the GNR code.                                  **/
	/************************************************************/
	

	**********************************************
	*** Write coefficient estimates to output
	
	qui sum kelas	
	return scalar betak = `r(mean)'
	qui sum ielas
	return scalar betam = `r(mean)'
	qui sum lelas
	return scalar betal = `r(mean)'	
 
restore	
	
end	
