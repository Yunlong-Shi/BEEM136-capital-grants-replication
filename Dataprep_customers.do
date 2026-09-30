
************************************************************************************
* SETTING UP THE DO-FILE
************************************************************************************

cd "${datadir}"

**** ROUND 1 *************************************

use SLMSround1.dta, clear
gen 	wave = 1


ren	q2_29	customers
ren q1_14	location

ren q2_24_1 suppliers_1km
ren	q2_26_1 customers_1km


**** Define keeplist
keep  	sheno wave customers location suppliers_1km customers_1km
order	sheno wave customers location suppliers_1km customers_1km

save customers_data_1, replace



**** ROUND 2 *************************************

use SLMSround2.dta, clear

ren	b2_17	customers
ren	b2_18	newproduct
ren	b2_20	newproduct_sales
ren b1_13	closure
ren b1_2	location

ren	b1_1	business_changes
ren	b2_19	new_product_name
ren bn2		new_business
ren bm3_3d	spoiled_m
ren bs3_3c	spoiled_s
ren bt3_3c	spoiled_t
ren bm3_3a	turnedover_m
ren bs3_3a	turnedover_s
ren bt3_3a	turnedover_t 
 

gen	wave = 2

**** Define keeplist
keep  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
order  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
		
save customers_data_2, replace



**** ROUND 3 *************************************

use SLMSround3_labeled.dta, clear

ren	c2_17	customers
ren	c2_18	newproduct
ren	c2_20	newproduct_sales
ren c1_13	closure
ren c1_2	location


ren	c1_1	business_changes
ren	c2_19	new_product_name
ren cn2		new_business
ren cm3_3d	spoiled_m
ren cs3_3c	spoiled_s
ren ct3_3c	spoiled_t
ren cm3_3a	turnedover_m
ren cs3_3a	turnedover_s
ren ct3_3a	turnedover_t 
 
ren c5_2_1 	problem_health
ren c5_2_2	problem_weather
ren c5_2_3	problem_demand
ren c5_2_4	problem_poverty
ren c5_2_5	problem_outages
ren c5_2_6	problem_materials
ren c5_2_7	problem_spoilage
ren c5_2_8	problem_prices
 

gen	wave = 3

**** Define keeplist
keep  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t problem_*
order  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t problem_* 
		
save customers_data_3, replace






**** ROUND 4 *************************************

use SLMSround4.dta, clear

ren	d2_17	customers
ren	d2_18	newproduct
ren	d2_20	newproduct_sales
ren d1_13	closure
ren d1_2	location

ren	d1_1	business_changes
ren	d2_19	new_product_name
ren dn2		new_business
ren dm3_3d	spoiled_m
ren ds3_3c	spoiled_s
ren dt3_3c	spoiled_t
ren dm3_3a	turnedover_m
ren ds3_3a	turnedover_s
ren dt3_3a	turnedover_t 
 

gen	wave = 4

**** Define keeplist
keep  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
order  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
		
save customers_data_4, replace



**** ROUND 5 *************************************

use SLMSround5_labeled.dta, clear

ren	e2_17	customers
ren	e2_18	newproduct
ren	e2_20	newproduct_sales
ren e1_13	closure
ren e1_2	location

ren	e1_1	business_changes
ren	e2_19	new_product_name
ren en2		new_business
ren em3_3d	spoiled_m
ren es3_3c	spoiled_s
ren et3_3c	spoiled_t
ren em3_3a	turnedover_m
ren es3_3a	turnedover_s
ren et3_3a	turnedover_t 
 
ren	e2_21_1 customers_1km 

gen	wave = 5

**** Define keeplist
keep  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t customers_1km
order  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t customers_1km
		
save customers_data_5, replace


**** ROUND 6 *************************************

use SLMSround6.dta, clear

ren	f2_17	customers
ren	f2_18	newproduct
ren	f2_20	newproduct_sales
ren f1_13	closure
ren f1_2	location

ren	f1_1	business_changes
ren	f2_19	new_product_name
ren fn2		new_business
ren fm3_3d	spoiled_m
ren fs3_3c	spoiled_s
ren ft3_3c	spoiled_t
ren fm3_3a	turnedover_m
ren fs3_3a	turnedover_s
ren ft3_3a	turnedover_t 
 
gen	wave = 6

**** Define keeplist
keep  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
order  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
		
save customers_data_6, replace



**** ROUND 7 *************************************

use SLMSround7.dta, clear

ren	g2_17	customers
ren	g2_18	newproduct
ren	g2_20	newproduct_sales
ren g1_13	closure
ren g1_2	location

ren	g1_1	business_changes
ren	g2_19	new_product_name
ren gn2		new_business
ren gm3_3d	spoiled_m
ren gs3_3c	spoiled_s
ren gt3_3c	spoiled_t
ren gm3_3a	turnedover_m
ren gs3_3a	turnedover_s
ren gt3_3a	turnedover_t 
 

gen	wave = 7

**** Define keeplist
keep  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
order  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
		
save customers_data_7, replace



**** ROUND 8 *************************************

use SLMSround8.dta, clear

ren	h2_17	customers
ren	h2_18	newproduct
ren	h2_20	newproduct_sales
ren h1_13	closure
ren h1_2	location

ren	h1_1	business_changes
ren	h2_19	new_product_name
ren hn2		new_business
ren hm3_3d	spoiled_m
ren hs3_3c	spoiled_s
ren ht3_3c	spoiled_t
ren hm3_3a	turnedover_m
ren hs3_3a	turnedover_s
ren ht3_3a	turnedover_t 
 

gen	wave = 8

**** Define keeplist
keep  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
order  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
		
save customers_data_8, replace



**** ROUND 9 *************************************

use SLMSround9.dta, clear

ren	i2_17	customers
ren	i2_18	newproduct
ren	i2_20	newproduct_sales
ren i1_13	closure
ren i1_2	location


ren	i1_1	business_changes
ren	i2_19	new_product_name
ren in2		new_business
ren im3_3d	spoiled_m
ren is3_3c	spoiled_s
ren it3_3c	spoiled_t
ren im3_3a	turnedover_m
ren is3_3a	turnedover_s
ren it3_3a	turnedover_t 
 

gen	wave = 9

**** Define keeplist
keep  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
order  	sheno wave customers newproduct newproduct_sales closure location ///
		business_changes new_product_name new_business spoiled_m spoiled_s spoiled_t ///
		turnedover_s turnedover_m turnedover_t
		
save customers_data_9, replace





***************************************************
**** Append all waves

use 	customers_data_1, clear
append 	using customers_data_2
append 	using customers_data_3
append 	using customers_data_4
append 	using customers_data_5
append 	using customers_data_6
append 	using customers_data_7
append 	using customers_data_8
append 	using customers_data_9

cap	drop _merge

save	SLMS_customers_data, replace

