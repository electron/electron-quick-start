#  Copyright (C) 2003-2009 The R Core Team

require(grDevices); require(graphics)

## --- Japanese characters in the Hershey Vector Fonts

######
# create tables of Japanese characters
######
make.table <- function(nr, nc) {
    opar <- par(mar=rep(0, 4), pty="s")
    plot(c(0, nc*(10%/%nc) + 1), c(0, -(nr + 1)),
         type="n", xlab="", ylab="", axes=FALSE)
    invisible(opar)
}

get.r <- function(i, nr)   i %% nr + 1
get.c <- function(i, nr)   i %/% nr + 1
Esc2 <- function(str)	   paste("\\", str, sep="")

draw.title <- function(title, nc)
    text((nc*(10%/%nc) + 1)/2, 0, title, font=2)

draw.vf.cell <- function(typeface, fontindex, string, i, nr, raw.string=NULL) {
    r <- get.r(i, nr)
    c <- get.c(i, nr)
    x0 <- 2*(c - 1)
    if (is.null(raw.string)) raw.string <- Esc2(string)
    text(x0 + 1.1, -r, raw.string, col="grey")
    text(x0 + 2,   -r, string, vfont=c(typeface, fontindex))
    rect(x0 +  .5, -(r - .5), x0 + 2.5, -(r + .5), border="grey")
}

draw.vf.cell2 <- function(string, alt, i, nr) {
    r <- get.r(i, nr)
    c <- get.c(i, nr)
    x0 <- 3*(c - 1)
    text(x0 + 1.1, -r, Esc2(string <- Esc2(string)), col="grey")
    text(x0 + 2.2, -r, Esc2(Esc2(alt)), col="grey", cex=.6)
    text(x0 + 3,   -r, string, vfont=c("serif", "plain"))
    rect(x0 +  .5, -(r - .5), x0 + 3.5, -(r + .5), border="grey")
}

tf <- "serif"
fi <- "plain"
nr <- 25
nc <- 4
oldpar <- make.table(nr, nc)
index <- 0
digits <- c(0:9,"a","b","c","d","e","f")
draw.title("Hiragana : \\\\#J24nn", nc)
for (i in 2:7) {
    for (j in 1:16) {
	if (!((i == 2 && j == 1) || (i == 7 && j > 4))) {
	    draw.vf.cell(tf, fi, paste("\\#J24", i, digits[j], sep=""),
	                 index, nr)
            index <- index + 1
	}
    }
}

nr <- 25
nc <- 4
make.table(nr, nc)
index <- 0
digits <- c(0:9,"a","b","c","d","e","f")
draw.title("Katakana : \\\\#J25nn", nc)
for (i in 2:7) {
    for (j in 1:16) {
	if (!((i == 2 && j == 1) || (i == 7 && j > 7))) {
	    draw.vf.cell(tf, fi, paste("\\#J25", i, digits[j], sep=""),
	                 index, nr)
            index <- index + 1
	}
    }
}

nr <- 26
nc <- 3
make.table(nr, nc)
i <- 0
draw.title("Kanji (1)", nc)
draw.vf.cell2("#J3021", "#N0043", i, nr); i <- i + 1
draw.vf.cell2("#J3026", "#N2829", i, nr); i <- i + 1
draw.vf.cell2("#J302d", "#N0062", i, nr); i <- i + 1
draw.vf.cell2("#J3035", "#N0818", i, nr); i <- i + 1
draw.vf.cell2("#J303f", "#N1802", i, nr); i <- i + 1
draw.vf.cell2("#J3045", "#N2154", i, nr); i <- i + 1
draw.vf.cell2("#J304c", "#N0401", i, nr); i <- i + 1
draw.vf.cell2("#J3057", "#N2107", i, nr); i <- i + 1
draw.vf.cell2("#J3059", "#N0138", i, nr); i <- i + 1
draw.vf.cell2("#J305b", "#N3008", i, nr); i <- i + 1
draw.vf.cell2("#J305e", "#N3579", i, nr); i <- i + 1
draw.vf.cell2("#J3061", "#N4214", i, nr); i <- i + 1
draw.vf.cell2("#J306c", "#N0001", i, nr); i <- i + 1
draw.vf.cell2("#J3070", "#N3294", i, nr); i <- i + 1
draw.vf.cell2("#J3078", "#N1026", i, nr); i <- i + 1
draw.vf.cell2("#J307a", "#N1562", i, nr); i <- i + 1
draw.vf.cell2("#J3122", "#N5006", i, nr); i <- i + 1
draw.vf.cell2("#J3126", "#N0878", i, nr); i <- i + 1
draw.vf.cell2("#J3127", "#N1280", i, nr); i <- i + 1
draw.vf.cell2("#J3129", "#N3673", i, nr); i <- i + 1
draw.vf.cell2("#J312b", "#N5042", i, nr); i <- i + 1
draw.vf.cell2("#J3132", "#N2629", i, nr); i <- i + 1
draw.vf.cell2("#J313b", "#N2973", i, nr); i <- i + 1
draw.vf.cell2("#J313f", "#N4725", i, nr); i <- i + 1
draw.vf.cell2("#J3140", "#N5046", i, nr); i <- i + 1
draw.vf.cell2("#J314a", "#N0130", i, nr); i <- i + 1
draw.vf.cell2("#J3155", "#N2599", i, nr); i <- i + 1
draw.vf.cell2("#J315f", "#N0617", i, nr); i <- i + 1
draw.vf.cell2("#J3173", "#N4733", i, nr); i <- i + 1
draw.vf.cell2("#J3176", "#N1125", i, nr); i <- i + 1
draw.vf.cell2("#J3177", "#N2083", i, nr); i <- i + 1
draw.vf.cell2("#J317e", "#N1504", i, nr); i <- i + 1
draw.vf.cell2("#J3221", "#N1885", i, nr); i <- i + 1
draw.vf.cell2("#J3223", "#N2361", i, nr); i <- i + 1
draw.vf.cell2("#J3226", "#N2922", i, nr); i <- i + 1
draw.vf.cell2("#J322b", "#N5399", i, nr); i <- i + 1
draw.vf.cell2("#J322f", "#N0551", i, nr); i <- i + 1
draw.vf.cell2("#J3235", "#N0260", i, nr); i <- i + 1
draw.vf.cell2("#J3239", "#N2634", i, nr); i <- i + 1
draw.vf.cell2("#J323b", "#N5110", i, nr); i <- i + 1
draw.vf.cell2("#J323c", "#N0009", i, nr); i <- i + 1
draw.vf.cell2("#J323d", "#N0350", i, nr); i <- i + 1
draw.vf.cell2("#J323f", "#N0409", i, nr); i <- i + 1
draw.vf.cell2("#J3241", "#N0422", i, nr); i <- i + 1
draw.vf.cell2("#J3243", "#N0716", i, nr); i <- i + 1
draw.vf.cell2("#J3244", "#N0024", i, nr); i <- i + 1
draw.vf.cell2("#J3246", "#N0058", i, nr); i <- i + 1
draw.vf.cell2("#J3248", "#N1311", i, nr); i <- i + 1
draw.vf.cell2("#J324a", "#N3272", i, nr); i <- i + 1
draw.vf.cell2("#J324c", "#N0107", i, nr); i <- i + 1
draw.vf.cell2("#J324f", "#N2530", i, nr); i <- i + 1
draw.vf.cell2("#J3250", "#N2743", i, nr); i <- i + 1
draw.vf.cell2("#J3256", "#N3909", i, nr); i <- i + 1
draw.vf.cell2("#J3259", "#N3956", i, nr); i <- i + 1
draw.vf.cell2("#J3261", "#N4723", i, nr); i <- i + 1
draw.vf.cell2("#J3267", "#N2848", i, nr); i <- i + 1
draw.vf.cell2("#J3268", "#N0050", i, nr); i <- i + 1
draw.vf.cell2("#J3272", "#N4306", i, nr); i <- i + 1
draw.vf.cell2("#J3273", "#N1028", i, nr); i <- i + 1
draw.vf.cell2("#J3323", "#N2264", i, nr); i <- i + 1
draw.vf.cell2("#J3324", "#N2553", i, nr); i <- i + 1
draw.vf.cell2("#J3326", "#N2998", i, nr); i <- i + 1
draw.vf.cell2("#J3328", "#N3537", i, nr); i <- i + 1
draw.vf.cell2("#J332b", "#N4950", i, nr); i <- i + 1
draw.vf.cell2("#J332d", "#N4486", i, nr); i <- i + 1
draw.vf.cell2("#J3330", "#N1168", i, nr); i <- i + 1
draw.vf.cell2("#J3346", "#N1163", i, nr); i <- i + 1
draw.vf.cell2("#J334b", "#N2254", i, nr); i <- i + 1
draw.vf.cell2("#J3351", "#N4301", i, nr); i <- i + 1
draw.vf.cell2("#J3353", "#N4623", i, nr); i <- i + 1
draw.vf.cell2("#J3357", "#N5088", i, nr); i <- i + 1
draw.vf.cell2("#J3358", "#N1271", i, nr); i <- i + 1
draw.vf.cell2("#J335a", "#N2324", i, nr); i <- i + 1
draw.vf.cell2("#J3364", "#N0703", i, nr); i <- i + 1
draw.vf.cell2("#J3424", "#N2977", i, nr); i <- i + 1
draw.vf.cell2("#J3428", "#N1322", i, nr); i <- i + 1

