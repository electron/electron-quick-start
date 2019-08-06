# tidyverse 1.2.1

* Require modern versions of all packages (#85)

* Work with RStudio 1.0 and earlier (#88).

# tidyverse 1.2.0

## Changes to tidyverse membership

* stringr and forcats have been added to the core tidyverse, so they are
  attached by `library(tidyverse)`.

* reprex joins the tidyverse to make it easier to create reproducible
  examples (#47)

## Other improvements

* On attach, tidyverse now makes better use of the horizontal space, 
  printing packages and versions in two columns (#59). It only prints
  packages that it attaches, not packages that you've already attached.
  Development versions are highlighted in red.
  
    You can now suppress this startup message by setting 
    `options(tidyverse.quiet = TRUE)`

* `tidyverse_conflicts()` now prints all conflicts that involve at least
  one tidyverse package; Previously it only omitted any intra-tidyverse
  conflicts (#26). I've also tweaked the display of conflicts to hopefully 
  make it more clear which function is the "winner".

* `tidyverse_update()` now just gives you the code you need to update the 
  packges, since in general it's not possible to update packages that are
  already loaded.

* feather is now _actually_ in suggests.

# tidyverse 1.1.1

* Moved feather from Imports to Suggests - feather is part of the tidyverse
  but it's installation requirements (C++11 + little-endian) make it painful
  in many scenarios (#36).

# tidyverse 1.1.0

* Added a `NEWS.md` file to track changes to the package.

* Membership changes:
  
  * Removed DBI (since very different API, #16)
  * Added feather (#15)

* `tidyverse_deps()` and `tidyverse_packages()` are now exported so you can
  more easily see the make up of the tidyverse, and what package versions
  you have (#18, #23)

* `suppressPackageStartupMessages()` now suppresses all messages during
   loading (#19). `suppressPackageStartupMessages()` is called automatically
   for all tidyverse packages (#27).
