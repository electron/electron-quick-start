### R code from vignette source 'OGR_shape_encoding.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: OGR_shape_encoding.Rnw:66-67
###################################################
library(rgdal)


###################################################
### code chunk number 2: OGR_shape_encoding.Rnw:69-70 (eval = FALSE)
###################################################
## .Call("RGDAL_CPL_RECODE_ICONV", PACKAGE="rgdal")


###################################################
### code chunk number 3: OGR_shape_encoding.Rnw:82-86
###################################################
dsn <- system.file("etc", package="rgdal")
layer <- "point"
oI <- ogrInfo(dsn, layer)
attr(oI, "LDID")


###################################################
### code chunk number 4: OGR_shape_encoding.Rnw:92-94
###################################################
scan(paste(dsn, .Platform$file.sep, layer, ".cpg", sep=""),
 "character")


###################################################
### code chunk number 5: OGR_shape_encoding.Rnw:102-104 (eval = FALSE)
###################################################
## writeOGR(mySDF, dsn, layer, driver="ESRI Shapefile",
##  layer_options='ENCODING="LDID/31"')


###################################################
### code chunk number 6: OGR_shape_encoding.Rnw:114-116
###################################################
Sys.getlocale("LC_CTYPE")
unlist(l10n_info())


###################################################
### code chunk number 7: OGR_shape_encoding.Rnw:126-127
###################################################
load(paste(dsn, .Platform$file.sep, "point_LinuxGDAL.RData", sep=""))


###################################################
### code chunk number 8: OGR_shape_encoding.Rnw:129-130 (eval = FALSE)
###################################################
## sessionInfo()


###################################################
### code chunk number 9: OGR_shape_encoding.Rnw:132-133
###################################################
sI_1


###################################################
### code chunk number 10: OGR_shape_encoding.Rnw:138-139 (eval = FALSE)
###################################################
## .Call("RGDAL_CPL_RECODE_ICONV", PACKAGE="rgdal")


###################################################
### code chunk number 11: OGR_shape_encoding.Rnw:141-142
###################################################
cpliconv_1


###################################################
### code chunk number 12: OGR_shape_encoding.Rnw:148-149 (eval = FALSE)
###################################################
## getCPLConfigOption("SHAPE_ENCODING")


###################################################
### code chunk number 13: OGR_shape_encoding.Rnw:151-152
###################################################
NULL


###################################################
### code chunk number 14: OGR_shape_encoding.Rnw:158-162 (eval = FALSE)
###################################################
## setCPLConfigOption("SHAPE_ENCODING", "CP1250")
## pt1 <- readOGR(dsn, layer, stringsAsFactors=FALSE)
## setCPLConfigOption("SHAPE_ENCODING", NULL)
## charToRaw(pt1$NAZEV[1])


###################################################
### code chunk number 15: OGR_shape_encoding.Rnw:164-165
###################################################
pt2cr_1


###################################################
### code chunk number 16: OGR_shape_encoding.Rnw:167-169 (eval = FALSE)
###################################################
## pt2 <- readOGR(dsn, layer, stringsAsFactors=FALSE, encoding="CP1250")
## charToRaw(pt2$NAZEV[1])


###################################################
### code chunk number 17: OGR_shape_encoding.Rnw:171-172
###################################################
pt2cr_1


###################################################
### code chunk number 18: OGR_shape_encoding.Rnw:174-179 (eval = FALSE)
###################################################
## setCPLConfigOption("SHAPE_ENCODING", "")
## pt3 <- readOGR(dsn, layer, stringsAsFactors=FALSE)
## setCPLConfigOption("SHAPE_ENCODING", NULL)
## pt1i_1 <- iconv(pt3$NAZEV[1], from="CP1250", to="UTF-8")
## charToRaw(pt1i_1)


###################################################
### code chunk number 19: OGR_shape_encoding.Rnw:181-182
###################################################
pt1icr_1


###################################################
### code chunk number 20: OGR_shape_encoding.Rnw:188-193 (eval = FALSE)
###################################################
## setCPLConfigOption("SHAPE_ENCODING", "")
## pt4 <- readOGR(dsn, layer, stringsAsFactors=FALSE, use_iconv=TRUE,
##  encoding="CP1250")
## setCPLConfigOption("SHAPE_ENCODING", NULL)
## charToRaw(pt4$NAZEV[1])


###################################################
### code chunk number 21: OGR_shape_encoding.Rnw:195-196
###################################################
pt1icr_1


###################################################
### code chunk number 22: OGR_shape_encoding.Rnw:202-204 (eval = FALSE)
###################################################
## pt5 <- readOGR(dsn, layer, stringsAsFactors=FALSE)
## charToRaw(pt5$NAZEV[1])


###################################################
### code chunk number 23: OGR_shape_encoding.Rnw:206-207
###################################################
ptcr_1


###################################################
### code chunk number 24: OGR_shape_encoding.Rnw:209-210 (eval = FALSE)
###################################################
## all.equal(charToRaw(pt5$NAZEV[1]), charToRaw(pt4$NAZEV[1]))


###################################################
### code chunk number 25: OGR_shape_encoding.Rnw:212-213
###################################################
all.equal(ptcr_1, pt1icr_1)


###################################################
### code chunk number 26: OGR_shape_encoding.Rnw:220-221
###################################################
load(paste(dsn, .Platform$file.sep, "point_WinCRAN.RData", sep=""))


###################################################
### code chunk number 27: OGR_shape_encoding.Rnw:223-224 (eval = FALSE)
###################################################
## sessionInfo()


###################################################
### code chunk number 28: OGR_shape_encoding.Rnw:226-227
###################################################
sI


###################################################
### code chunk number 29: OGR_shape_encoding.Rnw:229-230 (eval = FALSE)
###################################################
## unlist(l10n_info())


###################################################
### code chunk number 30: OGR_shape_encoding.Rnw:232-233
###################################################
unlist(l10n)


###################################################
### code chunk number 31: OGR_shape_encoding.Rnw:238-239 (eval = FALSE)
###################################################
## .Call("RGDAL_CPL_RECODE_ICONV", PACKAGE="rgdal")


###################################################
### code chunk number 32: OGR_shape_encoding.Rnw:241-242
###################################################
cpliconv


###################################################
### code chunk number 33: OGR_shape_encoding.Rnw:248-252 (eval = FALSE)
###################################################
## setCPLConfigOption("SHAPE_ENCODING", "")
## pt6 <- readOGR(dsn, layer, stringsAsFactors=FALSE)
## setCPLConfigOption("SHAPE_ENCODING", NULL)
## charToRaw(pt6$NAZEV[1])


###################################################
### code chunk number 34: OGR_shape_encoding.Rnw:254-255
###################################################
pt1cr


###################################################
### code chunk number 35: OGR_shape_encoding.Rnw:257-259 (eval = FALSE)
###################################################
## pt7 <- readOGR(dsn, layer, stringsAsFactors=FALSE, encoding="")
## charToRaw(pt7$NAZEV[1])


###################################################
### code chunk number 36: OGR_shape_encoding.Rnw:261-262
###################################################
pt1cr


