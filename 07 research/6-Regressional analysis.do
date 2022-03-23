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
*   			               Research Questions
*                   ===================================
********************************************************************************	

	/*1. What are the characteristics of the informal sector social protection programs initiated during the Covid 	
		 period? The social protection programs can be characterized by:	
			* a. Types of transfers (e.g., cash vs wages)
			* b. Target population (e.g., by region)
			* c. Targeting mechanisms.*/
			
	/*2. What factors, such as GDP and access to the internet, determine the choice of targeting mechanism in the 	
		 informal sector among LIC, LMIC and MIC countries?*/
		 
		 binscatter sa_targ_method GDP2020

		 


	
	
	