make.table(nr, nc)
i <- 0
draw.title("Kanji (2)", nc)
draw.vf.cell2("#J342c", "#N1466", i, nr); i <- i + 1
draw.vf.cell2("#J3433", "#N1492", i, nr); i <- i + 1
draw.vf.cell2("#J3434", "#N0790", i, nr); i <- i + 1
draw.vf.cell2("#J3436", "#N1731", i, nr); i <- i + 1
draw.vf.cell2("#J3437", "#N1756", i, nr); i <- i + 1
draw.vf.cell2("#J3445", "#N2988", i, nr); i <- i + 1
draw.vf.cell2("#J3449", "#N3416", i, nr); i <- i + 1
draw.vf.cell2("#J3454", "#N4750", i, nr); i <- i + 1
draw.vf.cell2("#J3456", "#N4949", i, nr); i <- i + 1
draw.vf.cell2("#J3458", "#N4958", i, nr); i <- i + 1
draw.vf.cell2("#J346f", "#N0994", i, nr); i <- i + 1
draw.vf.cell2("#J3470", "#N1098", i, nr); i <- i + 1
draw.vf.cell2("#J3476", "#N1496", i, nr); i <- i + 1
draw.vf.cell2("#J347c", "#N3785", i, nr); i <- i + 1
draw.vf.cell2("#J3521", "#N2379", i, nr); i <- i + 1
draw.vf.cell2("#J3522", "#N1582", i, nr); i <- i + 1
draw.vf.cell2("#J3524", "#N2480", i, nr); i <- i + 1
draw.vf.cell2("#J3525", "#N2507", i, nr); i <- i + 1
draw.vf.cell2("#J352d", "#N4318", i, nr); i <- i + 1
draw.vf.cell2("#J3530", "#N4610", i, nr); i <- i + 1
draw.vf.cell2("#J3534", "#N5276", i, nr); i <- i + 1
draw.vf.cell2("#J3535", "#N5445", i, nr); i <- i + 1
draw.vf.cell2("#J3546", "#N3981", i, nr); i <- i + 1
draw.vf.cell2("#J3555", "#N4685", i, nr); i <- i + 1
draw.vf.cell2("#J355a", "#N0154", i, nr); i <- i + 1
draw.vf.cell2("#J355b", "#N0885", i, nr); i <- i + 1
draw.vf.cell2("#J355d", "#N1560", i, nr); i <- i + 1
draw.vf.cell2("#J3565", "#N2941", i, nr); i <- i + 1
draw.vf.cell2("#J3566", "#N3314", i, nr); i <- i + 1
draw.vf.cell2("#J3569", "#N3496", i, nr); i <- i + 1
draw.vf.cell2("#J356d", "#N2852", i, nr); i <- i + 1
draw.vf.cell2("#J356e", "#N1051", i, nr); i <- i + 1
draw.vf.cell2("#J356f", "#N1387", i, nr); i <- i + 1
draw.vf.cell2("#J3575", "#N4109", i, nr); i <- i + 1
draw.vf.cell2("#J3577", "#N4548", i, nr); i <- i + 1
draw.vf.cell2("#J357b", "#N5281", i, nr); i <- i + 1
draw.vf.cell2("#J357e", "#N0295", i, nr); i <- i + 1
draw.vf.cell2("#J3621", "#N0431", i, nr); i <- i + 1
draw.vf.cell2("#J3626", "#N0581", i, nr); i <- i + 1
draw.vf.cell2("#J362d", "#N1135", i, nr); i <- i + 1
draw.vf.cell2("#J362f", "#N1571", i, nr); i <- i + 1
draw.vf.cell2("#J3635", "#N2052", i, nr); i <- i + 1
draw.vf.cell2("#J3636", "#N2378", i, nr); i <- i + 1
draw.vf.cell2("#J364a", "#N0103", i, nr); i <- i + 1
draw.vf.cell2("#J364b", "#N2305", i, nr); i <- i + 1
draw.vf.cell2("#J364c", "#N2923", i, nr); i <- i + 1
draw.vf.cell2("#J3651", "#N1065", i, nr); i <- i + 1
draw.vf.cell2("#J3661", "#N4671", i, nr); i <- i + 1
draw.vf.cell2("#J3662", "#N4815", i, nr); i <- i + 1
draw.vf.cell2("#J3664", "#N4855", i, nr); i <- i + 1
draw.vf.cell2("#J3665", "#N0146", i, nr); i <- i + 1
draw.vf.cell2("#J3671", "#N3128", i, nr); i <- i + 1
draw.vf.cell2("#J3675", "#N3317", i, nr); i <- i + 1
draw.vf.cell2("#J367e", "#N1386", i, nr); i <- i + 1
draw.vf.cell2("#J3738", "#N0449", i, nr); i <- i + 1
draw.vf.cell2("#J3739", "#N0534", i, nr); i <- i + 1
draw.vf.cell2("#J373e", "#N2937", i, nr); i <- i + 1
draw.vf.cell2("#J373f", "#N1077", i, nr); i <- i + 1
draw.vf.cell2("#J3741", "#N1589", i, nr); i <- i + 1
draw.vf.cell2("#J3742", "#N1602", i, nr); i <- i + 1
draw.vf.cell2("#J374f", "#N0195", i, nr); i <- i + 1
draw.vf.cell2("#J3750", "#N3523", i, nr); i <- i + 1
draw.vf.cell2("#J3757", "#N4312", i, nr); i <- i + 1
draw.vf.cell2("#J375a", "#N4620", i, nr); i <- i + 1
draw.vf.cell2("#J3767", "#N2412", i, nr); i <- i + 1
draw.vf.cell2("#J3768", "#N2509", i, nr); i <- i + 1
draw.vf.cell2("#J376a", "#N3313", i, nr); i <- i + 1
draw.vf.cell2("#J376b", "#N3540", i, nr); i <- i + 1
draw.vf.cell2("#J376c", "#N4205", i, nr); i <- i + 1
draw.vf.cell2("#J376e", "#N2169", i, nr); i <- i + 1
draw.vf.cell2("#J3777", "#N1045", i, nr); i <- i + 1
draw.vf.cell2("#J3824", "#N2868", i, nr); i <- i + 1
draw.vf.cell2("#J3826", "#N3180", i, nr); i <- i + 1
draw.vf.cell2("#J3828", "#N3543", i, nr); i <- i + 1
draw.vf.cell2("#J382b", "#N4284", i, nr); i <- i + 1
draw.vf.cell2("#J3833", "#N5220", i, nr); i <- i + 1

