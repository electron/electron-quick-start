#-*- R -*-

## Script from Fourth Edition of `Modern Applied Statistics with S'

# Chapter 2   Data Manipulation

library(MASS)
options(width=65, digits=5, height=9999)

-2:2

powers.of.pi <- pi^(-2:2)
powers.of.pi
class(powers.of.pi)

print(powers.of.pi)
summary(powers.of.pi)

# rm(powers.of.pi)

powers.of.pi[5]

names(powers.of.pi) <- -2:2
powers.of.pi
powers.of.pi["2"]
class(powers.of.pi)

as.vector(powers.of.pi)
names(powers.of.pi) <- NULL
powers.of.pi

citizen <- factor(c("uk", "us", "no", "au", "uk", "us", "us"))
citizen

unclass(citizen)

citizen[5:7]

citizen <- factor(c("uk", "us", "no", "au", "uk", "us", "us"),
                   levels = c("us", "fr", "no", "au", "uk"))
citizen

income <- ordered(c("Mid", "Hi", "Lo", "Mid", "Lo", "Hi", "Lo"))
income

as.numeric(income)

inc <- ordered(c("Mid", "Hi", "Lo", "Mid", "Lo", "Hi", "Lo"),
                levels = c("Lo", "Mid", "Hi"))
inc

erupt <- cut(geyser$duration, breaks = 0:6)
erupt <- ordered(erupt, labels=levels(erupt))
erupt

painters
row.names(painters)

summary(painters) # try it!

attach(painters)
School
detach("painters")

mymat <- matrix(1:30, 3, 10)
mymat

myarr <- mymat
dim(myarr) <- c(3, 5, 2)
class(myarr)
myarr
dim(myarr)

dimnames(myarr) <- list(letters[1:3], NULL, c("(i)", "(ii)"))
myarr

newvar <- NA
class(NA)

newvar > 3

x <- c(pi, 4, 5)
x[2] <- NA
x
class(x)

is.na(x)

1/0

x <- c(-1, 0, 1)/0
x
is.na(x)
x > Inf

x <- c(2.9, 3.1, 3.4, 3.4, 3.7, 3.7, 2.8, 2.5)



letters[1:3]
letters[c(1:3,3:1)]

longitude <- state.center$x
names(longitude) <- state.name
longitude[c("Hawaii", "Alaska")]

myarr[1, 2:4, ]
myarr[1, 2:4, , drop = FALSE]

attach(painters)
painters[Colour >= 17, ]

painters[Colour >= 15 & Composition > 10, ]
painters[Colour >= 15 & School != "D", ]

painters[is.element(School, c("A", "B", "D")), ]
painters[School %in% c("A", "B", "D"), ]   ## R only

painters[cbind(1:nrow(painters), ifelse(Colour > Expression, 3, 4))]

painters[grep("io$", row.names(painters)), ]

detach("painters")

m <- 30
fglsub1 <- fgl[sort(sample(1:nrow(fgl), m)), ]

fglsub2 <- fgl[rbinom(nrow(fgl), 1, 0.1) == 1, ]

fglsub3 <- fgl[seq(1, nrow(fgl), by = 10), ]

painters[sort.list(row.names(painters)), ]


lcrabs <- crabs  # make a copy
lcrabs[, 4:8] <- log(crabs[, 4:8])

scrabs <- crabs  # make a copy
scrabs[, 4:8] <- lapply(scrabs[, 4:8], scale)
## or to just centre the variables
scrabs[, 4:8] <- lapply(scrabs[, 4:8], scale, scale = FALSE)

scrabs <- crabs  # make a copy
scrabs[ ] <- lapply(scrabs,
   function(x) {if(is.numeric(x)) scale(x) else x})

sapply(crabs, is.numeric)

by(crabs[, 4:8], list(crabs$sp, crabs$sex), summary)

aggregate(crabs[, 4:8], by = list(sp=crabs$sp, sex=crabs$sex),
           median)

authors <- data.frame(
         surname = c("Tukey", "Venables", "Tierney", "Ripley", "McNeil"),
         nationality = c("US", "Australia", "US", "UK", "Australia"),
         deceased = c("yes", rep("no", 4)))
books <- data.frame(
         name = c("Tukey", "Venables", "Tierney",
                  "Ripley", "Ripley", "McNeil", "R Core"),
         title = c("Exploratory Data Analysis",
                   "Modern Applied Statistics ...",
                   "LISP-STAT",
                   "Spatial Statistics", "Stochastic Simulation",
                   "Interactive Data Analysis",
                   "An Introduction to R"))

authors
books

merge(authors, books, by.x = "surname", by.y = "name")

attach(quine)
table(Age)
table(Sex, Age)

tab <- xtabs(~ Sex + Age, quine)
unclass(tab)

tapply(Days, Age, mean)

tapply(Days, Age, mean, trim = 0.1)

tapply(Days, list(Sex, Age), mean)

tapply(Days, list(Sex, Age),
        function(x) sqrt(var(x)/length(x)))

quineFO <- quine[sapply(quine, is.factor)]

#tab <- do.call("table", quineFO)
tab <- table(quineFO)

QuineF <- expand.grid(lapply(quineFO, levels))

QuineF$Freq <- as.vector(tab)
QuineF

# End of ch02
