/*******************************************************************************
* File name: Social Assistance Tracker Data Cleaning Do-file
* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu )
* Date created: October 22, 2021
* Description: This file is created to clean dataset for the Social Assistance Tracker.
* Update 1: name, date - "new information/changes"
********************************************************************************/

*=================*
*     Figure 1    *
*=================*

preserve
{

* extract month and year from "start_date"
gen new_start_date = date(start_date, "DMY")
gen month = month(new_start_date)
gen year = year(new_start_date)
/// there is one year as "2002"

* generate culmulative months
gen cum_month = .
  foreach i in month {
	replace cum_month = `i' if year ==  2020
	replace cum_month = 12 +`i' if year == 2021
	}

* create tag to examine data at country or program level
egen tag_measure = tag(program_id)
egen tag_country = tag(country_name)
egen tag_month = tag(cum_month)

* create variables: number of projects/countries by month
bys cum_month: gen num_measure = _N
duplicates drop cum_month country_name, force

* keep one observation each month
bys country_name (cum_month): gen country_rank = _n
keep if country_rank == 1

bys cum_month: gen num_country = _N
duplicates drop cum_month, force

* collapse data
keep cum_month num_country num_measure
drop if cum_month == .

* calculate culmulative numbers of measures and countries
gen cum_num_country = sum(num_country)
gen cum_num_measure = sum(num_measure)

save "$output/figure_1.dta", replace
}

restore


*=================*
*     Figure 2    *
*=================*

preserve
{

* create tag to examine data at region level
egen tag_region = tag(region)
egen tag_country_area = tag(country_name sp_area)

*Create variables: number of projects by region
bys region: gen num_projects = _N

*Create variables, for each area of SP: number of projects/countries by region
encode sp_area, gen(sp_area_code)
bys region sp_area: gen num_projects_area = _N

* keep relevant variables
keep num_projects* region sp_area sp_area_code

* reshape date from long to wide
duplicates drop region sp_area, force
drop if sp_area  == ""
drop sp_area
reshape wide num_projects_area, i(region) j(sp_area_code)
br

* sum for total
egen total_assistance = sum(num_projects_area1)
egen total_insurance = sum(num_projects_area2)
egen total_labor = sum(num_projects_area3)

* calculate the percentage for each column (SP areas)
gen pct_assistance = (num_projects_area1/total_assistance)*100
gen pct_insurance = (num_projects_area2/total_insurance)*100
gen pct_labor = (num_projects_area3/total_labor)*100

drop num* total*
save "$output/figure_2_part1.dta", replace

}
restore


preserve
{
* create tag to examine data at income group level
egen tag_income= tag(income_group)
egen tag_country_area = tag(country_name sp_area)

*Create variables: number of projects by region
bys income_group: gen num_projects = _N

*Create variables, for each area of SP: number of projects/countries by region
encode sp_area, gen(sp_area_code)
bys income_group sp_area: gen num_projects_area = _N  

* keep relevant variables
keep num_projects* income_group sp_area sp_area_code

* reshape date from long to wide
duplicates drop income_group sp_area, force
drop if sp_area  == ""
drop sp_area
reshape wide num_projects_area, i(income_group) j(sp_area_code)

* calculate the percentage for each column (SP areas)
gen pct_assistance = (num_projects_area1/num_projects)*100
gen pct_insurance = (num_projects_area2/num_projects)*100
gen pct_labor = (num_projects_area3/num_projects)*100

drop num* 

* save the dataset
save "$output/figure_2_part2.dta", replace

restore
}


*=================*
*     Table 1     *
*=================*
preserve
{
*Create variables, for each area of SP:  number of projects/countries by
encode sp_category, gen(sp_category_code)

*Create tag if you want to examine data at country level
egen tag_country = tag(country_name)
egen tag_country_category = tag(country_name sp_category)

*Number of projects by area of social protection
bys sp_category: gen N_of_measures = _N
duplicates drop sp_category country_name, force

*Number of projects by country
bys sp_category: gen N_of_countries = _N
duplicates drop sp_category, force

*Restructure the dataframe for table 1
keep N_of_measures N_of_countries sp_category_code 
drop if missing(sp_category_code) 
keep in 1/7

save "$output/table_1.dta", replace
}

restore


