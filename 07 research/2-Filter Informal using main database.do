/*******************************************************************************
* File name: Social Protection for the Informal Section

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Jan 28, 2022
* Description: This file is created to filter the merged dataset with regard to programs targeted informal sector.

* Update 1: add new dataset, Dec 9 - "import new dataset" 
* Update 2: add new do-file, Dec 11- "add clean var do-file"
********************************************************************************/


********************************************************************************
*                   ===================================
*   			               BOX Globals
*                   ===================================
********************************************************************************
 	
	drop	 _all
	clear	 all
	cls
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

	
********************************************************************************
*                   =====================================
*   			                 Data Filtering
*                   =====================================
********************************************************************************

*	=================
*	1) Use clean data
*	=================

    use "$cleaned/2-merged_Main_database_Feb.dta", clear
	
*   ===============================
*	2) Remove high-income countries
*	===============================
	
	* remove high-income countries
	drop if income_group == "HIC"	

*	===================================
*	3) filter data with informal sector
*	===================================
	
	* target groups
	gen informal_targ = 0
	foreach var in sa_targ_group si_targ_group lm_targ_group {
		replace informal_targ = 1 if regexm(`var', "23")
	}
	
	* informal mentioned in description
	gen informal_desc = 0
	foreach var in benefit_desc benefit_desc_changes {
		replace informal_desc = 1 if regexm(`var', "informal")
	}
	
	* destring original var called informal 
	gen informal_new = 0
		replace informal_new = 1 if informal == "1. Yes"
		replace informal_new = 1 if informal == "informal"
		
	* add in-kind transfers & public works
	gen informal_trans = 0
		replace informal_trans = 1 if sp_category == "1.4. Unconditional food and in-kind transfers"
		replace informal_trans = 1 if sp_category == "1.6. Public works"
	 
	* label newly created filters
	label var informal_targ "targeted informal sector group"
	label var informal_desc "informal mentioned in description"
	label var informal_new "imported informal category"
	label var informal_trans "transfer to informal through public works & in-kind"
	
	* explore data
	tab informal_new informal_desc
	tab informal_new informal_targ
	tab informal_desc informal_targ
	
	* keep data marked with informal
	keep if informal_targ == 1 | informal_desc == 1 | informal_new == 1 | informal_trans == 1
	
*   ===========================================================
*	4) exclude programs that are not targeted at informal sector
*	============================================================
	
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
	

********************************************************************************
*                   =====================================
*   	                        Save Filtered Data
*                   =====================================
********************************************************************************	

	save "$cleaned/3-Filtered Informal Programs.dta", replace
