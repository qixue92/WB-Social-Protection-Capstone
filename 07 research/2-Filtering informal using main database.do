/*******************************************************************************
* File name: Social Protection for the Informal Section

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Jan 28, 2022
* Description: This file is created to filter the main dataset with regard to programs targeted informal sector.

* Update 1: change dataset, Mar 03 - "switch from merged data to main data" 
* Update 2: add new do-file, Dec 11- "add clean var do-file"
********************************************************************************/


********************************************************************************
*                   ===================================
*   			               BOX Globals
*                   ===================================
********************************************************************************
 	
	drop	 _all
	clear	 all
	capture  log close
	cls
	set more off
	set		 varabbrev off   
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

	* using log
	log using "$output/research/Filtering informal using main database.smcl", replace
	
********************************************************************************
*                   =====================================
*   			                 Data Filtering
*                   =====================================
********************************************************************************

*	=================
*	1) Use clean data
*	=================

    use "$cleaned/cleaned_main_database_Dec.dta", clear
	
*   ===============================
*	2) Remove high-income countries
*	===============================
	
	* remove high-income countries
	drop if income_group == "HIC"

*	=======================================
*	3) Filter data with the informal sector
*	=======================================
	
	* target groups
	gen informal_targ = 0
	foreach var in sa_targ_group si_targ_group lm_targ_group {
		replace informal_targ = 1 if regexm(`var', "23")
	}
	
	* informal mentioned in the description
	gen informal_desc = 0
	foreach var in benefit_desc benefit_desc_changes {
		replace informal_desc = 1 if regexm(`var', "informal") | regexm(`var', "Informal") 
	}
	
	* destring original var called informal 
	gen informal_new = 0
		replace informal_new = 1 if informal == "1. Yes"
		
	* label newly created filters
	label var informal_targ "targeted informal sector group"
	label var informal_desc "informal mentioned in description"
	label var informal_new "imported informal category"
	
	* explore data
	tab informal_new informal_desc
	tab informal_new informal_targ
	tab informal_desc informal_targ
	
	* explore the dataset
	count if informal_desc == 1
	count if informal_targ == 1
	count if informal_new == 1
	
	count if informal_targ == 1 | informal_desc == 1
	count if informal_targ == 1 | informal_desc == 1 | informal_new == 1
	
	* keep data marked with informal
	keep if informal_targ == 1 | informal_desc == 1 | informal_new == 1
	
*   ================================================================
*	4) exclude programs that are not targeted at the informal sector
*	================================================================
	
	* drop programs for below categories
	drop if sp_category == "1.7. Utility and financial obligations waivers/reductions"
	drop if sp_category == "2.1. Pensions"
	drop if sp_category == "2.2. Social security contributions"
	drop if sp_category == "3.7. Labor regulatory adjustment and enforcement"
	
*   ===================
*	5) sliming datasets
*	===================
	
	* drop variables there are no data entry
	foreach var of varlist _all {
		capture assert mi(`var')
		if !_rc {
        drop `var'
		}
	 }
	
	* export to temp data for manual selection
	 save "intermediate data filtering.dta", replace
	
********************************************************************************
*                   =====================================
*   	                    Manually Filtering Data
*                   =====================================
********************************************************************************

	* drop duplicated programs with different program_id
	drop if program_id == "C19_PRY_0004"
	
	* drop if programs are not identified as informal through manual selection
	drop if program_id == "C19_ARG_0004" //child allowance
	drop if program_id == "C19_ARG_0008" //child allowance
	drop if program_id == "C19_ARM_0027" //parents who are jobless
	drop if program_id == "C19_IDN_0014" //safety
	drop if program_id == "C19_MDA_0003" //unemployment aid
	drop if program_id == "C19_BLZ_0040" //unemployment relief
	drop if program_id == "C19_THA_0098" //labor training
	drop if program_id == "C19_JOR_0021" //uninsured business
	drop if program_id == "C19_ETH_LM_0003" //labor management system
	drop if program_id == "C19_BTN_0010" //skill training
	drop if program_id == "C19_VNM_0002" //suspended contracted workers
	drop if program_id == "C19_KEN_0037" //informal settlements
	drop if program_id == "C19_KEN_0036" //informal settlements
	drop if program_id == "C19_NAM_0025" //informal settlements
	drop if program_id == "C19_SLE_0001" //poor and disability ???
	drop if program_id == "C19_VNM_0013" //medium-sized business
	
	* list of ambiguous programs that were not excluded
	///C19_MYS_0033 - employment insurance
	///C19_CHN_0003 - employment insurance
	///C19_PHL_0017 - small business wage subsidy
	///C19_LKA_0007 - daily wage worker
	///C19_MMR_0012 - female garment worker
	///C19_MDV_0021 - poor and vulnerable
	///C19_DOM_0001 - poor and vulnerable
	///C19_VNM_0031 - artists and tour guide
	///C19_ZAF_0031 - freelance tour guide
	///C19_EGY_0043 - tourism
	///C19_CIV_0002 - food assistance for existing benefitiaries
	///C19_COL_0022 - universal cash transfer
	
	
********************************************************************************
*                   =====================================
*   	                        Save Filtered Data
*                   =====================================
********************************************************************************	

	* destring a few variables for merge
	foreach var of varlist start_date extended_date ben_pre_covidben_precovid exp_plan exp_plan_usd exp_actual_usd {
		destring `var', replace
		}
	
	save "$cleaned/2-Filtered Informal Programs.dta", replace
		label data "Filterted informal programs using the main dataset"
		notes: Source: "COVID-19 SP tracker_V16.xlsx"
		
	* close log
	log close
