#  File src/library/stats/tests/nlm.R
#  Part of the R package, https://www.R-project.org
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  https://www.R-project.org/Licenses/

## nlm()  testing  ---- partly same as in ../demo/nlm.R
## NB: Strict regression tests -- output not "looked at"
library(stats)

## "truly 64 bit platform"
##  {have seen "x86-64" (instead of "x86_64") on Windows 2008 server}
(b.64 <- grepl("^x86.64", Sys.info()[["machine"]]) && .Machine$sizeof.pointer == 8)
(Lb64 <- b.64 && Sys.info()[["sysname"]] == "Linux")

## Example 1: Rosenbrock banana valley function (2 D)
##
f.Rosenb <- function(x1, x2) 100*(x2 - x1*x1)^2 + (1-x1)^2
grRosenb <- function(x1, x2) c(-400*x1*(x2 - x1*x1) - 2*(1-x1),
                               200*(x2 - x1*x1))
hessRosenb <- function(x1, x2) {
  a11 <- 2 - 400*x2 + 1200*x1*x1
  a21 <- -400*x1
  matrix(c(a11, a21, a21, 200), 2, 2)
}

fg <- function(x) {   # analytic gradient only
  x1 <- x[1]; x2 <- x[2]
  structure(f.Rosenb(x1, x2), "gradient" = grRosenb(x1, x2))
}
##
fgh <- function(x) {  # analytic gradient and Hessian
  x1 <- x[1];  x2 <- x[2]
  structure(f.Rosenb(x1, x2),
            "gradient" =  grRosenb(x1, x2),
            "hessian" = hessRosenb(x1, x2))
}

nlm3 <- function(x0, ...) {
    stopifnot(length(x0) == 2, is.numeric(x0))
    list(nl.f  = nlm(function(x) f.Rosenb(x[1],x[2]), x0, ...),
         nl.fg = nlm(fg , x0, ...),
         nl.fgh= nlm(fgh, x0, ...))
}

utils::str(l3.0 <- nlm3(x0 = c(-1.2, 1)))

chkNlm <- function(nlL, estimate, tols, codes.wanted = 1:2)
{
    stopifnot(is.list(nlL), ## nlL = list(<nlm>, <nlm>, <nlm>,...)
              sapply(nlL, is.list), lengths(nlL) == 5, # nlm(.) like
              is.numeric(estimate),
              is.list(tols), names(tols) %in% c("min","est","grad"),
              sapply(tols, is.numeric), unlist(tols) > 0)
    p <- length(estimate)
    n <- length(nlL)
    tols <- lapply(tols, rep_len, length.out = n)
    stopifnot(
        vapply(nlL, `[[`, pi, "minimum") <= tols$min,
        ##----
        abs(vapply(nlL, `[[`, estimate, "estimate") - estimate) <=
        rep(tols$est, each=p),
        ##----
        abs(vapply(nlL, `[[`, c(0,0), "gradient")) <= rep(tols$grad, each=p),
        ##----
        vapply(nlL, `[[`, 0L, "code") %in% codes.wanted)
}

chkNlm(l3.0, estimate = c(1,1),
       ##                  nl.f  nl.fg nl.fgh
       tols = list(min = c(1e-11,1e-17,1e-16),
                   est = c(4e-5, 1e-9, 1e-8),
                   grad= c(1e-6, 9e-9, 7e-7)))



## nl.fgh, the one with the Hessian had failed in R <= 3.4.0
## ------- and still is less accurate here than the gradient-only version

## all converge here, too,  fgh now being best
utils::str(l3.10 <- nlm3(x0 = c(-10, 10), ndigit = 14, gradtol = 1e-8))

## These tolerances were plucked from thin air: reduced for 32-bit Linux
chkNlm(l3.10, estimate = c(1,1), # lower tolerances now, notably for fgh:
       ##                  nl.f   nl.fg  nl.fgh
       tols = list(min = c(1e-9, 1e-20, 1e-16),
                   est = c(2e-5,  1e-10, 1e-14),
                   grad= c(1e-3,  6e-9 , 1e-12)),
       codes.wanted = if(Lb64) 1:2 else 1:3)

## all 3 fail to converge here
utils::str(l3.1c <- nlm3(x0 = c(-100, 100), iterlim = 1000))
## i.e., all convergence codes > 1:
sapply(l3.1c, `[[`, "code")
## nl.f  nl.fg nl.fgh  (seen on 32-bit and 64-bit)
##    2      2      4
