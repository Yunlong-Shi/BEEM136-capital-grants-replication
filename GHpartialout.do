
* Industry dumies 

gen		ghindustry = .
replace ghindustry = 1 if sector_food == 1
replace ghindustry = 2 if sector_const == 1
replace ghindustry = 3 if sector_beauty == 1
replace ghindustry = 4 if sector_manuf == 1
replace ghindustry = 5 if sector_sewing == 1
replace ghindustry = 6 if sector_repair == 1
replace ghindustry = 7 if sector_trade == 1 | sector_other == 1

capture tab ghindustry, gen(ghindustryD)


keep	sheno wave lK lL lM lY atreat insample ghindustry* sector_trade

egen  numid = group(sheno)

xtset numid wave



** Rename raw variables before partialling out

ren	lK	lnK_raw
ren	lL	lnL_raw
ren lM	lnM_raw
ren lY  lnY_raw

ren	atreat treated


** Start by winsorizing...

foreach var of varlist lnK_raw lnL_raw lnM_raw {
		winsor 	`var', gen(`var'_t) p(0.01)
		replace `var' = `var'_t
	}
drop *_t


keep 	if insample

capture tab wave, gen(waveD)
gen		llnY_raw = L.lnY_raw					

qui reg		lnK_raw waveD2-waveD6 ghindustryD2-ghindustryD7 treated
qui predict lnK, residual
qui replace lnK = lnK + _b[_cons]

qui reg		lnL_raw waveD2-waveD6 ghindustryD2-ghindustryD7 treated 
qui predict lnL, residual
qui replace lnL = lnL + _b[_cons]

qui reg		lnM_raw waveD2-waveD6 ghindustryD2-ghindustryD7 treated 
qui predict lnM, residual  
qui replace lnM = lnM + _b[_cons]

qui reg		lnY_raw waveD2-waveD6 ghindustryD2-ghindustryD7 treated 
qui predict lnY, residual
qui replace lnY = lnY + _b[_cons]
		
qui reg		llnY_raw waveD2-waveD6 ghindustryD2-ghindustryD7 treated 
qui predict llnY, residual	
qui replace llnY = llnY + _b[_cons]
