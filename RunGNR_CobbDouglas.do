* RunGNR
* This is SQ's version of a CD restriction on the GNR code published at the JPE.

//clear

* First, read in the data...

//use 	TempGNRData

/* NOW -- I implement the GNR code.  This is from GNR_code.do,
 downloaded from the JPE data archive for the GNR paper. */


/************************************************************/
/**  This code is designed to estimate a gross output      **/
/**  production function with three inputs: capital,       **/
/**  labor, and intermediate inputs, using a series        **/
/**  estimator for the elasticity (from the share):        **/
/**  s = ln(g0+gl*l+gk*k+gi*i+gll*l*l+glk*l*k+gli*li+	   **/
/**    	 gkk*k*k+gki*k*i+gii*i*i+glki*l*k*i) + epsilon	   **/
/**  and a series estimator for the remaining part of the  **/
/**  the production function:                              **/
/**                                                        **/
/**  y= Integral(G(k,l,i)/I)dI + al*l+ak*k+all*ll+akk*kk   **/
/**    	+alk*lk+omega+epsilon                              **/
/************************************************************/


/************************************************************/
/**  Rename variables using the instructions below.        **/ 
/**  Pay attention to upper and lower case, as it          **/
/**  matters for Stata.  Inputs, output, and the share of  **/
/**  intermediate expenditures in total revenue should     **/
/**  all be expressed in levels.  The code will create     **/
/**  the log values.  Also note that input and output      **/
/**  variables are real values, whereas the share is       **/
/**  the nominal share.                                    **/
/**                                                        **/
/**  Firm ID: id                                           **/
/**  Time series variable (e.g., year, month): time        **/
/**  Real gross output: yg_level                           **/
/**  Real labor: l_level                                   **/
/**  Real capital: k_level                                 **/
/**  Real intermediate inputs): i_level                    **/
/**  Nominal Share of intermediates: si_level              **/ 
/**                                                        **/             
/************************************************************/

egen 	id 		= group(sheno)
gen 	time 	= wave

** Use this first block to implement without partialling...
/*
gen 	yg 		= ln_realrev
gen 	l 		= ln_totlabor
gen 	k 		= ln_k
gen 	i 		= ln_em
gen 	si 		= ln_em - ln_realrev
*/

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

/*
gen ll=l*l
gen kk=k*k
gen ii=i*i
gen lk=l*k
gen li=l*i
gen ki=k*i
gen lki=l*k*i
*/


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

/*
nl ( si = ln({g0=ncrap} + {gl=_b[l]}*l + {gk=_b[k]}*k + {gi=_b[i]}*i) ) ///
	if si~=. & l~=. & k~=. & i~=., iter(100)
*/

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

*ren beta2 gl
*ren beta3 gk
*ren beta4 gi
foreach var of varlist g0-gi {
	egen s`var'=mean(`var')
	drop `var'
	ren s`var' `var'
	replace `var' = `var' / mexp_eg
}	
*clear matrix

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

* up to here!

/*
reg vg l k ll kk lk 
matrix test2 = e(b)
matrix test3 = test2[1,1..5]


matrix test3[1,1] = test2[1,"l"]
matrix test3[1,2] = test2[1,"k"]
matrix test3[1,3] = test2[1,"ll"]
matrix test3[1,4] = test2[1,"kk"]
matrix test3[1,5] = test2[1,"lk"]
matrix test3 = [0, 0, 0, 0, 0]

matrix drop test2
*/

* Create initial values for Cobb-Douglas...
reg vg l k
matrix test2 		= e(b)
matrix test3_CD 	= test2[1,1..2]
matrix test3_CD[1,1] = test2[1,"l"]
matrix test3_CD[1,2] = test2[1,"k"]
matrix drop test2


do 	DefinePrograms


** First, run the original model...
/*
gmm gmm_prod if vg!=. & l!=. & k!=. & vg_1!=. & l_1!=. & k_1!=., ///
	one nequations(5) parameters(al ak all akk alk) from(test3) winitial(identity) rhs(vg l k ll kk lk vg_1 l_1 k_1 ll_1 kk_1 lk_1) conv_maxiter(100)
*/

** Now, run the model restricting to Cobb-Douglas...

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
/*
gen sum_elas 	= lelas + kelas + ielas

su *elas

gen i_outside01 	= (ielas < 0 | ielas > 1) & (ielas != .)
gen l_outside01 	= (lelas < 0 | lelas > 1) & (lelas != .)
gen k_outside01 	= (kelas < 0 | kelas > 1) & (kelas != .)

su *outside*

** And now some very crude regressions (not controlling for anything etc...)
			
reg logomega treated, cluster(sheno)

reg omega treated, cluster(sheno)
			

** Saving TFP estimates -- [Added by MK]
ren eg tfp_gnr_epsilon
ren logomega tfp_gnr_omega
gen tfp_gnr = tfp_gnr_epsilon + tfp_gnr_omega

keep sheno* wave tfp_gnr*

*save "C:\Users\lauri\Dropbox\Sri Lanka Ghana Firm Productivity\SL Working Paper\GNR_TFP_SL.dta", replace
*/		

