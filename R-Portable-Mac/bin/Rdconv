# ${R_HOME}/bin/Rdconv -*- sh -*- for installing add-on packages

args=
while test -n "${1}"; do
  ## quote each argument here, unquote in R code.
  args="${args}nextArg${1}"
  shift
done

## NB: Apple's ICU needs LC_COLLATE set when R is started.
echo 'tools:::.Rdconv()' | R_DEFAULT_PACKAGES= LC_COLLATE=C "${R_HOME}/bin/R" --vanilla --slave --args ${args}
