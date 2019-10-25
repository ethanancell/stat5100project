proc import datafile='/folders/myfolders/EPG194/project/crimeanalysis/crime_by_district_rt.csv' replace
	out = work.crimes
	dbms = CSV
	;
run;

proc reg data=work.crimes;
	model Murder = Assault_on_women Prevention_of_atrocities__POA__A Protection_of_Civil_Rights__PCR_  Kidnapping_and_Abduction Dacoity Robbery Arson Hurt;
run;data import;