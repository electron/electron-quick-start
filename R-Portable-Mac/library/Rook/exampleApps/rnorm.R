app <- Builder$new(
    URLMap$new(
	'^/.*\\.html$' = function(env){
	    req <- Request$new(env)
	    res <- Response$new()
	    if (is.null(req$GET()$n)){
		n <- 100
	    } else {
		n <- as.integer(req$GET()$n)
	    }
	    res$write('How many squares?\n')
	    res$write('<form method="GET">\n')
	    res$write(sprintf('<input type="text" name="n" value="%d">\n',n))
	    res$write('<input type="submit" name="Submit">\n</form>\n<br>')
	    if (n>0){
		res$write(paste('<img src="',req$to_url('/plot.png',n=n),'">',sep=''))
	    }
	    res$finish()
	},
	'^/.*\\.png$' = function(env){
	    req <- Request$new(env)
	    res <- Response$new()
	    res$header('Content-type','image/png')
	    if (is.null(req$GET()$n)){
		n <- 100
	    } else {
		n <- as.integer(req$GET()$n)
	    }
	    t <- tempfile()
	    png(file=t)
	    png(t,type="cairo",width=200,height=200)
	    par(mar=rep(0,4))
	    plot(rnorm(n),col=rainbow(n,alpha=runif(n,0,1)),pch='.',cex=c(2,3,4,5,10,50))
	    dev.off()
	    res$body <- t
	    names(res$body) <- 'file'
	    res$finish()
	},
	'.*' = Redirect$new('/index.html')
    )
)
