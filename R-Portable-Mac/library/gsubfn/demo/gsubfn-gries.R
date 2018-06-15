
# linguistic applications by Stefan Th. Gries

# create word frequency list from the gsubfn COPYING file

fn1 <- system.file("lipsum.txt", package = "gsubfn")
Lines1 <- tolower(scan(fn1, what = "char", sep = "\n"))
tail(sort(table(unlist(strapply(Lines1, "\\w+", perl = TRUE)))))

# frequency list of words from an SGML-annotated text file 
# sampled from the British National Corpus"

fn2 <- system.file("sample.txt", package = "gsubfn")
Lines2 <- scan(fn2, what = "char", sep = "\n")
tagged.corpus.sentences <- grep("^<s n=", Lines2, value = TRUE)
# just to see what it looks like
tagged.corpus.sentences[c(3, 8)]
words <- unlist(strapply(tagged.corpus.sentences, ">([^<]*)"))
words <- gsub(" $", "", words)
tail(words, 25)

# frequency list of words AND tags from same file

word.tag.pairs <- unlist(strapply(tagged.corpus.sentences, "<[^<]*")) 
cleaned.word.tag.pairs <- grep("<w ", word.tag.pairs, value = TRUE)
cleaned.word.tag.pairs <- gsub(" +$", "", cleaned.word.tag.pairs)
tail(sort(table(cleaned.word.tag.pairs)))
tail(cleaned.word.tag.pairs)

