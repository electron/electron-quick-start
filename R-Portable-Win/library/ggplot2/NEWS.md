# ggplot2 3.2.0

This is a minor release with an emphasis on internal changes to make ggplot2 
faster and more consistent. The few interface changes will only affect the 
aesthetics of the plot in minor ways, and will only potentially break code of
extension developers if they have relied on internals that have been changed. 
This release also sees the addition of Hiroaki Yutani (@yutannihilation) to the 
core developer team.

With the release of R 3.6, ggplot2 now requires the R version to be at least 3.2,
as the tidyverse is committed to support 5 major versions of R.

## Breaking changes

* Two patches (#2996 and #3050) fixed minor rendering problems. In most cases,
  the visual changes are so subtle that they are difficult to see with the naked
  eye. However, these changes are detected by the vdiffr package, and therefore
  any package developers who use vdiffr to test for visual correctness of ggplot2
  plots will have to regenerate all reference images.
  
* In some cases, ggplot2 now produces a warning or an error for code that previously
  produced plot output. In all these cases, the previous plot output was accidental,
  and the plotting code uses the ggplot2 API in a way that would lead to undefined
  behavior. Examples include a missing `group` aesthetic in `geom_boxplot()` (#3316),
  annotations across multiple facets (#3305), and not using aesthetic mappings when
  drawing ribbons with `geom_ribbon()` (#3318).

## New features

* This release includes a range of internal changes that speeds up plot 
  generation. None of the changes are user facing and will not break any code,
  but in general ggplot2 should feel much faster. The changes includes, but are
  not limited to:
  
  - Caching ascent and descent dimensions of text to avoid recalculating it for
    every title.
  
  - Using a faster data.frame constructor as well as faster indexing into 
    data.frames
    
  - Removing the plyr dependency, replacing plyr functions with faster 
    equivalents.

* `geom_polygon()` can now draw polygons with holes using the new `subgroup` 
  aesthetic. This functionality requires R 3.6.0 (@thomasp85, #3128)

* Aesthetic mappings now accept functions that return `NULL` (@yutannihilation,
  #2997).

* `stat_function()` now accepts rlang/purrr style anonymous functions for the 
  `fun` parameter (@dkahle, #3159).

* `geom_rug()` gains an "outside" option to allow for moving the rug tassels to 
  outside the plot area (@njtierney, #3085) and a `length` option to allow for 
  changing the length of the rug lines (@daniel-wells, #3109). 
  
* All geoms now take a `key_glyph` paramter that allows users to customize
  how legend keys are drawn (@clauswilke, #3145). In addition, a new key glyph
  `timeseries` is provided to draw nice legends for time series
  (@mitchelloharawild, #3145).

## Extensions

* Layers now have a new member function `setup_layer()` which is called at the
  very beginning of the plot building process and which has access to the 
  original input data and the plot object being built. This function allows the 
  creation of custom layers that autogenerate aesthetic mappings based on the 
  input data or that filter the input data in some form. For the time being, this
  feature is not exported, but it has enabled the development of a new layer type,
  `layer_sf()` (see next item). Other special-purpose layer types may be added
  in the future (@clauswilke, #2872).
  
* A new layer type `layer_sf()` can auto-detect and auto-map sf geometry
  columns in the data. It should be used by extension developers who are writing
  new sf-based geoms or stats (@clauswilke, #3232).

* `x0` and `y0` are now recognized positional aesthetics so they will get scaled 
  if used in extension geoms and stats (@thomasp85, #3168)
  
* Continuous scale limits now accept functions which accept the default
  limits and return adjusted limits. This makes it possible to write
  a function that e.g. ensures the limits are always a multiple of 100,
  regardless of the data (@econandrew, #2307).

## Minor improvements and bug fixes

* `cut_width()` now accepts `...` to pass further arguments to `base::cut.default()`
   like `cut_number()` and `cut_interval()` already did (@cderv, #3055)

* `coord_map()` now can have axes on the top and right (@karawoo, #3042).

* `coord_polar()` now correctly rescales the secondary axis (@linzi-sg, #3278)

* `coord_sf()`, `coord_map()`, and `coord_polar()` now squash `-Inf` and `Inf`
  into the min and max of the plot (@yutannihilation, #2972).

* `coord_sf()` graticule lines are now drawn in the same thickness as panel grid 
  lines in `coord_cartesian()`, and seting panel grid lines to `element_blank()` 
  now also works in `coord_sf()` 
  (@clauswilke, #2991, #2525).

* `economics` data has been regenerated. This leads to some changes in the
  values of all columns (especially in `psavert`), but more importantly, strips 
  the grouping attributes from `economics_long`.

* `element_line()` now fills closed arrows (@yutannihilation, #2924).

* Facet strips on the left side of plots now have clipping turned on, preventing
  text from running out of the strip and borders from looking thicker than for
  other strips (@karawoo, #2772 and #3061).

* ggplot2 now works in Turkish locale (@yutannihilation, #3011).

* Clearer error messages for inappropriate aesthetics (@clairemcwhite, #3060).

* ggplot2 no longer attaches any external packages when using functions that 
  depend on packages that are suggested but not imported by ggplot2. The 
  affected functions include `geom_hex()`, `stat_binhex()`, 
  `stat_summary_hex()`, `geom_quantile()`, `stat_quantile()`, and `map_data()` 
  (@clauswilke, #3126).
  
* `geom_area()` and `geom_ribbon()` now sort the data along the x-axis in the 
  `setup_data()` method rather than as part of `draw_group()` (@thomasp85, 
  #3023)

* `geom_hline()`, `geom_vline()`, and `geom_abline()` now throw a warning if the 
  user supplies both an `xintercept`, `yintercept`, or `slope` value and a 
  mapping (@RichardJActon, #2950).

* `geom_rug()` now works with `coord_flip()` (@has2k1, #2987).

* `geom_violin()` no longer throws an error when quantile lines fall outside 
  the violin polygon (@thomasp85, #3254).

* `guide_legend()` and `guide_colorbar()` now use appropriate spacing between legend
  key glyphs and legend text even if the legend title is missing (@clauswilke, #2943).

* Default labels are now generated more consistently; e.g., symbols no longer
  get backticks, and long expressions are abbreviated with `...`
  (@yutannihilation, #2981).

* All-`Inf` layers are now ignored for picking the scale (@yutannihilation, 
  #3184).
  
* Diverging Brewer colour palette now use the correct mid-point colour 
  (@dariyasydykova, #3072).
  
* `scale_color_continuous()` now points to `scale_colour_continuous()` so that 
  it will handle `type = "viridis"` as the documentation states (@hlendway, 
  #3079).

* `scale_shape_identity()` now works correctly with `guide = "legend"` 
  (@malcolmbarrett, #3029)
  
* `scale_continuous` will now draw axis line even if the length of breaks is 0
  (@thomasp85, #3257)

* `stat_bin()` will now error when the number of bins exceeds 1e6 to avoid 
  accidentally freezing the user session (@thomasp85).
  
* `sec_axis()` now places ticks accurately when using nonlinear transformations (@dpseidel, #2978).

* `facet_wrap()` and `facet_grid()` now automatically remove NULL from facet
  specs, and accept empty specs (@yutannihilation, #3070, #2986).

* `stat_bin()` now handles data with only one unique value (@yutannihilation 
  #3047).

* `sec_axis()` now accepts functions as well as formulas (@yutannihilation, #3031).

*   New theme elements allowing different ticks lengths for each axis. For instance,
    this can be used to have inwards ticks on the x-axis (`axis.ticks.length.x`) and
    outwards ticks on the y-axis (`axis.ticks.length.y`) (@pank, #2935).

* The arguments of `Stat*$compute_layer()` and `Position*$compute_layer()` are
  now renamed to always match the ones of `Stat$compute_layer()` and
  `Position$compute_layer()` (@yutannihilation, #3202).

* `geom_*()` and `stat_*()` now accepts purrr-style lambda notation
  (@yutannihilation, #3138).

* `geom_tile()` and `geom_rect()` now draw rectangles without notches at the
  corners. The style of the corner can be controlled by `linejoin` parameters
  (@yutannihilation, #3050).

# ggplot2 3.1.0

## Breaking changes

This is a minor release and breaking changes have been kept to a minimum. End users of ggplot2 are unlikely to encounter any issues. However, there are a few items that developers of ggplot2 extensions should be aware of. For additional details, see also the discussion accompanying issue #2890.

*   In non-user-facing internal code (specifically in the `aes()` function and in
    the `aesthetics` argument of scale functions), ggplot2 now always uses the British
    spelling for aesthetics containing the word "colour". When users specify a "color"
    aesthetic it is automatically renamed to "colour". This renaming is also applied
    to non-standard aesthetics that contain the word "color". For example, "point_color"
    is renamed to "point_colour". This convention makes it easier to support both
    British and American spelling for novel, non-standard aesthetics, but it may require
    some adjustment for packages that have previously introduced non-standard color
    aesthetics using American spelling. A new function `standardise_aes_names()` is
    provided in case extension writers need to perform this renaming in their own code
    (@clauswilke, #2649).

*   Functions that generate other functions (closures) now force the arguments that are
    used from the generated functions, to avoid hard-to-catch errors. This may affect
    some users of manual scales (such as `scale_colour_manual()`, `scale_fill_manual()`,
    etc.) who depend on incorrect behavior (@krlmlr, #2807).
    
*   `Coord` objects now have a function `backtransform_range()` that returns the
    panel range in data coordinates. This change may affect developers of custom coords,
    who now should implement this function. It may also affect developers of custom
    geoms that use the `range()` function. In some applications, `backtransform_range()`
    may be more appropriate (@clauswilke, #2821).


## New features

*   `coord_sf()` has much improved customization of axis tick labels. Labels can now
    be set manually, and there are two new parameters, `label_graticule` and
    `label_axes`, that can be used to specify which graticules to label on which side
    of the plot (@clauswilke, #2846, #2857, #2881).
    
*   Two new geoms `geom_sf_label()` and `geom_sf_text()` can draw labels and text
    on sf objects. Under the hood, a new `stat_sf_coordinates()` calculates the
    x and y coordinates from the coordinates of the sf geometries. You can customize
    the calculation method via `fun.geometry` argument (@yutannihilation, #2761).
    

## Minor improvements and fixes

*   `benchplot()` now uses tidy evaluation (@dpseidel, #2699).

*   The error message in `compute_aesthetics()` now only provides the names of
    aesthetics with mismatched lengths, rather than all aesthetics (@karawoo,
    #2853).

*   For faceted plots, data is no longer internally reordered. This makes it
    safer to feed data columns into `aes()` or into parameters of geoms or
    stats. However, doing so remains discouraged (@clauswilke, #2694).

*   `coord_sf()` now also understands the `clip` argument, just like the other
    coords (@clauswilke, #2938).

*   `fortify()` now displays a more informative error message for
    `grouped_df()` objects when dplyr is not installed (@jimhester, #2822).

*   All `geom_*()` now display an informative error message when required 
    aesthetics are missing (@dpseidel, #2637 and #2706).

*   `geom_boxplot()` now understands the `width` parameter even when used with
    a non-standard stat, such as `stat_identity()` (@clauswilke, #2893).
    
*  `geom_hex()` now understands the `size` and `linetype` aesthetics
   (@mikmart, #2488).
    
*   `geom_hline()`, `geom_vline()`, and `geom_abline()` now work properly
    with `coord_trans()` (@clauswilke, #2149, #2812).
    
*   `geom_text(..., parse = TRUE)` now correctly renders the expected number of
    items instead of silently dropping items that are empty expressions, e.g.
    the empty string "". If an expression spans multiple lines, we take just
    the first line and drop the rest. This same issue is also fixed for
    `geom_label()` and the axis labels for `geom_sf()` (@slowkow, #2867).

*   `geom_sf()` now respects `lineend`, `linejoin`, and `linemitre` parameters 
    for lines and polygons (@alistaire47, #2826).
    
*   `ggsave()` now exits without creating a new graphics device if previously
    none was open (@clauswilke, #2363).

*   `labs()` now has named arguments `title`, `subtitle`, `caption`, and `tag`.
    Also, `labs()` now accepts tidyeval (@yutannihilation, #2669).

*   `position_nudge()` is now more robust and nudges only in the direction
    requested. This enables, for example, the horizontal nudging of boxplots
    (@clauswilke, #2733).

*   `sec_axis()` and `dup_axis()` now return appropriate breaks for the secondary
    axis when applied to log transformed scales (@dpseidel, #2729).

*   `sec_axis()` now works as expected when used in combination with tidy eval
    (@dpseidel, #2788).

*   `scale_*_date()`, `scale_*_time()` and `scale_*_datetime()` can now display 
    a secondary axis that is a __one-to-one__ transformation of the primary axis,
    implemented using the `sec.axis` argument to the scale constructor 
    (@dpseidel, #2244).
    
*   `stat_contour()`, `stat_density2d()`, `stat_bin2d()`,  `stat_binhex()`
    now calculate normalized statistics including `nlevel`, `ndensity`, and
    `ncount`. Also, `stat_density()` now includes the calculated statistic 
    `nlevel`, an alias for `scaled`, to better match the syntax of `stat_bin()`
    (@bjreisman, #2679).

# ggplot2 3.0.0

## Breaking changes

*   ggplot2 now supports/uses tidy evaluation (as described below). This is a 
    major change and breaks a number of packages; we made this breaking change 
    because it is important to make ggplot2 more programmable, and to be more 
    consistent with the rest of the tidyverse. The best general (and detailed)
    introduction to tidy evaluation can be found in the meta programming
    chapters in [Advanced R](https://adv-r.hadley.nz).
    
    The primary developer facing change is that `aes()` now contains 
    quosures (expression + environment pairs) rather than symbols, and you'll 
    need to take a different approach to extracting the information you need. 
    A common symptom of this change are errors "undefined columns selected" or 
    "invalid 'type' (list) of argument" (#2610). As in the previous version,
    constants (like `aes(x = 1)` or `aes(colour = "smoothed")`) are stored
    as is.
    
    In this version of ggplot2, if you need to describe a mapping in a string, 
    use `quo_name()` (to generate single-line strings; longer expressions may 
    be abbreviated) or `quo_text()` (to generate non-abbreviated strings that
    may span multiple lines). If you do need to extract the value of a variable
    instead use `rlang::eval_tidy()`. You may want to condition on 
    `(packageVersion("ggplot2") <= "2.2.1")` so that your code can work with
    both released and development versions of ggplot2.
    
    We recognise that this is a big change and if you're not already familiar
    with rlang, there's a lot to learn. If you are stuck, or need any help,
    please reach out on <https://community.rstudio.com>.

*   Error: Column `y` must be a 1d atomic vector or a list

    Internally, ggplot2 now uses `as.data.frame(tibble::as_tibble(x))` to
    convert a list into a data frame. This improves ggplot2's support for
    list-columns (needed for sf support), at a small cost: you can no longer
    use matrix-columns. Note that unlike tibble we still allow column vectors
    such as returned by `base::scale()` because of their widespread use.

*   Error: More than one expression parsed
  
    Previously `aes_string(x = c("a", "b", "c"))` silently returned 
    `aes(x = a)`. Now this is a clear error.

*   Error: `data` must be uniquely named but has duplicate columns
  
    If layer data contains columns with identical names an error will be 
    thrown. In earlier versions the first occuring column was chosen silently,
    potentially masking that the wrong data was chosen.

*   Error: Aesthetics must be either length 1 or the same as the data
    
    Layers are stricter about the columns they will combine into a single
    data frame. Each aesthetic now must be either the same length as the data
    frame or a single value. This makes silent recycling errors much less likely.

*   Error: `coord_*` doesn't support free scales 
   
    Free scales only work with selected coordinate systems; previously you'd
    get an incorrect plot.

*   Error in f(...) : unused argument (range = c(0, 1))

    This is because the `oob` argument to scale has been set to a function
    that only takes a single argument; it needs to take two arguments
    (`x`, and `range`). 

*   Error: unused argument (output)
  
    The function `guide_train()` now has an optional parameter `aesthetic`
    that allows you to override the `aesthetic` setting in the scale.
    To make your code work with the both released and development versions of 
    ggplot2 appropriate, add `aesthetic = NULL` to the `guide_train()` method
    signature.
    
    ```R
    # old
    guide_train.legend <- function(guide, scale) {...}
    
    # new 
    guide_train.legend <- function(guide, scale, aesthetic = NULL) {...}
    ```
    
    Then, inside the function, replace `scale$aesthetics[1]`,
    `aesthetic %||% scale$aesthetics[1]`. (The %||% operator is defined in the 
    rlang package).
    
    ```R
    # old
    setNames(list(scale$map(breaks)), scale$aesthetics[1])

    # new
    setNames(list(scale$map(breaks)), aesthetic %||% scale$aesthetics[1])
    ```

*   The long-deprecated `subset` argument to `layer()` has been removed.

## Tidy evaluation

* `aes()` now supports quasiquotation so that you can use `!!`, `!!!`,
  and `:=`. This replaces `aes_()` and `aes_string()` which are now
  soft-deprecated (but will remain around for a long time).

* `facet_wrap()` and `facet_grid()` now support `vars()` inputs. Like
  `dplyr::vars()`, this helper quotes its inputs and supports
  quasiquotation. For instance, you can now supply faceting variables
  like this: `facet_wrap(vars(am, cyl))` instead of 
  `facet_wrap(~am + cyl)`. Note that the formula interface is not going 
  away and will not be deprecated. `vars()` is simply meant to make it 
  easier to create functions around `facet_wrap()` and `facet_grid()`.

  The first two arguments of `facet_grid()` become `rows` and `cols`
  and now support `vars()` inputs. Note however that we took special
  care to ensure complete backward compatibility. With this change
  `facet_grid(vars(cyl), vars(am, vs))` is equivalent to
  `facet_grid(cyl ~ am + vs)`, and `facet_grid(cols = vars(am, vs))` is
  equivalent to `facet_grid(. ~ am + vs)`.

  One nice aspect of the new interface is that you can now easily
  supply names: `facet_grid(vars(Cylinder = cyl), labeller =
  label_both)` will give nice label titles to the facets. Of course,
  those names can be unquoted with the usual tidy eval syntax.

### sf

* ggplot2 now has full support for sf with `geom_sf()` and `coord_sf()`:

  ```r
  nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
  ggplot(nc) +
    geom_sf(aes(fill = AREA))
  ```
  It supports all simple features, automatically aligns CRS across layers, sets
  up the correct aspect ratio, and draws a graticule.

## New features

* ggplot2 now works on R 3.1 onwards, and uses the 
  [vdiffr](https://github.com/lionel-/vdiffr) package for visual testing.

* In most cases, accidentally using `%>%` instead of `+` will generate an 
  informative error (#2400).

* New syntax for calculated aesthetics. Instead of using `aes(y = ..count..)` 
  you can (and should!) use `aes(y = stat(count))`. `stat()` is a real function 
  with documentation which hopefully will make this part of ggplot2 less 
  confusing (#2059).
  
  `stat()` is particularly nice for more complex calculations because you 
  only need to specify it once: `aes(y = stat(count / max(count)))`,
  rather than `aes(y = ..count.. / max(..count..))`
  
* New `tag` label for adding identification tags to plots, typically used for 
  labelling a subplot with a letter. Add a tag with `labs(tag = "A")`, style it 
  with the `plot.tag` theme element, and control position with the
  `plot.tag.position` theme setting (@thomasp85).

### Layers: geoms, stats, and position adjustments

* `geom_segment()` and `geom_curve()` have a new `arrow.fill` parameter which 
  allows you to specify a separate fill colour for closed arrowheads 
  (@hrbrmstr and @clauswilke, #2375).

* `geom_point()` and friends can now take shapes as strings instead of integers,
  e.g. `geom_point(shape = "diamond")` (@daniel-barnett, #2075).

* `position_dodge()` gains a `preserve` argument that allows you to control
  whether the `total` width at each `x` value is preserved (the current 
  default), or ensure that the width of a `single` element is preserved
  (what many people want) (#1935).

* New `position_dodge2()` provides enhanced dodging for boxplots. Compared to
  `position_dodge()`, `position_dodge2()` compares `xmin` and `xmax` values  
  to determine which elements overlap, and spreads overlapping elements evenly
  within the region of overlap. `position_dodge2()` is now the default position
  adjustment for `geom_boxplot()`, because it handles `varwidth = TRUE`, and 
  will be considered for other geoms in the future.
  
  The `padding` parameter adds a small amount of padding between elements 
  (@karawoo, #2143) and a `reverse` parameter allows you to reverse the order 
  of placement (@karawoo, #2171).
  
* New `stat_qq_line()` makes it easy to add a simple line to a Q-Q plot, which 
  makes it easier to judge the fit of the theoretical distribution 
  (@nicksolomon).

### Scales and guides

* Improved support for mapping date/time variables to `alpha`, `size`, `colour`, 
  and `fill` aesthetics, including `date_breaks` and `date_labels` arguments 
  (@karawoo, #1526), and new `scale_alpha()` variants (@karawoo, #1526).

* Improved support for ordered factors. Ordered factors throw a warning when 
  mapped to shape (unordered factors do not), and do not throw warnings when 
  mapped to size or alpha (unordered factors do). Viridis is used as the 
  default colour and fill scale for ordered factors (@karawoo, #1526).

* The `expand` argument of `scale_*_continuous()` and `scale_*_discrete()`
  now accepts separate expansion values for the lower and upper range
  limits. The expansion limits can be specified using the convenience
  function `expand_scale()`.
  
  Separate expansion limits may be useful for bar charts, e.g. if one
  wants the bottom of the bars to be flush with the x axis but still 
  leave some (automatically calculated amount of) space above them:
  
    ```r
    ggplot(mtcars) +
        geom_bar(aes(x = factor(cyl))) +
        scale_y_continuous(expand = expand_scale(mult = c(0, .1)))
    ```
  
  It can also be useful for line charts, e.g. for counts over time,
  where one wants to have a ’hard’ lower limit of y = 0 but leave the
  upper limit unspecified (and perhaps differing between panels), with
  some extra space above the highest point on the line (with symmetrical 
  limits, the extra space above the highest point could in some cases 
  cause the lower limit to be negative).
  
  The old syntax for the `expand` argument will, of course, continue
  to work (@huftis, #1669).

* `scale_colour_continuous()` and `scale_colour_gradient()` are now controlled 
  by global options `ggplot2.continuous.colour` and `ggplot2.continuous.fill`. 
  These can be set to `"gradient"` (the default) or `"viridis"` (@karawoo).

* New `scale_colour_viridis_c()`/`scale_fill_viridis_c()` (continuous) and
  `scale_colour_viridis_d()`/`scale_fill_viridis_d()` (discrete) make it
  easy to use Viridis colour scales (@karawoo, #1526).

* Guides for `geom_text()` now accept custom labels with 
  `guide_legend(override.aes = list(label = "foo"))` (@brianwdavis, #2458).

### Margins

* Strips gain margins on all sides by default. This means that to fully justify
  text to the edge of a strip, you will need to also set the margins to 0
  (@karawoo).

* Rotated strip labels now correctly understand `hjust` and `vjust` parameters
  at all angles (@karawoo).

* Strip labels now understand justification relative to the direction of the
  text, meaning that in y facets, the strip text can be placed at either end of
  the strip using `hjust` (@karawoo).

* Legend titles and labels get a little extra space around them, which 
  prevents legend titles from overlapping the legend at large font sizes 
  (@karawoo, #1881).

## Extension points

* New `autolayer()` S3 generic (@mitchelloharawild, #1974). This is similar
  to `autoplot()` but produces layers rather than complete plots.

* Custom objects can now be added using `+` if a `ggplot_add` method has been
  defined for the class of the object (@thomasp85).

* Theme elements can now be subclassed. Add a `merge_element` method to control
  how properties are inherited from the parent element. Add an `element_grob` 
  method to define how elements are rendered into grobs (@thomasp85, #1981).

* Coords have gained new extension mechanisms.
  
    If you have an existing coord extension, you will need to revise the
    specification of the `train()` method. It is now called 
    `setup_panel_params()` (better reflecting what it actually does) and now 
    has arguments `scale_x`, and `scale_y` (the x and y scales respectively) 
    and `param`, a list of plot specific parameters generated by 
    `setup_params()`.

    What was formerly called `scale_details` (in coords), `panel_ranges` 
    (in layout) and `panel_scales` (in geoms) are now consistently called
    `panel_params` (#1311). These are parameters of the coord that vary from
    panel to panel.

* `ggplot_build()` and `ggplot_gtable()` are now generics, so ggplot-subclasses 
  can define additional behavior during the build stage.

* `guide_train()`, `guide_merge()`, `guide_geom()`, and `guide_gengrob()`
  are now exported as they are needed if you want to design your own guide.
  They are not currently documented; use at your own risk (#2528).

* `scale_type()` generic is now exported and documented. Use this if you 
  want to extend ggplot2 to work with a new type of vector.

## Minor bug fixes and improvements

### Faceting

* `facet_grid()` gives a more informative error message if you try to use
  a variable in both rows and cols (#1928).

* `facet_grid()` and `facet_wrap()` both give better error messages if you
  attempt to use an unsupported coord with free scales (#2049).

* `label_parsed()` works once again (#2279).

* You can now style the background of horizontal and vertical strips
  independently with `strip.background.x` and `strip.background.y` 
  theme settings (#2249).

### Scales

* `discrete_scale()` documentation now inherits shared definitions from 
  `continuous_scale()` (@alistaire47, #2052).

* `guide_colorbar()` shows all colours of the scale (@has2k1, #2343).

* `scale_identity()` once again produces legends by default (#2112).

* Tick marks for secondary axes with strong transformations are more 
  accurately placed (@thomasp85, #1992).

* Missing line types now reliably generate missing lines (with standard 
  warning) (#2206).

* Legends now ignore set aesthetics that are not length one (#1932).

* All colour and fill scales now have an `aesthetics` argument that can
  be used to set the aesthetic(s) the scale works with. This makes it
  possible to apply a colour scale to both colour and fill aesthetics
  at the same time, via `aesthetics = c("colour", "fill")` (@clauswilke).
  
* Three new generic scales work with any aesthetic or set of aesthetics: 
  `scale_continuous_identity()`, `scale_discrete_identity()`, and
  `scale_discrete_manual()` (@clauswilke).

* `scale_*_gradient2()` now consistently omits points outside limits by 
  rescaling after the limits are enforced (@foo-bar-baz-qux, #2230).

### Layers

* `geom_label()` now correctly produces unbordered labels when `label.size` 
  is 0, even when saving to PDF (@bfgray3, #2407).

* `layer()` gives considerably better error messages for incorrectly specified
  `geom`, `stat`, or `position` (#2401).

* In all layers that use it, `linemitre` now defaults to 10 (instead of 1)
  to better match base R.

* `geom_boxplot()` now supplies a default value if no `x` aesthetic is present
  (@foo-bar-baz-qux, #2110).

* `geom_density()` drops groups with fewer than two data points and throws a
  warning. For groups with two data points, density values are now calculated 
  with `stats::density` (@karawoo, #2127).

* `geom_segment()` now also takes a `linejoin` parameter. This allows more 
  control over the appearance of the segments, which is especially useful for 
  plotting thick arrows (@Ax3man, #774).

* `geom_smooth()` now reports the formula used when `method = "auto"` 
  (@davharris #1951). `geom_smooth()` now orders by the `x` aesthetic, making it 
  easier to pass pre-computed values without manual ordering (@izahn, #2028). It 
  also now knows it has `ymin` and `ymax` aesthetics (#1939). The legend 
  correctly reflects the status of the `se` argument when used with stats 
  other than the default (@clauswilke, #1546).

* `geom_tile()` now once again interprets `width` and `height` correctly 
  (@malcolmbarrett, #2510).

* `position_jitter()` and `position_jitterdodge()` gain a `seed` argument that
  allows the specification of a random seed for reproducible jittering 
  (@krlmlr, #1996 and @slowkow, #2445).

* `stat_density()` has better behaviour if all groups are dropped because they
  are too small (#2282).

* `stat_summary_bin()` now understands the `breaks` parameter (@karawoo, #2214).

* `stat_bin()` now accepts functions for `binwidth`. This allows better binning 
  when faceting along variables with different ranges (@botanize).

* `stat_bin()` and `geom_histogram()` now sum correctly when using the `weight` 
  aesthetic (@jiho, #1921).

* `stat_bin()` again uses correct scaling for the computed variable `ndensity` 
  (@timgoodman, #2324).

* `stat_bin()` and `stat_bin_2d()` now properly handle the `breaks` parameter 
  when the scales are transformed (@has2k1, #2366).

* `update_geom_defaults()` and `update_stat_defaults()` allow American 
  spelling of aesthetic parameters (@foo-bar-baz-qux, #2299).

* The `show.legend` parameter now accepts a named logical vector to hide/show
  only some aesthetics in the legend (@tutuchan, #1798).

* Layers now silently ignore unknown aesthetics with value `NULL` (#1909).

### Coords

* Clipping to the plot panel is now configurable, through a `clip` argument
  to coordinate systems, e.g. `coord_cartesian(clip = "off")` 
  (@clauswilke, #2536).

* Like scales, coordinate systems now give you a message when you're 
  replacing an existing coordinate system (#2264).

* `coord_polar()` now draws secondary axis ticks and labels 
  (@dylan-stark, #2072), and can draw the radius axis on the right 
  (@thomasp85, #2005).

* `coord_trans()` now generates a warning when a transformation generates 
  non-finite values (@foo-bar-baz-qux, #2147).

### Themes

* Complete themes now always override all elements of the default theme
  (@has2k1, #2058, #2079).

* Themes now set default grid colour in `panel.grid` rather than individually
  in `panel.grid.major` and `panel.grid.minor` individually. This makes it 
  slightly easier to customise the theme (#2352).

* Fixed bug when setting strips to `element_blank()` (@thomasp85). 

* Axes positioned on the top and to the right can now customize their ticks and
  lines separately (@thomasp85, #1899).

* Built-in themes gain parameters `base_line_size` and `base_rect_size` which 
  control the default sizes of line and rectangle elements (@karawoo, #2176).

* Default themes use `rel()` to set line widths (@baptiste).

* Themes were tweaked for visual consistency and more graceful behavior when 
  changing the base font size. All absolute heights or widths were replaced 
  with heights or widths that are proportional to the base font size. One 
  relative font size was eliminated (@clauswilke).
  
* The height of descenders is now calculated solely on font metrics and doesn't
  change with the specific letters in the string. This fixes minor alignment 
  issues with plot titles, subtitles, and legend titles (#2288, @clauswilke).

### Guides

* `guide_colorbar()` is more configurable: tick marks and color bar frame
  can now by styled with arguments `ticks.colour`, `ticks.linewidth`, 
  `frame.colour`, `frame.linewidth`, and `frame.linetype`
  (@clauswilke).
  
* `guide_colorbar()` now uses `legend.spacing.x` and `legend.spacing.y` 
  correctly, and it can handle multi-line titles. Minor tweaks were made to 
  `guide_legend()` to make sure the two legend functions behave as similarly as
  possible (@clauswilke, #2397 and #2398).
  
* The theme elements `legend.title` and `legend.text` now respect the settings 
  of `margin`, `hjust`, and `vjust` (@clauswilke, #2465, #1502).

* Non-angle parameters of `label.theme` or `title.theme` can now be set in 
  `guide_legend()` and `guide_colorbar()` (@clauswilke, #2544).

### Other

* `fortify()` gains a method for tbls (@karawoo, #2218).

* `ggplot` gains a method for `grouped_df`s that adds a `.group` variable,
  which computes a unique value for each group. Use it with 
  `aes(group = .group)` (#2351).

* `ggproto()` produces objects with class `c("ggproto", "gg")`, allowing for
  a more informative error message when adding layers, scales, or other ggproto 
  objects (@jrnold, #2056).

* `ggsave()`'s DPI argument now supports 3 string options: "retina" (320
  DPI), "print" (300 DPI), and "screen" (72 DPI) (@foo-bar-baz-qux, #2156).
  `ggsave()` now uses full argument names to avoid partial match warnings 
  (#2355), and correctly restores the previous graphics device when several
  graphics devices are open (#2363).

* `print.ggplot()` now returns the original ggplot object, instead of the 
  output from `ggplot_build()`. Also, the object returned from 
  `ggplot_build()` now has the class `"ggplot_built"` (#2034).

* `map_data()` now works even when purrr is loaded (tidyverse#66).

* New functions `summarise_layout()`, `summarise_coord()`, and 
  `summarise_layers()` summarise the layout, coordinate systems, and layers 
  of a built ggplot object (#2034, @wch). This provides a tested API that 
  (e.g.) shiny can depend on.

* Updated startup messages reflect new resources (#2410, @mine-cetinkaya-rundel).

# ggplot2 2.2.1

* Fix usage of `structure(NULL)` for R-devel compatibility (#1968).

# ggplot2 2.2.0

## Major new features

### Subtitle and caption

Thanks to @hrbrmstr plots now have subtitles and captions, which can be set with the `subtitle`  and `caption` arguments to `ggtitle()` and `labs()`. You can control their appearance with the theme settings `plot.caption` and `plot.subtitle`. The main plot title is now left-aligned to better work better with a subtitle. The caption is right-aligned (@hrbrmstr).

### Stacking

`position_stack()` and `position_fill()` now sort the stacking order to match grouping order. This allows you to control the order through grouping, and ensures that the default legend matches the plot (#1552, #1593). If you want the opposite order (useful if you have horizontal bars and horizontal legend), you can request reverse stacking by using `position = position_stack(reverse = TRUE)` (#1837).
  
`position_stack()` and `position_fill()` now accepts negative values which will create stacks extending below the x-axis (#1691).

`position_stack()` and `position_fill()` gain a `vjust` argument which makes it easy to (e.g.) display labels in the middle of stacked bars (#1821).

### Layers

`geom_col()` was added to complement `geom_bar()` (@hrbrmstr). It uses `stat="identity"` by default, making the `y` aesthetic mandatory. It does not support any other `stat_()` and does not provide fallback support for the `binwidth` parameter. Examples and references in other functions were updated to demonstrate `geom_col()` usage. 

When creating a layer, ggplot2 will warn if you use an unknown aesthetic or an unknown parameter. Compared to the previous version, this is stricter for aesthetics (previously there was no message), and less strict for parameters (previously this threw an error) (#1585).

### Facetting

The facet system, as well as the internal panel class, has been rewritten in ggproto. Facets are now extendable in the same manner as geoms and stats, as described in `vignette("extending-ggplot2")`.

We have also added the following new fatures.
  
* `facet_grid()` and `facet_wrap()` now allow expressions in their faceting 
  formulas (@DanRuderman, #1596).

* When `facet_wrap()` results in an uneven number of panels, axes will now be
  drawn underneath the hanging panels (fixes #1607)

* Strips can now be freely positioned in `facet_wrap()` using the 
  `strip.position` argument (deprecates `switch`).

* The relative order of panel, strip, and axis can now be controlled with 
  the theme setting `strip.placement` that takes either `inside` (strip between 
  panel and axis) or `outside` (strip after axis).

* The theme option `panel.margin` has been deprecated in favour of 
  `panel.spacing` to more clearly communicate intent.

### Extensions

Unfortunately there was a major oversight in the construction of ggproto which lead to extensions capturing the super object at package build time, instead of at package run time (#1826). This problem has been fixed, but requires re-installation of all extension packages.

## Scales

* The position of x and y axes can now be changed using the `position` argument
  in `scale_x_*`and `scale_y_*` which can take `top` and `bottom`, and `left`
  and `right` respectively. The themes of top and right axes can be modified 
  using the `.top` and `.right` modifiers to `axis.text.*` and `axis.title.*`.

### Continuous scales

* `scale_x_continuous()` and `scale_y_continuous()` can now display a secondary 
  axis that is a __one-to-one__ transformation of the primary axis (e.g. degrees 
  Celcius to degrees Fahrenheit). The secondary axis will be positioned opposite 
  to the primary axis and can be controlled with the `sec.axis` argument to 
  the scale constructor.

* Scales worry less about having breaks. If no breaks can be computed, the
  plot will work instead of throwing an uninformative error (#791). This 
  is particularly helpful when you have facets with free scales, and not
  all panels contain data.

* Scales now warn when transformation introduces infinite values (#1696).

### Date time

* `scale_*_datetime()` now supports time zones. It will use the timezone 
  attached to the varaible by default, but can be overridden with the 
  `timezone` argument.

* New `scale_x_time()` and `scale_y_time()` generate reasonable default
  breaks and labels for hms vectors (#1752).

### Discrete scales

The treatment of missing values by discrete scales has been thoroughly overhauled (#1584). The underlying principle is that we can naturally represent missing values on discrete variables (by treating just like another level), so by default we should. 

This principle applies to:

* character vectors
* factors with implicit NA
* factors with explicit NA

And to all scales (both position and non-position.)

Compared to the previous version of ggplot2, there are three main changes:

1.  `scale_x_discrete()` and `scale_y_discrete()` always show discrete NA,
    regardless of their source

1.  If present, `NA`s are shown in discete legends.

1.  All discrete scales gain a `na.translate` argument that allows you to 
    control whether `NA`s are translated to something that can be visualised,
    or should be left as missing. Note that if you don't translate (i.e. 
    `na.translate = FALSE)` the missing values will passed on to the layer, 
    which will warning that it's dropping missing values. To suppress the
    warnings, you'll also need to add `na.rm = TRUE` to the layer call. 

There were also a number of other smaller changes

* Correctly use scale expansion factors.
* Don't preserve space for dropped levels (#1638).
* Only issue one warning when when asking for too many levels (#1674).
* Unicode labels work better on Windows (#1827).
* Warn when used with only continuous data (#1589)

## Themes

* The `theme()` constructor now has named arguments rather than ellipses. This 
  should make autocomplete substantially more useful. The documentation
  (including examples) has been considerably improved.
  
* Built-in themes are more visually homogeneous, and match `theme_grey` better.
  (@jiho, #1679)
  
* When computing the height of titles, ggplot2 now includes the height of the
  descenders (i.e. the bits of `g` and `y` that hang beneath the baseline). This 
  improves the margins around titles, particularly the y axis label (#1712).
  I have also very slightly increased the inner margins of axis titles, and 
  removed the outer margins. 

* Theme element inheritance is now easier to work with as modification now
  overrides default `element_blank` elements (#1555, #1557, #1565, #1567)
  
* Horizontal legends (i.e. legends on the top or bottom) are horizontally
  aligned by default (#1842). Use `legend.box = "vertical"` to switch back
  to the previous behaviour.
  
* `element_line()` now takes an `arrow` argument to specify arrows at the end of
  lines (#1740)

There were a number of tweaks to the theme elements that control legends:
  
* `legend.justification` now controls appearance will plotting the legend
  outside of the plot area. For example, you can use 
  `theme(legend.justification = "top")` to make the legend align with the 
  top of the plot.

* `panel.margin` and `legend.margin` have been renamed to `panel.spacing` and 
  `legend.spacing` respectively, to better communicate intent (they only
  affect spacing between legends and panels, not the margins around them)

* `legend.margin` now controls margin around individual legends.

* New `legend.box.background`, `legend.box.spacing`, and `legend.box.margin`
  control the background, spacing, and margin of the legend box (the region
  that contains all legends).

## Bug fixes and minor improvements

* ggplot2 now imports tibble. This ensures that all built-in datasets print 
  compactly even if you haven't explicitly loaded tibble or dplyr (#1677).

* Class of aesthetic mapping is preserved when adding `aes()` objects (#1624).

* `+.gg` now works for lists that include data frames.

* `annotation_x()` now works in the absense of global data (#1655)

* `geom_*(show.legend = FALSE)` now works for `guide_colorbar`.

* `geom_boxplot()` gains new `outlier.alpha` (@jonathan-g) and 
  `outlier.fill` (@schloerke, #1787) parameters to control the alpha/fill of
   outlier points independently of the alpha of the boxes. 

* `position_jitter()` (and hence `geom_jitter()`) now correctly computes 
  the jitter width/jitter when supplied by the user (#1775, @has2k1).

* `geom_contour()` more clearly describes what inputs it needs (#1577).

* `geom_curve()` respects the `lineend` paramater (#1852).

* `geom_histogram()` and `stat_bin()` understand the `breaks` parameter once 
  more. (#1665). The floating point adjustment for histogram bins is now 
  actually used - it was previously inadvertently ignored (#1651).

* `geom_violin()` no longer transforms quantile lines with the alpha aesthetic
  (@mnbram, #1714). It no longer errors when quantiles are requested but data
  have zero range (#1687). When `trim = FALSE` it once again has a nice 
  range that allows the density to reach zero (by extending the range 3 
  bandwidths to either side of the data) (#1700).

* `geom_dotplot()` works better when faceting and binning on the y-axis. 
  (#1618, @has2k1).
  
* `geom_hexbin()` once again supports `..density..` (@mikebirdgeneau, #1688).

* `geom_step()` gives useful warning if only one data point in layer (#1645).

* `layer()` gains new `check.aes` and `check.param` arguments. These allow
  geom/stat authors to optional suppress checks for known aesthetics/parameters.
  Currently this is used only in `geom_blank()` which powers `expand_limits()` 
  (#1795).

* All `stat_*()` display a better error message when required aesthetics are
  missing.
  
* `stat_bin()` and `stat_summary_hex()` now accept length 1 `binwidth` (#1610)

* `stat_density()` gains new argument `n`, which is passed to underlying function
  `stats::density` ("number of equally spaced points at which the
  density is to be estimated"). (@hbuschme)

* `stat_binhex()` now again returns `count` rather than `value` (#1747)

* `stat_ecdf()` respects `pad` argument (#1646).

* `stat_smooth()` once again informs you about the method it has chosen.
  It also correctly calculates the size of the largest group within facets.

* `x` and `y` scales are now symmetric regarding the list of
  aesthetics they accept: `xmin_final`, `xmax_final`, `xlower`,
  `xmiddle` and `xupper` are now valid `x` aesthetics.

* `Scale` extensions can now override the `make_title` and `make_sec_title` 
  methods to let the scale modify the axis/legend titles.

* The random stream is now reset after calling `.onAttach()` (#2409).

# ggplot2 2.1.0

## New features

* When mapping an aesthetic to a constant (e.g. 
  `geom_smooth(aes(colour = "loess")))`), the default guide title is the name 
  of the aesthetic (i.e. "colour"), not the value (i.e. "loess") (#1431).

* `layer()` now accepts a function as the data argument. The function will be
  applied to the data passed to the `ggplot()` function and must return a
  data.frame (#1527, @thomasp85). This is a more general version of the 
  deprecated `subset` argument.

* `theme_update()` now uses the `+` operator instead of `%+replace%`, so that
  unspecified values will no longer be `NULL`ed out. `theme_replace()`
  preserves the old behaviour if desired (@oneillkza, #1519). 

* `stat_bin()` has been overhauled to use the same algorithm as ggvis, which 
  has been considerably improved thanks to the advice of Randy Prium (@rpruim).
  This includes:
  
    * Better arguments and a better algorithm for determining the origin.
      You can now specify either `boundary` or the `center` of a bin.
      `origin` has been deprecated in favour of these arguments.
      
    * `drop` is deprecated in favour of `pad`, which adds extra 0-count bins
      at either end (needed for frequency polygons). `geom_histogram()` defaults 
      to `pad = FALSE` which considerably improves the default limits for 
      the histogram, especially when the bins are big (#1477).
      
    * The default algorithm does a (somewhat) better job at picking nice widths 
      and origins across a wider range of input data.
      
    * `bins = n` now gives a histogram with `n` bins, not `n + 1` (#1487).

## Bug fixes

* All `\donttest{}` examples run.

* All `geom_()` and `stat_()` functions now have consistent argument order:
  data + mapping, then geom/stat/position, then `...`, then specific arguments, 
  then arguments common to all layers (#1305). This may break code if you were
  previously relying on partial name matching, but in the long-term should make 
  ggplot2 easier to use. In particular, you can now set the `n` parameter
  in `geom_density2d()` without it partially matching `na.rm` (#1485).

* For geoms with both `colour` and `fill`, `alpha` once again only affects
  fill (Reverts #1371, #1523). This was causing problems for people.

* `facet_wrap()`/`facet_grid()` works with multiple empty panels of data 
  (#1445).

* `facet_wrap()` correctly swaps `nrow` and `ncol` when faceting vertically
  (#1417).

* `ggsave("x.svg")` now uses svglite to produce the svg (#1432).

* `geom_boxplot()` now understands `outlier.color` (#1455).

* `geom_path()` knows that "solid" (not just 1) represents a solid line (#1534).

* `geom_ribbon()` preserves missing values so they correctly generate a 
  gap in the ribbon (#1549).

* `geom_tile()` once again accepts `width` and `height` parameters (#1513). 
  It uses `draw_key_polygon()` for better a legend, including a coloured 
  outline (#1484).

* `layer()` now automatically adds a `na.rm` parameter if none is explicitly
  supplied.

* `position_jitterdodge()` now works on all possible dodge aesthetics, 
  e.g. `color`, `linetype` etc. instead of only based on `fill` (@bleutner)

* `position = "nudge"` now works (although it doesn't do anything useful)
  (#1428).

* The default scale for columns of class "AsIs" is now "identity" (#1518).

* `scale_*_discrete()` has better defaults when used with purely continuous
  data (#1542).

* `scale_size()` warns when used with categorical data.

* `scale_size()`, `scale_colour()`, and `scale_fill()` gain date and date-time
  variants (#1526).

* `stat_bin_hex()` and `stat_bin_summary()` now use the same underlying 
  algorithm so results are consistent (#1383). `stat_bin_hex()` now accepts
  a `weight` aesthetic. To be consistent with related stats, the output variable 
  from `stat_bin_hex()` is now value instead of count.

* `stat_density()` gains a `bw` parameter which makes it easy to get consistent 
   smoothing between facets (@jiho)

* `stat-density-2d()` no longer ignores the `h` parameter, and now accepts 
  `bins` and `binwidth` parameters to control the number of contours 
  (#1448, @has2k1).

* `stat_ecdf()` does a better job of adding padding to -Inf/Inf, and gains
  an argument `pad` to suppress the padding if not needed (#1467).

* `stat_function()` gains an `xlim` parameter (#1528). It once again works 
  with discrete x values (#1509).

* `stat_summary()` preserves sorted x order which avoids artefacts when
  display results with `geom_smooth()` (#1520).

* All elements should now inherit correctly for all themes except `theme_void()`.
  (@Katiedaisey, #1555) 

* `theme_void()` was completely void of text but facets and legends still
  need labels. They are now visible (@jiho). 

* You can once again set legend key and height width to unit arithmetic
  objects (like `2 * unit(1, "cm")`) (#1437).

* Eliminate spurious warning if you have a layer with no data and no aesthetics
  (#1451).

* Removed a superfluous comma in `theme-defaults.r` code (@jschoeley)

* Fixed a compatibility issue with `ggproto` and R versions prior to 3.1.2.
  (#1444)

* Fixed issue where `coord_map()` fails when given an explicit `parameters`
  argument (@tdmcarthur, #1729)
  
* Fixed issue where `geom_errorbarh()` had a required `x` aesthetic (#1933)  

# ggplot2 2.0.0

## Major changes

* ggplot no longer throws an error if your plot has no layers. Instead it 
  automatically adds `geom_blank()` (#1246).
  
* New `cut_width()` is a convenient replacement for the verbose
  `plyr::round_any()`, with the additional benefit of offering finer
  control.

* New `geom_count()` is a convenient alias to `stat_sum()`. Use it when you
  have overlapping points on a scatterplot. `stat_sum()` now defaults to 
  using counts instead of proportions.

* New `geom_curve()` adds curved lines, with a similar specification to 
  `geom_segment()` (@veraanadi, #1088).

* Date and datetime scales now have `date_breaks`, `date_minor_breaks` and
  `date_labels` arguments so that you never need to use the long
  `scales::date_breaks()` or `scales::date_format()`.
  
* `geom_bar()` now has it's own stat, distinct from `stat_bin()` which was
  also used by `geom_histogram()`. `geom_bar()` now uses `stat_count()` 
  which counts values at each distinct value of x (i.e. it does not bin
  the data first). This can be useful when you want to show exactly which 
  values are used in a continuous variable.

* `geom_point()` gains a `stroke` aesthetic which controls the border width of 
  shapes 21-25 (#1133, @SeySayux). `size` and `stroke` are additive so a point 
  with `size = 5` and `stroke = 5` will have a diameter of 10mm. (#1142)

* New `position_nudge()` allows you to slightly offset labels (or other 
  geoms) from their corresponding points (#1109).

* `scale_size()` now maps values to _area_, not radius. Use `scale_radius()`
  if you want the old behaviour (not recommended, except perhaps for lines).

* New `stat_summary_bin()` works like `stat_summary()` but on binned data. 
  It's a generalisation of `stat_bin()` that can compute any aggregate,
  not just counts (#1274). Both default to `mean_se()` if no aggregation
  functions are supplied (#1386).

* Layers are now much stricter about their arguments - you will get an error
  if you've supplied an argument that isn't an aesthetic or a parameter.
  This is likely to cause some short-term pain but in the long-term it will make
  it much easier to spot spelling mistakes and other errors (#1293).
  
    This change does break a handful of geoms/stats that used `...` to pass 
    additional arguments on to the underlying computation. Now 
    `geom_smooth()`/`stat_smooth()` and `geom_quantile()`/`stat_quantile()` 
    use `method.args` instead (#1245, #1289); and `stat_summary()` (#1242), 
    `stat_summary_hex()`, and `stat_summary2d()` use `fun.args`.

### Extensibility

There is now an official mechanism for defining Stats, Geoms, and Positions in other packages. See `vignette("extending-ggplot2")` for details.

* All Geoms, Stats and Positions are now exported, so you can inherit from them
  when making your own objects (#989).

* ggplot2 no longer uses proto or reference classes. Instead, we now use 
  ggproto, a new OO system designed specifically for ggplot2. Unlike proto
  and RC, ggproto supports clean cross-package inheritance. Creating a new OO
  system isn't usually the right way to solve a problem, but I'm pretty sure
  it was necessary here. Read more about it in the vignette.

* `aes_()` replaces `aes_q()`. It also supports formulas, so the most concise 
  SE version of `aes(carat, price)` is now `aes_(~carat, ~price)`. You may
  want to use this form in packages, as it will avoid spurious `R CMD check` 
  warnings about undefined global variables.

### Text

* `geom_text()` has been overhauled to make labelling your data a little
  easier. It:
  
    * `nudge_x` and `nudge_y` arguments let you offset labels from their
      corresponding points (#1120). 
      
    * `check_overlap = TRUE` provides a simple way to avoid overplotting 
      of labels: labels that would otherwise overlap are omitted (#1039).
      
    * `hjust` and `vjust` can now be character vectors: "left", "center", 
      "right", "bottom", "middle", "top". New options include "inward" and 
      "outward" which align text towards and away from the center of the plot 
      respectively.

* `geom_label()` works like `geom_text()` but draws a rounded rectangle 
  underneath each label (#1039). This is useful when you want to label plots
  that are dense with data.

### Deprecated features

* The little used `aes_auto()` has been deprecated. 

* `aes_q()` has been replaced with `aes_()` to be consistent with SE versions
  of NSE functions in other packages.

* The `order` aesthetic is officially deprecated. It never really worked, and 
  was poorly documented.

* The `stat` and `position` arguments to `qplot()` have been deprecated.
  `qplot()` is designed for quick plots - if you need to specify position
  or stat, use `ggplot()` instead.

* The theme setting `axis.ticks.margin` has been deprecated: now use the margin 
  property of `axis.text`.
  
* `stat_abline()`, `stat_hline()` and `stat_vline()` have been removed:
  these were never suitable for use other than with `geom_abline()` etc
  and were not documented.

* `show_guide` has been renamed to `show.legend`: this more accurately
  reflects what it does (controls appearance of layer in legend), and uses the 
  same convention as other ggplot2 arguments (i.e. a `.` between names).
  (Yes, I know that's inconsistent with function names with use `_`, but it's
  too late to change now.)

A number of geoms have been renamed to be internally consistent:

* `stat_binhex()` and `stat_bin2d()` have been renamed to `stat_bin_hex()` 
  and `stat_bin_2d()` (#1274). `stat_summary2d()` has been renamed to 
  `stat_summary_2d()`, `geom_density2d()`/`stat_density2d()` has been renamed 
  to `geom_density_2d()`/`stat_density_2d()`.

* `stat_spoke()` is now `geom_spoke()` since I realised it's a
  reparameterisation of `geom_segment().

* `stat_bindot()` has been removed because it's so tightly coupled to
  `geom_dotplot()`. If you happened to use `stat_bindot()`, just change to
  `geom_dotplot()` (#1194).

All defunct functions have been removed.

### Default appearance

* The default `theme_grey()` background colour has been changed from "grey90" 
  to "grey92": this makes the background a little less visually prominent.

* Labels and titles have been tweaked for readability:

    * Axes labels are darker.
    
    * Legend and axis titles are given the same visual treatment.
    
    * The default font size dropped from 12 to 11. You might be surprised that 
      I've made the default text size smaller as it was already hard for
      many people to read. It turns out there was a bug in RStudio (fixed in 
      0.99.724), that shrunk the text of all grid based graphics. Once that
      was resolved the defaults seemed too big to my eyes.
    
    * More spacing between titles and borders.
    
    * Default margins scale with the theme font size, so the appearance at 
      larger font sizes should be considerably improved (#1228). 

* `alpha` now affects both fill and colour aesthetics (#1371).

* `element_text()` gains a margins argument which allows you to add additional
  padding around text elements. To help see what's going on use `debug = TRUE` 
  to display the text region and anchors.

* The default font size in `geom_text()` has been decreased from 5mm (14 pts)
  to 3.8 mm (11 pts) to match the new default theme sizes.

* A diagonal line is no longer drawn on bar and rectangle legends. Instead, the
  border has been tweaked to be more visible, and more closely match the size of 
  line drawn on the plot.

* `geom_pointrange()` and `geom_linerange()` get vertical (not horizontal)
  lines in the legend (#1389).

* The default line `size` for `geom_smooth()` has been increased from 0.5 to 1 
  to make it easier to see when overlaid on data.
  
* `geom_bar()` and `geom_rect()` use a slightly paler shade of grey so they
  aren't so visually heavy.
  
* `geom_boxplot()` now colours outliers the same way as the boxes.

* `geom_point()` now uses shape 19 instead of 16. This looks much better on 
  the default Linux graphics device. (It's very slightly smaller than the old 
  point, but it shouldn't affect any graphics significantly)

* Sizes in ggplot2 are measured in mm. Previously they were converted to pts 
  (for use in grid) by multiplying by 72 / 25.4. However, grid uses printer's 
  points, not Adobe (big pts), so sizes are now correctly multiplied by 
  72.27 / 25.4. This is unlikely to noticeably affect display, but it's
  technically correct (<https://youtu.be/hou0lU8WMgo>).

* The default legend will now allocate multiple rows (if vertical) or
  columns (if horizontal) in order to make a legend that is more likely to
  fit on the screen. You can override with the `nrow`/`ncol` arguments
  to `guide_legend()`

    ```R
    p <- ggplot(mpg, aes(displ,hwy, colour = model)) + geom_point()
    p
    p + theme(legend.position = "bottom")
    # Previous behaviour
    p + guides(colour = guide_legend(ncol = 1))
    ```

### New and updated themes

* New `theme_void()` is completely empty. It's useful for plots with non-
  standard coordinates or for drawings (@jiho, #976).

* New `theme_dark()` has a dark background designed to make colours pop out
  (@jiho, #1018)

* `theme_minimal()` became slightly more minimal by removing the axis ticks:
  labels now line up directly beneath grid lines (@tomschloss, #1084)

* New theme setting `panel.ontop` (logical) make it possible to place 
  background elements (i.e., gridlines) on top of data. Best used with 
  transparent `panel.background` (@noamross. #551).

### Labelling

The facet labelling system was updated with many new features and a
more flexible interface (@lionel-). It now works consistently across
grid and wrap facets. The most important user visible changes are:

* `facet_wrap()` gains a `labeller` option (#25).

* `facet_grid()` and `facet_wrap()` gain a `switch` argument to
  display the facet titles near the axes. When switched, the labels
  become axes subtitles. `switch` can be set to "x", "y" or "both"
  (the latter only for grids) to control which margin is switched.

The labellers (such as `label_value()` or `label_both()`) also get
some new features:

* They now offer the `multi_line` argument to control whether to
  display composite facets (those specified as `~var1 + var2`) on one
  or multiple lines.

* In `label_bquote()` you now refer directly to the names of
  variables. With this change, you can create math expressions that
  depend on more than one variable. This math expression can be
  specified either for the rows or the columns and you can also
  provide different expressions to each margin.

  As a consequence of these changes, referring to `x` in backquoted
  expressions is deprecated.

* Similarly to `label_bquote()`, `labeller()` now take `.rows` and
  `.cols` arguments. In addition, it also takes `.default`.
  `labeller()` is useful to customise how particular variables are
  labelled. The three additional arguments specify how to label the
  variables are not specifically mentioned, respectively for rows,
  columns or both. This makes it especially easy to set up a
  project-wide labeller dispatcher that can be reused across all your
  plots. See the documentation for an example.

* The new labeller `label_context()` adapts to the number of factors
  facetted over. With a single factor, it displays only the values,
  just as before. But with multiple factors in a composite margin
  (e.g. with `~cyl + am`), the labels are passed over to
  `label_both()`. This way the variables names are displayed with the
  values to help identifying them.

On the programming side, the labeller API has been rewritten in order
to offer more control when faceting over multiple factors (e.g. with
formulae such as `~cyl + am`). This also means that if you have
written custom labellers, you will need to update them for this
version of ggplot.

* Previously, a labeller function would take `variable` and `value`
  arguments and return a character vector. Now, they take a data frame
  of character vectors and return a list. The input data frame has one
  column per factor facetted over and each column in the returned list
  becomes one line in the strip label. See documentation for more
  details.

* The labels received by a labeller now contain metadata: their margin
  (in the "type" attribute) and whether they come from a wrap or a
  grid facet (in the "facet" attribute).

* Note that the new `as_labeller()` function operator provides an easy
  way to transform an existing function to a labeller function. The
  existing function just needs to take and return a character vector.

## Documentation

* Improved documentation for `aes()`, `layer()` and much much more.

* I've tried to reduce the use of `...` so that you can see all the 
  documentation in one place rather than having to integrate multiple pages.
  In some cases this has involved adding additional arguments to geoms
  to make it more clear what you can do:
  
    *  `geom_smooth()` gains explicit `method`, `se` and `formula` arguments.
    
    * `geom_histogram()` gains `binwidth`, `bins`, origin` and `right` 
      arguments.
      
    * `geom_jitter()` gains `width` and `height` arguments to make it easier
      to control the amount of jittering without using the lengthy 
      `position_jitter()` function (#1116)

* Use of `qplot()` in examples has been minimised (#1123, @hrbrmstr). This is
  inline with the 2nd edition of the ggplot2 box, which minimises the use of 
  `qplot()` in favour of `ggplot()`.

* Tighly linked geoms and stats (e.g. `geom_boxplot()` and `stat_boxplot()`) 
  are now documented in the same file so you can see all the arguments in one
  place. Variations of the same idea (e.g. `geom_path()`, `geom_line()`, and
  `geom_step()`) are also documented together.

* It's now obvious that you can set the `binwidth` parameter for
  `stat_bin_hex()`, `stat_summary_hex()`, `stat_bin_2d()`, and
  `stat_summary_2d()`. 

* The internals of positions have been cleaned up considerably. You're unlikely
  to notice any external changes, although the documentation should be a little
  less confusing since positions now don't list parameters they never use.

## Data

* All datasets have class `tbl_df` so if you also use dplyr, you get a better
  print method.

* `economics` has been brought up to date to 2015-04-01.

* New `economics_long` is the economics data in long form.

* New `txhousing` dataset containing information about the Texas housing
  market. Useful for examples that need multiple time series, and for
  demonstrating model+vis methods.

* New `luv_colours` dataset which contains the locations of all
  built-in `colors()` in Luv space.

* `movies` has been moved into its own package, ggplot2movies, because it was 
  large and not terribly useful. If you've used the movies dataset, you'll now 
  need to explicitly load the package with `library(ggplot2movies)`.

## Bug fixes and minor improvements

* All partially matched arguments and `$` have been been replaced with 
  full matches (@jimhester, #1134).

* ggplot2 now exports `alpha()` from the scales package (#1107), and `arrow()` 
  and `unit()` from grid (#1225). This means you don't need attach scales/grid 
  or do `scales::`/`grid::` for these commonly used functions.

* `aes_string()` now only parses character inputs. This fixes bugs when
  using it with numbers and non default `OutDec` settings (#1045).

* `annotation_custom()` automatically adds a unique id to each grob name,
  making it easier to plot multiple grobs with the same name (e.g. grobs of
  ggplot2 graphics) in the same plot (#1256).

* `borders()` now accepts xlim and ylim arguments for specifying the geographical 
  region of interest (@markpayneatwork, #1392).

* `coord_cartesian()` applies the same expansion factor to limits as for scales. 
  You can suppress with `expand = FALSE` (#1207).

* `coord_trans()` now works when breaks are suppressed (#1422).

* `cut_number()` gives error message if the number of requested bins can
  be created because there are two few unique values (#1046).

* Character labels in `facet_grid()` are no longer (incorrectly) coerced into
  factors. This caused problems with custom label functions (#1070).

* `facet_wrap()` and `facet_grid()` now allow you to use non-standard
  variable names by surrounding them with backticks (#1067).

* `facet_wrap()` more carefully checks its `nrow` and `ncol` arguments
  to ensure that they're specified correctly (@richierocks, #962)

* `facet_wrap()` gains a `dir` argument to control the direction the
  panels are wrapped in. The default is "h" for horizontal. Use "v" for
  vertical layout (#1260).

* `geom_abline()`, `geom_hline()` and `geom_vline()` have been rewritten to
  have simpler behaviour and be more consistent:

    * `stat_abline()`, `stat_hline()` and `stat_vline()` have been removed:
      these were never suitable for use other than with `geom_abline()` etc
      and were not documented.

    * `geom_abline()`, `geom_vline()` and `geom_hline()` are bound to
      `stat_identity()` and `position_identity()`

    * Intercept parameters can no longer be set to a function.

    * They are all documented in one file, since they are so closely related.

* `geom_bin2d()` will now let you specify one dimension's breaks exactly,
  without touching the other dimension's default breaks at all (#1126).

* `geom_crossbar()` sets grouping correctly so you can display multiple
  crossbars on one plot. It also makes the default `fatten` argument a little
  bigger to make the middle line more obvious (#1125).

* `geom_histogram()` and `geom_smooth()` now only inform you about the
  default values once per layer, rather than once per panel (#1220).

* `geom_pointrange()` gains `fatten` argument so you can control the
  size of the point relative to the size of the line.

* `geom_segment()` annotations were not transforming with scales 
  (@BrianDiggs, #859).

* `geom_smooth()` is no longer so chatty. If you want to know what the deafult
  smoothing method is, look it up in the documentation! (#1247)

* `geom_violin()` now has the ability to draw quantile lines (@DanRuderman).

* `ggplot()` now captures the parent frame to use for evaluation,
  rather than always defaulting to the global environment. This should
  make ggplot more suitable to use in more situations (e.g. with knitr)

* `ggsave()` has been simplified a little to make it easier to maintain.
  It no longer checks that you're printing a ggplot2 object (so now also
  works with any grid grob) (#970), and always requires a filename.
  Parameter `device` now supports character argument to specify which supported
  device to use ('pdf', 'png', 'jpeg', etc.), for when it cannot be correctly
  inferred from the file extension (for example when a temporary filename is
  supplied server side in shiny apps) (@sebkopf, #939). It no longer opens
  a graphics device if one isn't already open - this is annoying when you're
  running from a script (#1326).

* `guide_colorbar()` creates correct legend if only one color (@krlmlr, #943).

* `guide_colorbar()` no longer fails when the legend is empty - previously
  this often masked misspecifications elsewhere in the plot (#967).

* New `layer_data()` function extracts the data used for plotting for a given
  layer. It's mostly useful for testing.

* User supplied `minor_breaks` can now be supplied on the same scale as 
  the data, and will be automatically transformed with by scale (#1385).

* You can now suppress the appearance of an axis/legend title (and the space
  that would allocated for it) with `NULL` in the `scale_` function. To
  use the default lable, use `waiver()` (#1145).

* Position adjustments no longer warn about potentially varying ranges
  because the problem rarely occurs in practice and there are currently a
  lot of false positives since I don't understand exactly what FP criteria
  I should be testing.

* `scale_fill_grey()` now uses red for missing values. This matches
  `scale_colour_grey()` and makes it obvious where missing values lie.
  Override with `na.value`.

* `scale_*_gradient2()` defaults to using Lab colour space.

* `scale_*_gradientn()` now allows `colours` or `colors` (#1290)

* `scale_y_continuous()` now also transforms the `lower`, `middle` and `upper`
  aesthetics used by `geom_boxplot()`: this only affects
  `geom_boxplot(stat = "identity")` (#1020).

* Legends no longer inherit aesthetics if `inherit.aes` is FALSE (#1267).

* `lims()` makes it easy to set the limits of any axis (#1138).

* `labels = NULL` now works with `guide_legend()` and `guide_colorbar()`.
  (#1175, #1183).

* `override.aes` now works with American aesthetic spelling, e.g. color

* Scales no longer round data points to improve performance of colour
  palettes. Instead the scales package now uses a much faster colour
  interpolation algorithm (#1022).

* `scale_*_brewer()` and `scale_*_distiller()` add new `direction` argument of 
  `scales::brewer_pal`, making it easier to change the order of colours 
  (@jiho, #1139).

* `scale_x_date()` now clips dates outside the limits in the same way as
  `scale_x_continuous()` (#1090).

* `stat_bin()` gains `bins` arguments, which denotes the number of bins. Now
  you can set `bins=100` instead of `binwidth=0.5`. Note that `breaks` or
  `binwidth` will override it (@tmshn, #1158, #102).

* `stat_boxplot()` warns if a continuous variable is used for the `x` aesthetic
  without also supplying a `group` aesthetic (#992, @krlmlr).

* `stat_summary_2d()` and `stat_bin_2d()` now share exactly the same code for 
  determining breaks from `bins`, `binwidth`, and `origin`. 
  
* `stat_summary_2d()` and `stat_bin_2d()` now output in tile/raster compatible 
  form instead of rect compatible form. 

* Automatically computed breaks do not lead to an error for transformations like
  "probit" where the inverse can map to infinity (#871, @krlmlr)

* `stat_function()` now always evaluates the function on the original scale.
  Previously it computed the function on transformed scales, giving incorrect
  values (@BrianDiggs, #1011).

* `strip_dots` works with anonymous functions within calculated aesthetics 
  (e.g. `aes(sapply(..density.., function(x) mean(x))))` (#1154, @NikNakk)

* `theme()` gains `validate = FALSE` parameter to turn off validation, and 
  hence store arbitrary additional data in the themes. (@tdhock, #1121)

* Improved the calculation of segments needed to draw the curve representing
  a line when plotted in polar coordinates. In some cases, the last segment
  of a multi-segment line was not drawn (@BrianDiggs, #952)
