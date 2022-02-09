clear all

	* Set the Dropbox Folder
	if      "`c(os)'" == "Windows" global BOX "C:/Users/`c(username)'/Library/CloudStorage/Box-Box/Capstone WB"
	else if "`c(os)'" == "MacOSX"  global BOX "/Users/`c(username)'/Library/CloudStorage/Box-Box/Capstone WB"
	else                           global BOX "/home/`c(username)'/Library/CloudStorage/Box-Box/Capstone WB"

	* Set general project folders
	global	raw			        "$BOX/data/raw"
	global	clean	            "$BOX/data/clean"
	global	output	            "$BOX/output"
	global	dofile			    "$BOX/do-file"

	cd  "$clean"
	use "Main_database_Dec.dta", clear

*****uniform start_date******

* replace missings in start_date
replace start_date = "" if start_date == "n.a."
replace start_date = "" if start_date == "n.s."

* replace different format from start date
replace start_date = "10mar2021" if start_date == "10-Mar-21"
replace start_date = "04mar2020" if start_date == "20.20-03-04"
replace start_date = "19may2020" if start_date == "2020_05=19"
replace start_date = "01apr2020" if start_date == "  4/1/2020"
replace start_date = "14apr2020" if start_date == " 4/14/2020"
replace start_date = "25jun2020" if start_date == " 6/25/2020"
replace start_date = "31apr2020" if start_date == "04/31/2020"

replace start_date = subinstr(start_date,"/01/","jan",.)
replace start_date = subinstr(start_date,"/02/","feb",.)
replace start_date = subinstr(start_date,"/03/","mar",.)
replace start_date = subinstr(start_date,"/04/","apr",.)
replace start_date = subinstr(start_date,"/05/","may",.)
replace start_date = subinstr(start_date,"/06/","jun",.)
replace start_date = subinstr(start_date,"/07/","jul",.)
replace start_date = subinstr(start_date,"/08/","aug",.)
replace start_date = subinstr(start_date,"/09/","sep",.)
replace start_date = subinstr(start_date,"/10/","oct",.)
replace start_date = subinstr(start_date,"/11/","nov",.)
replace start_date = subinstr(start_date,"/12/","dec",.)

*****uniform end_date******

* replace different format from start date
replace end_date = "29jan2021" if end_date == " 1/29/2021"
replace end_date = "12may2021" if end_date == "12-May-21"
replace end_date = "31jun2021" if end_date == "2021-06-31"
replace end_date = "31sep2021" if end_date == "2021-09-31"
replace end_date = "01mar2021" if end_date == "2022-02-30"
///entry error
replace end_date = "30feb2022" if end_date == "4/14/2020"

replace end_date = subinstr(end_date,"/01/","jan",.)
replace end_date = subinstr(end_date,"/02/","feb",.)
replace end_date = subinstr(end_date,"/03/","mar",.)
replace end_date = subinstr(end_date,"/04/","apr",.)
replace end_date = subinstr(end_date,"/05/","may",.)
replace end_date = subinstr(end_date,"/06/","jun",.)
replace end_date = subinstr(end_date,"/07/","jul",.)
replace end_date = subinstr(end_date,"/08/","aug",.)
replace end_date = subinstr(end_date,"/09/","sep",.)
replace end_date = subinstr(end_date,"/10/","oct",.)
replace end_date = subinstr(end_date,"/11/","nov",.)
replace end_date = subinstr(end_date,"/12/","dec",.)

* replace strings 
gen clean_date = regexm(end_date, "https")
replace clean_date = regexm(end_date, "n.")
replace end_date = "" if clean_date == 1

****Figure 1*******

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


****Figure 2*******

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


****Figure 4*******

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
list duration start_date end_date if duration == -6
drop if duration == -6

* check for program lasts less for a month
list duration start_date end_date if duration == 0

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


***********
* Figure 3
***********

preserve
{

keep country_name program_name sa_transfer

duplicates drop

keep if sa_transfer != .

save "$output/figure_3.dta", replace

}
restore

***********
* Figure 8
***********

preserve
{
	
* find non-numeric value
list program_id if ben_plan == "9000000 (per year)"
* C19_ETH_0026

* remove non-numeric factors
replace ben_plan =subinstr(ben_plan,"(per year)","",.)

* convert to numeric
destring ben_plan, replace

* concert per year data
gen new_start_date = date(start_date, "DMY")
gen new_end_date = date(end_date, "DMY")

gen start_year = year(new_start_date)
gen end_year = year(new_end_date)

replace ben_plan = ben_plan * (end_year - start_year) if program_id == "C19_ETH_0026"

* uniform format for ben_actual and ben_plan
replace ben_actual = "22970000" if ben_actual == "22.,970,000"
replace ben_actual = subinstr(ben_actual,"405,000","405000",.)
destring ben_actual, replace

replace ben_plan = "105000" if ben_plan == "1,05,000"
replace ben_plan = "210684" if ben_plan == "2,10,684 "
replace ben_plan = "1325410" if ben_plan == "1325410.38140673"
replace ben_plan = "19840000" if ben_plan == "9839999.999999998"
replace ben_plan = "905076" if ben_plan == "905076.2711864407"
replace ben_plan = "31755147" if ben_plan == "31755147.4"
replace ben_plan = "" if ben_plan == "all households"
destring ben_plan, replace force

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

/********* code for Gavin***********************************

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
*/









