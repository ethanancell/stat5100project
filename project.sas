proc import datafile='/folders/myfolders/EPG194/stat5100project/kc_house_data.csv' replace
	out = house
	dbms = CSV
	;
run;

/* Box-cox transformation. Ends up suggesting the log transform.*/
proc transreg data=house;
	model boxcox(price / lambda=-1 to 1 by 0.1) = identity(bedrooms bathrooms sqft_living sqft_lot waterfront yr_built grade);
	title1 'Box-cox transformation of predicting price';
run;

/* Fixed model violations with log transform */
data house; set house;
	logPrice = log(price);
run;
proc reg data=house plots(maxpoints=22000);
	model logPrice = bedrooms bathrooms sqft_living sqft_lot waterfront yr_built grade;
run;

/* Look at multicollinearity and influental points */
proc reg data=house plots(maxpoints=220000 label)=(CooksD RStudentByLeverage DFFITS DFBETAS);
	model logPrice = bedrooms bathrooms sqft_living sqft_lot waterfront yr_built grade / vif collin;
run;

/* Ignore those influential observations */
proc reg data=house plots(maxpoints=220000 label)=(CooksD RStudentByLeverage DFFITS DFBETAS);
	where _n_ NE 1720 and _n_ NE 12778 and _n_ NE 15871;
	model logPrice = bedrooms bathrooms sqft_living sqft_lot waterfront yr_built grade / vif collin;
run;