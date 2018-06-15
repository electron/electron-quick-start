# e.g.
#   getTradeMeCarData("http://www.trademe.co.nz/Trade-Me-Motors/Cars/Subaru/mcat-0001-0268-0332-.htm")

getTradeMeCarPage =
function(url, base = NULL)
{
   tmp = parseURI(url)
   if(tmp$server == "")
     url = paste(base$scheme, "://", base$server, url, sep = "")
   
   d = htmlTreeParse(url, useInternal = TRUE)
   n = getNodeSet(d, "//table[@class='listings']")
   n = n[[1]]
   if(xmlName(n[[1]]) == "tbody") {
     rows = n[[1]]
   } else
     rows = n

   list(doc = d, rows = rows)
}

if(FALSE) {
 tbody = getTradeMeCarPage("~/TradeMe.cars.subaru.html")$tbody
       # the children of tbody are all tr elements
 table(xmlSApply(tbody, xmlName))

       # And the first one has two elements and the remainder are the actual car listings
 xmlSApply(tbody, xmlSize)
}


getTradeMeCarData =
function(url = "~/TradeMe.cars.subaru.html",
         data = NULL, numPages = 1)
{
  uri = parseURI(url)
  
  doc = getTradeMeCarPage(url)
  rows = doc$rows
 
  if(is.null(data)) {
       # The first row has an entry of the form 1234 listings, showing 1 to 50"
       # so we get this number via regular expressions and gsub on the content
       # of that first cell.
   num = as.integer(gsub("^([0-9]+) .*", "\\1", xmlValue(rows[[1]][[1]])))


   if(is.na(num) || numPages == 1)
     num = xmlSize(rows) - 1

# type/description, kms, amount,  # bids, 

     data = data.frame(description = I(character(num)),
                       kms = integer(num),
                       askingPrice = integer(num),
                       numBid = as.integer(rep(NA, num)),
                       auctionExpiration = I(character(num)),
                       year = integer(num)              
                      )
   }

   page = 1
   cur = 1   
   while(page <= numPages) {

     tbody = rows
     for(i in 2:xmlSize(tbody)) {
       r = tbody[[i]]
       data[cur, 1] = xmlValue(r[[2]])
       data[cur, "year"] = as.integer(gsub(".* ([0-9]{4})", "\\1", strsplit(data[cur, 1], "\302\240")[[1]][1]))
       data[cur, 2] = as.integer(gsub(",", "", xmlValue(r[[3]][[1]])))
       data[cur, 3] = as.integer(gsub("[,$]", "", xmlValue(r[[4]])))

       bids = xmlValue(r[[6]])
       if(bids != "-")
         data[cur, 4] = as.integer(bids)

       data[cur, 5] = xmlValue(r[[7]])
       cur = cur + 1
     }

     nxt = getNodeSet(doc$doc, "//table//a/font/b[text() = 'Next']")
     if(length(nxt) == 0) {
       browser()
       print("no next page")
       break
     }

         # Get the <a href=> element for the Next
     a = xmlParent(xmlParent(nxt[[1]]))
     doc = getTradeMeCarPage(xmlGetAttr(a, "href"), base = uri)
     tbody = doc$tbody
   }

   data[1:(cur-1), ]
#   invisible(data)
}
