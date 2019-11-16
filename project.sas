proc import datafile='/folders/myfolders/EPG194/stat5100project/kc_house_data.csv' replace
	out = house
	dbms = CSV
	;
run;

data house;
	logPrice = log(price);
run;

proc reg data=house plots(maxpoints=22000);
	model price = bedrooms bathrooms sqft_living sqft_lot waterfront yr_built grade;
run;

proc reg data=house plots(maxpoints=220000 label)=(CooksD RStudentByLeverage DFFITS DFBETAS);
	model price = bedrooms bathrooms sqft_living sqft_lot waterfront yr_built grade / vif collin;
run;