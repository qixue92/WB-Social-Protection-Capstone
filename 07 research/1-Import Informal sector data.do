/*******************************************************************************
* File name: Import Informal Sector Data

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Feb 26, 2022
* Description: This file is created to import Informal Sector Data and merge it 
			   with the Main Database - Tracker.

* Update 1: import dataset, Feb 26, 2022 - "import new dataset" 
* Update 2: 
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
*   			                 Data Import
*                   =====================================
********************************************************************************

	 import excel "$raw/Informal Sector Worker_V16 Global Tracker.xlsx", ///
	 sheet("Sheet1") firstrow clear
	 
	 compress ///save storage space
	
	 label data "Informal Sector Workder_V16 Global Tracker"
	 notes: Source: Informal Sector Workder_V16 Global Tracker_as of Feb 2022.

	 save "$imported/Informal Sector Workder.dta", replace	 


********************************************************************************
*                   =====================================
*   			                 Data Merge
*                   =====================================
********************************************************************************

	* meger with the main data
	use "$cleaned/cleaned_main_database_Dec", clear

	merge m:m program_id using "Informal Sector Workder.dta", update replace force
	
	* save merged data	
	compress
	
	save "$cleaned/merged_Main_database_Feb.dta", replace
	
		label data "Merged datasets including Main Dataset and Informal Sector Targeted Programs"
		notes: Source: Main Database_V16 and Informal Sector Workder_V16 Global Tracker_as of Feb 2022.
	
	