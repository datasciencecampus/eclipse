
cd `"/${mypath}ECLIPSE/UKDA-6533-tab/tab"'
use "ndns_data_yr1-6_dietaryandperson_data.dta", clear

cd `"${mypath}ECLIPSE/Outputs"'

//ON

qui log using "ndns data - analysis", replace

/***
							
Estimating reporting error in self-reported energy intake 
=========================================================

Percent mis-reported used as outcome to model 
individual error in calorie intake estimates
where positive values represent under-reporting 
and negative values represent over-reporting

***/

/**/ ///
tabstat kcal_diff_pcnt  if agegr2==1 & dlw_grp==1, ///
                        s(n mean sd min max) save by(sex)
/**/ ///
        distplot scatter kcal_diff_pcnt if dlw_grp==1 & agegr2==1, by(sex)
/**/ ///
hist    kcal_diff_pcnt  if dlw_grp==1 & agegr2==1, ///
                        percent by(sex, note("")) ///
                        ytitle("percent of individuals", ///
                        orientation(horizontal) placement(center)) ///
                        ylabel(0 (2) 30) xlabel(-20 (10) 80) width(10) ///
                        xtitle( ///
"percent 'error' in self-reported intake (-ve numbers = over reported intake)")

        img, title("histogram pcnt error- adults") width(270)

//OFF
        graph save Graph "graph - hist - percent sr error - by sex", replace
        graph export "graph - hist - percent sr error - by sex.png", replace

qnorm   kcal_diff_pcnt if agegr2==1
        
        graph save Graph "graph - qqplot - percent sr error", replace
        graph export "graph - qqplot - percent sr error.png", replace

sktest  kcal_diff_pcnt if agegr2==1

        scalar skw=`r(P_skew)'
        scalar krt=`r(P_kurt)'

//ON

txt     "The dependant variable appears mostly normally distributed, with some" /// 
        "deviation from normality in the low end and negative range of error " ///
        "values, which represent a small number of over-reporters in the data" ///
        "set. There is also no evidence to reject the hypothesis that the " ///
        "data is normally distributed based on skewness  (P=" skw ")  " ///
        "or Kurtosis (P=" krt ")."

        img, title("quntile-quintile plot of % reporting error") width(270)

//OFF

// sktest kcal_diff_pcnt if agegr2==2
// qnorm kcal_diff_pcnt if agegr2==2


//ON

/***

---  

Univariate Analysis
===================

each independent variable considered for the model 
regressed on the outcome percent mis-reported
use linear regression model to estimate individual reporting error

***/

//OFF
* potential independent vars for regression

local pred_con "age height weight energykcal bmi2 pond_ind energy_ind"

//ON
levelsof agegr2, local(age_levs)

foreach a of local age_levs {
    
        txt "descriptives for age group `a'" 

        /**/ count if agegr2 ==`a' & dlw_grp==1

        /**/ tab sex if agegr2 == `a' & dlw_grp==1

        foreach i in `pred_con' {
                
                txt "descriptives for `i'"

                /**/ su `i' if agegr2== `a' & dlw_grp==1, detail
                
                /**/ table sex if agegr2== `a' & dlw_grp==1, ///
                c(mean `i' sd `i' min `i' max `i' p50 `i') row

                /**/ twoway 	(scatter kcal_diff_pcnt `i' if sex==1, sort) ///
                                (scatter kcal_diff_pcnt `i' if sex==2, sort ///
                legend(on label(1 "males") label(2 "females") ///
                ring(1) bplace(5) row(1))) ///
                if agegr2 == `a' & dlw_grp==1

                img, title("`i' vs percent error") width(270)

                /**/ reg kcal_diff_pcnt `i' if agegr2 == `a' & dlw_grp==1

                }	
        
        /**/ tab sex agegr2, col

        /**/ xi: reg kcal_diff_pcnt i.sex if agegr2==`a' & dlw_grp==1   

        /**/ graph matrix  `pred_con' if agegr2==`a' & dlw_grp==1, half
               /**/ qui: graph save "graph_matrix_variables.png", replace
        
        *img, title("correlation matrix") width(270)
}		


/***

- no statistically significant differnce between genders
- age significant - negative correlation in adults
- height not significant
- weight significant - small rsquared (0.07)
- as expected, the lower the EI reported, the higher the % under-reported (0.37)
- bmi sig small r
- energy index r2 = 0.66

***/

/***

---  

Multi-variate Analysis
======================

***/

//OFF

local pred_con "kcal_diff_pcnt energykcal lg_energykcal pond_ind energy_ind lg_energy_ind age sex weight height bmi2"

