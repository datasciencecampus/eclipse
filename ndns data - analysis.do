cd `"${mypath}ECLIPSE/ndns data dlw vs self reported"'

/**/ use 	"ndns_data_yr1-6_dietaryandperson_data.dta", clear

qui log using "ndns data - analysis", replace

//OFF

/***
---
							
Estimating bias in self-reported energy intake
==============================================

Percent mis-reported used as outcome to model 
individual error in calorie intake estimates
where positive values represent under-reporting 
and negative values represent over-reporting

***/

hist kcal_diff_pcnt, by(agegr2)

hist kcal_diff_pcnt if agegr2==1, by(sex, note(""))

       graph save Graph "histogram pcnt error - adults", replace
        graph export "histogram pcnt error - adults.png", replace
//ON
        img, title("histogram pcnt error- adults") width(270)

//OFF

/**/ qnorm kcal_diff_pcnt if agegr2==1
        graph save Graph "qq_plot_percent_misreported", replace
        graph export "qq_plot_percent_misreported.png", replace

//ON
            img, title("quntile-quintile plot of % reporting error") width(300)

sktest kcal_diff_pcnt if agegr2==1

        scalar skw=`r(P_skew)'
        scalar krt=`r(P_kurt)'

txt "The dependant variable appears mostly normally distributed, with some" /// 
    "deviation from normality in the low end and negative range of error values," /// 
    "which represent a small number of over-reporters in the data set." /// 
    "There is also no evidence to reject the hypothesis that the data is" ///
    "normally distributed based on skewness  (P=" skw ")  or Kurtosis (P=" krt ")."

//OFF
sktest kcal_diff_pcnt if agegr2==2
qnorm kcal_diff_pcnt if agegr2==2

/***
q-q plot
sufficiently normal, skewed to the right - most underreport, few over report
use linear regression model to estimate individual reporting error


Univariate Analysis
===================

each independent variable considered for the model 
regressed on the outcome percent mis-reported
***/

* potential independent vars for regression

local pred_con "age height weight energykcal"

levelsof agegr2, local(age_levs)

//ON
foreach a of local age_levs {
    
    txt "descriptives for `a'" 

    count if agegr2 ==`a'

    bysort sex: count if agegr2 == `a'

    foreach i in `pred_con' {
            
            su `i', detail
            
            table sex if agegr2== `a', ///
			c(mean `i' sd `i' min `i' max `i' p50 `i') row

            twoway 	(scatter kcal_diff_pcnt `i', sort) ///
            if agegr2 == `a', by(sex)

            *img, title("`i' against percentage error")

            reg kcal_diff_pcnt `i' if agegr2 == `a'

            }	
    
    tab sex agegr2, col

    xi: reg kcal_diff_pcnt i.sex if agegr2==`a'    

    graph matrix  `pred_con' if agegr2==`a', half
    
}		

/***
no statistically significant differnce between genders
age significant - negative correlation in adults, positive correlation for kids
height significant for children
weight significant for both age groups - small rsquared
as expected, the lower the EI reported, the higher the % under-reported
***/

/***
Multi-variate Analysis
======================
***/

//OFF

local pred_con "energykcal lg_energykcal pond_ind energy_ind lg_energy_ind age sex weight height bmi2"

graph matrix `pred_con', half


//OFF

* STEP WISE REGRESSION
bysort sex: ///
stepwise, pr(0.05): reg     kcal_diff_pcnt ///
                            energykcal lg_energykcal ///
                            energy_ind lg_energy_ind ///
                            age weight height bmi2 pond_ind ///
                            if dlw_grp==1

* coefficient vector saved in ereturn

mat list e(b)


*##################################################################
* including/excluding children?
xi: stepwise, pr(0.05): reg     kcal_diff_pcnt energykcal ///
                            age weight i.sex bmi2 bmr_kcal ///
                            if dlw_grp==1 & agegr2==1
predict ad_error, xb

xi: stepwise, pr(0.05): reg     kcal_diff_pcnt ///
                            age weight i.sex bmi2 bmr_kcal ///
                            if dlw_grp==1 & agegr2==2
predict ch_error, xb
*clearly differences between children and adults

* proceed with adults only....

*********************************************************************
//ON


* final model *****

xi: reg     kcal_diff_pcnt ///
                            energykcal ///
                            age weight i.sex ///
                            if dlw_grp==1 & agegr2==1

* use predict to generate variable from model output
estimates store pred_error_ads
predict ad_sr_error, xb

distplot line ad_sr_error kcal_diff_pcnt if dlw_grp==1 & agegr2==1

* reasonable fit
* tends to underfit extreme negative and small percetnage errors, 
* and over predicts at extreme high under-reporting  error range 


* check residuals from model fit

rvfplot

* no apparent trend with residuals and fitted values

* apply predict to test data

replace new_EI=energykcal/((100-ad_sr_error)/100)
format new_EI %9.0f

order energykcal kcal_diff_pcnt, last

distplot line energykcal new_EI if agegr2==1


parplot energykcal new_EI ///
        if (surveyyr==1 | surveyyr==3) ///
        & agegr2==1 & sex==1 ///
        & dlw_grp==0 ///
        , tr(raw) 


* calc plausbility of self-reported measure

tabstat ad_sr_error if agegr2==1, s(n mean sd min max) save by(sex)
tabstat new_EI if agegr2==1, s(n mean sd min max) save by(sex)
tabstat new_EI if agegr2==1 & surveyyr==1 | surveyyr==3 , s(n mean sd min max) save by(sex)

*summary recalibrated EI by survey year, males
/**/ tabstat new_EI if agegr2==1 & sex==1, s(n mean sd min max) save by(surveyyear)
*summary recalibrated EI by survey year, females
/**/ tabstat new_EI if agegr2==1 & sex==2, s(n mean sd min max) save by(surveyyear)



qui log c
* markdoc `"${mypath}ECLIPSE/ndns data dlw vs self reported/ndns data.smcl"', export(pdf) linesize(80)							

********************************************************************************
							
********************************************************************************
							
		

