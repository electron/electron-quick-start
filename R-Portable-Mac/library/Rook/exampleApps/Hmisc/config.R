library(Hmisc)
dir.create(file.path(tempdir(),'plots'),showWarnings=FALSE)
app <- Builder$new(
    Static$new(
	urls = c('/css','/images','/javascript'),
	root = '.'
    ),
    Static$new(urls='/plots',root=tempdir()),
    Brewery$new(
	url='/brew',
	root='.',
	imagepath=file.path(tempdir(),'plots'),
	imageurl='../plots/'
    ),
    Redirect$new('/brew/useR2007.rhtml')
)