graph matrix `pred_con' if agegr2==1 & dlw_grp==1, half
 
//ON
       img, title("correlation matrix") width(270)


* graph matrix `pred_con' if agegr2==2, half

*_______________________________________________________________________________
* STEP WISE REGRESSION
//OFF
xi: stepwise, pr(0.05): reg     kcal_diff_pcnt ///
                                energykcal lg_energykcal ///
                                energy_ind lg_energy_ind ///
                                age i.sex weight height bmi2 pond_ind ///
                                if dlw_grp==1
                                
                                mat list e(b)

* including/excluding children?

xi: stepwise, pr(0.05): reg     kcal_diff_pcnt ///
                                energykcal lg_energykcal ///
                                energy_ind lg_energy_ind ///
                                age i.sex weight height bmi2 pond_ind ///
                                if dlw_grp==1 & agegr2==1
 
                                predict ad_error, xb

xi: stepwise, pr(0.05): reg     kcal_diff_pcnt ///
                                energykcal lg_energykcal ///
                                energy_ind lg_energy_ind ///
                                age i.sex weight height bmi2 pond_ind ///
                                if dlw_grp==1 & agegr2==2
                            
                                predict ch_error, xb

*clear differences between children and adults

* proceed with adults only....
*###############################################################################

*full model
xi: stepwise, pr(0.05): reg     kcal_diff_pcnt ///
                                energykcal energy_ind pond_ind ///
                                age i.sex weight bmi2 bmr_kcal height ///
                                if dlw_grp==1 & agegr2==1

* choose bmi over height
xi: stepwise, pr(0.05): reg     kcal_diff_pcnt ///
                                energykcal energy_ind pond_ind ///
                                age i.sex weight bmi2 bmr_kcal ///
                                if dlw_grp==1 & agegr2==1
* choose weight over bmr
xi: stepwise, pr(0.05): reg     kcal_diff_pcnt ///
                                energykcal energy_ind pond_ind ///
                                age i.sex weight bmi2  ///
                                if dlw_grp==1 & agegr2==1

* choose energykcal over energy_ind
xi: stepwise, pr(0.05): reg     kcal_diff_pcnt ///
                                energykcal pond_ind ///
                                age i.sex weight bmi2  ///
                                if dlw_grp==1 & agegr2==1
//ON

* used fixed entry method for vars selcted from stepwise
/**/ ///
                xi:     reg     kcal_diff_pcnt ///
                                energykcal ///
                                age weight i.sex ///
                                if dlw_grp==1 & agegr2==1


//ON
* final model ******************************************************************

/**/ ///
                xi: reg         kcal_diff_pcnt ///
                                energykcal ///
                                age weight i.sex ///
                                if dlw_grp==1 & agegr2==1
                                 
                                estimates store pred_error_ads

                                matrix b=e(b)
                                local xlist: colnames b
                                di "`xlist'"


//OFF

* check sensitivity to outliers, run model with different parameters
* ratio of bmr to reported kcals within / without certain bounds 
* percentage mis-reported - with and without extreme values 
* very low pal scores
                gen bmr_sr_ratio=bmr_kcal/energykcal


                xi: reg         kcal_diff_pcnt  ///
                                energykcal ///
                                age weight i.sex ///
                                if dlw_grp==1 & agegr2==1 ///
                                & bmr_sr_ratio<2 & bmr_sr_ratio>0.5

* model coeffs remain very similar even when removing outlier values
//ON
*_______________________________________________________________________________
* use predict to generate variable from model output

qui: estimates restore pred_error_ads

            * create dummy for factor var
            * gen _Isex_2=sex==2

predict ad_sr_error, xb

* compare predicted vs measured intake for dlw sample group

distplot scatter ad_sr_error kcal_diff_pcnt if dlw_grp==1 & agegr2==1

img, title("distribution of self-reported error and adjusted error") width(270)

/***
							
reasonable fit
tends to underfit extreme negative and small percetnage errors, 
and over predicts at extreme high under-reporting  error range 

***/

//OFF
        /*
        *calc adjusted sr ei using avergae values from bootstrapping
        gen ad_sr_error_bs=.
        replace ad_sr_error_bs = 
        _sim_1_01 + age_01*age + energykcal_01*energykcal 
        + weight_01*weight + _Isex_2_01*_Isex_2 

        distplot line ad_sr_error ad_sr_error_bs if dlw_grp==1 & agegr2==1
        * consistent with distrubtion from model
        */

//ON

* check residuals from model fit

