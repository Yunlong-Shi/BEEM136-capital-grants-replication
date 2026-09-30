
************************************************************************************
* SETTING UP THE DO-FILE
************************************************************************************

cd "${datadir}"

// We will use the re-named data sets saved earlier

**** ROUND 1 ***************************************
**** Only has a data on the existing capital stock, not new acquisitions, so is different from subsequent waves
**** Estimating the share of various categories of capital goods

use SLMSround1.dta, clear
gen 	wave = 1

keep sheno wave q1_36b* q1_36f*


** Rename the product code variable

forvalue j = 1/10 {
	
cap ren q1_36b1`j'	productcode_tools`j'
cap ren q1_36b2`j'	productcode_machinery`j'
cap ren q1_36b3`j'	productcode_furnite`j'
cap ren q1_36b4`j'	productcode_vehicles`j'
cap ren q1_36b6`j'	productcode_otherassets`j'
	
cap ren q1_36f1`j'	productvalue_tools`j'
cap ren q1_36f2`j'	productvalue_machinery`j'
cap ren q1_36f3`j'	productvalue_furnite`j'
cap ren q1_36f4`j'	productvalue_vehicles`j'
cap ren q1_36f6`j'	productvalue_otherassets`j'	
}

keep	sheno wave productcode_* productvalue_*

reshape long 	productcode_tools ///
				productcode_machinery ///
				productcode_furnite ///
				productcode_vehicles ///
				productcode_otherassets ///
				productvalue_tools ///
				productvalue_machinery ///
				productvalue_furnite ///
				productvalue_vehicles ///
				productvalue_otherassets, ///
				i(sheno wave) j(prodnum)
				
drop prodnum

save wave_products_a, replace

local wave = 1

**** ROUNDS 2-9 *************************************
foreach x in b c d e f g h i j k {

local wave = `wave' + 1
use SLMSround`wave'.dta, clear

* Rename questions in a common way
ren `x'4_4* kadd_* // questions in the surveys are the same, but each wave has a different letter prefix
destring kadd_*, replace
ren `x'4_2* krep_* // commons repairs prefix
destring krep_*, replace
ren `x'4_7* kdam_* // commons repairs prefix
destring kdam_*, replace


* Define keep

gen wave = `wave'

keep sheno wave kadd_b* kadd_f*


** Rename the product code variable

forvalue j = 1/10 {
	
cap ren kadd_b1_`j'	productcode_tools`j'
cap ren kadd_b2_`j'	productcode_machinery`j'
cap ren kadd_b3_`j'	productcode_furnite`j'
cap ren kadd_b4_`j'	productcode_vehicles`j'
cap ren kadd_b6_`j'	productcode_otherassets`j'
	
cap ren kadd_f1_`j'	productvalue_tools`j'
cap ren kadd_f2_`j'	productvalue_machinery`j'
cap ren kadd_f3_`j'	productvalue_furnite`j'
cap ren kadd_f4_`j'	productvalue_vehicles`j'
cap ren kadd_f6_`j'	productvalue_otherassets`j'
		
}

keep	sheno wave productcode_* productvalue_*

reshape long 	productcode_tools ///
				productcode_machinery ///
				productcode_furnite ///
				productcode_vehicles ///
				productcode_otherassets ///
				productvalue_tools ///
				productvalue_machinery ///
				productvalue_furnite ///
				productvalue_vehicles ///
				productvalue_otherassets, ///
				i(sheno wave) j(prodnum)
				
drop prodnum

save wave_products_`x', replace
}
*

**** Append all waves
use wave_products_a, clear
foreach x in b c d e f g h i j k{
append using wave_products_`x'
}

**** Get in treatment information

merge m:1 sheno wave using "$SLfile", keepusing(treated treatever insample prof)

* Trimming
keep if insample == 1


********************************************************************************
*** 					List most common items
********************************************************************************

