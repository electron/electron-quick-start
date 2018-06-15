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
library(treemap)
data(GNI2014)
treemap(GNI2014,
       index=c("continent", "iso3"),
       vSize="population",
       vColor="GNI",
       type="value")

## ------------------------------------------------------------------------
library(data.tree)
GNI2014$continent <- as.character(GNI2014$continent)
GNI2014$pathString <- paste("world", GNI2014$continent, GNI2014$country, sep = "/")
tree <- as.Node(GNI2014[,])
print(tree, pruneMethod = "dist", limit = 20)

## ------------------------------------------------------------------------

tree$Europe$Switzerland$population


## ------------------------------------------------------------------------
northAm <- tree$`North America`
Sort(northAm, "GNI", decreasing = TRUE)
print(northAm, "iso3", "population", "GNI", limit = 12)

## ------------------------------------------------------------------------
maxGNI <- Aggregate(tree, "GNI", max)
#same thing, in a more traditional way:
maxGNI <- max(sapply(tree$leaves, function(x) x$GNI))

tree$Get("name", filterFun = function(x) x$isLeaf && x$GNI == maxGNI)

## ------------------------------------------------------------------------
tree$Do(function(x) {
        x$population <- Aggregate(node = x,
        attribute = "population",
        aggFun = sum)
        }, 
     traversal = "post-order")

## ------------------------------------------------------------------------
Sort(tree, attribute = "population", decreasing = TRUE, recursive = TRUE)


## ------------------------------------------------------------------------
tree$Do(function(x) x$cumPop <- Cumulate(x, "population", sum))


## ------------------------------------------------------------------------
print(tree, "population", "cumPop", pruneMethod = "dist", limit = 20)

## ------------------------------------------------------------------------

tree$Do(function(x) x$origCount <- x$count)


## ------------------------------------------------------------------------

myPruneFun <- function(x, cutoff = 0.9, maxCountries = 7) {
  if (isNotLeaf(x)) return (TRUE)
  if (x$position > maxCountries) return (FALSE)
  return (x$cumPop < (x$parent$population * cutoff))
}


## ------------------------------------------------------------------------
treeClone <- Clone(tree, pruneFun = myPruneFun)
print(treeClone$Oceania, "population", pruneMethod = "simple", limit = 20)

## ------------------------------------------------------------------------

treeClone$Do(function(x) {
  missing <- x$population - sum(sapply(x$children, function(x) x$population))
  other <- x$AddChild("Other")
  other$iso3 <- paste0("OTH(", x$origCount, ")")
  other$country <- "Other"
  other$continent <- x$name
  other$GNI <- 0
  other$population <- missing
},
filterFun = function(x) x$level == 2
)


print(treeClone$Oceania, "population", pruneMethod = "simple", limit = 20)


## ------------------------------------------------------------------------
df <- ToDataFrameTable(treeClone, "iso3", "country", "continent", "population", "GNI")

treemap(df,
        index=c("continent", "iso3"),
        vSize="population",
        vColor="GNI",
        type="value")


## ------------------------------------------------------------------------
plot(as.dendrogram(treeClone, heightAttribute = "population"))


## ------------------------------------------------------------------------
fileName <- system.file("extdata", "portfolio.csv", package="data.tree")
pfodf <- read.csv(fileName, stringsAsFactors = FALSE)
head(pfodf)

## ------------------------------------------------------------------------
pfodf$pathString <- paste("portfolio", 
                          pfodf$AssetCategory, 
                          pfodf$AssetClass, 
                          pfodf$SubAssetClass, 
                          pfodf$ISIN, 
                          sep = "/")
pfo <- as.Node(pfodf)


## ------------------------------------------------------------------------
t <- Traverse(pfo, traversal = "post-order")
Do(t, function(x) x$Weight <- Aggregate(node = x, attribute = "Weight", aggFun = sum))

## ------------------------------------------------------------------------

Do(t, function(x) x$WeightOfParent <- x$Weight / x$parent$Weight)


## ------------------------------------------------------------------------

pfo$Do(function(x) x$Duration <- ifelse(is.null(x$Duration), 0, x$Duration), filterFun = isLeaf)
Do(t, function(x) x$Duration <- Aggregate(x, function(x) x$WeightOfParent * x$Duration, sum))


## ------------------------------------------------------------------------
SetFormat(pfo, "WeightOfParent", function(x) FormatPercent(x, digits = 1))
SetFormat(pfo, "Weight", FormatPercent)

