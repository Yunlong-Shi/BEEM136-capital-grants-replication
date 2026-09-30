

************************************************************************************
* SETTING UP THE DO-FILE
************************************************************************************


cd "${datadir}"

**** ROUND 12 ***************************************
**** Capital stock categories still exists; but no more perpetuual inventory rather
**** direct elicitation

use SLMSround12.dta, clear
*ren q1_36* kadd*


*** Get inventories
ren 	q7_2	inventories
recode	inventories (. = 0) if q7_1 == 2


*** Get fixed assets categories		
ren		q5_1a_1 k_tools
ren		q5_1a_2 k_machinery
ren		q5_1a_3 k_furnite
ren		q5_1a_4 k_vehicles
ren		q5_1a_5 k_site
ren		q5_1a_6 k_otherassets
ren		q5_1a_7 k_total_withland


*** Get labour and materials inputs
ren		q5_4a	ownlabor_hours
egen	famlabor_hours = rowtotal(q5_6d_*)
gen		totlabor = ownlabor_hours + famlabor_hours

gen		em = q7_4l  -  q7_4d


*** Get revenue
ren		q7_6 rev
replace rev = . if em == .


*** Get profits
ren		q7_9 prof	// Note: these are only for trimming, we want to keep them nominal


** Real values: deflate
foreach x of varlist k_tools k_machinery k_furnite k_vehicles k_site k_otherassets ///
					 k_total_withland inventories em rev {
	
	cap replace `x'=`x'*187.4/326.6 /*w12 inferred from Science rep data*/
}

ren		rev realrev

gen		wave = 12

keep sheno wave realrev prof em totlabor inventories ///
				k_tools k_machinery k_furnite k_vehicles k_site k_otherassets ///
				k_total_withland

compress				
	
save ExtraWave12, replace




**** ROUND 13 ***************************************
**** Again perpetual inventory against previous wave (round 12)

use SLMSround13.dta, clear
*ren q1_36* kadd*


*** Get inventories
ren 	q7_2	inventories
recode	inventories (. = 0) if q7_1 == 2

*******************************
*** Get fixed assets categories		

* Rename questions in a common way
ren q4_4* kadd_* // questions in the surveys are the same, but each wave has a different letter prefix
destring kadd_*, replace
ren q4_2* krep_* // commons repairs prefix
destring krep_*, replace
ren q4_7* kdam_* // commons repairs prefix
destring kdam_*, replace