*=================*
*     Table 2     *
*=================*

preserve
{
*Create variables, for each area of SP:  number of projects/countries by
encode sp_category, gen(sp_category_code)

*Create tag if you want to examine data at country level
egen tag_country = tag(country_name)
egen tag_country_category = tag(country_name sp_category)

*Number of projects by area of social protection
bys sp_category: gen N_of_measures = _N
duplicates drop sp_category country_name, force

*Number of projects by country
bys sp_category: gen N_of_countries = _N
duplicates drop sp_category, force

*Restructure the dataframe for table 1
keep N_of_measures N_of_countries sp_category_code 
drop if missing(sp_category_code) 
drop in 1/7
keep in 1/5
save "$output/table_2.dta", replace
}
restore

*=================*
*     Table 3     *
*=================*


preserve
{
*Create variables, for each area of SP:  number of projects/countries by
encode sp_category, gen(sp_category_code)

*Create tag if you want to examine data at country level
egen tag_country = tag(country_name)
egen tag_country_category = tag(country_name sp_category)

*Number of projects by area of social protection
bys sp_category: gen N_of_measures = _N
duplicates drop sp_category country_name, force

*Number of projects by country
bys sp_category: gen N_of_countries = _N
duplicates drop sp_category, force

*Restructure the dataframe for table 1
keep N_of_measures N_of_countries sp_category_code 
drop if missing(sp_category_code) 
drop in 1/12

save "$output/table_3.dta", replace
}

restore


*=================*
*     Table 4     *
*=================*

preserve

{
*Generate new variable for each status category
gen Planned  = 0
replace Planned = 1 if status ==  "1. Announced/Planned"
label define PlannedLab 1 "planned"
label values Planned PlannedLab

gen Ongoing = 0
replace Ongoing = 1 if status == "2. Started/Ongoing"
label define OngoingLab 0 "other" 1 "ongoing"
label values Ongoing OngoingLab

gen Ended = 0
replace Ended = 1 if status ==  "3. Ended"
label define EndedLab 0 "other" 1 "ended"
label values Ended EndedLab

*Create variables, for each area of sp_category	
encode sp_category, gen(sp_category_code)

*create count for projects by status 

collapse (sum) Planned Ongoing Ended, by(sp_category_code)

*Restructure the dataframe for table 4
keep sp_category_code Planned Ongoing Ended
drop if missing(sp_category_code) 
keep in 1/7

egen Total_known_prog_status = rowtotal(Planned Ongoing Ended)

save "$output/table_4a.dta", replace
}

restore

*additional columns added 

preserve
{
encode sp_category, gen(sp_category_code)

*creating subtotal within each category
bys sp_category: gen Total_measures = _N
duplicates drop sp_cat*, force

keep sp_category_code Total_measures
drop if missing(sp_category_code) 
keep in 1/7
save "$output/table_4b.dta", replace

*merging dataset 4a and 4b
use "$output/Table_4a.dta"

merge 1:1 sp_category_code using "$output/Table_4b.dta"

drop _merge
gen pct_measures_knownprog_status = (Total_known_prog_status/Total_measures) * 100

save "$output/Table_4.dta", replace

}
restore


*=================*
*     Figure 3    *
*=================*

preserve
{

keep country_name program_name sa_transfer

duplicates drop

keep if sa_transfer != .

replace program_name = "" if country_name == "Uzbekistan"

save "$output/figure_3.dta", replace

}
restore


*=================*
*     Table 5     *
*=================*

*generate table for cash transfers, use data again as the merge function disrupts the preserve/restore function

use "$cleaned/cleaned_main_database_Dec", clear

preserve

{
*Generate new variable for each status category

encode sp_category, gen(sp_category_code)
encode sa_policy_adap, gen(sa_policy_adap_code)
*new category for cash transfers only
gen cash_transfer = 0
replace cash_transfer = 1 if sp_category_code == 1
replace cash_transfer = 1 if sp_category_code == 2

bys sa_policy_adap: gen N_of_Programs = _N 


egen tag_country = tag(country_name)
egen tag_country_policy = tag(country_name sa_policy_adap)
duplicates drop sa_policy_adap country_name, force

bys sa_policy_adap: gen N_of_countries = _N 

duplicates drop sa_policy_adap, force
br sa_policy_adap N_of_Programs N_of_countries

*Restructure the dataframe for table 5
keep sa_policy_adap N_of_Programs N_of_countries cash_transfer
*drop if cash_transfer == 0
drop if missing(sa_policy_adap) 

keep sa_policy_adap N_of_Programs N_of_countries 
*keep in 1/7

save "$output/table_5a.dta", replace
}

