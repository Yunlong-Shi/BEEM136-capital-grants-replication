* Generating the master file for this paper based on the data available online from the original study

************************************************************************************
* SETTING UP THE DO-FILE
************************************************************************************
clear all
version 13
set more off, perm

cd "$datadir"

** Working on individual wave datasets to generate some additional variables.
** These then get merged into the main original dataset.

* Rename the datasets so the number in the name of the dataset corresponds to the letter used to identify questions from different waves
use 	SLMSround1.dta, clear
gen 	wave = 1
save 	"${maindir}/Results/IntData/SLMSrounda", replace

use 	SLMSround2.dta, clear
save 	"${maindir}/Results/IntData/SLMSroundb", replace

use 	SLMSround3_labeled.dta, clear
save 	"${maindir}/Data/SLMSround3", replace
save 	"${maindir}/Results/IntData/SLMSroundc", replace

use 	SLMSround4.dta, clear
save 	"${maindir}/Results/IntData/SLMSroundd", replace

use 	SLMSround5_labeled.dta, clear
save 	"${maindir}/Data/SLMSround5", replace
save 	"${maindir}/Results/IntData/SLMSrounde", replace

use 	SLMSround6.dta, clear
save 	"${maindir}/Results/IntData/SLMSroundf", replace

use 	SLMSround7.dta, clear
save 	"${maindir}/Results/IntData/SLMSroundg", replace

use 	SLMSround8.dta, clear
save 	"${maindir}/Results/IntData/SLMSroundh", replace

use 	SLMSround9.dta, clear
save 	"${maindir}/Results/IntData/SLMSroundi", replace

use 	SLMSround10.dta, clear
save 	"${maindir}/Results/IntData/SLMSroundj", replace

use 	SLMSround11.dta, clear
save	"${maindir}/Results/IntData/SLMSroundk", replace

use 	SLMSround12.dta, clear
save 	"${maindir}/Results/IntData/SLMSroundl", replace

use 	SLMSround13.dta, clear
save 	"${maindir}/Results/IntData/SLMSroundm", replace



**** ROUND 1 ***************************************
**** Only has a data on the existing capital stock, not new acquisitions, so is different from subsequent waves
**** Estimating the share of various categories of capital goods

cd "${maindir}/Results/IntData"
use SLMSrounda.dta, clear
*ren q1_36* kadd*

rename edi district

