
dyn.load("piWithInterrupts.so")
#res <- .Call("PiLeibniz", n=1e9, frequency=1e6)
res <- .Call("PiLeibniz", n=1e9, frequency=1e6)
print(res, digits=10)
