# RSQLite 2.1.1 (2018-05-05)

- Breaking change: The `field.types` argument to `dbWriteTable()` no longer takes precedence when defining the order of the columns in the new table.
- Add support for `bigint` argument to `dbConnect()`, supported values are `"integer64"`, `"integer"`, `"numeric"` and `"character"`. Large integers are returned as values of that type (r-dbi/DBItest#133).
- Data frames resulting from a query always have unique non-empty column names (r-dbi/DBItest#137).
- New arguments `temporary` and `fail_if_missing` (default: `TRUE`) to `dbRemoveTable()` (r-dbi/DBI#141, r-dbi/DBI#197).
- Using `dbCreateTable()` and `dbAppendTable()` internally (r-dbi/DBI#74).
- Implement `format()` method for `SqliteConnection` (r-dbi/DBI#163).
- Reexporting `Id()`, `DBI::dbIsReadOnly()` and `DBI::dbCanConnect()`.
- Now imports DBI 1.0.0.


# RSQLite 2.1.0 (2018-03-29)

## Bug fixes

- Fix rchk warnings on CRAN (#250).
- `dbRowsAffected()` and `dbExecute()` return zero after a `DROP TABLE` statement, and not the number of rows affected by the last `INSERT`, `UPDATE`, or `DELETE` (#238).
- `dbIsValid()` returns `FALSE` instead of throwing an error for an invalid connection object (#217).
- Names in the `x` argument to `dbQuoteIdentifier()` are preserved in the output (r-lib/DBI#173).
- Ignore invalid UTF-8 strings in `dbQuoteIdentifier()` (r-dbi/DBItest#156).

## Features

- Update bundled sqlite3 library to 3.22 (#252).
- Values of class `"integer64"` are now supported for `dbWriteTable()` and `dbBind()` (#243).
- New connections now automatically load default RSQLite extensions (#236).
- Implement `dbUnquoteIdentifier()`.

## Internal

- Now raising error if `dbBind()` is called with too many named arguments, according to spec.
- Refactor connection and result handling to be more similar to other backends.


# RSQLite 2.0 (2017-06-18)

API changes
-----------

- Updated embedded SQLite to 3.19.3.
- 64-bit integers are returned as `integer64` vectors. The `bit64` package is imported to support this data type (#65).
- The `row.names` argument to `dbFetch()`, `dbReadTable()`, `dbWriteTable()`, `sqliteBuildTableDefinition()`, and `sqlData()` now defaults to `FALSE`. (This also affects `dbGetQuery()`.) The old default can be restored temporarily on a per-package basis by calling `pkgconfig::set_config("RSQLite::row.names.query" = NA)`. `NULL` is a valid value for the `row.names` argument, same as `FALSE` (#210).
- The `name` argument to `dbBegin()`, `dbCommit()`, and `dbRollback()` is now declared after the ellipsis. Code that calls these methods with an unnamed second argument still works but receives a warning (#208).
- The `select.cols` argument to `dbReadTable()` is deprecated, use `dbGetQuery()` with a `SELECT` query instead (#185).
- The methods related to tables (`dbReadTable()`, `dbWriteTable()`, `dbExistsTable()`, and `dbRemoveTable()`) always treat the `name` argument as literal name, even if it contains backticks. This breaks the CRAN version (but not the GitHub version) of the sqldf package (#188).
- `dbWriteTable(append = TRUE)` raises an error if column names are not the same in the data and the existing table (#165).
- `dbFetch()` now errs for `n < -1`, and accepts `n == Inf`.
- Removed dummy `dbGetQuery()` method introduced for compatibility with some Bioconductor packages (#187).
- `sqlData()` now returns quoted strings, like the default implementation in DBI (#207).
- `dbWriteTable()` returns invisibly.
- Now returning objects of type `blob` for blobs (#189).
- `dbGetRowsAffected()` now returns `NA` for a statement with placeholders, if `dbBind()` has not been called.
- If a column contains incompatible values (e.g., numbers and strings), a warning is raised in `dbFetch()` (#161).
- Failing to set `PRAGMA cache_size` or `PRAGMA synchronous` in `dbConnect()` now gives a clear warning (#197).
- Improve warning message if named parameters are not used in `dbGetPreparedQuery()` or `dbSendPreparedQuery()` (#193).
- SQLite collects additional histogram data during `ANALYZE`, which may lead to faster executions of queries (#124).

Bug fixes
---------

- Identifiers are now escaped with backticks, to avoid ambiguous handling of double quotes in the context of strings (#123).
- Fix `dbBind()` behavior and tests. Attempting to bind to a query without parameters throws an error (#114).
- Fix corner case when repeatedly fetching from columns that don't have an affinity.
- The `variance()` and `stdev()` extension functions now return `NULL` for input of length 1 (#201).
- Fix roundtrip of `raw` columns (#116).

Documentation
-------------

- Remove redundant documentation, link to `DBI` more prominently (#186).

Internal
--------

- Most DBItest tests now pass. Reduced number of skips shown for tests.
- C++ code now compiles with strict compiler settings `-Wall -Wextra -pedantic -Wconversion`.
- Restore compatibility with older compilers/libraries by using <boost/limits.hpp> (#206).
- Use `boost/cstdint` instead of compound data type for 64-bit values (#198).
- Remove `Makevars.local` logic, resolve installation issues with non-GNU Make (#203).
- All methods of DBI are reexported.
- Registering native functions, as required by R >= 3.4.0.
- Use UTF-8 encoded file names as required by the SQLite API, to support non-ASCII file names (#211).
- Calling `dbFetch(n = 0)` instead of `dbFetch(n = 1)` in `dbListFields()`.
- Exclude SQLite3 source code from coverage computation again (#204).


# RSQLite 1.1-2 (2017-01-07)

- Check reverse dependencies.
- Check and warn if the `name` argument is quoted in `dbReadTable()` and `dbRemoveTable()`, for compatibility with `sqldf` (#196).


# RSQLite 1.1-1 (2016-12-10)

- Fix protection issue that could lead to memory access errors when fetching `BLOB` data (#192, #194, @MikeBadescu).


# RSQLite 1.1 (2016-11-25)

- New maintainer: Kirill Müller.

## Bundled SQLite

- RSQLite always builds with the included source, which is located in `src/sqlite3`. This prevents bugs due to API mismatches and considerably simplifies the build process.

- Current version: 3.11.1.

- Enable JSON1 extension (#152, @tigertoes).

- Include support for FTS5 (@mkuhn).

- Compilation limits `SQLITE_MAX_VARIABLE_NUMBER` and `SQLITE_MAX_COLUMN` have been reset to the defaults. The documentation suggests setting to such high values is a bad idea.

- Header files for `sqlite3` are no longer installed, linking to the package is not possible anymore. Packages that require access to the low-level sqlite3 API should bundle their own copy.

## Breaking changes

- `RSQLite()` no longer automatically attaches DBI when loaded. This is to
  encourage you to use `library(DBI); dbConnect(RSQLite::SQLite())`.

- Functions that take a table name, such as `dbWriteTable()` and `dbReadTable()`,
  now quote the table name via `dbQuoteIdentifier()`.
  This means that caller-quoted names should be marked as such with `DBI::SQL()`.

## New features

- RSQLite has been rewritten (essentially from scratch) in C++ with
  Rcpp. This has considerably reduced the amount of code, and allows us to
  take advantage of the more sophisticated memory management tools available in
  Rcpp. This rewrite should yield some minor performance improvements, but
  most importantly protect against memory leaks and crashes. It also provides
  a better base for future development. In particular, it is now technically
  possible to have multiple result sets per connection, although this feature
  is currently disabled (#150).

- You can now use SQLite's URL specification for databases. This allows you to
  create [shared in-memory](https://www.sqlite.org/inmemorydb.html) databases
  (#70).

- Queries (#69), query parameters and table data are always converted to UTF-8 before being sent to the database.

- Adapted to `DBI` 0.5, new code should use `dbExecute()` instead of `dbGetQuery()`, and `dbSendStatement()` instead of `dbSendQuery()` where appropriate.

- New strategy for prepared queries. Create a prepared query with `dbSendQuery()` or `dbSendStatement()` and bind values with `dbBind()`. The same query/statement can be executed efficiently multiple times by passing a data-frame-like object (#168, #178, #181).

- `dbSendQuery()`, `dbGetQuery()`, `dbSendStatement()` and `dbExecute()`
  also support inline parameterised queries,
  like `dbGetQuery(datasetsDb(), "SELECT * FROM mtcars WHERE cyl = :cyl",
  params = list(cyl = 4))`. This has no performance benefits but protects you
  from SQL injection attacks.

- Improve column type inference: the first non-`NULL` value decides the type of a column (#111). If there are no non-`NULL` values, the column affinity is used, determined according to sqlite3 rules (#160).

- `dbFetch()` uses the same row name strategy as `dbReadTable()` (#53).

- `dbColumnInfo()` will now return information even before you've retrieved any data.

- New `sqliteVersion()` prints the header and library versions of RSQLite.

- Deprecation warnings are given only once, with a clear reference to the source.

- `datasetsDb()` now returns a read-only database, to avoid modifications to the installed file.

## Deprecated functions

- `make.db.names()` has been formally deprecated. Please use `dbQuoteIdentifier()` instead. This function is also used in `dbReadTable()`, `dbRemoveTable()`, and `dbListFields()` (#106, #132).

- `sqliteBuildTableDefinition()` has been deprecated. Use `DBI::sqlCreateTable()` instead.

- `dbGetException()` now raises a deprecation warning and always returns `list(errorNum = 0L, errorMsg = "OK")`, because querying the last SQLite error only works if an error actually occurred (#129).

- `dbSendPreparedQuery()` and `dbGetPreparedQuery()` have been reimplemented (with deprecation warning) using `dbSendQuery()`, `dbBind()` and `dbFetch()` for compatibility with existing packages (#100, #153, #168, #181). Please convert to the new API, because the old function may be removed completely very soon: They were never part of the official API, and do less argument checking than the new APIs. Both `dbSendPreparedQuery()` and `dbGetPreparedQuery()` ignore parameters not found in the query, with a warning (#174).

- Reimplemented `dbListResults()` (with deprecation warning) for compatibility with existing packages (#154).

- Soft-deprecated `dbGetInfo()`: The "Result" method is implemented by DBI, the methods for the other classes raise a warning (#137). It's now better to access the metadata with individual functions `dbHasCompleted()`, `dbGetRowCount()` and `dbGetRowsAffected()`.

- All `summary()` methods have been removed: the same information is now displayed in the `show()` methods, which were previously pretty useless.

## Compatibility fixes

- The `raw` data type is supported in `dbWriteTable()`, creates a `TEXT` column with a warning (#173).

- Numeric values for the `row.names` argument are converted to logical, with a warning (#170).

- If the number of data frame columns matches the number of existing columns for `dbWriteTable(append = TRUE)`, columns will be matched by position for compatibility, with a warning in case of a name mismatch (#164).

- `dbWriteTable()` supports the `field.types` argument when creating a new table (#171), and the `temporary` argument, default `FALSE` (#113).

- Reexporting `dbGetQuery()` and `dbDriver()` (#147, #148, #183).

- `sqliteCopyDatabase()` accepts character as `to` argument again, in this case a temporary connection is opened.

- Reimplemented `dbWriteTable("SQLiteConnection", "character", "character")` for import of CSV files, using a function from the old codebase (#151).

- `dbWriteTable("SQLiteConnection", "character", "data.frame")` looks
  for table names already enclosed in backticks and uses these,
  (with a warning), for compatibility with the sqldf package.

## Performance

- The `dbExistsTable()` function now works faster by filtering the list of tables using SQL (#166).

## Documentation

- Start on a basic vignette: `vignette("RSQLite")` (#50).

- Reworked function and method documentation, removed old documentation (#121).

- Using `dbExecute()` in documentation and examples.

- Using both `":memory:"` and `":file::memory:"` in documentation.

- Added additional documentation and unit tests for
  [autoincrement keys](https://www.sqlite.org/autoinc.html) (#119, @wibeasley).

## Internal

- Avoid warning about missing `long long` data type in C++98 by using a compound data type built from two 32-bit integers, with static assert that the size is 8 indeed.

- Remove all compilation warnings.

- All DBI methods contain an ellipsis `...` in their signature. Only the `name` argument to the transaction methods appears before the ellipsis for compatibility reasons.

- Using the `DBItest` package for testing (#105), with the new `constructor_relax_args` tweak.

- Using the `plogr` for logging at the C++ level, can be enabled via `RSQLite:::init_logging()`.

- Using new `sqlRownamesToColumn()` and `sqlColumnToRownames()` (rstats-db/DBI#91).

- Using `astyle` for code formatting (#159), also in tests (but only if sources can be located), stripped space at end of line in all source files.

- Tracking dependencies between source and header files (#138).

- Moved all functions from headers to modules (#162).

- Fixed all warnings in tests (#157).

- Checking message wording for deprecation warnings (#157).

- Testing simple and named transactions (#163).

- Using container-based builds and development version of `testthat` on Travis.

- Enabled AppVeyor testing.

- Differential reverse dependency checks.

- Added upgrade script for sqlite3 sources and creation script for the datasets database to the `data-raw` directory.


# Version 1.0.0

## New features

- Updated to SQLite 3.8.6

- Added `datasetsDb()`, a bundled SQLite database containing all data frames 
  in the datasets package (#15).

- Inlined `RSQLite.extfuns` - use `initExtension()` to load the many
  useful extension functions (#44).

- Methods no longer automatically clone the connection if there is an open
  result set. This was implement inconsistently in a handful of places (#22).
  RSQLite is now more forgiving if you forget to close a result set - it will
  close it for you, with a warning. It's still good practice to clean up
  after yourself, but you don't have to.

- `dbBegin()`, `dbCommit()`, `dbRollback()` throw errors on failure, rather than 
  return `FALSE`.  They all gain a `name` argument to specify named savepoints.

- `dbFetch()` method added (`fetch()` will be deprecated in the future)

- `dbRemoveTable()` throws errors on failure, rather than returning `FALSE`.

- `dbWriteTable()` has been rewritten:

    * It quotes field names using `dbQuoteIdentifier()`, rather
      than use a flawed black-list based approach with name munging.

    * It now throws errors on failure, rather than returning FALSE. 
    
    * It will automatically add row names only if they are character, not integer.
    
    * When loading a file from disk, `dbWriteTable()` will no longer
      attempt to guess the correct values for `row.names` and `header` - instead
      supply them explicitly if the defaults are incorrect. 
    
    * It uses named save points so it can be nested inside other 
      transactions (#41). 
    
    * When given a zero-row data frame it will just creates the table 
      definition (#35). 

## Changes to objects

- The `dbname`, `loadable.extensions`, `flags` and `vfs` properties of
  a SqliteConnection are now slots. Access them directly instead of using 
  `dbGetInfo()`.

## Deprecated and removed functions

- RSQLite is no longer nominally compatible with S (#39).

- `idIsValid()` is deprecated. Please use `dbIsValid()` instead.

- `dbBeginTransaction()` has been deprecated. Please use `dbBegin()` instead.

- `dbCallProc()` method removed, since generic is now deprecated.

- Renamed `dbBuildTableDefinition()` to `sqliteBuildTableDefinition()` 
  to avoid implying it's a DBI generic. Old function is aliased to new with
  a warning.

- `dbFetch()` no longer numbers row names sequentially between fetches.

- `safe.write()` is no longer exported as it shouldn't be part of the 
  public RSQLite interface (#26).

- Internal `sqlite*()` functions are no longer exported (#20).

- Removed `SqliteObject` and `dbObject` classes, modifying `SqliteDriver`, 
  `SqliteConnection`, and `SqliteResult` to use composition instead of multiple
  inheritance.

# Version 0.11.6

- Upgrade to SQLite 3.8.4.2

# Version 0.11.5

- Include temporary tables in dbListTables()

- Added Rstudio project file

- Added select.cols capability to sqliteReadTable()

# Version 0.11.4

- Upgrade to SQLite 3.7.7

- Fix bug in dbWriteTable preventing use of colClasses argument from
  being used to control input types.

# Version 0.11.3

- Upgrade to SQLite 3.7.16.2

# Version 0.11.2

- Upgrade to SQLite 3.7.14

# Version 0.11.1

- Prevent RSQLite from crashing R when operations are attempted on
  expired (closed) connections.

# Version 0.11.0

- Enhance type detection in sqliteDataType (dbDataType). The storage
  mode of a data.frame column is now used as part of the type
  detection. Prior to this patch, all vectors with class other than
  numeric or logical were mapped to a TEXT column. This patch uses the
  output of storage.mode to map to integer and double vectors to
  INTEGER and REAL columns, respectively.  All other modes are mapped
  to a TEXT column.

- Detection of BLOBs was narrowed slightly. The code now treats only
  objects with data.class(obj) == "list" as BLOBs. Previously, is.list
  was used which could return TRUE for lists of various classes.

- Fix bug in sqliteImportFile (used by dbWriteTable) that prevented a
  comment character from being specified for the input file.

- Increase compile-time SQLite limits for maximum number of columns in
  a table to 30000 and maximum number of parameters (?N) in a SELECT
  to 40000. Use of wide tables is not encouraged. The default values
  for SQLite are 2000 and 999, respectively. Databases containing
  tables with more than 2000 columns may not be compatible with
  versions of SQLite compiled with default settings.

- Upgrade to SQLite 3.7.9.

# Version 0.10.0

- Upgrade to SQLite 3.7.8.

# Version 0.9-5

- Fix error handling for prepared queries when bind data is missing a
  named parameter.

# Version 0.9-4

- Fix incorrect handling of NA's for character data in the code that
  binds parameters to a SQL query.  The string "NA" was incorrectly
  interpretted as a missing value.

# Version 0.9-3

- Upgrade SQLite to 3.7.3.  See http://www.sqlite.org/changes.html
  for release notes for SQLite.

- Enable the sounder(X) function via the SQLITE_SOUNDEX compile time
  flag.  See http://www.sqlite.org/lang_corefunc.html#soundex for
  details.

# Version 0.9-2

- Fix two missing PROTECTs in RS_SQLite_managerInfo and
  RS_SQLite_getException, thanks to a patch from Andrew Runnalls

# Version 0.9-1

- SQLite header files needed to compile SQLite extension functions are
  now made available by RSQLite.  Packages can bundle SQLite extension
  functions and use LinkingTo: RSQLite in the DESCRIPTION file.

- SQLite loadable extensions are now enabled by default for new
  connections.  If you wish to disallow loadable extensions for a
  given connection, loadable.extensions=FALSE to dbConnect.

# Version 0.9-0

- The SQLite driver handle validation code, is_ValidHandle, no longer
  requires the driver ID to be equal to the current process ID.
  SQLite supports multiple processes accessing the same SQLite file
  via locking (however, results are known to be unreliable on NFS).
  This change should make using RSQLite with the multicore package
  easier.  For an example of the issue that the PID check causes see:
  https://stat.ethz.ch/pipermail/r-sig-hpc/2009-August/000335.html

- Refactor to use external pointers to wrap handle IDs; remove handle
  ID coerce code (e.g. as(obj@Id, "integer")).  For now, the old
  scheme of storing handle IDs in an integer vector is mostly
  maintained only these integer vectors are stored in the protection
  slot of an external pointer.  Using external pointers will allow the
  use of finalizer code so that, for example, unreferenced result sets
  can be cleaned up.

- Upgrade to SQLite 3.6.23.1.

- The memory mangement code for keeping track of database connections
  was significantly refactored.  Instead of tracking connections in a
  pre-allocated array attached to the driver manager, connections are
  now managed dynamically using R's external pointers and finalizers.
  Consequences of this change are as follows:

    * There is no longer a maximum connection limit (values specified
      using the max.con argument to SQLite() are now ignored).

    * The dbGetInfo(mgr) method no longer lists open connections and
      dbListConnections will now always return an empty list.  This
      functionality was only needed because one needed a reference to
      a connection in order to finalize the resource via
      dbDisconnect().  While calling dbDisconnect() is still the
      recommended approach, database connections that are no longer
      referenced by any R variables will be finalized by R's garbage
      collector.

    * The behavior of SQLiteConnection objects now follows typical R
      semantics.  If no R variables reference a given connection, it
      will be finalized by R's garbage collector.

- Add support for SQLite BLOBs.  You can now insert and retrieve BLOBs
  using raw vectors.  For parameterized queries using
  dbSendPreparedQuery, the BLOB column must be a list.  When a query
  returns a result set with a BLOB column, that column will be a list
  of raw vectors.  Lists as columns in data.frames work for simple
  access, but may break some code that expects columns to be atomic
  vectors.  A database NULL value is mapped to an R NULL value for
  BLOBs.  This differs from the mapping of database NULL to NA used
  for other datatypes (there is no notion of NA for a raw vector).

- The behavior of dbDataType, sqliteDataType, and as a consequence,
  dbWriteTable has been changed to support BLOBs represented as a
  column of type list in a data.frame.  Such columns were previously
  mapped to a TEXT column in SQLite and are not mapped to BLOB.

- RSQLite now depends on R >= 2.10.0.

# Version 0.8-4

- Fix a memory leak in bound parameter management and resolve a
  missing PROTECT bug that caused spurious crashes when performing
  many prepared queries.

- Improve internal memory handling for prepared queries.  Use
  R_PreserveObject/R_ReleaseObject instead of the protection stack to
  manage parameter binding.  Logical vectors are now properly coerced
  to integer vectors and Rf_asCharacterFactor is used to convert
  factors in bind data.

- RSQLite now requires DBI >= 0.2-5

- There is now a fairly comprehensive example of using prepared
  queries in the man page for dbSendQuery-methods.

- Upgrade to SQLite 3.6.21 => 3.6.22 (minor bug fixes).

- Use sqlite3_prepare_v2 throughout, remove workaround code needed for
  legacy sqlite3_prepare behavior.

- Add name space unload hook to unload RSQLite.so.

- Enable full-text search module by default.  See
  http://www.sqlite.org/fts3.html for details on this SQLite
  module.

- Add support for prepared queries that involve a SELECT.  This was
  previously unsupported.  SELECT queries can now be used with
  dbSendPreparedQuery.  The return value is the same as rbind'ing the
  results of the individual queries.  This means that parameters that
  return no results are ignored in the result.

# Version 0.8-3

- Enable RTree module for the Windows build.  The configure script is
  not run on Windows, options are set directly in src/Makevars.win.

# Version 0.8-2

- Changes to support WIN64

# Version 0.8-1

- sqliteFetch now returns a data.frame with the expected number of
  columns when a query returns zero rows.  Before, a 0 x 0 data.frame
  was returned regardless of the number of columns in the original
  query.  The change will be seen in calls to fetch and dbGetQuery for
  queries that return no result rows.

- sqliteCopyDatabase has been refactored to support copying to either
  a file or an open and empty database connection.  This makes it
  possible to transfer a disk based database to an in-memory based
  database.  The changes to sqliteCopyDatabase are NOT BACKWARDS
  COMPATIBLE: the return value is now NULL (an error is raised if the
  copying fails) and the argument names have been changed to 'from'
  and 'to'.  As this was a newly added feature that uses an
  experimental SQLite API, I decided to disregards compatibility.

- Calling dbSendPreparedQuery with a non-NULL bind.data that has zero
  rows or zero columns is now an error.

# Version 0.8-0

- Upgrade to SQLite 3.6.21

- Apply some code and Rd cleanups contributed by Mattias Burger.
  Avoid partial argument name matching, use TRUE/FALSE not T/F and
  improve Rd markup.

- Integrate RUnit unit tests so that they run during R CMD check.
  Small improvements to make the tests run more quietly.  You can run
  the unit tests by calling RSQLite:::.test_RSQLite() (require latest
  version of the RUnit package).  Also had to disable some unit tests
  on Windows.  Investigation of details is on the TODO list.

- Add sqliteCopyDatabase, a function that uses SQLite's online backup
  API to allow a specified database to be copied to a file.  This can
  be used to create a file copy of an in memory database.

- Increase the default max connections from 16 to 200 in SQLite().
  Connections to SQLite are inexpensive and there is no longer any
  hard-coded limit to the number of connections you can have.
  However, memory is allocated at driver initialization time based on
  the maximum, so it is best not to use very large values unless you
  really need the connections.

- sqliteTransactionStatement, which is used by dbCommit, dbRollback,
  and dbBeginTransaction, now passes silent=TRUE to try() to suppress
  error messages.  Without this, code that could otherwise handle a
  failed commit gracefully had no way to suppress the error message.
  You can use dbGetException to see the error when
  sqliteTransactionStatement returns FALSE.

- dbConnect/sqliteNewConnection now throws an error if dbname argument
  is NA.  Previously, if as.character(NA) was provided, a database
  with filename "NA" was created.

- dbConnect/sqliteNewConnection now accepts two new arguments:

  flags:
      provides additional control over connetion details.  For
      convenience, you can specify one of SQLITE_RWC (default),
      SQLITE_RW, or SQLITE_RO to obtain a connection in
      read/write/create, read/write, or read only mode, respectively.
      See http://sqlite.org/c3ref/open.html for details.
  vfs:
      controls the virtual filesystem used by SQLite.  The default,
      NULL, lets SQLite select the appropriate vfs for the system.
      You can specify one of "unix-posix", "unix-afp", "unix-flock",
      "unix-dotfile", or "unix-none".  For details, see
      http://www.sqlite.org/compile.html.  This functionality is only
      fully available on OSX.  On non-OSX Unix, you can use
      unix-dotfile and unix-none.  None of these modules are available
      on Windows where a non-NULL values of the vfs argument will be
      ignored with a warning.


# Version 0.7-3

- Use the default value for SQLITE_MAX_SQL_LENGTH which has now been
  significantly increased over the value of 2 million that we had set
  in 2008.

- Fix some Rd cross references in the documentation.

# Version 0.7-2

- Fixed some partial argument matching warnings.  Thanks to Matthias
  Burger for reporting and sending a patch.

- Added dbBuildTableDefinition to exports per user request.

# Version 0.7-1

- Upgraded included SQLite from 3.6.0 to 3.6.4

- Old news is now in ONEWS.  Taking a fresh start with this NEWS file
  to keep better track of changes on a per-release basis.

- Added a HACKING file where we will add notes about how to do
  development on RSQLite.

# Version 0.4-12

* Fix bug in dbListTables for empty databases

# Version 0.4-11

* Implemented dbCommit() and dbRollback(). There is also a new
  generic method dbBeginTransaction(), which begins a transaction.
  Note that this is an extension to the DBI interface.

* Update to the SQLite 3 API for fetching records. This means that
  the records are pulled from the database as required, and not
  cached in memory as was previously done.

* Added generic methods dbSendPreparedQuery() and dbGetPreparedQuery()
  which are similiar to dbSendQuery() and dbGetQuery(), but take an
  extra "bind.data" parameter, which is a data frame. The statement
  is assumed to contain bind variables. Bind variables are either
  for a column name (":name" or "@name") or for a column index ("?")
  in the data frame. See http://sqlite.org/capi3ref.html for more details.

  dbGetPreparedQuery(con, "INSERT INTO table1 VALUES (:col1)",
                           data.frame(col1=c(1, 2)) )

  Each bind variable in the query has to be bound only once, either via
  named or positional parameters. If it is not bound or is bound more
  than once (due to a mix or positional/named parameters) an error is
  thrown. Any extra columns in the data frame are ignored.

  If you are having a lot of string parameters, use stringsAsFactors=FALSE
  when creating the bind.data data.frame instance.  You can also use I().

* Added experimental sqliteQuickColumn function that retrieves an entire 
  column from a specified table as quickly as possible.

* The SQLite driver has a new logical parameter "shared.cache" to
  enable the shared-cache mode, which allows multiple connections
  to share a single data and schema cache. See
  http://www.sqlite.org/sharedcache.html

# Version 0.4-9

* Upgraded to SQLite 3.3.8

* Use .SQLitePkgName instead of hard-coding the package name when
  using .Call

* dbConnect() now has a logical parameter "loadable.extensions"
  which will allow loading of extensions. See the Loadable
  Extensions documentation:
  http://www.sqlite.org/cvstrac/wiki?p=LoadableExtensions

# Version 0.4-4

* Upgraded to SQLite 3.3.7

* Default when building from source is now to compile the included
  version of SQLite and link to it statically

* Fixed unclosed textConnections

# Version 0.4-1

* Added a method for dbWriteTable to write table from a text file, e.g.,
  dbWriteTable(con, "tablename", "filename")

* Fixed problems exporting/importing NA's (thanks to Ronngui Huang for
  a very clear bug report).

* Fixed double free() in the C code, a tiny memory leak, and configure now
  builds sqlite properly on 64-bit linux (thanks to Seth Falcon for these).

* dbConnect() now accepts values for the "cache_size" and "sychnronous"
  PRAGMAs ("synchronous" defaults to 0 or "off") to improve
  performance (thanks to Charles Loboz for pointing these out, see the
  file "rsqlitePerf.txt").

# Version 0.4-0

* First attempt at using the new SQLite Version 3 API.  This version
  is a bridge to the new API, but it does not make available the new
  capabilities (e.g., prepared statements, data bindings, etc.) but
  prepares us for those new features.

* Clean up some installation code (mainly to make it easy to automatically
  build on Windows, as per Kurt Hornik and Uwe Ligges suggestions).

* Fixed bug that ignored "fetch.default.rec" in SQLite()/dbDriver()
  (as reported by Duncan Murdoch)

* Fixed bug in dbReadTable() that was not recognizing "row.names" in its
  default, thus it now re-creates a data.frame that has been exported
  with dbWriteTable().

* Fixed bug where dbListTables was not listing views (as reported by
  Doug Bates).

* Added code in "configure.in" to determine CC/CFLAGS used in compiling R
  (as suggested by Brian D. Ripley to get it to compile on 64-bit machines).
  As of today, I can't test this myself.

# Version 0.3-5

* Documentation typos, trivial packaging changes, as per CRAN maintainer
  request.

# Version 0.3-4

* Fixed documentation typos.

# Version 0.3-3

* Minor fixes to accommadate R 1.8.0 changes to data.frame subsetting.

* Updated the documentation to use 1.8.0 new S4-style method documentation.

* Updated to SQLite to the latest 2.8.6 (included with RSQLite).

* Added file NAMESPACE.future to prepare for namespace implementation
  at some future release.

# Version 0.3-2

* Ported to Windows.  It now installs fine under Windows with

    Rcmd INSTALL RSQLite_0.3-2.tar.gz

  (there's also a binary RSQLite_0.3-2.zip)

* Added code to verify that the SQLite library versions used for
  compilation and at runtime agree.

* Added source sqlite-2.8.3.

* Fixed minor documentation errors and removed the DBI.pdf documentation
  file, which is included in the required DBI package.

* The package now installs as a binary image by default (use the --no-save
  argument to R CMD INSTALL to override this).

# Version 0.3-1

* Moved the implementation to version 4 style classes, and it now
  it is fully compliant with the DBI 0.1-3.

* Simplified the core helper R/SQLite functions (w. prefix "sqlite")
  following the ROracle model.

* Updated to sqlite version 2.7.1 (note that if you have an sqlite
  database file from a version prior to 2.6 you'll need to update
  it -- for details see http://www.hwaic.com/sw/sqlite).

# Version 0.2-1

* Worked mostly in the configuration;  added the --enable-sqlite and
  --with-sqlite arguments to have the RSQLite configuration also install
  SQLite or locate it, respectively.

# Version 0.1-1

* First implementation -- used the RS-DBI.[ch] code (which is the core
  connection/cursor manager) "as is" and modified the RS-MySQL.[hc],
  (which sits directly on top of the MySQL C API) and replace the
  MySQL API calls with SQLite API calls.  This was pretty easy, except
  for the fact that the SQLite API is so minimal (3, yes, 3 C functions)
  with no support for connections, result set (cursors), data types,
  meta-data -- nothing.  So I had to simulate all this. (Actually it
  wasn't too bad).

