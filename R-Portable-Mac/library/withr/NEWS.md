# withr 2.1.2

- `set_makevars()` is now exported (#68, @gaborcsardi).

- `with_temp_libpaths()` gains an `action` argument, to specify how the
  temporary library path will be added (#66, @krlmlr).

# withr 2.1.1

- Fixes test failures with testthat 2.0.0

- `with_file()` function to automatically remove files.

# withr 2.1.0

- `with_connection()` function to automatically close R file connections.

- `with_db_connection()` function to automatically disconnect from DBI database
  connections.

- `with_gctorture2` command to run code with gctorture2, useful for testing
  (#47).

- `with_package()`, `with_namespace()` and `with_environment()` (and equivalent
  locals) functions added, to run code with a modified object search path (#38,
  #48).

- Add `with_tempfile()` and `local_tempfile()` functions to create temporary
  files which are cleanup up afterwards. (#32)

- Remove the `code` argument from `local_` functions (#50).

# withr 2.0.0

- Each `with_` function now has a `local_` variant, which reset at the end of
  their local scope, generally at the end of the function body.

- New functions `with_seed()` and `with_preserve_seed()` for running code with
  a given random seed (#45, @krlmlr).

# withr 1.0.2
- `with_makevars()` gains an `assignment` argument to allow specifying
  additional assignment types.

# withr 1.0.1
- Relaxed R version requirement to 3.0.2 (#35, #39).
- New `with_output_sink()` and `with_message_sink()` (#24).

# withr 1.0.0

- First Public Release
