* simulate errors


/***

### Test Data

the remaining sample of individuals with the NDNS data 
used to create a simulation of 1,000 individuals. 
The simulated data set was initalised with the standard european population (eurostat2013)
structure and height, weight and self reported calories were selected randomly
from the sample data set.

***/


* define prog called by simulate

prog avg_fail, rclass
    
    use init_sample_obs, clear

    * use joinby - create obs for every pariwise match by age, sex in dataset

    joinby  age_grp sex ///
            using ndns_data_yr1-6_dietaryandperson_data.dta, ///
            update replace unm(m) _merge(org)

    keep    id age_grp age sex ///
            height weight energykcal bmr_kcal seriali 

    tab     id //check how many matches per age sex subgroup

        *randomly select observation for each age sex subgroup*/
        *set seed 1234 //ff
        gen double shuffle=runiform()
        gen check=_n //delete after testing
            bysort id (shuffle): gen shuff_id=_n
                       * mutiply std pop by 5 = 1000 individuals (500 m's 500 f's)
                       keep if (age_grp==4 & shuff_id<41) ///
                            | (age_grp==5 & shuff_id<41) ///
                            | (age_grp==6 & shuff_id<41) ///
                            | (age_grp==7 & shuff_id<46) ///
                            | (age_grp==8 & shuff_id<46) ///
                            | (age_grp==9 & shuff_id<46) ///
                            | (age_grp==10 & shuff_id<46) ///
                            | (age_grp==11 & shuff_id<41) ///
                            | (age_grp==12 & shuff_id<41) ///
                            | (age_grp==13 & shuff_id<36) ///
                            | (age_grp==14 & shuff_id<31) ///
                            | (age_grp==15 & shuff_id<26) ///
                            | (age_grp==16 & shuff_id<16) ///
                            | (age_grp==17 & shuff_id<16) 

                        *check age sex dist maintained
                        tab age_grp sex, col nofreq

        * predict error - based on linear equation
        
        estimates restore pred_error_ads
            
            * create dummy for factor var
            gen _Isex_2=sex==2

        predict pred_error, xb
        
        tabstat pred_error, by(sex) s(mean sd min max iqr) ///
            save
                matrix tl_er = r(StatTotal)'
                matrix males = r(Stat1)'
                matrix femal = r(Stat2)'

        * cal adjusted energy intake
        gen     new_EI=energykcal/((100-pred_error)/100)
        format  new_EI %9.0f
        
        tabstat energykcal, by(sex) s(mean sd min max iqr)
        tabstat new_EI, by(sex) s(mean sd min max iqr)
        
        * cal pal based on adjusted energy intake

        gen     new_energy_ind=new_EI/bmr_kcal
        la var  new_energy_ind "energy index"

        * calc % with implausible pal

        gen		new_energy_ind_pl			=1
        replace new_energy_ind_pl			=0 if new_energy_ind<1
        replace new_energy_ind_pl           =0 if new_energy_ind>2.8 & sex==2
        replace new_energy_ind_pl           =0 if new_energy_ind>3.5 & sex==1

        la	var	new_energy_ind_pl	"plausible self-report"	

        * outputs to be returned by program

        return scalar avg_err=tl_er[1,1]
        return scalar avg_male=males[1,1]
        return scalar avg_fema=femal[1,1]

        return scalar min_err=tl_er[1,3]
        return scalar min_male=males[1,3]
        return scalar min_fema=femal[1,3]
        
        return scalar max_err=tl_er[1,4]
        return scalar max_male=males[1,4]
        return scalar max_fema=femal[1,4]

        *save avg ei for males and females for sample
        forval i = 1/2 {
                su new_EI if sex==`i', mean
                return scalar mu_EI_`i' = r(mean)
               }

   
        * save % implausible for sample
        qui: su new_energy_ind, detail
        return scalar obs = r(N)
        
        tab new_energy_ind_pl
        qui: su new_energy_ind_pl, mean
        return scalar mu = r(mean)


end 
    ***** check *******
    set seed 10101
    avg_fail
    return list
    *******************



********************************************************************************
* replicate random sample and predicted error using simulate
* ----------------------------------------------------------
    
    * set graphics off
    local sreps 1000

    simulate fail=r(mu) kcal_m=r(mu_EI_1) kcal_f=r(mu_EI_2) count=r(obs) ///
              avg_err=r(avg_err) min_err=r(min_err) max_err=r(max_err) /// 
            , seed(10101) reps(`sreps') ///
            saving(sim_failures, replace) : avg_fail

   * set graphics on
    qui: graph combine   "output - box plot - energykcal - 1 - single simulation" ///
                            "parplot sr EI vs adj EI - adults - 1 - single simulation" ///
                            "output - box plot - new_EI - 1 - single simulation" ///
                            "output - box plot - energykcal - 2 - single simulation" ///
                            "parplot sr EI vs adj EI - adults - 2 - single simulation" ///
                            "output - box plot - new_EI - 2 - single simulation" ///                    
                            , row(2) ycomm imargin(small)
            
            graph save Graph "combined reported and predicted adults males and females - single simulation", replace
            graph export "combined reported and predicted adults males and females - single simulation.png", replace
            

    * average % implausible for sample of samples
    
    /***
    implausbibility rate based on avergae from 1,000 simulations 
    of percent of individuals with with a PAL out of bounds
    (i.e. <1 or > upper bound by gender)
    ***/

    sum fail
    dotplot fail
    * avgerage of mean kcals
    sum kcal_m
    sum kcal_f

********************************************************************************


















