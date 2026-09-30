/** MK, 06 June 2018
	This extends the program acf_solution written by Jadadeesh Sivadasan to a gross production
	function using
		lny		output
		lnl		labor
		lnk		capital
		lnm		materials
	all in logs. This is despite the warning of ACF to not apply their method to 
	gross production functions. We do want to do so for comparative purposes.
 **/
 

set more off

cap drop var_*
cap drop phihat

/**  Ackerberg-Caves-Frazer first stage estimation equation:  getting to phihat**/
/*  Generating 2nd order proxy polynomial  */
local i=1
foreach x in lnl lnk lnm {
gen double var_`i'=`x'
local i=`i'+1
}

forv i=1/3{
forv j=`i'/3{
gen double var_`i'`j'=var_`i'*var_`j'
}
}

/** In ACF, no coefficients are identified in the first stage. phihat is simply the predicted y*/
qui regress lny var*
qui predict phihat
xtset plantid wave
/** Once we have this phihat, we need to enter a search routine to find the best estimates for the capital
and labor coefficients.  The objective function we want to maximize is defined below --
the  moment conditions assume current values of capital and labor are orthogonal to
unpredicted parts of the productiviy term, based on the asumption that all of labor and capital are chosen in period
t-1 ***/

capture program drop ofn
program define ofn
tempvar e omega omlag omlag2 omlag3 epsilon mom1 mom2 mom3 mom4 mom5 xx
matrix score `e'=`1'
qui gen double `omega'=phihat -`e'
sort plantid wave
qui gen double `omlag'=L.`omega'
qui gen double `omlag2'=`omlag'^2
qui gen double `omlag3'=`omlag'^3

qui reg `omega' `omlag' `omlag2' `omlag3'
qui predict `xx'
qui gen `epsilon'=`omega' -`xx'

    qui gen double `mom1'= (`epsilon')
    qui su `mom1'
    scalar sumom1= (r(sum))^2

    qui gen double `mom2'= (`epsilon'*lnk)
    qui su `mom2'
    scalar sumom2= (r(sum))^2

    qui gen double `mom3'= (`epsilon'*laglnl)
    qui su `mom3'
    scalar sumom3= (r(sum))^2

    qui gen double `mom4'= (`epsilon'*laglnm)
    qui su `mom4'
    scalar sumom4= (r(sum))^2
	
    qui gen double `mom5'= (`epsilon'*`omlag')
    qui su `mom5'
    scalar sumom5= (r(sum))^2	
	
    scalar obj= -(sumom1 + sumom2 +sumom3 + sumom4 + sumom5)
    scalar `2'=obj
end

/** Using the amoeba optimization routine ***/
***********************************************************
qui reg lny lnk lnl lnm
mat initols=e(b)
amoeba ofn initols obj vcoef . 200 0.0000001


