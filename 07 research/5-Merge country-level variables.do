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

	
********************************************************************************
*                   ===================================
*   			               Import Macro-data
*                   ===================================
********************************************************************************

	import excel "$raw/Capstone 2 Macro Data.xlsx", ///
	sheet("Main") firstrow clear
	 
		compress ///save storage space
	
		* rename country name preparing merging data
		rename CountryCode country_code
	
		save "$imported/Macro_Data.dta", replace
	
		label data "Country-lavel macro data"
		notes: Source: country-level macro data agreed in the research plan as of Feb 2022.
	
	
	/*import excel "$raw/IMF-GDPpc_2020.xls", sheet("Y2020") firstrow clear
	
		save "$imported/IMF-GDPpc_2020", replace*/

	
********************************************************************************
*                   ===================================
*   			               Merge Variables
*                   ===================================
********************************************************************************

	* use filtered data
	use "$imported/Macro_Data.dta", clear
	
	* merge country-level variables
	merge 1:m country_code using "$cleaned/4-Cleaned Project-level Data.dta"
	
	
********************************************************************************
*                 ======================================
*   			    Remove Groups other than Countries
*                 ======================================
********************************************************************************

	drop if inlist(country_code,"AFE","AFW","ARB","CSS","EAP","EAR","EAS","ECA")
	drop if inlist(country_code,"ECS","EUU","FCS","HIC","HPC","IBD","IBT","IDA")
	drop if inlist(country_code,"IDB","IDX","UMC","CEB","WLD","OSS","TSA","TSS")						 
	drop if inlist(country_code,"INX","LAC","LCN","LDC","LIC","LMC","LMY","LTE")
	drop if inlist(country_code,"MIC","MNA","NAC","OED","PRE","PSS","PST","SSA")
	drop if inlist(country_code,"SST","TEA","TEC","TLA","TMN","SSF","MEA")
								 
						 