make.table(nr, nc)
i <- 0
draw.title("Kanji (3)", nc)
draw.vf.cell2("#J3835", "#N0275", i, nr); i <- i + 1
draw.vf.cell2("#J3836", "#N0825", i, nr); i <- i + 1
draw.vf.cell2("#J3839", "#N1568", i, nr); i <- i + 1
draw.vf.cell2("#J383a", "#N2637", i, nr); i <- i + 1
draw.vf.cell2("#J383b", "#N2656", i, nr); i <- i + 1
draw.vf.cell2("#J383d", "#N2943", i, nr); i <- i + 1
draw.vf.cell2("#J3840", "#N4309", i, nr); i <- i + 1
draw.vf.cell2("#J3842", "#N4987", i, nr); i <- i + 1
draw.vf.cell2("#J3845", "#N0770", i, nr); i <- i + 1
draw.vf.cell2("#J3847", "#N1036", i, nr); i <- i + 1
draw.vf.cell2("#J384c", "#N1567", i, nr); i <- i + 1
draw.vf.cell2("#J384d", "#N1817", i, nr); i <- i + 1
draw.vf.cell2("#J384e", "#N2044", i, nr); i <- i + 1
draw.vf.cell2("#J385d", "#N5415", i, nr); i <- i + 1
draw.vf.cell2("#J385e", "#N0015", i, nr); i <- i + 1
draw.vf.cell2("#J3861", "#N0162", i, nr); i <- i + 1
draw.vf.cell2("#J3865", "#N1610", i, nr); i <- i + 1
draw.vf.cell2("#J3866", "#N1628", i, nr); i <- i + 1
draw.vf.cell2("#J386c", "#N4374", i, nr); i <- i + 1
draw.vf.cell2("#J3872", "#N0290", i, nr); i <- i + 1
draw.vf.cell2("#J3877", "#N1358", i, nr); i <- i + 1
draw.vf.cell2("#J3878", "#N0579", i, nr); i <- i + 1
draw.vf.cell2("#J387d", "#N0868", i, nr); i <- i + 1
draw.vf.cell2("#J387e", "#N0101", i, nr); i <- i + 1
draw.vf.cell2("#J3929", "#N1451", i, nr); i <- i + 1
draw.vf.cell2("#J3931", "#N1683", i, nr); i <- i + 1
draw.vf.cell2("#J393d", "#N2343", i, nr); i <- i + 1
draw.vf.cell2("#J3943", "#N0092", i, nr); i <- i + 1
draw.vf.cell2("#J394d", "#N3684", i, nr); i <- i + 1
draw.vf.cell2("#J3954", "#N4213", i, nr); i <- i + 1
draw.vf.cell2("#J3955", "#N1641", i, nr); i <- i + 1
draw.vf.cell2("#J395b", "#N4843", i, nr); i <- i + 1
draw.vf.cell2("#J395d", "#N4883", i, nr); i <- i + 1
draw.vf.cell2("#J395f", "#N4994", i, nr); i <- i + 1
draw.vf.cell2("#J3960", "#N1459", i, nr); i <- i + 1
draw.vf.cell2("#J3961", "#N5188", i, nr); i <- i + 1
draw.vf.cell2("#J3962", "#N5248", i, nr); i <- i + 1
draw.vf.cell2("#J3966", "#N0882", i, nr); i <- i + 1
draw.vf.cell2("#J3967", "#N0383", i, nr); i <- i + 1
draw.vf.cell2("#J3971", "#N1037", i, nr); i <- i + 1
draw.vf.cell2("#J3975", "#N5403", i, nr); i <- i + 1
draw.vf.cell2("#J397c", "#N5236", i, nr); i <- i + 1
draw.vf.cell2("#J397e", "#N4660", i, nr); i <- i + 1
draw.vf.cell2("#J3a21", "#N2430", i, nr); i <- i + 1
draw.vf.cell2("#J3a23", "#N0352", i, nr); i <- i + 1
draw.vf.cell2("#J3a2c", "#N2261", i, nr); i <- i + 1
draw.vf.cell2("#J3a38", "#N1455", i, nr); i <- i + 1
draw.vf.cell2("#J3a39", "#N3662", i, nr); i <- i + 1
draw.vf.cell2("#J3a42", "#N1515", i, nr); i <- i + 1
draw.vf.cell2("#J3a46", "#N0035", i, nr); i <- i + 1
draw.vf.cell2("#J3a47", "#N2146", i, nr); i <- i + 1
draw.vf.cell2("#J3a59", "#N3522", i, nr); i <- i + 1
draw.vf.cell2("#J3a5f", "#N1055", i, nr); i <- i + 1
draw.vf.cell2("#J3a6e", "#N0407", i, nr); i <- i + 1
draw.vf.cell2("#J3a72", "#N2119", i, nr); i <- i + 1
draw.vf.cell2("#J3a79", "#N2256", i, nr); i <- i + 1
draw.vf.cell2("#J3b2e", "#N3113", i, nr); i <- i + 1
draw.vf.cell2("#J3b30", "#N0008", i, nr); i <- i + 1
draw.vf.cell2("#J3b33", "#N1407", i, nr); i <- i + 1
draw.vf.cell2("#J3b36", "#N2056", i, nr); i <- i + 1
draw.vf.cell2("#J3b3b", "#N3415", i, nr); i <- i + 1
draw.vf.cell2("#J3b40", "#N4789", i, nr); i <- i + 1
draw.vf.cell2("#J3b45", "#N0362", i, nr); i <- i + 1
draw.vf.cell2("#J3b4d", "#N1025", i, nr); i <- i + 1
draw.vf.cell2("#J3b4e", "#N1160", i, nr); i <- i + 1
draw.vf.cell2("#J3b4f", "#N1208", i, nr); i <- i + 1
draw.vf.cell2("#J3b52", "#N1264", i, nr); i <- i + 1
draw.vf.cell2("#J3b54", "#N0284", i, nr); i <- i + 1
draw.vf.cell2("#J3b57", "#N3001", i, nr); i <- i + 1
draw.vf.cell2("#J3b58", "#N1904", i, nr); i <- i + 1
draw.vf.cell2("#J3b59", "#N2039", i, nr); i <- i + 1
draw.vf.cell2("#J3b5e", "#N2211", i, nr); i <- i + 1
draw.vf.cell2("#J3b5f", "#N2429", i, nr); i <- i + 1
draw.vf.cell2("#J3b60", "#N2439", i, nr); i <- i + 1
draw.vf.cell2("#J3b61", "#N2478", i, nr); i <- i + 1
draw.vf.cell2("#J3b64", "#N3265", i, nr); i <- i + 1