FormatDuration <- function(x) {
  if (x != 0) res <- FormatFixedDecimal(x, digits = 1)
  else res <- ""
  return (res)
}

SetFormat(pfo, "Duration", FormatDuration)


## ------------------------------------------------------------------------

#Print
print(pfo, 
      "Weight", 
      "WeightOfParent",
      "Duration",
      filterFun = function(x) !x$isLeaf)


## ------------------------------------------------------------------------
IsPure <- function(data) {
  length(unique(data[,ncol(data)])) == 1
}

## ------------------------------------------------------------------------
Entropy <- function( vls ) {
  res <- vls/sum(vls) * log2(vls/sum(vls))
  res[vls == 0] <- 0
  -sum(res)
}

## ------------------------------------------------------------------------

InformationGain <- function( tble ) {
  entropyBefore <- Entropy(colSums(tble))
  s <- rowSums(tble)
  entropyAfter <- sum (s / sum(s) * apply(tble, MARGIN = 1, FUN = Entropy ))
  informationGain <- entropyBefore - entropyAfter
  return (informationGain)
}

## ------------------------------------------------------------------------
TrainID3 <- function(node, data) {
    
  node$obsCount <- nrow(data)
  
  #if the data-set is pure (e.g. all toxic), then
  if (IsPure(data)) {
    #construct a leaf having the name of the pure feature (e.g. 'toxic')
    child <- node$AddChild(unique(data[,ncol(data)]))
    node$feature <- tail(names(data), 1)
    child$obsCount <- nrow(data)
    child$feature <- ''
  } else {
    #calculate the information gain
    ig <- sapply(colnames(data)[-ncol(data)], 
            function(x) InformationGain(
              table(data[,x], data[,ncol(data)])
              )
            )
    #chose the feature with the highest information gain (e.g. 'color')
    #if more than one feature have the same information gain, then take
    #the first one
    feature <- names(which.max(ig))
    node$feature <- feature
    
    #take the subset of the data-set having that feature value
    
    childObs <- split(data[ ,names(data) != feature, drop = FALSE], 
                      data[ ,feature], 
                      drop = TRUE)
  
    for(i in 1:length(childObs)) {
      #construct a child having the name of that feature value (e.g. 'red')
      child <- node$AddChild(names(childObs)[i])
      
      #call the algorithm recursively on the child and the subset      
      TrainID3(child, childObs[[i]])
    }
    
  }
  
  

}

## ------------------------------------------------------------------------
library(data.tree)
data(mushroom)
mushroom

## ------------------------------------------------------------------------

tree <- Node$new("mushroom")
TrainID3(tree, mushroom)
print(tree, "feature", "obsCount")


## ------------------------------------------------------------------------

Predict <- function(tree, features) {
  if (tree$children[[1]]$isLeaf) return (tree$children[[1]]$name)
  child <- tree$children[[features[[tree$feature]]]]
  return ( Predict(child, features))
}


## ------------------------------------------------------------------------
Predict(tree, c(color = 'red', 
                size = 'large', 
                points = 'yes')
        )

## ------------------------------------------------------------------------
fileName <- system.file("extdata", "jennylind.yaml", package="data.tree")
cat(readChar(fileName, file.info(fileName)$size))


## ------------------------------------------------------------------------

library(data.tree)
library(yaml)
lol <- yaml.load_file(fileName)
jl <- as.Node(lol)
print(jl, "type", "payoff", "p")

## ------------------------------------------------------------------------

payoff <- function(node) {
  if (node$type == 'chance') node$payoff <- sum(sapply(node$children, function(child) child$payoff * child$p))
  else if (node$type == 'decision') node$payoff <- max(sapply(node$children, function(child) child$payoff))
}

jl$Do(payoff, traversal = "post-order", filterFun = isNotLeaf)


## ------------------------------------------------------------------------
decision <- function(x) {
  po <- sapply(x$children, function(child) child$payoff)
  x$decision <- names(po[po == x$payoff])
}

jl$Do(decision, filterFun = function(x) x$type == 'decision')



## ------------------------------------------------------------------------

GetNodeLabel <- function(node) switch(node$type, 
                                      terminal = paste0( '$ ', format(node$payoff, scientific = FALSE, big.mark = ",")),
                                      paste0('ER\n', '$ ', format(node$payoff, scientific = FALSE, big.mark = ",")))