* Replace values as missing if item is not own
forvalue i = 1/6 {
	forvalue j = 1/10 {
		cap replace q1_36f`i'`j' = . 	if q1_36d`i'`j' != 1
	}
}

* Adds up the value of the individual capital categories
egen kt_tools 		= rowtotal(q1_36f1*), missing
egen kt_machinery 	= rowtotal(q1_36f2*), missing
egen kt_furnite 	= rowtotal(q1_36f3*), missing
egen kt_vehicles 	= rowtotal(q1_36f4*), missing
egen kt_site 		= rowtotal(q1_36f5*), missing
egen kt_otherassets = rowtotal(q1_36f6*), missing
egen kt_total		= rowtotal(q1_36f*), missing


**** Estimating average unit prices (where we believe higher unit prices indicate better technology)		
* Calculates the mean price of items, need to recode 0 to . first, otherwise the mean doesn't work out
for var q1_36f1*: replace X = . if X==0 // no new capital is variably 0 or ., but egen requires .
egen km_tools 		= rowmean(q1_36f1*)
egen km_machinery 	= rowmean(q1_36f2*)
egen km_furnite 	= rowmean(q1_36f3*)
egen km_vehicles 	= rowmean(q1_36f4*)
egen km_site 		= rowmean(q1_36f5*)
egen km_otherassets = rowmean(q1_36f6*)
egen km_total		= rowmean(q1_36f*)

**** Material and equipment costs in the first wave

ren q2_1* mtls*
ren mtls_11 mtls_12 // have added another variable in the second wave, so the question number changes, this corrects this problem
ren mtls_10 mtls_11


** Tech codes for each of the products
cap drop techval*

forvalue i = 1/6 {
	forvalue j = 1/10 {
	
	tempvar var
	cap gen		`var' = q1_36b`i'`j'
	
	cap gen		techval_`i'_`j' = .
	cap replace techval_`i'_`j' = 	q1_36f`i'`j' if  ///
							`var' == 7 | `var' == 11 | `var' == 14 | `var' == 15 | ///
							`var' == 19 | `var' == 23 | `var' == 27 | `var' == 28 | ///
							`var' == 30 | `var' == 31 | `var' == 35 | `var' == 40 | ///
							`var' == 47 | `var' == 48 | `var' == 53 | `var' == 56 | ///
							`var' == 59 | `var' == 60 | `var' == 61 | `var' == 63 | ///
							`var' == 201 | `var' == 202 | `var' == 203 | `var' == 204 | ///
							`var' == 205 | `var' == 207 | `var' == 208 | `var' == 210 | ///
							`var' == 212 | `var' == 213 | `var' == 214 | `var' == 215 | ///
							`var' == 216 | `var' == 217 | `var' == 218 | `var' == 224 | ///
							`var' == 225 | `var' == 226 | `var' == 227 | `var' == 229 | ///
							`var' == 230 | `var' == 232 | `var' == 233 | `var' == 234 | ///
							`var' == 235 | `var' == 236 | `var' == 239 | `var' == 242 | ///
							`var' == 243 | `var' == 244 | `var' == 245 | `var' == 246 | ///
							`var' == 247 | `var' == 248 | `var' == 250 | `var' == 253 | ///
							`var' == 254 | `var' == 255 | `var' == 256 | `var' == 257 | ///
							`var' == 258 | `var' == 259 | `var' == 260 | `var' == 261 | ///
							`var' == 262 | `var' == 263 | `var' == 264 | `var' == 265 | ///
							`var' == 266 | `var' == 267 | `var' == 268 | ///
							`var' == 603 | `var' == 604 | `var' == 605 | `var' == 607 | ///
							`var' == 608 | `var' == 1002 | `var' == 1003 | `var' == 1004 | ///
							`var' == 1005 | `var' == 1006 | `var' == 1007 | `var' == 1008 | ///
							`var' == 1010 | `var' == 1020 | `var' == 1021 | `var' == 1026 | ///
							`var' == 1028 | `var' == 1031 | `var' == 1037 | `var' == 1039
	}
}
* Adds up the value of the individual tech capital per category
egen kt_tools_tech 			= rowtotal(techval_1_*), missing
egen kt_machinery_tech 		= rowtotal(techval_2_*), missing
egen kt_vehicles_tech 		= rowtotal(techval_4_*), missing
egen kt_otherassets_tech 	= rowtotal(techval_6_*), missing
egen kt_total_tech			= rowtotal(techval_*), missing

**** Estimating average unit prices (where we believe higher unit prices indicate better technology)		
* Calculates the mean price of items, need to recode 0 to . first, otherwise the mean doesn't work out
egen km_tools_tech 			= rowmean(techval_1_*)
egen km_machinery_tech 		= rowmean(techval_2_*)
egen km_vehicles_tech 		= rowmean(techval_4_*)
egen km_otherassets_tech 	= rowmean(techval_6_*)
egen km_total_tech			= rowmean(techval_*)

*** Get inventories
ren	 q1_38	inventories

***** DK addition
gen famlabor_hours = q1_27a5 if q1_27a3 > 1 & q1_27a3 < .
replace famlabor_hours = famlabor_hours + q1_27b5 if q1_27b3 > 1 & q1_27b3 < .
replace famlabor_hours = famlabor_hours + q1_27c5 if q1_27c3 > 1 & q1_27c3 < .
* Hired means "non-family"
gen hiredlabor_hours = q1_27a5 if q1_27a3 == 1
replace hiredlabor_hours = hiredlabor_hours + q1_27b5 if q1_27b3 == 1
replace hiredlabor_hours = hiredlabor_hours + q1_27c5 if q1_27c3 == 1

*keep sheno q2_1_* q1_3 q1_23a q1_23b famlabor_hours hiredlabor_hours qm2 qt2 qs2
keep sheno wave kt* km* inventories q2* q3_1* q1_3 q1_23a q1_23b famlabor_hours hiredlabor_hours qm2 qt2 qs2 mtls* district

*ren q2_1_11 q2_1_12
*ren q2_1_10 q2_1_11
*renpfix q2_1 mtls
ren q1_3 ownlabor_yn
ren q1_23a ownlabor_hours
ren q1_23b ownlabor_normal_hours
ren qm2 Mrevenue
ren qt2 Trevenue
ren qs2 Srevenue
***** DK addition end


*keep sheno wave kt* km* inventories
save wave_extract_a, replace


**** ROUNDS 2-9 *************************************
foreach x in b c d e f g h i j k{
//foreach x in b{

use SLMSround`x'.dta, clear


* Rename questions in a common way
ren `x'4_4* kadd_* // questions in the surveys are the same, but each wave has a different letter prefix
destring kadd_*, replace
ren `x'4_2* krep_* // commons repairs prefix
destring krep_*, replace
ren `x'4_7* kdam_* // commons repairs prefix
destring kdam_*, replace

**** Code for materials and equipment costs
*ren `x'3* *
*ren _* q3_*

* Get inventories
ren		`x'2_13	inventories
recode  inventories (. = 0) if `x'2_12 == 2

* Replace values as missing if item is not own
forvalue i = 1/6 {
	forvalue j = 1/10 {
		cap replace kadd_f`i'_`j' = . 	if kadd_d`i'_`j' != 1
	}
}


* Adds up the NEW value of the individual capital categories
egen knt_tools 		= rowtotal(kadd_f1*), missing
egen knt_machinery 	= rowtotal(kadd_f2*), missing
egen knt_furnite 	= rowtotal(kadd_f3*), missing
egen knt_vehicles 	= rowtotal(kadd_f4*), missing
capture noisily egen knt_site 		= rowtotal(kadd_f5*), missing
egen knt_otherassets = rowtotal(kadd_f6*), missing
egen knt_total		= rowtotal(kadd_f*), missing

* Adds up the REPAIR value of the individual capital categories
cap egen krt_tools 		= rowtotal(krep_e1*), missing
cap egen krt_machinery 	= rowtotal(krep_e2*), missing
cap egen krt_furnite 	= rowtotal(krep_e3*), missing
cap egen krt_vehicles 	= rowtotal(krep_e4*), missing
capture noisily egen krt_site 		= rowtotal(krep_e5*), missing
cap egen krt_otherassets = rowtotal(krep_e6*), missing
cap egen krt_total		= rowtotal(krep_e*), missing

* Adds up the DAMAGE value of the individual capital categories
cap egen kdt_tools 		= rowtotal(kdam_f1*), missing
cap egen kdt_machinery 	= rowtotal(kdam_f2*), missing
cap egen kdt_furnite 	= rowtotal(kdam_f3*), missing
cap egen kdt_vehicles 	= rowtotal(kdam_f4*), missing
capture noisily egen kdt_site 		= rowtotal(kdam_f5*), missing
cap egen kdt_otherassets = rowtotal(kdam_f6*), missing
cap egen kdt_total		= rowtotal(kdam_f*), missing

* Adds up the SALE/RETURN value of the individual capital categories
cap egen kst_tools 		= rowtotal(kdam_d1*), missing
cap egen kst_machinery 	= rowtotal(kdam_d2*), missing
cap egen kst_furnite 	= rowtotal(kdam_d3*), missing
cap egen kst_vehicles 	= rowtotal(kdam_d4*), missing
capture noisily egen kst_site 		= rowtotal(kdam_d5*), missing
cap egen kst_otherassets = rowtotal(kdam_d6*), missing
cap egen kst_total		= rowtotal(kdam_d*), missing

**** Estimating average unit prices (where we believe higher unit prices indicate better technology)		
* Calculates the mean price of items, need to recode 0 to . first, otherwise the mean doesn't work out
for var kadd_f1*: replace X = . if X==0
egen knm_tools 		= rowmean(kadd_f1*)
egen knm_machinery 	= rowmean(kadd_f2*)
egen knm_furnite 	= rowmean(kadd_f3*)
egen knm_vehicles 	= rowmean(kadd_f4*)
capture noisily egen knm_site 		= rowmean(kadd_f5*)
egen knm_otherassets = rowmean(kadd_f6*)
egen knm_total		= rowmean(kadd_f*)


** Tech codes for each of the NEW products
cap drop techval*

forvalue i = 1/6 {
	forvalue j = 1/10 {
	
	tempvar var
	cap gen		`var' = kadd_b`i'_`j'
	
	gen		techval_`i'_`j' = .
	cap replace techval_`i'_`j' = 	kadd_f`i'_`j' if  ///
							`var' == 7 | `var' == 11 | `var' == 14 | `var' == 15 | ///
							`var' == 19 | `var' == 23 | `var' == 27 | `var' == 28 | ///
							`var' == 30 | `var' == 31 | `var' == 35 | `var' == 40 | ///
							`var' == 47 | `var' == 48 | `var' == 53 | `var' == 56 | ///
							`var' == 59 | `var' == 60 | `var' == 61 | `var' == 63 | ///
							`var' == 201 | `var' == 202 | `var' == 203 | `var' == 204 | ///
							`var' == 205 | `var' == 207 | `var' == 208 | `var' == 210 | ///
							`var' == 212 | `var' == 213 | `var' == 214 | `var' == 215 | ///
							`var' == 216 | `var' == 217 | `var' == 218 | `var' == 224 | ///
							`var' == 225 | `var' == 226 | `var' == 227 | `var' == 229 | ///
							`var' == 230 | `var' == 232 | `var' == 233 | `var' == 234 | ///
							`var' == 235 | `var' == 236 | `var' == 239 | `var' == 242 | ///
							`var' == 243 | `var' == 244 | `var' == 245 | `var' == 246 | ///
							`var' == 247 | `var' == 248 | `var' == 250 | `var' == 253 | ///
							`var' == 254 | `var' == 255 | `var' == 256 | `var' == 257 | ///
							`var' == 258 | `var' == 259 | `var' == 260 | `var' == 261 | ///
							`var' == 262 | `var' == 263 | `var' == 264 | `var' == 265 | ///
							`var' == 266 | `var' == 267 | `var' == 268 | ///
							`var' == 603 | `var' == 604 | `var' == 605 | `var' == 607 | ///
							`var' == 608 | `var' == 1002 | `var' == 1003 | `var' == 1004 | ///
							`var' == 1005 | `var' == 1006 | `var' == 1007 | `var' == 1008 | ///
							`var' == 1010 | `var' == 1020 | `var' == 1021 | `var' == 1026 | ///
							`var' == 1028 | `var' == 1031 | `var' == 1037 | `var' == 1039
	}
}
* Adds up the new value of the individual tech capital per category
egen knt_tools_tech 		= rowtotal(techval_1_*), missing
egen knt_machinery_tech 	= rowtotal(techval_2_*), missing
egen knt_vehicles_tech 		= rowtotal(techval_4_*), missing
egen knt_otherassets_tech 	= rowtotal(techval_6_*), missing
egen knt_total_tech			= rowtotal(techval_*), missing

**** Estimating average unit prices (where we believe higher unit prices indicate better technology)		
* Calculates the mean price of items, need to recode 0 to . first, otherwise the mean doesn't work out
for var kadd_f1*: replace X = . if X==0
egen knm_tools_tech 		= rowmean(techval_1_*)
egen knm_machinery_tech 	= rowmean(techval_2_*)
egen knm_vehicles_tech 		= rowmean(techval_4_*)
egen knm_otherassets_tech 	= rowmean(techval_6_*)
egen knm_total_tech			= rowmean(techval_*)



**** Tech codes for each of the REPAIRED products

// Note: Here we express the value of the REPAIR (= addition to capital stock), 
// 		 not the value of the item after repair. For the latter to be useful for 
//		 perpetual inventory, we would need to identify the initial item value
//		 and remove to avoid double counting.

cap drop techval*

forvalue i = 1/6 {
	forvalue j = 1/10 {
	
	tempvar var
	cap gen		`var' = krep_c`i'_`j' // Note the different variable names here!
	
	cap gen		techval_`i'_`j' = .
									  // Also note different variable name here!
	cap replace techval_`i'_`j' = 	krep_e`i'_`j' if  ///
							`var' == 7 | `var' == 11 | `var' == 14 | `var' == 15 | ///
							`var' == 19 | `var' == 23 | `var' == 27 | `var' == 28 | ///
							`var' == 30 | `var' == 31 | `var' == 35 | `var' == 40 | ///
							`var' == 47 | `var' == 48 | `var' == 53 | `var' == 56 | ///
							`var' == 59 | `var' == 60 | `var' == 61 | `var' == 63 | ///
							`var' == 201 | `var' == 202 | `var' == 203 | `var' == 204 | ///
							`var' == 205 | `var' == 207 | `var' == 208 | `var' == 210 | ///
							`var' == 212 | `var' == 213 | `var' == 214 | `var' == 215 | ///
							`var' == 216 | `var' == 217 | `var' == 218 | `var' == 224 | ///
							`var' == 225 | `var' == 226 | `var' == 227 | `var' == 229 | ///
							`var' == 230 | `var' == 232 | `var' == 233 | `var' == 234 | ///
							`var' == 235 | `var' == 236 | `var' == 239 | `var' == 242 | ///
							`var' == 243 | `var' == 244 | `var' == 245 | `var' == 246 | ///
							`var' == 247 | `var' == 248 | `var' == 250 | `var' == 253 | ///
							`var' == 254 | `var' == 255 | `var' == 256 | `var' == 257 | ///
							`var' == 258 | `var' == 259 | `var' == 260 | `var' == 261 | ///
							`var' == 262 | `var' == 263 | `var' == 264 | `var' == 265 | ///
							`var' == 266 | `var' == 267 | `var' == 268 | ///
							`var' == 603 | `var' == 604 | `var' == 605 | `var' == 607 | ///
							`var' == 608 | `var' == 1002 | `var' == 1003 | `var' == 1004 | ///
							`var' == 1005 | `var' == 1006 | `var' == 1007 | `var' == 1008 | ///
							`var' == 1010 | `var' == 1020 | `var' == 1021 | `var' == 1026 | ///
							`var' == 1028 | `var' == 1031 | `var' == 1037 | `var' == 1039
	}
}
* Adds up the REPAIR value of the individual tech capital per category
cap egen krt_tools_tech 		= rowtotal(techval_1_*), missing
cap egen krt_machinery_tech 	= rowtotal(techval_2_*), missing
cap egen krt_vehicles_tech 		= rowtotal(techval_4_*), missing
cap egen krt_otherassets_tech 	= rowtotal(techval_6_*), missing
cap egen krt_total_tech			= rowtotal(techval_*), missing



**** Tech codes for each of the DAMAGED products
cap drop techval*

forvalue i = 1/6 {
	forvalue j = 1/10 {
	
	tempvar var
	cap gen		`var' = kdam_b`i'_`j'
	
	cap gen		techval_`i'_`j' = .
	cap replace techval_`i'_`j' = 	kdam_f`i'_`j' if  ///
							`var' == 7 | `var' == 11 | `var' == 14 | `var' == 15 | ///
							`var' == 19 | `var' == 23 | `var' == 27 | `var' == 28 | ///
							`var' == 30 | `var' == 31 | `var' == 35 | `var' == 40 | ///
							`var' == 47 | `var' == 48 | `var' == 53 | `var' == 56 | ///
							`var' == 59 | `var' == 60 | `var' == 61 | `var' == 63 | ///
							`var' == 201 | `var' == 202 | `var' == 203 | `var' == 204 | ///
							`var' == 205 | `var' == 207 | `var' == 208 | `var' == 210 | ///
							`var' == 212 | `var' == 213 | `var' == 214 | `var' == 215 | ///
							`var' == 216 | `var' == 217 | `var' == 218 | `var' == 224 | ///
							`var' == 225 | `var' == 226 | `var' == 227 | `var' == 229 | ///
							`var' == 230 | `var' == 232 | `var' == 233 | `var' == 234 | ///
							`var' == 235 | `var' == 236 | `var' == 239 | `var' == 242 | ///
							`var' == 243 | `var' == 244 | `var' == 245 | `var' == 246 | ///
							`var' == 247 | `var' == 248 | `var' == 250 | `var' == 253 | ///
							`var' == 254 | `var' == 255 | `var' == 256 | `var' == 257 | ///
							`var' == 258 | `var' == 259 | `var' == 260 | `var' == 261 | ///
							`var' == 262 | `var' == 263 | `var' == 264 | `var' == 265 | ///
							`var' == 266 | `var' == 267 | `var' == 268 | ///
							`var' == 603 | `var' == 604 | `var' == 605 | `var' == 607 | ///
							`var' == 608 | `var' == 1002 | `var' == 1003 | `var' == 1004 | ///
							`var' == 1005 | `var' == 1006 | `var' == 1007 | `var' == 1008 | ///
							`var' == 1010 | `var' == 1020 | `var' == 1021 | `var' == 1026 | ///
							`var' == 1028 | `var' == 1031 | `var' == 1037 | `var' == 1039
	}
}
* Adds up the DAMAGE value of the individual tech capital per category
cap egen kdt_tools_tech 		= rowtotal(techval_1_*), missing
cap egen kdt_machinery_tech 	= rowtotal(techval_2_*), missing
cap egen kdt_vehicles_tech 		= rowtotal(techval_4_*), missing
cap egen kdt_otherassets_tech 	= rowtotal(techval_6_*), missing
cap egen kdt_total_tech			= rowtotal(techval_*), missing



**** Tech codes for each of the SOLD/RETURNED products
cap drop techval*

forvalue i = 1/6 {
	forvalue j = 1/10 {
	
	tempvar var
	cap gen		`var' = kdam_b`i'_`j'
	
	cap gen		techval_`i'_`j' = .
	cap replace techval_`i'_`j' = 	kdam_d`i'_`j' if  ///
							`var' == 7 | `var' == 11 | `var' == 14 | `var' == 15 | ///
							`var' == 19 | `var' == 23 | `var' == 27 | `var' == 28 | ///
							`var' == 30 | `var' == 31 | `var' == 35 | `var' == 40 | ///
							`var' == 47 | `var' == 48 | `var' == 53 | `var' == 56 | ///
							`var' == 59 | `var' == 60 | `var' == 61 | `var' == 63 | ///
							`var' == 201 | `var' == 202 | `var' == 203 | `var' == 204 | ///
							`var' == 205 | `var' == 207 | `var' == 208 | `var' == 210 | ///
							`var' == 212 | `var' == 213 | `var' == 214 | `var' == 215 | ///
							`var' == 216 | `var' == 217 | `var' == 218 | `var' == 224 | ///
							`var' == 225 | `var' == 226 | `var' == 227 | `var' == 229 | ///
							`var' == 230 | `var' == 232 | `var' == 233 | `var' == 234 | ///
							`var' == 235 | `var' == 236 | `var' == 239 | `var' == 242 | ///
							`var' == 243 | `var' == 244 | `var' == 245 | `var' == 246 | ///
							`var' == 247 | `var' == 248 | `var' == 250 | `var' == 253 | ///
							`var' == 254 | `var' == 255 | `var' == 256 | `var' == 257 | ///
							`var' == 258 | `var' == 259 | `var' == 260 | `var' == 261 | ///
							`var' == 262 | `var' == 263 | `var' == 264 | `var' == 265 | ///
							`var' == 266 | `var' == 267 | `var' == 268 | ///
							`var' == 603 | `var' == 604 | `var' == 605 | `var' == 607 | ///
							`var' == 608 | `var' == 1002 | `var' == 1003 | `var' == 1004 | ///
							`var' == 1005 | `var' == 1006 | `var' == 1007 | `var' == 1008 | ///
							`var' == 1010 | `var' == 1020 | `var' == 1021 | `var' == 1026 | ///
							`var' == 1028 | `var' == 1031 | `var' == 1037 | `var' == 1039
	}
}
* Adds up the RESALE value of the individual tech capital per category
cap egen kst_tools_tech 		= rowtotal(techval_1_*), missing
cap egen kst_machinery_tech 	= rowtotal(techval_2_*), missing
cap egen kst_vehicles_tech 		= rowtotal(techval_4_*), missing
cap egen kst_otherassets_tech 	= rowtotal(techval_6_*), missing
cap egen kst_total_tech			= rowtotal(techval_*), missing




**** Adding a wave indicator - somewhat messy code but necessary
gen wave="`x'"
gen waven=2 if wave=="b"
replace waven=3 if wave=="c"
replace waven=4 if wave=="d"
replace waven=5 if wave=="e"
replace waven=6 if wave=="f"
replace waven=7 if wave=="g"
replace waven=8 if wave=="h"
replace waven=9 if wave=="i"
replace waven=10 if wave=="j"
replace waven=11 if wave=="k"
drop wave
ren waven wave

******* DK Code added

	cap gen `x'4_7_7 = . // Doesn't seem to exit for 2nd survey?
	cap gen `x'm3_3a = .  // Aren't asked in 11th round
	cap gen `x'm3_3b = .
	cap gen `x'm3_3c = .
	cap gen `x't3_3a = .
	cap gen `x't3_3b = .
	cap gen `x's3_3a = .
	cap gen `x's3_3b = .
	*keep sheno `x'1_1 `x'1_6 `x'3_1_* `x'2_1 `x'2_4 `x'2_10 `x'2_11 `x'4_2_7 `x'4_4_7 `x'4_7_7 ///
	*	`x'm3_2 `x'm3_3a `x'm3_3b `x'm3_3c  `x'm3_3d `x't3_2 `x't3_3a `x't3_3b `x't3_3c   ///
	*	`x's3_2 `x's3_3a `x's3_3b `x's3_3c 
	ren `x'1_1 exit_yn
	ren `x'1_6 exit_why
	ren `x'2_1 ownlabor_yn
	ren `x'2_4 ownlabor_hours
	ren `x'2_10 famlabor_hours
	ren `x'2_11 hiredlabor_hours
	*ren `x'4_2_7 repairs
	*ren `x'4_4_7 investment
	*ren `x'4_7_7 divestment

	*destring divestment, replace
	
	ren `x'm3_2 Mrevenue
	ren `x'm3_3a Mmtls_heldraw
	ren `x'm3_3b Mmtls_notsold
	ren `x'm3_3c Mmtls_sold
	ren `x'm3_3d Mmtls_wasted
	
	ren `x't3_2 Trevenue
	ren `x't3_3a Tmtls_sold
	ren `x't3_3b Tmtls_notsold
	ren `x't3_3c Tmtls_wasted
	
	ren `x's3_2 Srevenue
	ren `x's3_3a Smtls_sold
	ren `x's3_3b Smtls_notsold
	ren `x's3_3c Smtls_wasted

	renpfix `x'3_1 mtls
	destring mtls*, replace

******* DK Code end


*keep sheno wave knt* knm* krt* kdt* kst* inventories

keep sheno wave knt* knm* krt* kdt* kst* inventories exit_yn exit_why ownlabor_yn ownlabor_hours famlabor_hours  hiredlabor_hours /*repairs investment divestment*/ Mrevenue Mmtls_heldraw Mmtls_notsold Mmtls_sold Mmtls_wasted  Trevenue Tmtls_sold Tmtls_notsold Tmtls_wasted Srevenue Smtls_sold Smtls_notsold Smtls_wasted mtls*

save wave_extract_`x', replace
}
*

**** Append all waves
use wave_extract_a, clear
foreach x in b c d e f g h i j k{
append using wave_extract_`x'
}
*


**** Make all real and turn missing back to zero (as firms buy 0 new assets, so they should show up in analysis)
foreach x in kt_tools kt_machinery kt_furnite kt_vehicles kt_site kt_otherassets kt_total ///
			 km_tools km_machinery km_furnite km_vehicles km_site km_otherassets km_total ///
			 knt_tools knt_machinery knt_furnite knt_vehicles knt_site knt_otherassets knt_total ///
			 knm_tools knm_machinery knm_furnite knm_vehicles knm_site knm_otherassets knm_total ///
			 krt_tools krt_machinery krt_furnite krt_vehicles krt_site krt_otherassets krt_total ///
			 kdt_tools kdt_machinery kdt_furnite kdt_vehicles kdt_site kdt_otherassets kdt_total ///
			 kst_tools kst_machinery kst_furnite kst_vehicles kst_site kst_otherassets kst_total ///
			 knt_tools_tech knt_machinery_tech knt_vehicles_tech knt_otherassets_tech knt_total_tech ///
			 knm_tools_tech knm_machinery_tech knm_vehicles_tech knm_otherassets_tech knm_total_tech ///
			 krt_tools_tech krt_machinery_tech krt_vehicles_tech krt_otherassets_tech krt_total_tech ///
			 kdt_tools_tech kdt_machinery_tech kdt_vehicles_tech kdt_otherassets_tech kdt_total_tech ///
			 kst_tools_tech kst_machinery_tech kst_vehicles_tech kst_otherassets_tech kst_total_tech ///			 
			 inventories {
cap gen nom_`x'=`x'
cap lab var nom_`x' "nominal version of `x'"
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
cap replace `x'=0 if `x'==.  /*replace missing values with zero*******/
}
*

**** Save as new dataset for import into master
sort sheno wave
drop nom_*
save wave_extract_all, replace


*******************************************************************************
* MERGING DATA FROM INITIAL WAVES INTO THE MAIN DATASET
*******************************************************************************


* Merge the consolidated wave dataset into the Master
use "$datadir/SLMSMaster_web.dta", clear
capture drop _merge
sort	sheno wave

merge sheno wave using wave_extract_all



*******************************************************************************
**** PERPETUAL INVENTORY FOR TECH CAPITAL
*******************************************************************************


**** Replace missing values as zeros (as firms bought assets)
for var knm_* knt* krt* kdt* kst*: replace X = 0 if X == .
gen newtech_ratio_k = knt_total_tech / K2_nolandnew


*******************************************************************************
**** PERPETUAL INVENTORY FOR TECH CAPITAL
*******************************************************************************

*** Missing starting tech capital is zero if there is overall capital in category
foreach x in  kt_tools_tech kt_machinery_tech kt_vehicles_tech ///
			  kt_otherassets_tech kt_total_tech {

	recode `x' (. = 0) 		if kt_total != .

}

*** Now fill in the wave=1 variable for each firm, for all periods (not only wave 1)
foreach x in  kt_tools kt_machinery kt_furnite kt_vehicles kt_site kt_otherassets kt_total ///
			  kt_tools_tech kt_machinery_tech kt_vehicles_tech ///
			  kt_otherassets_tech kt_total_tech {

	bysort sheno: 	egen `x'_start = total(`x')
	replace 		`x' = `x'_start
	drop			`x'_start
}


sort sheno wave

foreach x in knt_tools knt_machinery knt_furnite knt_vehicles knt_site knt_otherassets knt_total ///
			 krt_tools krt_machinery krt_furnite krt_vehicles krt_site krt_otherassets krt_total ///
			 kdt_tools kdt_machinery kdt_furnite kdt_vehicles kdt_site kdt_otherassets kdt_total ///
			 kdt_tools kst_machinery kst_furnite kst_vehicles kst_site kst_otherassets kst_total ///
			 knt_tools_tech knt_machinery_tech knt_vehicles_tech knt_otherassets_tech knt_total_tech ///
			 krt_tools_tech krt_machinery_tech krt_vehicles_tech krt_otherassets_tech krt_total_tech ///
			 kdt_tools_tech kdt_machinery_tech kdt_vehicles_tech kdt_otherassets_tech kdt_total_tech ///
			 kst_tools_tech kst_machinery_tech kst_vehicles_tech kst_otherassets_tech kst_total_tech ///			 
			 { 
	cap bysort sheno: gen cum_`x' = sum(`x')
}

gen k_tools 		= kt_tools + cum_knt_tools + cum_krt_tools - cum_kdt_tools - cum_kst_tools
gen k_machinery 	= kt_machinery + cum_knt_machinery + cum_krt_machinery - cum_kdt_machinery - cum_kst_machinery
gen k_furnite 		= kt_furnite + cum_knt_furnite + cum_krt_furnite - cum_kdt_furnite - cum_kst_furnite
gen k_vehicles 		= kt_vehicles + cum_knt_vehicles + cum_krt_vehicles - cum_kdt_vehicles - cum_kst_vehicles
gen k_site 			= kt_site + cum_knt_site + cum_krt_site // No damages here
gen k_otherassets 	= kt_otherassets + cum_knt_otherassets + cum_krt_otherassets - cum_kdt_otherassets - cum_kst_otherassets
gen k_total_withland= kt_total + cum_knt_total + cum_krt_total - cum_kdt_total - cum_kst_total
gen fk_total 		= k_total_withland - k_site


gen k_tools_tech 		= kt_tools_tech + cum_knt_tools_tech + cum_krt_tools_tech - cum_kdt_tools_tech - cum_kst_tools_tech
gen k_machinery_tech 	= kt_machinery_tech + cum_knt_machinery_tech + cum_krt_machinery_tech - cum_kdt_machinery_tech - cum_kst_machinery_tech
gen k_vehicles_tech 	= kt_vehicles_tech + cum_knt_vehicles_tech + cum_krt_vehicles_tech - cum_kdt_vehicles_tech - cum_kst_vehicles_tech
gen k_otherassets_tech 	= kt_otherassets_tech + cum_knt_otherassets_tech + cum_krt_otherassets_tech - cum_kdt_otherassets_tech - cum_kst_otherassets_tech
gen fk_total_tech 		= kt_total_tech + cum_knt_total_tech + cum_krt_total_tech - cum_kdt_total_tech - cum_kst_total_tech



/*----replacing coding errors----*/
foreach x in k_tools k_machinery k_vehicles k_site k_otherassets fk_total ///
			 k_tools_tech k_machinery_tech k_vehicles_tech ///
			 k_otherassets_tech fk_total_tech {

	replace `x'=. if sheno==298  & wave==6
	replace `x'=. if sheno==298  & wave==7
	replace `x'=. if sheno==298  & wave==8
	replace `x'=. if sheno==298  & wave==9
	replace `x'=. if sheno==321  & wave==6
	replace `x'=. if sheno==321  & wave==7
	replace `x'=. if sheno==321  & wave==8
	replace `x'=. if sheno==321  & wave==9
	replace `x'=. if sheno==388  & wave==5
	replace `x'=. if sheno==388  & wave==6
	replace `x'=. if sheno==388  & wave==7
	replace `x'=. if sheno==388  & wave==8
	replace `x'=. if sheno==388  & wave==9
	
	replace `x' = . if `x' < 0
}

recode k_tools_tech (. = 0) 		if k_tools != .
recode k_machinery_tech (. = 0) 	if k_machinery != .
recode k_vehicles_tech (. = 0) 		if k_vehicles != .
recode k_otherassets_tech (. = 0) 	if k_otherassets != .
recode fk_total_tech (. = 0) 		if fk_total != .

save "$datadir/$SLfile", replace

*
*
*
*
*
*
*


*** New Code starts here

*use SLMSMaster_web.dta, clear
*keep sheno- a_levels ets ownhours ednyearsFIRM gender agebus detailedind ednyears prof realinv realprof rev rev_baseline treatever- trtmnt_type amount age femaleverified
drop K2_noland K_noland K_own
*merge sheno wave using `temp1', sort unique
gen toobig = _m == 1
label var toobig "Capital over 100K LKR"
drop _m

* Making a new dummy for firms affected by the tsunami:
ren ets tsunami_affected
replace tsunami_affected = tsunami_affected == 1  | tsunami_affected == .

* Clean the labor variables:
replace ownlabor_hours = 0 if ownlabor_yn == 2 | ownlabor_hours == . | ownlabor_hours >= 995
replace famlabor_hours = 0 if famlabor_hours == . | famlabor_hours >= 995
replace hiredlabor_hours = 0 if hiredlabor_hours == . | hiredlabor_hours >= 995

* Cleaning investment
* replace investment = 0 if investment == .
* replace divestment = 0 if divestment == .

* Adjust revenues for inflation
cap drop temp
gen temp = realprof/prof
egen inflation = mean(temp), by(wave)
gen realrev = rev*infl
drop temp
label var realrev "DMW's revenues adjusted for inflation"
label var inflation "Sri Lanka CPI deflator"

* Clean the materials variables: If any of them are non-empty, replace all empties with zeros:
egen temp = rowmax(mtls*)
foreach var of varlist mtls* {
	replace `var' = 0 if `var' == . & temp ~= .
}

