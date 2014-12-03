program mbbs
    syntax varlist [if], reps(integer)
    preserve
    marksample touse
    keep if `touse'
    * Prepare ------------------------------------------------------------------
    * Get parameters
    tokenize `varlist'
    loc depvar `1'
    macro shift
    loc indepvars `*'
    * Get panel caracteristics
    qui xtset
    loc panelvar `r(panelvar)'
    loc timevar `r(timevar)'
    qui levelsof `panelvar', loc(N)
    loc N : word count `N'
    qui levelsof `timevar', loc(T)
    loc T : word count `T'
    * De-meaned variables
    tempvar mdepvar dmdepvar
    bysort `panelvar': egen `mdepvar' = mean(`depvar')
    gen `dmdepvar' = `depvar'-`mdepvar'
    * Optimal block length -----------------------------------------------------
    tempvar residuals meanx demx tag st
    * Run fixed effect model, get error and save results for later
    qui xtreg `depvar' `indepvars', fe
    tempname origest
    mat `origest'=e(b)
    predict `residuals', e
    * Compute scores
    bysort `timevar': egen `st' = mean(`residuals'*`dmdepvar')
    * Fit an AR(1) on the scores
    egen `tag' = tag(`timevar')
    sort `panelvar' `timevar'
    qui reg `st' L.`st' if `tag'==1
    loc rho = _b[L1.`st']
    * Use Andrews (1991) formula for Bartlett kernel
    loc a1 = (2*`rho'/((1-`rho')*(1+`rho')))^2
    loc bw = floor(1.1447*(`a1'*`T')^(1/3))+1 // always > 0
    di as text "Optimal block length is `bw'"
    loc nblocks = floor(`T'/`bw')
    * Format data and bootstrap ------------------------------------------------
    tempvar timevarunit cluster
    qui egen `timevarunit' = group(`timevar')
    * Expand dataset for easy resampling
    qui expand `bw'
    * Cluster identifier
    bysort `panelvar' `timevar': gen `cluster' = `timevarunit' - (_N-_n)
    qui replace `cluster' = `T' + `cluster' if `cluster'<=0
    * Bootstrap
    tempname a b
    mat `b' = .
	n di as text _newline "Bootstrap replications ({result:`reps'})"
	n di as text _newline "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
    forvalue n=1/`reps' {
        myboot `depvar' `indepvars', cl(`cluster') n(`nblocks') pan(`panelvar')
        mat `a'=e(b)
        if `n'==1 mat `b'=`a'
        else mat `b' = (`b' \ `a')
        * Progress bar
		if `n'/50 == int(`n'/50) n di ".  " `n'
		else n di _continue "."
    }
    clear
    matrix colnames `b' = `indepvars'
    qui svmat `b', n(col)
    * Display results
    tempname finest
    mat `finest' = J(1,`:word count `indepvars'',.)
    mat colnames `finest' = `indepvars'
    foreach v of local indepvars {
        mat `finest'[1,colnumb(`finest',"`v'")] = `origest'[1,colnumb(`origest',"`v'")]
    }
    bstat, stat(`finest')
end

program myboot
    syntax varlist, CLuster(string) Nblocks(integer) PANelvar(string)
    preserve
    * Sample -------------------------------------------------------------------
    bsample `nblocks', cl(`cluster')
    * Variables ----------------------------------------------------------------
    loc dvarlist `""'
    foreach v of local varlist {
        tempvar m`v' d`v'
        bysort `panelvar': egen `m`v'' = mean(`v')
        qui gen `d`v'' = `v'-`m`v''
        loc dvarlist `dvarlist' `d`v''
    }
    tokenize `dvarlist'
    loc depvar `1'
    macro shift
    loc indepvars `*'
    * Estimation ---------------------------------------------------------------
    qui reg `depvar' `indepvars', noconst
end
