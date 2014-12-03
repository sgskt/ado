* Convert WGS84 coordinates to any projection, providing espg code
prog def wgs84ToProj
	syntax namelist(min=3 max=3) using/, Code(integer) [Filename(string)]
    * Default filename
    loc fn = cond("`filename'"!="","`filename'","`using'`code'")
    * Get proj4 string from espg.io given code
    ashell curl http://epsg.io/`code'.proj4
    loc proj `"`r(o1)'"'
    * Load data
	use `using', clear
    * Preserve order
	tempvar order
	gen `order' = _n
    * Export only x and y variables to text file
	tokenize `namelist'
	sort `1' `2'
	tempfile oridata wgs84 newproj 
	save `oridata'
	export delim `1' `2' using `wgs84' if !mi(`1')&!mi(`2'), novar nolab delim(" ")
    * Run the text file through proj, with proj string from espg.io
	!proj `proj' `wgs84' > `newproj'
    * Import new projection
	import delim _X _Y using `newproj', delim(tab) clear
	merge 1:1 _n using `oridata'
    * Revert to original order
	sort `3' `order'
	drop _merge `order'
	save `fn', replace
end
