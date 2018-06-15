### Windows-only regression tests

## closing a graphics window could segfault in Windows
windows(record = TRUE)
plot(1)
dev.off()
gc()
## segfaulted in 2.0.0


## Using a closed progress bar (PR#13709)
bar = winProgressBar(min = 0, max = 100, width = 300)
setWinProgressBar(bar, 25)
close(bar)
try(setWinProgressBar(bar, 50))
## segfaulted in 2.9.0


## trio peculiarity with %a, and incorrect fix
x <- sprintf("%a", 1:8)
y <- c("0x1p+0", "0x1p+1", "0x1.8p+1", "0x1p+2", "0x1.4p+2", "0x1.8p+2",
       "0x1.cp+2", "0x1p+3")
stopifnot(identical(x, y))
