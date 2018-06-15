### R code from vignette source 'tradelist.Rnw'

###################################################
### code chunk number 1: tradelist.Rnw:40-45
###################################################
## Sets display options
options(width = 75, digits = 2, scipen = 5)
set.seed(0)
## Loads the package 
library(portfolio) 


###################################################
### code chunk number 2: tradelist.Rnw:48-65
###################################################
## data saved for this example

## save(portfolios, misc, data.list, mvCandidates, file = "tradelist.RData", compress = TRUE)

## loads the dataset for this vignette

load("tradelist.RData")

p.current <- portfolios[["p.current.abs"]]
p.target <- portfolios[["p.target.abs"]]
data <- data.list[["data.abs"]]

sorts <- list(alpha = 1.5, ret.1.d = 1)

tl <- new("tradelist", orig = p.current, target = p.target, sorts =
sorts, turnover = 2000, chunk.usd = 2000, data = data, to.equity = FALSE)



###################################################
### code chunk number 3: p.current@shares
###################################################
p.current@shares[, c("shares", "price")]


###################################################
### code chunk number 4: p.target@shares
###################################################
p.target@shares[, c("shares", "price")]


###################################################
### code chunk number 5: tradelist.Rnw:252-253
###################################################
tl@candidates[, c("side", "shares", "mv")]


###################################################
### code chunk number 6: shows alpha sort
###################################################
tmp <- data.frame(side = tl@candidates[, "side"], alpha =  tl@ranks[, "alpha"])
row.names(tmp) <- tl@candidates$id
tmp  <- tmp[order(tmp$alpha, decreasing = TRUE),]
tmp


###################################################
### code chunk number 7: trades ranked and ordered by alpha
###################################################

## for buys, ranks by the inverse because lower values are better
tl@ranks$rank <- rank(-tl@ranks$alpha, na.last = TRUE,  ties.method = "random")

## removes the "ret.1.d" column for successful row binding later on
alpha <- tl@ranks[,!names(tl@ranks) %in% "ret.1.d"]

## appends a column so we know what sort these values come from
alpha$sort <- "alpha"

alpha[order(alpha$rank), c("rank", "side", "alpha", "shares", "mv")]


###################################################
### code chunk number 8: ret.1.d sort
###################################################
tmp <- tl@ranks[order(tl@ranks$ret.1.d), c("side","ret.1.d")]
tmp <- cbind(rank = 1:nrow(tmp), tmp)
tmp$ret.1.d <- tmp$ret.1.d[order(tmp$ret.1.d, decreasing = TRUE)]
row.names(tmp) <- tl@candidates$id


###################################################
### code chunk number 9: two sorts sorting by alpha
###################################################
tmp.1 <- tl@ranks[order(tl@ranks$alpha, decreasing = TRUE), c("alpha", "ret.1.d")]
tmp.1 <- tmp.1 <- cbind(rank = 1:nrow(tmp.1), tmp.1)
tmp.1


###################################################
### code chunk number 10: two sorts sorting by ret.1.d
###################################################
tmp.2 <- tl@ranks[order(tl@ranks$ret.1.d, decreasing = TRUE), c("alpha", "ret.1.d")]
tmp.2 <- cbind(rank = 1:nrow(tmp.2), tmp.2)
tmp.2


###################################################
### code chunk number 11: trades ranked and ordered by ret.1.d
###################################################
## we don't actually show any of these values right here
## for buys, ranks by the inverse because lower values are better
tl@ranks$rank <- rank(-tl@ranks$ret.1.d, na.last = TRUE, ties.method = "random")
## removes the "alpha" column for successful row binding later on
ret.1.d <- tl@ranks[,!names(tl@ranks) %in% "alpha"]
## appends a column so we know what sort these values come from
ret.1.d$sort <- "ret.1.d"


###################################################
### code chunk number 12: weighted alpha
###################################################
## saves off alpha$rank
alpha.rank.orig <- alpha$rank

