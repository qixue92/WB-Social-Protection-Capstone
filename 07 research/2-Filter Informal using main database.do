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
		replace informal_desc = 1 if regexm(`var', "informal")
	}
	
	* destring original var called informal 
	gen informal_new = "1" if strmatch(informal, "*1.Yes*") | strmatch(informal, "*informal*")
	
	* label newly created filters
	label var informal_tar "targeted informal sector"
	label var informal_desc "informal mentioned in description"
	label var informal_new "destringed informal var"
	
	* keep data marked with informal
	keep if informal_tar == 1 | informal_desc == 1 | informal_new == "1"
	
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
	
*   ===============================
*	5) Remove high-income countries
*	===============================
	
	* remove high-income countries
	drop if income_group == "HIC"
		
	
********************************************************************************
*                   =====================================
*   	                        Save Filtered Data
*                   =====================================
********************************************************************************	

	save "$cleaned/3-Filtered Informal Projects.dta", replace