restore

*generate table for Public works same as above if asked //


*=================*
*     Figure 4    *
*=================*

preserve
{

* generate duration
gen new_start_date = date(start_date, "DMY")
gen new_end_date = date(end_date, "DMY")

gen start_month = month(new_start_date)
gen end_month = month(new_end_date)

gen duration = end_month - start_month
label var duration "duration in month"

* check for entry error and remove invalid values
drop if duration < 0

* select cash trasder program in sp_category
encode sp_category, gen(sp_category_code)
drop if sp_category_code != 1 & sp_category_code != 2

* create tag to examine data at month level
egen tag_duration = tag(duration)

*Create variables: number of projects by region
bys duration: gen num_projects = _N
duplicates drop duration num_projects, force

* keep relevant variables for reshape
keep duration sp_category_code num_projects

save "$output/figure_4.dta", replace

}
restore


*=================*
*     Figure 5    *
*=================*

preserve
{

* create population_filled to provide matching variables
keep country_name population
drop if population == ""
duplicates drop country_name, force
ren population population_filled
tempfile tt
save `tt'

use "$cleaned/cleaned_main_database_Dec", clear
 
merge m:1 country_name using `tt'
br population population_filled country_name 
br 

*destring population & create sa_app "Social Assistance actual population percentage"
gen population_filled_n = real(population_filled)
format population_filled_n %10.0g 
*destring Policy Adaptations
*encode sa_policy_adap, generate(sa_policy_adap) //duplicate

*cleaning sa_policy_adap

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

*encode population_filled, generate(population_filled2)
**sa_app:Social Assistance_Actual Population Percentage
gen ben_actual_n = ben_actual
gen sa_app = (ben_actual_n/population_filled_n)*100
gsort -sa_app 
encode sp_category, gen(sp_category_code)
*drop if sp_category_code != 1 & sp_category_code != 2

**sa_app:Social Assistance_Planned Population Percentage
gen ben_plan_n = ben_plan
gen sa_ppp = (ben_plan_n/population_filled_n)*100
gsort -sa_ppp 
drop if sa_app == .

*titling variables 
encode sp_area, generate(sp_area2) // duplicate
*drop if sp_area2 !=1 // elimintates large pension plan

*cleaning sa_policy_adap2

*replace program_name = sa_policy_adap if program_name == ""
replace program_name = sa_policy if program_name == ""
keep program_id country_name program_name sa_app sa_ppp
keep in 1/50

replace program_name = "Special Regime for Small and Micro Enterprises" if program_name == "Special Regime for Small and Micro Enterprises, Special Regime for Small and Micro Enterprises (REMPE)"

save "$output/figure_5.dta", replace

}
restore


*=================*
*     Table 6     *
*=================*

