/*******************************************************************************
* File name: Country-level data Regressional Analysis

* Author(s): Qi Xue (qx61@georgetown.edu)
             Gavin Hawkins (jgh73@georgetown.edu)
			 Neha Dagaonkar (nd569@georgetown.edu)
			 
* Date created: Mar 22, 2022
* Description: This file is created to run regressional analysis for the country-level data.

* Update 1: add coef table, April 8 - "run regression with different controls" 
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
	replace  SPP_program = 0 if SPP_program == 1
	replace  SPP_program = 1 if SPP_program == 3
	
********************************************************************************
*                   ===================================
*   			               Research Questions
*                   ===================================
********************************************************************************	
 
	* ================== *
	* research questions
	* ================== *
 
* 1. Real GDP per capita (use the most recent GDP value)
	
	* recode data - gen missing
	foreach var of varlist GDPPC2018 - GDPPC2020 {
		replace `var' = . if `var' == 0
	}
	
	* use previous year data if missing
	gen GDPPC = GDPPC2020
	foreach var of varlist GDPPC2019 GDPPC2018 {
		replace GDPPC = `var' if missing(GDPPC)
	}
	
	* gen log GDPpc
	gen lGDPPC = log(GDPPC)
	
	* two-way scatter
	binscatter SPP_program lGDPPC, xtitle(log GDP per capita) ytitle(Has an informal SPP program)
	
	* graph export
	graph export "$output/research/binscatter/GDPpc.png", replace
	
* 2. Informality (JAM) 
	
	* two-way scatter
	binscatter SPP_program JAM, xtitle(JAM Index) ytitle(Has an informal SPP program)
	
	* graph export
	graph export "$output/research/binscatter/JAM.png", replace
	
* 3. Access to internet
	
	* recode data - gen missing
	foreach var of varlist IAPop2015 - IAPop2020 {
		replace `var' = . if `var' == 0
	}
	
	* use previous year data if missing
	gen IAPop = IAPop2020
	foreach var of varlist IAPop2019 IAPop2018 IAPop2017 IAPop2016 IAPop2015 {
		replace IAPop = `var' if missing(IAPop)
	}
	
	* two-way scatter
	binscatter SPP_program IAPop, xtitle(Access to Internet) ytitle(Has an informal SPP program)
	
	* graph export
	graph export "$output/research/binscatter/internet.png", replace
	
* 4. Proportion of workforce in the informal sector.
	
	* recode data - gen missing
	foreach var of varlist InfEmp2013 - InfEmp2018 {
		replace `var' = . if `var' == 0
	}
	
	* use previous year data if missing
	gen InfEmp = InfEmp2018
	foreach var of varlist InfEmp2017 InfEmp2016 InfEmp2015 InfEmp2014 InfEmp2013 {
		replace InfEmp = `var' if missing(InfEmp)
	}
	
	* two-way scatter
	binscatter SPP_program InfEmp, xtitle(Proportion of workforce in the informal sector) ytitle(Has an informal SPP program)
	
	* graph export
	graph export "$output/research/binscatter/informal_pc.png", replace

* 5. Literacy rate
	
	* recode data - gen missing
	foreach var of varlist LRPop2010 - LRPop2020 {
		replace `var' = . if `var' == 0
	}
	
	* create loop to use previous year data if missing
	gen LRPop = LRPop2020
	foreach var of varlist LRPop2019 LRPop2018 LRPop2017 LRPop2016 LRPop2015 LRPop2014 LRPop2013 LRPop2012 LRPop2011 LRPop2010{
		replace LRPop = `var' if missing(LRPop)
	}
	
	* two-way scatter
	binscatter SPP_program LRPop, xtitle(Literacy Rate) ytitle(Has an informal SPP program)
	
	* graph export
	graph export "$output/research/binscatter/literacy.png", replace
	
	
********************************************************************************
*                   ===================================
*   			             Coefficient Tables
*                   ===================================
********************************************************************************	
	
	* gen models
	foreach var of varlist JAM IAPop InfEmp LRPop {
		eststo: reg SPP_program `var', robust
		eststo: reg SPP_program `var' lGDPPC, robust
			}
	
	esttab using "$output/research/results.rtf", ///
	se r2 label title(Correlation Regression Results) replace
	

		 