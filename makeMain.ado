cap prog drop makeMain
prog def makeMain
syntax using/,Filelist(string) /// List of files to process
    Colnums(string) /// List of number of columns each table has
    Types(string asis) /// List of either "auto" or "wide" table style
    [Zooms(string) /// List of how much to zoom on tables 
    TItles(string asis) /// List of table titles
    FOrmat(string asis) /// List of either nothing or "lscape" to landscape tables
    ENCodings(string asis) /// Usefull to handle accents "y" or "n"
    noCOMPile]
* Checks -----------------------------------------------------------------------
loc possible_opts `""colnums" "zooms" "types" "titles" "format" "encodings""'
loc opts `""'
foreach opt of local possible_opts {
    if `"``opt''"' != "" {
        loc opts `"`opts' "`opt'""'
    }
}
* Write ------------------------------------------------------------------------
tempname fid
file open `fid' using `using', write replace
file write `fid' "\documentclass[a4paper]{article}"_n ///
    "\usepackage{preamble}"_n ///
    "\begin{document}"_n
* Initialize counters
foreach opt of local opts {
    loc `opt'_i 0
}
foreach f of local filelist {
    * Get options
    foreach opt of local opts {
        loc `opt'_c : word `=``opt'_i'+1' of ``opt''
        * If it's not the last, increment counter
        if "``opt'_c'" != "" {
            loc ++`opt'_i
        }
        * If it's the last, stick to it
        else {
            loc `opt'_c : word ``opt'_i' of ``opt''
        }
    } 
    * If "lscape" adapt header
    if "`format_c'" == "lscape" {
        file write `fid' "\begin{landscape}"_n ///
            "\thispagestyle{empty}"_n
        loc `types_c' = "lscape"
    }
    file write `fid' "\begin{table}"_n ///
        "\centering"_n ///
        "\scalebox{`zooms_c'}{%"_n ///
        "\begin{threeparttable}"_n ///
        "\caption{`titles_c'}"_n
    if "`encodings_c'"=="y" {
        file write `fid' "\inputencoding{applemac}"_n
    }
    file write `fid' "\est`types_c'{`f'}{`colnums_c'}{c}"_n
    if "`encodings_c'"=="y" {
        file write `fid' "\inputencoding{utf8}"_n
    }
    file write `fid' "\Starnote%"_n ///
        "\end{threeparttable}"_n ///
        "}\end{table}"_n
    if "`format_c'" == "lscape" {
        file write `fid' "\end{landscape}"_n
    }
}
file write `fid' "\end{document}"
file close `fid'
* Compilation ------------------------------------------------------------------
if "`compile'" != "nocompile"{
    qui ashell pwd
    loc pwd `r(o1)'
    loc nls = strpos(reverse("`using'"),"/")
    loc texname = substr("`using'",1-`nls',.)
    loc pdfname = substr("`texname'",1,length("`texname'")-4)+".pdf"
    loc dir = substr("`using'",1,length("`using'")-`nls')
    qui cd `dir'
    qui !pdflatex `texname' && open -a Preview `pdfname'
    qui cd `pwd'
}
end

