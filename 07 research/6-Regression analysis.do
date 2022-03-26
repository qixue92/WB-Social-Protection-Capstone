/*******************************************************************************
* File name: Country-level data Regressional Analysis

* Author(s): Qi Xue (qx61@georgetown.edu)
             Gavin Hawkins (jgh73@georgetown.edu)
			 Neha Dagaonkar (nd569@georgetown.edu)
			 
* Date created: Mar 22, 2022
* Description: This file is created to run regressional analysis for the country-level data.

* Update 1: add new dataset, Dec 9 - "import new dataset" 
* Update 2: add new do-file, Dec 11- "add clean var do-file"
********************************************************************************/


********************************************************************************
*                   ===================================
*   			               GitHub Globals
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
	
	* load data
	use "$cleaned/5-Merged_country-level data.dta", clear

********************************************************************************
*                   ===================================
*   			               Data Cleaning
*                   ===================================
********************************************************************************	

	/* Result                      Number of obs
    -----------------------------------------
    Not matched                           206
        from master                       206  (_merge==1)
        from using                          0  (_merge==2)

    Matched                                95  (_merge==3)
    -----------------------------------------*/
	
	* rename _merge to understand data source
	gen SPP_program = _merge
		label var SPP_program "has a SPP program"
	replace  SPP_program = 0 if SPP_program == 2
	replace  SPP_program = 1 if SPP_program == 3
	
********************************************************************************
*                   ===================================
*   			               Research Questions
*                   ===================================
********************************************************************************	
	
	* ========================= *
	* gloabl controls variables
	* ========================= *
	 
	 gloabl control "Neha please add variables here"
 
	* ================== *
	* research questions
	* ================== *
 
* 1. Real GDP per capita (use the most recent GDP value)
	
	* PDC per capita
	tab GDPpc, m
	
	* tab population
	tab population, m
	
	* regression
	reg SPP_program GDPpc control
	
* 2. Informality (JAM) 
	
	* regression
	reg SPP_program JAM control
	
* 3. Access to internet

	* regression
	reg SPP_program (internet) control
	
* 4. Proportion of workforce in the informal sector.

	* regression
	reg SPP_program (proporation) control

* 5. Literacy rate
	reg SPP_program (Literacy rate) control

	

		 