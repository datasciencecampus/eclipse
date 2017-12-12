//OFF
cd  `"${mypath}ECLIPSE/ndns data dlw vs self reported"'
qui log using test1, append 

use "ndns_data_yr1-6_dietaryandperson_data - raw.dta"

/***
---

### Formatting
***/
			


lab     var     seriali         "person id"
lab     var     surveyyr        "year"

lab     define  lbl_year ///
                1 "2008" ///
                2 "2009" ///
                3 "2011" ///
                4 "2012" ///
                5 "2013" ///
                6 "2014"

lab     val     surveyyr ///
                lbl_year

lab		var 	agegr2 			"age group"			
		
lab		define 	lbl_agegr2 ///
				1 "adults" ///
				2 "children", replace
				
lab		val 	agegr2 ///
				lbl_agegr2			
		
lab 	define 	lbl_agegr1 	///
				1 "1.5-3 years" ///
				2 "4-10 years" ///
				3 "11-18 years" ///
				4 "19-64 years" ///
				5 "65+ years"

lab 	val 	agegr1 ///
				lbl_agegr1	
		
lab 	define 	lbl_agegad2	///
				-1 "<16" ///
				1 "16-18" ///
				2 "19-34" ///
				3 "35-49" ///
				4 "50-64" ///
				5 "65+ years", replace 
		
lab 	val 	agegad2 ///
				lbl_agegad2

gen     age_grp = int(age/5)
replace age_grp = 17 if age_grp>17

la      def     lbl_age_grp ///
                0 "0-4" ///
                1 "5-9" ///
                2 "10-14" ///
                3 "15-19" ///
                4 "20-24" ///
                5 "25-29" ///
                6 "30-34" ///
                7 "35-39" /// 
                8 "40-44" ///
                9 "45-49" ///
                10 "50-54" ///
                11 "55-59" ///
                12 "60-64" ///
                13 "65-69" ///
                14 "70-74" ///
                15 "75-79" /// 
                16 "80-84" ///
                17 "85+" 

la val age_grp lbl_age_grp

lab 	define	lbl_sex ///
				1 "males" ///
				2 "females"

lab		val 	sex ///
				lbl_sex

lab		var		htval			"height (validated)"
lab		var		wtval			"weight (validated)"

lab     var     height          "height (cm)"
lab     var     weight          "weight (kg)"

gen     height_m = height/100
replace height_m = . if height==-1
la var  height_m "height (mtrs)"


la var	bmival "BMI (validated)"

** create BMI from height and weight

lab 	var		bmivg5			"BMI groups (adults only)"
        recode 	bmivg5 	-1=99

la de   lbl_bmivg5 ///
		1 "<18.5" ///
		2 "18.5-25" ///
		3 "25-30" ///
		4 "30-40" ///
		5 "40+" ///
		99 "null", replace
		
la val   bmivg5 ///
        lbl_bmivg5

gen     bmi2 =(weight)/(height_m^2)

la var  bmi2 "bmi (recalc)"


/***
---

Derive energy intake & expenditure variables
--------------------------------------------
***/

//ON
/***

The analysis used estimates of energy intake from self reported data (EISR) 
along with the energy expenditure (EE) measures from the DLW tests to estimate 
the error in self-reported data. Using the assumption of homeostasis for 
individuals (i.e. that body weight is stable), 
Energy Intake = Energy Expenditure. 
In this context, EE is considered a proxy for the true EI.

***/




la var  energykcal  "reported intake kcal" /*inc alcohol*/
//OFF
format  energykcal %9.0f

gen     lg_energykcal = log(energykcal)
la var  lg_energykcal "log(reported intake)"
//ON				
* caution error in data doc var description
* Food energy (kJ) diet only inconsistent with var name
* Should be Total energy (kcal) 

gen     morethanear = 0
replace morethanear = 1 if energykcal>=ekcalear
la var  morethanear "reported kcals greater than EAR (0=no)"

la var  tee     "measured expend kj"

cou if  tee!=-4 ///
        & tee!=-1 ///
        & tee!=.


/***
---

Converting energy expenditure from kj to kcal
---------------------------------------------

* 1 kcal = 0.239 kj or kcal approx kj/4.1868
use 29/7 instead
***/

	
gen		tee_kcal = tee/(29/7)
        replace tee_kcal =. if dlw_grp==0

la var	tee_kcal "measured expend kcal"

//OFF

/***

### Check conversion

compare self-reported kcals with self-reported kjs /(29/7)	
***/

gen		energykcal_c = (energykj/(29/7)) - energykcal
summ	energykcal_c
drop    energykcal_c

/***

some small differences between energy intake in kcals as in the data and 
kcals converted from energy intake in kj - probably conversion rate

---	
***/


//ON
gen     dlw_grp = 0
replace dlw_grp = 1 if  tee!=-4 & tee!=-1 & tee!=.     

la var  dlw_grp "included in DLW sample sub-group"



/***

---

Calculating error in self-reported energy intake
------------------------------------------------

***/

* error of actual energy consumption
gen		kcal_diff = tee_kcal-energykcal
la var	kcal_diff "kcals not reported"

gen		kcal_diff_pcnt = (kcal_diff/tee_kcal)*100
la var	kcal_diff_pcnt "percent misreported"


/***

The error in self-reported estimates was derived for subjects in the 
training dataset as the percentage difference between self reported 
energy intake and energy expenditure, 
as a percentage of energy expenditure. 
Percent error = (EE - EISR / EE) 


---	
***/

******


/***

---

Calculate Basal Metabolic Rate (BMR)
------------------------------------

Basal Metabolic Rate (BMR) is a measure of the estimated number of calories 
required to sustain life. BMR was derived for all individuals in both datasets 
using age and sex specific formulas based on height and weight described as the 
Schofield equations (In line with the methods referenced in the NDNS report).

gives estimate in kj's - need to convert to kcals

Schofields equations
BMR (based on weight, height, age and sex) 

***/


gen     BMR=.

replace BMR= (0.033*weight) + (1.917*height_m) + 0.074 if sex==2
replace BMR= (0.038*weight) + (4.068*height_m) - 3.491 if sex==1

replace BMR= (0.034*weight) + (0.006*height_m) + 3.530 if sex==2 & age<60
replace BMR= (0.048*weight) - (0.011*height_m) + 3.670 if sex==1 & age<60

replace BMR= (0.057*weight) + (1.184*height_m) + 0.411 if sex==2 & age<30
replace BMR= (0.063*weight) - (0.042*height_m) + 2.953 if sex==1 & age<30

replace BMR= (0.035*weight) + (1.948*height_m) + 0.837 if sex==2 & age<18
replace BMR= (0.068*weight) + (0.574*height_m) + 2.157 if sex==1 & age<18

replace BMR= (0.071*weight) + (0.677*height_m) + 1.553 if sex==2 & age<10
replace BMR= (0.082*weight) + (0.545*height_m) + 1.736 if sex==1 & age<10

replace BMR= (0.001*weight) + (6.349*height_m) - 2.584 if sex==2 & age<3
replace BMR= (0.068*weight) + (4.281*height_m) - 1.730 if sex==1 & age<3

replace BMR=. if weight==-1 | height==-1
la var  BMR "BMR - Schofield"

* outputs are too small - by factor of 1000, apply correction
gen     bmr_crc=1000*BMR
format  bmr_crc %9.0f
la var  bmr_crc "corrected BMR"

* convert BMR unit to kcals
gen		bmr_kcal = bmr_crc/(29/7)
la var  bmr_kcal "basal metabolic rate kcal"


/***

---

Calculate Pyhsical Activity Level (PAL)
------------------------------------

Physical Activity Level (PAL) is a ratio of energy expenditure to BMR 
(PAL = EE/BMR) and, as EE cannot biologically be less than BMR, 
PAL has a lower bound of 1. Under the assumption of homeostasis, 
EE = EI and so EE/BMR = EI/BMR = PAL, also has a lower bound of 1. 

* PAL removes virtually all differences between individuals
allows comparison of self reported EI with different BMR
also allows comparison between IndEI from ndns data and PAL from other sources

* low values of PAL represent bed bound and high values represent very active

***/


la var  pal	"physical activity level"

gen		energy_ind  =energykj/bmr_crc
la var	energy_ind  "energy intake index"

gen     lg_energy_ind = log(energy_ind)
la var  lg_energy_ind "log(energy index)"		

/***

### Biological plausibility

create flag to indicate if self-reported intake is plausible

***/


/***
The Failure Rate was defined as the percentage of individuals with 
energy intake values outside the biologically plausible range 
(i.e where EI/BMR < 1).
***/

		
gen		energy_ind_pl =1
replace energy_ind_pl =0 if energy_ind<1
replace energy_ind_pl =0 if energy_ind>2.8 & sex==2
replace energy_ind_pl =0 if energy_ind>3.5 & sex==1

la var  energy_ind_pl "plausible self-report"	

la de   lbl_energy_plc ///
        0 "not plausible" ///
        1 "plausible" 

la val  energy_ind_pl ///
        lbl_energy_ind_pl

* considered Goldberg principle for range of plausibility
	


/***
### Ponderal Index

measure of leaness of a person, measured as ratio between mass and height
= mass/(height^3)

(metric units: mass (body weight) kg; height m)

***/


gen     pond_ind = 100*(weight^(1/3))/height


* new variables created after predicting model

gen new_EI=.

gen     new_energy_ind=.
la var      new_energy_ind "energy index"

gen		new_energy_ind_pl			=.
lab		var		new_energy_ind_pl	"plausible self-report"	

lab     val     new_energy_ind_pl ///
                lbl_energy_ind_pl


//OFF	
		
order 	seriali ///
        surveyyr ///    
        age ///
        agegad1 agegad2 agegr2 ///
        sex ///
        bmival bmivg5 ///        
        htval wtval height height_m weight ///
        dlw_grp ///
        energykj ///
		energykcal ///
		tee ///
		tee_kcal ///
		kcal_diff ///
		kcal_diff_pcnt ///
		bmr_kcal ///
		pal ///
		energy_ind ///
		energy_ind_pl ///
		, first

sort age_grp sex 

				
save 	"ndns_data_yr1-6_dietaryandperson_data.dta", replace

export delim using "ndns_data_yr1-6_dietaryandperson_data.csv", replace



/***

variables created
-----------------

var name  			description     
--------  			-----------
dlw_grp             subject inc in DLW sample (0=no)
energykcal			energy intake (EIclaimed)
tee_kcal			energy expended kcals (EE)
kcal_diff           reporting error
kcal_diff_pcnt      percent reporting error
height_m            height (meters)
bmr_kcal			resting metabolic rate (RMR)
pal					physical activity level (PAL) 
energy_ind          energy index (analagous to PAL)
energy_ind_pl       energy index plausible (no=0)

***/

* qui log close  