alpha$rank <- alpha$rank
alpha[order(alpha$rank), c("rank", "side", "alpha", "shares", "mv")]


###################################################
### code chunk number 13: unweighted ret.1.d
###################################################
ret.1.d[order(ret.1.d$rank), c("rank", "side", "ret.1.d", "shares", "mv")]


###################################################
### code chunk number 14: unweighted ranks
###################################################

## sets the ranks of alpha to the original, unweighted ranks
alpha$rank <- alpha.rank.orig

## subsets out the "alpha" and "ret.1.d" columns so that both data frames have the same set of columns
alpha   <- alpha[,!names(alpha) %in% "alpha"]
ret.1.d <- ret.1.d[,!names(ret.1.d) %in% "ret.1.d"]

overall.ranks <- rbind(alpha, ret.1.d)
overall.ranks <- overall.ranks[order(overall.ranks$rank), c("id", "sort", "rank", "side", "shares", "mv")]
row.names(overall.ranks) <- paste(overall.ranks$id, overall.ranks$sort, sep = ".")
overall.ranks[, c("rank", "sort", "side", "shares", "mv")]


###################################################
### code chunk number 15: unweighted w/out duplicates
###################################################

ranks <- alpha
top.ranks <- aggregate(overall.ranks[c("rank")], by = list(id = overall.ranks$id), min)
ranks$rank <- top.ranks$rank[match(ranks$id, top.ranks$id)]
ranks[order(ranks$rank), c("rank", "shares", "mv")]


###################################################
### code chunk number 16: unbalanced weights
###################################################
## Assigns one sort, alpha, a much higher weight than the other sort

## restores the original alpha rankings

alpha$rank <- alpha.rank.orig

## weights the alpha rankings by 10

alpha$rank <- alpha$rank / 10

overall.ranks <- data.frame()
overall.ranks <- rbind(alpha, ret.1.d)
overall.ranks <- overall.ranks[order(overall.ranks$rank), c("id", "sort", "rank", "side", "shares", "mv")]
row.names(overall.ranks) <- paste(overall.ranks$id, overall.ranks$sort, sep = ".")
overall.ranks[c("rank", "side", "shares", "mv")]


###################################################
### code chunk number 17: unbalanced w/out duplicates
###################################################

top.ranks <- do.call(rbind, lapply(split(overall.ranks, overall.ranks$id),
                                   function(x) { x[which.min(x$rank),] }))
top.ranks <- top.ranks[order(top.ranks$rank),]
top.ranks[c("rank","sort","shares","mv")]

ranks <- alpha
top.ranks <- aggregate(overall.ranks[c("rank")], by = list(id = overall.ranks$id), min)
ranks$rank <- top.ranks$rank[match(ranks$id, top.ranks$id)]
## ranks[order(ranks$rank), c("rank", "sort", "shares", "mv")]


###################################################
### code chunk number 18: mixed weighting
###################################################

## returns alpha$rank to original level

alpha$rank <- alpha.rank.orig
alpha$rank <- alpha$rank / 1.5

overall.ranks <- data.frame()
overall.ranks <- rbind(alpha, ret.1.d)
overall.ranks <- overall.ranks[order(overall.ranks$rank), c("id", "sort", "rank", "side", "shares", "mv")]
row.names(overall.ranks) <- paste(overall.ranks$id, overall.ranks$sort, sep = ".")
overall.ranks[c("rank", "side", "shares", "mv")]


###################################################
### code chunk number 19: mixed w/out duplicates
###################################################

top.ranks <- do.call(rbind, lapply(split(overall.ranks, overall.ranks$id),
                                   function(x) { x[which.min(x$rank),] }))
top.ranks <- top.ranks[order(top.ranks$rank),]
top.ranks[c("rank","sort","shares","mv")]

ranks <- alpha
top.ranks <- aggregate(overall.ranks[c("rank")], by = list(id = overall.ranks$id), min)
ranks$rank <- top.ranks$rank[match(ranks$id, top.ranks$id)]
tmp <- ranks[order(ranks$rank), c("rank", "sort", "shares", "mv")]
## tmp


