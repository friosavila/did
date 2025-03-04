*! didsetup v.0.1.0 install rcall, github and R packages for did. 05apr2021 by Nick CH-K
prog def didsetup

	version 14

	syntax [anything], [go]

	local worked = 1
	
	if "`go'" == "" {
	
		display "{txt}This function will set up the proper packages ({res}github{txt} and{res} rcall{txt} in Stata) necessary to use R in Stata."
		display "These are both installed from GitHub and are not maintained by StataCorp or me."
		local url1 = `""https://journals.sagepub.com/doi/10.1177/1536867X19830891""'
		display "For more information on github and rcall, see {browse " `"`url1'"' ":the Stata Journal publication by Haghish}."
		display ""
		display "This will also install all of the R packages that did can use."
		display ""
		display "Finally, this setup requires that R is ALREADY installed on your machine."
		local urlR = `""https://www.r-project.org/""'
		display "R can be installed at {browse " `"`urlR'"' ":R-Project.org}. Do that first if it's not already installed."
		display as error "You will likely see a lot of flashing windows as R calls open and close, both when this function and other did functions run. That is expected. If you are sensitive to flashing lights you may want to look away."
		display "Do you want to continue? Type Y or Yes to continue, and anything else to quit."
		display _request(start)
		
		local st = lower("$start")
		
		if !inlist("`st'","y","yes") {
			di "Exiting..."
			exit
		}
		
		display "Should setup check for updated versions of packages?"
		display "Type Y or yes to check for updates, and anything else to only install packages if they are completely missing."
		display _request(upd)
		
		local st = lower("$upd")
	}
	else {
		local st = "y"
	}

	if "`anything'" == "" {
		local repo = "https://cloud.r-project.org"
	}
	else {
		local repo = "`anything'"
	}
	
	if inlist("`st'","y","yes") {
		net install github, from("https://haghish.github.io/github/") replace
		github install haghish/rcall, stable
		
		capture rcall_check, rversion(4.0)
		if _rc > 0 {
			display as error "did requires R version 4.0 or higher. Install the newest version of R from R-project.org."
			exit 198
		}
		
		display as error "rcall has been installed. rcall will now be used to install R packages."
		display as text "If errors occur, please see {help rcall} or the rcall website for troubleshooting:"
		display as text "http://www.haghish.com/packages/Rcall.php"
		display as text "Errors may arise if rcall cannot find your R installation,"
		display as text "or if you do not have write permission to your R folder."
		display as text "Or you may want to check {help didsetup} for instructions on manual package installation."
		display as text "(the last option may be a good idea if installation seems to hang for a long time)"
		
		foreach pkg in "did" "rmarkdown" "plm" "here" "knitr" "BMisc" "Matrix" "pbapply" "ggplot2" "ggpubr" "DRDID" "generics" "broom" {
			rcall: if(!("`pkg'" %in% rownames(installed.packages()))) {install.packages('`pkg'', repos = '`repo'', dependencies = TRUE)} else { update.packages('`pkg'', repos = '`repo'', dependencies = TRUE)}
			
			capture rcall: library(`pkg')
			if _rc > 0 {
				display as error "Package `pkg' failed to install. Try rcall: install.packages('`pkg'') to try again, and maybe get a more detailed error message as to why it didn't work."
			}
		}
	}
	else {
		* Check if github is installed and if not, install it
		capture which github
		if _rc > 0 {
			net install github, from("https://haghish.github.io/github/")
		}
		
		* Check if rcall is installed and if not, install it
		capture which rcall
		if _rc > 0 {
			github install haghish/rcall, stable
			display as error "rcall has been installed. rcall will now be used to install R packages."
			display "If errors occur, please see {help rcall} or the rcall website for troubleshooting:"
			display as text "http://www.haghish.com/packages/Rcall.php"
			display as text "Errors may arise if rcall cannot find your R installation,"
			display as text "or if you do not have write permission to your R folder."
			display as text "Or you may want to check {help didsetup} for instructions on manual package installation."
			display as text "(the last option may be a good idea if installation seems to hang for a long time)"
		}
	
		* Use install.packages because install_github can get strange with dependencies
		
		foreach pkg in "did" "rmarkdown" "plm" "here" "knitr" "BMisc" "Matrix" "pbapply" "ggplot2" "ggpubr" "DRDID" "generics" "broom" {
			display "Installing the R package `pkg'"
			rcall: if(!("`pkg'" %in% rownames(installed.packages()))) {install.packages('`pkg'', repos = '`repo'', dependencies = TRUE)}
			
			capture rcall: library(`pkg')
			if _rc > 0 {
				display as error "Package `pkg' failed to install. Try rcall: install.packages('`pkg'') to try again, and maybe get a more detailed error message as to why it didn't work."
			}
		}
	}
	if `worked' == 1 {
		display "You're good to go! Everything is installed."
		display "You may want to rerun didsetup regularly to get updated versions of packages."
	}
	
end
