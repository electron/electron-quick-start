swf <- function(x) {
##   Schwefel problem
##
##   -500 <= xi <= 500, i = {1, 2, ..., n}
##   The number of local minima for a given n is not known, but the global minimum
##   f(x*) = -418.9829n is located at x* = (s, s, ..., s), s = 420.97.
##
##   Source:
##     Ali, M. Montaz, Khompatraporn, Charoenchai, and Zabinsky, Zelda B. (2005).
##     A numerical evaluation of several stochastic algorithms on selected
##     continuous global optimization test problems.
##     Journal of Global Optimization 31, 635-672.

    -crossprod( x, sin(sqrt(abs(x))) )
}

sf1 <- function(x) {
    ##   Schaffer 1 problem
    ##
    ##   -100 <= x1, x2 <= 100
    ##   The number of local minima is not known but
    ##   the global minimum is located at x* = (0, 0) with f(x*) = 0.
    ##
    ##   Source:
    ##     Ali, M. Montaz, Khompatraporn, Charoenchai, and Zabinsky, Zelda B. (2005).
    ##     A numerical evaluation of several stochastic algorithms on selected
    ##     continuous global optimization test problems.
    ##     Journal of Global Optimization 31, 635-672.

    temp <- x[1]^2 + x[2]^2
    0.5 + (sin(sqrt(temp))^2 - 0.5)/(1 + 0.001*temp)^2
}

RND <-
    list(obj = function(x) {
        ##   Reactor network design
        ##
        ##   1e-5 <= x5, x6 <= 16
        ##   It possesses two local solutions at x = (16, 0) with f = -0.37461
        ##   and at x = (0, 16) with f = -0.38808.
        ##   The global optimum is (x5, x6; f) = (3.036504, 5.096052; -0.388812).
        ##
        ##   Source:
        ##     Babu, B. V., and Angira, Rakesh (2006).
        ##     Modified differential evolution (MDE) for optimization of nonlinear
        ##     chemical processes.
        ##     Computers and Chemical Engineering 30, 989-1002.

        x5 <- x[1]; x6 <- x[2]
        k1 <- 0.09755988; k2 <- 0.99*k1; k3 <- 0.0391908; k4 <- 0.9*k3
        -( k2*x6*(1 + k3*x5) +
           k1*x5*(1 + k2*x6) ) /
              ( (1 + k1*x5)*(1 + k2*x6)*
                (1 + k3*x5)*(1 + k4*x6) )
    },
         con = function(x) sqrt(x[1]) + sqrt(x[2]) - 4
         )

HEND <-
    list(obj = function(x) {
        ##   Heat exchanger network design
        ##
        ##   100 <= x1 <= 10000,   1000 <= x2, x3 <= 10000,
        ##   10 <= x4, x5 <= 1000
        ##   The global optimum is (x1, x2, x3, x4, x5; f) = (579.19, 1360.13,
        ##   5109.92, 182.01, 295.60; 7049.25).
        ##
        ##   Source:
        ##     Babu, B. V., and Angira, Rakesh (2006).
        ##     Modified differential evolution (MDE) for optimization of nonlinear
        ##     chemical processes.
        ##     Computers and Chemical Engineering 30, 989-1002.

        x[1] + x[2] + x[3]
    },
         con = function(x) {
             x1 <- x[1]; x2 <- x[2]; x3 <- x[3]; x4 <- x[4]; x5 <- x[5]
             c(100*x1 - x1*(400 -x4) + 833.33252*x4 -83333.333,
               x2*x4 - x2*(400 - x5 + x4) - 1250*x4 + 1250*x5,
               x3*x5 - x3*(100 + x5) - 2500*x5 + 1250000)
         })

alkylation <-
    list(obj = function(x) {
        ##   Optimal operation of alkylation unit
        ##
        ##   Variable   Lower Bound   Upper Bound
        ##   ------------------------------------
        ##   x1                1500          2000
        ##   x2                   1           120
        ##   x3                3000          3500
        ##   x4                  85            93
        ##   x5                  90            95
        ##   x6                   3            12
        ##   x7                 145           162
        ##   ------------------------------------
        ##   The maximum profit is $1766.36 per day, and the optimal
        ##   variable values are x1 = 1698.256922, x2 = 54.274463, x3 = 3031.357313,
        ##   x4 = 90.190233, x5 = 95.0, x6 = 10.504119, x7 = 153.535355.
        ##
        ##   Source:
        ##     Babu, B. V., and Angira, Rakesh (2006).
        ##     Modified differential evolution (MDE) for optimization of nonlinear
        ##     chemical processes.
        ##     Computers and Chemical Engineering 30, 989-1002.

        x1 <- x[1]; x3 <- x[3]
        1.715*x1 + 0.035*x1*x[6] + 4.0565*x3 +10.0*x[2] - 0.063*x3*x[5]
    },
         con = function(x) {
             x1 <- x[1]; x2 <- x[2]; x3 <- x[3]; x4 <- x[4]
             x5 <- x[5]; x6 <- x[6]; x7 <- x[7]
             c(0.0059553571*x6^2*x1 + 0.88392857*x3 - 0.1175625*x6*x1 - x1,
               1.1088*x1 + 0.1303533*x1*x6 - 0.0066033*x1*x6^2 - x3,
               6.66173269*x6^2 + 172.39878*x5 -56.596669*x4 - 191.20592*x6 - 10000,
               1.08702*x6 + 0.32175*x4 - 0.03762*x6^2 - x5 + 56.85075,
               0.006198*x7*x4*x3 + 2462.3121*x2 -25.125634*x2*x4 - x3*x4,
               161.18996*x3*x4 + 5000.0*x2*x4 - 489510.0*x2 - x3*x4*x7,
               0.33*x7 - x5 + 44.333333,
               0.022556*x5 - 0.007595*x7 - 1.0,
               0.00061*x3 - 0.0005*x1 - 1.0,
               0.819672*x1 - x3 + 0.819672,
               24500.0*x2 - 250.0*x2*x4 - x3*x4,
               1020.4082*x4*x2 - 1.2244898*x3*x4 - 100000*x2,
               6.25*x1*x6 + 6.25*x1 - 7.625*x3 - 100000,
               1.22*x3 - x6*x1 - x1 + 1.0)
         })