make.table(nr, nc)
i <- 0
draw.title("Kanji (4)", nc)
draw.vf.cell2("#J3b65", "#N3492", i, nr); i <- i + 1
draw.vf.cell2("#J3b66", "#N3510", i, nr); i <- i + 1
draw.vf.cell2("#J3b6a", "#N3845", i, nr); i <- i + 1
draw.vf.cell2("#J3b73", "#N2435", i, nr); i <- i + 1
draw.vf.cell2("#J3b75", "#N5428", i, nr); i <- i + 1
draw.vf.cell2("#J3b76", "#N0272", i, nr); i <- i + 1
draw.vf.cell2("#J3b7a", "#N1281", i, nr); i <- i + 1
draw.vf.cell2("#J3b7d", "#N1903", i, nr); i <- i + 1
draw.vf.cell2("#J3b7e", "#N2126", i, nr); i <- i + 1
draw.vf.cell2("#J3c21", "#N0638", i, nr); i <- i + 1
draw.vf.cell2("#J3c27", "#N3209", i, nr); i <- i + 1
draw.vf.cell2("#J3c28", "#N3228", i, nr); i <- i + 1
draw.vf.cell2("#J3c2a", "#N3697", i, nr); i <- i + 1
draw.vf.cell2("#J3c2b", "#N3841", i, nr); i <- i + 1
draw.vf.cell2("#J3c2d", "#N3860", i, nr); i <- i + 1
draw.vf.cell2("#J3c2f", "#N5375", i, nr); i <- i + 1
draw.vf.cell2("#J3c30", "#N1556", i, nr); i <- i + 1
draw.vf.cell2("#J3c34", "#N4619", i, nr); i <- i + 1
draw.vf.cell2("#J3c37", "#N0261", i, nr); i <- i + 1
draw.vf.cell2("#J3c3c", "#N1300", i, nr); i <- i + 1
draw.vf.cell2("#J3c3e", "#N2631", i, nr); i <- i + 1
draw.vf.cell2("#J3c41", "#N4518", i, nr); i <- i + 1
draw.vf.cell2("#J3c42", "#N1297", i, nr); i <- i + 1
draw.vf.cell2("#J3c4d", "#N4603", i, nr); i <- i + 1
draw.vf.cell2("#J3c50", "#N2074", i, nr); i <- i + 1
draw.vf.cell2("#J3c54", "#N3685", i, nr); i <- i + 1
draw.vf.cell2("#J3c56", "#N4608", i, nr); i <- i + 1
draw.vf.cell2("#J3c5c", "#N1377", i, nr); i <- i + 1
draw.vf.cell2("#J3c61", "#N4809", i, nr); i <- i + 1
draw.vf.cell2("#J3c63", "#N3926", i, nr); i <- i + 1
draw.vf.cell2("#J3c67", "#N0285", i, nr); i <- i + 1
draw.vf.cell2("#J3c68", "#N3699", i, nr); i <- i + 1
draw.vf.cell2("#J3c6a", "#N1827", i, nr); i <- i + 1
draw.vf.cell2("#J3c6f", "#N3295", i, nr); i <- i + 1
draw.vf.cell2("#J3c72", "#N2573", i, nr); i <- i + 1
draw.vf.cell2("#J3c73", "#N5186", i, nr); i <- i + 1
draw.vf.cell2("#J3c7e", "#N0622", i, nr); i <- i + 1
draw.vf.cell2("#J3d29", "#N3273", i, nr); i <- i + 1
draw.vf.cell2("#J3d2a", "#N3521", i, nr); i <- i + 1
draw.vf.cell2("#J3d2e", "#N3863", i, nr); i <- i + 1
draw.vf.cell2("#J3d39", "#N4798", i, nr); i <- i + 1
draw.vf.cell2("#J3d3d", "#N0768", i, nr); i <- i + 1
draw.vf.cell2("#J3d3e", "#N1613", i, nr); i <- i + 1
draw.vf.cell2("#J3d44", "#N3597", i, nr); i <- i + 1
draw.vf.cell2("#J3d45", "#N0224", i, nr); i <- i + 1
draw.vf.cell2("#J3d50", "#N0097", i, nr); i <- i + 1
draw.vf.cell2("#J3d51", "#N1621", i, nr); i <- i + 1
draw.vf.cell2("#J3d55", "#N2122", i, nr); i <- i + 1
draw.vf.cell2("#J3d60", "#N0791", i, nr); i <- i + 1
draw.vf.cell2("#J3d63", "#N3509", i, nr); i <- i + 1
draw.vf.cell2("#J3d68", "#N1162", i, nr); i <- i + 1
draw.vf.cell2("#J3d6b", "#N2138", i, nr); i <- i + 1
draw.vf.cell2("#J3d71", "#N3719", i, nr); i <- i + 1
draw.vf.cell2("#J3d77", "#N1185", i, nr); i <- i + 1
draw.vf.cell2("#J3d7c", "#N4993", i, nr); i <- i + 1
draw.vf.cell2("#J3e26", "#N0321", i, nr); i <- i + 1
draw.vf.cell2("#J3e2e", "#N1355", i, nr); i <- i + 1
draw.vf.cell2("#J3e2f", "#N0166", i, nr); i <- i + 1
draw.vf.cell2("#J3e3d", "#N2137", i, nr); i <- i + 1
draw.vf.cell2("#J3e3e", "#N2212", i, nr); i <- i + 1
draw.vf.cell2("#J3e46", "#N2772", i, nr); i <- i + 1
draw.vf.cell2("#J3e4b", "#N3192", i, nr); i <- i + 1
draw.vf.cell2("#J3e4e", "#N3280", i, nr); i <- i + 1
draw.vf.cell2("#J3e57", "#N1638", i, nr); i <- i + 1
draw.vf.cell2("#J3e5a", "#N4341", i, nr); i <- i + 1
draw.vf.cell2("#J3e5d", "#N4472", i, nr); i <- i + 1
draw.vf.cell2("#J3e65", "#N0798", i, nr); i <- i + 1
draw.vf.cell2("#J3e68", "#N0223", i, nr); i <- i + 1
draw.vf.cell2("#J3e6c", "#N1113", i, nr); i <- i + 1
draw.vf.cell2("#J3e6f", "#N1364", i, nr); i <- i + 1
draw.vf.cell2("#J3e75", "#N2839", i, nr); i <- i + 1
draw.vf.cell2("#J3e78", "#N4002", i, nr); i <- i + 1
draw.vf.cell2("#J3f22", "#N2303", i, nr); i <- i + 1
draw.vf.cell2("#J3f27", "#N3889", i, nr); i <- i + 1
draw.vf.cell2("#J3f29", "#N5154", i, nr); i <- i + 1
draw.vf.cell2("#J3f2d", "#N0403", i, nr); i <- i + 1

