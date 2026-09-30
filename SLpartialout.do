

** Make capital and expenses real-valued 

gen	expenses = exp(ln_em)
gen klevel   = exp(ln_k)

foreach x of varlist expenses klevel {

	cap replace `x'=`x'*187.4/187.3 if wave==2 /*base March05, w2 June05*/
	cap replace `x'=`x'*187.4/187.3 if wave==3 /*w3 Sept05*/
	cap replace `x'=`x'*187.4/195.6 if wave==4 /*w4 Dec05*/
	cap replace `x'=`x'*187.4/194.9 if wave==5 /*w5 March06*/
	cap replace `x'=`x'*187.4/207.3 if wave==6 /*w6 June06*/
	cap replace `x'=`x'*187.4/208.8 if wave==7 /*w7 Sept06*/
	cap replace `x'=`x'*187.4/230.6 if wave==8 /*w8 Dec06*/
	cap replace `x'=`x'*187.4/231.2 if wave==9 /*w9 March07*/
	cap replace `x'=`x'*187.4/255.0 if wave==10 /*w10 Sept07*/
	cap replace `x'=`x'*187.4/296.0 if wave==11 /*w11 March08*/
	cap replace `x'=`x'*187.4/326.6 if wave==12 /*w12 inferred from Science rep data*/
	cap replace `x'=`x'*187.4/342.5 if wave==13 /*w13 inferred from Science rep data*/
}

replace ln_em = ln(expenses)
replace ln_k  = ln(klevel)


** Winsorize

foreach var of varlist ln_k ln_em ln_totlabor  {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t


* Create dummies

keep 	if insample
capture tab wave, gen(waveD)
gen		lln_realrev = L.ln_realrev

do		"${maindir}/slindustry.do"
capture tab slindustry, gen(slindustryD)


*** First remove the time variation by regressing all variables on time dummies,
*** and treatment status for the preferred sample						

qui reg		ln_k waveD2-waveD9 slindustryD2-slindustryD6 treated
qui predict lnK, residual
qui replace lnK = lnK + _b[_cons]

qui reg		ln_totlabor waveD2-waveD9 slindustryD2-slindustryD6 treated 
qui predict lnL, residual
qui replace lnL = lnL + _b[_cons]

qui reg		ln_em waveD2-waveD9 slindustryD2-slindustryD6 treated 
qui predict lnM, residual
qui replace lnM = lnM + _b[_cons]

qui reg		ln_realrev waveD2-waveD9 slindustryD2-slindustryD6 treated 
qui predict lnY, residual
qui replace lnY = lnY + _b[_cons]
		
qui reg		lln_realrev waveD2-waveD9 slindustryD2-slindustryD6 treated 
qui predict llnY, residual	
qui replace llnY = llnY + _b[_cons]
