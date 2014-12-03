* Jan 1; May 1; May 8; Jul 14; Aug 15; Nov 1; Nov 11; Dec 25;
* Easter; Ascension; Pentecost
cap prog drop pubHol
prog def pubHol
    syntax varname, gen(name) loc(name)
    gen `gen' = 0
    loc res `""'
    tempvar year
    gen `year' = year(`varlist')
    qui levelsof `year', loc(years)
    foreach y of local years {
        * Moveables
        ashell date -j -f"%B %d %Y" "$(LC_ALL="en_US.UTF-8" ncal -e `y')" +%Y%m%d
        loc easter = date("`r(o1)'","YMD")
        foreach n of numlist 1 39 50 {
            replace `gen' = 1 if `varlist' == `easter' + `n'
            loc res `"`res' `=`easter'+`n''"'
        }
        * Fixed
        loc pubh `"0101 0105 0805 1407 1508 0111 1111 2512"'
        foreach l of local pubh {
            replace `gen' = 1 if `varlist'==date("`l'`y'","DMY")
            loc res `"`res' `=date("`l'`y'","DMY")'"'
        }
    }
    c_local `loc' `"`res'"'
end
