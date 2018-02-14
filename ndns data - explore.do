
cd `"/${mypath}ECLIPSE/UKDA-6533-tab/tab"'

//OFF
use "ndns_data_yr1-6_dietaryandperson_data.dta", clear
cd `"/${mypath}ECLIPSE/Outputs"'

qui log using "ndns data - explore", replace 


//ON

/***
## Results
***/

//OFF

* summarise mean kcal intake by age and sex

twoway  (histogram energykcal if agegr2==1 & sex==1, ///
                            color("bluishgray8") ///
                            subtitle(, ring(0) lcolor("none") pos(12) nobexpand) ///
                            percent by(sex, note("") leg(off) rows(1)) ///
                            xscale(range(0 6000)) ///
                            width(100) ///
                            yscale(range(0 12)) ///
                            ylabel(0 (2) 12) /// 
                            xlabel(0 (1000) 6000, format(%9.0fc)) ///  
                            xtitle("self-reported energy intake (kcals)") ///
                            ytitle("percent of individuals", placement(center))) ///  
        (histogram energykcal if agegr2==1 & sex==2, ///
                            color("maroon")  ///
                            percent by(sex, note("") )) 
                          
        graph save "graph - histogram - sr ei - adults - by sex", replace
        graph export "graph - histogram - sr ei - adults - by sex.png", replace
//ON


twoway  (hist energykcal    if agegr2==1 & sex==2, percent ///
                            xscale(range(0 (1000) 6000)) ///
                            xlabel(0 (1000) 6000, format(%9.0fc)) ///
                            start(0) width(100) ///
                            xtitle("self-reported energy intake (kcals)") ///
                            yscale(range(0 12)) ///
                            ylabel(0 (2) 12) ///
                            ytitle("percent of individuals", placement(center)) ///
                            color("maroon") fintensity(100)) ///
        (hist energykcal    if agegr2==1 & sex==1, percent ///
                            xscale(range(0 (1000) 6000)) ///
                            xlabel(0 (1000) 6000, format(%9.0fc)) ///
                            start(0) width(100) ///
                            fcolor("none") lcolor("gs10") lwidth(medium)) ///
        , legend(order(2 "males" 1 "females") ring(0) position(2))

        graph save "graph - histogram - sr ei - adults", replace
        graph export "graph - histogram - sr ei - adults.png", replace
//ON
        img,    title("histogram of self-reported calories") ///
        height(200) width(300) 


graph   hbox energykcal if agegr2==1, ///
                        over(sex) horizontal asyvars ///
                        box(1, fcolor("bluishgray8") lcolor("gs10")) ///
                        box(2, color("maroon")) ///
                        ylabel(0 (1000) 6000, ang(h)) ///
                        ytitle("self-reported energy intake (kcals)", orientation(horizontal) placement(top)) ///
                        legend( ring(0) position(5)) ///
                        plotregion( margin(large))
                 
        graph save "graph - hbox - sr ei - adults", replace
        graph export "graph - hbox - sr ei - adults.png", replace


*********
* COMBINE DIST OF SR KCALS *


twoway  (hist energykcal    if agegr2==1 & sex==2, percent ///
                            xscale(range(0 (1000) 6000)) ///
                            xlabel(0 (1000) 6000, format(%9.0fc)) ///
                            start(0) width(100) ///
                            xtitle("self-reported energy intake (kcals)") ///
                            yscale(range(0 12) alt) ///
                            ylabel(0 (2) 12) ///
                            ytitle("percent of individuals", placement(center)) ///
                            color("maroon") fintensity(100)) ///
        (hist energykcal    if agegr2==1 & sex==1, percent ///
                            xscale(range(0 (1000) 6000)) ///
                            xlabel(0 (1000) 6000, format(%9.0fc)) ///
                            start(0) width(100) ///
                            fcolor("none") lcolor("gs10") lwidth(medium)) ///
        , legend(order(2 "males" 1 "females") ring(0) position(2))

        graph save "graph - histogram - sr ei - adults - altax", replace
        graph export "graph - histogram - sr ei - adults - altax.png", replace



graph combine   "graph - histogram - sr ei - adults - altax" ///               
                "graph - hbox - sr ei - adults" ///
                , col(1) xcomm
*********** cimbined chart axis not aligned, needs formatting



/**/ summ energykcal if agegr2==1 & sex==1
/**/ scalar av_m=`r(mean)'

/**/ summ energykcal if agegr2==1 & sex==2
/**/ scalar av_f=`r(mean)'

txt     "Figure shows the distribution of self reported energy intake. " ///
        "Average energy intake from self reported data for adults aged 19 " ///
        "years and over based self-reported data was found to be " av_m ///
        " and " av_f " for males and females respectively, over all survey years."
//OFF

