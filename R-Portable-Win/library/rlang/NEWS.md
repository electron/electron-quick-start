
# rlang 0.3.4

* Fixed a unit test that failed on the Solaris CRAN machine.


# rlang 0.3.3

* Fixed an issue in knitr that caused backtraces to print even when `error = TRUE`.

* `maybe_missing()` gains a `default` argument.


# rlang 0.3.2

* Fixed protection issue reported by rchk.

* The experimental option `rlang__backtrace_on_error` is no longer
  experimental and has been renamed to `rlang_backtrace_on_error`.

* New "none" option for `rlang_backtrace_on_error`.

* Unary operators applied to quosures now give better error messages.

* Fixed issue with backtraces of warnings promoted to error, and
  entraced via `withCallingHandlers()`. The issue didn't affect
  entracing via top level `options(error = rlang::entrace)` handling.


# rlang 0.3.1

This patch release polishes the new backtrace feature introduced in
rlang 0.3.0 and solves bugs for the upcoming release of purrr
0.3.0. It also features `as_label()` and `as_name()` which are meant
to replace `quo_name()` in the future. Finally, a bunch of deparsing
issues have been fixed.


## Backtrace fixes

* New `entrace()` condition handler. Add this to your RProfile to
  enable rlang backtraces for all errors, including warnings promoted
  to errors:

  ```r
  if (requireNamespace("rlang", quietly = TRUE)) {
    options(error = rlang::entrace)
  }
  ```

  This handler also works as a calling handler:

  ```r
  with_handlers(
    error = calling(entrace),
    foo(bar)
  )
  ```

  However it's often more practical to use `with_abort()` in that case:

  ```r
  with_abort(foo(bar))
  ```

* `with_abort()` gains a `classes` argument to promote any kind of
  condition to an rlang error.

* New `last_trace()` shortcut to print the backtrace stored in the
  `last_error()`.

* Backtrace objects now print in full by default.

* Calls in backtraces are now numbered according to their position in
  the call tree. The numbering is non-contiguous for simplified
  backtraces because of omitted call frames.