make.table(nr, nc)
i <- 0
draw.title("Kanji (5)", nc)
draw.vf.cell2("#J3f34", "#N1645", i, nr); i <- i + 1
draw.vf.cell2("#J3f36", "#N1920", i, nr); i <- i + 1
draw.vf.cell2("#J3f37", "#N2080", i, nr); i <- i + 1
draw.vf.cell2("#J3f39", "#N2301", i, nr); i <- i + 1
draw.vf.cell2("#J3f3f", "#N0783", i, nr); i <- i + 1
draw.vf.cell2("#J3f43", "#N3837", i, nr); i <- i + 1
draw.vf.cell2("#J3f48", "#N4601", i, nr); i <- i + 1
draw.vf.cell2("#J3f49", "#N4646", i, nr); i <- i + 1
draw.vf.cell2("#J3f4a", "#N4709", i, nr); i <- i + 1
draw.vf.cell2("#J3f4c", "#N5055", i, nr); i <- i + 1
draw.vf.cell2("#J3f4d", "#N0339", i, nr); i <- i + 1
draw.vf.cell2("#J3f5e", "#N1034", i, nr); i <- i + 1
draw.vf.cell2("#J3f62", "#N0211", i, nr); i <- i + 1
draw.vf.cell2("#J3f65", "#N2482", i, nr); i <- i + 1
draw.vf.cell2("#J3f69", "#N3676", i, nr); i <- i + 1
draw.vf.cell2("#J3f74", "#N2057", i, nr); i <- i + 1
draw.vf.cell2("#J402d", "#N1666", i, nr); i <- i + 1
draw.vf.cell2("#J402e", "#N1799", i, nr); i <- i + 1
draw.vf.cell2("#J4030", "#N2436", i, nr); i <- i + 1
draw.vf.cell2("#J4031", "#N2121", i, nr); i <- i + 1
draw.vf.cell2("#J4032", "#N2143", i, nr); i <- i + 1
draw.vf.cell2("#J4035", "#N0027", i, nr); i <- i + 1
draw.vf.cell2("#J4038", "#N2991", i, nr); i <- i + 1
draw.vf.cell2("#J403e", "#N4273", i, nr); i <- i + 1
draw.vf.cell2("#J4044", "#N5076", i, nr); i <- i + 1
draw.vf.cell2("#J4045", "#N5077", i, nr); i <- i + 1
draw.vf.cell2("#J404e", "#N2108", i, nr); i <- i + 1
draw.vf.cell2("#J404f", "#N2194", i, nr); i <- i + 1
draw.vf.cell2("#J4050", "#N3176", i, nr); i <- i + 1
draw.vf.cell2("#J4051", "#N3306", i, nr); i <- i + 1
draw.vf.cell2("#J4056", "#N4534", i, nr); i <- i + 1
draw.vf.cell2("#J405a", "#N0667", i, nr); i <- i + 1
draw.vf.cell2("#J405c", "#N1951", i, nr); i <- i + 1
draw.vf.cell2("#J405e", "#N1855", i, nr); i <- i + 1
draw.vf.cell2("#J4063", "#N5044", i, nr); i <- i + 1
draw.vf.cell2("#J4064", "#N3539", i, nr); i <- i + 1
draw.vf.cell2("#J4065", "#N3855", i, nr); i <- i + 1
draw.vf.cell2("#J4068", "#N0571", i, nr); i <- i + 1
draw.vf.cell2("#J4069", "#N0156", i, nr); i <- i + 1
draw.vf.cell2("#J406e", "#N1447", i, nr); i <- i + 1
draw.vf.cell2("#J4070", "#N1823", i, nr); i <- i + 1
draw.vf.cell2("#J407e", "#N3580", i, nr); i <- i + 1
draw.vf.cell2("#J4125", "#N3873", i, nr); i <- i + 1
draw.vf.cell2("#J4130", "#N0595", i, nr); i <- i + 1
draw.vf.cell2("#J4133", "#N2770", i, nr); i <- i + 1
draw.vf.cell2("#J4134", "#N0384", i, nr); i <- i + 1
draw.vf.cell2("#J4147", "#N3511", i, nr); i <- i + 1
draw.vf.cell2("#J4148", "#N3520", i, nr); i <- i + 1
draw.vf.cell2("#J4150", "#N0859", i, nr); i <- i + 1
draw.vf.cell2("#J4158", "#N1402", i, nr); i <- i + 1
draw.vf.cell2("#J415b", "#N1728", i, nr); i <- i + 1
draw.vf.cell2("#J4161", "#N2100", i, nr); i <- i + 1
draw.vf.cell2("#J416a", "#N2241", i, nr); i <- i + 1
draw.vf.cell2("#J416d", "#N3567", i, nr); i <- i + 1
draw.vf.cell2("#J4170", "#N3939", i, nr); i <- i + 1
draw.vf.cell2("#J4175", "#N4234", i, nr); i <- i + 1
draw.vf.cell2("#J4176", "#N4539", i, nr); i <- i + 1
draw.vf.cell2("#J417c", "#N0540", i, nr); i <- i + 1
draw.vf.cell2("#J417d", "#N1137", i, nr); i <- i + 1
draw.vf.cell2("#J4224", "#N4701", i, nr); i <- i + 1
draw.vf.cell2("#J4226", "#N0509", i, nr); i <- i + 1
draw.vf.cell2("#J422b", "#N0196", i, nr); i <- i + 1
draw.vf.cell2("#J422c", "#N2632", i, nr); i <- i + 1
draw.vf.cell2("#J422d", "#N4546", i, nr); i <- i + 1
draw.vf.cell2("#J422e", "#N4700", i, nr); i <- i + 1
draw.vf.cell2("#J4233", "#N3544", i, nr); i <- i + 1
draw.vf.cell2("#J4236", "#N0590", i, nr); i <- i + 1
draw.vf.cell2("#J4238", "#N1267", i, nr); i <- i + 1
draw.vf.cell2("#J423e", "#N0361", i, nr); i <- i + 1
draw.vf.cell2("#J423f", "#N1169", i, nr); i <- i + 1
draw.vf.cell2("#J4240", "#N1172", i, nr); i <- i + 1
draw.vf.cell2("#J424a", "#N2313", i, nr); i <- i + 1
draw.vf.cell2("#J424e", "#N0405", i, nr); i <- i + 1
draw.vf.cell2("#J4250", "#N2067", i, nr); i <- i + 1
draw.vf.cell2("#J4256", "#N1743", i, nr); i <- i + 1
draw.vf.cell2("#J4265", "#N0364", i, nr); i <- i + 1

