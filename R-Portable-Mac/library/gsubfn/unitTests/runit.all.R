
# To run these tests:
#   library(gsubfn)
#   library(svUnit)
#   runit.all <- system.file("unitTests", "runit.all.R", package = "sqldf")
#   source(runit.all); clearLog(); test.all()
#   Log()

test.all <- function() {

	checkIdentical(
		gsubfn('([0-9]+):([0-9]+)', ~ as.numeric(x) + as.numeric(y),
			'abc 10:20 def 30:40 50'),
		"abc 30 def 70 50"
	)

	checkIdentical(
		gsubfn('[MGP]$', ~ c(M = 'e6', G = 'e9', P = 'e12')[[x]],
			c('3.5G', '88P', '19')),
		c("3.5e9", "88e12", "19")
	)

	checkIdentical(
		gsubfn('[MGP]$', ~ list(M = 'e6', G = 'e9', P = 'e12')[[x]],
			c('3.5G', '88P', '19')),
		c("3.5e9", "88e12", "19")
	)

	checkIdentical(
		gsubfn("\\B.", tolower, "I LIKE A BANANA SPLIT", perl = TRUE),
		"I Like A Banana Split"
	)

	p <- proto(fun = function(this, x) paste0(x, "{", count, "}"))
	checkIdentical(
		gsubfn("\\w+", p, c("the dog and the cat are in the house", "x y x")),
		c("the{1} dog{2} and{3} the{4} cat{5} are{6} in{7} the{8} house{9}", 
			"x{1} y{2} x{3}")
	)

	pwords <- proto(
		pre = function(this) { this$words <- list() },
		fun = function(this, x) {
			if (is.null(words[[x]])) this$words[[x]] <- 0
			this$words[[x]] <- words[[x]] + 1
			paste0(x, "{", words[[x]], "}")
		}
	)
	checkIdentical(
		gsubfn("\\w+", pwords, "the dog and the cat are in the house"),
		"the{1} dog{1} and{1} the{2} cat{1} are{1} in{1} the{3} house{1}"
	)

    s2 <- c('123abc', '12cd34', '1e23')
	target <- matrix(c("123", "12", "1", "abc", "cd34", "e23"), 3)
	checkIdentical(
		strapply(s2, '^([[:digit:]]+)(.*)', c, simplify = rbind),
		target
	)

	if (require(tcltk)) {
		checkIdentical(
			strapplyc(s2, '^([[:digit:]]+)(.*)', simplify = rbind),
			target
		)
	}

	ss <- c('a:b c:d', 'e:f')
	target <- list(c("a", "b", "c", "d"), c("e", "f"))
	checkIdentical(strapply(ss, '(.):(.)', c), target)
	checkIdentical(strapplyc(ss, '(.):(.)'), target)
	checkIdentical(
		strapply(ss, '(.):(.)', c, combine = list),
		list(list(c("a", "b"), c("c", "d")), list(c("e", "f")))
	)

	checkIdentical(
		strapply(' a b c d e f ', ' [a-z](?=( [a-z] ))', paste0)[[1]],
		c(" a", " b", " c", " d", " e")
	)

	checkIdentical(
		round(fn$integrate(~ sin(x) + sin(x), 0, pi/2)$value), 
		2
	)

	checkIdentical(
		fn$lapply(list(1:4, 1:5), ~ LETTERS[x]),
		list(LETTERS[1:4], LETTERS[1:5])
	)

	checkIdentical(
		fn$mapply(~ seq_len(x) + y * z, 1:3, 4:6, 2),
		list(9, c(11, 12), c(13, 14, 15))
	)

	checkIdentical(
		gsubfn("\\B.", tolower, "I LIKE A BANANA SPLIT", perl = TRUE),
		"I Like A Banana Split"
	)

	pwords2 <- proto(
		pre = function(this) { this$words <- list() },
		fun = function(this, x) {
			if (is.null(words[[x]])) this$words[[x]] <- 0
			this$words[[x]] <- words[[x]] + 1
			list(x, words[[x]])
		}
	)

	checkIdentical(
			strapply("the dog and the cat are in the house", "\\w+", pwords2, 
				combine = list, simplify = x ~ do.call(rbind, x) ),
		structure(list("the", "dog", "and", "the", "cat", "are", "in", 
			"the", "house", 1, 1, 1, 2, 1, 1, 1, 3, 1), .Dim = c(9L, 2L))
	)

	checkIdentical(
		strapplyc("a:b c:d", "(.):(.)")[[1]],
		letters[1:4]
	)
}
