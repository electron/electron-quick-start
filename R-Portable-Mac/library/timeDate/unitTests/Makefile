PKG=timeDate
TOP=../..
SUITE=doRUnit.R
R=R

all: inst test

inst: # Install package -- but where ?? -- will that be in R_LIBS ?
	cd ${TOP}/..;\
	${R} CMD INSTALL ${PKG}

test: # Run unit tests
	export RCMDCHECK=FALSE;\
	cd ${TOP}/tests;\
	${R} --vanilla --slave < ${SUITE}
