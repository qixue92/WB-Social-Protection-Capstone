
use "C:\Users\ejc93\Box\Capstone WB\data\clean\Main_database_Oct.dta" , clear


keep country_name population
drop if population == ""
duplicates drop country_name, force
ren population population_filled
tempfile tt
save `tt'

use "C:\Users\ejc93\Box\Capstone WB\data\clean\data_2021-11-12.dta" , clear
merge m:1 country_name using `tt'

br population population_filled country_name

