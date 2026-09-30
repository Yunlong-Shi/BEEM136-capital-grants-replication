

************************************************************************************
* KEEP RELEVANT VARIABLES AND RENAME, CONSTRUCT POLYNOMIAL
************************************************************************************

ren lnY		lny
ren	lnK		lnk
ren lnL		lnl
ren lnM		lnm

ren	sheno			plantid

gen		laglnl = L.lnl
gen		laglnm = L.lnm

keep 	if insample
keep	wave plantid lny lnk lnl lnm laglnl laglnm


************************************************************************************
* RUN A SINGLE REALISATION OF THE acf_solution CODE
************************************************************************************

** Using the 2006 moment conditions (adapted to my problem)

do "${maindir}/acf_solution_gross_mk.do"

** ... and features of the data that are relevant for the regression table

mat		b = (vcoef[1,1],vcoef[1,2],vcoef[1,3])

qui 	count
global  N = e(N)

by plantid, sort: gen nvals = _n == 1 
count if nvals == 1
global	F = r(N)



************************************************************************************
* COPY IN AND RUN THE BOOTSTRAP CODE
************************************************************************************


/* This counter sets the number of bootstrap iterations you want to have*/
global nrep 100
matrix A =J($nrep,4,99) 
*****************************
/** Here we start the code to allow us to bootstrap the sample **/
sort plantid wave
egen gid=group(plantid)
qui su gid
scalar tt=r(max)
sort gid wave
by gid: gen count=_N
by gid: gen smalln=_n
sort gid smalln
save tempk, replace
local i=1
while `i' < $nrep + 1 {
use tempk, clear
/** Here we draw random samples with replacement. We sample each 
    set of plant level observations as an independent block.**/
quietly {
keep if gid[_n]~=gid[_n-1]
sort gid 
keep gid count
save temp1, replace
set seed `i'
gen kk=int(tt*uniform()+1)
keep kk 
gen test=99
rename kk gid
sort gid 
merge n:1 gid using temp1 
drop _merge
keep if test~=.
 drop test
egen fill=fill(1 2/3)
expand count
sort fill gid
by fill: gen smalln=_n
sort gid smalln 
merge n:1 gid smalln using tempk 
drop _merge
drop if fill==.
ren plantid oldplantid
ren fill plantid
save temp2, replace
}


*********************************
disp "Bootstrap replication `i'"
do "${maindir}/acf_solution_gross_mk.do"

matrix A[`i',1]=`i'
matrix A[`i',2]=vcoef[1,1]
matrix A[`i',3]=vcoef[1,2]
matrix A[`i',4]=vcoef[1,3]
local i=`i'+1
}

matrix coln A = iter_num kcoef lcoef mcoef
svmat A, name(col)


****************
** Get the bootstrapped variance matrix...

keep iter_num *coef
keep if iter_num~=.

foreach xx in k l m {
qui su `xx'coef, d
scalar `xx'mean=r(mean)
scalar `xx'se=r(sd)
}
display " kmean" kmean " kse" kse " lmean" lmean " lse" lse " mmean" mmean " mse" mse 

correlate	kcoef lcoef mcoef, covariance

mat			V = r(C)


****************
** Epost the estimates!


ereturn clear

capture program drop myacf
program define myacf, eclass

	local	xlist "lnK lnL lnM"
	matrix 	colnames b = `xlist'
	matrix 	colnames V = `xlist'
	matrix 	rownames V = `xlist'

	ereturn post 	b V

	estadd scalar N 	= $N
	estadd scalar N_g 	= $F
	
	estadd local  cmd "ACF"

	estadd scalar CRS 		= _b[lnK] + _b[lnL] + _b[lnM]
			
	quietly test 	_b[lnK] + _b[lnL] + _b[lnM] == 1	
			
	estadd scalar CRSp 		= r(p)

end

myacf
	
