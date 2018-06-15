# sourcetools 0.1.5

- Ensure that symbols included from e.g. `<cstdio>`, `<cstring>`
  are resolved using a `std::` prefix.
# sourcetools 0.1.4

- More work to ensure `sourcetools` can build on Solaris.

# sourcetools 0.1.3

- Relax C++11 requirement, to ensure that `sourcetools` can
  build on machines with older compilers (e.g. gcc 4.4).
  
# sourcetools 0.1.2

- Disable failing tests on Solaris.

# sourcetools 0.1.1

- Rename token type `ERR` to `INVALID` to fix build errors
  on Solaris.

# sourcetools 0.1.0

## Features

The first release of `sourcetools` comes with a small set
of features exposed to R:

- `read(file)`: Read a file (as a string). Similar to
  `readChar()`, but faster (and maybe be optimized to
  use a memory mapped file reader in the future).

- `tokenize_file(file)`: Tokenize an R script.

- `tokenize_string(string)`: Tokenize a string of R code.