###################################################
### code chunk number 20: tradelist.Rnw:680-682
###################################################
tmp$rank <- rank(tmp$rank, ties.method = "first")
tmp[order(tmp$rank),c("rank","shares","mv")]


###################################################
### code chunk number 21: scaling ranks
###################################################

## a hacked version of the scaling function in calcRanks, built only
## for a list of all buys

r.max  <- max(tmp$rank) + 1
r.mult <- 0.15
r.add  <- 0.85

tmp$rank.s <- (r.mult * tmp$rank[nrow(tmp):1] / r.max) + r.add

## Saves off rank.s for later use
rank.s <- tmp

tmp[c("rank","shares","mv","rank.s")]


###################################################
### code chunk number 22: synthesised ranks
###################################################
tmp$rank.t <- qnorm(tmp$rank.s)
tmp[c("rank", "shares", "mv","rank.s", "rank.t")]


###################################################
### code chunk number 23: chunk w/out tca.rank
###################################################
tl@chunks[order(-tl@chunks$rank.t), c("side", "shares", "mv", "alpha", "ret.1.d", "rank.t", "chunk.shares", "chunk.mv")]


###################################################
### code chunk number 24: trading volume
###################################################
trading.volume <- data.frame(rank.t = tl@ranks$rank.t, volume = tl@data$volume[match(tl@ranks$id, tl@data$id)], shares = tl@ranks$shares)
row.names(trading.volume) <- tl@ranks$id
trading.volume[order(-trading.volume$rank.t),]


###################################################
### code chunk number 25: chunks w/ tca.rank
###################################################

tl@chunks[order(-tl@chunks$rank.t), c("side", "mv", "alpha", "ret.1.d",
                                      "rank.t", "chunk.shares", "chunk.mv", "tca.rank")]


###################################################
### code chunk number 26: ordered chunks w/ tca.rank
###################################################

tl@chunks[order(tl@chunks$tca.rank, decreasing = TRUE), c("side",
              "mv", "alpha", "ret.1.d", "rank.t", "chunk.shares",
              "chunk.mv", "tca.rank")]


###################################################
### code chunk number 27: rank.s
###################################################
rank.s[c("rank","shares","mv","rank.s")]


###################################################
### code chunk number 28: rank.t
###################################################
rank.t <- rank.s
rank.t$rank.t <- qnorm(rank.t$rank.s)
rank.t[c("rank","shares","mv","rank.s","rank.t")]


###################################################
### code chunk number 29: misc$rank.s
###################################################
misc$rank.s


###################################################
### code chunk number 30: swaps table
###################################################
head(tl@swaps[, c("tca.rank.enter", "tca.rank.exit",
"rank.gain")])


###################################################
### code chunk number 31: tradelist.Rnw:1239-1241
###################################################
tl@swaps.actual[, c("tca.rank.enter", "tca.rank.exit",
"rank.gain")]


###################################################
### code chunk number 32: remove idiots
###################################################

tl@chunks.actual[, c("side", "mv", "alpha", "ret.1.d", "rank.t",
              "chunk.shares", "chunk.mv", "tca.rank")]


###################################################
### code chunk number 33: tradelist.Rnw:1264-1265
###################################################
tl@actual[, !names(tl@actual) %in% c("id")]


###################################################
### code chunk number 34: tradelist.Rnw:2328-2359
###################################################

## Clears the search list.

rm(list = ls())
load("tradelist.RData")

## prepares data for this example

p.current <- portfolios[["p.current.lo"]]
p.target <- portfolios[["p.target.lo"]]
data <- data.list[["data.lo"]]

## Original Equity, Target Equity

oe <- portfolio:::mvShort(p.current) + portfolio:::mvLong(p.current)
te <- portfolio:::mvShort(p.target) + portfolio:::mvLong(p.target)

## Creates the sorts list

