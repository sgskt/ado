cap prog drop win2mac
prog def win2mac
* 1.0.0 Simon Georges-Kot 13May2014 
* Program to convert strings from windows to mac

	syntax varlist[, LAbel VALues]
	* Check we're on mac
	if c(os)=="Windows"{
		di as error "This program should not be run on windows"
		exit
	}
	* Check for ashell
	cap which ashell
	if _rc!=0{
		di as res "Installing package ashell first ..."
		qui ssc install ashell
		di as res "Done"
	}
	foreach v of local varlist{
		* Handle variable label
		loc varlab : variable label `v'
		if "`label'"!=""&"`varlab'"!=""{
			qui ashell echo -e "`varlab'" | iconv -f latin1 -t macroman
			la var `v' "`r(o1)'"
		}
		* Handle values
		if "`values'"!=""{
			cap confirm string variable `v'
			loc is_str = !_rc
			loc label : value label `v'
			qui levelsof `v',loc(levs)
			foreach l of local levs{
				** If string variable, handle values directly
				if `is_str'{
					qui ashell echo -e "`l'" | iconv -f latin1 -t macroman
					qui replace `v'="`r(o1)'" if `v'=="`l'"
				}
				** If numeric variable, handle value labels if they exist
				else if "`v'"!=""{
					qui ashell echo -e "`:label `label' `l''" | iconv -f latin1 -t macroman
					la def `label' `l' "`r(o1)'", modify
				}
			}
		}
	}
end	