* Identify which businesses exited in which periods:
sort sheno wave
gen gone = exit_yn == 2 | exit_yn == 4
replace gone = 1 if gone[_n-1] == 1 & sheno[_n-1] == sheno
label var gone "Whether original firm exited at or before this wave"
gen exited = (exit_yn[_n+1] == 2 | exit_yn[_n+1] == 4) & sheno[_n+1] == sheno
label var exited "Firm exited in next period"

* Label firms as being in either services, manufacturing, or retail sectors:
gen Mtemp = Mrevenue ~= .
bys sheno: egen Mfirm = max(Mtemp)
gen Stemp = Srevenue ~= .
bys sheno: egen Sfirm = max(Stemp)
gen Ttemp = Trevenue ~= .
bys sheno: egen Tfirm = max(Ttemp)
gen firmtype = 1 if Mfirm
replace firmtype = 2 if Sfirm
replace firmtype = 3 if Tfirm
label def firmtype 1 Manufacturing 2 Services 3 Trade
label val firmtype firmtype 
label var firmtype "Firm Sector"
drop Mtemp Stemp Ttemp Mfirm Sfirm Tfirm

* Generate dummies for periods after the firm received treatment:
gen inkind10k = trtmnt_type == "equipment" & trtmnt_offer == 10000 & treatmentround == 1 & wave > 1
replace inkind10k = 1 if trtmnt_type == "equipment" & trtmnt_offer == 10000 & treatmentround == 2 & wave > 3
gen inkind20k = trtmnt_type == "equipment" & trtmnt_offer == 20000 & treatmentround == 1 & wave > 1
replace inkind20k = 1 if trtmnt_type == "equipment" & trtmnt_offer == 20000 & treatmentround == 2 & wave > 3