/**/ rvfplot

img, title("residuals from predicted error") width(270)


* no apparent trend with residuals and fitted values

* apply predict to test data ***************************************************

//OFF

replace     new_EI =energykcal/((100-ad_sr_error)/100)
format      new_EI %9.0f

order       energykcal kcal_diff_pcnt, last

distplot    scatter energykcal new_EI if agegr2==1 & dlw_grp==0

parplot     energykcal new_EI ///
            if agegr2==1 & sex==1 ///
            & dlw_grp==0 ///
            , tr(raw) variablelabels

scatter     bmr_kcal new_EI if agegr2==1 & dlw_grp==0, ///
                            yscale(range(0 6000)) ///
                            ylabel(0 (1000) 6000, format(%9.0fc))  ///
                            xscale(range(0 6000)) ///
                            xlabel(0 (1000) 6000, format(%9.0fc)) ///
                            ytitle("basal metabolic rate (kcals)") ///
                            xtitle("adjusted energy intake (kcals)") sort ///
                            lcolor(gs10) fcolor(bluishgray8)

* note 3 outliers......

* on exploration, these three all had very low SR energy intake ests
* less than half than bmr

* compare with and without outliers

gen         outliers=0
replace     outliers=1 if new_EI>=6000

distplot    scatter energykcal new_EI if agegr2==1 & dlw_grp==0 & outliers==0, ///
            xlabel(0 (1000) 6000) xscale(range(0 6000)) sort

//ON

img, title("self-reported and adjusted EI") width(270)

/**/ ///
parplot     energykcal new_EI ///
            if agegr2==1 & sex==1 ///
            & dlw_grp==0 ///
            & outliers==0 ///
            , ylabel(0 (500) 6000) tr(raw) variablelabels

img, title("self-reported and adjusted EI") width(270)

/**/ ///
scatter    bmr_kcal new_EI if agegr2==1 & dlw_grp==0 & outliers==0, ///
                            yscale(range(0 6000)) ///
                            ylabel(0 (1000) 6000, format(%9.0fc))  ///
                            xscale(range(0 6000)) ///
                            xlabel(0 (1000) 6000, format(%9.0fc)) ///
                            ytitle("basal metabolic rate (kcals)") ///
                            xtitle("adjusted energy intake (kcals)") sort ///
                            lcolor(gs10) fcolor(bluishgray8)

img, title("self-reported and adjusted EI") width(270)


* after adjusting, energy intake estimates are more closely correlated with bmr
* would be interesting to test sensitivity using different bmr calcs

* calc summary measures for predicted errors and adjusted intake 
* (with and without outliers)

/**/ /// 
tabstat ad_sr_error if agegr2==1, s(n mean sd min max) save by(sex)
/**/ ///
tabstat ad_sr_error if agegr2==1 & outliers==0 ///
                    , s(n mean sd min max) save by(sex)
/**/ ///
tabstat new_EI      if agegr2==1, s(n mean sd min max) save by(sex)
/**/ ///
tabstat new_EI      if agegr2==1  & outliers==0 ///
                    , s(n mean sd min max) save by(sex)

//OFF

* calc new energy index with adjusted intake estimates

replace new_energy_ind      =new_EI/bmr_kcal
la var  new_energy_ind      "new energy index"

* calc % with implausible pal

replace new_energy_ind_pl			=1
replace new_energy_ind_pl			=0 if new_energy_ind<1
replace new_energy_ind_pl           =0 if new_energy_ind>2.8 & sex==2
replace new_energy_ind_pl           =0 if new_energy_ind>3.5 & sex==1

la	var	new_energy_ind_pl	"new plausible self-report"	

hist    new_energy_ind if dlw_grp==0 & agegr2==1

hist    new_energy_ind  if agegr2==1 & dlw_grp==0, ///
                        lcolor(emerald) fcolor(none) ///
                        width(0.025) start(0) percent ///
                        yscale(titlegap(0) ) ylabel(0 (2) 10) ///
                        xlabel(0 (0.5) 3.5, format(%4.1fc)) ///
                        ytitle("percent of individuals", ///
                        orientation(vertical) placement(center)) ///
        addplot(hist    new_energy_ind  if agegr2==1 & dlw_grp==0 ///
                                        & new_energy_ind>=1, percent ///
                                        bcolor(emerald) width(0.025) start(0) ///
        xtitle("adjusted PAL (= adjusted energy intake / basal metabolic rate)")) ///
        legend(on label(1 "implausible") label(2 "plausible") ring(0) bplace(2))
        
        graph save      "graph - hist - new pal - adults", replace
        graph export    "graph - hist - new pal - adults.png", replace


