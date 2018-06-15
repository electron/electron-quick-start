## initialize R simulations (also parallel workers)
## need to export the variables N, robustDoc and slave
if (!exists("N")) N <- 1000
if (!exists("robustDoc"))
    robustDoc <- system.file('doc', package='robustbase')

## load required packages
stopifnot(require(xtable),
          require(robustbase))

## load more packages if this is a worker
if (exists("slave"))
    stopifnot(require(robust),
              require(skewt),
              require(foreach))

## default data set
dd <- data.frame(X1 = c(0.0707996949791054, 0.0347546309449992,
                   1.30548268152542, 0.866041511462982,
                   0.275764343116733, 0.670798705161399,
                   -0.549345193993536, -1.00640134962924,
                   -1.22061169833477, -0.905619374719898,
                   -0.678473241822565, 0.607011706444643,
                   0.304237114526011, -2.14562816298790,
                   2.34057395639167, 0.310752185537814,
                   -0.972658170945796, 0.362012836241727,
                   0.925888071796771, -0.595380245695561),
                 X2 = c(0.119970864158429,
                   -0.738808741221796, 5.49659158913364,
                   3.52149647048925, 2.02079730735676,
                   3.82735326206246, -1.24025420267206,
                   -4.37015614526438, -5.00575484838141,
                   -3.56682651298729, -2.82581432351811,
                   0.0456819251791285, -0.93949674689997,
                   -8.08282316242221, 9.76283850058346,
                   0.866426786132133, -2.90670860898916,
                   2.95555226542630, 4.50904028657548,
                   -3.44910596474065),
                 X3 = c(1.11332914932289,
                   3.55583356836222, 10.4937363250789,
                   0.548517298224424, 1.67062103214174,
                   0.124224367717813, 6.86425894634543,
                   1.14254475111985, 0.612987848127285,
                   0.85062803777296, 0.881141283379239,
                   0.650457856125926, 0.641015255931405,
                   1.51667982973630, 0.764725309853834,
                   1.61169179152476, 0.596312457754167,
                   0.262270854360470, 1.24686336241,
                   0.386112727548389))

## load functions
source(file.path(robustDoc, 'simulation.functions.R'))
source(file.path(robustDoc, 'estimating.functions.R'))
source(file.path(robustDoc, 'error.distributions.R'))

## set estlist and parameters
estlist <- .estlist.confint
## nr. of repetitions
estlist$nrep <- N
estlist$seed <- 13082010
## set errors
estlist$errs <- c(estlist$errs,
                  list(.errs.skt.Inf.2,
                       .errs.skt.5.2,
                       .errs.cnorm..1.0.10,
                       .errs.cnorm..1.4.1))