make.table(nr, nc)
i <- 0
draw.title("Kanji (6)", nc)
draw.vf.cell2("#J4267", "#N1171", i, nr); i <- i + 1
draw.vf.cell2("#J4268", "#N3385", i, nr); i <- i + 1
draw.vf.cell2("#J426a", "#N2164", i, nr); i <- i + 1
draw.vf.cell2("#J426c", "#N2655", i, nr); i <- i + 1
draw.vf.cell2("#J4274", "#N2503", i, nr); i <- i + 1
draw.vf.cell2("#J4323", "#N4721", i, nr); i <- i + 1
draw.vf.cell2("#J432b", "#N4458", i, nr); i <- i + 1
draw.vf.cell2("#J432f", "#N4384", i, nr); i <- i + 1
draw.vf.cell2("#J4331", "#N0139", i, nr); i <- i + 1
draw.vf.cell2("#J433a", "#N1418", i, nr); i <- i + 1
draw.vf.cell2("#J433b", "#N3172", i, nr); i <- i + 1
draw.vf.cell2("#J4346", "#N1575", i, nr); i <- i + 1
draw.vf.cell2("#J434b", "#N2996", i, nr); i <- i + 1
draw.vf.cell2("#J434d", "#N0488", i, nr); i <- i + 1
draw.vf.cell2("#J434e", "#N3169", i, nr); i <- i + 1
draw.vf.cell2("#J434f", "#N1056", i, nr); i <- i + 1
draw.vf.cell2("#J4356", "#N3644", i, nr); i <- i + 1
draw.vf.cell2("#J4359", "#N4722", i, nr); i <- i + 1
draw.vf.cell2("#J435d", "#N3366", i, nr); i <- i + 1
draw.vf.cell2("#J4362", "#N3325", i, nr); i <- i + 1
draw.vf.cell2("#J4363", "#N3940", i, nr); i <- i + 1
draw.vf.cell2("#J4365", "#N3665", i, nr); i <- i + 1
draw.vf.cell2("#J4366", "#N0081", i, nr); i <- i + 1
draw.vf.cell2("#J4368", "#N1291", i, nr); i <- i + 1
draw.vf.cell2("#J436b", "#N0053", i, nr); i <- i + 1
draw.vf.cell2("#J436c", "#N2236", i, nr); i <- i + 1
draw.vf.cell2("#J436e", "#N4115", i, nr); i <- i + 1
draw.vf.cell2("#J442b", "#N3788", i, nr); i <- i + 1
draw.vf.cell2("#J442c", "#N2702", i, nr); i <- i + 1
draw.vf.cell2("#J4436", "#N4543", i, nr); i <- i + 1
draw.vf.cell2("#J4439", "#N4938", i, nr); i <- i + 1
draw.vf.cell2("#J443b", "#N5340", i, nr); i <- i + 1
draw.vf.cell2("#J443e", "#N0775", i, nr); i <- i + 1
draw.vf.cell2("#J444c", "#N4703", i, nr); i <- i + 1
draw.vf.cell2("#J4463", "#N0406", i, nr); i <- i + 1
draw.vf.cell2("#J446a", "#N1296", i, nr); i <- i + 1
draw.vf.cell2("#J446c", "#N1508", i, nr); i <- i + 1
draw.vf.cell2("#J446d", "#N1514", i, nr); i <- i + 1
draw.vf.cell2("#J4472", "#N1914", i, nr); i <- i + 1
draw.vf.cell2("#J4478", "#N3285", i, nr); i <- i + 1
draw.vf.cell2("#J4479", "#N3581", i, nr); i <- i + 1
draw.vf.cell2("#J4526", "#N1987", i, nr); i <- i + 1
draw.vf.cell2("#J452a", "#N3097", i, nr); i <- i + 1
draw.vf.cell2("#J452f", "#N0931", i, nr); i <- i + 1
draw.vf.cell2("#J4534", "#N4844", i, nr); i <- i + 1
draw.vf.cell2("#J4535", "#N0588", i, nr); i <- i + 1
draw.vf.cell2("#J4537", "#N0016", i, nr); i <- i + 1
draw.vf.cell2("#J453e", "#N4615", i, nr); i <- i + 1
draw.vf.cell2("#J4540", "#N0804", i, nr); i <- i + 1
draw.vf.cell2("#J4544", "#N2994", i, nr); i <- i + 1
draw.vf.cell2("#J4545", "#N5050", i, nr); i <- i + 1
draw.vf.cell2("#J454c", "#N1614", i, nr); i <- i + 1
draw.vf.cell2("#J4559", "#N1511", i, nr); i <- i + 1
draw.vf.cell2("#J455a", "#N1050", i, nr); i <- i + 1
draw.vf.cell2("#J455f", "#N1161", i, nr); i <- i + 1
draw.vf.cell2("#J4561", "#N0665", i, nr); i <- i + 1
draw.vf.cell2("#J4563", "#N1109", i, nr); i <- i + 1
draw.vf.cell2("#J4567", "#N0230", i, nr); i <- i + 1
draw.vf.cell2("#J456c", "#N0213", i, nr); i <- i + 1
draw.vf.cell2("#J4574", "#N2745", i, nr); i <- i + 1
draw.vf.cell2("#J4576", "#N1359", i, nr); i <- i + 1
draw.vf.cell2("#J4579", "#N3396", i, nr); i <- i + 1
draw.vf.cell2("#J4626", "#N4465", i, nr); i <- i + 1
draw.vf.cell2("#J4630", "#N0730", i, nr); i <- i + 1
draw.vf.cell2("#J4631", "#N0619", i, nr); i <- i + 1
draw.vf.cell2("#J4633", "#N1354", i, nr); i <- i + 1
draw.vf.cell2("#J463b", "#N4724", i, nr); i <- i + 1
draw.vf.cell2("#J463c", "#N4853", i, nr); i <- i + 1
draw.vf.cell2("#J4643", "#N2860", i, nr); i <- i + 1
draw.vf.cell2("#J4649", "#N4375", i, nr); i <- i + 1
draw.vf.cell2("#J465e", "#N2160", i, nr); i <- i + 1
draw.vf.cell2("#J4662", "#N0082", i, nr); i <- i + 1
draw.vf.cell2("#J466e", "#N0778", i, nr); i <- i + 1
draw.vf.cell2("#J4671", "#N5038", i, nr); i <- i + 1
draw.vf.cell2("#J4673", "#N0273", i, nr); i <- i + 1
draw.vf.cell2("#J4679", "#N3724", i, nr); i <- i + 1

