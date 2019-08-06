if(requireNamespace("scico")) {

library("colorspace")

scico_seq <- c("Oslo", "Lajolla", "Turku")
for(i in scico_seq) specplot(rev(scico::scico(9, palette = tolower(i))), sequential_hcl(9, i, rev = i == "Lajolla"), main = i)

scico_div <- c("Broc", "Cork", "Vik", "Berlin", "Lisbon", "Tofino")
for(i in scico_div) specplot(scico::scico(11, palette = tolower(i)), diverging_hcl(11, i), main = i)

}
