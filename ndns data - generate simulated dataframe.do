cd `"${mypath}ECLIPSE/ndns data dlw vs self reported"'

* initialise simulated dataset
* based on age and gender distributions as per eurostat 2013
        input age_grp
                    4
                    5
                    6
                    7
                    8
                    9
                    10
                    11
                    12
                    13
                    14
                    15
                    16
                    17
            end

        label de    lbl_age_grp ///
                    4   "20-24" ///
                    5	"25-29" ///
                    6	"30-34" ///
                    7	"35-39" /// 
                    8	"40-44" ///
                    9	"45-49" ///
                    10	"50-54" ///
                    11	"55-59" ///
                    12	"60-64" ///
                    13	"65-69" ///
                    14	"70-74" ///
                    15	"75-79" /// 
                    16	"80-84" ///
                    17	"85+"

        lab val     age_grp ///
                    lbl_age_grp

        * create initial populations for males and females
        expand 2, gen(sex)

        recode  sex(0=2)

        la de   lbl_sex ///
                1 "males" ///
                2 "females"

        la val  sex ///
                lbl_sex

        tab     age_grp sex, col

        * gen predictor vars to be replaced by random matching

        gen height=.
        gen weight=.
        gen energykcal=.

        sort age_grp sex
        gen id=_n

save init_sample_obs, replace


