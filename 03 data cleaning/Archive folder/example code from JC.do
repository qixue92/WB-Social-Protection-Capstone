use "C:\Users\ejc93\Downloads\Main_database_Oct.dta" , clear

**Number of projects by region and area of social protection

*Create tag if you want to examine data at region or country level
egen tag_region = tag(region)
egen tag_country = tag(country_name)
egen tag_country_area = tag(country_name sp_area)

*Create variables: number of projects/countries by region
bys region: gen num_projects = _N
bys region: egen num_country = sum(tag_country)

*Create variables, for each area of SP:  number of projects/countries by region
encode sp_area, gen(sp_area_code)

bys region sp_area: gen num_projects_area = _N 
bys region sp_area: gen num_country_area = sum(tag_country_area) 

keep num_projects* num_country* region sp_area sp_area_code

duplicates drop region sp_area, force
drop if sp_area  == ""
drop sp_area
reshape wide num_projects_area num_country_area, i(region) j(sp_area_code)
br