GetEdgeLabel <- function(node) {
  if (!node$isRoot && node$parent$type == 'chance') {
    label = paste0(node$name, " (", node$p, ")")
  } else {
    label = node$name
  }
  return (label)
}

GetNodeShape <- function(node) switch(node$type, decision = "box", chance = "circle", terminal = "none")


SetEdgeStyle(jl, fontname = 'helvetica', label = GetEdgeLabel)
SetNodeStyle(jl, fontname = 'helvetica', label = GetNodeLabel, shape = GetNodeShape)

## ------------------------------------------------------------------------
jl$Do(function(x) SetEdgeStyle(x, color = "red", inherit = FALSE), 
      filterFun = function(x) !x$isRoot && x$parent$type == "decision" && x$parent$decision == x$name)



## ---- eval = FALSE-------------------------------------------------------
#  SetGraphStyle(jl, rankdir = "LR")
#  plot(jl)
#  

## ------------------------------------------------------------------------
fileName <- system.file("extdata", "flare.json", package="data.tree")
flareJSON <- readChar(fileName, file.info(fileName)$size)
cat(substr(flareJSON, 1, 300))


## ------------------------------------------------------------------------
library(jsonlite)
flareLoL <- fromJSON(file(fileName),
                     simplifyDataFrame = FALSE
                     )

flareTree <- as.Node(flareLoL, mode = "explicit", check = "no-warn")
flareTree$fieldsAll
print(flareTree, "size", limit = 30)


## ------------------------------------------------------------------------

flare_df <- ToDataFrameTable(flareTree, 
                             className = function(x) x$parent$name, 
                             packageName = "name", 
                             "size")
head(flare_df)


## ---- eval = FALSE-------------------------------------------------------
#  
#  devtools::install_github("jcheng5/bubbles@6724e43f5e")
#  library(scales)
#  library(bubbles)
#  library(RColorBrewer)
#  bubbles(
#    flare_df$size,
#    substr(flare_df$packageName, 1, 2),
#    tooltip = flare_df$packageName,
#    color = col_factor(
#      brewer.pal(9,"Set1"),
#      factor(flare_df$className)
#    )(flare_df$className),
#    height = 800,
#    width = 800
#  )

## ------------------------------------------------------------------------
path <- ".."
files <- list.files(path = path, 
                    recursive = TRUE,
                    include.dirs = FALSE) 

df <- data.frame(
      filename = sapply(files, 
                        function(fl) paste0("data.tree","/",fl)
      ), 
      file.info(paste(path, files, sep = "/")),
      stringsAsFactors = FALSE
    )
 
print(head(df)[c(1,2,3,4)], row.names = FALSE)


## ------------------------------------------------------------------------

fileStructure <- as.Node(df, pathName = "filename")
fileStructure$leafCount / (fileStructure$totalCount - fileStructure$leafCount)
print(fileStructure, "mode", "size", limit = 25)


## ---- eval = FALSE-------------------------------------------------------
#  
#  #This requires listviewer, which is available only on github
#  devtools::install_github("timelyportfolio/listviewer")
#  
#  library(listviewer)
#  
#  l <- ToListSimple(fileStructure)
#  jsonedit(l)
#  

## ------------------------------------------------------------------------