* Replace values as missing if item is not own
forvalue i = 1/6 {
	forvalue j = 1/10 {
		cap replace kadd_f`i'_`j' = . 	if kadd_d`i'_`j' != 1
	}
}

* Individual variable fixes
replace  kadd_f_4_1 = subinstr(kadd_f_4_1,",","",.)
destring kadd_f_4_1, replace

* Adds up the NEW value of the individual capital categories
egen knt_tools 		= rowtotal(kadd_f_1*), missing
egen knt_machinery 	= rowtotal(kadd_f_2*), missing
egen knt_furnite 	= rowtotal(kadd_f_3*), missing
egen knt_vehicles 	= rowtotal(kadd_f_4*), missing
capture noisily egen knt_site 		= rowtotal(kadd_f_5*), missing
egen knt_otherassets = rowtotal(kadd_f_6*), missing
egen knt_total		= rowtotal(kadd_f_*), missing

* Adds up the REPAIR value of the individual capital categories
cap egen krt_tools 		= rowtotal(krep_e_1*), missing
cap egen krt_machinery 	= rowtotal(krep_e_2*), missing
cap egen krt_furnite 	= rowtotal(krep_e_3*), missing
cap egen krt_vehicles 	= rowtotal(krep_e_4*), missing
capture noisily egen krt_site 		= rowtotal(krep_e_5*), missing
cap egen krt_otherassets = rowtotal(krep_e_6*), missing
cap egen krt_total		= rowtotal(krep_e_*), missing

* Adds up the DAMAGE value of the individual capital categories
cap egen kdt_tools 		= rowtotal(kdam_f_1*), missing
cap egen kdt_machinery 	= rowtotal(kdam_f_2*), missing
cap egen kdt_furnite 	= rowtotal(kdam_f_3*), missing
cap egen kdt_vehicles 	= rowtotal(kdam_f_4*), missing
capture noisily egen kdt_site 		= rowtotal(kdam_f_5*), missing
cap egen kdt_otherassets = rowtotal(kdam_f_6*), missing
cap egen kdt_total		= rowtotal(kdam_f_*), missing

* Adds up the SALE/RETURN value of the individual capital categories
cap egen kst_tools 		= rowtotal(kdam_d_1*), missing
cap egen kst_machinery 	= rowtotal(kdam_d_2*), missing
cap egen kst_furnite 	= rowtotal(kdam_d_3*), missing
cap egen kst_vehicles 	= rowtotal(kdam_d_4*), missing
capture noisily egen kst_site 		= rowtotal(kdam_d_5*), missing
cap egen kst_otherassets = rowtotal(kdam_d_6*), missing
cap egen kst_total		= rowtotal(kdam_d_*), missing


*** Get labour and materials inputs
ren		q5_4a	ownlabor_hours
egen	famlabor_hours = rowtotal(q5_6d_*)
gen		totlabor = ownlabor_hours + famlabor_hours

gen		em = q7_4l  -  q7_4d


*** Get revenue
ren		q7_6 rev
replace rev = . if em == .


*** Get profits
ren		q7_9 prof	// Note: these are only for trimming, we want to keep them nominal


** Real values: deflate
foreach x of varlist inventories em rev ///
					knt_tools knt_machinery knt_furnite knt_vehicles knt_site knt_otherassets knt_total ///
					krt_tools krt_machinery krt_furnite krt_vehicles krt_site krt_otherassets krt_total ///
					kdt_tools kdt_machinery kdt_furnite kdt_vehicles kdt_site kdt_otherassets kdt_total ///
					kst_tools kst_machinery kst_furnite kst_vehicles kst_site kst_otherassets kst_total /// 
					{ ///
	
	cap replace `x'=`x'*187.4/342.5 /*w12 inferred from Science rep data*/
	cap replace `x'=0 if `x'==.  /*replace missing values with zero*******/
	
}

ren		rev realrev

gen		wave = 13

keep sheno wave realrev prof inventories em totlabor knt_* krt_* kdt_* kst_* 

compress				
	
save ExtraWave13, replace




**** PUT ROUNDS 12 AND 13 TOGETHER *****************************
**** Again perpetual inventory against previous wave (round 12)

use 	ExtraWave12, clear
append	using ExtraWave13

xtset	sheno wave


*** PERPETUAL INVENTORY for wave 13
replace k_tools 		= L.k_tools + knt_tools + krt_tools - kdt_tools - kst_tools if wave == 13
replace k_machinery 	= L.k_machinery + knt_machinery + krt_machinery - kdt_machinery - kst_machinery if wave == 13
replace k_furnite 		= L.k_furnite + knt_furnite + krt_furnite - kdt_furnite - kst_furnite if wave == 13
replace k_vehicles 		= L.k_vehicles + knt_vehicles + krt_vehicles - kdt_vehicles - kst_vehicles if wave == 13
replace k_site 			= L.k_site + knt_site + krt_site - kdt_site - kst_site if wave == 13
replace k_otherassets 	= L.k_otherassets + knt_otherassets + krt_otherassets - kdt_otherassets - kst_otherassets if wave == 13
replace k_total_withland = L.k_total_withland + knt_total + krt_total - kdt_total - kst_total if wave == 13

gen		fk_total = k_total_withland - k_site

foreach x in k_tools k_machinery k_furnite k_vehicles k_site k_otherassets fk_total {
	replace `x' = . if `x' < 0
}

** Log all that needs logging..
gen		ln_totlabor = ln(totlabor)
gen		ln_k		= ln(fk_total)
gen		ln_em		= ln(em)
gen		ln_realrev  = ln(realrev)



keep 	sheno wave ln_realrev ln_em ln_k ln_totlabor inventories em prof fk_total ///
		k_tools k_machinery k_furnite k_vehicles k_site k_otherassets 			

compress				
	
save 	"${datadir}/SLMS_Waves1213", replace
