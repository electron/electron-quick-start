## ----echo=F--------------------------------------------------------------
### get knitr just the way we like it

knitr::opts_chunk$set(
  message = FALSE,
  warning = FALSE,
  error = FALSE,
  tidy = FALSE,
  cache = FALSE
)


## ------------------------------------------------------------------------
library(data.tree)

acme <- Node$new("Acme Inc.")
  accounting <- acme$AddChild("Accounting")
    software <- accounting$AddChild("New Software")
    standards <- accounting$AddChild("New Accounting Standards")
  research <- acme$AddChild("Research")
    newProductLine <- research$AddChild("New Product Line")
    newLabs <- research$AddChild("New Labs")
  it <- acme$AddChild("IT")
    outsource <- it$AddChild("Outsource")
    agile <- it$AddChild("Go agile")
    goToR <- it$AddChild("Switch to R")

print(acme)

## ------------------------------------------------------------------------
library(treemap)
data(GNI2014)
head(GNI2014)

## ------------------------------------------------------------------------
GNI2014$pathString <- paste("world", 
                            GNI2014$continent, 
                            GNI2014$country, 
                            sep = "/")


## ------------------------------------------------------------------------
population <- as.Node(GNI2014)
print(population, "iso3", "population", "GNI", limit = 20)

## ------------------------------------------------------------------------
library(yaml)
yaml <- "
name: OS Students 2014/15
OS X:
  Yosemite:
    users: 16
  Leopard:
    users: 43
Linux:
  Debian:
    users: 27
  Ubuntu:
    users: 36
Windows:
  W7:
    users: 31
  W8:
    users: 32
  W10:
    users: 4
"

osList <- yaml.load(yaml)
osNode <- as.Node(osList)
print(osNode, "users")

## ------------------------------------------------------------------------
print(population, limit = 15)
population$isRoot
population$height
population$count
population$totalCount
population$fields
population$fieldsAll
population$averageBranchingFactor

## ------------------------------------------------------------------------

sum(population$Get("population", filterFun = isLeaf))


## ------------------------------------------------------------------------
Prune(population, pruneFun = function(x) !x$isLeaf || x$population > 1000000)

## ------------------------------------------------------------------------
sum(population$Get("population", filterFun = isLeaf), na.rm = TRUE)

## ------------------------------------------------------------------------
popClone <- Clone(acme)


## ------------------------------------------------------------------------
as.data.frame(acme)

## ------------------------------------------------------------------------
ToDataFrameNetwork(acme)

## ------------------------------------------------------------------------
acme$IT$Outsource
acme$Research$`New Labs`

## ------------------------------------------------------------------------

acme$children[[1]]$children[[2]]$name


## ------------------------------------------------------------------------
acme$Climb(position = 1, name = "New Software")$path


## ------------------------------------------------------------------------
tree <- CreateRegularTree(5, 5)
tree$Climb(position = c(2, 3, 4))$path

## ------------------------------------------------------------------------
tree$Climb(position = c(2, 3), name = c("1.2.3.4", "1.2.3.4.5"))$path

## ------------------------------------------------------------------------
acme

## ------------------------------------------------------------------------
software$cost <- 1000000
standards$cost <- 500000
newProductLine$cost <- 2000000
newLabs$cost <- 750000
outsource$cost <- 400000
agile$cost <- 250000
goToR$cost <- 50000

software$p <- 0.5
standards$p <- 0.75
newProductLine$p <- 0.25
newLabs$p <- 0.9
outsource$p <- 0.2
agile$p <- 0.05
goToR$p <- 1
print(acme, "cost", "p")


## ------------------------------------------------------------------------
NODE_RESERVED_NAMES_CONST

## ------------------------------------------------------------------------
birds <- Node$new("Aves", vulgo = "Bird")
birds$AddChild("Neognathae", vulgo = "New Jaws", species = 10000)
birds$AddChild("Palaeognathae", vulgo = "Old Jaws", species = 60)
print(birds, "vulgo", "species")


## ------------------------------------------------------------------------
birds$species <- function(self) sum(sapply(self$children, function(x) x$species))
print(birds, "species")


## ------------------------------------------------------------------------
birds$Palaeognathae$species <- 61
print(birds, "species")

## ------------------------------------------------------------------------

print(acme, "cost", "p")


## ------------------------------------------------------------------------
SetFormat(acme, "p", formatFun = FormatPercent)
SetFormat(acme, "cost", formatFun = function(x) FormatFixedDecimal(x, digits = 2))
print(acme, "cost", "p")


## ------------------------------------------------------------------------
data.frame(cost = acme$Get("cost", format = function(x) FormatFixedDecimal(x, 2)),
           p = acme$Get("p", format = FormatPercent))
           


