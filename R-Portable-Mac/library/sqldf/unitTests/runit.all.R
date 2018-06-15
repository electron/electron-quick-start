
# To run these tests:
#   library(sqldf)
#   library(svUnit)
#   # optionally: library(RH2), library(RMySQL) or library(RpgSQL)
#   #  otherwise sqlite will be used.
#   # optionally: options(sqldf.verbose = TRUE)
#   runit.all <- system.file("unitTests", "runit.all.R", package = "sqldf")
#   source(runit.all); clearLog(); test.all()
#   Log()

test.all <- function() {

	# set drv
	drv <- getOption("sqldf.driver") 
	if (is.null(drv)) {
		drv <- if ("package:RPostgreSQL" %in% search()) { "PostgreSQL"
			} else if ("package:RpgSQL" %in% search()) { "pgSQL"
			} else if ("package:RMySQL" %in% search()) { "MySQL" 
			} else if ("package:RH2" %in% search()) { "H2" 
			} else "SQLite"
	}
	drv <- tolower(drv)
	cat("using driver:", drv, "\n")

	# head
	a1r <- head(warpbreaks)
	a1s <- sqldf("select * from warpbreaks limit 6")
	checkIdentical(a1r, a1s)

	# subset / like
	a2r <- subset(as.data.frame(CO2), grepl("^Qn", Plant))
    class(a2r) <- "data.frame"
	if (drv == "postgresql") { # pgsql needs quotes for Plant
		a2s <- sqldf("select * from \"CO2\" where \"Plant\" like 'Qn%'")
	} else if (drv == "pgsql") {
		a2s <- sqldf("select * from CO2 where \"Plant\" like 'Qn%'")
	} else a2s <- sqldf("select * from CO2 where Plant like 'Qn%'")
	# checkEquals(a2r, a2s, check.attributes = FALSE)
	checkIdentical(a2r, a2s)

	data(farms, package = "MASS")
	# subset / in
	a3r <- subset(farms, Manag %in% c("BF", "HF"))
	row.names(a3r) <- NULL
	if (drv == "pgsql" || drv == "postgresql") { # pgsql needs quotes for Manag 
		a3s <- sqldf("select * from farms where \"Manag\" in ('BF', 'HF')")
	} else { 
		a3s <- sqldf("select * from farms where Manag in ('BF', 'HF')")
	}
	checkIdentical(a3r, a3s)

	# subset / multiple inequality constraints
	a4r <- subset(warpbreaks, breaks >= 20 & breaks <= 30)
	a4s <- sqldf("select * from warpbreaks where breaks between 20 and 30", 
	   row.names = TRUE)
	if (drv == "h2" || drv == "pgsql" || drv == "postgresql") {
		checkEquals(a4r, a4s, check.attributes = FALSE)
	} else checkIdentical(a4r, a4s)

		# subset
		a5r <- subset(farms, Mois == 'M1')
		if (drv == "pgsql" || drv == "postgresql") {
			a5s <- sqldf("select * from farms where \"Mois\" = 'M1'", 
				row.names = TRUE)
		} else a5s <- sqldf("select * from farms where Mois = 'M1'", row.names = TRUE)
		if (drv == "sqlite") {
			checkIdentical(a5r, a5s)
		# } else if (drv != "mysql") checkEquals(a5r, a5s, check.attributes = FALSE) 
		} else checkEquals(a5r, a5s, check.attributes = FALSE) 

		# subset
		a6r <- subset(farms, Mois == 'M2')
		if (drv == "pgsql" || drv == "postgresql") {
			a6s <- sqldf("select * from farms where \"Mois\" = 'M2'", row.names = TRUE)
	 	} else {
			a6s <- sqldf("select * from farms where Mois = 'M2'", row.names = TRUE)
		}
		if (drv == "sqlite") {
			checkIdentical(a6r, a6s)
		} else checkEquals(a6r, a6s, check.attributes = FALSE)

		# rbind
		a7r <- rbind(a5r, a6r)
		a7s <- sqldf("select * from a5s union all select * from a6s")

		# sqldf drops the unused levels of Mois but rbind does not; however,
		# all data is the same and the other columns are identical
		row.names(a7r) <- NULL
		checkIdentical(a7r[-1], a7s[-1])
	# }

	# aggregate - avg conc and uptake by Plant and Type
	# pgsql and h2 require double quote quoting 
	# whereas sqlite and mysql can use backquote
	# Species needs to be quoted in pgsql but not in the other data bases.
	a8r <- aggregate(iris[1:2], iris[5], mean)
	if (drv == "pgsql" || drv == "postgresql" || drv == "h2" || drv == "sqlite") {
		a8s <- sqldf('select "Species", avg("Sepal.Length") \"Sepal.Length\", 
			avg("Sepal.Width") \"Sepal.Width\" from iris 
			group by "Species" order by "Species"')
		if (drv == "postgresql") checkIdentical(a8r, a8s) else
		checkEquals(a8r, a8s, check.attributes = FALSE)
	} else {
		a8s <- sqldf("select Species, avg(Sepal_Length) `Sepal.Length`, 
		   avg(Sepal_Width) `Sepal.Width` from iris
		   group by Species order by Species")
	    # checkEquals(a8r, a8s, check.attributes = drv != "mysql")
	    checkEquals(a8r, a8s)
	}


	# by - avg conc and total uptake by Plant and Type
	a9r <- do.call(rbind, by(iris, iris[5], function(x) with(x,
		data.frame(Species = Species[1], 
			mean.Sepal.Length = mean(Sepal.Length),
			mean.Sepal.Width = mean(Sepal.Width),
			mean.Sepal.ratio = mean(Sepal.Length/Sepal.Width)))))
	row.names(a9r) <- NULL
	if (drv == "pgsql" || drv == "postgresql" || drv == "h2" || drv == "sqlite") {
		a9s <- sqldf('select "Species", avg("Sepal.Length") "mean.Sepal.Length",
			avg("Sepal.Width") "mean.Sepal.Width", 
			avg("Sepal.Length"/"Sepal.Width") "mean.Sepal.ratio" from iris
			group by "Species" order by "Species"')
			checkEquals(a9r, a9s, check.attributes = FALSE)
	} else {
		a9s <- sqldf("select Species, avg(Sepal_Length) `mean.Sepal.Length`,
			avg(Sepal_Width) `mean.Sepal.Width`, 
			avg(Sepal_Length/Sepal_Width) `mean.Sepal.ratio` from iris
			group by Species order by Species")
			# checkEquals(a9r, a9s, check.attributes = drv != "mysql")
			checkEquals(a9r, a9s)
	}

	# head - top 3 breaks
	a10r <- head(warpbreaks[order(warpbreaks$breaks, decreasing = TRUE), ], 3)
	a10s <- sqldf("select * from warpbreaks order by breaks desc limit 3")
	row.names(a10r) <- NULL
	checkIdentical(a10r, a10s)

	# head - bottom 3 breaks
	a11r <- head(warpbreaks[order(warpbreaks$breaks), ], 3)
	a11s <- sqldf("select * from warpbreaks order by breaks limit 3")
	# attributes(a11r) <- attributes(a11s) <- NULL
	row.names(a11r) <- NULL
	checkIdentical(a11r, a11s)

	# ave - rows for which v exceeds its group average where g is group
	DF <- data.frame(g = rep(1:2, each = 5), t = rep(1:5, 2), v = 1:10)
	a12r <- subset(DF, v > ave(v, g, FUN = mean))
	if (drv == "postgresql") {
		Gavg <- sqldf('select g, avg(v) as avg_v from "DF" group by g')
		a12s <- sqldf('select "DF".g, t, v from "DF", "Gavg" where "DF".g = "Gavg".g and v > avg_v')
	} else {
		Gavg <- sqldf("select g, avg(v) as avg_v from DF group by g")
		a12s <- sqldf("select DF.g, t, v from DF, Gavg where DF.g = Gavg.g and v > avg_v")
	}
	row.names(a12r) <- NULL
	checkIdentical(a12r, a12s)

	# same but reduce the two select statements to one using a subquery
	a13s <- if (drv == "postgresql") {
		sqldf('select g, t, v from "DF" d1, (select g as g2, avg(v) as avg_v from "DF" group by g) d2 where d1.g = g2 and v > avg_v')
	} else {
		sqldf("select g, t, v from DF d1, (select g as g2, avg(v) as avg_v from DF group by g) d2 where d1.g = g2 and v > avg_v")
	}
	checkIdentical(a12r, a13s)

	# same but shorten using natural join
	a14s <- if (drv == "postgresql") {
		sqldf('select d1.g, t, v from "DF" d1 natural join 
		  (select g, avg(v) as avg_v from "DF" group by g) d2 where v > avg_v')
	} else { 
		sqldf("select d1.g, t, v from DF d1 natural join 
		  (select g, avg(v) as avg_v from DF group by g) d2 where v > avg_v")
	}
	checkIdentical(a12r, a14s)

	# table
	a15r <- table(warpbreaks$tension, warpbreaks$wool)
	if (drv == "pgsql" || drv == "postgresql") {
		a15s <- sqldf("select 
					sum(cast(wool = 'A' as integer)), 
					sum(cast(wool = 'B' as integer))
			   from warpbreaks group by tension")
	} else {
		a15s <- sqldf("select SUM(wool = 'A'), SUM(wool = 'B') 
			   from warpbreaks group by tension")
	}

	checkEquals(as.data.frame.matrix(a15r), a15s, check.attributes = FALSE)

	# reshape
	t.names <- paste("t", unique(as.character(DF$t)), sep = "_")
	a16r <- reshape(DF, direction = "wide", timevar = "t", idvar = "g", varying = list(t.names))
	if (drv == "postgresql") {
		a16s <- sqldf("select g, 
			sum(cast(t = 1 as integer) * v) t_1, 
			sum(cast(t = 2 as integer) * v) t_2, 
			sum(cast(t = 3 as integer) * v) t_3, 
			sum(cast(t = 4 as integer) * v) t_4, 
			sum(cast(t = 5 as integer) * v) t_5 from \"DF\" group by g")
	} else if (drv == "pgsql") {
		a16s <- sqldf("select g, 
			sum(cast(t = 1 as integer) * v) t_1, 
			sum(cast(t = 2 as integer) * v) t_2, 
			sum(cast(t = 3 as integer) * v) t_3, 
			sum(cast(t = 4 as integer) * v) t_4, 
			sum(cast(t = 5 as integer) * v) t_5 from DF group by g")
	} else a16s <- sqldf("select g, 
		SUM((t = 1) * v) t_1, 
		SUM((t = 2) * v) t_2, 
		SUM((t = 3) * v) t_3, 
		SUM((t = 4) * v) t_4, 
		SUM((t = 5) * v) t_5 from DF group by g")
	checkEquals(a16r, a16s, check.attributes = FALSE)

	# order
	a17r <- Formaldehyde[order(Formaldehyde$optden, decreasing = TRUE), ]
	if (drv == "postgresql") {
	a17s <- sqldf("select * from \"Formaldehyde\" order by optden desc") 
	} else a17s <- sqldf("select * from Formaldehyde order by optden desc")
	row.names(a17r) <- NULL
	checkIdentical(a17r, a17s)

	DF <- data.frame(x = rnorm(15, 1:15))
	a18r <- data.frame(x = DF[4:12,], movavgx = rowMeans(embed(DF$x, 7)))
	# centered moving average of length 7
	if (drv == "postgresql" || drv == "h2") {
		DF2 <- cbind(id = 1:nrow(DF), DF)
		a18s <- sqldf("select min(a.x) x, avg(b.x) movavgx 
           from \"DF2\" a, \"DF2\" b 
		   where a.id - b.id between -3 and 3 
		   group by a.id having count(*) = 7 
		   order by a.id")
	} else if (drv == "pgsql") {
		DF2 <- cbind(id = 1:nrow(DF), DF)
		a18s <- sqldf("select min(a.x) x, avg(b.x) movavgx 
           from DF2 a, DF2 b 
		   where a.id - b.id between -3 and 3 
		   group by a.id having count(*) = 7 
		   order by a.id")
	} else {
		a18s <- sqldf("select a.x x, avg(b.x) movavgx from DF a, DF b 
		   where a.row_names - b.row_names between -3 and 3 
		   group by a.row_names having count(*) = 7 
		   order by a.row_names+0", 
		 row.names = TRUE)
	}
	checkEquals(a18r, a18s)

	# merge.  a19r and a19s are same except row order and row names
	A <- data.frame(a1 = c(1, 2, 1), a2 = c(2, 3, 3), a3 = c(3, 1, 2))
	B <- data.frame(b1 = 1:2, b2 = 2:1)
	a19s <- if (drv == "postgresql") {
		sqldf('select * from "A", "B"')
	} else sqldf("select * from A, B")
	a19r <- merge(A, B)
	Sort <- function(DF) DF[do.call(order, DF),]
	checkEquals(Sort(a19s), Sort(a19r), check.attributes = FALSE)

	if (drv != "postgresql") {

	  # check Date class
	  DF.Date <- structure(list(date = structure(c(-15676, -15648), 
	   class = "Date"), x = c(2, 3), y = c(4, 5)), 
	   .Names = c("date", "x", "y"), row.names = 1:2, class = "data.frame")
	  g <- data.frame(date=as.Date(c("1927-01-31","1927-02-28")),x=c(2,3))
	  h <- data.frame(date=as.Date(c("1927-01-31","1927-02-28")),y=c(4,5))
	  final <- sqldf("select d1.*, d2.y 
		       from g d1 left join h d2 on d1.date=d2.date")
	  checkEquals(final, DF.Date)

	}

	# test sqlite system tables

	if (drv == "sqlite") {

		checkIdentical(dim(sqldf("pragma table_info(BOD)")), c(2L, 6L))

		sql <- c("select * from BOD", "select * from sqlite_master")
		checkIdentical(dim(sqldf(sql)), c(1L, 5L))

		checkTrue(sqldf("pragma database_list")$name == "main")

		DF <- data.frame(a = 1:2, b = 2:1)

		checkIdentical(sqldf("select a/b as quotient from DF")$quotient, c(0L, 2L))

		checkIdentical(sqldf("select (a+0.0)/b as quotient from DF")$quotient, c(0.5, 2.0))

		checkIdentical(sqldf("select cast(a as real)/b as quotient from DF")$quotient, c(0.5, 2.0))

		checkIdentical(sqldf(c("create table mytab(a real, b real)", 
		   "insert into mytab select * from DF",  
		   "select a/b as quotient from mytab"))$quotient, c(0.5, 2.0))

		tonum <- function(DF) replace(DF, TRUE, lapply(DF, as.numeric))
		checkIdentical(sqldf("select a/b as quotient from DF", 
			method = list("auto", tonum))$quotient, c(0.5, 2.0))
	}

}