preserve
{

*New Variables
*NV 2.1.1
gen ben_plan_n = ben_plan

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

tabstat ben_plan_n if vert_dum == 1 | hori_dum == 1, statistics(sum) format(%12.0f)
//tabstat ben_plan_n if vert_dum == 1 & cash_tra_dum == 1 | hori_dum == 1 & cash_tra_dum == 1 , statistics(sum) format(%12.0f)

egen T2 = sum(ben_plan_n) if vert_dum == 1 | hori_dum==1
*----------------------------
**2.2.3 "Planned number of individuals" by "Cash transfer beneficiaries covered"


tabstat ben_plan_n if hori_dum == 1, statistics(sum) format(%12.0fc)
//tabstat ben_plan_n if vert_dum!=1, statistics(sum) format(%12.0fc)
//tabstat ben_plan_n if vert_dum == 1 & cash_tra_dum = 1, statistics(sum) format(%12.0fc)

egen T3 = sum(ben_plan_n) if hori_dum == 1

*----------------------------
*2.2.4 "Actual number of individuals" by "Social assistance beneficiaries//
//that benefit from more coverage or more generous transfers"

tabstat ben_actual, statistics(sum) format(%12.0fc)

egen T4 = sum(ben_actual)

*----------------------------
*2.2.5 "Actual number of individuals" by "Cash transfer beneficiaries//
//that benefit from more coverage or more generous transfers"
*Problem - less than original report

tabstat ben_actual if vert_dum == 1 | hori_dum == 1, statistics(sum) format(%12.0fc)

egen T5 = sum(ben_actual) if vert_dum == 1 | hori_dum == 1

*----------------------------
*2.2.6 "Actual number of individuals" by "Cash transfer beneficiaries covered"
*PROBLEM - less than original report

tabstat ben_actual if hori_dum == 1, statistics(sum) format(%12.0fc)

egen T6 = sum(ben_actual) if hori_dum == 1

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

gen j = _n
replace j = 0 if j<=3
replace j = 1 if j>=4

drop position 

*reshape wide stub, i(y) j(j)
reshape wide ben_totals ben_percent, i(y) j(j)

label define ylab 1 "Social assistance beneficiaries that benefit from more coverage or more generous transfers" 2 "Cash transfer beneficiaries that benefit from more coverage or more generous transfers" 3 "Cash transfer beneficiaries covered"
label values y ylab

save "$output/table_6.dta", replace

}
restore


*=================*
*     Figure 6    *
*=================*

preserve
{

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
replace sa_policy = "10. One-off (universal)"     if sa_policy_adap10 == 1
replace sa_policy = "11. Multiple payments (universal)"  if sa_policy_adap11 == 1
replace sa_policy = "12. Multiple payments (targeted)"   if sa_policy_adap12 == 1
replace sa_policy = "13. Not applicable"                 if sa_policy_adap13 == 1

* use codebook to see encoded strings, verified
codebook sa_policy, tab(99)

encode sp_area, generate(sp_area2) // duplicate

//test
br country_name ben_actual sa_policy_adap program_name 
gsort -ben_actual 
drop if sp_area2 !=1 // elimintates large pension plan
replace program_name = sa_policy if program_name == ""

keep country_name ben_actual program_name    
keep in 1/10

replace program_name = "Pradhan Mantri Jan Dhan Yojana (PMJDY)" if program_name == "Pradhan Mantri Jan Dhan Yojana (PMJDY), Pradhan Mantri Garib Kalyan Yojana -- cash assistance to Pradhan Mantri Jan Dhan Yojana (PMJDY) women account holders"

replace program_name = "Pradhan Mantri Kisan Samman Nidhi (PM-Kisan)" if program_name == "Pradhan Mantri Kisan Samman Nidhi (PM-Kisan)-- Pradhan Mantri Garib Kalyan Yojana Package"

save "$output/figure_6.dta", replace

}
restore

*=================*
*     Figure 7    *
*=================*

preserve
{

*create population_filled to provide matching variables
keep country_name population
drop if population == ""
duplicates drop country_name, force
ren population population_filled
tempfile tt
save `tt'

use "$cleaned/cleaned_main_database_Dec", clear
 
merge m:1 country_name using `tt'
br population population_filled country_name 
br 

*destring population & create sa_app "Social Assistance actual population percentage"
gen population_filled_n = real(population_filled)

*destring Policy Adaptations
encode sa_policy_adap, generate(sa_policy_adap2) //duplicate

*encode population_filled, generate(population_filled2)
**sa_app:Social Assistance_Actual Population Percentage
gen ben_actual_n = ben_actual
gen sa_app = (ben_actual_n/population_filled_n)*100
gsort -sa_app 
encode sp_category, gen(sp_category_code)
drop if sp_category_code != 1 & sp_category_code != 2

//Quality Check
br program_id country_name sa_app sa_policy_adap2 population_filled_n ben_actual sp_category_code

//Data Isolation
keep   country_name sa_app sa_policy_adap2       
keep in 1/10

gen sa_policy_adap = ""
replace sa_policy_adap = "universal one-off" if sa_policy_adap2 == 7
replace sa_policy_adap = "universal multiple payments" if sa_policy_adap2 == 9
replace sa_policy_adap = "targeted one-off" if sa_policy_adap2 == 6
replace sa_policy_adap = "horizental & vertical" if sa_policy_adap2 == 10

save "$output/figure_7.dta", replace
 
}
restore


