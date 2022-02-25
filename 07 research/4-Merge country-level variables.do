/*******************************************************************************
* File name: Merging Country-level Varibales

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Feb 17, 2022
* Description: This file is created to merge country-level variables agreed with
			   the existing project-level data.

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
*                   ===================================
*   			               Merge Variables
*                   ===================================
********************************************************************************

	* use informal section data
	*use "$cleaned/1-Informal Sector Workder.dta", clear
	use "$cleaned/3-Filtered Informal Projects.dta", clear
	
	* merge country-level variables
	merge 1:1 country_name using "Macro_Data.dta"
	
	* save merged dataset
	save "$cleaned/5.1-merged_country-level data.dta", replace
		notes: country-level data using merged dataset
		
	*save "$cleaned/5.2-merged_country-level data.dta", replace
		*notes: country-level data using informal data only
	