graph combine "graph - hist - sr pal - adults" "graph - hist - new pal - adults" ///
        , col(1) xcomm ycomm

        graph save      "graph - hist - sr and new pal - adults", replace
        graph export    "graph - hist - sr and new pal - adults.png", replace

//ON

img, title("histogram of self-reported and adjusted PAL") width(270)

//OFF
*summary recalibrated EI by survey year, males
/**/ ///
tabstat new_EI      if agegr2==1 & sex==1 & dlw_grp==0, ///
                    s(n mean sd min max) save by(surveyyear)
/**/ ///
tabstat new_EI      if agegr2==1 & sex==1 & dlw_grp==0 & outliers==0, ///
                    s(n mean sd min max) save by(surveyyear)

*summary recalibrated EI by survey year, females
/**/ ///
tabstat new_EI      if agegr2==1 & sex==2 & dlw_grp==0 ///
                    , s(n mean sd min max) save by(surveyyear)
/**/ ///
tabstat new_EI      if agegr2==1 & sex==2 & dlw_grp==0 & outliers==0 ///
                    , s(n mean sd min max) save by(surveyyear)

//ON
*summary recalibrated EI by survey year, males
/**/    ///
tabstat new_EI      if agegr2==1 & sex==1 & dlw_grp==0 & outliers==0, ///
                    s(n mean sd min max) by(surveyyear) save
//OFF
                    mat yrs_1 = r(Stat1)
                    scalar yr1_m =yrs_1[2,1]
                    mat yrs_6 = r(Stat6)
                    scalar yr6_m =yrs_6[2,1]
        
reg     new_EI      i.surveyyear ///
                    if agegr2==1 & sex==1 & dlw_grp==0 & outliers==0
//ON
                    contrast surveyyear
//OFF
                    mat mf=r(F)
                    scalar f_stat_m=mf[1,1]
                    mat mdf=r(df)
                    scalar f_df_m=mdf[1,1]
                    mat mpr=r(p)
                    scalar f_pr_m=mpr[1,1]
//ON
*summary recalibrated EI by survey year, females
/**/    ///
tabstat new_EI      if agegr2==1 & sex==2 & dlw_grp==0 & outliers==0, ///
                    s(n mean sd min max) by(surveyyear) save
//OFF        
                    mat yrs_1 = r(Stat1)
                    scalar yr1_f =yrs_1[2,1]
                    mat yrs_6 = r(Stat6)
                    scalar yr6_f =yrs_6[2,1]

reg     new_EI      i.surveyyear ///
                    if agegr2==1 & sex==2 & dlw_grp==0 & outliers==0
//ON
                    contrast surveyyear
//OFF
                    mat mf=r(F)
                    scalar f_stat_f=mf[1,1]
                    mat mdf=r(df)
                    scalar f_df_f=mdf[1,1]
                    mat mpr=r(p)
                    scalar f_pr_f=mpr[1,1]
//ON
txt     "The average adjusted EI is failry consistent over study years, from " ///
        yr1_m " and " yr1_f " kcals in 2008 to " yr6_m " and " yr6_f " kcals in " ///
        "2014 for males and females respectively, as shown in figure. The " ///
        "change in average EI was not statistically significant for males " ///
        "(F=" f_stat_m " p=" f_pr_m ") or for females" ///
        "(F=" f_stat_f ", p=" f_pr_f ")."

//OFF
graph box energykcal new_EI if agegr2==1 & dlw_grp==0 & outliers==0, ///
                            subtitle(, ring(0) lcolor("none") pos(12) nobexpand) ///
                            by(sex, note("")) asyvars over(surveyyr) ///
                            box(1, fcolor("bluishgray8") lcolor("gs10")) ///
                            box(2, color("maroon")) ///
                            legend(order(1 "self-reported estimates" ///
                            2 "adjusted estimate")) ///
                            ylabel(0 (500) 6000, angle(horizontal)) ///
                            ytitle("average daily energy intake (kcals)", ///
                            orientation(vertical) placement(center)) 
  
                  
                        graph save ///
                        "graph - box - sr and new ei over years - adults.gph" ///
                        , replace
                        graph export ///
                        "graph - box - sr and new ei over years - adults.png" ///
                        , replace
//ON

img, title("self-reported and adjusted EI over study years") width(270)


/**/ qui         log close

markdoc "ndns data - analysis", export(pdf) replace install title("ECLIPSE")

********************************************************************************
							
********************************************************************************
							
		

