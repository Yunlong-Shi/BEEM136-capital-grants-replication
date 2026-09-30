
decode detailedind, gen(detailedindustry)

gen		slindustry = .
replace	slindustry = 1 if 	detailedindustry == "Food sales" | ///
							detailedindustry == "Betel sales" | ///
							detailedindustry == "Food production" | ///
							detailedindustry == "Food sales" | ///
							detailedindustry == "Providing Food & equipment for occasion" | ///
							detailedindustry == "Food Production" | ///
							detailedindustry == "Food Sales" | ///
							detailedindustry == "Tea shop" 
							
replace	slindustry = 2 if 	(firmtype == 3 & slindustry == .) | ///
							detailedindustry == "Clothing Outlets" | ///
							detailedindustry == "Incense Stick Sales" | ///
							detailedindustry == "Acquarium" | ///
							detailedindustry == "Clothing Outlets" | ///
							detailedindustry == "Selling Timber wood"

replace	slindustry = 3 if 	detailedindustry == "Work that a beautician is engaged in" | ///
							detailedindustry == "Education institute" | ///
							detailedindustry == "Salon" 

replace	slindustry = 4 if 	detailedindustry == "Bamboo trade" 
							
replace	slindustry = 5 if 	detailedindustry == "Sewing Clothes" 

replace	slindustry = 6 if 	(firmtype == 2 & slindustry == .) | ///
							detailedindustry == "Reparing gold & silver goods"


replace	slindustry = 7 if 	(firmtype == 1 & slindustry == .) | ///
							detailedindustry == "Aluminum related Production"
							
