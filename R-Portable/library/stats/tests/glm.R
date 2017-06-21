## Example in which the fit for the null deviance fails to converge:
# https://stat.ethz.ch/pipermail/r-help/2012-May/313161.html
Y <- c(rep(0,35),1,2,0,6,8,16,43)
beta <- 42:1
cst <- lchoose(42, beta)
tau <- (beta^2)/2
fit <- glm(formula = Y ~ offset(cst) + beta + tau, family = poisson)