sorts <- list(alpha = 1, ret.1.d = 1.1)

## Creates the tradelist so we can use different measures

tl <- new("tradelist", orig = p.current, target = p.target, chunk.usd
= 2000, sorts = sorts, turnover = 30250, target.equity = te, data =
data)

## Necessary turnover to make all the candidate trades

nt <- mvCandidates(tl)



###################################################
### code chunk number 35: prep-p.current.shares
###################################################
p.current.shares <- p.current@shares[, c("shares", "price")]


###################################################
### code chunk number 36: p.current.shares
###################################################
p.current.shares


###################################################
### code chunk number 37: tradelist.Rnw:2386-2387
###################################################
p.target.shares <- p.target@shares[, c("shares", "price")]


###################################################
### code chunk number 38: tradelist.Rnw:2390-2391
###################################################
p.target.shares


###################################################
### code chunk number 39: tradelist.Rnw:2400-2401
###################################################
sub.candidates <- tl@candidates[,!names(tl@candidates) %in% "id"]


###################################################
### code chunk number 40: long-only candidates
###################################################
sub.candidates


###################################################
### code chunk number 41: tradelist.Rnw:2416-2417
###################################################
sorts <- list(alpha = 1, ret.1.d = 1.1)


###################################################
### code chunk number 42: tradelist.Rnw:2430-2432
###################################################
row.names(data) <- data$id
sub.data <- data[, c("id", "volume", "price.usd", "alpha", "ret.1.d")]


###################################################
### code chunk number 43: necessary data
###################################################
sub.data


###################################################
### code chunk number 44: new long-only tl
###################################################

tl <- new("tradelist", orig = p.current, target = p.target, chunk.usd
= 2000, sorts = sorts, turnover = 30250, data = data)



###################################################
### code chunk number 45: tradelist.Rnw:2457-2462
###################################################

tl <- new("tradelist", orig = p.current, target = p.target, chunk.usd
= 2000, sorts = sorts, turnover = 30250, target.equity = 47500, data =
data)



###################################################
### code chunk number 46: tl@candidates
###################################################
tl@candidates


###################################################
### code chunk number 47: tradelist.Rnw:2568-2575
###################################################

ranks <- tl@rank.sorts$ret.1.d
ranks <- split(ranks, ranks$side)
ranks$B$rank <- 1:nrow(ranks$B)
ranks$S$rank <- 1:nrow(ranks$S)
ranks



###################################################
### code chunk number 48: tradelist.Rnw:2600-2602
###################################################
tmp <- rbind(ranks$B, ranks$S)[order(rbind(ranks$B, ranks$S)[["rank"]]),]
tmp[,!names(tmp) %in% "id"]


###################################################
### code chunk number 49: tradelist.Rnw:2611-2612
###################################################
tl@rank.sorts[["alpha"]][,!names(tl@rank.sorts[["alpha"]]) %in% "id"]


###################################################
### code chunk number 50: lo weighted ranks
###################################################
ranks <- tl@rank.sorts[["ret.1.d"]]
ranks[["rank"]] <- ranks[["rank"]]/sorts[["ret.1.d"]]
ranks


###################################################
### code chunk number 51: tradelist.Rnw:2647-2648
###################################################
tl@rank.sorts[["alpha"]]


###################################################
### code chunk number 52: prep-duplicates
###################################################

alpha <- tl@rank.sorts[["alpha"]]
ret.1.d <- tl@rank.sorts[["ret.1.d"]]

alpha <- alpha[,!names(alpha) %in% "alpha"]
ret.1.d <- ret.1.d[,!names(ret.1.d) %in% "ret.1.d"]

duplicates <- rbind(alpha, ret.1.d)
duplicates <- duplicates[order(duplicates$id),]
row.names(duplicates) <- 1:nrow(duplicates)



###################################################
### code chunk number 53: duplicates
###################################################
duplicates


###################################################
### code chunk number 54: prep-top.ranks
###################################################
tl.ranks <- tl@ranks