*=================*
*     Figure 8    *
*=================*

preserve
{
	
* find non-numeric value
* list program_id if ben_plan == "9000000 (per year)"
* C19_ETH_0026

* remove non-numeric factors
* replace ben_plan =subinstr(ben_plan,"(per year)","",.)

* convert to numeric
* destring ben_plan, replace ///change b/c dataset change

* concert per year data
gen new_start_date = date(start_date, "DMY")
gen new_end_date = date(end_date, "DMY")

gen start_year = year(new_start_date)
gen end_year = year(new_end_date)

replace ben_plan = ben_plan * (end_year - start_year) if program_id == "C19_ETH_0026"

* calculate the scale_up size
gen rate_scaleup = ((ben_actual - ben_plan)/ben_plan) * 100

* remove outliers
drop if rate_scaleup <= 0 | rate_scaleup > 1000

* sort in descending order
gsort -rate_scaleup

* keep relavant data
keep country_name rate_scaleup
keep in 1/15

* save the dataset
save "$output/figure_8.dta", replace

}
restore


*=================*
*     Table 7     *
*=================*

preserve

{
encode sp_area , gen(sp_area_code)
encode income_group, gen (inc_grp_code)

*generate numeric value for planed expenditure
gen exp_plan_num_usd = real(exp_plan_usd)

*collapse (sum) exp_plan_usd if sp_area_code == 1, by(inc_grp_code)
collapse (sum) exp_plan_num_usd, by(inc_grp_code sp_area_code)

drop if missing(sp_area_code) 

reshape wide exp_plan_num_usd, i(inc_grp_code) j(sp_area_code)

egen total_expenditure = rowtotal(exp_plan_num_usd1 exp_plan_num_usd2 exp_plan_num_usd3)
format total_expenditure %12.0fc

save "$output/Table_7a.dta", replace
}

restore

preserve
{
encode income_group, gen (inc_grp_code)

*to collapse population by income group by population 
keep country_name income_group inc_grp_code population
drop if population == ""

*dropping the duplicate countries, to get one population variable per country
duplicates drop country_name, force
rename population population_inc

*numeric value and generating missing values
gen population_inc_num = real(population_inc)

*collpsing data by income group
collapse (sum) population_inc_num, by(inc_grp_code)

save "$output/Table_7b.dta", replace

*merging dataset 7a and 7b

use "$output/Table_7a.dta"

merge 1:1 inc_grp_code using "$output/Table_7b.dta"

drop _merge
gen expenditure_per_capita = total_expenditure/population_inc_num

save "$output/Table_7.dta", replace

}
restore
//can generate same table for Spending by social protection component by region replacing income_group with region


*===========================================*
*    Table 8 Urban and Rural CT programs 	*
*===========================================*

*use of main dataset here again as the merge function disables previous pres/restore function

preserve
{

encode sa_loc, gen(sa_loc_code)
keep sa_loc* region 

*generating new dummies for sa_loc_code

gen rural_only = 0
replace rural_only = 1 if sa_loc_code ==  1
label define Ruralab 1 "Rural only"
label values rural_only Ruralab

gen urban_only = 0
replace urban_only = 1 if sa_loc_code ==  2
label define Urbanlab 1 "Urban and periurban only"
label values urban_only Urbanlab

gen Rural_and_Urban = 0
replace Rural_and_Urban = 1 if sa_loc_code ==  3
label define Rurbanlab 1 "Rural and Urban"
label values Rural_and_Urban Rurbanlab

collapse (sum) rural_only urban_only Rural_and_Urban, by(region)
//need to add column total at the bottom of each variable in R

save "$output/Table_8.dta", replace

}

restore


*=======================================*
*   Table 9 For pie chart For sp area   *
*=======================================*

preserve

{
*to collapse population by income group by population 
keep sp_area 
encode sp_area, gen (sp_area_code)

*counting no of measures for each area
egen tag_sp_area = tag(sp_area)
bys sp_area: gen N_of_measures = _N

duplicates drop sp_area, force

egen total_measure = sum(N_of_measures)
gen measure_fraction = (N_of_measures/total_measure) * 100

keep sp_area N_of_measures measure_fraction

save "$output/Table_9.dta", replace

}
restore

