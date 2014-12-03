* Create variables for n modes
* Might go over in case of ties / under in case of no observations left
cap prog drop genModes
prog def genModes
	syntax varlist(max=1) [if], basename(string) Nmodes(integer) [baselev(string) LAbel(string)]
	* To use
	tempvar touse
	qui gen `touse' = 0
	qui replace `touse' = 1 `if'
	* Loop	
	loc j=0
	loc cond = "`touse'==1"
	while `j'<`nmodes'{
		getModes `varlist' if `cond'
		if "`r(modes)'"==""{
			continue, break
		}
		foreach m in `r(modes)' {
			gen `basename'_`baselev'`j' = `varlist'==`m' & `cond'
			la var `basename'_`baselev'`j' "`label'`:label (`varlist') `m''"
			loc cond = "`cond' & `basename'_`baselev'`j'==0"
			loc j = `j'+1
		}
	}
end
