/*******************************************************************************
* File name: Summary Stats for Project-Level Data

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Feb 17, 2022
* Description: This file is created to summarize project-level data of the informal
			   sector.

* Update 1: add labels, Feb 20 - "complete labels for a few variables" 
* Update 2: apply new dataset, Feb 22- "apply merged dataset"
********************************************************************************/


********************************************************************************
*                   ===================================
*   			               Globals Set-Up
*                   ===================================
********************************************************************************
 	
	drop	 _all
	clear	 all
	cls
	capture log close
	set more off
	set		 varabbrev on   
	set 	 memory  900m
	
	* Set the Dropbox Folder
	if      "`c(os)'" == "Windows" global root "C:/Users/`c(username)'/Documents/GitHub/WB-Social-Protection-Capstone"
	else if "`c(os)'" == "MacOSX"  global root "/Users/`c(username)'/Documents/GitHub/WB-Social-Protection-Capstone"
	else                           global root "/home/`c(username)'/Documents/GitHub/WB-Social-Protection-Capstone"

	* Set general project folders
	global	raw			        "$root/02 raw data/raw"
	global	imported	        "$root/02 raw data/imported"
	global	output	            "$root/04 output"
	global	cleaning			"$root/03 data cleaning"
	global  cleaned             "$root/05 clean data"
	global  tables_informal     "$root/04 output/tables_informal data"
	global  tables_full         "$root/04 output/tables_merged full datat"
	
	* using log
	log using "$output/research/Project-level summary stat using informal dataset.smcl", replace
	*log using "$output/research/Project-level summary stat using merged full dataset.smcl", replace
	
	* using data
	use "$cleaned/1-Informal Sector Worker.dta"
	*use "$cleaned/3-Filtered Informal Projects.dta", clear
	
	
********************************************************************************
*                   ===================================
*   			               Summary Stats
*                   ===================================
********************************************************************************
	
* =======================================================
* Summary characteristics of informal targeted programs *
* =======================================================
	
	* =====================
	* 1_General Information
	* =====================
	
	* region
		
		* rename sublabels
		replace region = "East Asia & Pacific" if region == "EAS"
		replace region = "Europe & Central Asia" if region == "ECS"
		replace region = "Latin America & Caribbean" if region == "LCN"
		replace region = "Middle East & North Africa" if region == "MEA"
		replace region = "North America" if region == "NAC"
		replace region = "South Asia" if region == "SAS"
		replace region = "Sub-Saharan Africa" if region == "SSF"
		
		* tab region
		tab region, missing

			* export table
			asdoc tab region, save(region.doc) replace
	
	* hhsize
	sum hhsize, detail
	
			* export table
			asdoc sum hhsize, save(hhsize.doc) replace
	
	* sp_sub_category
	tab sp_sub_category, missing
	
			* export table
			asdoc tab sp_sub_category, save(sp_sub_category) replace
	
	* updated_status
	replace updated_status = status if missing(updated_status)
	tab updated_status, missing
			
			* export table
			asdoc tab updated_status, save(updated_status) replace
			
	* informal
	rename Column3 informal_type
	tab informal_type, missing
			
			* export table
			asdoc tab informal_type, save(informal_type) replace			
	