* `catch_cnd()` gains a `classes` argument to specify which classes of
  condition to catch. It returns `NULL` if the expected condition
  could not be caught (#696).


## `as_label()` and `as_name()`

The new `as_label()` and `as_name()` functions should be used instead
of `quo_name()` to transform objects and quoted expressions to a
string. We have noticed that tidy eval users often use `quo_name()` to
extract names from quosured symbols. This is not a good use for that
function because the way `quo_name()` creates a string is not a well
defined operation.

For this reason, we are replacing `quo_name()` with two new functions
that have more clearly defined purposes, and hopefully better names
reflecting those purposes. Use `as_label()` to transform any object to
a short human-readable description, and `as_name()` to extract names
from (possibly quosured) symbols.

Create labels with `as_label()` to:

* Display an object in a concise way, for example to labellise axes
  in a graphical plot.

* Give default names to columns in a data frame. In this case,
  labelling is the first step before name repair.

We expect `as_label()` to gain additional parameters in the future,
for example to control the maximum width of a label. The way an object
is labelled is thus subject to change.

On the other hand, `as_name()` transforms symbols back to a string in
a well defined manner. Unlike `as_label()`, `as_name()` guarantees the
roundtrip symbol -> string -> symbol.

In general, if you don't know for sure what kind of object you're
dealing with (a call, a symbol, an unquoted constant), use
`as_label()` and make no assumption about the resulting string. If you
know you have a symbol and need the name of the object it refers to,
use `as_name()`. For instance, use `as_label()` with objects captured
with `enquo()` and `as_name()` with symbols captured with `ensym()`.

Note that `quo_name()` will only be soft-deprecated at the next major
version of rlang (0.4.0). At this point, it will start issuing
once-per-session warnings in scripts, but not in packages. It will
then be deprecated in yet another major version, at which point it
will issue once-per-session warnings in packages as well. You thus
have plenty of time to change your code.


## Minor fixes and features

* New `is_interactive()` function. It serves the same purpose as
  `base::interactive()` but also checks if knitr is in progress and
  provides an escape hatch. Use `with_interactive()` and
  `scoped_interactive()` to override the return value of
  `is_interactive()`. This is useful in unit tests or to manually turn
  on interactive features in RMarkdown outputs

* `calling()` now boxes its argument.

* New `done()` function to box a value. Done boxes are sentinels to
  indicate early termination of a loop or computation. For instance,
  it will be used in the purrr package to allow users to shortcircuit
  a reduction or accumulation.

* `new_box()` now accepts additional attributes passed to `structure()`.

* Fixed a quotation bug with binary operators of zero or one argument
  such as `` `/`(1) `` (#652). They are now deparsed and printed
  properly as well.

* New `call_ns()` function to retrieve the namespace of a
  call. Returns `NULL` if the call is not namespaced.

* Top-level S3 objects are now deparsed properly.

* Empty `{` blocks are now deparsed on the same line.

* Fixed a deparsing issue with symbols containing non-ASCII
  characters (#691).

* `expr_print()` now handles `[` and `[[` operators correctly, and
  deparses non-syntactic symbols with backticks.

* `call_modify()` now respects ordering of unnamed inputs. Before this
  fix, it would move all unnamed inputs after named ones.

* `as_closure()` wrappers now call primitives with positional
  arguments to avoid edge case issues of argument matching.

* `as_closure()` wrappers now dispatch properly on methods defined in
  the global environment (tidyverse/purrr#459).

* `as_closure()` now supports both base-style (`e1` and `e2`) and
  purrr-style (`.x` and `.y`) arguments with binary primitives.

* `exec()` takes `.fn` as first argument instead of `f`, for
  consistency with other rlang functions.

* Fixed infinite loop with quosures created inside a data mask.

* Base errors set as `parent` of rlang errors are now printed
  correctly.



# rlang 0.3.0

## Breaking changes

The rlang API is still maturing. In this section, you'll find hard
breaking changes. See the life cycle section below for an exhaustive
list of API changes.

* `quo_text()` now deparses non-syntactic symbols with backticks:

  ```
  quo_text(sym("foo+"))
  #> [1] "`foo+`"
  ```

  This caused a number of issues in reverse dependencies as
  `quo_text()` tends to be used for converting symbols to strings.
  `quo_text()` and `quo_name()` should not be used for this purpose
  because they are general purpose deparsers. These functions should
  generally only be used for printing outputs or creating default
  labels. If you need to convert symbols to strings, please use
  `as_string()` rather than `quo_text()`.

  We have extended the documentation of `?quo_text` and `?quo_name` to
  make these points clearer.

* `exprs()` no longer flattens quosures. `exprs(!!!quos(x, y))` is now
  equivalent to `quos(x, y)`.

* The sentinel for removing arguments in `call_modify()` has been
  changed from `NULL` to `zap()`. This breaking change is motivated
  by the ambiguity of `NULL` with valid argument values.

  ```r
  call_modify(call, arg = NULL)  # Add `arg = NULL` to the call
  call_modify(call, arg = zap()) # Remove the `arg` argument from the call
  ```

* The `%@%` operator now quotes its input and supports S4 objects.
  This makes it directly equivalent to `@` except that it extracts
  attributes for non-S4 objects (#207).

* Taking the `env_parent()` of the empty environment is now an error.


## Summary

The changes for this version are organised around three main themes:
error reporting, tidy eval, and tidy dots.

* `abort()` now records backtraces automatically in the error object.
  Errors thrown with `abort()` invite users to call
  `rlang::last_error()` to see a backtrace and help identifying where
  and why the error occurred. The backtraces created by rlang (you can
  create one manually with `trace_back()`) are printed in a simplified
  form by default that removes implementation details from the
  backtrace. To see the full backtrace, call
  `summary(rlang::last_error())`.

  `abort()` also gains a `parent` argument. This is meant for
  situations where you're calling a low level API (to download a file,
  parse a JSON file, etc) and would like to intercept errors with
  `base::tryCatch()` or `rlang::with_handlers()` and rethrow them with
  a high-level message. Call `abort()` with the intercepted error as
  the `parent` argument. When the user prints `rlang::last_error()`,
  the backtrace will be shown in two sections corresponding to the
  high-level and low-level contexts.

  In order to get segmented backtraces, the low-level error has to be
  thrown with `abort()`. When that's not the case, you can call the
  low-level function within `with_abort()` to automatically promote
  all errors to rlang errors.

* The tidy eval changes are mostly for developers of data masking
  APIs. The main user-facing change is that `.data[[` is now an
  unquote operator so that `var` in `.data[[var]]` is never masked by
  data frame columns and always picked from the environment. This
  makes the pronoun safe for programming in functions.

* The `!!!` operator now supports all classed objects like factors. It
  calls `as.list()` on S3 objects and `as(x, "list")` on S4 objects.

* `dots_list()` gains several arguments to control how dots are
  collected. You can control the selection of arguments with the same
  name with `.homonyms` (keep first, last, all, or abort). You can
  also elect to preserve empty arguments with `.preserve_empty`.


## Conditions and errors

* New `trace_back()` captures a backtrace. Compared to the base R
  traceback, it contains additional structure about the relationship
  between frames. It comes with tools for automatically restricting to
  frames after a certain environment on the stack, and to simplify
  when printing. These backtraces are now recorded in errors thrown by
  `abort()` (see below).

* `abort()` gains a `parent` argument to specify a parent error. This
  is meant for situations where a low-level error is expected
  (e.g. download or parsing failed) and you'd like to throw an error
  with higher level information. Specifying the low-level error as
  parent makes it possible to partition the backtraces based on
  ancestry.

* Errors thrown with `abort()` now embed a backtrace in the condition
  object. It is no longer necessary to record a trace with a calling
  handler for such errors.

* `with_abort()` runs expressions in a context where all errors are
  promoted to rlang errors and gain a backtrace.

* Unhandled errors thrown by `abort()` are now automatically saved and
  can be retrieved with `rlang::last_error()`. The error prints with a
  simplified backtrace. Call `summary(last_error())` to see the full
  backtrace.

* New experimental option `rlang__backtrace_on_error` to display
  backtraces alongside error messages. See `?rlang::abort` for
  supported options.

* The new `signal()` function completes the `abort()`, `warn()` and
  `inform()` family. It creates and signals a bare condition.

* New `interrupt()` function to simulate an user interrupt from R
  code.

* `cnd_signal()` now dispatches messages, warnings, errors and
  interrupts to the relevant signalling functions (`message()`,
  `warning()`, `stop()` and the C function `Rf_onintr()`). This makes
  it a good choice to resignal a captured condition.

* New `cnd_type()` helper to determine the type of a condition
  (`"condition"`, `"message"`, `"warning"`, `"error"` or `"interrupt"`).

* `abort()`, `warn()` and `inform()` now accepts metadata with `...`.
  The data are stored in the condition and can be examined by user
  handlers.

  Consequently all arguments have been renamed and prefixed with a dot
  (to limit naming conflicts between arguments and metadata names).

* `with_handlers()` treats bare functions as exiting handlers
  (equivalent to handlers supplied to `tryCatch()`). It also supports
  the formula shortcut for lambda functions (as in purrr).

* `with_handlers()` now produces a cleaner stack trace.


## Tidy dots

* The input types of `!!!` have been standardised. `!!!` is generally
  defined on vectors: it takes a vector (typically, a list) and
  unquotes each element as a separate argument. The standardisation
  makes `!!!` behave the same in functions taking dots with `list2()`
  and in quoting functions. `!!!` accepts these types:

  - Lists, pairlists, and atomic vectors. If they have a class, they
    are converted with `base::as.list()` to allow S3 dispatch.
    Following this change, objects like factors can now be spliced
    without data loss.

  - S4 objects. These are converted with `as(obj, "list")` before
    splicing.

  - Quoted blocks of expressions, i.e. `{ }` calls

  `!!!` disallows:

  - Any other objects like functions or environments, but also
    language objects like formula, symbols, or quosures.

  Quoting functions used to automatically wrap language objects in
  lists to make them spliceable. This behaviour is now soft-deprecated
  and it is no longer valid to write `!!!enquo(x)`. Please unquote
  scalar objects with `!!` instead.

* `dots_list()`, `enexprs()` and `enquos()` gain a `.homonyms`
  argument to control how to treat arguments with the same name.
  The default is to keep them. Set it to `"first"` or `"last"` to keep
  only the first or last occurrences. Set it to `"error"` to raise an
  informative error about the arguments with duplicated names.

* `enexprs()` and `enquos()` now support `.ignore_empty = "all"`
  with named arguments as well (#414).

* `dots_list()` gains a `.preserve_empty` argument. When `TRUE`, empty
  arguments are stored as missing arguments (see `?missing_arg`).

* `dots_list()`, `enexprs()` and `enquos()` gain a `.check_assign`
  argument. When `TRUE`, a warning is issued when a `<-` call is
  detected in `...`. No warning is issued if the assignment is wrapped
  in brackets like `{ a <- 1 }`. The warning lets users know about a
  possible typo in their code (assigning instead of matching a
  function parameter) and requires them to be explicit that they
  really want to assign to a variable by wrapping in parentheses.

* `lapply(list(quote(foo)), list2)` no longer evaluates `foo` (#580).


## Tidy eval

* You can now unquote quosured symbols as LHS of `:=`. The symbol is
  automatically unwrapped from the quosure.

* Quosure methods have been defined for common operations like
  `==`. These methods fail with an informative error message
  suggesting to unquote the quosure (#478, #tidyverse/dplyr#3476).

* `as_data_pronoun()` now accepts data masks. If the mask has multiple
  environments, all of these are looked up when subsetting the pronoun.
  Function objects stored in the mask are bypassed.

* It is now possible to unquote strings in function position. This is
  consistent with how the R parser coerces strings to symbols. These
  two expressions are now equivalent: `expr("foo"())` and
  `expr((!!"foo")())`.

* Quosures converted to functions with `as_function()` now support
  nested quosures.

* `expr_deparse()` (used to print quosures at the console) now escapes
  special characters. For instance, newlines now print as `"\n"` (#484).
  This ensures that the roundtrip `parse_expr(expr_deparse(x))` is not
  lossy.

* `new_data_mask()` now throws an error when `bottom` is not a child
  of `top` (#551).

* Formulas are now evaluated in the correct environment within
  `eval_tidy()`. This fixes issues in dplyr and other tidy-evaluation
  interfaces.

* New functions `new_quosures()` and `as_quosures()` to create or
  coerce to a list of quosures. This is a small S3 class that ensures
  two invariants on subsetting and concatenation: that each element is
  a quosure and that the list is always named even if only with a
  vector of empty strings.


## Environments

* `env()` now treats a single unnamed argument as the parent of the
  new environment. Consequently, `child_env()` is now superfluous and
  is now in questioning life cycle.

* New `current_env()` and `current_fn()` functions to retrieve the
  current environment or the function being evaluated. They are
  equivalent to `base::environment()` and `base::sys.function()`
  called without argument.

* `env_get()` and `env_get_list()` gain a `default` argument to
  provide a default value for non-existing bindings.

* `env_poke()` now returns the old value invisibly rather than the
  input environment.

* The new function `env_name()` returns the name of an environment.
  It always adds the "namespace:" prefix to namespace names. It
  returns "global" instead of ".GlobalEnv" or "R_GlobalEnv", "empty"
  instead of "R_EmptyEnv". The companion `env_label()` is like
  `env_name()` but returns the memory address for anonymous
  environments.

* `env_parents()` now returns a named list. The names are taken with
  `env_name()`.

* `env_parents()` and `env_tail()` now stop at the global environment
  by default. This can be changed with the `last` argument. The empty
  environment is always a stopping condition so you can take the
  parents or the tail of an environment on the search path without
  changing the default.

* New predicates `env_binding_are_active()` and
  `env_binding_are_lazy()` detect the kind of bindings in an
  environment.

* `env_binding_lock()` and `env_binding_unlock()` allows to lock and
  unlock multiple bindings. The predicate `env_binding_are_locked()`
  tests if bindings are locked.

* `env_lock()` and `env_is_locked()` lock an environment or test if
  an environment is locked.

* `env_print()` pretty-prints environments. It shows the contents (up
  to 20 elements) and the properties of the environment.

* `is_scoped()` has been soft-deprecated and renamed to
  `is_attached()`. It now supports environments in addition to search
  names.

* `env_bind_lazy()` and `env_bind_active()` now support quosures.

* `env_bind_exprs()` and `env_bind_fns()` are soft-deprecated and
  renamed to `env_bind_lazy()` and `env_bind_active()` for clarity
  and consistency.

* `env_bind()`, `env_bind_exprs()`, and `env_bind_fns()` now return
  the list of old binding values (or missing arguments when there is
  no old value). This makes it easy to restore the original
  environment state:

  ```
  old <- env_bind(env, foo = "foo", bar = "bar")
  env_bind(env, !!!old)
  ```

* `env_bind()` now supports binding missing arguments and removing
  bindings with zap sentinels. `env_bind(env, foo = )` binds a missing
  argument and `env_bind(env, foo = zap())` removes the `foo`
  binding.

* The `inherit` argument of `env_get()` and `env_get_list()` has
  changed position. It now comes after `default`.

* `scoped_bindings()` and `with_bindings()` can now be called without
  bindings.

* `env_clone()` now recreates active bindings correctly.

* `env_get()` now evaluates promises and active bindings since these are
  internal objects which should not be exposed at the R level (#554)

* `env_print()` calls `get_env()` on its argument, making it easier to 
  see the environment of closures and quosures (#567).

* `env_get()` now supports retrieving missing arguments when `inherit`
  is `FALSE`.


## Calls

* `is_call()` now accepts multiple namespaces. For instance
  `is_call(x, "list", ns = c("", "base"))` will match if `x` is
  `list()` or if it's `base::list()`:

* `call_modify()` has better support for `...` and now treats it like
  a named argument. `call_modify(call, ... = )` adds `...` to the call
  and `call_modify(call, ... = NULL)` removes it.

* `call_modify()` now preserves empty arguments. It is no longer
  necessary to use `missing_arg()` to add a missing argument to a
  call. This is possible thanks to the new `.preserve_empty` option of
  `dots_list()`.

* `call_modify()` now supports removing unexisting arguments (#393)
  and passing multiple arguments with the same name (#398). The new
  `.homonyms` argument controls how to treat these arguments.

* `call_standardise()` now handles primitive functions like `~`
  properly (#473).

* `call_print_type()` indicates how a call is deparsed and printed at
  the console by R: prefix, infix, and special form.

* The `call_` functions such as `call_modify()` now correctly check
  that their input is the right type (#187).


## Other improvements and fixes

* New function `zap()` returns a sentinel that instructs functions
  like `env_bind()` or `call_modify()` that objects are to be removed.

* New function `rep_named()` repeats value along a character vector of
  names.

* New function `exec()` is a simpler replacement to `invoke()`
  (#536). `invoke()` has been soft-deprecated.

* Lambda functions created from formulas with `as_function()` are now
  classed. Use `is_lambda()` to check a function was created with the
  formula shorthand.

* `is_integerish()` now supports large double values (#578).

* `are_na()` now requires atomic vectors (#558).

* The operator `%@%` has now a replacement version to update
  attributes of an object (#207).

* `fn_body()` always returns a `{` block, even if the function has a
  single expression. For instance `fn_body(function(x) do()) ` returns
  `quote({ do() })`.

* `is_string()` now returns `FALSE` for `NA_character_`.

* The vector predicates have been rewritten in C for performance.

* The `finite` argument of `is_integerish()` is now `NULL` by
  default. Missing values are now considered as non-finite for
  consistency with `base::is.finite()`.

* `is_bare_integerish()` and `is_scalar_integerish()` gain a `finite`
  argument for consistency with `is_integerish()`.

* `flatten_if()` and `squash_if()` now handle primitive functions like
  `base::is.list()` as predicates.

* `is_symbol()` now accepts a character vector of names to mach the
  symbol against.

* `parse_exprs()` and `parse_quos()` now support character vectors.
  Note that the output may be longer than the input as each string may
  yield multiple expressions (such as `"foo; bar"`).

* `parse_quos()` now adds the `quosures` class to its output.


## Lifecycle

### Soft-deprecated functions and arguments

rlang 0.3.0 introduces a new warning mechanism for soft-deprecated
functions and arguments. A warning is issued, but only under one of
these circumstances:

* rlang has been attached with a `library()` call.
* The deprecated function has been called from the global environment.

In addition, deprecation warnings appear only once per session in
order to not be disruptive.

Deprecation warnings shouldn't make R CMD check fail for packages
using testthat. However, `expect_silent()` can transform the warning
to a hard failure.


#### tidyeval

* `.data[[foo]]` is now an unquote operator. This guarantees that
  `foo` is evaluated in the context rather than the data mask and
  makes it easier to treat `.data[["bar"]]` the same way as a
  symbol. For instance, this will help ensuring that `group_by(df,
  .data[["name"]])` and `group_by(df, name)` produce the same column
  name.

* Automatic naming of expressions now uses a new deparser (still
  unexported) instead of `quo_text()`. Following this change,
  automatic naming is now compatible with all object types (via
  `pillar::type_sum()` if available), prevents multi-line names, and
  ensures `name` and `.data[["name"]]` are given the same default
  name.

* Supplying a name with `!!!` calls is soft-deprecated. This name is
  ignored because only the names of the spliced vector are applied.

* Quosure lists returned by `quos()` and `enquos()` now have "list-of"
  behaviour: the types of new elements are checked when adding objects
  to the list. Consequently, assigning non-quosure objects to quosure
  lists is now soft-deprecated. Please coerce to a bare list with
  `as.list()` beforehand.

* `as_quosure()` now requires an explicit environment for symbols and
  calls. This should typically be the environment in which the
  expression was created.

* `names()` and `length()` methods for data pronouns are deprecated.
  It is no longer valid to write `names(.data)` or `length(.data)`.

* Using `as.character()` on quosures is soft-deprecated (#523).


#### Miscellaneous

* Using `get_env()` without supplying an environment is now
  soft-deprecated. Please use `current_env()` to retrieve the current
  environment.

* The frame and stack API is soft-deprecated. Some of the
  functionality has been replaced by `trace_back()`.

* The `new_vector_along()` family is soft-deprecated because these
  functions are longer to type than the equivalent `rep_along()` or
  `rep_named()` calls without added clarity.

* Passing environment wrappers like formulas or functions to `env_`
  functions is now soft-deprecated. This internal genericity was
  causing confusion (see issue #427). You should now extract the
  environment separately before calling these functions.

  This change concerns `env_depth()`, `env_poke_parent()`,
  `env_parent<-`, `env_tail()`, `set_env()`, `env_clone()`,
  `env_inherits()`, `env_bind()`, `scoped_bindings()`,
  `with_bindings()`, `env_poke()`, `env_has()`, `env_get()`,
  `env_names()`, `env_bind_exprs()` and `env_bind_fns()`.

* `cnd_signal()` now always installs a muffling restart for
  non-critical conditions. Consequently the `.mufflable` argument has
  been soft-deprecated and no longer has any effect.


### Deprecated functions and arguments

Deprecated functions and arguments issue a warning inconditionally,
but only once per session.

* Calling `UQ()` and `UQS()` with the rlang namespace qualifier is
  deprecated as of rlang 0.3.0. Just use the unqualified forms
  instead:

  ```
  # Bad
  rlang::expr(mean(rlang::UQ(var) * 100))

  # Ok
  rlang::expr(mean(UQ(var) * 100))

  # Good
  rlang::expr(mean(!!var * 100))
  ```

  Although soft-deprecated since rlang 0.2.0, `UQ()` and `UQS()` can still be used for now.

* The `call` argument of `abort()` and condition constructors is now
  deprecated in favour of storing full backtraces.

* The `.standardise` argument of `call_modify()` is deprecated. Please
  use `call_standardise()` beforehand.

* The `sentinel` argument of `env_tail()` has been deprecated and
  renamed to `last`.


### Defunct functions and arguments

Defunct functions and arguments throw an error when used.

* `as_dictionary()` is now defunct.

* The experimental function `rst_muffle()` is now defunct. Please use
  `cnd_muffle()` instead. Unlike its predecessor, `cnd_muffle()` is not
  generic. It is marked as a calling handler and thus can be passed
  directly to `with_handlers()` to muffle specific conditions (such as
  specific subclasses of warnings).

* `cnd_inform()`, `cnd_warn()` and `cnd_abort()` are retired and
  defunct. The old `cnd_message()`, `cnd_warning()`, `cnd_error()` and
  `new_cnd()` constructors deprecated in rlang 0.2.0 are now defunct.

* Modifying a condition with `cnd_signal()` is defunct. In addition,
  creating a condition with `cnd_signal()` is soft-deprecated, please
  use the new function [signal()] instead.

* `inplace()` has been renamed to `calling()` to follow base R
  terminology more closely.


### Functions and arguments in the questioning stage

We are no longer convinced these functions are the right approach but
we do not have a precise alternative yet.

* The functions from the restart API are now in the questioning
  lifecycle stage. It is not clear yet whether we want to recommend
  restarts as a style of programming in R.

* `prepend()` and `modify()` are in the questioning stage, as well as
  `as_logical()`, `as_character()`, etc. We are still figuring out
  what vector tools belong in rlang.

* `flatten()`, `squash()` and their atomic variants are now in the
  questioning lifecycle stage. They have slightly different semantics
  than the flattening functions in purrr and we are currently
  rethinking our approach to flattening with the new typing facilities
  of the vctrs package.


# rlang 0.2.2

This is a maintenance release that fixes several garbage collection
protection issues.


# rlang 0.2.1

This is a maintenance release that fixes several tidy evaluation
issues.

* Functions with tidy dots support now allow splicing atomic vectors.

* Quosures no longer capture the current `srcref`.

* Formulas are now evaluated in the correct environment by
  `eval_tidy()`. This fixes issues in dplyr and other tidy-evaluation
  interfaces.


# rlang 0.2.0

This release of rlang is mostly an effort at polishing the tidy
evaluation framework. All tidy eval functions and operators have been
rewritten in C in order to improve performance. Capture of expression,
quasiquotation, and evaluation of quosures are now vastly faster. On
the UI side, many of the inconveniences that affected the first
release of rlang have been solved:

* The `!!` operator now has the precedence of unary `+` and `-` which
  allows a much more natural syntax: `!!a > b` only unquotes `a`
  rather than the whole `a > b` expression.

* `enquo()` works in magrittr pipes: `mtcars %>% select(!!enquo(var))`.

* `enquos()` is a variant of `quos()` that has a more natural
  interface for capturing multiple arguments and `...`.

See the first section below for a complete list of changes to the tidy
evaluation framework.

This release also polishes the rlang API. Many functions have been
renamed as we get a better feel for the consistency and clarity of the
API. Note that rlang as a whole is still maturing and some functions
are even experimental. In order to make things clearer for users of
rlang, we have started to develop a set of conventions to document the
current stability of each function. You will now find "lifecycle"
sections in documentation topics. In addition we have gathered all
lifecycle information in the `?rlang::lifecycle` help page. Please
only use functions marked as stable in your projects unless you are
prepared to deal with occasional backward incompatible updates.


## Tidy evaluation

* The backend for `quos()`, `exprs()`, `list2()`, `dots_list()`, etc
  is now written in C. This greatly improve the performance of dots
  capture, especially with the splicing operator `!!!` which now
  scales much better (you'll see a 1000x performance gain in some
  cases). The unquoting algorithm has also been improved which makes
  `enexpr()` and `enquo()` more efficient as well.

* The tidy eval `!!` operator now binds tightly. You no longer have to
  wrap it in parentheses, i.e. `!!x > y` will only unquote `x`.

  Technically the `!!` operator has the same precedence as unary `-`
  and `+`. This means that `!!a:b` and `!!a + b` are equivalent to
  `(!!a):b` and `(!!a) + b`. On the other hand `!!a^b` and `!!a$b` are
  equivalent to`!!(a^b)` and `!!(a$b)`.

* The print method for quosures has been greatly improved. Quosures no
  longer appear as formulas but as expressions prefixed with `^`;
  quosures are colourised according to their environment; unquoted
  objects are displayed between angular brackets instead of code
  (i.e. an unquoted integer vector is shown as `<int: 1, 2>` rather
  than `1:2`); unquoted S3 objects are displayed using
  `pillar::type_sum()` if available.

* New `enquos()` function to capture arguments. It treats `...` the
  same way as `quos()` but can also capture named arguments just like
  `enquo()`, i.e. one level up. By comparison `quos(arg)` only
  captures the name `arg` rather than the expression supplied to the
  `arg` argument.

  In addition, `enexprs()` is like `enquos()` but like `exprs()` it
  returns bare expressions. And `ensyms()` expects strings or symbols.

* It is now possible to use `enquo()` within a magrittr pipe:

  ```
  select_one <- function(df, var) {
    df %>% dplyr::select(!!enquo(var))
  }
  ```

  Technically, this is because `enquo()` now also captures arguments
  in parents of the current environment rather than just in the
  current environment. The flip side of this increased flexibility is
  that if you made a typo in the name of the variable you want to
  capture, and if an object of that name exists anywhere in the parent
  contexts, you will capture that object rather than getting an error.

* `quo_expr()` has been renamed to `quo_squash()` in order to better
  reflect that it is a lossy operation that flattens all nested
  quosures.


* `!!!` now accepts any kind of objects for consistency. Scalar types
  are treated as vectors of length 1. Previously only symbolic objects
  like symbols and calls were treated as such.

* `ensym()` is a new variant of `enexpr()` that expects a symbol or a
  string and always returns a symbol. If a complex expression is
  supplied it fails with an error.

* `exprs()` and `quos()` gain a `.unquote_names` arguments to switch
  off interpretation of `:=` as a name operator. This should be useful
  for programming on the language targetting APIs such as
  data.table.

* `exprs()` gains a `.named` option to auto-label its arguments (#267).

* Functions taking dots by value rather than by expression
  (e.g. regular functions, not quoting functions) have a more
  restricted set of unquoting operations. They only support `:=` and
  `!!!`, and only at top-level. I.e. `dots_list(!!! x)` is valid but
  not `dots_list(nested_call(!!! x))` (#217).

* Functions taking dots with `list2()` or `dots_list()` now support
  splicing of `NULL` values. `!!! NULL` is equivalent to `!!! list()`
  (#242).

* Capture operators now support evaluated arguments. Capturing a
  forced or evaluated argument is exactly the same as unquoting that
  argument: the actual object (even if a vector) is inlined in the
  expression. Capturing a forced argument occurs when you use
  `enquo()`, `enexpr()`, etc too late. It also happens when your
  quoting function is supplied to `lapply()` or when you try to quote
  the first argument of an S3 method (which is necessarily evaluated
  in order to detect which class to dispatch to). (#295, #300).

* Parentheses around `!!` are automatically removed. This makes the
  generated expression call cleaner: `(!! sym("name"))(arg)`. Note
  that removing the parentheses will never affect the actual
  precedence within the expression as the parentheses are only useful
  when parsing code as text. The parentheses will also be added by R
  when printing code if needed (#296).

* Quasiquotation now supports `!!` and `!!!` as functional forms:

  ```
  expr(`!!`(var))
  quo(call(`!!!`(var)))
  ```

  This is consistent with the way native R operators parses to
  function calls. These new functional forms are to be preferred to
  `UQ()` and `UQS()`. We are now questioning the latter and might
  deprecate them in a future release.

* The quasiquotation parser now gives meaningful errors in corner
  cases to help you figure out what is wrong.

* New getters and setters for quosures: `quo_get_expr()`,
  `quo_get_env()`, `quo_set_expr()`, and `quo_set_env()`. Compared to
  `get_expr()` etc, these accessors only work on quosures and are
  slightly more efficient.

* `quo_is_symbol()` and `quo_is_call()` now take the same set of
  arguments as `is_symbol()` and `is_call()`.

* `enquo()` and `enexpr()` now deal with default values correctly (#201).

* Splicing a list no longer mutates it (#280).


## Conditions

* The new functions `cnd_warn()` and `cnd_inform()` transform
  conditions to warnings or messages before signalling them.

* `cnd_signal()` now returns invisibly.

* `cnd_signal()` and `cnd_abort()` now accept character vectors to
  create typed conditions with several S3 subclasses.

* `is_condition()` is now properly exported.

* Condition signallers such as `cnd_signal()` and `abort()` now accept
  a call depth as `call` arguments. This allows plucking a call from
  further up the call stack (#30).

* New helper `catch_cnd()`. This is a small wrapper around
  `tryCatch()` that captures and returns any signalled condition. It
  returns `NULL` if none was signalled.

* `cnd_abort()` now adds the correct S3 classes for error
  conditions. This fixes error catching, for instance by
  `testthat::expect_error()`.


## Environments

* `env_get_list()` retrieves muliple bindings from an environment into
  a named list.

* `with_bindings()` and `scoped_bindings()` establish temporary
  bindings in an environment.

* `is_namespace()` is a snake case wrapper around `isNamespace()`.


## Various features

* New functions `inherits_any()`, `inherits_all()`, and
  `inherits_only()`. They allow testing for inheritance from multiple
  classes. The `_any` variant is equivalent to `base::inherits()` but
  is more explicit about its behaviour. `inherits_all()` checks that
  all classes are present in order and `inherits_only()` checks that
  the class vectors are identical.

* New `fn_fmls<-` and `fn_fmls_names<-` setters.

* New function experimental function `chr_unserialise_unicode()` for
  turning characters serialised to unicode point form
  (e.g. `<U+xxxx>`) to UTF-8. In addition, `as_utf8_character()` now
  translates those as well. (@krlmlr)

* `expr_label()` now supports quoted function definition calls (#275).

* `call_modify()` and `call_standardise()` gain an argument to specify
  an environment. The call definition is looked up in that environment
  when the call to modify or standardise is not wrapped in a quosure.

* `is_symbol()` gains a `name` argument to check that that the symbol
  name matches a string (#287).

* New `rlang_box` class. Its purpose is similar to the `AsIs` class
  from `base::I()`, i.e. it protects a value temporarily. However it
  does so by wrapping the value in a scalar list. Use `new_box()` to
  create a boxed value, `is_box()` to test for a boxed value, and
  `unbox()` to unbox it. `new_box()` and `is_box()` accept optional
  subclass.

* The vector constructors such as `new_integer()`,
  `new_double_along()` etc gain a `names` argument. In the case of the
  `_along` family it defaults to the names of the input vector.


## Bugfixes

* When nested quosures are evaluated with `eval_tidy()`, the `.env`
  pronoun now correctly refers to the current quosure under evaluation
  (#174). Previously it would always refer to the environment of the
  outermost quosure.

* `as_pairlist()` (part of the experimental API) now supports `NULL`
  and objects of type pairlist (#397).

* Fixed a performance bug in `set_names()` that caused a full copy of
  the vector names (@jimhester, #366).


## API changes

The rlang API is maturing and still in flux. However we have made an
effort to better communicate what parts are stable. We will not
introduce breaking changes for stable functions unless the payoff for
the change is worth the trouble. See `?rlang::lifecycle` for the
lifecycle status of exported functions.

* The particle "lang" has been renamed to "call":

    - `lang()` has been renamed to `call2()`.
    - `new_language()` has ben renamed to `new_call()`.
    - `is_lang()` has been renamed to `is_call()`. We haven't replaced
      the `is_unary_lang()` and `is_binary_lang()` because they are
      redundant with the `n` argument of `is_call()`.
    - All call accessors such as `lang_fn()`, `lang_name()`,
      `lang_args()` etc are soft-deprecated and renamed with `call_`
      prefix.

  In rlang 0.1 calls were called "language" objects in order to follow
  the R type nomenclature as returned by `base::typeof()`. We wanted
  to avoid adding to the confusion between S modes and R types. With
  hindsight we find it is better to use more meaningful type names.

* We now use the term "data mask" instead of "overscope". We think
  data mask is a more natural name in the context of R. We say that
  that objects from user data mask objects in the current environment.
  This makes reference to object masking in the search path which is
  due to the same mechanism (in technical terms, lexical scoping with
  hierarchically nested environments).

  Following this new terminology, the new functions `as_data_mask()`
  and `new_data_mask()` replace `as_overscope()` and
  `new_overscope()`. `as_data_mask()` has also a more consistent
  interface. These functions are only meant for developers of tidy
  evaluation interfaces.

* We no longer require a data mask (previously called overscope) to be
  cleaned up after evaluation. `overscope_clean()` is thus
  soft-deprecated without replacement.


### Breaking changes

* `!!` now binds tightly in order to match intuitive parsing of tidy
  eval code, e.g. `!! x > y` is now equivalent to `(!! x) > y`.  A
  corollary of this new syntax is that you now have to be explicit
  when you want to unquote the whole expression on the right of `!!`.
  For instance you have to explicitly write `!! (x > y)` to unquote
  `x > y` rather than just `x`.

* `UQ()`, `UQS()` and `:=` now issue an error when called
  directly. The previous definitions caused surprising results when
  the operators were invoked in wrong places (i.e. not in quasiquoted
  arguments).

* The prefix form `` `!!`() `` is now an alias to `!!` rather than
  `UQE()`. This makes it more in line with regular R syntax where
  operators are parsed as regular calls, e.g. `a + b` is parsed as ``
  `+`(a, b) `` and both forms are completely equivalent. Also the
  prefix form `` `!!!`() `` is now equivalent to `!!!`.

* `UQE()` is now deprecated in order to simplify the syntax of
  quasiquotation. Please use `!! get_expr(x)` instead.

* `expr_interp()` now returns a formula instead of a quosure when
  supplied a formula.

* `is_quosureish()` and `as_quosureish()` are deprecated. These
  functions assumed that quosures are formulas but that is only an
  implementation detail.

* `new_cnd()` is now `cnd()` for consistency with other constructors.
  Also, `cnd_error()`, `cnd_warning()` and `cnd_message()` are now
  `error_cnd()`, `warning_cnd()` and `message_cnd()` to follow our
  naming scheme according to which the type of output is a suffix
  rather than a prefix.

* `is_node()` now returns `TRUE` for calls as well and `is_pairlist()`
  does not return `TRUE` for `NULL` objects. Use `is_node_list()` to
  determine whether an object either of type `pairlist` or `NULL`.
  Note that all these functions are still experimental.

* `set_names()` no longer automatically splices lists of character
  vectors as we are moving away from automatic splicing semantics.


### Upcoming breaking changes

* Calling the functional forms of unquote operators with the rlang
  namespace qualifier is soft-deprecated. `UQ()` and `UQS()` are not
  function calls so it does not make sense to namespace them.
  Supporting namespace qualifiers complicates the implementation of
  unquotation and is misleading as to the nature of unquoting (which
  are syntactic operators at quotation-time rather than function calls
  at evaluation-time).

* We are now questioning `UQ()` and `UQS()` as functional forms of
  `!!`.  If `!!` and `!!!` were native R operators, they would parse
  to the functional calls `` `!!`() `` and `` `!!!`() ``. This is now
  the preferred way to unquote with a function call rather than with
  the operators. We haven't decided yet whether we will deprecate
  `UQ()` and `UQS()` in the future. In any case we recommend using the
  new functional forms.

* `parse_quosure()` and `parse_quosures()` are soft-deprecated in
  favour of `parse_quo()` and `parse_quos()`. These new names are
  consistent with the rule that abbreviated suffixes indicate the
  return type of a function. In addition the new functions require their
  callers to explicitly supply an environment for the quosures.

* Using `f_rhs()` and `f_env()` on quosures is soft-deprecated. The
  fact that quosures are formulas is an implementation detail that
  might change in the future. Please use `quo_get_expr()` and
  `quo_get_env()` instead.

* `quo_expr()` is soft-deprecated in favour of `quo_squash()`.
  `quo_expr()` was a misnomer because it implied that it was a mere
  expression acccessor for quosures whereas it was really a lossy
  operation that squashed all nested quosures.

* With the renaming of the `lang` particle to `call`, all these
  functions are soft-deprecated: `lang()`, `is_lang()`, `lang_fn()`,
  `lang_name()`, `lang_args()`.

  In addition, `lang_head()` and `lang_tail()` are soft-deprecated
  without replacement because these are low level accessors that are
  rarely needed.

* `as_overscope()` is soft-deprecated in favour of `as_data_mask()`.

* The node setters were renamed from `mut_node_` prefix to
  `node_poke_`. This change follows a new naming convention in rlang
  where mutation is referred to as "poking".

* `splice()` is now in questioning stage as it is not needed given the
  `!!!` operator works in functions taking dots with `dots_list()`.

* `lgl_len()`, `int_len()` etc have been soft-deprecated and renamed
  with `new_` prefix, e.g. `new_logical()` and `new_integer()`. This
  is for consistency with other non-variadic object constructors.

* `ll()` is now an alias to `list2()`. This is consistent with the new
  `call2()` constructor for calls. `list2()` and `call2()` are
  versions of `list()` and `call()` that support splicing of lists
  with `!!!`. `ll()` remains around as a shorthand for users who like
  its conciseness.

* Automatic splicing of lists in vector constructors (e.g. `lgl()`,
  `chr()`, etc) is now soft-deprecated. Please be explicit with the
  splicing operator `!!!`.


# rlang 0.1.6

* This is a maintenance release in anticipation of a forthcoming
  change to R's C API (use `MARK_NOT_MUTABLE()` instead of
  `SET_NAMED()`).

* New function `is_reference()` to check whether two objects are one
  and the same.


# rlang 0.1.4

* `eval_tidy()` no longer maps over lists but returns them literally.
  This behaviour is an overlook from past refactorings and was never
  documented.


# rlang 0.1.2

This hotfix release makes rlang compatible with the R 3.1 branch.


# rlang 0.1.1

This release includes two important fixes for tidy evaluation:

* Bare formulas are now evaluated in the correct environment in
  tidyeval functions.

* `enquo()` now works properly within compiled functions. Before this
  release, constants optimised by the bytecode compiler couldn't be
  enquoted.


## New functions:

* The `new_environment()` constructor creates a child of the empty
  environment and takes an optional named list of data to populate it.
  Compared to `env()` and `child_env()`, it is meant to create
  environments as data structures rather than as part of a scope
  hierarchy.

* The `new_call()` constructor creates calls out of a callable
  object (a function or an expression) and a pairlist of arguments. It
  is useful to avoid costly internal coercions between lists and
  pairlists of arguments.


## UI improvements:

* `env_child()`'s first argument is now `.parent` instead of `parent`.

* `mut_` setters like `mut_attrs()` and environment helpers like
  `env_bind()` and `env_unbind()` now return their (modified) input
  invisibly. This follows the tidyverse convention that functions
  called primarily for their side effects should return their input
  invisibly.

* `is_pairlist()` now returns `TRUE` for `NULL`. We added `is_node()`
  to test for actual pairlist nodes. In other words, `is_pairlist()`
  tests for the data structure while `is_node()` tests for the type.


## Bugfixes:

* `env()` and `env_child()` can now get arguments whose names start
  with `.`.  Prior to this fix, these arguments were partial-matching
  on `env_bind()`'s `.env` argument.

* The internal `replace_na()` symbol was renamed to avoid a collision
  with an exported function in tidyverse. This solves an issue
  occurring in old versions of R prior to 3.3.2 (#133).


# rlang 0.1.0

Initial release.
