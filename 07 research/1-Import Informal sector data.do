/*******************************************************************************
* File name: Import Informal Sector Data

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Feb 22, 2022
* Description: This file is created to import Informal Sector Data and merge it 
			   with the Main Database Tracker.

* Update 1: import dataset, Feb 23, 2022 - "import new dataset" 
* Update 2: add merge, Feb 26, 2022 - "merge with the main tracker"
* Update 3: remove merge, Mar 03, 2022 - "postpone merge after filtering"
********************************************************************************/


********************************************************************************
*                   ===================================
*   			               Github Globals
*                   ===================================
********************************************************************************
 	
	drop	 _all
	clear	 all
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
	
	
********************************************************************************
*                   =====================================
*   			                 Data Import
*                   =====================================
********************************************************************************

	 import excel "$raw/Informal Sector Worker_V16 Global Tracker.xlsx", ///
	 sheet("Sheet1") firstrow clear
	 
	 compress ///save storage space
	
	 label data "Informal Sector Workder_V16 Global Tracker"
	 notes: Source: Informal Sector Workder_V16 Global Tracker_as of Feb 2022.
	 
	 * filtering out high-income countries
	 drop if income_group == "HIC"

	 save "$imported/Informal Sector Worker.dta", replace
	 
	 
********************************************************************************
*                   =====================================
*   			                 Data Cleaning
*                   =====================================
********************************************************************************
	
	* destring variables for numeric caculation 
	foreach var of varlist ben_plan {
		destring `var', replace force
		}
	
	* clean up unlabel variable
	replace ben_unit_actual = Column2 if missing(ben_unit_actual)
	
	* re-calculate beneficaries planned (ben_ind_plan)
	gen ben_ind_plan2 = .
		replace ben_ind_plan2 = ben_plan * hhsize if ben_unit_plan == "1. Household"
		replace ben_ind_plan2 = ben_plan if ben_unit_plan == "2. Individuals"
	label var ben_ind_plan2 "re-calculated planned individual beneficiaries based on household size"
	* drop original variable - confirmed matching
	drop ben_ind_plan
	
	* re-calculate actual number of beneficaries (ben_ind_actual)
	gen ben_ind_actual2 = .
		replace ben_ind_actual2 = ben_actual * hhsize if ben_unit_actual == "1. Household"
		replace ben_ind_actual2 = ben_actual if ben_unit_actual == "2. Individuals"
	label var ben_ind_actual2 "re-calculated actual individual beneficiaries based on household size"
	
	* drop original variable - confirmed matching
	drop ben_ind_actual acualcoverage

	
********************************************************************************
*                   ==================================
*   			               Save Dataset
*                   ==================================
********************************************************************************	
	
	* drop duplicates - Duplicates in terms of all variables
	duplicates drop
	
	compress ///save storage space
	
	* save cleaned dataset
	save "$cleaned/1-Informal Sector Worker.dta", replace
		label data "cleaned Informal Sector Worker Data"
		notes: Source: Informal Sector Worker_V16 Global Tracker_as of Feb 2022.
	
	