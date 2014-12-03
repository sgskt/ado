/*
Helper for tspmap
*/

cap prog drop tspmap_layer
prog def tspmap_layer, rclass 
	syntax, Data(string) TYpe(string) ///
		[Time(string) Select(string asis) *] 
	preserve
	use `data', clear
	if "`select'"!=""{
		`select'
	}
	if "`time'"!=""{
		qui levelsof `time', loc(times)
	}
	loc fn = upper(substr("`type'",1,3))
	save _`fn', replace
	restore
	return local opts `"data(_`fn') `options'"'
	return local times `"`times'"'
	return local tvar `"`time'"'
end
