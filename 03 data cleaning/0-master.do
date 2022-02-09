/*******************************************************************************
* File name: Social Assistance Tracker master global do-file

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: October 22, 2021
* Description: This file is created to set up globals for the Social Assistance Tracker.

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

*	========================
*	1) Saving today's date
*	========================

	local today : display %dCY-N-D date(c(current_date), "DMY")
	display 	"`today'"

*	==================
*	2) Importing data
*	==================

/* temp mute

	 import excel "$raw/COVID-19 SPJ TRACKER_ALL_FINAL V16 [002].xlsx", ///
	 sheet("COVID -19 SPJ Data") cellrange(A7:HL3842) firstrow clear
	 
	 compress ///save storage space
	
	 label data "Social Assistance Tracker"
	 notes: Source: Main database_COVID-19 SPJ TRACKER_as of 2021 Dec 9.

	 save "$imported/Main_database_Dec", replace	 
*/

*	=====================
*	3) load imported data
*	=====================

    use "$imported/Main_database_Dec.dta", clear

	
/*==============================================================================

* Part 1. - Execute the cleaning do-file
    - clean certain variables
	
===============================================================================*/
	
	do "$cleaning/1-variable cleaning.do"

/*==============================================================================

* Part 2. - Produce subset of data
	- produce tables and figures
	
===============================================================================*/	
	
	do "$cleaning/2-gen subset data.do"
	
	
