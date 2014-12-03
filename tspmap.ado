/*
tspmap is a wrapper around spmap that allows users to make map videos
*/

cap prog drop tspmap
prog def tspmap 
	syntax [varname(numeric default=none)] [if] using/ , 	///
		[Time(varname numeric) MOVie]						///
		[POLygon(string asis)]                               ///
		[LINe(string asis)]                                  ///
		[POInt(string asis)]                                 ///
		[DIAgram(string asis)]                               ///
		[ARRow(string asis)]                                 ///
		[LABel(string asis)]                                 ///
		[SCAlebar(string asis)]                              ///
		[*]
	* timer box
	preserve
	use `using', clear
	qui su _X
	loc tbox_x = `r(min)'
	qui su _Y
	loc tbox_y = `r(min)'
	restore
	* Handle if
	tempvar touse
	gen `touse' = 1 `if'
	keep if `touse'==1
	* Useful locals
	loc all_times `""'
	loc mov_layers `""'
	loc cnt_layers `""'
	loc layers = `"line point polygon diagram arrow label scalebar"'
	* Time 
	if "`time'"!=""{
		qui levelsof `time',loc(self_times)
		loc all_times = `self_times'
		loc mov_layers `"self"'
	}
	* Prepare the layers
	foreach l of local layers {
		if "``l''"!=""{
			tspmap_layer, ``l'' type("`l'")
			loc t = `"`r(times)'"'
			if "`t'"!=""{
				loc mov_layers `"`mov_layers' `l'"'
				loc `l'_opt `r(opts)'
				loc `l'_times: list sort t
				loc `l'_tvar="`r(tvar)'"
				loc all_times: list all_times | `l'_times
			}
			else {
				loc cnt_layers `"`cnt_layers' `l'"'
			}
		}
	}
	loc all_times: list sort all_times
	loc ntimes: word count `all_times'
	/* Generate proper time lists
	Remember: different layers might have different time levels. */
	forvalues j=1/`ntimes' {
		loc ts: word `j' of `all_times'
		foreach l of local mov_layers {
			loc ts_`l': word `j' of ``l'_times'
			if `ts_`l''!=`ts'{
				if `j'>1{
					loc `l'_times `"`l'_times `ts'"'
					loc `l'_times: list sort `l'_times
				}
				else {
					loc `l'_times `"`l'_times 0"'
					loc `l'_times: list sort `l'_times
				}
			}
		}
	}
	
	* Map
	loc ss `"self"'
	loc mov_layers: list mov_layers - ss
	!mkdir tspmap
	forvalues j=1/`ntimes'{
		loc opts `""'
		if "`time'"!=""{	
			loc if = `"`time'==`:word `j' of `self_times''"'
		}
		foreach l of local mov_layers{
			loc keif `"s(keep if ``l'_tvar'==`:word `j' of ``l'_times'')"'
			loc opts `"`opts' `l'(``l'_opt' `keif')"'
		}
		foreach l of local cnt_layers{
			loc opts `"`l'(``l'')"'
		}
		loc opts `"`opts' `options'"'
		spmap `varname' `if' using `using', `opts' name("map_`j'",replace) ///
			text(`tbox_y' `tbox_x' "`:di %tc `:word `j' of `all_times'''", place(ne))
		graph export tspmap/map_`j'.eps, replace name("map_`j'")
		!convert tspmap/map_`j'.eps tspmap/map_`j'.png
		rm tspmap/map_`j'.eps
	}
	
	if "`movie'"==""{
		cd tspmap
		!cat *.png | ffmpeg -v debug -vcodec png -f image2pipe -framerate 25 ///
			 -i - -r 25 -vcodec libx264 -pix_fmt yuv420p -y video.mp4
		!rm *.png
		cd ..
	}	
end
