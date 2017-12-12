//ON
cd `"${mypath}ECLIPSE/ndns data dlw vs self reported"'
qui log using test1, replace 

/***
### Data

This project uses data from the National Diet and Nutrition Survey (NDNS) 
accessed from the UK Data Service. Data from NDNS years 1 to 6 were used 
(collected between 2008 and 2014). The NDNS data contains information on 
energy intake from self-reported dietary behaviour collected using food diaries 
Information on Individual demographics and anthropometric measures are also 
recorded; and, for a sub group of participants, biometric data  from Doubly 
Labelled Water (DLW) tests sampled from participants during survey years 1 and 3. 
***/

//OFF

cd 	`"${mypath}ECLIPSE/UKDA-6533-tab/tab"'

* import individual level data - includes bio & anthro measures
* append data from yrs5-6 to yrs1-4


import delim "ndns_rp_yr5-6a_indiv.tab"

    save "ndns_rp_yr5-6a_indiv.dta", replace
        clear


import 	delim 	"ndns_rp_yr1-4a_indiv_uk.tab"   
    
    save "ndns_rp_yr1-4a_indiv_uk.dta", replace
    
    append using "ndns_rp_yr5-6a_indiv.dta", force
		
        keep	seriali surveyyr tee teerep_kj_day_1   bmr_kj_day_1 ///
                pal htval wtval bmival agegad1 bmivg5 ///
                height weight ///
		        age    agegr1    agegr2  agegad2 sex ///
                ethgru ethgr5 ethgr2  educfin   qualch qual qual7 ///
				benefits benefit2 ///
                benefit3 benefit4 beneft1y4 beneft2y4 ///
                beneft3y4 beneft4y4 beneft5y4   ///
                hhinc  mcclem  eqvinc 		
       
        save 	"ndns_data_yr1-6_person_data.dta", replace
   
    clear

* import individual level dietary data - includes avg daily kcal intake
* append data from yrs5-6 to yrs 1-4

import 	delim 	"ndns_rp_yr5-6a_personleveldietarydata.tab"
    
    save "ndns_rp_yr5-6a_personleveldietarydata_uk.dta", replace
        clear
	
import 	delim 	"ndns_rp_yr1-4a_personleveldietarydata_uk.tab"
    
    save "ndns_rp_yr1-4a_personleveldietarydata_uk.dta", replace

    append using "ndns_rp_yr5-6a_personleveldietarydata_uk.dta", force

* merge dietary data with person level data 
* save in project working directory

merge 	1:1 seriali using "ndns_data_yr1-6_person_data.dta", force
			
    cd `"${mypath}ECLIPSE/ndns data dlw vs self reported"'
      save 	"ndns_data_yr1-6_dietaryandperson_data - raw.dta", replace
        *clear

qui log close

/***

### Method

This analysis presented here describes utilisation of DLW data. The measure of 
‘error’ in the self-reported survey data is derived by comparing the 
bio-metrically measured estimate of expenditure to the self reported estimate of 
calorie  intake for each individual. The method utilises results from the 
analysis described above to re-calibrate calorie intake estimates from 
self-reported data for individuals for whom biometric measures are not available. 

***/

//OFF

count

txt "there are `r(N)' subjects in the data"


tab     age, miss				
tab 	agegr1, miss nolab
tab 	agegr2 agegr1  /* agegr2: 1 = adults >18 */
//ON
txt "Records for individuals aged 4 years and over were extracted " ///
     "from the NDNS data."
//OFF
cou if  agegr1==1

txt "there are `r(N)' subjects under the age of four"

drop if agegr1==1

count

txt "there are `r(N)' subjects remaining after excluding under fours"

tab     sex, miss

tab     height, miss
tab     weight, miss

count if weight==-1 | height==-1

txt "`r(N)' subjects dropped because of missing height and weight"

drop if weight==-1 | height==-1

count

//ON

txt "After excluding records with missing values for height and weight, " ///
    "the total number of records was n=`r(N)'" 
//OFF

count if dlw_grp==1
scalar  dlw1=`r(N)'
count if dlw_grp==0
scalar dlw0=`r(N)'

//ON 
 
txt "Data was divided into a training dataset comprised of" ///
    "the DLW sub group used to develop the models (n= " dlw1 ")" ///
    " and a test dataset of the remaining individuals (n= " dlw0 ")"

//OFF

save 	"ndns_data_yr1-6_dietaryandperson_data - raw.dta", replace


*qui log close












			
