
local dp "kcal_diff_pcnt"
local ip  "age sex weight height energykcal lg_energykcal energy_ind lg_energy_ind"
gettoken indepvar : ip

  foreach var of local ip {
        local res "`res' `var'=r(`var')"
    }
    local res="`res' r(_cons)"

simulate `res' , reps(1000) : sw_pbs_simulator
save "20172308 - 1000 reg coefs - adults only", replace


preserve

    qui ds
        local a = r(varlist)
            collapse `a'

                qui ds
                    local a = r(varlist)
                        foreach var of local a {
                            scalar `var'_01=`var'
                        } 

restore



**************

program define sw_pbs_simulator, rclass
 
    drop _all
    use "ndns_data_yr1-6_dietaryandperson_data.dta", clear
    keep if dlw_grp==1

    bsample, str(sex agegad2)
       
    local dp "kcal_diff_pcnt"
    local ip  "energykcal lg_energykcal energy_ind lg_energy_ind age sex weight height"

    tempname rmse b
    tempvar yhat y
        
        *gettoken depvar indepvar : vars
    stepwise, pr(0.05): ///
        reg kcal_diff_pcnt ///
            energykcal lg_energykcal ///
            energy_ind lg_energy_ind ///
            age sex weight height ///
                if agegr2==1


        // start returning coefficients
        matrix b = e(b)
         local in : colnames b
        di `in'
        local out : list ip - in
       
        foreach var of local in {
            return scalar `var' = _b[`var']
        }
        foreach var of local out {
            return scalar `var' = .
        }
end


*************

* simulate regression coefs (without stepwise)

program define sw_pbs_simulator, rclass
 
        drop _all
        use "ndns_data_yr1-6_dietaryandperson_data.dta", clear
        keep if dlw_grp==1 

        bsample, str(sex agegad2)

       
        local dp "kcal_diff_pcnt"
        local ip  "energykcal age sex weight"

        tempname rmse b
        tempvar yhat y
        
        *gettoken depvar indepvar : vars
        *stepwise, pr(0.05):

        xi: reg     kcal_diff_pcnt ///
                    energykcal ///
                    age weight i.sex ///
                    if agegr2==1


        // start returning coefficients
        matrix b = e(b)
         local in : colnames b
        di `in'
        local out : list ip - in
       
        foreach var of local in {
            return scalar `var' = _b[`var']
        }
        foreach var of local out {
            return scalar `var' = .
        }
end