## ---- eval = FALSE-------------------------------------------------------
#  plot(acme)

## ---- eval = FALSE-------------------------------------------------------
#  SetGraphStyle(acme, rankdir = "TB")
#  SetEdgeStyle(acme, arrowhead = "vee", color = "grey35", penwidth = 2)
#  SetNodeStyle(acme, style = "filled,rounded", shape = "box", fillcolor = "GreenYellow",
#              fontname = "helvetica", tooltip = GetDefaultTooltip)
#  SetNodeStyle(acme$IT, fillcolor = "LightBlue", penwidth = "5px")
#  plot(acme)

## ---- eval = FALSE-------------------------------------------------------
#  SetNodeStyle(acme$Accounting, inherit = FALSE, fillcolor = "Thistle",
#               fontcolor = "Firebrick", tooltip = "This is the accounting department")
#  plot(acme)

## ---- eval = FALSE-------------------------------------------------------
#  Do(acme$leaves, function(node) SetNodeStyle(node, shape = "egg"))
#  plot(acme)

## ------------------------------------------------------------------------
plot(as.dendrogram(CreateRandomTree(nodes = 20)), center = TRUE)

## ----echo=FALSE----------------------------------------------------------
library(igraph, quietly = TRUE, warn.conflicts = FALSE, verbose = FALSE)

## ------------------------------------------------------------------------
library(igraph)
plot(as.igraph(acme, directed = TRUE, direction = "climb"))

## ------------------------------------------------------------------------
library(networkD3)
acmeNetwork <- ToDataFrameNetwork(acme, "name")
simpleNetwork(acmeNetwork[-3], fontSize = 12)

## ------------------------------------------------------------------------
fileName <- system.file("extdata", "useR15.csv", package="data.tree")
useRdf <- read.csv(fileName, stringsAsFactors = FALSE)
#define the hierarchy (Session/Room/Speaker)
useRdf$pathString <- paste("useR", useRdf$session, useRdf$room, useRdf$speaker, sep="|")
#convert to Node
useRtree <- as.Node(useRdf, pathDelimiter = "|")

#plot with networkD3
useRtreeList <- ToListExplicit(useRtree, unname = TRUE)
radialNetwork( useRtreeList)


## ------------------------------------------------------------------------
acmedf <- as.data.frame(acme)
as.data.frame(acme$IT)

## ---- eval=FALSE---------------------------------------------------------
#  ToDataFrameTree(acme)

## ------------------------------------------------------------------------
ToDataFrameTree(acme, "level", "cost")

## ------------------------------------------------------------------------
ToDataFrameTable(acme, "pathString", "cost")

## ------------------------------------------------------------------------
ToDataFrameNetwork(acme, "cost")

## ------------------------------------------------------------------------
ToDataFrameTypeCol(acme, 'cost')

## ------------------------------------------------------------------------
acme$IT$Outsource$AddChild("India")
acme$IT$Outsource$AddChild("Poland")


## ------------------------------------------------------------------------
acme$Set(type = c('company', 'department', 'project', 'project', 'department', 'project', 'project', 'department', 'program', 'project', 'project', 'project', 'project'))


## ------------------------------------------------------------------------
print(acme, 'type')

## ------------------------------------------------------------------------
ToDataFrameTypeCol(acme, type = 'type', prefix = NULL)

## ------------------------------------------------------------------------
data(acme)
str(as.list(acme$IT))
str(ToListExplicit(acme$IT, unname = FALSE, nameName = "id", childrenName = "dependencies"))

## ------------------------------------------------------------------------
print(acme, "level")

## ------------------------------------------------------------------------
acme$Get('level', traversal = "post-order")

## ------------------------------------------------------------------------

data.frame(level = agile$Get('level', traversal = "ancestor"))


## ------------------------------------------------------------------------
acme$Get('name', pruneFun = function(x) x$position <= 2)

## ------------------------------------------------------------------------
acme$Get('name', filterFun = isLeaf)

## ------------------------------------------------------------------------
acme$Get('name')

## ------------------------------------------------------------------------

ExpectedCost <- function(node, adjustmentFactor = 1) {
  return ( node$cost * node$p * adjustmentFactor)
}

acme$Get(ExpectedCost, adjustmentFactor = 0.9, filterFun = isLeaf)


## ------------------------------------------------------------------------
Cost <- function(node) {
  result <- node$cost
  if(length(result) == 0) result <- sum(sapply(node$children, Cost))
  return (result)
}

print(acme, "p", cost = Cost)

## ------------------------------------------------------------------------

acme$Do(function(node) node$cost <- Cost(node), filterFun = isNotLeaf)
print(acme, "p", "cost")