#' @param children the number of children each population member has
#' @param probSex the probability of the sex of a descendant
#' @param probInherit the probability the feature is inherited, depending on the sex of the descendant
#' @param probDevelop the probability the feature is developed (e.g. a gene defect), depending on the sex
#' of the descendant
#' @param generations the number of generations our simulated population should have
#' @param parent for recursion
GenerateChildrenTree <- function(children = 2, 
                                 probSex = c(male = 0.52, female = 0.48), 
                                 probInherit = c(male = 0.8, female = 0.5),
                                 probDevelop = c(male = 0.05, female = 0.01),
                                 generations = 3, 
                                 parent = NULL) {
  
  if (is.null(parent)) {
    parent <- Node$new("1")
    parent$sex <- 1
    parent$feature <- TRUE
    parent$develop <- FALSE
  }
  
  #sex of descendants
  #1 = male
  #2 = female
  sex <- sample.int(n = 2, size = children, replace = TRUE, prob = probSex)
  for (i in 1:children) child <- parent$AddChild(i)
  Set(parent$children, sex = sex)
  
  #inherit
  if (parent$feature == TRUE) {
    for (i in 1:2) {
      subPop <- Traverse(parent, filterFun = function(x) x$sex == i)
      inherit <- sample.int(n = 2, 
                            size = length(subPop), 
                            replace = TRUE, 
                            prob = c(1 - probInherit[i], probInherit[i]))
      
      Set(subPop, feature = as.logical(inherit - 1))
    }
  } else {
    Set(parent$children, feature = FALSE)
  }
  
  #develop
  Set(parent$children, develop = FALSE)
  for (i in 1:2) {
    subPop <- Traverse(parent, filterFun = function(x) x$sex == i && !x$feature)
    develop <- sample.int(n = 2, 
                          size = length(subPop), 
                          replace = TRUE, 
                          prob = c(1 - probDevelop[i], probDevelop[i]))
    Set(subPop, feature = as.logical((develop - 1)), develop = as.logical((develop - 1)))
  }
  
  #recursion to next generation
  if (generations > 0) for (i in 1:children) GenerateChildrenTree(children, 
                                                                  probSex, 
                                                                  probInherit, 
                                                                  probDevelop, 
                                                                  generations - 1, 
                                                                  parent$children[[i]])
  
  return (parent)
}


## ------------------------------------------------------------------------

tree <- GenerateChildrenTree()
print(tree, "sex", "feature", "develop", limit = 20)


## ------------------------------------------------------------------------
tree$totalCount

## ------------------------------------------------------------------------
length(Traverse(tree, filterFun = function(x) x$feature))

## ------------------------------------------------------------------------
length(Traverse(tree, filterFun = function(x) x$sex == 1 && x$develop))

## ------------------------------------------------------------------------
FreqLastGen <- function(tree) {
  l <- tree$leaves
  sum(sapply(l, function(x) x$feature))/length(l)
}

FreqLastGen(tree)


## ------------------------------------------------------------------------
system.time(x <- sapply(1:100, function(x) FreqLastGen(GenerateChildrenTree())))

## ------------------------------------------------------------------------
hist(x, probability = TRUE, main = "Frequency of feature in last generation")

## ---- eval = FALSE-------------------------------------------------------
#  library(foreach)
#  library(doParallel)
#  registerDoParallel(makeCluster(3))
#  #On Linux, there are other alternatives, e.g.: library(doMC);  registerDoMC(3)
#  
#  system.time(x <- foreach (i = 1:100, .packages = "data.tree") %dopar% FreqLastGen(GenerateChildrenTree()))
#  stopImplicitCluster()

## ---- echo = FALSE-------------------------------------------------------

print(c(user = 0.07, system = 0.02, elapsed = 1.40))

## ------------------------------------------------------------------------

fields <- expand.grid(letters[1:3], 1:3)
fields


## ------------------------------------------------------------------------
ttt <- Node$new("ttt")

#consider rotation, so first move is explicit
ttt$AddChild("a3")
ttt$a3$f <- 7
ttt$AddChild("b3")
ttt$b3$f <- 8
ttt$AddChild("b2")
ttt$b2$f <- 5


ttt$Set(player = 1, filterFun = isLeaf)



## ------------------------------------------------------------------------
AddPossibleMoves <- function(node) {
  t <- Traverse(node, traversal = "ancestor", filterFun = isNotRoot)
  
  available <- rownames(fields)[!rownames(fields) %in% Get(t, "f")]
  for (f in available) {
    child <- node$AddChild(paste0(fields[f, 1], fields[f, 2]))
    child$f <- as.numeric(f)
    child$player <- ifelse(node$player == 1, 2, 1)
    hasWon <- HasWon(child)
    if (!hasWon && child$level <= 10) AddPossibleMoves(child)
    if (hasWon) {
      child$result <- child$player
      print(paste("Player ", child$player, "wins!"))
    } else if(child$level == 10) {
      child$result <- 0
      print("Tie!")
    }
    
  }
  return (node)  
}


## ------------------------------------------------------------------------
HasWon <- function(node) {
  t <- Traverse(node, traversal = "ancestor", filterFun = function(x) !x$isRoot && x$player == node$player)
  mine <- Get(t, "f")
  mineV <- rep(0, 9)
  mineV[mine] <- 1
  mineM <- matrix(mineV, 3, 3, byrow = TRUE)
  result <- any(rowSums(mineM) == 3) ||
    any(colSums(mineM) == 3) ||
    sum(diag(mineM)) == 3 ||
    sum(diag(t(mineM))) == 3
  return (result)
}


