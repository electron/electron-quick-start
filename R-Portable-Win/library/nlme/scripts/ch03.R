#-*- R -*-

# initialization

library(nlme)
options(width = 65, digits = 5)
options(contrasts = c(unordered = "contr.helmert", ordered = "contr.poly"))
pdf(file = 'ch03.pdf')

# Chapter 3    Describing the Structure of Grouped Data

# 3.1 The Display Formula and Its Components

formula( Rail )
formula( ergoStool )
formula( Machines )
formula( Orthodont )
formula( Pixel )
formula( Oats )
table( Oxboys$Subject )
table( getGroups( Oxboys ) )
unique( table( getGroups( Oxboys ) ) )  # a more concise result
unique( table( getCovariate( Oxboys ), getGroups( Oxboys ) ) )
length( unique( getCovariate( Oxboys ) ) )
unique( getGroups(Pixel, level = 1) )
unique( getGroups(Pixel, level = 2) )
Pixel.groups <- getGroups( Pixel, level = 1:2 )
class( Pixel.groups )
names( Pixel.groups )
unique( Pixel.groups[["Side"]] )
formula( PBG )
PBG.log <- update( PBG, formula = deltaBP ~ log(dose) | Rabbit )
formula(PBG.log)
unique( getCovariate(PBG.log) )
unique( getCovariate(PBG) )

# 3.2 Constructing groupedData Objects

# The next line is not from the book.
# It is added to ensure that the file is available

write.table( Oxboys, "oxboys.dat" )

Oxboys.frm <- read.table( "oxboys.dat", header = TRUE )
class( Oxboys.frm )        # check the class of the result
dim( Oxboys.frm )          # check the dimensions
Oxboys <- groupedData( height ~ age | Subject,
   data = read.table("oxboys.dat", header = TRUE),
   labels = list(x = "Centered age", y = "Height"),
   units = list(y = "(cm)") )
Oxboys                     # display the object
unique( getGroups( Oxboys ) )
plot( BodyWeight, outer = ~ Diet, aspect = 3 )  # Figure 3.3
plot( BodyWeight, outer = TRUE, aspect = 3 )
plot( Soybean, outer = ~ Year * Variety )       # Figure 6.10
plot( Soybean, outer = ~ Variety * Year )
gsummary( BodyWeight, invar = TRUE )
plot( PBG, inner = ~ Treatment, scales = list(x = list(log = 2)))
ergoStool.mat <- asTable( ergoStool )
ergoStool.mat
ergoStool.new <- balancedGrouped( effort ~ Type | Subject,
                                   data = ergoStool.mat )
ergoStool.new

# 3.3 Controlling Trellis Graphics Presentations of Grouped Data

plot(CO2, layout=c(6,2), between=list(x=c(0,0,0.5,0,0)))
plot( Spruce, layout = c(7, 4, 3),
       skip = c(rep(FALSE, 27), TRUE, rep(FALSE, 27), TRUE,
                rep(FALSE, 12), rep(TRUE, 2), rep(FALSE,13)) )
plot( Spruce, layout = c(9, 3, 3),
       skip = c(rep(FALSE, 66), TRUE, TRUE, rep(FALSE, 13)) )
unique( getCovariate(DNase) )
log( unique(getCovariate(DNase)), 2 )
plot( DNase, layout=c(6,2), scales = list(x=list(log=2)) )
plot(Pixel, layout = c(4,5),
     between = list(x = c(0, 0.5, 0), y = 0.5))
plot( Pixel, displayLevel = 1 )
plot( Wafer, display = 1, collapse = 1 )
plot( Wafer, display = 1, collapse = 1,
       FUN = function(x) sqrt(var(x)), layout = c(10,1) )

# 3.4 Summaries

sapply( ergoStool, data.class )
gsummary( Theoph, inv = TRUE )
gsummary( Theoph, omit = TRUE, inv = TRUE )
is.null(gsummary(Theoph, inv = TRUE, omit = TRUE)) # invariants present
is.null(gsummary(Oxboys, inv = TRUE, omit = TRUE)) # no invariants
gsummary( Theoph )
gsummary( Theoph, FUN = max, omit = TRUE )
Quin.sum <- gsummary( Quinidine, omit = TRUE, FUN = mean )
dim( Quin.sum )
Quin.sum[1:10, ]
Quinidine[Quinidine[["Subject"]] == 3, 1:8]
Quin.sum1 <- gsummary( Quinidine, omit = TRUE )
Quin.sum1[1:10, 1:7]
summary( Quin.sum1 )
summary( Quinidine )
sum( ifelse(is.na(Quinidine[["conc"]]), 0, 1) )
sum( !is.na(Quinidine[["conc"]]) )
sum( !is.na(Quinidine[["dose"]]) )
gapply( Quinidine, "conc", function(x) sum(!is.na(x)) )
table( gapply(Quinidine, "conc", function(x) sum(!is.na(x))) )
changeRecords <- gapply( Quinidine, FUN = function(frm)
    any(is.na(frm[["conc"]]) & is.na(frm[["dose"]])) )
changeRecords
sort( as.numeric( names(changeRecords)[changeRecords] ) )
Quinidine[29:31,]
Quinidine[Quinidine[["Subject"]] == 4, ]

# cleanup

proc.time()