## ------------------------------------------------------------------------
acme$Set(id = 1:acme$totalCount)

print(acme, "id")

## ------------------------------------------------------------------------
secretaries <- c(3, 2, 8)
employees <- c(52, 43, 51)
acme$Set(secretaries, 
         emps = employees,
         filterFun = function(x) x$level == 2)
print(acme, "emps", "secretaries", "id")



## ------------------------------------------------------------------------
acme$Set(avgExpectedCost = NULL)

## ------------------------------------------------------------------------
acme$fieldsAll

## ------------------------------------------------------------------------
acme$Do(function(node) node$RemoveAttribute("avgExpectedCost"))

## ------------------------------------------------------------------------
acme$Set(cost = c(function(self) sum(sapply(self$children, 
                                            function(child) GetAttribute(child, "cost")))), 
         filterFun = isNotLeaf)
print(acme, "cost")
acme$IT$AddChild("Paperless", cost = 240000)
print(acme, "cost")

## ------------------------------------------------------------------------
traversal <- Traverse(acme, traversal = "post-order", filterFun = function(x) x$level == 2)
Set(traversal, floor = c(1, 2, 3))
Do(traversal, function(x) {
    if (x$floor <= 2) {
      x$extension <- "044"
    } else {
      x$extension <- "043"
    }
  })
Get(traversal, "extension")


## ------------------------------------------------------------------------
Aggregate(node = acme, attribute = "cost", aggFun = sum)


## ---- eval=FALSE---------------------------------------------------------
#  acme$Get(Aggregate, "cost", sum)

## ------------------------------------------------------------------------
acme$Do(function(node) node$cost <- Aggregate(node, attribute = "cost", aggFun = sum), traversal = "post-order")
print(acme, "cost")


## ------------------------------------------------------------------------
Cumulate(acme$IT$`Go agile`, "cost", sum)


## ------------------------------------------------------------------------
Cumulate(acme$IT$`Go agile`, "cost", min)


## ------------------------------------------------------------------------

acme$Do(function(node) node$cumCost <- Cumulate(node, 
                                                attribute = "cost", 
                                                aggFun = sum))
print(acme, "cost", "cumCost")


## ------------------------------------------------------------------------
acmeClone <- Clone(acme)
acmeClone$name <- "New Acme"
# acmeClone does not point to the same reference object anymore:
acme$name == acmeClone$name

## ------------------------------------------------------------------------
Sort(acme, "name")
acme
Sort(acme, Aggregate, "cost", sum, decreasing = TRUE, recursive = TRUE)
print(acme, "cost", aggCost = acme$Get(Aggregate, "cost", sum))

## ------------------------------------------------------------------------
acme$Do(function(x) x$cost <- Aggregate(x, "cost", sum))
Prune(acme, function(x) x$cost > 700000)
print(acme, "cost")

## ---- eval = FALSE-------------------------------------------------------
#  system.time(tree <- CreateRegularTree(6, 6))

## ---- echo = FALSE-------------------------------------------------------
c(user = 2.499, system = 0.009, elapsed = 2.506)

## ---- eval = FALSE-------------------------------------------------------
#  system.time(tree <- Clone(tree))

## ---- echo = FALSE-------------------------------------------------------
c(user = 3.704, system = 0.023, elapsed = 3.726)

## ---- eval = FALSE-------------------------------------------------------
#  system.time(traversal <- Traverse(tree))

## ---- echo = FALSE-------------------------------------------------------
c(user = 0.096, system = 0.000, elapsed = 0.097)

## ---- eval = FALSE-------------------------------------------------------
#  system.time(Set(traversal, id = 1:tree$totalCount))

## ---- echo = FALSE-------------------------------------------------------
c(user = 0.205, system = 0.000, elapsed = 0.204)

## ---- eval = FALSE-------------------------------------------------------
#  system.time(ids <- Get(traversal, "id"))

## ---- echo = FALSE-------------------------------------------------------
c(user = 0.569, system = 0.000, elapsed = 0.569)

## ---- eval = FALSE-------------------------------------------------------
#  leaves <- Traverse(tree, filterFun = isLeaf)
#  Set(leaves, leafId = 1:length(leaves))
#  system.time(Get(traversal, function(node) Aggregate(node, "leafId", max)))

## ---- echo = FALSE-------------------------------------------------------
c(user = 1.418, system = 0.000, elapsed = 1.417)

## ---- eval = FALSE-------------------------------------------------------
#  system.time(tree$Get(function(node) Aggregate(tree, "leafId", max, "maxLeafId"), traversal = "post-order"))

## ---- echo = FALSE-------------------------------------------------------
c(user = 0.69, system = 0.00, elapsed = 0.69)

