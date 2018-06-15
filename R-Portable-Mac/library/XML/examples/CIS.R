require(RCurl)
require(XML)
#myCurl = getCurlHandle()
#getURL("http://www.statindex.org/CIS/psqlQuery/", cookiejar = "-", curl = myCurl)
#.opts = list(cookie = '_ZopeId="19324353A25Uc.N15jM"', verbose = TRUE))
mycookie <-  '_ZopeId="19324353A25Uc.N15jM"'

CISQuery <- function(author = "Ihaka", title = "", keyword = "",
                journal = "", yearbeg = "", yearend = "", format = "bib",
                url = "http://www.statindex.org/CIS/psqlQuery/Searcher",
                cookie=mycookie){
        v <-  postForm(url, skip = "+", authed = "+", authed = "a",
          authorstring = author, titlestring = title,
          keywordstring = keyword, jnt = "jp", jnamestring = journal, pt= "+",
          pt = "b", pt = "j", pt = "p", pt = "+",
          yearbeg = yearbeg, yearend = yearend,
          startDisplay = "1", endDisplay = "50", fmt = format,
          .opts = list(cookie = cookie, verbose = TRUE))
        browser()
        g <- htmlTreeParse(v,asText = TRUE)
        h <- g$children$html[["body"]]
        uh <- unlist(h)
        ugh <- uh[grep("not an authenticated user",uh)]
        if(length(ugh)>0)
                stop("Not an authenticated CIS user")
        h <- h[["pre"]][["text"]]
        i <- unlist(strsplit(h$value,"@"))[-1]
        j <- gsub("\n+$","",i)
        k <- gsub("^","@",j)
        l <- sapply(k, function(x) strsplit(x,"\n"),USE.NAMES = FALSE)
        lapply(l,function(x) {x; class(x) <- "Bibtex"; x})
        }
f <- CISQuery(cookie=mycookie) 
