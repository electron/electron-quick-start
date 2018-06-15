# plogr 0.2.0 (2018-03-24)

- The `PLOGR_ENABLE` macro needs to be enabled at compilation time for the library to have any effect (#3)
- In GCC builds, the function is now shown with its return type; stripping the return type failed for functions in template clases with more than one template argument.


# plogr 0.1-1 (2016-09-24)

- Using a stripped version of plog 1.0-1.
- Works on Linux, OS X, and Windows.
- Log items are printed using `REprintf()`.
- New `plog::init_r()` to initialize logging via  `REprintf()`, allows changing the log level and passing the log level as string.
