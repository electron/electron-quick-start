# `recipes` 0.1.2

## General Changes:

* Edwin Thoen suggested [adding validation checks](https://github.com/topepo/recipes/pull/104) for certain data characteristics. This fed into the existing notion of expanding `recipes` beyond steps (see the [non-step steps project](https://github.com/topepo/recipes/projects)). A new set of operations, called **`checks`**, can now be used. These should throw an informative error when the check conditions are not met and return the existing data otherwise. 

* Steps now have a `skip` option that will not apply preprocessing when `bake` is used. See the article [on skipping steps](https://topepo.github.io/recipes/articles/Skipping.html) for more information. 


## New Operations:

 * `check_missing` will validate that none of the specified variables contain missing data. 
 * `step_num2factor` can be used to convert numeric data (especially integers) to factors. 
 * `step_novel` adds a new factor level to nominal variables that will be used when new data contain a level that did not exist when the recipe was prepared. 
 * `step_profile` can be used to generate design matrix grids for prediction profile plots of additive models where one variable is varied over a grid and all of the others are fixed at a single value. 
 * `step_downsample` and `step_upsample` can be used to change the number of rows in the data based on the frequency distributions of a factor variable in the training set. By default, this operation is only applied to the training set; `bake` ignores this operation. 

## Other Changes:

* `step_spatialsign` now has the option of removing missing data prior to computing the norm.


# `recipes` 0.1.1

* The default selectors for `bake` was changed from `all_predictors()` to `everything()`. 
* The `verbose` option for `prep` is now defaulted to `FALSE`
* [A bug in `step_dummy`](https://github.com/topepo/recipes/issues/83) was fixed that makes sure that the correct binary variables are generated despite the levels or values of the incoming factor. Also, `step_dummy` now requires factor inputs.
* `step_dummy` also has a new default naming function that works better for factors. However, there is an extra argument (`ordinal`) now to the functions that can be passed to `step_dummy`.  
* `step_interact` now allows for selectors (e.g. `all_predictors()` or `starts_with("prefix")` to be used in the interaction formula. 
* `step_YeoJohnson` gained an `na.rm` option.
* [`dplyr::one_of`](https://github.com/topepo/recipes/issues/85) was added to the list of selectors.
* `step_bs` adds B-spline basis functions. 
* `step_unorder` converts ordered factors to unordered factors. 
* `step_count` counts the number of instances that a pattern exists in a string. 
* `step_string2factor` and `step_factor2string` can be used to move between encodings. 
* `step_lowerimpute` is for numeric data where the values cannot be measured below a specific value. For these cases, random uniform values are used for the truncated values.  
* A step to remove simple zero-variance variables was added (`step_zv`).
* A series of `tidy` methods were added for recipes and many (but not all) steps. 
* In `bake.recipe`, the argument `newdata` is now without a default. 
* `bake` and `juice` can now save the _final_ processed data set in [sparse format](https://github.com/topepo/recipes/issues/49). Note that, as the steps are processed, a non-sparse data frame is used to store the results. 
* A formula method was added for recipes to get a formula with the outcome(s) and predictors based on the trained recipe. 

# `recipes` 0.1.0

First CRAN release. 

* Changed `prepare` to `prep` per [issue #59](https://github.com/topepo/recipes/issues/59)

# `recipes` 0.0.1.9003

 * Two of the main functions [changed names](https://github.com/topepo/recipes/issues/57). `learn` has become `prepare` and `process` has become `bake`


# `recipes` 0.0.1.9002

New steps:

  * `step_lincomb` removes variables involved in linear combinations to resolve them. 
  * A step for converting binary variables to factors (`step_bin2factor`)
  *  `step_regex` applies a regular expression to a character or factor vector to create dummy variables. 

Other changes: 

* `step_dummy` and `step_interact` do a better job of respecting missing values in the data set. 


# `recipes` 0.0.1.9001

* The class system for `recipe` objects was changed so that [pipes can be used to create the recipe with a formula](https://github.com/topepo/recipes/issues/46).
* `process.recipe` lost the `role` argument in factor of a general set of [selectors](https://topepo.github.io/recipes/articles/Selecting_Variables.html). If no selector is used, all the predictors are returned. 
* Two steps for simple imputation using the mean or mode were added. 