gen cash10k = trtmnt_type == "cash" & trtmnt_offer == 10000 & treatmentround == 1 & wave > 1
replace cash10k = 1 if trtmnt_type == "cash" & trtmnt_offer == 10000 & treatmentround == 2 & wave > 3
gen cash20k = trtmnt_type == "cash" & trtmnt_offer == 20000 & treatmentround == 1 & wave > 1
replace cash20k = 1 if trtmnt_type == "cash" & trtmnt_offer == 20000 & treatmentround == 2 & wave > 3

gen treated = inkind10k | inkind20k | cash10k | cash20k
label var treated "Received any grand aside from the 2500 wave 5 amount"

* Generate numbers for treatments:
gen treat10k = trtmnt_offer == 10000 & treatmentround == 1 & wave > 1
replace treat10k = 1 if trtmnt_offer == 10000 & treatmentround == 2 & wave > 3
replace treat10k = treat10k*100
 
gen treat20k = trtmnt_offer == 20000 & treatmentround == 1 & wave > 1
replace treat20k = 1 if trtmnt_offer == 20000 & treatmentround == 2 & wave > 3
replace treat20k = treat20k*200

gen treat2_5k = trtmnt_offer == 0 & wave > 5
replace treat2_5k = treat2_5k*2.5

gen treat_amount = treat10k + treat20k + treat2_5k


