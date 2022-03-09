/*******************************************************************************
* File name: Comparing two datasets

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Mar 9, 2022
* Description: This file is created to compare the explore the inconsistency between the two datasets.
				- data set provided by client
				- manually filtered data set

* Update 1: xxx, Mar 03 - "xxx"
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
*                   ===================================
*   			               Compare datasets
*                   ===================================
********************************************************************************
	
	* load data
	use "$cleaned/2-Filtered Informal Programs.dta", clear
	
	* merge code-filtered dataset with client's dataset
	merge 1:1 _n using "$cleaned/1-Informal Sector Worker.dta", force
	
	* =======================
	* explore the differences
	* =======================
		
	* gen a score to filter conditions
	gen score = informal_targ + informal_desc
		label var score "informal_targ + informal_desc"
	
	* browse programs that were not included in client's data, not indentified by "informal" in decription
	br program_id informal_desc informal_targ benefit_desc if _merge == 1 & informal_desc == 0
	
	
********************************************************************************
*                   ===================================
*   			              Comparing datasets
*                   ===================================
********************************************************************************	

	* save the dataset which were not included in the client's data
	keep if _merge == 1 
	
	* save dataset
	save "$cleaned/3-Difference in datasets.dta", replace
	
	