* =====*
* Binary
* =====*

	* benefit_new
	tab benefit_new, missing
	
			* export table
			asdoc tab benefit_new, save(binary_stat.doc) replace			
	
	* household or individual
	tab ben_unit_plan, missing
	
			* export table
			asdoc tab ben_unit_plan, save(binary_stat.doc) append
	
	* benefit temp or one-off
	tab benefit_temp, missing
	
		* correctly wrongly coded var
		replace benefit_temp = "4. Temporary to Permanent" if benefit_temp == "3. Temporary to Permanent"
		
		* generate dummy var for all subcategories
		forvalues v = 1/4 {
			gen benefit_temp_`v' = regexm(benefit_temp, "`v'") == 1	
			}
		
		* label newly created dummy variables
		label var benefit_temp_1 "1.One-off"
		label var benefit_temp_2 "2.Temporary (not one-off)"
		label var benefit_temp_3 "3.Permanent"
		label var benefit_temp_4 "4.Temporary to Permanent"
		
		* summarize subcategories (including repetitives)
		fsum benefit_temp_*, label
		
	*** financing_source
		
		* Initial tab - finding which program used multiple financing sources
		tab financing_source, missing
		
		* generate dummy var for all subcategories
		forvalues v = 1/4 {
			gen financing_source_`v' = regexm(financing_source, "`v'") == 1	
			}
	
		* label newly created dummy variables
		label var financing_source_1 "1.Public"
		label var financing_source_2 "2.Private"
		label var financing_source_3 "3.Social security"
		label var financing_source_4 "4.International"
		
		* summarize subcategories (including repetitives)
		fsum financing_source_*, label
	
	/* policy_Objective
	rename Policy_Objective policy_objective
	tab policy_objective, m
	* not much valuable info */
	
	* ====================
	* 2_Social Assistance
	* ====================
	
	* sa_policy_adap
	tab sa_policy_adap, missing
		* gen new var to reduce dimensions of measuring
		gen expansion_type = ""
		replace expansion_type = "Vertical" if strmatch(sa_policy_adap, "*Vertical*")
		replace expansion_type = "Horizontal" if strmatch(sa_policy_adap, "*Horizontal*")
		
		* export table
		asdoc tab sa_policy_adap, save(sa_policy_adap.doc) replace
	
	* tab expansion type
	tab expansion_type, missing
	
		* export table
		asdoc tab expansion_type, save(expansion_type.doc) replace
	
	* rural vs urban
	tab sa_location, missing
		
		* export table
		asdoc tab sa_location, save(sa_location.doc) replace
	
	* benefit type
	tab sa_b_type, missing
	
		* export table
		asdoc tab sa_b_type, save(sa_b_type.doc) replace
	
	*** indentification_instruments
		
		* Initial tab - finding which program used multiple targeting methods
		tab identification_instruments, missing
		
		* generate dummy var for all subcategories
		forvalues v = 1/7 {
			gen identification_instruments_`v' = regexm(identification_instruments, "`v'") == 1	
			}
			
		* label newly created dummy variables
		label var identification_instruments_1 "1.Social registry"
		label var identification_instruments_2 "2.Existing beneficiary database"
		label var identification_instruments_3 "3.Civil registry"
		label var identification_instruments_4 "4.Other government registry"
		label var identification_instruments_5 "5.Informal workers/self-employed registry"
		label var identification_instruments_6 "6.Open registraion/new enrolment campaign"
		label var identification_instruments_7 "7.Others"
		
		* summarize subcategories (including repetitives)
		fsum identification_instruments_*, label
		
	*** targeting method
		
		* replace website input as missing
		replace sa_targ_method = "" if strmatch(sa_targ_method, "*https*")
		
		* Initial tab - finding which program used multiple targeting methods
		tab sa_targ_method, missing
		
		* generate dummy var for all subcategories
		forvalues v = 0/8 {
			gen sa_targ_method_`v' = regexm(sa_targ_method, "`v'") == 1	
			}
		
		* label newly created dummy variables
		label var sa_targ_method_0 "0.Universal"
		label var sa_targ_method_1 "1.Geographical"
		label var sa_targ_method_2 "2.Categorical"
		label var sa_targ_method_3 "3.Community-based"
		label var sa_targ_method_4 "4.Means/income"
		label var sa_targ_method_5 "5.Proxy-means test"
		label var sa_targ_method_6 "6.Self-targeting"
		label var sa_targ_method_7 "7.Pension-tested"
		label var sa_targ_method_8 "8.Other"
		
		* summarize subcategories (including repetitives)
		fsum sa_targ_method_*, label
	
	*** targeting groups
	
		* generate dummy var for all subcategories
		forvalues v = 0/28 {
			gen sa_targ_group_`v' = regexm(sa_targ_group, "`v.'") == 1	
			}
		
		* label newly created dummy variables
		label var sa_targ_group_0 "0.All/entire population"
		label var sa_targ_group_1 "1.Children (under 15)"
		label var sa_targ_group_2 "2.Youth (16-25)"
		label var sa_targ_group_3 "3.Adults (18 plus)"
		label var sa_targ_group_4 "4.Working age (16-64)"
		label var sa_targ_group_5 "5.Elderly (65 plus)"
		label var sa_targ_group_6 "6.Families"
		label var sa_targ_group_7 "7.Parents (all)"
		label var sa_targ_group_8 "8.Parents (of young children)"
		label var sa_targ_group_9 "9. Women (all)"
		label var sa_targ_group_10 "10. Women (pregnant, lactating or with children)"
		label var sa_targ_group_11 "11.Men"
		label var sa_targ_group_12 "12. Indigenous"
		label var sa_targ_group_13 "13.Disabled"
		label var sa_targ_group_14 "14.Migrants"
		label var sa_targ_group_15 "15.COVID-19 risk group"
		label var sa_targ_group_16 "16.Homeless"
		label var sa_targ_group_17 "17.Frontline workers"
		label var sa_targ_group_18 "18.Cross-border commuters"
		label var sa_targ_group_19 "19.Veterants"
		label var sa_targ_group_20 "20.Unemployed"
		label var sa_targ_group_21 "21.All employment"
		label var sa_targ_group_22 "22.Wage emplyment"
		label var sa_targ_group_23 "23.Self-employed"
		label var sa_targ_group_24 "24.Informal sector workers"
		label var sa_targ_group_25 "25.Workers in non-standard form of employment"
		label var sa_targ_group_26 "26.Students"
		label var sa_targ_group_27 "27.Poor and vulnerable"
		label var sa_targ_group_28 "28.Other"
		
		* summarize subcategories (including repetitives)
		fsum sa_targ_group_*, label

	*** payment mechanisam
	
		* generate dummy var for all sub-categories
		forvalues v = 1/5 {
			gen sa_payment_mecha_`v' = regexm(sa_payment_mecha, "`v'") == 1
			}
		
		* label newly created dummy variables
		label var sa_payment_mecha_1 "1.Fully functional account"
		label var sa_payment_mecha_2 "2.Limited purpose account"
		label var sa_payment_mecha_3 "3.Electronic non-account based"
		label var sa_payment_mecha_4 "4.Check or voucher"
		label var sa_payment_mecha_5 "5.Cash"
		
		* summarize subcategories (including repetitives)
		fsum sa_payment_mecha_*, label

	*** payment instruments
		* generate dummy var for all sub-categories
		forvalues v = 1/6 {
			gen sa_payment_instruments_`v' = regexm(sa_payment_instruments, "`v'")	== 1
			}
			
		* summarize subcategories (including repetitives)
		label var sa_payment_instruments_1 "1.Debit card (general purpose)"
		label var sa_payment_instruments_2 "2.Prepaid or program card (limited purpose)"
		label var sa_payment_instruments_3 "3.E-wallet or mobile banking"
		label var sa_payment_instruments_4 "4.Unique-cose based payment or OTP"
		label var sa_payment_instruments_5 "5.Biometric"
		label var sa_payment_instruments_6 "6.Other"
		
		* summarize subcategories (including repetitives)
		fsum sa_payment_instruments_*, label
			
