## Example in which the fit for the null deviance fails to converge:
# https://stat.ethz.ch/pipermail/r-help/2012-May/313161.html
Y <- c(rep(0,35),1,2,0,6,8,16,43)
beta <- 42:1
cst <- lchoose(42, beta)
tau <- (beta^2)/2
fit <- glm(formula = Y ~ offset(cst) + beta + tau, family = poisson)

## Ensure make.link() consistency:
linkNames <- c("logit", "probit", "cauchit", "cloglog",
               "identity",
               "log",  "sqrt",  "1/mu^2", "inverse")
links <- lapply(setNames(,linkNames), make.link)
fns <- c("linkfun", "linkinv", "mu.eta", "valideta")
stopifnot(exprs = {
    is.matrix(nms <- sapply(links, names)) # matching number & type
    is.character(nms)
    nms[,1] == nms ## all columns are the same
    identical(setNames(,linkNames), vapply(links, `[[`, "", "name"))
    fns %in% nms[,1]
})
links <- lapply(links, `[`, fns) # functions only
stopifnot(unlist(lapply(links, function(L) vapply(L, is.function, NA))))
## all functions having consistent arguments :
lf <- lapply(links, function(L) lapply(L, formals))
stopifnot(exprs = { ## all functions have 1 argument
    unlist(lapply(lf, lengths), recursive=FALSE) == 1L
    is.matrix(argNms <- sapply(lf, function(L) vapply(L, names, "")))
    argNms[,1] == argNms ## all columns are the same
})
noquote(t(argNms))

## Calling all functions
## 1. valideta
stopifnot(vv <- vapply(links, function(L) L$valideta((1:3)/4), NA))
## 2. all others
other <- fns != "valideta"
str(linkO <- lapply(links, function(L) L[other]))
v <- sapply(linkO, function(L) sapply(L, function(F) F((0:4)/4)),
            simplify = "array")
stopifnot(exprs = {
    is.numeric(v)
    identical(dim(v), c(5L, sum(other), length(links)))
    identical(dimnames(v)[[2]], fns[other])
    ## check that all functions are monotone (incr. _or_ decr.) <==>
    ## signs of differences are constant <==> var(*) == 0
    apply(v, 2:3, function(f) var(sign(diff(f))) == 0)
})

## Could further check  [for 'okLinks' of given families]:
##	<family>(          "<linkname>")  ==
##      <family>(make.link("<linkname>"))


## <family>$aic() vs logLik() vs AIC() -- for Gamma:
# From example(glm) :
clotting <- data.frame(
    u    = c( 5, 10,15,20,30,40,60,80,100),
    lot1 = c(118,58,42,35,27,25,21,19,18),
    lot2 = c(69, 35,26,21,18,16,13,12,12))
summary(fm1 <- glm(lot1 ~ log(u), data = clotting, family = Gamma))
summary(fm2 <- glm(lot2 ~ log(u), data = clotting, family = Gamma))

hasDisp <- 1 # have dispersion (here, but not e.g., for binomial, poisson)
for(fm in list(fm1, fm2)) {
    print(ll <- logLik(fm))
    p <- attr(ll, "df")
    A0 <- AIC(fm)
    A1 <- -2*c(ll) + 2*p
    aic.v <- fm$family$aic(y  = fm$y, mu = fitted(fm),
                           wt = weights(fm), dev= deviance(fm))
    stopifnot(p == (p. <- length(coef(fm))) + hasDisp,
              all.equal(-2*c(ll) + 2*hasDisp, aic.v)) # <fam>$aic() = -2 * loglik + 2s
    A2 <- aic.v + 2 * p.
    stopifnot(exprs = {
        all.equal(A0, A1)
        all.equal(A1, A2)
        all.equal(A1, fm$aic)
    })
}


