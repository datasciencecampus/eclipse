

* set up variables to be returned from simulations
local dp "kcal_diff_pcnt"
local ip  "age _Isex_2 weight energykcal"
local vals "count r2 sr_ei_male sr_ei_male_sd sr_ei_female sr_ei_female_sd pct_err_male pct_err_male_sd pct_err_female pct_err_female_sd"

local cols "`ip' `vals'"

  * use local ip to return coeffs only or cols to return coeffs & descriptors
  foreach var of local cols {
        local res "`res' `var'=r(`var')"
    }
  local res="r(_cons) `res'"

di "`res'"

* run with local res to return full output from bootstrapped sample 
simulate `res' , reps(1000) : sw_pbs_simulator

* save outputs from simulations - one row per replication
cd `"${mypath}ECLIPSE/Outputs"'
save "20172308 - 1000 reg coefs - adults only", replace

  * summarise coeffs over each replication  
  foreach var of local ip {
     tabstat `var', s(n mean sd min max) 
    reg `var'
    }

****************
* save mean vals for model coeffs from bootstrapped sample

preserve
            *create means for each var in local ip plus var for constant _sim_1
            * consider extracting name for constant in program
            collapse `ip' _sim_1

            *save each mean as a scalar with varname_01 
            *to use later to predict error
             qui ds
                    local a = r(varlist)
                        foreach var of local a {
                            scalar `var'_01=`var'
                        } 
restore


pause
********************************************************************************
* NEED TO RUN PROGRAM IN SESSION BEFORE USING SIMULATE COMMAND
********************************************************************************

* generate random sample and retun regression coeffs from each replication

* program returns rclass values from commands
program define sw_pbs_simulator, rclass
        
        *start each replication with clear memory
        drop _all

        cd `"/${mypath}ECLIPSE/UKDA-6533-tab/tab"'
        use "ndns_data_yr1-6_dietaryandperson_data.dta", clear
        
        *keep only training sample - adults only
        keep if dlw_grp==1 & agegr2==1
        
        *select samples maintaining gender and age distribution
        bsample, str(sex agegad2)
        
        *return summary statistics for the sample
        return scalar count = r(N)

        summ energykcal if sex==1
        return scalar sr_ei_male = r(mean)
        return scalar sr_ei_male_sd = r(sd)
 
        summ energykcal if sex==2
        return scalar sr_ei_female = r(mean)
        return scalar sr_ei_female_sd = r(sd)

        summ kcal_diff_pcnt if sex==1
        return scalar pct_err_male = r(mean)
        return scalar pct_err_male_sd = r(sd)
 
        summ kcal_diff_pcnt if sex==2
        return scalar pct_err_female = r(mean)
        return scalar pct_err_female_sd = r(sd)
       
        local dp "kcal_diff_pcnt"
        local ip  "energykcal age sex weight"

        tempname rmse b
        tempvar yhat y
        
        *gettoken depvar indepvar : vars

        xi: reg     kcal_diff_pcnt ///
                    energykcal ///
                    age weight i.sex

        // start returning coefficients
        matrix b = e(b)
         local in : colnames b
        di "`in'"
        local out : list ip - in
       
        foreach var of local in {
            return scalar `var' = _b[`var']
        }
        foreach var of local out {
            return scalar `var' = .
        }

        return scalar r2 = e(r2)
        
end