label define lother ///
1001	"Clock" ///
1002	"Refrigerator" ///
1003	"Oven" ///
1004	"Gas Cooker" /// 
1005	"Rice Cooker" ///
1006	"Showcase" ///
1007	"Blender" ///
1008	"Fan" ///
1009	"Wedding reception equipment" ///
1010	"Roll Cage" ///
1012	"Almera" ///
1013	"Iron tools" ///
1014	"Petrol max" ///
1015	"Bell" ///
1016	"Plastic Chairs" ///
1017	"Rig foam boxes" ///
1018	"Gas cylinder" ///
1019	"Pipe rings" ///
1020	"Steamer iron board" ///
1021	"Beater" ///
1022	"Tent material" ///
1023	"Rotti stone" ///
1024	"Boxer wheel" ///
1025	"Plastic racks" ///
1026	"Lathe work" ///
1027	"Fiber related other assets" ///
1028	"Phones" ///
1029	"Nameboards" ///
1030	"Workers" ///
1031	"Lightmeter" ///
1032	"Eylashes" ///
1033	"Barrels" ///
1034	"Cement tank" ///
1035	"Flower pot comoflauge nets" ///
1036	"Oxygen Cylinders" ///
1037	"Furnance" ///
1038	"Roofing sheets" ///
1039	"Radio" ///
1040	"Fishing hooks"

label values productcode_otherassets lother					

* Tools
tab productcode_tools if wave == 1, sort
tab productcode_tools if treated == 0 & wave > 1, sort
tab productcode_tools if treated == 1 & wave > 1, sort

* Machinery
tab productcode_machinery if wave == 1, sort
tab productcode_machinery if treated == 0 & wave > 1, sort
tab productcode_machinery if treated == 1 & wave > 1, sort

* Furniture
tab productcode_furnite if wave == 1, sort
tab productcode_furnite if treated == 0 & wave > 1, sort
tab productcode_furnite if treated == 1 & wave > 1, sort

* Vehicles
tab productcode_vehicles if wave == 1, sort
tab productcode_vehicles if treated == 0 & wave > 1, sort
tab productcode_vehicles if treated == 1 & wave > 1, sort

tab productcode_vehicles if treatever == 1 & wave == 1, sort


* Other assets
tab productcode_otherassets if wave == 1, sort
tab productcode_otherassets if treated == 0 & wave > 1, sort
tab productcode_otherassets if treated == 1 & wave > 1, sort

tab productcode_otherassets if treatever == 1 & wave == 1, sort

********************************************************************************
*** 					List unit values
********************************************************************************


**************
** Clean values

recode productvalue_* (0 = .)

foreach var of varlist productvalue_* {
		cap winsor 	`var', gen(`var'_t) p(0.025)
		cap replace `var' = `var'_t
	}
drop *_t

sum productvalue_*, d

tab	productvalue_vehicles
tab productvalue_otherassets
	// 55% of items in either category have unit value of 4000 or higher


/*egen totalvalues_other 		= total(productvalue_otherassets)
egen totalvalues_fridge_case 	= total(productvalue_otherassets) ///
	if productcode_otherassets == 1002 | productcode_otherassets == 1007
sum	totalvalues*, d
*/
	
bysort sheno: egen totalvalues_other 		= total(productvalue_otherassets)
replace totalvalues_other = . if productvalue_otherassets == .
bysort sheno: egen totalvalues_fridge_case 	= total(productvalue_otherassets) ///
	if productcode_otherassets == 1002 | productcode_otherassets == 1006
replace totalvalues_fridge_case = 0 if totalvalues_fridge_case == . & totalvalues_other != .
	
**************
** Clean values

ren productcode_tools 		productcode1
ren	productcode_machinery	productcode2
ren productcode_furnite		productcode3
ren	productcode_vehicles	productcode4
ren	productcode_otherassets productcode5

ren productvalue_tools 			productvalue1
ren	productvalue_machinery		productvalue2
ren productvalue_furnite		productvalue3
ren	productvalue_vehicles		productvalue4
ren	productvalue_otherassets 	productvalue5


**************
** Reshape long

bysort sheno wave treatever: gen prodnum = _n

reshape long	productcode productvalue, i(sheno wave treatever prodnum) j(product)

keep	if productcode != . | productvalue != .

compress

save	"Unitvalues.dta", replace


**************
** Data set with largest item per firm and wave

preserve

	bysort sheno wave: egen largestitem = max(productvalue)
	gen	   largestcode = productcode if (productvalue == largestitem)
	keep   if largestcode != .
	keep   sheno wave largestitem largestcode
	
	duplicates drop sheno wave, force
	
	compress
	
	save	"Largestvalues.dta", replace
	
restore

exit
