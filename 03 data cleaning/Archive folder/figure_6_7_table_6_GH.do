
*-------------------------------------------------------------------------------
*						Capstone -- Social Assistance
*							Tables 6,7 & Figure 6
*
* Author: Gavin Hawkins
* Date: Nov 17th 2021
*
*IMPORTANT (When updating tables - please be sure to update the 4 flagged "use"/// commands with the most current dta file)
*-------------------------------------------------------------------------------

use "/Users/gavinhawkins/Box/Capstone WB/data/clean/Main_database_Oct.dta", clear
*----------------------------
**1.1 -- Table 5 - Essential Data**
*----------------------------
*New Variables

*create population_filled to provide matching variables
keep country_name population
drop if population == ""
duplicates drop country_name, force
ren population population_filled
tempfile tt
save `tt'

use "/Users/gavinhawkins/Box/Capstone WB/data/clean/Main_database_Oct.dta", clear
 
merge m:1 country_name using `tt'
br population population_filled country_name 
br 

*destring population & create sa_app "Social Assistance actual population percentage"
gen population_filled_n = real(population_filled)
*destring Policy Adaptations
encode sa_policy_adap, generate(sa_policy_adap2) //duplicate

*cleaning sa_policy_adap



*encode population_filled, generate(population_filled2)
**sa_app:Social Assistance_Actual Population Percentage
gen sa_app = (ben_actual/population_filled_n)*100
gsort -sa_app 
encode sp_category, gen(sp_category_code)
*drop if sp_category_code != 1 & sp_category_code != 2

**sa_app:Social Assistance_Planned Population Percentage
gen ben_plan_n = real(ben_plan)
gen sa_ppp = (ben_plan_n/population_filled_n)*100
gsort -sa_ppp 
drop if sa_app == .

*titling variables 
encode sp_area, generate(sp_area2) // duplicate
*drop if sp_area2 !=1 // elimintates large pension plan


*cleaning sa_policy_adap2



*replace program_name = sa_policy_adap if program_name == ""

keep program_id country_name program_name sa_app sa_ppp
keep in 1/50







*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 use "/Users/gavinhawkins/Box/Capstone WB/data/clean/Main_database_Oct.dta", clear
*----------------------------
**2.1 -- Table 6 - Essential Data**
*----------------------------
*New Variables
*NV 2.1.1
gen ben_plan_n = real(ben_plan)

encode sp_area, generate(sp_area2)

*NV 2.1.2 & 2.1.3
//Destring "Policy Adaptations"  Expansions (vertical and horizontal) and administrative adaptations
encode sa_policy_adap, generate(sa_policy_adap2)
*replace sa_policy_adap2 = . if sa_policy_adap2 == ""
//Destring "Social Protection Catagory"
encode sp_category, generate(sp_category2)
*replace sp_category2 = . if sp_category2 == ""
gen cash_tra_dum =0
replace cash_tra_dum = 1 if sp_category2==1
replace cash_tra_dum = 1 if sp_category2==2

labelbook sa_policy_adap2
gen vert_dum = 0
replace vert_dum = 1 if sa_policy_adap2 == 9
replace vert_dum = 1 if sa_policy_adap2 == 4
replace vert_dum = 1 if sa_policy_adap2 == 13


gen hori_dum = 0
replace hori_dum = 1 if sa_policy_adap2 == 1
replace hori_dum = 1 if sa_policy_adap2 == 2
replace hori_dum = 1 if sa_policy_adap2 == 3
replace hori_dum = 1 if sa_policy_adap2 == 4
replace hori_dum = 1 if sa_policy_adap2 == 5
replace hori_dum = 1 if sa_policy_adap2 == 15
replace hori_dum = 1 if sa_policy_adap2 == 7


*Cleaning
list ben_plan_n if ben_plan_n >=4000000000 & ben_plan_n != . 
replace ben_plan_n = .  if ben_plan_n >=4000000000 


*----------------------------
**2.2.1 "Planned number of individuals" by "Social assistance beneficiaries//
//that benefit from more coverage or more generous transfers"


tabstat ben_plan_n, statistics( sum ) format(%12.0f)
//tabstat ben_plan_n if sp_area2 == 1, statistics( sum ) format(%12.0f)

egen T1 = sum(ben_plan_n)

*----------------------------
**2.2.2 "Planned number of individuals" by "Cash transfer beneficiaries//
//that benefit from more coverage or more generous transfers"

tabstat ben_plan_n if vert_dum==1 | hori_dum==1, statistics( sum ) format(%12.0f)
//tabstat ben_plan_n if vert_dum==1 & cash_tra_dum == 1 | hori_dum==1 & cash_tra_dum == 1 , statistics( sum ) format(%12.0f)

egen T2 = sum(ben_plan_n) if vert_dum==1 | hori_dum==1
*----------------------------
**2.2.3 "Planned number of individuals" by "Cash transfer beneficiaries covered"


tabstat ben_plan_n if hori_dum==1, statistics( sum ) format(%12.0fc)
//tabstat ben_plan_n if vert_dum!=1, statistics( sum ) format(%12.0fc)
//tabstat ben_plan_n if vert_dum==1 & cash_tra_dum = 1, statistics( sum ) format(%12.0fc)

egen T3 = sum(ben_plan_n) if hori_dum==1

*----------------------------
*2.2.4 "Actual number of individuals" by "Social assistance beneficiaries//
//that benefit from more coverage or more generous transfers"

tabstat ben_actual, statistics( sum ) format(%12.0fc)

egen T4 = sum(ben_actual)

*----------------------------
*2.2.5 "Actual number of individuals" by "Cash transfer beneficiaries//
//that benefit from more coverage or more generous transfers"
*Problem - less than original report

tabstat ben_actual if vert_dum==1 | hori_dum==1, statistics( sum ) format(%12.0fc)

egen T5 = sum(ben_actual) if vert_dum==1 | hori_dum==1

*----------------------------
*2.2.6 "Actual number of individuals" by "Cash transfer beneficiaries covered"
*PROBLEM - less than original report

tabstat ben_actual if hori_dum==1, statistics( sum ) format(%12.0fc)

egen T6 = sum(ben_actual) if hori_dum==1


*----------------------------
*2.3 Table 6 - Table
*----------------------------

keep T1 T2 T3 T4 T5 T6
collapse T1 T2 T3 T4 T5 T6
format T1 T2 T3 T4 T5 T6 %12.0fc
xpose, clear
rename v1 ben_totals
gen ben_percent = (ben_totals/7900000000)*100
gen position = uniform()

gen x = _n
gen y = mod(x, 3)
replace y = 3 if y==0
drop x

gen x = _n
gen j = mod(x, 2)
replace y = 2 if y==0
drop x

drop position 

reshape wide ben_totals ben_percent, i(y) j(j)

*reshape wide stub, i(y) j(j)

save "$output/Table_6.dta", replace

label define ylab 1 "other" 2 "ended" 3 "three"
label values y ylab

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*----------------------------
*3.1 Figure 6 - Graphing Table
*----------------------------
use "/Users/gavinhawkins/Box/Capstone WB/data/clean/Main_database_Oct.dta", clear

encode sp_area, generate(sp_area2) // duplicate

//test
br    country_name ben_actual sa_policy_adap program_name 
gsort -ben_actual 
drop if sp_area2 !=1 // elimintates large pension plan
replace program_name = sa_policy_adap if program_name == ""

keep country_name ben_actual program_name    
keep in 1/10

save "$output/figure_6.dta", replace

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*----------------------------
*4.1 Figure 7 - Graphing Table
*----------------------------
use "/Users/gavinhawkins/Box/Capstone WB/data/clean/Main_database_Oct.dta", clear

*create population_filled to provide matching variables
keep country_name population
drop if population == ""
duplicates drop country_name, force
ren population population_filled
tempfile tt
save `tt'

use "/Users/gavinhawkins/Box/Capstone WB/data/clean/Main_database_Oct.dta", clear
 
merge m:1 country_name using `tt'
br population population_filled country_name 
br 


*destring population & create sa_app "Social Assistance actual population percentage"
gen population_filled_n = real(population_filled)
*destring Policy Adaptations
encode sa_policy_adap, generate(sa_policy_adap2) //duplicate

*encode population_filled, generate(population_filled2)
**sa_app:Social Assistance_Actual Population Percentage
gen sa_app = (ben_actual/population_filled_n)*100
gsort -sa_app 
encode sp_category, gen(sp_category_code)
drop if sp_category_code != 1 & sp_category_code != 2

//Quality Check
br program_id country_name sa_app sa_policy_adap2 population_filled_n ben_actual sp_category_code

//Data Isolation
keep   country_name sa_app sa_policy_adap2       
keep in 1/10

save "$output/figure_7.dta", replace



*********

* check the encoded values/str
codebook sa_policy_adap, tab(99) 

* generate a dummy variable for each encoded str
forvalues v = 1/13 {
	gen sa_policy_adap`v' = regexm(sa_policy_adap,"`v'.") 
}

* generate a new var
gen sa_policy = .
* tostring to replace with string later
tostring sa_policy, replace

* regularize the variable with formal labels
replace sa_policy = "1. Horizontal Expansion"    if sa_policy_adap1 == 1
replace sa_policy = "2. Vertical Expansion"      if sa_policy_adap2 == 1
replace sa_policy = "4. Change in conditionality" if sa_policy_adap4 == 1
replace sa_policy = "5. Admin simplification"     if sa_policy_adap5 == 1
replace sa_policy = "6. Advance payment"          if sa_policy_adap6 == 1
replace sa_policy = "7. Additional payment"       if sa_policy_adap7 == 1
replace sa_policy = "8. Other admin adaptations"  if sa_policy_adap8 == 1
replace sa_policy = "9. One-off (targeted)"      if sa_policy_adap9 == 1
replace sa_policy = "10. One-of (universal)"     if sa_policy_adap10 == 1
replace sa_policy = "11. Multiple payments (universal)"  if sa_policy_adap11 == 1
replace sa_policy = "12. Multiple payments (targeted)"   if sa_policy_adap12 == 1
replace sa_policy = "13. Not applicable"                 if sa_policy_adap13 == 1

* use codebook to see encoded strings, verified
codebook sa_policy, tab(99)
