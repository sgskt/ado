cap prog drop isoWeek
prog def isoWeek
	syntax varname, GENerate(name)
	n cap drop `generate'
	qui gen `generate' = 0
	tempvar year newdate
	qui gen `newdate' = `varlist'
	format `varlist' %td
	qui gen `year' = year(`varlist')
	qui levelsof `year', loc(years)
	foreach y of local years {
		loc dow_11`y'=dow(mdy(1,1,`y'))
		if `dow_11`y'' < 5 {
			loc slide = `dow_11`y''-1
		}
		else {
			loc slide =  -mod((7-`dow_11`y''),7)-1
		}
		qui replace `newdate' = `varlist'+`slide'
		qui replace `generate'=week(`newdate') if year(`newdate')==`y'
	}
end