###################################################
### code chunk number 55: top.ranks
###################################################
top.ranks <- aggregate(duplicates[c("rank")], by = list(id = duplicates$id), min)
tl.ranks$rank <- top.ranks$rank[match(tl.ranks$id, top.ranks$id)]
tl.ranks[order(tl.ranks$rank), !names(tl@ranks) %in% c("id", "alpha", "ret.1.d", "rank.t")]


###################################################
### code chunk number 56: tradelist.Rnw:2687-2692
###################################################

tl.ranks$rank <- rank(tl.ranks$rank)
tl.ranks <- tl.ranks[, !names(tl.ranks) %in% c("id", "alpha", "ret.1.d")]

tl.ranks[order(tl.ranks$rank), !names(tl@ranks) %in% c("id", "alpha", "ret.1.d", "rank.t")]


###################################################
### code chunk number 57: scaled.ranks.lo
###################################################
misc$scaled.ranks.lo


###################################################
### code chunk number 58: pre.rank.t
###################################################
tl.ranks <- tl@ranks[order(tl@ranks$rank.t),!names(tl.ranks) %in% "id"]


###################################################
### code chunk number 59: rank.t
###################################################
tl.ranks


###################################################
### code chunk number 60: prep-chunks
###################################################
sub.chunks <- tl@chunks[, c("side", "rank.t", "chunk.shares",
                           "chunk.mv", "tca.rank")]


###################################################
### code chunk number 61: chunks
###################################################
sub.chunks


###################################################
### code chunk number 62: ordered chunks
###################################################
head(sub.chunks[order(sub.chunks[["tca.rank"]]),])


###################################################
### code chunk number 63: prep-swaps
###################################################
swaps.sub <- tl@swaps[, c("side.enter", "tca.rank.enter", "side.exit", "tca.rank.exit",
"rank.gain")]


###################################################
### code chunk number 64: tradelist.Rnw:2791-2792
###################################################
swaps.sub


###################################################
### code chunk number 65: prep-swaps.actual
###################################################

sub.swaps.actual <- tl@swaps.actual[, c("side.enter", "tca.rank.enter", "side.exit", "tca.rank.exit",
"rank.gain")]



###################################################
### code chunk number 66: swaps.actual
###################################################
sub.swaps.actual


###################################################
### code chunk number 67: pre-turnover.text
###################################################
tl.bak <- tl


###################################################
### code chunk number 68: tradelist.Rnw:2843-2844
###################################################
tl@turnover <- 30250 - tl@chunk.usd


###################################################
### code chunk number 69: tradelist.Rnw:2847-2852
###################################################

tl <- portfolio:::calcSwapsActual(tl)
sub.swaps.actual <- tl@swaps.actual[, c("side.enter", "tca.rank.enter", "side.exit", "tca.rank.exit",
"rank.gain")]



###################################################
### code chunk number 70: sub.swaps.actual
###################################################
sub.swaps.actual


###################################################
### code chunk number 71: restores tl
###################################################
tl <- tl.bak


###################################################
### code chunk number 72: tradelist.Rnw:2878-2880
###################################################
sub.chunks.actual <- tl@chunks.actual[,!names(tl@chunks.actual)
%in% c("id", "orig", "target", "shares", "mv")]


###################################################
### code chunk number 73: sub.chunks.actual
###################################################
sub.chunks.actual


###################################################
### code chunk number 74: prep-tl.actual
###################################################
tl.actual <- tl@actual[, !names(tl@actual) %in% c("id")]


###################################################
### code chunk number 75: tl.actual
###################################################
tl.actual


###################################################
### code chunk number 76: tradelist.Rnw:2906-2937
###################################################

## clear the workspace for this example

rm(list = ls())
load("tradelist.RData")

## Set portfolios for long-short example
p.current <- portfolios[["p.current.ls"]]
p.target <- portfolios[["p.target.ls"]]

## retrieves data for the long-short portfolio
data <- data.list$data.ls

## Creates the sorts list

