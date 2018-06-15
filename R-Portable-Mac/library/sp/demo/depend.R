require(tools)
x = check_packages_in_dir(".",
	#check_args = c("--as-cran", ""),
	check_args = c("", ""),
	reverse = list(repos = getOption("repos")))
summary(x)