## ---- eval=FALSE---------------------------------------------------------
#  system.time(for (child in ttt$children) AddPossibleMoves(child))

## ---- echo= FALSE--------------------------------------------------------
c(user = 345.645, system = 3.245, elapsed = 346.445)

## ---- eval = FALSE-------------------------------------------------------
#  ttt$leafCount

## ---- echo = FALSE-------------------------------------------------------
89796

## ---- eval = FALSE-------------------------------------------------------
#  ttt$totalCount

## ---- echo = FALSE-------------------------------------------------------
203716

## ---- eval = FALSE-------------------------------------------------------
#  mean(ttt$Get(function(x) x$level - 1, filterFun = isLeaf))

## ---- echo = FALSE-------------------------------------------------------
8.400775

## ---- eval = FALSE-------------------------------------------------------
#  ttt$averageBranchingFactor

## ---- echo = FALSE-------------------------------------------------------
1.788229

## ---- eval = FALSE-------------------------------------------------------
#  
#  winnerOne <- Traverse(ttt, filterFun = function(x) x$isLeaf && x$result == 1)
#  winnerTwo <- Traverse(ttt, filterFun = function(x) x$isLeaf && x$result == 2)
#  ties <- Traverse(ttt, filterFun = function(x) x$isLeaf && x$result == 0)
#  
#  c(winnerOne = length(winnerOne), winnerTwo = length(winnerTwo), ties = length(ties))

## ---- echo=FALSE---------------------------------------------------------
c(winnerOne = 39588, winnerTwo = 21408, ties = 28800)

## ------------------------------------------------------------------------

PrintBoard <- function(node) {
  mineV <- rep(0, 9)

  
  t <- Traverse(node, traversal = "ancestor", filterFun = function(x) !x$isRoot && x$player == 1)
  field <- Get(t, "f")
  value <- Get(t, function(x) paste0("X", x$level - 1))
  mineV[field] <- value
  
  t <- Traverse(node, traversal = "ancestor", filterFun = function(x) !x$isRoot && x$player == 2)
  field <- Get(t, "f")
  value <- Get(t, function(x) paste0("O", x$level - 1))
  mineV[field] <- value
    
  mineM <- matrix(mineV, 3, 3, byrow = TRUE)
  rownames(mineM) <- letters[1:3]
  colnames(mineM) <- as.character(1:3)
  mineM
}


## ---- eval = FALSE-------------------------------------------------------
#  
#  PrintBoard(ties[[1]])
#  

## ---- echo = FALSE-------------------------------------------------------
mt <- matrix(c("O2", "X3", "O4", "X5", "O6", "X7", "X1", "O8", "X9"), nrow = 3, ncol = 3, byrow = TRUE)
rownames(mt) <- letters[1:3]
colnames(mt) <- as.character(1:3)
mt

## ---- eval=FALSE---------------------------------------------------------
#  
#  
#  AnalyseTicTacToe <- function(subtree) {
#    # 1. create sub-tree
#    AddPossibleMoves(subtree)
#    # 2. run the analysis
#    winnerOne <- Traverse(subtree, filterFun = function(x) x$isLeaf && x$result == 1)
#    winnerTwo <- Traverse(subtree, filterFun = function(x) x$isLeaf && x$result == 2)
#    ties <- Traverse(subtree, filterFun = function(x) x$isLeaf && x$result == 0)
#  
#    res <- c(winnerOne = length(winnerOne),
#             winnerTwo = length(winnerTwo),
#             ties = length(ties))
#    # 3. return the result
#    return(res)
#  }
#  
#  
#  library(foreach)
#  library(doParallel)
#  registerDoParallel(makeCluster(3))
#  #On Linux, there are other alternatives, e.g.: library(doMC);  registerDoMC(3)
#  system.time(
#    x <- foreach (child = ttt$children,
#                  .packages = "data.tree") %dopar% AnalyseTicTacToe(child)
#  )

## ---- echo= FALSE--------------------------------------------------------
c(user = 0.05, system = 0.04, elapsed = 116.86)

## ---- eval = FALSE-------------------------------------------------------
#  stopImplicitCluster()
#  # 4. aggregate results
#  rowSums(sapply(x, c))

## ---- echo=FALSE---------------------------------------------------------
c(winnerOne = 39588, winnerTwo = 21408, ties = 28800)

