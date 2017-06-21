require("tools")

(ud4 <- undoc("stats4"))
stopifnot(sapply(ud4, length) == 0)