* Identify firms wth at least 3 waves of profit data:
gen hasprofit1 = prof ~= . & wave <= 9
bys sheno: egen hasprofit2 = sum (hasprofit1)
gen profit3waves = hasprofit2 > 2
drop hasprofit1 hasprofit2
label var profit3waves "Reported 3 waves of profit data"

gen insample = wave <= 9 & tsunami_affected == 0 & toobig == 0 & profit3waves


* Identify 5% outliers in absolute and percentage profit changes:
*---Trimming points---*
tsset sheno wave
gen abschange=prof-L.prof 
gen perchange=100*(prof-L.prof)/L.prof

* cuts for top 0.5% (about one observation per wave, on average)
egen xtreme_high=pctile(perchange), p(99.5)
egen xtreme_low=pctile(perchange), p(.5)
egen xtreme_high_abs=pctile(abschange), p(99.5)
egen xtreme_low_abs=pctile(abschange), p(.5)

sum perchange, de

egen minchange=min(perchange), by(sheno)
egen maxchange=max(perchange), by(sheno)

* sample 2 trims the upper .5%, but both percentage and absolute changes
gen profit_outlier = (abschange > xtreme_high_abs | perchange > xtreme_high) & abschange ~= . & perchange~=. if insample
label var profit_outlier "Top 5% of absolute or relative profit changes"
drop insample minchange maxchange perchange xtreme_high xtreme_low xtreme_low_abs xtreme_high_abs abschange
*drop minchange maxchange perchange xtreme_high xtreme_low xtreme_low_abs xtreme_high_abs abschange
gen insample = wave <= 9 & tsunami_affected == 0 & toobig == 0 & profit3waves & ~profit_outlier



* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* %%%%%%%%%%  ADJUSTING PROFITS FOR HOURS WORKED %%%%%%%%%%%%%
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Allow 'wages' to vary with gender and education
gen gend=gender if wave==1
egen gender_1=mean(gender), by(sheno)

gen ednEN=ednyearsFIRM
gen femlow=gender_1==2 & ednEN<=7 if gender_1~=. & ednEN~=.
gen femmed=gender_1==2 & ednEN>=8 & ednEN<=10 if gender_1~=. & ednEN~=.
gen femhi=gender_1==2 & ednEN>=11 if gender_1~=. & ednEN~=.

gen malelow=gender_1==1 & ednEN<=7 if gender_1~=. & ednEN~=.
gen malemed=gender_1==1 & ednEN>=8 & ednEN<=10 if gender_1~=. & ednEN~=.
gen malehi=gender_1==1 & ednEN>=11 if gender_1~=. & ednEN~=.

* for var femlow femmed femhi malelow malemed malehi: sum hourlywage if X==1, det
gen mcat_hourly=7.9 if femlow==1
replace mcat_hourly=11.9 if femmed==1
replace mcat_hourly=10.6 if femhi==1
replace mcat_hourly=15.9 if malelow==1
replace mcat_hourly=17.3 if malemed==1
replace mcat_hourly=15.1 if malehi==1

