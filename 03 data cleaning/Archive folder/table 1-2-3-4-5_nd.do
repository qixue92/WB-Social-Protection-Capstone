*Date:11/05/2021
*Author: Neha Dagaonkar
*this do file is for table 1, 2, 3 for the dataset

*use"$clean/Main_database_Dec.dta", replace

/* master:

* Set the Dropbox Folder
	if      "`c(os)'" == "Windows" global BOX "C:/Users/`c(username)'/Box/Capstone WB"
	else if "`c(os)'" == "MacOSX"  global BOX "/Users/`c(username)'/Box/Capstone WB"
	else                           global BOX "/home/`c(username)'/Box/Capstone WB"

	* Set general project folders
	global	raw			        "$BOX/data/raw"
	global	clean	            "$BOX/data/clean"
	global	output	            "$BOX/output"
	global	dofile			    "$BOX/do-file"

local today : display %dCY-N-D date(c(current_date), "DMY")
	display 	"`today'"
	
cd 	"$dofile"


use "$clean/Main_database_Dec", clear


*/
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
				Table 1
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

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

save "$BOX/output/table_1.dta", replace
}

restore


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
				Table 2
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

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
save "$BOX/output/table_2.dta", replace
}
restore

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
				Table 3
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

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

save "$BOX/output/table_3.dta", replace
}

restore

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
								Table 4
		Status of SA measure (only for measures we found information online)
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

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

save "$BOX/output/table_4a.dta", replace
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
save "$BOX/output/table_4b.dta", replace
}

restore

*merging dataset 4a and 4b

use "$BOX/output/Table_4a.dta"

merge 1:1 sp_category_code using "$BOX/output/Table_4b.dta"

drop _merge
gen pct_measures_knownprog_status = (Total_known_prog_status/Total_measures) * 100

save "$BOX/output/Table_4.dta", replace

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
				Table 5
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*


*generate table for cash transfers
use "$clean/Main_database_Dec", clear

preserve

{
*Generate new variable for each status category

encode sp_category, gen(sp_category_code)
encode sa_policy_adap, gen(sa_policy_adap_code)
*new category for cash transfers only
gen cash_transfer = 0
replace cash_transfer = 1 if sp_category_code == 1
replace cash_transfer = 1 if sp_category_code == 2

bys sa_policy_adap: gen N_of_Programs = _N if cash_transfer == 1


egen tag_country = tag(country_name)
egen tag_country_policy = tag(country_name sa_policy_adap)
duplicates drop sa_policy_adap country_name, force

bys sa_policy_adap: gen N_of_countries = _N if cash_transfer ==1

duplicates drop sa_policy_adap, force
br sa_policy_adap N_of_Programs N_of_countries

*Restructure the dataframe for table 5
keep sa_policy_adap N_of_Programs N_of_countries sp_category_code cash_transfer
drop if cash_transfer == 0
drop if missing(sa_policy_adap) 

keep sa_policy_adap N_of_Programs N_of_countries sp_category_code 
*keep in 1/7

save "$BOX/output/table_5a.dta", replace
}

restore

*generate table for Public works same as above if asked //


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	Table 7 Spending by social protection component, country income group (USD)
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

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

save "$BOX/output/Table_7a.dta", replace
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

save "$BOX/output/Table_7b.dta", replace
}

restore

*merging dataset 7a and 7b

use "$BOX/output/Table_7a.dta"

merge 1:1 inc_grp_code using "$BOX/output/Table_7b.dta"

drop _merge
gen expenditure_per_capita = total_expenditure/population_inc_num

save "$BOX/output/Table_7.dta", replace

//can generate same table for Spending by social protection component by region replacing income_group with region

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	Table 8 Urban and Rural CT programs
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

*use of main dataset here again as the merge function disables previous pres/restore function

use "$clean/Main_database_Dec", clear


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

save "$BOX/output/Table_8.dta", replace

}

restore

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	Table FY21 List of Fragile &
	Conflict-affected Situations
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
preserve

{

encode country_name, gen(country_numcode)
encode sp_area, gen(sp_area_code)


*create new variable for fragile and conflict affected states

gen High_Intensity_conflicts = 0
replace High_Intensity_conflicts = 1 if country_numcode  ==  1 
replace High_Intensity_conflicts = 1 if country_numcode  ==  117
replace High_Intensity_conflicts = 1 if country_numcode  == 182
replace High_Intensity_conflicts = 1 if country_numcode  ==  194


gen Med_Intensity_conflicts = 0
replace Med_Intensity_conflicts = 1 if country_numcode  == 32
replace Med_Intensity_conflicts = 1 if country_numcode  == 35
replace Med_Intensity_conflicts = 1 if country_numcode  == 40
replace Med_Intensity_conflicts = 1 if country_numcode  == 41
replace Med_Intensity_conflicts = 1 if country_numcode  == 46
replace Med_Intensity_conflicts = 1 if country_numcode  == 96
replace Med_Intensity_conflicts = 1 if country_numcode  == 126
replace Med_Intensity_conflicts = 1 if country_numcode  == 139
replace Med_Intensity_conflicts = 1 if country_numcode  == 140
replace Med_Intensity_conflicts = 1 if country_numcode  == 147
replace Med_Intensity_conflicts = 1 if country_numcode  == 148
replace Med_Intensity_conflicts = 1 if country_numcode  == 184
replace Med_Intensity_conflicts = 1 if country_numcode  == 221

gen High_Inst_Soc_Fragility = 0
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 33
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 45
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 47
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 64
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 74
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 86
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 88
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 107
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 109
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 112
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 114
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 116
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 128
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 132
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 156
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 181
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 190
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 200
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 208
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 217
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 220
replace High_Inst_Soc_Fragility = 1 if country_numcode  == 223

*Generate area for projects by status 
gen SA_Measures = 0
replace SA_Measures = 1 if sp_area_code  == 1

gen SI_Measures = 0
replace SI_Measures = 1 if sp_area_code  == 2

gen LM_Measures = 0
replace LM_Measures = 1 if sp_area_code  == 3


keep country_numcode High_Intensity_conflicts SA_Measures SI_Measure LM_Measures






*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
	Table 9 For pie chart For sp area
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

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

save "$BOX/output/Table_9.dta", replace

}
restore



