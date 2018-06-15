#ifndef SOURCETOOLS_TESTS_TESTTHAT_H
#define SOURCETOOLS_TESTS_TESTTHAT_H

// disable testthat with older gcc
#if defined(__GNUC__) && defined(__GNUC_MINOR__) && !defined(__clang__)
# if __GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 6)
#  define TESTTHAT_DISABLED
# endif
#endif

// include testthat.h
#include <testthat.h>

#endif /* SOURCETOOLS_TESTS_TESTTHAT_H */