* Use coefficeints from this regression:(coeffs typed in)
* for var femlow femmed femhi malelow malemed malehi:gen hours_X=(ownhours*4.2)*X
* reg prof age  femlow femmed femhi malelow malemed malehi K2_noland  hours_femlow- hours_malehi if wave==1
gen reg_hourlywage=0 if femlow==1 | femmed==1
replace reg_hourlywage=9.3 if femhi==1
replace reg_hourlywage=3.0 if malelow==1
replace reg_hourlywage=4.8 if malemed==1
replace reg_hourlywage=7.5 if malehi==1

gen adjprof3=realprof-(reg_hourlywage*4.2*ownhours)
label var adjprof3 "Profit adjusted for own wage (regression)"
gen adjprof4=realprof-(mcat_hourly*4.2*ownhours)
label var adjprof3 "Profit adjusted for own wage (median wage)"
drop  gend- reg_hourlywage temp
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


* Just for fun, correct the labels:
gen varlabels = ""
local i = 1
qui {
foreach var of varlist _all {
	local oldlabel : variable label `var'
	local newlabel : subinstr local oldlabel " in June" ""
	label variable `var' "`newlabel'"
	replace varlabels = "`newlabel'" in `i'
	local i = `i' + 1
}
}

sort sheno wave


***** MY own code to calculate materials and equipment

sort sheno wave
foreach i of num 1/12{
replace mtls_`i'=0 if mtls_`i'==.
}

gen e_mate = mtls_1
*rename mtls_1 e_mate
label variable e_mate "Expenditure - Purchase of materials"
rename mtls_2 e_util
rename mtls_3 e_loan
rename mtls_4 e_wage
rename mtls_5 e_rema
label variable e_rema "Amount spent last month on rent of machinery and equipment"
rename mtls_6 e_rela
rename mtls_7 e_tele
label variable e_tele "Amount spent last month on telephone and cellphone"
rename mtls_8 e_tax
label variable e_tax "Amount spent last month on taxes"
rename mtls_9 e_repr
label variable e_repr "Amount spent last month on repair"
rename mtls_10 e_trvl
rename mtls_11 e_othr
rename mtls_12 e_tot
label variable e_tot "Total expenses in the month"

* Generate different spending variables
gen e_nowage=e_mate+e_loan+e_rema+e_rela+e_tele+e_tax+e_othr+e_repr+e_trvl
la var e_nowage "spending on everything apart form utilities and wages"
gen e_m=e_nowage+e_util
la var e_m "spending on everything apart from wages"
gen e_matinv=e_mate+inv
la var e_matinv "e_matinv=e_mate+inv"

**** Make all real and turn missing back to zero (as firms buy 0 new assets, so they should show up in analysis)
foreach x in e_m{
cap gen nom_`x'=`x'
cap lab var nom_`x' "nominal version of `x'"
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
cap replace `x'=0 if `x'==.  /*replace missing values with zero*******/
}


*** New Code ends here
*
*
*
*
*
*
*


*******************************************************************************
**** Generate a few variables on tech intensity
*******************************************************************************


* "Tech Capital" Intensity
gen techratio_y = kt_total_tech / rev
gen techratio_k = kt_total_tech / K2_nolandnew

gen	techintensity_initial 	= kt_total_tech		/ kt_total


* "Tech intensity" of different capital categories and overall
gen techintensity_tools 	= k_tools_tech 			/ k_tools
gen techintensity_machinery = k_machinery_tech 		/ k_machinery
gen techintensity_vehicles  = k_vehicles_tech 		/ k_vehicles
gen techintensity_other		= k_otherassets_tech 	/ k_otherassets
gen	techintensity_total 	= fk_total_tech			/ fk_total


