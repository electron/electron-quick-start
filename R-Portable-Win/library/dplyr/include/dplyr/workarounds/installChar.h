#ifndef DPLYR_WORKAROUNDS_INSTALLCHAR_H
#define DPLYR_WORKAROUNDS_INSTALLCHAR_H

// installChar was introduced in R 3.2.0
#ifndef installChar
#define installChar(x) Rf_install(CHAR(x))
#define Rf_installChar installChar
#endif

#endif
