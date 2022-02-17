/*******************************************************************************
* File name: Social Protection for the Informal Section

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Jan 28, 2022
* Description: This file is created to filter the Social Assistance Tracker with
			   regard to programs targeted informal sector.

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

    use "$cleaned/cleaned_main_database_Dec.dta", clear

*	===================================
*	2) filter data with informal sector
*	===================================
	
	* target groups
	gen informal_tar = .
	foreach var in sa_targ_group si_targ_group lm_targ_group {
		replace informal_tar = 1 if regexm(`var', "23") | regexm(`var', "24") 
	}
	
	* informal mentioned in description
	gen informal_desc = .
	foreach var in benefit_desc benefit_desc_changes {
		replace informal_desc = 1 if regexm(`var', "informal") | regexm(`var', "self")
	}
	
	* destring original var called informal 
	gen informal_new = 1 if regexm(informal, "Yes") | regexm(self_employed, "Yes")
	
	* label newly created filters
	label var informal_tar "targeted informal sector"
	label var informal_desc "informal mentioned in description"
	label var informal_new "destringed informal var"
	
	* keep data marked with informal
	keep if informal_tar == 1 | informal_desc == 1 | informal_new == 1
	
*   ===================
*	4) sliming datasets
*	===================
	
	* drop variables there are no data entry
	foreach var of varlist _all {
		capture assert mi(`var')
		if !_rc {
        drop `var'
		}
	 }
	
	* keep relavent variable
	keep program_* region country_* income_group lending_category hh_size original_* benefit_* sp_* *_date ben_* exp_* financing_* sa_* si_* lm_* Deliveryinnovationpractices informal_*
	
	* drop variables irrelavant
	drop country_ASPIRE original_class original_area exp_dat entry_date ben_exp_changes lm_related ben_source_date_actual *sources *explanation clean_date lm_targ_company *_objective announced_date *_comments
	
*   ===============================
*	5) Remove high-income countries
*	===============================
	
	* remove high-income countries
	drop if income_group == "HIC"
	
	
	
********************************************************************************
*                   =====================================
*   			                 Data Cleaning
*                   =====================================
********************************************************************************
	
* Neha & Gavin, please start here.
		
	
********************************************************************************
*                   =====================================
*   	                        Save clean data
*                   =====================================
********************************************************************************	

save "$cleaned/Informal_SP_projects.dta", replace


