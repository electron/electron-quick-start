################################################################################
# Demo of gexf function - An example with real data
# Author: Jorge Fabrega
################################################################################

pause <- function() {  
  invisible(readline("\nPress <return> to continue: ")) 
}

# Example to be used as a demo for rgexf
# This example uses follower-following relationships among chilean politicians,
# journalists and political analysists on Twitter (sample) by december 2011. 
# Source: Fabrega and Paredes (2012): 'La politica en 140 caracteres'
# en Intermedios: medios de comunicacion y democracia en Chile. Ediciones UDP

pause()

# inputs: twitter accounts of chilean politicians and the list of following relationships
# among them in the online social network Twitter.
# for more information about Twitter, please visit: www.twitter.com

data(twitteraccounts)
data(followers)

# preparing data 
nodos <- data.frame(id=1:NROW(twitteraccounts), label=twitteraccounts$label)

nodos.att <- subset(twitteraccounts, select=c(cargo, partido, sector, categoria))
relations<- subset(followers, select=c(source, target))

# Creating the follower-following network in gexf format with some nodes' attribute
pause()

x1 <- write.gexf(nodos, relations, keepFactors=F, nodesAtt=nodos.att)

summary(x1)
