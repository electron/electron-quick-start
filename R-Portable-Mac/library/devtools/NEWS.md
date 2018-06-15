# devtools 1.13.5
* Fix two test errors related to GitHub rate limiting and mocking base functions.

# devtools 1.13.4
* Fix test errors for upcoming testthat release.

# devtools 1.13.3
* Workaround a change in how Rcpp::compileAttributes stores the symbol names
  that broke tests.

# devtools 1.13.2
* Workaround a regression in Rcpp::compileAttributes. Add trimws implementation
  for R 3.1 support.

# devtools 1.13.1

* Bugfix for installing from git remote and not passing git2r credentials
  (@james-atkins, #1498)

* Fix `test()` compatibility with testthat versions 1.0.2 (#1503).

* Fix `install_version()`, `install_bitbucket()`, `install_local()`,
`install_url()`, `install_svn()`, `install_bioc()` gain `quiet` arguments and
properly pass them to internal functions. (#1502)

# devtools 1.13.0

## New Features

* `spell_check` gains a `dict` argument to set a custom language or dictionary

* `release()` now checks documentation for spelling errors by default.

* New `use_gpl3_license()` sets the license field in `DESCRIPTION` and
  includes a copy of the license in `LICENSE`.

## Revdep check improvements

* Various minor improvements around checking of reverse dependencies
  (#1284, @krlmlr). All packages involved are listed at the start,
  the whole process is now more resilient against package
  installation failures.

* `revdep_check()` and `revdep_check_resume()` gain a skip argument
  which takes a character vector of packages to skip.

* `revdep_check()` and `check_cran()` gain a `quiet_check` argument.
  You can use `quiet_check = FALSE` to see the actual text of R CMD
  check as it runs (not recommending with multiple threads).

* `revdep_check_resume()` now takes `...` which can be used to
  override settings from `revdep_check()`. For debugging a problem
  with package checks, try
  `revdep_check(threads = 1, quiet_check = FALSE)`

* `revdep_check()` collects timing information in `timing.md` (#1319, @krlmlr).

* Package names and examples are sorted in case-insensitive C collation (#1322, @krlmlr).

* `use_revdep()` adds `.gitignore` entry for check database (#1321, @krlmlr).

* Own package is installed in temporary library for revdep checking (#1338, @krlmlr).

* Automated revdep check e-mails now can use the new `my_version` and
  `you_cant_install` variables. The e-mail template has been updated
  to use these variables (#1285, @krlmlr).

* Installation failures are logged during revdep checking, by default in
  `revdep/install`. Once an installation has failed, it is not attempted
  a second time (#1300, @krlmlr).

* Print summary table in README.md and problems.md (#1284, @krlmlr).Revdep
  check improvements (#1284)

## Bug fixes and minor improvements

* Handle case of un-installed package being passed to session_info (#1281).

* Using authentication to access Github package name. (#1262, @eriknil).

* `spell_check()` checks for hunspell before running (#1475, @jimvine).

* `add_desc_package()` checks for package dependencies correctly (#1463, @thomasp85).

* Remove deprecated `args` argument from `install_git()` to allow passthrough to `install` (#1373, @ReportMort).

* added a `quiet` argument to `install_bitbucket()`, with a default value
  of `FALSE` (fixes issue #1345, @plantarum).

* `update_packages()` allows for override of interactive prompt (#1260, @pkq).

* `use_test()` template no longer includes useless comments (#1349)

* Add encoding support in `test_dir()` call by adding reference to pkg$encoding (#1306, @hansharhoff)

* Parse valid Git remote URLs that lack trailing `.git`, e.g. GitHub browser URLs (#1253, @jennybc).

* Add a `check_bioconductor()` internal function to automatically install
  BiocInstaller() if it is not installed and the user wants to do so.

* Improve Git integration. `use_git_ignore()` and `use_git_config()` gain
  `quiet` argument, tests work without setting `user.name` and `user.email` Git
  configuration settings (#1320, @krlmlr).

* Improve Git status checks used in `release()` (#1205, @krlmlr).

* Improved handling of local `file://` repositories in `install()` (#1284, @krlmlr).

* `setup()` and `create()` gain new `quiet` argument (#1284, @krlmlr).

* Avoid unnecessary query of `available_packages()` (#1269, @krlmlr).

* Add cache setting to AppVeyor template (#1290, @krlmlr).

* Fix AppVeyor test by manually installing `curl` (#1301).

* `install(dependencies = FALSE)` doesn't query the available packages anymore (@krlmlr, #1269).

* `use_travis()` now opens a webpage in your browser to more easily activate
  a repo.

* `use_readme_rmd()` and `use_readme()` share a common template with sections
  for package overview, GitHub installation (if applicable), and an example
  (@jennybc, #1287).

* `test()` doesn't load helpers twice anymore (@krlmlr, #1256).

* Fix auto download method selection for `install_github()` on R 3.1 which
  lacks "libcurl" in `capabilities()`. (@kiwiroy, #1244)

* Fix removal of vignette files by not trying to remove files twice anymore (#1291)

# devtools 1.12.0

## New features

* New `install_bioc()` function and bioc remote to install Bioconductor
  packages from their SVN repository.

* `install_dev_deps()` gets everything you need to start development on source
  package - it installs all dependencies, and roxygen2 (#1193).

* `use_dev_version()` automates the process of switching from a release
  version number by tweaking the `DESCRIPTION`, adding a heading to
  `NEWS.md` (if present), and checking into git (if you use it) (#1076.)

* `use_github()` accepts a host argument, similar to `install_github()` 
  (@ijlyttle, #1101)
  
## Bug fixes and minor improvements

* Update with Rtools-3.4 information, (@jimhester)

* devtools now uses https to access the RStudio CRAN mirror if it will work
  on your system (#1059)

* Handle case when a GitHub request returns a non-JSON error response.
  (@jimhester, #1204, #1211)

* Suggested packages, including those specified as `Remotes:` are now installed
  after package installation. This allows you to use circular `Remotes:`
  dependencies for two related packages as long as one of the dependencies is a
  Suggested package. (@jimhester, #1184, hadley/dplyr#1809)

* bug fix for installation of binary packages on windows, they must be
  installed directly from a zip file. (@jimhester, #1191, #1192)

* `build_vignette()` will now only install the "VignetteBuilder" if it's 
  not present, not try and upgrade it if it is (#1139).

* `clean_dll()` Only removes package_name.def files and now operates
  recursively. (@jimhester, #1175, #1159, #1161)
  
* `check_man()` now prints a message if no problems are found (#1187).

* `install_*` functions and `update_packages()` refactored to allow updating of
  packages installed using any of the install methods. (@jimhester, #1067)

* `install_github()` now uses `https://api.github.com` as the host argument, so
  users can specify 'http:' or other protocols if needed. (@jimhester, #1131, #1200)

* `load_all()` runs package hooks before sourcing test helper files 
  allowing test helper to make use of objects created when a package is loaded 
  or attached. (@imanuelcostigan, #1146) 

* `revdep_check()` will now create the `revdep/` directory if it does not
  already exist (#1178).

* `source_gist()` gains a `filename` argument to specify a particular file to
  source from a GitHub gist. (@ateucher, #1172)

* Add a default codecov.yml file to turn off commenting with `use_coverage()`
  (@jimhester, #1188)
  
* Bug fix for 'nchar(text) : invalid multibyte string' errors when running
  `write_dcf()` on DESCRIPTION files with non-ASCII encodings (#1224, @jimhester).

# devtools 1.11.1

* Bug fix in `search_path_for_rtools()` using the gcc-4.9.3 toolchain when
  there is no rtools setting in the windows registry. (@jimhester, #1155)

# devtools 1.11.0

## Infrastructure helpers

* `create_description()` now sets `Encoding: UTF-8`. This helps non-English
  package authors (#1123).

* All `use_` function have been overhauled to be more consistent, particularly
  arround notification. Most functions now also ask to overwrite if a file 
  already exists (#1074).

* `use_coverage()` now adds covr to "Suggests", rather than recommending you
  install it explicitly in `.travis.yml`.

* `use_cran_badge()` now uses HTTPS URL (@krlmlr, #1124).

* `use_github()` now confirms that you've picked a good title and description
  (#1092) and prints the url of the repo (#1063).

* `use_news()`, and `use_test()` open the files in RStudio (if you're using
  it and have the rstudioapi package installed).

* `use_testthat()` tells you what it's doing (#1056).  

* `use_travis()` generates a template compatible with the newest R-travis.

* `use_readme_md()` creates a basic `README.md` template (#1064).

* `use_revdep()` has an updated template for the new revdep check 
  system (#1090, @krlmlr). 

* Removed the deprecated `use_coveralls()`, `add_rstudio_project()`, 
  `add_test_infrastructure()`, and `add_travis()`.
  
## Checks and and release()

* `check()` now always succeeds (instead of throwing an error when 
  `R CMD check` finds an `ERROR`), returning an object that summarises
  the check failures.

* `check()` gains `run_dont_test` and `manual` arguments to control whether or 
  not `\donttest{}` tests are tested, or manuals are built. This defaults to 
  `FALSE`, but `release()` runs check with it set to `TRUE` (#1071; #1087, 
  @krlmlr).

* The `cleanup` argument to `check()` is deprecated: it now always returns
  the path to the check directory.

* `check_built()` allows you to run `R CMD check` on an already built package.

* `check_cran()` suppresses X11 with `DISPLAY = ""`.

* `release()` has been tweaked to improve the order of the questions, 
  and to ensure that you're ok with problems. It  warns if both `inst/NEWS.Rd` 
  and `NEWS.md` exist (@krlmlr, #1135), doesn't throw error if Git head is 
  detached (@krlmlr, #1136).

* `release()` gains an `args` argument to control build options, e.g.
  to allow passing `args = "--compact-vignettes=both"` for packages with
  heavy PDF vignettes (@krlmlr, #1077).

* `system_check()` gains new arguments `path` to controls the working directory
  of the command, and `throw` to control whether or not it throws an error
  on command failure. `env` has been renamed to the more explicit `env_vars`.

## Revdep checks

`revdep_check()` has been overhauled. All `revdep_` functions now work like 
other devtools functions, taking a path to the package as the first argument.

`revdep_check()` now saves its results to disk as `check/check.rds`, and the other `revdep()` functions read from that cache. This also allows you to resume a partial run with `revdep_check_resume()`. This should be a big time saver if something goes unexpected wrong in the middle of the checks. You can blow away the cache and start afresh with `revdep_check_reset()`.

`revdep_check_save_summary()` now creates `README.md` to save one level of clicking in github. It also creates a `problems.md` that contains only results for only packages that had warnings or errors. Each problem is limited to at most 25 lines of output - this avoids lengthy output for failing examples. `revdep_check_print_problems()` prints a bulleted list of problems, suitable for inclusion in your `cran-comments.md`.

Summary results are reported as they come in, every then messages you'll get a message giving elapsed and estimated remaining time.

An experimental `revdep_email()` emails individual maintainers with their `R CMD check` summary results (#1014). See testthat and dplyr for example usage.

There were a handful of smaller fixes:

* `revdep_check()` doesn't complain about missing `git2r` package anymore
  (#1068, @krlmlr).

* Package index caches for `revdep_check()` now time out after 30 minutes.

* `revdep_check_save_logs()` has been removed - it is just not that useful.

* `revdep_check_summary()` has been removed - it never should have been
  part of the exported API.

## Other improvements

* Devtools now uses new gcc toolchain on windows, if installed (@jimhester).

* `install_git()` now allows you to pass credentials to git2r to specify
  specific ssh credentials (@onlymee, #982)

* `load_all()` now sources all test helpers if you use testthat. This makes it 
  much easier to interactively run tests (#1125). `load_all()` also correctly 
  handles `unix` and `windows` subdirectories within `R` (@gaborcsardi, #1102)

* `build_win()` defaults to only R-devel, since this is most commonly
  what you want.

* Help shims now inform you that you're using development documentation 
  (#1049).

* `git_sha1()` Fix fetching the latest git commit so that it also works
  for shallow git clones, i.e. git clones which make use of depth.
  (#1048, #1046, @nparley)

# devtools 1.10.0

## New features

* `curl`, `evaluate`, `roxygen2` and `rversions` have been moved from Imports
  to Suggests to lighten the dependency load of devtools. If you run a 
  function that needs one of the packages, you'll prompted to install it
  (#962, @jimhester).

* Devtools uses a new strategy for detecting RTools on windows: it now only 
  looks for Rtools if you need to `load_all()` or `build()` a package with
  compiled code. This should make it easier to work with devtools if
  you're developing pure R packages (#947).

* `package_file()` lets you find files inside a package. It starts by 
  finding the root directory of the package (i.e. the directory that contains 
  `DESCRIPTION`) (#985).

* `use_news_md()` adds a basic `NEWS.md` template (#957).

* `use_mit_license()` writes the necessary infrastructure to declare and 
  release an R package under the MIT license in a CRAN-compliant way. 
  (#995, @kevinushey)

* `check(cran = TRUE)` adds `--run-donttest` since you do need to test
  code in `\dontest()` for CRAN submission (#1002).

## Package installation

* `install()` installs packages specified in the `Additional_repositories`
  field, such as drat repositories. (#907, #1028, @jimhester). It 
  correctly installs missing dependencies (#1013, @gaborcsardi). If called on a
  Bioconductor package, include the Bioconductor repositories if they are not 
  already set (#895, @jimhester).
  
* `install()` gains a `metadata` argument which lets you add extra fields to
  the `DESCRIPTION` on install. (#1027, @rmflight)
  
* `install_github()` and `install_git()` only downloads and installs the
  package if the remote SHA1 reference differs from the currently installed 
  reference (#903, @jimhester).

* `install_local()` captures git and github information and stores it in the
  `DESCRIPTION` (#1027, @rmflight).

* `install_version()` is more robust when handling multiple repos (#943, #1030,
  @jimhester).

* Bugfix for `Remotes: ` feature that prevented it from working if devtools was
  not attached as is done in travis-r (#936, @jimhester).

## Bug fixes and minor improvements

* `check_dev_versions()` checks only package dependencies (#983).

* `check_man()` replaces `check_doc()` (since most other functions are
  named after the corresponding directory). `check_doc()` will hang around
  as an alias for the forseeable future (#958).

* `create()` produces a dummy namespace will fake comment so roxygen2 will 
  overwrite silently (#1016).

* `create()` and `setup()` are more permissive -- they now accept a path to
  either a new directory or empty directory. (#966, @kevinushey)

* `document()` now only runs `update_collate()` once.

* `load_all()` resolves a longstanding lazy load database corruption issue when 
  reloading packages which define S3 methods on generics from base or other 
  packages (#1001, @jimhester).

* `release_checks()` gains two new checks:

  * `check_vignette_titles()` checks that your vignette titles aren't the 
    default "Vignette Title" (#960, @jennybc). 
  
  * `check_news_md()` checks that `NEWS.md` isn't in your `.Rbuildignore`
    (since it's now supported by CRAN, #1042).

* `revdep_check()`:

    * More verbose about which package is installed (#926, @krlmlr)

    * Verifies the integrity of already downloaded package archives 
      (#930, @krlmlr)

    * Is now more tolerant of errors when retrieving the summary for a
      checked package (#929, @krlmlr). 

    * When `ncpus > 1`, it includes the package name for when so you know 
      which package has failed and can start looking at the output without 
      needing to wait for all packages to finish (@mattdowle).

    * Uses proper repository when `BiocInstaller::useDevel(TRUE)` 
      (#937, @jimhester).

* Shimmed `system.file()` now respects `mustWork = TRUE` and throws an error
  if the file does not exist (#1034).

* `use_appveyor()` template now creates `failure.zip` artifact instead of
  polluting the logs with `R CMD check` output (#1017, @krlmlr, @HenrikBengtsson).

* `use_cran_comments()` template has been improved (#1038).

* `use_data()` now warns when trying to save the same object twice,
  and stops if there is no object to save (#948, @krlmlr).

* `use_revdep_check()` no longer includes `revdep_check_save_logs` in 
  default template. I found I never used the logs and they just cluttered up
  the package directory (#1003).

* `with_*()` functions have moved into the withr package, and devtools
  functions have been deprecated (#925, @jimhester).

# devtools 1.9.1

* Avoid importing heavy dependencies to speed up loading (#830, @krlmlr).

* Remove explicit `library(testthat)` call in `test()` (#798, @krlmlr).

* `as.package()` and `load_all()` gain new argument `create`. Like other 
  functions with a `pkg` argument, `load_all()` looks for a `DESCRIPTION` file 
  in parent directories - if `create = TRUE` it will be automatically
  created if there's a `R/` or `data/` directory (#852, @krlmlr).

* `build_vignettes()` gains dependencies argument (#825, @krlmlr).

* `build_win()` now uses `curl` instead of `RCurl` for ftp upload.

* `build_win()` asks for consent to receive e-mail at maintainer address
  in interactive mode (#800, @krlmlr).

* `check()` now uses a better strategy when `cran = TRUE`. Instead of 
  attempting to simulate `--as-cran` behaviour by turning on certain env vars,
  it now uses `--as-cran` and turns off problematic checks with env vars (#866).
  The problematic `cran_env_vars()` function has been removed.

* `find_rtools()` now looks for registry keys in both HKCU (user) and 
  HKLM (admin) locations (@Kevin-Jin, #844)

* `install()` can now install dependencies from remote repositories by
  specifying them as `Remotes` in the `DESCRIPTION` file (#902, @jimhester).
  See `vignette("dependencies")` for more details.

* `install_*()` detects if called on a Bioconductor package and if so,
  automatically includes the Bioconductor repositories if needed (#895,
  @jimhester).

* `install_deps()` now automatically upgrades out of date dependencies. This
  is typically what you want when you're working on a development version of a 
  package. To suppress this behaviour, set `upgrade_dependencies = FALSE` 
  (#863). `install_deps()` is more careful with `...` - this means additional
  arguments to `install_*` are more likely to work (#870).

* `install_gitorious()` has been removed since gitorious no longer exists
  (#913).

* `load_all()` no longer fails if a `useDynLib()` entry in the NAMESPACE 
  is incorrect. This should make it easy to recover from an incorrect
  `@useDynLib`, because re-documenting() should now succeed.

* `release()` works for packages not located at root of git repository 
  (#845, #846, @mbjones).

* `revdep_check()` now installs _suggested_ packages by default (#808), and 
  sets `NOT_CRAN` env var to `false` (#809). This makes testing more similar to
  CRAN so that more packages should pass cleanly. It also sets `RGL_USE_NULL`
  to `true` to stop rgl windows from popping up during testing (#897). It
  also downloads all source packages at the beginning - this makes life a 
  bit easier if you're on a flaky internet connection (#906).
  
* New `uninstall()` removes installed package (#820, @krlmlr).

* Add `use_coverage()` function to add codecov.io or coveralls.io to a project,
  deprecate `use_coveralls()` (@jimhester, #822, #818).
  
* `use_cran_badge()` uses canonical url form preferred by CRAN.

* `use_data()` also works with data from the parent frame (#829, @krlmlr).

* `use_git_hook()` now creates `.git/hooks` if needed (#888)

* GitHub integration extended: `use_github()` gains a `protocol` argument (ssh or https), populates URL and BugReports fields of DESCRIPTION (only if non-existent or empty), pushes to the newly created GitHub repo, and sets a remote tracking branch. `use_github_links()` is a new exported function. `dr_github()` diagnoses more possible problems. (#642, @jennybc).

* `use_travis()`: Default travis script leaves notifications on default 
  settings.

* `uses_testthat()` and `check_failures()` are now exported (#824, #839, 
  @krlmlr).

* `use_readme_rmd()` uses `uses_git()` correctly  (#793).

* `with_debug()` now uses `with_makevars()` rather than `with_env()`, because R
  reads compilation variables from the Makevars rather than the environment
  (@jimhester, #788).

* Properly reset library path after `with_lib()` (#836, @krlmlr).

* `remove_s4classes()` performs a topological sort of the classes
  (#848, #849, @famuvie).

* `load_all()` warns (instead of failing) if importing symbols, methods, or classes
   from `NAMESPACE` fails (@krlmlr, #921).

# devtools 1.8.0
 
## Helpers

* New `dr_devtools()` runs some common diagnostics: are you using the 
  latest version of R  and devtools? It is run automatically by 
  `release()` (#592).

* `use_code_of_conduct()` adds a contributor code of conduct from 
  http://contributor-covenant.org. (#729)

* `use_coveralls()` allows you to easily add test coverage with coveralls
  (@jimhester, #680, #681).
  
* `use_git()` sets up a package to use git, initialising the repo and
  checking the existing files.

* `use_test()` adds a new test file (#769, @krlmlr).

* New `use_cran_badge()` adds a CRAN status badge that you can copy into a README file. Green indicates package is on CRAN. Packages not yet submitted or accepted to CRAN get a red badge.

## Package installation and info

* `build_vignettes()` automatically installs the VignetteBuilder package,
  if necessary (#736).

* `install()` and `install_deps()` gain a `...` argument, so additional
  arguments can be passed to `utils::install.packages()` (@jimhester, #712).
  `install_svn()` optionally accepts a revision (@lev-kuznetsov, #739).
  `install_version()` now knows how to look in multiple repos (#721).

* `package_deps()` (and `dev_package_deps()`) determines all recursive 
  dependencies and whether or not they're up-to-date (#663). Use
  `update(package_deps("xyz"))` to update out of date dependencies. This code 
  is used in `install_deps()` and `revdep_check()` - it's slightly more 
  aggressive than previous code (i.e. it forces you to use the latest version), 
  which should avoid problems when you go to submit to CRAN.

* New `update_packages()` will install a package (and its dependencies) only if
  they are missing or out of date (#675).

* `session_info()` can now take a vector of package names, in which case it
  will print the version of those packages and their dependencies (#664).

## Git and github

* Devtools now uses the git2r package to inspect git properties and install
  remote git packages with `install_git()`. This should be considerably
  more reliable than the previous strategy which involves calling the 
  command line `git` client. It has two small downsides: `install_git()`
  no longer accepts additional `args`, and must do a deep clone when
  installing.

* `dr_github()` checks for common problems with git/github setup (#643).

* If you use git, `release()` now warns you if you have uncommited changes,
  or if you've forgotten to synchronise with the remote (#691).

* `install_github()` warns if repository contains submodules (@ashander, #751).

## Bug fixes and minor improvements

* Previously, devtools ran all external R processes with `R --vanilla`.
  Now it only suppresses user profiles, and constructs a custom `.Rprofile` to
  override the default.  Currently, this `.Rprofile` sets up the `repos` option.
  Among others, this enables the cyclic dependency check in `devtools::release`
  (#602, @krlmlr).

* `R_BROWSER` and `R_PDFVIEWER` environment variables are set to "false" to 
  suppress random windows opening during checks.

* Devtools correctly identifies RTools 3.1 and 3.2 (#738), and
  preserves continuation lines in the `DESCRIPTION` (#709).

* `dev_help()` now uses `normalizePath()`. Hopefully this will make it more
  likely to work if you're on windows and have a space in the path.

* `lint()` gains a `cache` argument (@jimhester, #708).

* Fixed namespace issues related to `stats::setNames()` (#734, #772) and 
  `utils::unzip()` (#761, @robertzk).

* `release()` now reminds you to check the existing CRAN check results page
  (#613) ands shows file size before uploading to CRAN (#683, @krlmlr).

* `RCMD()` and `system_check()` are now exported so they can be used by other 
  packages. (@jimhester, #699).

* `revdep_check()` creates directories if needed (#759).

* `system_check()` combines arguments with ` `, not `, `. (#753)

* `test()` gains an `...` argument so that additional arguments can be passed
  to `testthat::test_dir` (@jimhester, #747)

* `use_travis()` now suggests you link to the svg icon since that looks a 
  little sharper. Default template sets `CRAN: http://cran.rstudio.com/` to 
  enable the cyclic dependency check.

* `NOT_CRAN` envvar no longer overrides externally set variable.

* `check(check_version = TRUE)` also checks spelling of the `DESCRIPTION`; if no
  spell checker is installed, a warning is given (#784, @krlmlr).

# devtools 1.7.0

## Improve reverse dependency checking

Devtools now supports a new and improved style of revdep checking with `use_revdep()`. This creates a new directory called `revdep` which contains a `check.R` template. Run this template to check all reverse dependencies, and save summarised results to `check/summary.md`. You can then check this file into git, making it much easier to track how reverse dependency results change between versions. The documentation for `revdep_check()` is much improved, and should be more useful (#635)

I recommend that you specify a library to use when checking with `options("devtools.revdep.libpath")`. (This should be a directory that already exists). This should be difference from your default library to keep the revdep environment isolated from your development environment.

I've also tweaked the output of `revdep_maintainers()` so it's easier to copy and paste into an email (#634). This makes life a little easier pre-release.

## New helpers

* `lint()` runs `lintr::lint_package()` to check style consistency and errors
  in a package. (@jimhester, #694)

* `use_appveyor()` sets up a package for testing with AppVeyor (@krlmlr, #549).

* `use_cran_comments()` creates a `cran-comments.md` template and adds it
  to `.Rbuildignore` to help with CRAN submissions. (#661)

* `use_git_hook()` allows you to easily add a git hook to a package.

* `use_readme_rmd()` sets up a template to generate a `README.md` from a
  `README.Rmd` with knitr.

## Minor improvements

* Deprecated `doc_clean` argument to `check()` has been removed.

* Initial package version in `create()` is now `0.0.0.9000` (#632).
 `create()` and `create_description()` checks that the package name is 
  valid  (#610).

* `load_all()` runs `roxygen2::update_collate()` before loading code. This
  ensures that files are sourced in the way you expect, as defined by 
  roxygen `@include` tags. If you don't have any `@include` tags, the
  collate will be not be touched (#623).

* `session_info()` gains `include_base` argument to also display loaded/attached
  base packages (#646).

* `release()` no longer asks if you've read the CRAN policies since the 
  CRAN submission process now asks the same question (#692). 
  
    `release(check = TRUE)` now runs some additional custom checks. These include:
    
    * Checking that you don't depend on a development version of a package.
    
    * Checking that the version number has exactly three components (#633).
    
    `release()` now builds packages without the `--no-manual` switch, both for
    checking and for actually building the release package (#603, @krlmlr). 
    `build()` gains an additional argument `manual`, defaulting to `FALSE`, 
    and `check()` gains `...` unmodified to `build()`.
  
* `use_travis()` now sets an environment variable so that any WARNING will
  also cause the build to fail (#570).

* `with_debug()` and `compiler_flags()` set `CFLAGS` etc instead of 
  `PKG_CFLAGS`. `PKG_*` are for packages to use, the raw values are for users
  to set. (According to http://cran.rstudio.com/doc/manuals/r-devel/R-exts.html#Using-Makevars)

* New `setup()` works like `create()` but assumes an existing, not necessarily 
  empty, directory (#627, @krlmlr).

## Bug fixes

* When installing a pull request, `install_github()` now uses the repository
  associated with the pull request's branch (and not the repository of the user
  who created the pull request) (#658, @krlmlr).

* `missing_s3()` works once again (#672)

* Fixed scoping issues with `unzip()`.

* `load_code()` now executes the package's code with the package's root as
  working directory, just like `R CMD build` et al. (#640, @krlmlr).

# devtools 1.6.1

* Don't set non-portable compiler flags on Solaris.

* The file `template.Rproj` is now correctly installed and the function
  `use_rstudio` works as it should. (#595, @hmalmedal)

* The function `use_rcpp` will now create the file `src/.gitignore` with the
  correct wildcards. (@hmalmedal)

* The functions `test`, `document`, `load_all`, `build`, `check` and any
  function that applies to some package directory will work from subdirectories
  of a package (like the "R" or "inst/tests" directories). (#616, @robertzk)

# devtools 1.6

## Tool templates and `create()`

* `create()` no longer generates `man/` directory - roxygen2 now does
  this automatically. It also no longer generates an package-level doc
  template. If you want this, use `use_package_doc()`. It also makes a dummy 
  namespace so that you can build & reload without running `document()` first.

* New `use_data()` makes it easy to include data in a package, either 
  in `data/` (for exported datasets) or in `R/sysdata.rda` (for internal
  data). (#542)
  
* New `use_data_raw()` creates `data-raw/` directory for reproducible
  generation of `data/` files (#541).

* New `use_package()` allows you to set dependencies (#559). 

* New `use_package_doc()` sets up an Roxygen template for package-level
  docs.

* New `use_rcpp()` sets up a package to use Rcpp.
  
* `use_travis()` now figures out your github username and repo so it can 
  construct the markdown for the build image. (#546)

* New `use_vignette()` creates a draft vignette using Rmarkdown (#572).

* renamed `add_rstudio_project()` to `use_rstudio()`, `add_travis()` to 
  `use_travis()`, `add_build_ignore()` to `use_build_ignore()`, and 
  `add_test_infrastructure()` to `use_testthat()` (old functions are 
  aliased to new)

## The release process

* You can add arbitrary extra questions to `release()` by defining a function 
  `release_questions()` in your package. Your `release_questions()` should 
  return a character vector of questions to ask (#451). 

* `release()` uses new CRAN submission process, as implemented by 
  `submit_cran()` (#430).

## Package installation

* All `install_*` now use the same code and store much useful metadata.
  Currently only `session_info()` takes advantage of this information,
  but it will allow the development of future tools like generic update
  functions.
  
* Vignettes are no longer installed by default because they potentally require 
  all suggested packages to also be installed. Use `build_vignettes = TRUE` to 
  force building and to install all suggested packages (#573).
  
* `install_bitbucket()` has been bought into alignment with `install_github()`:
  this means you can now specify repos with the compact `username/repo@ref`
  syntax. The `username` is now deprecated. 
    
* `install_git()` has been simplified and many of the arguments have changed 
  names for consistency with metadata for other package installs.

* `install_github()` has been considerably improved:

    * `username` is deprecated - please include the user in the repo name: 
      `rstudio/shiny`, `hadley/devtools` etc. 
      
    * `dependencies = TRUE` is no longer forced (regression in 1.5) 
       (@krlmlr, #462).
      
    * Deprecated parameters `auth_user`, `branch`, `pull` and `password` have 
      all been removed.
  
    * New `host` argument which allows you to install packages from github 
      enterprise (#410, #506). 
    
    * The GitHub API is used to download archive file (@krlmlr, #466) - this
      makes it less likely to break in the future.
  
    * To download a specified pull request, use `ref = github_pull(...)`
      (@krlmlr, #509). To install the latest release, use `"user/repo@*release"` 
      or `ref = github_release()` (@krlmlr, #350).

* `install_gitorious()` has been bought into alignment with `install_github()`:
  this means you can now specify repos with the compact `username/repo@ref`
  syntax. You must now always supply user (project) name and repo.

* `install_svn()` lets you install an R package from a subversion repository
  (assuming you have subversion installed).
  
* `decompress()` and hence `install_url()` now work when the downloaded
  file decompresses without additional top-level directory (#537).

## Other minor improvements and bug fixes

* If you're using RStudio, and you you're trying to build a binary package
  without the necessary build tools, RStudio will prompt to download and
  install the right thing. (#488)

* Commands are no longer run with `LC_ALL=C` - this no longer seems 
  necessary (#507).

* `build(binary = TRUE)` creates an even-more-temporary package library
  avoid conflicts (#557).

* `check_dir()` no longer fails on UNC paths (#522).

* `check_devtools()` also checks for dependencies on development versions
  of packages (#534).

* `load_all()` no longer fails on partial loading of a package containing
  S4 or RC classes (#577).

* On windows, `find_rtools()` is now run on package load, not package
  attach.

* `help()`, `?`, and `system.file()` are now made available when a package is
  loaded with `load_all()`, even if the devtools package isn't attached.

* `httr` 0.3 required (@krlmlr, #466).

* `load_all()` no longer gives an error when objects listed as exports are
  missing.
  
* Shim added for `library.dynam.unload()`.

* `loaded_packages()` now returns package name and path it was loaded from. 
  (#486)

* The `parenvs()` function has been removed from devtools, because is now in the
  pryr package.

* `missing_s3()` uses a better heuristic for determining if a function
  is a S3 method (#393).

* New `session_info()` provides useful information about your R session.
  It's a little more focussed than `sessionInfo()` and includes where
  packages where installed from (#526).

* `rstudioapi` package moved from suggests to imports, since it's always 
  needed (it's job is to figure out if rstudio is available, #458)

* Implemented own version `utils::unzip()` that throws error if command
  fails and doesn't print unneeded messages on non-Windows platforms (#540).

* Wrote own version of `write.dcf()` that doesn't butcher whitespace and 
  fieldnames.

## Removed functionality

* The `fresh` argument to `test()` has been removed - this is best done by 
  the editor since it can run the tests in a completely clean environment
  by starting a new R session.

* `compile_dll()` can now build packages located in R's `tempdir()`
  directory (@richfitz, #531).

# devtools 1.5

Four new functions make it easier to add useful infrastructure to packages:

* `add_test_infrastructure()` will create test infrastructure for a new package.
  It is called automatically from `test()` if no test directories are
  found, the session is interactive and you agree.

* `add_rstudio_project()` adds an RStudio project file to your package.
  `create()` gains an `rstudio` argument which will automatically create
  an RStudio project in the package directory. It defaults to `TRUE`:
  if you don't use RStudio, just delete the file.

* `add_travis()` adds a basic travis template to your package. `.travis.yml`
  is automatically added to `.Rbuildignore` to avoid including it in the built
  package.

* `add_build_ignore()` makes it easy to add files to `.Rbuildignore`,
  correctly escaping special characters

Two dependencies were incremented:

* devtools requires at least R version 3.0.2.

* `document()` requires at least roxygen2 version 3.0.0.

## Minor improvements

* `build_win()` now builds R-release and R-devel by default (@krlmlr, #438).
  It also gains parameter `args`, which is passed on to `build()`
  (@krlmlr, #421).

* `check_doc()` now runs `document()` automatically.

* `install()` gains `thread` argument which allows you to install multiple
  packages in parallel (@mllg, #401). `threads` argument to `check_cran()`
  now defaults to `getOption("Ncpus")`

* `install_deps(deps = T)` no longer installs all dependencies of
  dependencies (#369).

* `install_github()` now prefers personal access tokens supplied to
  `auth_token` rather than passwords (#418, @jeroenooms).

* `install_github()` now defaults to `dependencies = TRUE` so you definitely
  get all the packages you need to build from source.

* devtools supplies its own version of `system.file()` so that when the function
  is called from the R console, it will have special behavior for packages
  loaded with devtools.

* devtools supplies its own version of `help` and `?`, which will search
  devtools-loaded packages as well as normally-loaded packages.

## Bug fixes

* `check_devtools()` no longer called by `check()` because the relevant
  functionality is now included in `R CMD CHECK` and it was causing
  false positives (#446).

* `install_deps(TRUE)` now includes packages listed in `VignetteBuilder` (#396)

* `build()` no longer checks for `pdflatex` when building vignettes, as
  many modern vignettes don't need it (#398). It also uses
  `--no-build-vignettes` for >3.0.0 compatibility (#391).

* `release()` does a better job of opening your email client if you're inside
  of RStudio (#433).

* `check()` now correctly reports the location of the `R CMD
  check` output when called with a custom `check_dir`. (Thanks to @brentonk)

* `check_cran()` records check times for each package tested.

* Improved default `DESCRIPTION` file created by `create_description()`.
  (Thanks to @ncarchedi, #428)

* Fixed bug in `install_github()` that prevented installing a pull request by
  supplying `repo = "username/repo#pull"`. (#388)

* explicitly specify user agent when querying user name and ref for pull request
  in `install_github`. (Thanks to Kirill Müller, #405)

* `install_github()` now removes blank lines found in a package `DESCRIPTION`
  file, protecting users from the vague `error: contains a blank line` error.
  (#394)

* `with_options()` now works, instead of throwing an error (Thanks to
  @krlmlr, #434)

# devtools 1.4.1

* Fixed bug in `wd()` when `path` was ommitted. (#374)

* Fixed bug in `dev_help()` that prevented it from working when not using
  RStudio.

* `source_gist()` respects new github policy by sending user agent
  (hadley/devtools)

* `install_github()` now takes repo names of the form
  `[username/]repo[/subdir][@ref|#pull]` -
  this is now the recommended form to specify username, subdir, ref and/or
  pull for install_github. (Thanks to Kirill Müller, #376)

# devtools 1.4

## Installation improvements

* `install()` now respects the global option `keep.source.pkgs`.

* `install()` gains a `build_vignettes` which defaults to TRUE, and ensures
  that vignettes are built even when doing a local install. It does this
  by forcing `local = FALSE` if the package has vignettes, so `R CMD build`
  can follow the usual process. (#344)

* `install_github()` now takes repo names of the form `username/repo` -
  this is now the recommended form for install_github if your username is
  not hadley ;)

* `install_github()` now adds details on the source of the installed package
  (e.g. repository, SHA1, etc.) to the package DESCRIPTION file. (Thanks to JJ
  Allaire)

* Adjusted `install_version()` to new meta data structure on CRAN.
  (Thanks to Kornelius Rohmeyer)

* Fixed bug so that `install_version()` works with version numbers that
  contain hyphens. (Thanks to Kornelius Rohmeyer)

* `install_deps()` is now exported, making it easier to install the dependencies
  of a package.

## Other minor improvements

* `build(binary = TRUE)` now no longer installs the package as a side-effect.
  (#335)

* `build_github_devtools()` is a new function which makes it easy for Windows
  users to upgrade to the development version of devtools.

* `create_description()` does a better job of combining defaults and user
  specified options. (#332)

* `install()` also installs the dependencies that do not have the required
  versions; besides, the argument `dependencies` now works like
  `install.packages()` (in previous versions, it was essentially
  `c("Depends", "Imports", "LinkingTo")`) (thanks, Yihui Xie, #355)

* `check()` and `check_cran()` gain new `check_dir` argument to control where
  checking takes place (#337)

* `check_devtools()` no longer incorrectly complains about a `vignettes/`
  directory

* Decompression of zip files now respects `getOption("unzip")` (#326)

* `dev_help` will now use the RStudio help pane, if you're using a recent
  version of RStudio (#322)

* Release is now a little bit smarter: if it's a new package, it'll ask you
  to read and agree to the CRAN policies; it will only ask about
  dependencies if it has any.

* `source_url()` (and `source_gist()`) accept SHA1 prefixes.

* `source_gist()` uses the github api to reliably locate the raw gist.
  Additionally it now only attempts to source files with `.R` or `.r`
  extensions, and gains a `quiet` argument. (#348)

* Safer installation of source packages, which were previously extracted
  directly into the temp directory; this could be a problem if directory
  names collide. Instead, source packages are now extracted into unique
  subdirectories.


# devtools 1.3

## Changes to best practices

* The documentation for many devtools functions has been considerably expanded,
  aiming to give the novice package developer more hints about what they should
  be doing and why.

* `load_all()` now defaults to `reset = TRUE` so that changes to the NAMESPACE
  etc are incorporated. This makes it slightly slower (but hopefully not
  noticeably so), and generally more accurate, and a better simulation of
  the install + restart + reload cycle.

* `test()` now looks in both `inst/test` and `tests/testthat` for unit tests.
  It is recommended to use `tests/testthat` because it allows users to
  choose whether or not to install test. If you move your tests from
  `inst/tests` to `tests/testthat`, you'll also need to change
  `tests/test-all.R` to run `test_check()` instead of `test_package()`.
  This change requires testthat 0.8 which will be available on CRAN shortly.

* New devtools guarantee: if because of a devtools bug, a CRAN maintainer yells
  at you, I'll send you a hand-written apology note. Just forward me the email
  and your address.

## New features

* New `install_local()` function for installing local package files
 (as zip, tar, tgz, etc.) (Suggested by landroni)

* `parse_deps()`, which parses R's package dependency strings, is now exported.

* All package and user events (e.g. load, unload, attach and detach) are now
  called in the correct place.

## Minor improvements and bug fixes

* `build()` gains `args` parameter allowing you to add additional arbitrary
  arguments, and `check()` gains similar `build_args` parameter.

* `install_git` gains `git_arg` parameter allowing you to add arbitrary
  additional arguments.

* Files are now loaded in a way that preserves srcreferences - this means
  that you will get much better locations on error messages, which should
  considerably aid debugging.

* Fixed bug in `build_vignettes()` which prevented files in `inst/doc` from
  being updated

* `as.package()` no longer uses the full path, which should make for nicer
  error messages.

* More flexibility when installing package dependencies with the
 `dependencies` argument to `install_*()` (thanks to Martin Studer)

* The deprecated `show_rd()` function has now been removed.

* `install_bitbucket()` gains `auth_user` and `password` params so that you can
  install from private repos (thanks to Brian Bolt)

* Better git detection on windows (thanks to Mikhail Titov)

* Fix bug so that `document()` will automatically create `man/` directory

* Default `DESCRIPTION` gains `LazyData: true`

* `create_description()` now checks that the directory is probably a package
  by looking for `R/`, `data/` or `src/` directories

* Rolled back required R version from 3.0 to 2.15.

* Add missing import for `digest()`

* Bump max compatible version of R with RTools 3.0, and add details for
  RTools 3.1

# devtools 1.2

## Better installation

* `install` gains a `local` option for installing the package from the local
  package directory, rather than from a built tar.gz.  This is now used by
  default for all package installations. If you want to guarantee a clean
  build, run `local = FALSE`

* `install` now uses option `devtools.install.args` for default installation
  arguments. This allows you to set any useful defaults (e.g. `--no-multiarch`)
  in your Rprofile.

* `install_git` gains `branch` argument to specify branch or tag (Fixes #255)

## Clean sessions

* `run_examples` and `test` gain a `fresh` argument which forces them to run
  in a fresh R session. This completely insulates the examples/tests from your
  current session but means that interactive code (like `browser()`) won't work.(Fixes #258)

* New functions `eval_clean` and `evalq_clean` make it easy to evaluate code
  in a clean R session.

* `clean_source` loses the `vanilla` argument (which did not work) and gains
  a `quiet` argument

## New features

* `source_url` and `source_gist` now allow you to specify a sha, so you can
  make sure that files you source from the internet don't change without you
  knowing about it. (Fixes #259)

* `build_vignettes` builds using `buildVignette()` and movies/copies outputs
  using the same algorithm as `R CMD build`. This means that
  `build_vignettes()` now exactly mimics R's regular behaviour, including
  building non-Sweave vignettes (#277), building in the correct directory
  (#231), using make files (if present), and copying over extra files.

* devtools now sets best practice compiler flags: from `check()`,
  `-Wall -pedantic` and from `load_all()`, `-Wall -pedantic -g -O0 -UNDEBUG`.
  These are prefixed to existing environment variables so that you can override
  them if desired. (Fixes #257)

* If there's no `DESCRIPTION` file present, `load_all()` will automatically
  create one using `create_description()`.  You can set options in your
  `.Rprofile` to control what it contains: see `package?devtools` for more
  details.

## Minor improvements

* `check()` now also sets environment variable
  `_R_CHECK_CODE_DATA_INTO_GLOBALENV_` to TRUE (to match current `--as-cran`
  behaviour) (Fixes #256)

* Improved default email sent by `release()`, eliminating `create.post()`
  boilerplate

* `revdep` includes LinkingTo by default.

* Fixed regular expression problem that caused RTools `3.0.*` to fail to be
  found on Windows.

* `load_data()` got an overhaul and now respects `LazyData` and correctly
  exports datasets by default (Fixes #242)

* `with_envvar` gains the option to either replace, prefix or suffix existing
  environmental variables. The default is to replace, which was the previous
  behaviour.

* `check_cran` includes `sessionInfo()` in the summary output (Fixes #273)

* `create()` gains a `check` argument which defaults to FALSE.

* `with_env` will be deprecated in 1.2 and removed in 1.3

* When `load_all()` calls `.onAttach()` and `.onLoad()`, it now passes the
  lib path to those functions.

# devtools 1.1

* `source_gist()` has been updated to accept new gist URLs with username.
  (Fixes #247)

* `test()` and `document()` now set environment variables, including NOT_CRAN.

* Test packages have been renamed to avoid conflicts with existing packages on
  CRAN. This bug prevented devtools 1.0 from passing check on CRAN for some
  platforms.

* Catch additional case in `find_rtools()`: previously installed, but directory
  empty/deleted (Fixes #241)

# devtools 1.0

## Improvements to package loading

* Rcpp attributes are now automatically compiled during build.

* Packages listed in depends are `require()`d (Fixes #161, #178, #192)

* `load_all` inserts a special version of `system.file` into the package's
  imports environment. This tries to simulate the behavior of
  `base::system.file` but gives modified results because the directory structure
  of installed packages and uninstalled source packages is different.
  (Fixes #179). In other words, `system.file` should now just work even if the
  package is loaded with devtools.

* Source files are only recompiled if they've changed since the last run, and
  the recompile will be clean (`--preclean`) if any exported header files have
  changed. (Closes #224)

* The compilation process now performs a mock install instead of using
  `R CMD SHLIB`. This means that `Makevars` and makefiles will now be respected
  and generally there should be fewer mismatches between `load_all` and
  the regular install and reload process.

* S4 classes are correctly loaded and unloaded.

## Windows

* Rtools detection on windows has been substantially overhauled and should both
  be more reliable, and when it fails give more information about what is wrong
  with your install.

* If you don't have rtools installed, devtools now automatically sets the TAR
  environment variable to internal so you can still build packages.

## Minor features

* `check_cran` now downloads packages from cran.rstudio.com.

* `check()` now makes the CRAN version check optional, and off by default. The
  `release()` function still checks the version number against CRAN.

* In `check()`, it is optional to require suggested packages, using the
  `force_suggests` option.

* When `check()` is called, the new default behavior is to not delete existing
  .Rd files from man/. This behavior can be set with the "devtools.cleandoc"
  option.

* `install_bitbucket()` now always uses lowercase repo names. (Thanks to mnel)

* New function `with_lib()`, which runs an expression code with a library path
  prepended to the existing libpaths. It differs slightly from
  `with_libpaths()`, which replaces the existing libpaths.

* New function `install_git()` installs a package directly from a git
  repository. (Thanks to David Coallier)

* If `pdflatex` isn't available, don't try to build vignettes with `install()`
  or `check()`. (Fixes #173)

* `install_github()` now downloads from a new URL, to reflect changes on how
  files are hosted on GitHub.

* `build()` now has a `vignettes` option to turn off rebuilding vignettes.

* `install(quick=TRUE)` now builds the package without rebuilding vignettes.
  (Fixes #167)

* All R commands called from `devtools` now have the environment variable
  `NOT_CRAN` set, so that you can perform tasks when you know your code
  is definitely not running on CRAN. (Closes #227)

* Most devtools functions can a quiet argument that suppresses output. This is
  particularly useful for testing.

## Bug fixes

* Fixed path issue when looking for Rtools on windows when registry entry is not present. (Fixes #201)

* Reloading a package that requires a forced-unload of the namespace now works.

* When reloading a package that another loaded package depends on, if there
  was an error loading the code, devtools would print out something about an
  error in `unloadNamespace`, which was confusing. It now gives more useful
  errors.

* An intermittent error in `clear_topic_index` related to using `rm()` has
  been fixed. (Thanks to Gregory Jefferis)

* `revdep()` now lists "Suggests" packages, in addition to "Depends" and
  "Imports".

* `revdep_check()` now correctly passes the `recursive` argument to `revdep()`.

* The collection of check results at the end of `check_cran()` previously did
  not remove existing results, but now it does.

* When a package is loaded with `load_all()`, it now passes the name of the
  package to the `.onLoad()` function. (Thanks to Andrew Redd)

# devtools 0.8.0

## New features

* `create` function makes it easier to create a package skeleton using
  devtools standards.

* `install_github()` can now install from a pull request -- it installs
  the branch referenced in the pull request.

* `install_github` now accepts `auth_user` and `password` arguments if you
  want to install a package in a private github repo. You only need to specify
  `auth_user` if it's not your package (i.e. it's not your `username`)
  (Fixes #116)

* new `dev_help` function replaces `show_rd` and makes it easy to get help on
  any topic in a development package (i.e. a package loaded with `load_all`)
  (Fixes #110)

* `dev_example` runs the examples for one in-development package. (Fixes #108)

* `build_vignettes` now looks in modern location for vignettes (`vignettes/`)
   and warn if vignettes found in old location (`inst/doc`).  Building now
   occurs in a temporary directory (to avoid polluting the package with
   build artefacts) and only final pdf files are copied over.

* new `clean_vignettes` function to remove pdfs in `inst/doc` that were built
  from vignettes in `vignettes/`

* `load_all` does a much much better job at simulating package loading (see
  LOADING section). It also compiles and loads C/C++/Fortran code.

* `unload()` is now an exported function, which unloads a package, trying
  harder than just `detach`. It now also unloads DLLs. (Winston Chang.
  Fixes #119)

* `run_examples` now has parameters `show`, `test`, `run` to control which of
  `\dontrun{}`, `\dontshow{}`, `\donttest{}` and `\testonly{}` are commented
  out. The `strict` parameter has been removed since it is no longer necessary
  because `load_all` can respect namespaces. (Fixes #118)

* `build()`, `check()`, `install()` etc now run R in `--vanilla` mode which
  prevents it from reading any of your site or personal configuration files.
  This should prevent inconsistencies between the environment in which the
  package is run between your computer and other computers (e.g. the CRAN
  server) (Fixes #145)

* All system R command now print the full command used to make it easier to
  understand what's going on.

## Package paths

* `as.package` no longer uses `~/.Rpackages`.

* `as.package` provides more informative error messages when path does not
  exist, isn't a directory, or doesn't contain a `DESCRIPTION` file.

* New function `inst()` takes the name of a package and returns the installed
  path of that package. (Winston Chang. Fixes #130). This makes it possible to
  use `devtools` functions (e.g. `unload`) with regular installed packages,
  not just in-development source packages.

* New function `devtest()` returns paths to an internal testing packages
  in devtools.

## Loading

* Development packages are now loaded into a namespace environment,
  <namespace:xxxx>, and then the objects namespace are copied to the
  package environment, <package:xxxx>. This more accurately simulates
  how packages are normally loaded. However, all of the objects (not
  just the exported ones) are still copied to the package environment.
  (Winston Chang. Fixes #3, #60, and #125)

* Packages listed in Imports and Depends are now loaded into an imports
  environment, with name attribute "imports:xxxx", which is the parent
  of the namespace environment. The imports environment is in turn a
  child of the <namespace:base> environment, which is a child of the
  global environment. This more accurately simulates how packages are
  normally loaded.  These packages previously were loaded and attached.
  (Winston Chang. Fixes #85)

* The NAMESPACE file is now used for loading imports, instead of the
  DESCRIPTION file. Previously, `load_all` loaded all objects from the
  packages listed in DESCRIPTION. Now it loads packages (and, when
  when 'importfrom' is used, specific objects from packages) listed in
  NAMESPACE. This more closely simulates normal package loading. It
  still checks version numbers of packages listed in DESCRIPTION.
  (Winston Chang)

* `load_all` can now be used to properly reload devtools. It does this
  by creating a copy of the devtools namespace environment, and calling
  `load_all` from that environment. (Winston Chang)

* The `.onLoad` and `.onAttach` functions for a development package are
  now both called when loading a package for the first time, or with
  `reset=TRUE`, and the order more correctly simulates normal package
  loading (create the namespace, call `.onLoad`, copy objects to the
  package environment, and then call `.onAttach`). (Winston Chang)

* `load_all` will now throw a warning if a dependency package does not
  satisfy the version requirement listed in DESCRIPTION. (Winston Chang.
  Fixes #109)

* The package environment now has a 'path' attribute, similar to a
  package loaded the normal way. (Winston Chang)

* `load_all` now has an option `export_all`. When set to TRUE, only the
  objects listed as exports in NAMESPACE are exported. (Winston Chang)

* `load_all` now compiles C files in the /src directory. (Winston Chang)

* New functions `compile_dll()` and `clean_dll()`, which compile C/C++/
  Fortan source code, and clean up the compiled objects, respectively.
  (Winston Chang. Fixes #131)

## Bug fixes

* `load_code` now properly skips missing files. (Winston Chang)

* Add `--no-resave-data` to default build command.

* The subject line of the email created by `release` is now "CRAN submission
  [package] [version]", per CRAN repository policy.

* `install_bitbucket` properly installs zip files of projects stored
  in Mercurial repositories. (Winston Chang. Fixes #148)

* `build` now builds vignettes because `install` does not. (Fixes #155)

## Introspection

* New function `loaded_packages()`, which returns the names of packages
  that are loaded and attached.

* Packages loaded with `load_all` now store devtools metadata in their
  namespace environment, in a variable called `.__DEVTOOLS__`. This can
  be accessed with the `dev_meta` function. (Winston Chang. Fixes #128)

* `dev_mode` now stores the path it uses in option `dev_path`. That makes it
  easy for other applications to detect when it is on and to act accordingly.

* New function `parse_ns_file()`, which parses a NAMESPACE file for a
  package.

* New function `parenvs()`, which parents the parent environments
  of an object. (Winston Chang)

# devtools 0.7.1

* bump dependency to R 2.15

* `load_code` now also looks for files ending in `.q` - this is not
  recommended, but is needed for some older packages

# devtools 0.7

## Installation

* `install_bitbucket` installs R packages on bitbucket.

* `install` now uses `--with-keep.source` to make debugging a little easier.

* All remote install functions give better error messages in the case of http
  errors (Fixes #82).

* `install` has new quick option to make package installation faster, by
  sacrificing documentation, demos and multi-architecture binaries.
  (Fixes #77)

* `install_url`, `install_github` and `install_gitorious` gain a subdir
  argument which makes it possible to install packages that are contained
  within a sub-directory of a repository or compressed file. (Fixes #64)

## Checking

* `with_debug` function temporarily sets env vars so that compilation is
  performed with the appropriate debugging flags set. Contributed by Andrew
  Redd.

* `revdep`, `revdep_maintainers` and `revdep_check` for calculating reverse
  dependencies, finding their maintainers and running `R CMD check`.
  (Fixes #78)

* `check_cran` has received a massive overhaul: it now checks multiple
  packages, installs dependencies (in user specified library), and parse check
  output to extract errors and warnings

* `check` uses new `--as-cran` option to make checking as close to CRAN as
  possible (fixes #68)

## Other new features

* devtools now uses options `devtools.path` to set the default path to use
  with devmode, and `github.user` to set the default user when installing
  packages from github.

* if no package supplied, and no package has been worked with previously, all
  functions now will try the working directory. (Fixes #87)

* on windows, devtools now looks in the registry to find where Rtools is
  installed, and does a better a job of locating gcc. (Contributed by Andrew
  Redd)

* `show_rd` passes `...` on to `Rd2txt` - this is useful if you're checking
  how build time `\Sexpr`s are generated.

* A suite of `with` functions that allow you to temporarily alter the
  environment in which code is run: `in_dir`, `with_collate`, `with_locale`,
  `with_options`, `with_path`, ... (Fixes #89)

* `release` ask more questions and randomises correct answers so you really
  need to read them (Fixes #79)

* `source_gist` now accepts default url such as "https://gist.github.com/nnn"

* New system path manipulation functions, `get_path`, `set_path`, `add_path`
  and `on_path`, contributed by Andrew Redd.

* If you're on windows, `devtools` now suppresses the unimportant warning from
  CYGWIN about the dos style file paths

## Bug fixes

* `decompress` now uses target directory as defined in the function call
  when expanding a compressed file. (Fixes #84)

* `document` is always run in a C locale so that `NAMESPACE` sort order is
  consistent across platforms.

* `install` now quotes `libpath` and build path so paths with embedded spaces
  work (Fixes #73 and #76)

* `load_data` now also loads `.RData` files (Fixes #81)

* `install` now has `args` argument to pass additional command line arguments
  on to `R CMD install` (replaces `...` which didn't actually do anything).
  (Fixes #69)

* `load_code` does a better job of reconciling files in DESCRIPTION collate
  with files that actually exist in the R directory. (Fixes #14)

# devtools 0.6

## New features

* `test` function takes `filter` argument which allows you to restrict which
  tests are to be run

* `check` runs with example timings, as is done on CRAN. Run with new param
  `cleanup = F` to access the timings.

* `missing_s3` function to help figure out if you've forgotten to export any
  s3 methods

* `check_cran` downloads and checks a CRAN package - this is useful to run as
  part of the testing process of your package if you want to check the
  dependencies of your package

* `strict` mode for `run_examples` which runs each example in a clean
  environment. This is much slower than the default (running in the current
  environment), but ensures that each example works standalone.

* `dev_mode` now updates prompt to indicate that it's active (Thanks to Kohske
  Takahashi)

* new `source_url` function for sourcing script on a remote server via
  protocols other than http (e.g. https or ftp). (Thanks to Kohske Takahashi)

* new `source_gist` function to source R code stored in a github gist. (Thanks
  to Kohske Takahashi)

* `load_all` now also loads all package dependencies (including suggestions) -
  this works around some bugs in the way that devtools attaches the
  development environment into the search path in a way that fails to recreate
  what happens normally during package loading.

## Installation

* remote installation will ensure the configure file is executable.

* all external package installation functions are vectorised so you can
  install multiple packages at time

* new `install_gitorious` function install packages in gitorious repos.

* new `install_url` function for installing package from an arbitrary url

* include `install_version` function from Jeremy Stephens for installing a
  specific version of a CRAN package from the archive.

## Better windows behaviour

* better check for OS type (thanks to Brian Ripley)

* better default paths for 64-bit R on windows (Fixes #35)

* check to see if Rtools is already available before trying to mess with the
  paths. (Fixes #55)

## Bug fixes

* if an error occurs when calling loading R files, the cache will be
  automatically cleared so that all files are loaded again next time you try
  (Fixes #55)

* functions that run R now do so with `R_LIBS` set to the current
  `.libPaths()` - this will ensure that checking uses the development library
  if you are in development mode. `R_ENVIRON_USER` is set to an empty file to
  avoid your existing settings overriding this.

* `load_data` (called by `load_all`) will also load data defined in R files in
  the data directory. (Fixes #45)

* `dev_mode` performs some basic tests to make sure you're not setting your
  development library to a directory that's not already an R library.
  (Fixes #25)

# devtools 0.5.1

* Fix error in that was causing R commands to fail on windows.

# devtools 0.5

## New functions

* new `show_rd` function that will show the development version of a help
  file.

## Improvements and bug fixes

* external R commands always run in locale `C`, because that's what the CRAN
  severs do.

* `clean_source` sources an R script into a fresh R environment, ensuring that
  it can run independently of your current working environment. Optionally
  (`vanilla = T`), it will source in a vanilla R environment which ignores all
  local environment settings.

* On windows, `devtools` will also add the path to `mingw` on startup. (Thanks
  to pointer from Dave Lovell)

# devtools 0.4

## New functions

* new `wd` function to change the working directory to a package subdirectory.

* `check_doc` now checks package documentation as a whole, in the same way
  that `R CMD check` does, rather than low-level syntax checking, which is
  done by `roxygen2. DESCRIPTION checking has been moved into `load_all`.
  `check_rd` has been removed.

* `build` is now exported, and defaults to building in the package's parent
  directory. It also gains a new `binary` parameter controls whether a binary
  or a source version (with no vignettes or manuals) is built. Confusingly,
  binary packages are built with `R CMD INSTALL`.

* `build_win` sends your package to the R windows builder, allowing you to
  make a binary version of your package for windows users if you're using
  linux or a max (if you're using windows already, use `build(binary = T)`)

## Improvements and bug fixes

* if using `.Rpackages` config file, default function is used last, not first.

* on Windows, `devtools` now checks for the presence of `Rtools` on startup,
  and will automatically add it to the path if needed.

* `document` uses `roxygen2` instead of `roxygen`. It now loads package
  dependency so that they're available when roxygen executes the package
  source code.

* `document` has new parameter `clean` which clears all roxygen caches and
  removes all existing man files. `check` now runs `document` in this mode.

* `dev_mode` will create directories recursively, and complain if it can't
  create them.  It should also work better on windows.

* `install_github` now allows you to specify which branch to download, and
  automatically reloads package if needed.

* `reload` now will only reload if the package is already loaded.

* `release` gains `check` parameter that allows you to skip package check (if
  you've just done it.)

* `test` automatically reloads code so you never run tests on old code

# devtools 0.3

* new `bash()` function that starts bash shell in package directory. Useful if
  you want to use git etc.

* removed inelegant `update_src()` since now superseded by `bash()`

* fix bug in ftp upload that was adding extraneous space

* `build` function builds package in specified directory. `install`, `check`
  and `release` now all use this function.

* `build`, `install`, `check` and `release` better about cleaning up after
  themselves - always try to both work in session temporary directory and
  delete any files/directories that they create

# devtools 0.2

* `install_github` now uses `RCurl` instead of external `wget` to retrieve
  package. This should make it more robust wrt external dependencies.

* `load_all` will skip missing files with a warning (thanks to suggestion from Jeff Laake)

* `check` automatically deletes `.Rcheck` directory on successful completion

* Quote the path to R so it works even if there are spaces in the path.

# devtools 0.1

* Check for presence of `DESCRIPTION` when loading packages to avoid false
  positives

* `install` now works correctly with `devel_mode` to install packages in your
  development library

* `release` prints news so you can more easily check it

* All `R CMD xxx` functions now use the current R, not the first R found on
  the system path.