make.table(nr, nc)
i <- 0
draw.title("Kanji (7)", nc)
draw.vf.cell2("#J467c", "#N2097", i, nr); i <- i + 1
draw.vf.cell2("#J467e", "#N0574", i, nr); i <- i + 1
draw.vf.cell2("#J4721", "#N1189", i, nr); i <- i + 1
draw.vf.cell2("#J472e", "#N2797", i, nr); i <- i + 1
draw.vf.cell2("#J472f", "#N0188", i, nr); i <- i + 1
draw.vf.cell2("#J4733", "#N2808", i, nr); i <- i + 1
draw.vf.cell2("#J4734", "#N3472", i, nr); i <- i + 1
draw.vf.cell2("#J4748", "#N2529", i, nr); i <- i + 1
draw.vf.cell2("#J474f", "#N5191", i, nr); i <- i + 1
draw.vf.cell2("#J4769", "#N3275", i, nr); i <- i + 1
draw.vf.cell2("#J4772", "#N3095", i, nr); i <- i + 1
draw.vf.cell2("#J477e", "#N5385", i, nr); i <- i + 1
draw.vf.cell2("#J4821", "#N0049", i, nr); i <- i + 1
draw.vf.cell2("#J482c", "#N0577", i, nr); i <- i + 1
draw.vf.cell2("#J482f", "#N3092", i, nr); i <- i + 1
draw.vf.cell2("#J483e", "#N0132", i, nr); i <- i + 1
draw.vf.cell2("#J483f", "#N0817", i, nr); i <- i + 1
draw.vf.cell2("#J4841", "#N1469", i, nr); i <- i + 1
draw.vf.cell2("#J484c", "#N3865", i, nr); i <- i + 1
draw.vf.cell2("#J4856", "#N4811", i, nr); i <- i + 1
draw.vf.cell2("#J4860", "#N1604", i, nr); i <- i + 1
draw.vf.cell2("#J4866", "#N2470", i, nr); i <- i + 1
draw.vf.cell2("#J4869", "#N3109", i, nr); i <- i + 1
draw.vf.cell2("#J4873", "#N5080", i, nr); i <- i + 1
draw.vf.cell2("#J4874", "#N5152", i, nr); i <- i + 1
draw.vf.cell2("#J4878", "#N1383", i, nr); i <- i + 1
draw.vf.cell2("#J4879", "#N1631", i, nr); i <- i + 1
draw.vf.cell2("#J487e", "#N3658", i, nr); i <- i + 1
draw.vf.cell2("#J4921", "#N5421", i, nr); i <- i + 1
draw.vf.cell2("#J492e", "#N3397", i, nr); i <- i + 1
draw.vf.cell2("#J4934", "#N0033", i, nr); i <- i + 1
draw.vf.cell2("#J4938", "#N2359", i, nr); i <- i + 1
draw.vf.cell2("#J4939", "#N0131", i, nr); i <- i + 1
draw.vf.cell2("#J493d", "#N0108", i, nr); i <- i + 1
draw.vf.cell2("#J4942", "#N3042", i, nr); i <- i + 1
draw.vf.cell2("#J4943", "#N3271", i, nr); i <- i + 1
draw.vf.cell2("#J494a", "#N0923", i, nr); i <- i + 1
draw.vf.cell2("#J4954", "#N0017", i, nr); i <- i + 1
draw.vf.cell2("#J495b", "#N1468", i, nr); i <- i + 1
draw.vf.cell2("#J4963", "#N2832", i, nr); i <- i + 1
draw.vf.cell2("#J4969", "#N4488", i, nr); i <- i + 1
draw.vf.cell2("#J4977", "#N5148", i, nr); i <- i + 1
draw.vf.cell2("#J497d", "#N1484", i, nr); i <- i + 1
draw.vf.cell2("#J4a23", "#N4255", i, nr); i <- i + 1
draw.vf.cell2("#J4a26", "#N0173", i, nr); i <- i + 1
draw.vf.cell2("#J4a2a", "#N2857", i, nr); i <- i + 1
draw.vf.cell2("#J4a2c", "#N0578", i, nr); i <- i + 1
draw.vf.cell2("#J4a38", "#N2064", i, nr); i <- i + 1
draw.vf.cell2("#J4a39", "#N4959", i, nr); i <- i + 1
draw.vf.cell2("#J4a3f", "#N0026", i, nr); i <- i + 1
draw.vf.cell2("#J4a42", "#N0589", i, nr); i <- i + 1
draw.vf.cell2("#J4a44", "#N4945", i, nr); i <- i + 1
draw.vf.cell2("#J4a46", "#N3461", i, nr); i <- i + 1
draw.vf.cell2("#J4a50", "#N0511", i, nr); i <- i + 1
draw.vf.cell2("#J4a51", "#N0306", i, nr); i <- i + 1
draw.vf.cell2("#J4a52", "#N2842", i, nr); i <- i + 1
draw.vf.cell2("#J4a55", "#N4661", i, nr); i <- i + 1
draw.vf.cell2("#J4a6c", "#N2466", i, nr); i <- i + 1
draw.vf.cell2("#J4a7c", "#N2084", i, nr); i <- i + 1
draw.vf.cell2("#J4a7d", "#N2082", i, nr); i <- i + 1
draw.vf.cell2("#J4b21", "#N2535", i, nr); i <- i + 1
draw.vf.cell2("#J4b26", "#N3749", i, nr); i <- i + 1
draw.vf.cell2("#J4b4c", "#N0751", i, nr); i <- i + 1
draw.vf.cell2("#J4b4f", "#N5404", i, nr); i <- i + 1
draw.vf.cell2("#J4b5c", "#N0096", i, nr); i <- i + 1
draw.vf.cell2("#J4b63", "#N5390", i, nr); i <- i + 1
draw.vf.cell2("#J4b68", "#N2467", i, nr); i <- i + 1
draw.vf.cell2("#J4b74", "#N0855", i, nr); i <- i + 1
draw.vf.cell2("#J4b7c", "#N0007", i, nr); i <- i + 1
draw.vf.cell2("#J4c23", "#N0913", i, nr); i <- i + 1
draw.vf.cell2("#J4c24", "#N0179", i, nr); i <- i + 1
draw.vf.cell2("#J4c29", "#N1316", i, nr); i <- i + 1
draw.vf.cell2("#J4c35", "#N2773", i, nr); i <- i + 1
draw.vf.cell2("#J4c37", "#N3164", i, nr); i <- i + 1
draw.vf.cell2("#J4c3e", "#N1170", i, nr); i <- i + 1
draw.vf.cell2("#J4c40", "#N2110", i, nr); i <- i + 1

