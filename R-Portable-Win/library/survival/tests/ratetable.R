options(na.action=na.exclude) # preserve missings
options(contrasts=c('contr.treatment', 'contr.poly')) #ensure constrast type
library(survival)

#
# Generate each of the messages from is.ratetable
#
{if (is.R()) mdy.date <- function(m, d, y) {
    y <- ifelse(y<100, y+1900, y)
    as.Date(paste(m,d,y, sep='/'), "%m/%d/%Y")
    }
else mdy.date <- function(m,d,y) {
    y <- ifelse(y<100, y+1900, y)
    timeDate(paste(y, m, d, sep='/'), in.format="%Y/%m/%d")
    }
 }

temp <- runif(21*2*4)

# Good
attributes(temp) <- list(dim=c(21,2,4),
    dimnames=list(c(as.character(75:95)), c("male","female"),
                  c(as.character(2000:2003))),
    dimid=c("age","sex","year"),
    type=c(2,1,4),
    cutpoints=list(c(75:95), NULL, mdy.date(1,1,2000) +c(0:3)*366.25),
    class='ratetable')
is.ratetable(temp)

# Factor problem + cutpoints length
attributes(temp) <- list(dim=c(21,2,4),
    dimnames=list(c(as.character(75:95)), c("male","female"),
                  c(as.character(2000:2003))),
    dimid=c("age","sex","year"),
    type=c(1,1,2),
    cutpoints=list(c(75:95), NULL, mdy.date(1,1,2000) +c(0:4)*366.25),
    class='ratetable')
is.ratetable(temp, verbose=T)
 
                    
# missing dimid attribute + unsorted cutpoint
attributes(temp) <- list(dim=c(21,2,4),
    dimnames=list(c(as.character(75:95)), c("male","female"),
                  c(as.character(2000:2003))),
    type=c(2,1,3),
    cutpoints=list(c(75:95), NULL, mdy.date(1,1,2000) +c(4:1)*366.25),
    class='ratetable')
is.ratetable(temp, verbose=T)

# wrong length for dimid and type, illegal type
attributes(temp) <- list(dim=c(21,2,4),
    dimnames=list(c(as.character(75:95)), c("male","female"),
                  c(as.character(2000:2003))),
    dimid=c("age","sex","year", "zed"),
    type=c(2,1,3,6),
    cutpoints=list(c(75:95), NULL, mdy.date(1,1,2000) +c(0:3)*366.25),
    class='ratetable')
is.ratetable(temp, verbose=T)


# Print and summary
print(survexp.us[1:30,,c('1953', '1985')] )
summary(survexp.usr)
