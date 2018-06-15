
pause <- function() {}

### The Zachary Karate club network

karate <- make_graph("Zachary")
summary(karate)

pause()

### Create a layout that is used from now on

karate$layout <- layout_nicely(karate)
plot(karate)

pause()

### Run cohesive blocking on it

cbKarate <- cohesive_blocks(karate)
cbKarate

pause()

### Plot the results and all the groups

plot(cbKarate, karate)

pause()

### This is a bit messy, plot them step-by-step
### See the hierarchy tree first

hierarchy(cbKarate)
plot_hierarchy(cbKarate)

## Plot the first level, blocks 1 & 2

plot(cbKarate, karate, mark.groups=blocks(cbKarate)[1:2+1],
     col="cyan")

pause()

### The second group is simple, plot its more cohesive subgroup

plot(cbKarate, karate, mark.groups=blocks(cbKarate)[c(2,5)+1], col="cyan")

pause()

### The first group has more subgroups, plot them

sub1 <- blocks(cbKarate)[parent(cbKarate)==1]
sub1
plot(cbKarate, karate, mark.groups=sub1)

pause()

