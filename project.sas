proc import datafile='/folders/myfolders/EPG194/stat5100project/kc_house_data.csv' replace
	out = house
	dbms = CSV
	;
run;

/** Brown-Forsythe and Correlation Test of Normality (shortcut) **/
filename macrourl url "http://www.stat.usu.edu/jrstevens/stat5100/resid_num_diag.sas";
     %include macrourl;

/* What does the data look like before the transformation? */
proc reg data=house plots(maxpoints=22000);
	model price = bedrooms bathrooms sqft_living sqft_lot waterfront yr_built grade;
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
proc reg data=house plots(maxpoints=220000 label)=(CooksD RStudentByLeverage DFFITS DFBETAS);
	model logPrice = bedrooms bathrooms sqft_living logSqftLot waterfront yr_built grade;
	output out = house_out r=resid p=pred;
run;

/* Numeric diagnostics to support probably doing WLS */
%resid_num_diag(dataset=house_out, datavar=resid, 
   label='residual', predvar=pred, predlabel='predicted');
  
  
/* Multicollinearity*/
proc reg data=house;
	model logPrice = bedrooms bathrooms sqft_living sqft_lot waterfront yr_built grade / collin;
run;

/* Influential points */
proc reg data=house plots(maxpoints=220000 label)=(CooksD RStudentByLeverage DFFITS DFBETAS);
	model logPrice = bedrooms bathrooms sqft_living sqft_lot waterfront yr_built grade;
run;

/* Remedial measures of influential points */
data house; set house;
	logSqftLot = log(sqft_lot);
	order = _n_;
run;

/* Refit model */
proc reg data=house plots(maxpoints=220000 label)=(CooksD RStudentByLeverage DFFITS DFBETAS);
	where order NE 15871 and order NE 12778;
	model logPrice = bedrooms bathrooms sqft_living logSqftLot waterfront yr_built grade;
run;
  
  
/* Look at interaction terms */
data house; set house;
	waterfrontLogSqftLot = logSqftLot * waterfront;
	yrBuiltSqftLiving = yr_built * sqft_living;
run;

/* Test for significance */
proc reg data=house;
	where order NE 15871 and order NE 12778;
	model logPrice = bedrooms bathrooms sqft_living logSqftLot waterfront yr_built grade yrBuiltSqftLiving waterfrontLogSqftLot;
run;



/* Alternative model (Weighted least squares) */
/* Set up */
proc reg data=house noprint;
	where order NE 15871 and order NE 12778;
	model logPrice = bedrooms bathrooms sqft_living logSqftLot waterfront yr_built grade yrBuiltSqftLiving waterfrontLogSqftLot;
	output out=house_out r=resid;
run;
data house_out; set house_out;
	abs_resid = abs(resid);
run;
proc reg data=house_out noprint;
	model abs_resid = bedrooms bathrooms sqft_living logSqftLot waterfront yr_built grade yrBuiltSqftLiving waterfrontLogSqftLot;
	output out=house_out2 p=estSD;
run;
data house_out2; set house_out2;
	useWeight = 1/estSD**2;
run;

/* Actual weighted model */
proc reg data=house_out2;
	where order NE 15871 and order NE 12778;
	model logPrice = bedrooms bathrooms sqft_living logSqftLot waterfront yr_built grade yrBuiltSqftLiving waterfrontLogSqftLot;
	weight useWeight;
run;