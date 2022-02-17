/*******************************************************************************
* File name: Import Informal Definition

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Feb 26, 2022
* Description: This file is created to merge the Informal definition with the existing tracker.

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

	/* meger information definition with the main data base

	use "Main_database_Dec.dta", clear

	merge m:m program_id using "Informal Sector Workder.dta", update replace force
	
	cf _all using "Informal Sector Workder.dta"*/
	
	