*******************************************************************************
**** Generate variables on starting to utilise tech capital
*******************************************************************************
sort sheno wave

gen k_own_tools_tech		= 1 if k_tools_tech > 0
gen k_own_machinery_tech	= 1 if k_machinery_tech > 0
gen k_own_vehicles_tech 	= 1 if k_vehicles_tech > 0
gen k_own_otherassets_tech 	= 1 if k_otherassets_tech > 0
gen k_own_total_tech 		= 1 if fk_total_tech > 0


recode k_own_* (miss = 0)

gen k_switch_tools_tech				= 1 if k_own_tools_tech == 1 & k_own_tools_tech[_n-1] == 0 & sheno == sheno[_n-1]
replace k_switch_tools_tech			= 1 if k_switch_tools_tech == . & k_switch_tools_tech[_n-1] == 1 & sheno == sheno[_n-1]

gen k_switch_machinery_tech			= 1 if k_own_machinery_tech == 1 & k_own_machinery_tech[_n-1] == 0 & sheno == sheno[_n-1]
replace k_switch_machinery_tech		= 1 if k_switch_machinery_tech == . & k_switch_machinery_tech[_n-1] == 1 & sheno == sheno[_n-1]

gen k_switch_vehicles_tech			= 1 if k_own_vehicles_tech == 1 & k_own_vehicles_tech[_n-1] == 0 & sheno == sheno[_n-1]
replace k_switch_vehicles_tech		= 1 if k_switch_vehicles_tech == . & k_switch_vehicles_tech[_n-1] == 1 & sheno == sheno[_n-1]

gen k_switch_otherassets_tech		= 1 if k_own_otherassets_tech == 1 & k_own_otherassets_tech[_n-1] == 0 & sheno == sheno[_n-1]
replace k_switch_otherassets_tech	= 1 if k_switch_otherassets_tech == . & k_switch_otherassets_tech[_n-1] == 1 & sheno == sheno[_n-1]

gen k_switch_total_tech		= 1 if k_own_total_tech == 1 & k_own_total_tech[_n-1] == 0 & sheno == sheno[_n-1]
replace k_switch_total_tech	= 1 if k_switch_total_tech == . & k_switch_total_tech[_n-1] == 1 & sheno == sheno[_n-1]

recode k_switch_* (miss = 0)

/*
gen treated_inkind = 1 if inkind10k | inkind20k
replace treated_inkind = 0 if treated_inkind == .

gen treated_cash= 1 if cash10k | cash20k
replace treated_cash = 0 if treated_cash == .
*/

gen treated_inkind = 1 if trtmnt_type == "equipment"
replace treated_inkind = 0 if treated_inkind == .

gen treated_cash = 1 if trtmnt_type == "cash"
replace treated_cash = 0 if treated_cash == .

**** Some more variables from DK Code

* Generate some helper variables:
gen totlabor = ownlabor_hours + famlabor_hours + hiredlabor_hours
gen realmtls_1 = inflation*e_mate
gen treatround_ind = treatmentround - 1
gen female = gender - 1

gen ln_realrev = log(realrev)
gen ln_realprof = log(realprof)
gen ln_adjprof3 = log(adjprof3)
gen ln_k = log(K2_nolandnew)
gen ln_totlabor = log(totlabor)
gen ln_realmtls_1 = log(realmtls_1)
gen ln_ownhours = log(ownlabor_hours)
gen ln_age = log(age)
gen ln_ednyears = log(ednyears)
gen ln_em = log(e_m)


gen K2_nolandnew00 = K2_nolandnew/100

drop k
ren waves waves_O

save "$datadir/$SLfile", replace

/*
*****************************************
**** DELETE: Reconcile with old dataset

**** Run the production function in Table 1 in our original dataset and keep the input variables
**** This also generates a variable to filter for the same sample as our main analysis (original_sample)
*use "C:\Users\lauri\OneDrive\Documents\Sri Lanka Ghana Firm Productivity\Sri Lanka Ghana Firm Productivity\PaperAnalysis\EJ_replication_package\Data\SLMS_master_withcapital_techcapital.dta", clear
use "C:\Users\lauri\Dropbox\Sri Lanka Ghana Firm Productivity\Publication\data_original_temp\SLMS_master.dta", clear
xtset sheno wave
do "${maindir}/SLpartialout.do"


* Estimate

eststo clear

	global 	LagY	= "2 3"
	global 	LagK 	= "3 4"
	global  LagLab 	= "1 2"
	global 	LagM 	= "2 3"
	

eststo Est1: xtabond2 lnY lnK lnL lnM llnY, ///
						gmm(llnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan
		

gen original_sample = 1 if e(sample)
keep sheno wave lnY lnK lnL lnM llnY ln_realrev ln_k ln_totlabor ln_em original_sample
ren ln* ln*_O
ren llnY llnY_O
save "${maindir}\Table1Sample.dta", replace
 
**** Now open the replicated main dataset again and merge in the variables from our original equation
use "$SLfile", clear

sort	sheno wave
capture drop _merge
merge 1:1 sheno wave using "${maindir}\Table1Sample.dta"

*keep if original_sample == 1
do "${maindir}/SLpartialout.do"

*** Try production functions with original and newly replicated data
*** First the new data

	global 	LagY	= "2 3"
	global 	LagK 	= "3 4"
	global  LagLab 	= "1 2"
	global 	LagM 	= "2 3"
	
xtabond2 lnY lnK lnL lnM llnY if original_sample == 1, ///
						gmm(llnY, laglimits($LagY)) ///
						gmm(lnK, laglimits($LagK)) ///
						gmm(lnL, laglimits($LagLab)) ///
						gmm(lnM, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan
						
e
*** And now orginal data
*capture ren llnY_0 llnY_O
xtabond2 lnY_O lnK_O lnL_O lnM_O llnY_O if original_sample == 1, ///
						gmm(llnY_O, laglimits($LagY)) ///
						gmm(lnK_O, laglimits($LagK)) ///
						gmm(lnL_O, laglimits($LagLab)) ///
						gmm(lnM_O, laglimits($LagM)) ///
						robust twostep artests(3) svmat nodiffsargan


*** Comparing the 
capture drop *_comp
foreach X in ln_k ln_em ln_totlabor ln_realrev lnY lnK lnL lnM llnY{
gen `X'_comp = 1 if `X' == `X'_O
}
browse ln_k* lnK* ln_em* lnM* ln_totlabor* lnL* ln_realrev* lnY* llnY* if original_sample
* Hi Simon! You see here that for some reason the variables that start with ln are different between the original and replicated data.
* These get generated by the SLpartialout.do, the same way in both datasets, and the starting variables are the same (the ln_ versions)!?


e
save "$SLfile", replace
*save "$datadir/${SLfile}", replace
