#ifndef DPLYR_WORKAROUND_H
#define DPLYR_WORKAROUND_H

// installChar was introduced in R 3.2.0
#ifndef installChar
#define installChar(x) Rf_install(CHAR(x))
#define Rf_installChar installChar
#endif

#endif
