use "C:\Users\ejc93\Box\Capstone WB\data\clean\Main_database_Oct.dta" , clear

****Figure 1*******

* extract month from "start_date"
gen my_date = dofm(start_date)
gen month = month(my_date)
gen year = year(start_date)


gen cul_month = month
replace cul_month = month + 12 if year == 2021


* generate culmulative months
gen cul_month = .
  foreach i in month {
	replace cul_month = `i' if year ==  2020
	replace cul_month = 12 +`i' if year == 2021
	}

*Create tag if you want to examine data at country or program level
egen tag_measure = tag(program_id)
egen tag_country = tag(country_name)
egen tag_month = tag(cul_month)

*Create variables: number of projects/countries by month
bys cul_month: gen num_measure = _N

duplicates drop cul_month country_name, force
bys cul_month: gen num_country = _N
duplicates drop cul_month, force
keep cul_month num_country num_measure
