
cd `"/${mypath}ECLIPSE/ndns data dlw vs self reported"'
qui log using "ndns data - test", replace 

//OFF
use "ndns_data_yr1-6_dietaryandperson_data.dta", clear

//ON

/***
## Results
***/

//OFF

* summarise mean kcal intake by age and sex

hist    energykcal if agegr2==1, percent by(sex, note("")) ///
        xscale(range(0 6000)) ///
        ytitle("%", placement(top) orientation(horizontal))

            graph save "reported_energy_intake_hist_adults", replace
                graph export "reported_energy_intake_hist_adults.png", replace
//ON
                    img,    title("histogram of self-reported calories") ///
                            height(200) width(300) 

/**/ summ energykcal if agegr2==1 & sex==1
/**/ scalar av_m=`r(mean)'

/**/ summ energykcal if agegr2==1 & sex==2
/**/ scalar av_f=`r(mean)'

txt     "Figure shows the distribution of self reported energy intake. " ///
        "Average energy intake from self reported data for adults aged 19 " ///
        "years and over based self-reported data was found to be " av_m ///
        "and " av_f "for males and females respectively, over all survey years."
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

/**/ tab morethanear, miss matcell(ear_true) matrow(ear_tot)
            qui: scalar ear_0=ear_true[1,1] 
            qui: scalar ear_tot=`r(N)' 

txt     "80.3% of subjects (" ear_0 " out of " ear_tot ") had EISR values " ///
        "below the Estimated Average Requirements (EAR) for their age-sex group"
       
//OFF
* compare average kcals over time
graph   bar (mean) energykcal, over(surveyyear)

graph   box energykcal ///
        if agegr2==1, ///
        by(sex, note("")) ///
        ylabel(0 (500) 6000, angle(horizontal)) ///
        ytitle("kcals", orientation(horizontal) placement(top)) ///
        over(surveyyear, relabel( ///
        1 "2008" 2 "2009" 3 "2011" 4 "2012" 5 "2013" 6 "2014"))
       
            graph save ///
            Graph "output - box plot - sr kcals over time - adults.gph" ///
            , replace
                graph ///
                export "output - box plot - sr kcals over time - adults.png" ///
                , replace
//ON
                img, title("boxplot sr kcals over time - adults")

//OFF
graph   box energykcal ///
        if agegr2==2, ///
        over(surveyyear)
      
            graph save ///
            Graph "output - box plot - sr kcals over time - childs.gph" ///
            , replace

//ON    * average energy intake by survey year
/**/    tabstat energykcal if agegr2==1 & sex==1, ///
        s(n mean sd min max) by(surveyyear) save
//OFF
            mat yrs_1 = r(Stat1)
            scalar yr1_m =yrs_1[2,1]
            mat yrs_6 = r(Stat6)
            scalar yr6_m =yrs_6[2,1]

        
        reg energykcal i.surveyyear if agegr2==1 & sex==1
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
/**/    tabstat energykcal if agegr2==1 & sex==2, ///
        s(n mean sd min max) by(surveyyear) save
//OFF        
            mat yrs_1 = r(Stat1)
            scalar yr1_f =yrs_1[2,1]
            mat yrs_6 = r(Stat6)
            scalar yr6_f =yrs_6[2,1]

        reg energykcal i.surveyyear if agegr2==1 & sex==2
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
        " and" yr1_f " kcals in 2008 to " yr6_m " and " yr6_m " kcals in " ///
        "2014 for males and females respectively, as shown in figure. The " ///
        "decline was found to be statistically significant for males " ///
        "( F=" f_stat_m " p=" f_pr_m ") but not for females " ///
        "(F=" f_stat_f ", p=" f_pr_f ")."

//OFF

* plausible self-reported

hist    energy_ind, ///
        bcolor(teal) ///
        width(0.025) start(0) percent ///
        yscale(titlegap(0) ) ///
        ytitle("%", orientation(horizontal) placement(top)) ///
            addplot(hist    energy_ind if energy_ind>1, ///
                            width(0.025) start(0) percent ///
                            xtitle("reported pal")) ///
                            legend(on label(1 "implausible") ///
                            label(2 "plausible") ///
                            ring(0) bplace(2))
            graph save "reported_energy_index", replace
                graph export "reported_energy_index.png", replace
//ON
                    img, title("histogram pal scores - all ages")

tabstat energy_ind, s(mean min max) save
//OFF
        mat pal = r(StatTotal)
        scalar avg_pal = pal[1,1]
//ON
tab     energy_ind_pl
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

* avg self reported vs dlw

graph   hbox energykcal tee_kcal if agegr2==1, by(sex, note("")) 
            graph save Graph "reported_vs_dlw_kcals_adults", replace
                graph export "reported_vs_dlw_kcals_adults.png", replace

* diffs between dlw and self-reported

twoway 	(scatter tee_kcal energykcal, sort) 
			* y axis var x axis var

twoway 	(scatter tee_kcal energykcal if age>18 & sex==1, ///
		yscale(range(1000 4000)) xscale(range(1000 6000))  ///
		ylabel(1000 (1000) 6000) xlabel(1000 (1000) 6000) sort) ///
			(scatter tee_kcal energykcal if age>18 & sex==2, ///
			yscale(range(1000 4000)) xscale(range(1000 4000)) sort ///
            legend(on label(1 "males") label(2 "females") ///
                                ring(0) bplace(5))) ///
				|| function y=x, ra(energykcal) clpat(dash)                             
           
        graph save Graph "measured_vs_reported_scatter_adults", replace
        graph export "measured_vs_reported_scatter_adults.png", replace
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
		
hist    kcal_diff, percent by(sex)	

hist    kcal_diff_pcnt, percent by(sex, note("")) ///
        ytitle("%", orientation(horizontal) placement(top))
            graph save Graph "percent_error_adults_dist", replace
                graph export "percent_error_adults_dist.png", replace

graph   box kcal_diff_pcnt if agegr2==1, over(sex) ///
        ytitle("%", orientation(horizontal) placement(top)) 
            graph save Graph "percent_error_adults", replace
                graph export "percent_error_adults.png", replace
//ON
        img, title("hbox pcnt error - adults")

tabstat kcal_diff_pcnt if agegr2==1, s(n mean sd min max) save by(sex)
* tabstat kcal_diff_pcnt if age>15 & age<65, s(n mean sd min max) save by(sex)
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
tabstat kcal_diff if agegr2==1, s(n mean sd min max) save by(sex)
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
tab     sex


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

