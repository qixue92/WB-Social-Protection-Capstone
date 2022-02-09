/*******************************************************************************
* File name: Social Assistance Tracker variable cleaning do-file

* Author(s): Qi Xue (qx61@georgetown.edu)
             Neha Dagaonkar (nd569@georgetown.edu)
			 Gavin Hawkins (jgh73@georgetown.edu)
			 
* Date created: Dec 10, 2021
* Description: This file is created to clean certain variables.

* Update 1: add new dataset, Dec 9 - "import new dataset" 
********************************************************************************/

* ==========*
* start_date
* ==========*

* replace missings in start_date
replace start_date = "" if start_date == "n.a."
replace start_date = "" if start_date == "n.s."

* replace different format from start date
replace start_date = "10mar2021" if start_date == "10-Mar-21"
replace start_date = "04mar2020" if start_date == "20.20-03-04"
replace start_date = "19may2020" if start_date == "2020_05=19"
replace start_date = "01apr2020" if start_date == "  4/1/2020"
replace start_date = "14apr2020" if start_date == " 4/14/2020"
replace start_date = "25jun2020" if start_date == " 6/25/2020"
replace start_date = "31apr2020" if start_date == "04/31/2020"

replace start_date = subinstr(start_date,"/01/","jan",.)
replace start_date = subinstr(start_date,"/02/","feb",.)
replace start_date = subinstr(start_date,"/03/","mar",.)
replace start_date = subinstr(start_date,"/04/","apr",.)
replace start_date = subinstr(start_date,"/05/","may",.)
replace start_date = subinstr(start_date,"/06/","jun",.)
replace start_date = subinstr(start_date,"/07/","jul",.)
replace start_date = subinstr(start_date,"/08/","aug",.)
replace start_date = subinstr(start_date,"/09/","sep",.)
replace start_date = subinstr(start_date,"/10/","oct",.)
replace start_date = subinstr(start_date,"/11/","nov",.)
replace start_date = subinstr(start_date,"/12/","dec",.)


* ==========*
*  end_date
* ==========*

* replace different format from start date
replace end_date = "29jan2021" if end_date == " 1/29/2021"
replace end_date = "12may2021" if end_date == "12-May-21"
replace end_date = "31jun2021" if end_date == "2021-06-31"
replace end_date = "31sep2021" if end_date == "2021-09-31"
replace end_date = "01mar2021" if end_date == "2022-02-30"
///entry error
replace end_date = "30feb2022" if end_date == "4/14/2020"

replace end_date = subinstr(end_date,"/01/","jan",.)
replace end_date = subinstr(end_date,"/02/","feb",.)
replace end_date = subinstr(end_date,"/03/","mar",.)
replace end_date = subinstr(end_date,"/04/","apr",.)
replace end_date = subinstr(end_date,"/05/","may",.)
replace end_date = subinstr(end_date,"/06/","jun",.)
replace end_date = subinstr(end_date,"/07/","jul",.)
replace end_date = subinstr(end_date,"/08/","aug",.)
replace end_date = subinstr(end_date,"/09/","sep",.)
replace end_date = subinstr(end_date,"/10/","oct",.)
replace end_date = subinstr(end_date,"/11/","nov",.)
replace end_date = subinstr(end_date,"/12/","dec",.)

* replace strings 
gen clean_date = regexm(end_date, "https")
replace clean_date = regexm(end_date, "n.")
replace end_date = "" if clean_date == 1


* ==========*
*  ben_plan *
* ==========*

replace ben_actual = "22970000" if ben_actual == "22.,970,000"
replace ben_actual = subinstr(ben_actual,"405,000","405000",.)
destring ben_actual, replace


* ============*
*  ben_actual *
* ============*

replace ben_plan = "105000" if ben_plan == "1,05,000"
replace ben_plan = "210684" if ben_plan == "2,10,684 "
replace ben_plan = "1325410" if ben_plan == "1325410.38140673"
replace ben_plan = "19840000" if ben_plan == "9839999.999999998"
replace ben_plan = "905076" if ben_plan == "905076.2711864407"
replace ben_plan = "31755147" if ben_plan == "31755147.4"
replace ben_plan = "" if ben_plan == "all households"
destring ben_plan, replace force


********************************************************************************
*                           Save dataset                                       *
********************************************************************************

save "$cleaned/cleaned_main_database_Dec", replace

