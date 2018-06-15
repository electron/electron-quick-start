foo <- 
function(x= 10, b="asd") { 
 if(x) 
  1 
 else if(T) 
        2 
      else 4
}

bar <- 
function(x)
{
 for(i in 1:length(x)) {
    print(x[[i]])
 }

 return(T)
}

single <-
function(x)
  T


While <-
function()
{
 while(f(x)) {
   print(f(x))
   break
 }

 repeat {
   x <- x + 1
   break
 }
}

Logic <-
function()
{
  if(x < 1 && y > 10) {
     x | y & z
  }
}