sorts <- list(alpha = 1, ret.1.d = 1/2)

## Original Equity, Target Equity

oe <- portfolio:::mvShort(p.current) + portfolio:::mvLong(p.current)
te <- portfolio:::mvShort(p.target) + portfolio:::mvLong(p.target)

## Creates the tradelist so we can use different measures

tl <- new("tradelist", orig = p.current, target = p.target, chunk.usd
= 2500, sorts = sorts, turnover = 36825, target.equity = te, data =
data)

## Necessary turnover to make all the candidate trades

 nt <- mvCandidates(tl)


###################################################
### code chunk number 77: prep-p.current.shares
###################################################
p.current.shares <- p.current@shares[, !names(p.current@shares) %in% "id"]


###################################################
### code chunk number 78: tradelist.Rnw:2957-2958
###################################################
p.current.shares


###################################################
### code chunk number 79: prep-p.target.shares
###################################################
p.target.shares <- p.target@shares[, !names(p.target@shares) %in% "id"]


###################################################
### code chunk number 80: p.target.shares
###################################################
p.target.shares


###################################################
### code chunk number 81: prep-sub.candidates
###################################################
sub.candidates <- tl@candidates[,!names(tl@candidates) %in% "id"]


###################################################
### code chunk number 82: sub.candidates
###################################################
sub.candidates


###################################################
### code chunk number 83: prep-restricted
###################################################
row.names(tl@restricted) <- 1:nrow(tl@restricted)


###################################################
### code chunk number 84: restricted
###################################################
tl@restricted


###################################################
### code chunk number 85: tradelist.Rnw:3036-3037
###################################################
sorts <- list(alpha = 1, ret.1.d = 1/2)


###################################################
### code chunk number 86: tradelist.Rnw:3049-3051
###################################################
row.names(data) <- data$id
sub.data <- data[, c("id", "volume", "price.usd", "alpha", "ret.1.d")]


###################################################
### code chunk number 87: necessary data
###################################################
sub.data


###################################################
### code chunk number 88: new ls tradelist
###################################################

tl <- new("tradelist", orig = p.current, target = p.target, chunk.usd
= 2000, sorts = sorts, turnover = 36825, data = data)



###################################################
### code chunk number 89: tradelist.Rnw:3075-3078
###################################################
tl <- new("tradelist", orig = p.current, target = p.target, chunk.usd
= 2000, sorts = sorts, turnover = 36825, target.equity = te, data =
data)


###################################################
### code chunk number 90: tradelist.Rnw:3113-3121
###################################################

ranks <- tl@rank.sorts$alpha
ranks <- split(ranks, ranks$side)
ranks$B$rank <- 1:nrow(ranks$B)
ranks$S$rank <- 1:nrow(ranks$S)
ranks$X$rank <- 1:nrow(ranks$X)
ranks



###################################################
### code chunk number 91: tradelist.Rnw:3139-3142
###################################################
tmp <- do.call(rbind, lapply(ranks, function(x) {x}))
tmp <- tmp[order(tmp$rank),]
tmp[,!names(tmp) %in% "id"]


###################################################
### code chunk number 92: tradelist.Rnw:3152-3153
###################################################
tl@rank.sorts[["alpha"]][,!names(tl@rank.sorts[["alpha"]]) %in% "id"]


###################################################
### code chunk number 93: ls weighted ranks
###################################################
ranks <- tl@rank.sorts[["alpha"]]
ranks[["rank"]] <- ranks[["rank"]]/sorts[["alpha"]]
ranks


###################################################
### code chunk number 94: tradelist.Rnw:3176-3177
###################################################
tl@rank.sorts[["ret.1.d"]]


###################################################
### code chunk number 95: prep-duplicates
###################################################

alpha <- tl@rank.sorts[["alpha"]]
ret.1.d <- tl@rank.sorts[["ret.1.d"]]

alpha <- alpha[,!names(alpha) %in% "alpha"]
ret.1.d <- ret.1.d[,!names(ret.1.d) %in% "ret.1.d"]