* ================================================
* Ranking country program & name by program size *
* ================================================
	
	* replace long/irrgular program name
	replace program_name = "Aide exceptionnelle de 200 dinars" if strmatch(program_name, "*dinars*")
	replace program_name = "Bihar's Corona Sahayata (Assistance) Program" if strmatch(program_name, "*SAHAYATA*")
	
	* ===========================
	* 1) Number of beneficiaries
	* ===========================
	
	* note that ben_plan & ben_actual need to combine with units to interpretate
	destring ben_plan, replace force
		label var ben_plan "Number of planned beneficiaries (either individual or household)"
	
	destring ben_actual, replace force
		label var ben_plan "Number of actual beneficiaries (either individual or household)"
		
	* ben_ind_plan & ben_ind_actual reflect the converted numbers of beneficiaries
	destring ben_ind_plan, replace force
		label var ben_ind_plan "Beneficiaries planned (ind) (converting hhs into individuals) CALCULATED VARIABLE"
		
		gsort -ben_ind_plan
		list country_name program_name ben_ind_plan in 1/15 if !missing(ben_ind_plan), table

	
	destring ben_ind_actual, replace force
		label var ben_ind_actual "Beneficiaries actual (ind) (converting hhs into individuals) CALCULATED VARIABLE"
		
		gsort -ben_ind_actual
		list country_name program_name ben_ind_actual in 1/15 if !missing(ben_ind_plan), table
	
	/* actual coverage - how different from ben_ind_actual?
	gsort -acualcoverage
	list country_name program_name acualcoverage in -15/-1 if !missing(ben_plan), table*/
	
	* ==========================
	* 2) Amount of expenditures
	* ==========================
	
	* exp_plan_USD
	destring exp_plan_usd, replace
		label var exp_plan_usd "Total expenditure (planned) in USD"
	
		gsort -exp_plan_usd
		list country_name program_name exp_plan_usd in 1/15 if !missing(exp_plan_usd), table
	
	* exp_actual_USD
	destring exp_actual_usd, replace
		label var exp_actual_usd "Total expenditure (actual) in USD"
		
		gsort -exp_actual_usd
		list country_name program_name exp_actual_usd in 1/15 if !missing(exp_actual_usd), table
		
	/* benefit amount in local currencies
	gsort -sa_b_amount_l
	list country_name program_name acualcoverage in 1/15 if !missing(ben_plan), table*/
	
********************************************************************************
*                   ===================================
*   			               Close Log
*                   ===================================
********************************************************************************	

	* save merged dataset
	*save "$cleaned/4.1-merged_project-level data.dta", replace
		*notes: project-level data using merged dataset
		
	save "$cleaned/4.2-merged_project-level data.dta", replace
		notes: project-level data using informal data only
	
	* close log
	log close
	
	