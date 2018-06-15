

# given number possibly followed by SI letter (e.g. 32.5k where k means 1000)
# replace letter with e followed by appropriate digits.
# (see formatEng2R by Hans-Joerg Bibiko in the R Wiki)

conv <- list(y = "e-24", z = "e-21", a = "e-18", f = "e-15", p = "e-12", 
    n = "e-9", u = "e-6", m = "e-3", d = "e-1", c = "e-2", k = "e3", 
    M = "e6", G = "e9", T = "e12", P = "e15", E = "e18", Z = "e21", Y = "e24") 
gsubfn(".$", conv, c("19", "32.5M"))