********************************************************************************
*                   ===================================
*   			           Rename & Label Variables
*                   ===================================
********************************************************************************
		
	* GDP in $	
	la var GDP2018 "GDP in $ by country in 2018"
	la var GDP2019 "GDP in $ by country in 2019"
	la var GDP2020 "GDP in $ by country in 2020"
	
	* Public Spending on Social Assistance, % of GDP	
	la var Incomegroup "Income Group, public spending on social assistance as % of GDP"
	la var Region "Region, public spending on social assistance as % of GDP"
	
	la var AllSocialAssistance "Total Social assistance spending as % of GDP"
	la var CashTransfers "Social assistance spending on cash transfers as % of GDP"
	la var ConditionalCashTransfers "Social assistance spending on conditional cash transfers as % of GDP"
	
	la var FeeWaivers "Social assistance spending on fee waivers as % of GDP"
	la var InKind "Social assistance spending on in-kind SA as % of GDP"
	
	la var Mostrecentyearofexpenditure "Most recent year of SA expenditure, % of GDP"
	la var OtherSocialAssistance "Social assistance spending on other forms of SA as % of GDP"
	
	la var PublicWorks "Social assistance spending on public works programs as % of GDP"
	la var SchoolFeeding "Social assistance spending on school feeding programs as % of GDP"
	la var SocialPension "Social assistance spending on pensions as % of GDP"

	* Migrant Population %Pop
	la var MigrantPop2015 "International migrant stock (% of population)"	
	
	* Literacy Rate %Pop
	la var LRPop2010 "Literacy rate in 2010, adult total (% of people ages 15 and above)"
	la var LRPop2011 "Literacy rate in 2011, adult total (% of people ages 15 and above)"
	la var LRPop2012 "Literacy rate in 2012, adult total (% of people ages 15 and above)"
	la var LRPop2013 "Literacy rate in 2013, adult total (% of people ages 15 and above)"
	la var LRPop2014 "Literacy rate in 2014, adult total (% of people ages 15 and above)"
	
	la var LRPop2015 "Literacy rate in 2015, adult total (% of people ages 15 and above)"
	la var LRPop2016 "Literacy rate in 2016, adult total (% of people ages 15 and above)"
	la var LRPop2017 "Literacy rate in 2017, adult total (% of people ages 15 and above)"
	la var LRPop2018 "Literacy rate in 2018, adult total (% of people ages 15 and above)"
	la var LRPop2019 "Literacy rate in 2019, adult total (% of people ages 15 and above)"
	la var LRPop2020 "Literacy rate in 2020, adult total (% of people ages 15 and above)"

	* Internet Access %Pop
	la var IAPop2015 "Individuals using the Internet in 2015(% of population)"
	la var IAPop2016 "Individuals using the Internet in 2016 (% of population)"
	la var IAPop2017 "Individuals using the Internet in 2017 (% of population)"
	la var IAPop2018 "Individuals using the Internet in 2018 (% of population)"
	la var IAPop2019 "Individuals using the Internet in 2019 (% of population)"
	la var IAPop2020 "Individuals using the Internet in 2020 (% of population)"

	* Informal %GDP DGE
	la var InfGDPDGE2017 "Dynamic general equilibrium model-based (DGE) estimates of informal output in 2017 (% of official GDP)"
	la var InfGDPDGE2018 "Dynamic general equilibrium model-based (DGE) estimates of informal output in 2018 (% of official GDP)"

	* Informal %GDP MIMIC
	la var InfGDPMIMIC2016 "Multiple indicators multiple causes model-based (MIMIC) estimates of informal output in 2016 (% of official GDP)"
	la var InfGDPMIMIC2017 "Multiple indicators multiple causes model-based (MIMIC) estimates of informal output in 2017 (% of official GDP)"
	la var InfGDPMIMIC2018 "Multiple indicators multiple causes model-based (MIMIC) estimates of informal output in 2018 (% of official GDP)"
	
	* Pension %LF Pension_p
	la var PenLF2004 "Labor force with pension in 2004 (% of labor force)"
	la var PenLF2005 "Labor force with pension in 2005 (% of labor force)"
	la var PenLF2006 "Labor force with pension in 2006 (% of labor force)"
	la var PenLF2007 "Labor force with pension in 2007 (% of labor force)"
	la var PenLF2008 "Labor force with pension in 2008 (% of labor force)"
	la var PenLF2009 "Labor force with pension in 2009 (% of labor force)"
	la var PenLF2010 "Labor force with pension in 2010 (% of labor force)"

	* Informal Employment %Emp Infemp_p
	la var InfEmp2013 "Informal employment as % of total employment in 2013 (ILO, hamonized)"
	la var InfEmp2014 "Informal employment as % of total employment in 2014 (ILO, hamonized)"
	la var InfEmp2015 "Informal employment as % of total employment in 2015 (ILO, hamonized)"
	la var InfEmp2016 "Informal employment as % of total employment in 2016 (ILO, hamonized)"
	la var InfEmp2017 "Informal employment as % of total employment in 2017 (ILO, hamonized)"
	la var InfEmp2018 "Informal employment as % of total employment in 2018 (ILO, hamonized)"
	
	* Outside LF Employment %Emp  Infsize_p
	la var OOLFEmp2013 "Employment outside the formal sector as % of total employment in 2013 (ILO, hamonized)"
	la var OOLFEmp2014 "Employment outside the formal sector as % of total employment in 2014 (ILO, hamonized)"
	la var OOLFEmp2015 "Employment outside the formal sector as % of total employment in 2015 (ILO, hamonized)"
	la var OOLFEmp2016 "Employment outside the formal sector as % of total employment in 2016 (ILO, hamonized)"
	la var OOLFEmp2017 "Employment outside the formal sector as % of total employment in 2017 (ILO, hamonized)"
	la var OOLFEmp2018 "Employment outside the formal sector as % of total employment in 2018 (ILO, hamonized)"
	
	* Financial Account Ownership %Pop
	la var FAOPop2011 "Account ownership at a financial institution or with a mobile-money-service provider (% of population ages 15+)"
	la var FAOPop2014 "Account ownership at a financial institution or with a mobile-money-service provider (% of population ages 15+)"
	la var FAOPop2017 "Account ownership at a financial institution or with a mobile-money-service provider (% of population ages 15+)"

	* JAM Index
	la var BJ "Region - JAM index"
	la var IncomeGroup "Income Group - JAM index"
	
	la var IDCoverage "ID Coverage as % of Population - JAM index"
	la var Financialaccountcoverage "Financial Account Coverage Percent of Population - JAM index"
	la var MobileOwnership "Mobile Ownership Percent of Population - JAM index"
	
	la var JAM "Compound indicators - JAM index"
	

********************************************************************************
*                   	=========================
*   			                 Save Data
*                   	=========================
********************************************************************************
	
	* save and label data
	save "$cleaned/5-Merged_country-level data.dta", replace
		notes: Merged country-level data using filtered main dataset
	
	