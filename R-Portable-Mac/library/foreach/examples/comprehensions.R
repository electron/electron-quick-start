library(foreach)

a <-
  foreach(x=1:4, .combine='c') %do%
    (x + 2 * x + x / 2)
print(a)

a <-
  foreach(x=1:9, .combine='c') %do%
    (x %% 2 == 1)
print(a)

a <-
  foreach(x=1:4, .combine='c') %:%
    foreach(y=c(3,5,7,9), .combine='c') %do%
      (x * y)
print(a)

a <-
  foreach(x=c(1,5,12,3,23,11,7,2), .combine='c') %:%
    when(x > 10) %do%
      x
print(a)

a <-
  foreach(x=c(1,3,5), .combine='c') %:%
    foreach(y=c(2,4,6)) %:%
      when(x < y) %do%
        c(x, y)
print(a)

n <- 30
s <- seq(length=n)
a <-
  foreach(x=s, .combine='c') %:%
    foreach(y=s, .combine='c') %:%
      foreach(z=s) %:%
        when(x + y + z <= n) %:%
          when(x * x + y * y == z * z) %do%
            c(x, y, z)
print(a)