/* self-reported estimates by less than or greater than ear

twoway 	(scatter tee_kcal energykcal if age>18 & morethanear==1, ///
		yscale(range(1000 4000)) xscale(range(1000 6000))  ///
		ylabel(1000 (1000) 6000) xlabel(1000 (1000) 6000) sort) ///
			(scatter tee_kcal energykcal if age>18 & morethanear==0, ///
			yscale(range(1000 4000)) xscale(range(1000 4000)) sort ///
            legend(on label(1 "more than EAR") label(2 "less than EAR") ///
                                ring(0) bplace(5))) ///
				|| function y=x, ra(energykcal) clpat(dash)                             
*/

//ON  

/**/ tab morethanear if agegr2==1, miss matcell(ear_true) matrow(ear_tot)
            qui: scalar ear_0=ear_true[1,1] 
            qui: scalar ear_tot=`r(N)' 

txt     "80.3% of subjects (" ear_0 " out of " ear_tot ") had EISR values " ///
        "below the Estimated Average Requirements (EAR) for their age-sex group"
       
//OFF
* compare average kcals over time
graph bar (mean) energykcal if agegr2==1, over(surveyyear)

graph box energykcal    if agegr2==1, ///
                        by(sex, note("")) ///
                        subtitle(, ring(0) lcolor("none") pos(12) nobexpand) ///
                        box(1, fcolor("bluishgray8") lcolor("gs10")) ///
                        box(2, color("maroon"))  ///
                        ylabel(0 (500) 6000, angle(horizontal)) ///
                        ytitle("self-reported energy intake (kcals)", ///
                            orientation(vertical) placement(center)) ///
                        legend( ring(0) position(2)) ///
                        over(surveyyear, relabel( ///
                        1 "2008" 2 "2009" 3 "2011" 4 "2012" 5 "2013" 6 "2014"))
                  
 
graph box energykcal    if agegr2==1, ///
                        over(sex) asyvars ///
                        box(1, fcolor("bluishgray8") lcolor("gs10")) ///
                        box(2, color("maroon")) ///
                        ylabel(0 (500) 6000, angle(horizontal)) ///
                        ytitle("self-reported energy intake (kcals)", ///
                            orientation(vertical) placement(center)) ///
                        legend( ring(0) position(2)) ///
                        over(surveyyear, relabel( ///
                        1 "2008" 2 "2009" 3 "2011" 4 "2012" 5 "2013" 6 "2014"))
 
                  
                        graph save ///
                        "graph - box - sr ei over years - adults.gph" ///
                        , replace
                        graph export ///
                        "graph - box - sr ei over years - adults.png" ///
                        , replace
//ON
                        img, title("boxplot sr kcals over time - adults")

//OFF
graph box energykcal    if agegr2==2, ///
                        over(surveyyear)
      
                        graph save "graph - box - sr kcals over time - childs.gph", replace

//ON    * average energy intake by survey year
/**/    ///
tabstat energykcal  if agegr2==1 & sex==1, ///
                    s(n mean sd min max) by(surveyyear) save
//OFF
                    mat yrs_1 = r(Stat1)
                    scalar yr1_m =yrs_1[2,1]
                    mat yrs_6 = r(Stat6)
                    scalar yr6_m =yrs_6[2,1]
        
reg     energykcal  i.surveyyear if agegr2==1 & sex==1
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
/**/    ///
tabstat energykcal  if agegr2==1 & sex==2, ///
                    s(n mean sd min max) by(surveyyear) save
//OFF        
                    mat yrs_1 = r(Stat1)
                    scalar yr1_f =yrs_1[2,1]
                    mat yrs_6 = r(Stat6)
                    scalar yr6_f =yrs_6[2,1]

reg     energykcal  i.surveyyear if agegr2==1 & sex==2
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
txt     "The estimated average EI declined across study years, from " yr1_m ///
        " and" yr1_f " kcals in 2008 to " yr6_m " and " yr6_f " kcals in " ///
        "2014 for males and females respectively, as shown in figure. The " ///
        "decline was found to be statistically significant for males " ///
        "( F=" f_stat_m " p=" f_pr_m ") but not for females " ///
        "(F=" f_stat_f ", p=" f_pr_f ")."

//OFF

* plausible self-reported

hist    energy_ind  if agegr2==1 , ///
                    lcolor(emerald) fcolor(none) ///
                    width(0.025) start(0) percent ///
                    yscale(titlegap(0) ) xlabel(0 (0.5) 3.5, format(%4.1fc)) ///
                    ytitle("percent of individuals", orientation(vertical) ///
                    placement(center)) ylabel(0 (2) 10) ///
        addplot(hist    energy_ind  if agegr2==1 & energy_ind>=1, ///
                                    bcolor(emerald) width(0.025) start(0) percent ///
                                    xtitle("PAL (= self-reported energy intake / basal metabolic rate)")) ///
                                    legend(on label(1 "implausible") ///
                                    label(2 "plausible") ///
                                    ring(0) bplace(2))

        graph save "graph - hist - sr pal - adults", replace
        graph export "graph - hist - sr pal - adults.png", replace
//ON
        img, title("histogram pal scores - all ages")

tabstat energy_ind if agegr2==1, s(mean min max) save
//OFF
        mat pal = r(StatTotal)
        scalar avg_pal = pal[1,1]
//ON
tab     energy_ind_pl if agegr2==1
//OFF
tabstat energy_ind_pl, save
        mat pal_pl = r(StatTotal)
        scalar pcnt_impl = 100*(1-pal_pl[1,1])
//ON
txt     "The distribution of PAL scores derived from EISR are shown in figure." ///
        "The scores range from low - representing minimal energy expenditure, " ///
        "as would be expected in bed bound individuals, to high - representing " ///
        "excessive energy expenditure, as would be expected by professional" ///
        "athletes. The scores are normally distributed centred on a mean " ///
        "value of " avg_pal ". The percentage of individuals with PAL < 1, " ///
        "the overall implausibility rate, was " pcnt_impl "percent."

//OFF

* self reported versus BMR

scatter    bmr_kcal energykcal if agegr2==1, ///
                    yscale(range(0 6000)) ylabel(0 (1000) 6000, format(%9.0fc))  ///
                    xscale(range(0 6000)) xlabel(0 (1000) 6000, format(%9.0fc)) ///
                    ytitle("basal metabolic rate (kcals)") ///
                    xtitle("self-reported energy intake (kcals)") sort ///
                    lcolor(gs10) fcolor(bluishgray8)
        
        gen bmr_sr_ratio=bmr_kcal/energykcal

        distplot scatter bmr_sr_ratio if agegr2==1, by(sex)


* avg self reported vs dlw

graph   hbox    energykcal tee_kcal if agegr2==1, ///
                by(sex, note("")) ///
                box(1, fcolor("bluishgray8") lcolor("gs10")) ///
                box(2, color("maroon")) ///
                subtitle(, ring(0) lcolor("none") pos(12) nobexpand) ///
                ytitle("(kcals)") ylabel(0 (1000) 6000) ///
                legend(order(1 "estimated energy intake" 2 "measured energy expenditure")) 
        
                graph save Graph "graph - hbox - sr and dlw kcals - adults", replace
                graph export "graph - hbox - sr and dlw kcals - adults.png", replace

* diffs between dlw and self-reported

twoway 	(scatter tee_kcal energykcal, sort) 
			* y axis var x axis var

twoway 	(scatter    tee_kcal energykcal if age>18 & sex==1, ///
                    yscale(range(0 6000)) ylabel(0 (1000) 6000, format(%9.0fc))  ///
                    xscale(range(0 6000)) xlabel(0 (1000) 6000, format(%9.0fc)) ///
                    ytitle("DLW measured energy expenditure (kcals)") ///
                    xtitle("self-reported energy intake (kcals)") sort ///
                    lcolor(gs10) fcolor(bluishgray8)) ///
        (scatter    tee_kcal energykcal if age>18 & sex==2, ///
                    yscale(range(1000 6000)) xscale(range(1000 6000)) sort ///
                    color("maroon") fintensity(100) ///
                    legend(on label(1 "males") label(2 "females") ///
                    label(3 "intake = expenditure") ring(0) bplace(4) row(1))) ///
		|| function y=x, ra(energykcal) clpat(dash) lcolor(bluishgray8)                             
           
        graph save Graph "graph - scatter - sr kcals vs dlw kcals - adults", replace
        graph export "graph - scatter - sr kcals vs dlw kcals - adults.png", replace
//ON

/***
The scatter plot shows estimates of energy intake from self reported data
(EISR) against the estimates of energy intake from DLW data for individuals
in the training data, where these two estimates are the same, individuals 
would appear on the dashed line.. Most of the points are above this line, 
representing under-reported estimates from self-reported data. There are a 
small number of cases which show over-reporting, represented by points 
below y=x. 
***/
        img, title("scatter dlw vs sr - adults")

//OFF

* tee_kcal energykcal kcal_diff 
			
foreach i of var kcal_diff_pcnt {

		*sum `i', detail

		bysort 	agegr2: ///
		table 	sex, ///
				c(n `i' mean `i' sd `i' min `i' max `i') row

		hist	`i', by(sex agegr2)
		*img, title("histogram of `i'") width(350)
		graph 	hbox `i', by(sex agegr2)	
		*img, title("distribution of `i'") width(350)

    	* correlation between actual tee and reported ei, & % 'error'
		twoway 	(scatter `i' tee_kcal, sort) ///
				(scatter `i' tee_kcal, sort) ///
				(lfit `i' tee_kcal) ///
				(lfit `i' tee_kcal), ///
				legend(label(1 "Males") label(2 "Females")) ///
				by(sex agegr2)

}

bysort  energy_ind_pl: ///
table 	agegr2, c( ///
        n       kcal_diff ///
        mean    kcal_diff ///
        sd      kcal_diff ///
        min     kcal_diff ///
        max     kcal_diff) row
		
hist    kcal_diff if dlw_grp==1 & agegr2==1, percent by(sex)	

hist    kcal_diff_pcnt  if dlw_grp==1 & agegr2==1, ///
                        percent by(sex, note("")) ///
                        ytitle("percent of individuals", ///
                        orientation(horizontal) placement(center)) ///
                        ylabel(0 (2) 30) xlabel(-20 (10) 80) width(10) ///
        xtitle("percent 'error' in self-reported intake (-ve numbers = over reported intake)")
        
        graph save Graph "graph - hist - percent sr error - by sex", replace
        graph export "graph - hist - percent sr error - by sex.png", replace

        distplot scatter kcal_diff_pcnt if dlw_grp==1 & agegr2==1, by(sex)


graph   hbox    kcal_diff_pcnt if agegr2==1, ///
                over(sex, label(angle(90))) asyvars ///
                box(1, fcolor("bluishgray8") lcolor("gs10")) ///
                box(2, color("maroon")) ///
                ylabel(-20 (10) 80) ///
                ytitle("percent 'error' in self-reported intake (-ve numbers = over reported intake)") ///
                legend( ring(0) position(5)) ///
                plotregion( margin(large))
    

                graph save Graph "graph - hbox - percent sr error - by sex", replace
                graph export "graph - hbox - percent sr error - by sex.png", replace
//ON
                img, title("hbox pcnt error - adults")




tabstat     kcal_diff_pcnt  if agegr2==1 & dlw_grp==1, ///
                            s(n mean sd min max) save by(sex)

//OFF
            mat diff = r(StatTotal)
            scalar pct_df_tot=diff[2,1]
                mat diff_m = r(Stat1)
                scalar pct_df_m=diff_m[2,1]
                scalar min_df_m=diff_m[4,1]
                scalar max_df_m=diff_m[5,1]
                    mat diff_f=r(Stat2)
                    scalar pct_df_f=diff_f[2,1]
                    scalar min_df_f=diff_f[4,1]
                    scalar max_df_m=diff_f[5,1]

//ON
tabstat     kcal_diff   if agegr2==1 & dlw_grp==1, ///
                        s(n mean sd min max) save by(sex)
//OFF
            mat diff_m = r(Stat1)
            scalar min_cal_m=diff_m[4,1]
            scalar max_cal_m=diff_m[5,1]
                mat diff_f = r(Stat2)
                scalar min_cal_f=diff_f[4,1]
                scalar max_cal_f=diff_f[5,1]

//ON

/***
Comparing measures of calorie expenditure of DLW (EE) with self-reported 
calorie intake (EISR) shows an average level of under-reporting of <!pct_df_tot!>
% overall, with little difference between males and females (<!pct_df_m!>% 
and <!pct_df_f!>% respectively). 

Individual error ranged from -<!min_df_m!>% to <!max_df_m!>% among males and 
from -<!min_df_f!>% to <!max_df_f!>% among females, corresponding to differences
ranging from -<!min_cal_m!> to <!max_cal_m!> kcals for males and -<!min_cal_f!>
to <!max_cal_f!> kcals for females, where negative values represent EI values 
greater than measured EE and positive values represent EI estimates lower than 
measured EE.
***/


/***
---
## Summary of individual characteristics
***/

				 
foreach i of var  age  height_m weight bmi2 age {

		sum `i', detail

		/***
		summary stats "`i'"
		***/


		bysort 	agegr2: ///
		table 	sex, ///
				c(med `i' mean `i' sd `i' min `i' max `i') row

		hist	`i', by(sex agegr2)
		
       }

/***
###      Cohort Profiles
***/


count if dlw_grp==1

//ON
txt     "There are `r(N)' subjects in the DLW test group"

/**/ bysort  dlw_grp: ///
tab     sex if agegr2==1


levelsof dlw_grp, local(dlw_levs)

foreach i of var age height_m weight bmi2 energykcal {
        
        di "`i'"
        
        foreach d of local dlw_levs {

            di "dlw group `d'"
            count if dlw_grp==`d' & agegr2==1

            di "males"
            summ `i' if ///
                            agegr2==1 ///
                            & dlw_grp==`d' ///
                            & sex==1
            di "females"
            summ `i' if ///
                            agegr2==1 ///
                            & dlw_grp==`d' ///
                            & sex==2

        }
}

qui log close


markdoc `"/${mypath}ECLIPSE/UKDA-6533-tab/tab/ndns data - explore"', export(pdf) replace install title("ECLIPSE")


