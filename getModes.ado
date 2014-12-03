cap prog drop getModes 
prog def getModes, rclass
	syntax varlist(max=1) [if]
	* To use
	tempvar touse
	qui gen `touse' = 0
	qui replace `touse' = 1 `if'
	* Levels to inspect
	qui levelsof `varlist' if `touse'==1, local(levs)
	loc max 0
	loc modes `""'
	foreach l of local levs{
		qui count if `varlist'==`l' & `touse'==1
		if `r(N)'>`max' {
			loc max = `r(N)'
			loc modes `"`l'"'
		}
		else if `r(N)'==`max'{
			loc modes `"`modes' `l'"'
		}
	}
	return local modes `"`modes'"'
end
