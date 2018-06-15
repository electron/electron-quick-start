
# tidyselect 0.2.4

* Fixed a warning that occurred when a vector of column positions was
  supplied to `vars_select()` or functions depending on it such as
  `tidyr::gather()` (#43 and tidyverse/tidyr#374).

* Fixed compatibility issue with rlang 0.2.0 (#51).


# tidyselect 0.2.3

* Internal fixes in prevision of using `tidyselect` within `dplyr`.

* `vars_select()` and `vars_rename()` now correctly support unquoting
  character vectors that have names.

* `vars_select()` now ignores missing variables.


# tidyselect 0.2.2

* `dplyr` is now correctly mentioned as suggested package.


# tidyselect 0.2.1

* `-` now supports character vectors in addition to strings. This
  makes it easy to unquote column names to exclude from the set:

  ```{r}
  vars <- c("cyl", "am", "disp", "drat")
  vars_select(names(mtcars), - (!! vars))
  ```

* `last_col()` now issues an error when the variable vector is empty.

* `last_col()` now returns column positions rather than column names
  for consistency with other helpers. This also makes it compatible
  with functions like `seq()`.

* `c()` now supports character vectors the same way as `-` and `seq()`.
  (#37 @gergness)


# tidyselect 0.2.0

The main point of this release is to revert a troublesome behaviour
introduced in tidyselect 0.1.0. It also includes a few features.


## Evaluation rules

The special evaluation semantics for selection have been changed
back to the old behaviour because the new rules were causing too
much trouble and confusion. From now on data expressions (symbols
and calls to `:` and `c()`) can refer to both registered variables
and to objects from the context.

However the semantics for context expressions (any calls other than
to `:` and `c()`) remain the same. Those expressions are evaluated
in the context only and cannot refer to registered variables.

If you're writing functions and refer to contextual objects, it is
still a good idea to avoid data expressions. Since registered
variables are change as a function of user input and you never know
if your local objects might be shadowed by a variable. Consider:

```
n <- 2
vars_select(letters, 1:n)
```

Should that select up to the second element of `letters` or up to
the 14th? Since the variables have precedence in a data expression,
this will select the 14 first letters. This can be made more robust
by turning the data expression into a context expression:

```
vars_select(letters, seq(1, n))
```

You can also use quasiquotation since unquoted arguments are
guaranteed to be evaluated without any user data in scope. While
equivalent because of the special rules for context expressions,
this may be clearer to the reader accustomed to tidy eval:

```{r}
vars_select(letters, seq(1, !! n))
```

Finally, you may want to be more explicit in the opposite direction.
If you expect a variable to be found in the data but not in the
context, you can use the `.data` pronoun:

```{r}
vars_select(names(mtcars), .data$cyl : .data$drat)
```

## New features

* The new select helper `last_col()` is helpful to select over a
  custom range: `vars_select(vars, 3:last_col())`.

* `:` and `-` now handle strings as well. This makes it easy to
  unquote a column name: `(!! name) : last_col()` or `-(!! name)`.

* `vars_select()` gains a `.strict` argument similar to
  `rename_vars()`.  If set to `FALSE`, errors about unknown variables
  are ignored.

* `vars_select()` now treats `NULL` as empty inputs. This follows a
  trend in the tidyverse tools.

* `vars_rename()` now handles variable positions (integers or round
  doubles) just like `vars_select()` (#20).

* `vars_rename()` is now implemented with the tidy eval framework.
  Like `vars_select()`, expressions are evaluated without any user
  data in scope. In addition a variable context is now established so
  you can write rename helpers. Those should return a single round
  number or a string (variable position or variable name).

* `has_vars()` is a predicate that tests whether a variable context
  has been set (#21).

* The selection helpers are now exported in a list
  `vars_select_helpers`.  This is intended for APIs that embed the
  helpers in the evaluation environment.


## Fixes

* `one_of()` argument `vars` has been renamed to `.vars` to avoid
  spurious matching.


# tidyselect 0.1.1

tidyselect is the new home for the legacy functions
`dplyr::select_vars()`, `dplyr::rename_vars()` and
`dplyr::select_var()`.


## API changes

We took this opportunity to make a few changes to the API:

* `select_vars()` and `rename_vars()` are now `vars_select()` and
  `vars_rename()`. This follows the tidyverse convention that a prefix
  corresponds to the input type while suffixes indicate the output
  type. Similarly, `select_var()` is now `vars_pull()`.

* The arguments are now prefixed with dots to limit argument matching
  issues. While the dots help, it is still a good idea to splice a
  list of captured quosures to make sure dotted arguments are never
  matched to `vars_select()`'s named arguments:

  ```
  vars_select(vars, !!! quos(...))
  ```

* Error messages can now be customised. For consistency with dplyr,
  error messages refer to "columns" by default. This assumes that the
  variables being selected come from a data frame. If this is not
  appropriate for your DSL, you can now add an attribute `vars_type`
  to the `.vars` vector to specify alternative names. This must be a
  character vector of length 2 whose first component is the singular
  form and the second is the plural. For example, `c("variable",
  "variables")`.


## Establishing a variable context

tidyselect provides a few more ways of establishing a variable
context:

* `scoped_vars()` sets up a variable context along with an an exit
  hook that automatically restores the previous variables. It is the
  preferred way of changing the variable context.

  `with_vars()` takes variables and an expression and evaluates the
  latter in the context of the former.

* `poke_vars()` establishes a new variable context. It returns the
  previous context invisibly and it is your responsibility to restore
  it after you are done. This is for expert use only.

  `current_vars()` has been renamed to `peek_vars()`. This naming is a
  reference to [peek and poke](https://en.wikipedia.org/wiki/PEEK_and_POKE)
  from legacy languages.


## New evaluation semantics

The evaluation semantics for selecting verbs have changed. Symbols are
now evaluated in a data-only context that is isolated from the calling
environment. This means that you can no longer refer to local variables
unless you are explicitly unquoting these variables with `!!`, which
is mostly for expert use.

Note that since dplyr 0.7, helper calls (like `starts_with()`) obey
the opposite behaviour and are evaluated in the calling context
isolated from the data context. To sum up, symbols can only refer to
data frame objects, while helpers can only refer to contextual
objects. This differs from usual R evaluation semantics where both
the data and the calling environment are in scope (with the former
prevailing over the latter).