duplicates <- rbind(alpha, ret.1.d)
duplicates <- duplicates[order(duplicates$id),]
row.names(duplicates) <- 1:nrow(duplicates)



###################################################
### code chunk number 96: duplicates
###################################################
duplicates


###################################################
### code chunk number 97: prep-top.ranks
###################################################
tl.ranks <- tl@ranks


###################################################
### code chunk number 98: top.ranks
###################################################
top.ranks <- aggregate(duplicates[c("rank")], by = list(id = duplicates$id), min)
tl.ranks$rank <- top.ranks$rank[match(tl.ranks$id, top.ranks$id)]
tl.ranks[order(tl.ranks$rank), !names(tl@ranks) %in% c("id", "alpha", "ret.1.d", "rank.t")]


###################################################
### code chunk number 99: tradelist.Rnw:3217-3222
###################################################

tl.ranks$rank <- rank(tl.ranks$rank)
tl.ranks <- tl.ranks[, !names(tl.ranks) %in% c("id", "alpha", "ret.1.d")]

tl.ranks[order(tl.ranks$rank), !names(tl.ranks) %in% c("id", "alpha", "ret.1.d", "rank.t")]


###################################################
### code chunk number 100: scaled.ranks.ls
###################################################
misc$scaled.ranks.ls


###################################################
### code chunk number 101: pre.rank.t
###################################################
tl.ranks <- tl@ranks[order(tl@ranks$rank.t),!names(tl.ranks) %in% "id"]


###################################################
### code chunk number 102: rank.t
###################################################
tl.ranks


###################################################
### code chunk number 103: prep-chunks
###################################################
sub.chunks <- tl@chunks[, c("side", "rank.t", "chunk.shares",
                           "chunk.mv", "tca.rank")]


###################################################
### code chunk number 104: chunks
###################################################
sub.chunks


###################################################
### code chunk number 105: prep-swaps
###################################################
swaps.sub <- tl@swaps[, c("side.enter", "tca.rank.enter", "side.exit",
                          "tca.rank.exit", "rank.gain")]


###################################################
### code chunk number 106: tradelist.Rnw:3284-3285
###################################################
swaps.sub


###################################################
### code chunk number 107: tradelist.Rnw:3315-3317
###################################################
sub.swaps.actual <- tl@swaps.actual[, c("side.enter", "tca.rank.enter", "side.exit",
                                        "tca.rank.exit", "rank.gain")]


###################################################
### code chunk number 108: tradelist.Rnw:3320-3321
###################################################
sub.swaps.actual


###################################################
### code chunk number 109: tradelist.Rnw:3328-3329
###################################################
tl.bak <- tl


###################################################
### code chunk number 110: tradelist.Rnw:3332-3333
###################################################
tl@turnover <- nt - tl@chunk.usd


###################################################
### code chunk number 111: tradelist.Rnw:3342-3343
###################################################
tl <- portfolio:::calcSwapsActual(tl)


###################################################
### code chunk number 112: tradelist.Rnw:3346-3348
###################################################
sub.swaps.actual <- tl@swaps.actual[, c("side.enter", "tca.rank.enter", "side.exit",
                                        "tca.rank.exit", "rank.gain")]


###################################################
### code chunk number 113: tradelist.Rnw:3351-3352
###################################################
sub.swaps.actual


###################################################
### code chunk number 114: tradelist.Rnw:3355-3359
###################################################

## restores tl to pre-swaps value

tl <- tl.bak


###################################################
### code chunk number 115: tradelist.Rnw:3369-3371
###################################################
sub.chunks.actual <- tl@chunks.actual[,!names(tl@chunks.actual)
%in% c("id", "orig", "target", "shares", "mv")]


###################################################
### code chunk number 116: sub.chunks.actual
###################################################
sub.chunks.actual


###################################################
### code chunk number 117: tradelist.Rnw:3387-3390
###################################################

tl@actual