make.table(nr, nc)
i <- 0
draw.title("Kanji (8)", nc)
draw.vf.cell2("#J4c4c", "#N5087", i, nr); i <- i + 1
draw.vf.cell2("#J4c53", "#N2473", i, nr); i <- i + 1
draw.vf.cell2("#J4c5a", "#N2170", i, nr); i <- i + 1
draw.vf.cell2("#J4c5c", "#N3127", i, nr); i <- i + 1
draw.vf.cell2("#J4c64", "#N4944", i, nr); i <- i + 1
draw.vf.cell2("#J4c67", "#N4940", i, nr); i <- i + 1
draw.vf.cell2("#J4c6b", "#N0298", i, nr); i <- i + 1
draw.vf.cell2("#J4c70", "#N3168", i, nr); i <- i + 1
draw.vf.cell2("#J4c72", "#N1598", i, nr); i <- i + 1
draw.vf.cell2("#J4c74", "#N4074", i, nr); i <- i + 1
draw.vf.cell2("#J4c78", "#N2233", i, nr); i <- i + 1
draw.vf.cell2("#J4c7d", "#N2534", i, nr); i <- i + 1
draw.vf.cell2("#J4d2d", "#N3727", i, nr); i <- i + 1
draw.vf.cell2("#J4d30", "#N2565", i, nr); i <- i + 1
draw.vf.cell2("#J4d3a", "#N5030", i, nr); i <- i + 1
draw.vf.cell2("#J4d3c", "#N1167", i, nr); i <- i + 1
draw.vf.cell2("#J4d3e", "#N0408", i, nr); i <- i + 1
draw.vf.cell2("#J4d4f", "#N2659", i, nr); i <- i + 1
draw.vf.cell2("#J4d51", "#N2993", i, nr); i <- i + 1
draw.vf.cell2("#J4d53", "#N3656", i, nr); i <- i + 1
draw.vf.cell2("#J4d55", "#N4001", i, nr); i <- i + 1
draw.vf.cell2("#J4d57", "#N4274", i, nr); i <- i + 1
draw.vf.cell2("#J4d5b", "#N5012", i, nr); i <- i + 1
draw.vf.cell2("#J4d63", "#N3680", i, nr); i <- i + 1
draw.vf.cell2("#J4d68", "#N0202", i, nr); i <- i + 1
draw.vf.cell2("#J4d6b", "#N5049", i, nr); i <- i + 1
draw.vf.cell2("#J4d70", "#N3856", i, nr); i <- i + 1
draw.vf.cell2("#J4d71", "#N0199", i, nr); i <- i + 1
draw.vf.cell2("#J4d72", "#N1431", i, nr); i <- i + 1
draw.vf.cell2("#J4d78", "#N3264", i, nr); i <- i + 1
draw.vf.cell2("#J4d7d", "#N2942", i, nr); i <- i + 1
draw.vf.cell2("#J4e24", "#N4813", i, nr); i <- i + 1
draw.vf.cell2("#J4e25", "#N5040", i, nr); i <- i + 1
draw.vf.cell2("#J4e26", "#N5005", i, nr); i <- i + 1
draw.vf.cell2("#J4e28", "#N0319", i, nr); i <- i + 1
draw.vf.cell2("#J4e29", "#N3343", i, nr); i <- i + 1
draw.vf.cell2("#J4e2e", "#N2576", i, nr); i <- i + 1
draw.vf.cell2("#J4e32", "#N3191", i, nr); i <- i + 1
draw.vf.cell2("#J4e33", "#N3471", i, nr); i <- i + 1
draw.vf.cell2("#J4e35", "#N5440", i, nr); i <- i + 1
draw.vf.cell2("#J4e3e", "#N0034", i, nr); i <- i + 1
draw.vf.cell2("#J4e41", "#N3468", i, nr); i <- i + 1
draw.vf.cell2("#J4e49", "#N3885", i, nr); i <- i + 1
draw.vf.cell2("#J4e4c", "#N2141", i, nr); i <- i + 1
draw.vf.cell2("#J4e4f", "#N0715", i, nr); i <- i + 1
draw.vf.cell2("#J4e53", "#N2210", i, nr); i <- i + 1
draw.vf.cell2("#J4e55", "#N2807", i, nr); i <- i + 1
draw.vf.cell2("#J4e58", "#N4630", i, nr); i <- i + 1
draw.vf.cell2("#J4e60", "#N5138", i, nr); i <- i + 1
draw.vf.cell2("#J4e63", "#N0428", i, nr); i <- i + 1
draw.vf.cell2("#J4e64", "#N0642", i, nr); i <- i + 1
draw.vf.cell2("#J4e6d", "#N5048", i, nr); i <- i + 1
draw.vf.cell2("#J4e6e", "#N5056", i, nr); i <- i + 1
draw.vf.cell2("#J4e73", "#N2438", i, nr); i <- i + 1
draw.vf.cell2("#J4f22", "#N4702", i, nr); i <- i + 1
draw.vf.cell2("#J4f27", "#N2750", i, nr); i <- i + 1
draw.vf.cell2("#J4f29", "#N4561", i, nr); i <- i + 1
draw.vf.cell2("#J4f37", "#N3683", i, nr); i <- i + 1
draw.vf.cell2("#J4f3b", "#N0283", i, nr); i <- i + 1
draw.vf.cell2("#J4f40", "#N4391", i, nr); i <- i + 1
draw.vf.cell2("#J4f42", "#N3268", i, nr); i <- i + 1
draw.vf.cell2("#J4f43", "#N4358", i, nr); i <- i + 1
draw.vf.cell2("#J4f44", "#N0054", i, nr); i <- i + 1
draw.vf.cell2("#J4f47", "#N1710", i, nr); i <- i + 1

draw.vf.cell2("#J534c", "#N0973", i, nr); i <- i + 1
draw.vf.cell2("#J5879", "#N1794", i, nr); i <- i + 1
draw.vf.cell2("#J5960", "#N1942", i, nr); i <- i + 1
draw.vf.cell2("#J626f", "#N3200", i, nr); i <- i + 1
draw.vf.cell2("#J6446", "#N3458", i, nr); i <- i + 1
draw.vf.cell2("#J6647", "#N5083", i, nr); i <- i + 1
draw.vf.cell2("#J6d55", "#N4633", i, nr); i <- i + 1

par(oldpar)
