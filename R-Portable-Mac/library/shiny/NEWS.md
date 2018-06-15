shiny 1.1.0
===========

This is a significant release for Shiny, with a major new feature that was nearly a year in the making: support for asynchronous operations! Until now, R's single-threaded nature meant that performing long-running calculations or tasks from Shiny would bring your app to a halt for other users of that process. This release of Shiny deeply integrates the [promises](https://rstudio.github.io/promises/) package to allow you to execute some tasks asynchronously, including as part of reactive expressions and outputs. See the [promises](https://rstudio.github.io/promises/) documentation to learn more.

## Full changelog

### Breaking changes

* `extractStackTrace` and `formatStackTrace` are deprecated and will be removed in a future version of Shiny. As far as we can tell, nobody has been using these functions, and a refactor has made them vestigial; if you need this functionality, please file an issue.

### New features

* Support for asynchronous operations! Built-in render functions that expected a certain kind of object to be yielded from their `expr`, now generally can handle a promise for that kind of object. Reactive expressions and observers are now promise-aware as well. ([#1932](https://github.com/rstudio/shiny/pull/1932))

* Introduced two changes to the (undocumented but widely used) JavaScript function `Shiny.onInputChange(name, value)`. First, we changed the function name to `Shiny.setInputValue` (but don't worry--the old function name will continue to work). Second, until now, all calls to `Shiny.onInputChange(inputId, value)` have been "deduplicated"; that is, anytime an input is set to the same value it already has, the set is ignored. With Shiny v1.1, you can now add an options object as the third parameter: `Shiny.setInputValue("name", value, {priority: "event"})`. When the priority option is set to `"event"`, Shiny will always send the value and trigger reactivity, whether it is a duplicate or not. This closes [#928](https://github.com/rstudio/shiny/issues/928), which was the most upvoted open issue by far! Thanks, @daattali. ([#2018](https://github.com/rstudio/shiny/pull/2018))

### Minor new features and improvements

* Addressed [#1978](https://github.com/rstudio/shiny/issues/1978): `shiny:value` is now triggered when duplicate output data is received from the server. (Thanks, @andrewsali! [#1999](https://github.com/rstudio/shiny/pull/1999))

* If a shiny output contains a css class of `shiny-report-size`, its container height and width are now reported in `session$clientData`. So, for an output with an id with `"myID"`, the height/width can be accessed via `session$clientData[['output_myID_height']]`/`session$clientData[['output_myID_width']]`. Addresses [#1980](https://github.com/rstudio/shiny/issues/1980). (Thanks, @cpsievert! [#1981](https://github.com/rstudio/shiny/pull/1981))

* Added a new `autoclose = TRUE` parameter to `dateInput()` and `dateRangeInput()`. This closed [#1969](https://github.com/rstudio/shiny/issues/1969) which was a duplicate of much older issue, [#173](https://github.com/rstudio/shiny/issues/173). The default value is `TRUE` since that seems to be the common use case. However, this will cause existing apps with date inputs (that update to this version of Shiny) to have the datepicker be immediately closed once a date is selected. For most apps, this is actually desired behavior; if you wish to keep the datepicker open until the user clicks out of it use `autoclose = FALSE`. ([#1987](https://github.com/rstudio/shiny/pull/1987))

* The version of Shiny is now accessible from Javascript, with `Shiny.version`. There is also a new function for comparing version strings, `Shiny.compareVersion()`. ([#1826](https://github.com/rstudio/shiny/pull/1826), [#1830](https://github.com/rstudio/shiny/pull/1830))

* Addressed [#1851](https://github.com/rstudio/shiny/issues/1851): Stack traces are now smaller in some places `do.call()` is used. ([#1856](https://github.com/rstudio/shiny/pull/1856))

* Stack traces have been improved, with more aggressive de-noising and support for deep stack traces (stitching together multiple stack traces that are conceptually part of the same async operation).

* Addressed [#1859](https://github.com/rstudio/shiny/issues/1859): Server-side selectize is now significantly faster. (Thanks to @dselivanov [#1861](https://github.com/rstudio/shiny/pull/1861))

* [#1989](https://github.com/rstudio/shiny/issues/1989): The server side of outputs can now be removed (e.g. `output$plot <- NULL`). This is not usually necessary but it does allow some objects to be garbage collected, which might matter if you are dynamically creating and destroying many outputs. (Thanks, @mmuurr! [#2011](https://github.com/rstudio/shiny/pull/2011))

* Removed the (ridiculously outdated) "experimental feature" tag from the reference documentation for `renderUI`. ([#2036](https://github.com/rstudio/shiny/pull/2036))

* Addressed [#1907](https://github.com/rstudio/shiny/issues/1907): the `ignoreInit` argument was first added only to `observeEvent`. Later, we also added it to `eventReactive`, but forgot to update the documentation. Now done, thanks [@flo12392](https://github.com/flo12392)! ([#2036](https://github.com/rstudio/shiny/pull/2036))

### Bug fixes

* Fixed [#1006](https://github.com/rstudio/shiny/issues/1006): Slider inputs sometimes showed too many digits. ([#1956](https://github.com/rstudio/shiny/pull/1956))

* Fixed [#1958](https://github.com/rstudio/shiny/issues/1958): Slider inputs previously displayed commas after a decimal point. ([#1960](https://github.com/rstudio/shiny/pull/1960))

* The internal `URLdecode()` function previously was a copy of `httpuv::decodeURIComponent()`, assigned at build time; now it invokes the httpuv function at run time.

* Fixed [#1840](https://github.com/rstudio/shiny/issues/1840): with the release of Shiny 1.0.5, we accidently changed the relative positioning of the icon and the title text in `navbarMenu`s and `tabPanel`s. This fix reverts this behavior back (i.e. the icon should be to the left of the text and/or the downward arrow in case of `navbarMenu`s). ([#1848](https://github.com/rstudio/shiny/pull/1848))

* Fixed [#1600](https://github.com/rstudio/shiny/issues/1600): URL-encoded bookmarking did not work with sliders that had dates or date-times. ([#1961](https://github.com/rstudio/shiny/pull/1961))

* Fixed [#1962](https://github.com/rstudio/shiny/issues/1962): [File dragging and dropping](https://blog.rstudio.com/2017/08/15/shiny-1-0-4/) broke in the presence of jQuery version 3.0 as introduced by the [rhandsontable](https://jrowen.github.io/rhandsontable/) [htmlwidget](https://www.htmlwidgets.org/). ([#2005](https://github.com/rstudio/shiny/pull/2005))

* Improved the error handling inside the `addResourcePath()` function, to give end users more informative error messages when the `directoryPath` argument cannot be normalized. This is especially useful for `runtime: shiny_prerendered` Rmd documents, like `learnr` tutorials. ([#1968](https://github.com/rstudio/shiny/pull/1968))

* Changed script tags in reactlog ([inst/www/reactive-graph.html](https://github.com/rstudio/shiny/blob/master/inst/www/reactive-graph.html)) from HTTP to HTTPS in order to avoid mixed content blocking by most browsers. (Thanks, @jekriske-lilly! [#1844](https://github.com/rstudio/shiny/pull/1844))

* Addressed [#1784](https://github.com/rstudio/shiny/issues/1784): `runApp()` will avoid port 6697, which is considered unsafe by Chrome.

* Fixed [#2000](https://github.com/rstudio/shiny/issues/2000): Implicit calls to `xxxOutput` not working inside modules. (Thanks, @GregorDeCillia! [#2010](https://github.com/rstudio/shiny/pull/2010))

* Fixed [#2021](https://github.com/rstudio/shiny/issues/2021): Memory leak with `reactiveTimer` and `invalidateLater`. ([#2022](https://github.com/rstudio/shiny/pull/2022))

### Library updates

* Updated to ion.rangeSlider 2.2.0. ([#1955](https://github.com/rstudio/shiny/pull/1955))


## Known issues

In some rare cases, interrupting an application (by pressing Ctrl-C or Esc) may result in the message `Error in execCallbacks(timeoutSecs) : c++ exception (unknown reason)`. Although this message sounds alarming, it is harmless, and will go away in a future version of the later package (more information [here](https://github.com/r-lib/later/issues/55)).


shiny 1.0.5
===========

## Full changelog

### Bug fixes

* Fixed [#1818](https://github.com/rstudio/shiny/issues/1818): `conditionalPanel()` expressions that have a newline character in them caused the application to not work. ([#1820](https://github.com/rstudio/shiny/pull/1820))

* Added a safe wrapper function for internal calls to `jsonlite::fromJSON()`. ([#1822](https://github.com/rstudio/shiny/pull/1822))

* Fixed [#1824](https://github.com/rstudio/shiny/issues/1824): HTTP HEAD requests on static files caused the application to stop. ([#1825](https://github.com/rstudio/shiny/pull/1825))


shiny 1.0.4
===========

There are three headlining features in this release of Shiny. It is now possible to add and remove tabs from a `tabPanel`; there is a new function, `onStop()`, which registers callbacks that execute when an application exits; and `fileInput`s now can have files dragged and dropped on them. In addition to these features, this release has a number of minor features and bug fixes. See the full changelog below for more details.

## Full changelog

### New features

* Implemented [#1668](https://github.com/rstudio/shiny/issues/1668): dynamic tabs: added functions (`insertTab`, `appendTab`, `prependTab`, `removeTab`, `showTab` and `hideTab`) that allow you to do those actions for an existing `tabsetPanel`. ([#1794](https://github.com/rstudio/shiny/pull/1794))

* Implemented [#1213](https://github.com/rstudio/shiny/issues/1213): Added a new function, `onStop()`, which can be used to register callback functions that are invoked when an application exits, or when a user session ends. (Multiple sessions can be connected to a single running Shiny application.) This is useful if you have finalization/clean-up code that should be run after the application exits. ([#1770](https://github.com/rstudio/shiny/pull/1770)

* Implemented [#1155](https://github.com/rstudio/shiny/issues/1155): Files can now be drag-and-dropped on `fileInput` controls. The appearance of `fileInput` controls while files are being dragged can be modified by overriding the `shiny-file-input-active` and `shiny-file-input-over` classes. ([#1782](https://github.com/rstudio/shiny/pull/1782))

### Minor new features and improvements

* Addressed [#1688](https://github.com/rstudio/shiny/issues/1688): trigger a new `shiny:outputinvalidated` event when an output gets invalidated, at the same time that the `recalculating` CSS class is added. ([#1758](https://github.com/rstudio/shiny/pull/1758), thanks [@andrewsali](https://github.com/andrewsali)!)

* Addressed [#1508](https://github.com/rstudio/shiny/issues/1508): `fileInput` now permits the same file to be uploaded multiple times. ([#1719](https://github.com/rstudio/shiny/pull/1719))

* Addressed [#1501](https://github.com/rstudio/shiny/issues/1501): The `fileInput` control now retains uploaded file extensions on the server. This fixes [readxl](https://github.com/tidyverse/readxl)'s `readxl::read_excel` and other functions that must recognize a file's extension in order to work. ([#1706](https://github.com/rstudio/shiny/pull/1706))

* For `conditionalPanel`s, Shiny now gives more informative messages if there are errors evaluating or parsing the JavaScript conditional expression. ([#1727](https://github.com/rstudio/shiny/pull/1727))

* Addressed [#1586](https://github.com/rstudio/shiny/issues/1586): The `conditionalPanel` function now accepts an `ns` argument. The `ns` argument can be used in a [module](https://shiny.rstudio.com/articles/modules.html) UI function to scope the `condition` expression to the module's own input and output IDs. ([#1735](https://github.com/rstudio/shiny/pull/1735))

* With `options(shiny.testmode=TRUE)`, the Shiny process will send a message to the client in response to a changed input, even if no outputs have changed. This helps to streamline testing using the shinytest package. ([#1747](https://github.com/rstudio/shiny/pull/1747))

* Addressed [#1738](https://github.com/rstudio/shiny/issues/1738): The `updateTextInput` and `updateTextAreaInput` functions can now update the placeholder. ([#1742](https://github.com/rstudio/shiny/pull/1742))

* Converted examples to single file apps, and made updates and enhancements to comments in the example app scripts. ([#1685](https://github.com/rstudio/shiny/pull/1685))

* Added new `snapshotPreprocessInput()` and `snapshotPreprocessOutput()` functions, which is used for preprocessing and input and output values before taking a test snapshot. ([#1760](https://github.com/rstudio/shiny/pull/1760), [#1789](https://github.com/rstudio/shiny/pull/1789))

* The HTML generated by `renderTable()` no longer includes comments with the R version, xtable version, and timestamp. ([#1771](https://github.com/rstudio/shiny/pull/1771))

* Added a function `isRunning` to test whether a Shiny app is currently running. ([#1785](https://github.com/rstudio/shiny/pull/1785))

* Added a function `setSerializer`, which allows authors to specify a function for serializing the value of a custom input. ([#1791](https://github.com/rstudio/shiny/pull/1791))

### Bug fixes

* Fixed [#1546](https://github.com/rstudio/shiny/issues/1546): make it possible (without any hacks) to write arbitrary data into a module's `session$userData` (which is exactly the same environment as the parent's `session$userData`). To be clear, it allows something like `session$userData$x <- TRUE`, but not something like `session$userData <- TRUE` (that is not allowed in any context, whether you're in the main app, or in a module) ([#1732](https://github.com/rstudio/shiny/pull/1732)).

* Fixed [#1701](https://github.com/rstudio/shiny/issues/1701): There was a partial argument match in the `generateOptions` function. ([#1702](https://github.com/rstudio/shiny/pull/1702))

* Fixed [#1710](https://github.com/rstudio/shiny/issues/1710): `ReactiveVal` objects did not have separate dependents. ([#1712](https://github.com/rstudio/shiny/pull/1712))

* Fixed [#1438](https://github.com/rstudio/shiny/issues/1438): `unbindAll()` should not be called when inserting content with `insertUI()`. A previous fix ([#1449](https://github.com/rstudio/shiny/pull/1449)) did not work correctly. ([#1736](https://github.com/rstudio/shiny/pull/1736))

* Fixed [#1755](https://github.com/rstudio/shiny/issues/1755): dynamic htmlwidgets sent the path of the package on the server to the client. ([#1756](https://github.com/rstudio/shiny/pull/1756))

* Fixed [#1763](https://github.com/rstudio/shiny/issues/1763): Shiny's private random stream leaked out into the main random stream. ([#1768](https://github.com/rstudio/shiny/pull/1768))

* Fixed [#1680](https://github.com/rstudio/shiny/issues/1680): `options(warn=2)` was not respected when running an app. ([#1790](https://github.com/rstudio/shiny/pull/1790))

* Fixed [#1772](https://github.com/rstudio/shiny/issues/1772): ensure that `runApp()` respects the `shinyApp(onStart = function())` argument. ([#1770](https://github.com/rstudio/shiny/pull/1770))

* Fixed [#1474](https://github.com/rstudio/shiny/issues/1474): A `browser()` call in an observer could cause an error in the RStudio IDE on Windows. ([#1802](https://github.com/rstudio/shiny/pull/1802))


shiny 1.0.3
================

This is a hotfix release of Shiny. With previous versions of Shiny, when running an application on the newly-released version of R, 3.4.0, it would print a message: `Warning in body(fun) : argument is not a function`. This has no effect on the application, but because the message could be alarming to users, we are releasing a new version of Shiny that fixes this issue.

## Full changelog

### Bug fixes

* Fixed [#1672](https://github.com/rstudio/shiny/issues/1672): When an error occurred while uploading a file, the progress bar did not change colors. ([#1673](https://github.com/rstudio/shiny/pull/1673))

* Fixed [#1676](https://github.com/rstudio/shiny/issues/1676): On R 3.4.0, running a Shiny application gave a warning: `Warning in body(fun) : argument is not a function`. ([#1677](https://github.com/rstudio/shiny/pull/1677))


shiny 1.0.2
================

This is a hotfix release of Shiny. The primary reason for this release is because the web host for MathJax JavaScript library is scheduled to be shut down in the next few weeks. After it is shut down, Shiny applications that use MathJax will no longer be able to load the MathJax library if they are run with Shiny 1.0.1 and below. (If you don't know whether your application uses MathJax, it probably does not.) For more information about why the MathJax CDN is shutting down, see https://www.mathjax.org/cdn-shutting-down/.

## Full changelog

### Minor new features and improvements

* Added a `shiny:sessioninitialized` Javascript event, which is fired at the end of the initialize method of the Session object. This allows us to listen for this event when we want to get the value of things like `Shiny.user`. ([#1568](https://github.com/rstudio/shiny/pull/1568))

* Fixed [#1649](https://github.com/rstudio/shiny/issues/1649): allow the `choices` argument in `checkboxGroupInput()` to be `NULL` (or `c()`) to keep backward compatibility with Shiny < 1.0.1. This will result in the same thing as providing `choices = character(0)`. ([#1652](https://github.com/rstudio/shiny/pull/1652))

* The official URL for accessing MathJax libraries over CDN has been deprecated and will be removed soon. We have switched to a new rstudio.com URL that we will support going forward. ([#1664](https://github.com/rstudio/shiny/pull/1664))

### Bug fixes

* Fixed [#1653](https://github.com/rstudio/shiny/issues/1653): wrong code example in documentation. ([#1658](https://github.com/rstudio/shiny/pull/1658))


shiny 1.0.1
================

This is a maintenance release of Shiny, mostly aimed at fixing bugs and introducing minor features. The most notable additions in this version of Shiny are the introduction of the `reactiveVal()` function (it's like `reactiveValues()`, but it only stores a single value), and that the choices of `radioButtons()` and `checkboxGroupInput()` can now contain HTML content instead of just plain text.

## Full changelog

### Breaking changes

* The functions `radioButtons()`, `checkboxGroupInput()` and `selectInput()` (and the corresponding `updateXXX()` functions) no longer accept a `selected` argument whose value is the name of a choice, instead of the value of the choice. This feature had been deprecated since Shiny 0.10 (it printed a warning message, but still tried to match the name to the right choice) and it's now completely unsupported.

### New features

* Added `reactiveVal` function, for storing a single value which can be (reactively) read and written. Similar to `reactiveValues`, except that `reactiveVal` just lets you store a single value instead of storing multiple values by name. ([#1614](https://github.com/rstudio/shiny/pull/1614))

### Minor new features and improvements

* Fixed [#1637](https://github.com/rstudio/shiny/issues/1637): Outputs stay faded on MS Edge. ([#1640](https://github.com/rstudio/shiny/pull/1640))

* Addressed [#1348](https://github.com/rstudio/shiny/issues/1348) and [#1437](https://github.com/rstudio/shiny/issues/1437) by adding two new arguments to `radioButtons()` and `checkboxGroupInput()`: `choiceNames` (list or vector) and `choiceValues` (list or vector). These can be passed in as an alternative to `choices`, with the added benefit that the elements in `choiceNames` can be arbitrary UI (i.e. anything created by `HTML()` and the `tags()` functions, like icons and images). While the underlying values for each choice (passed in through `choiceValues`) must still be simple text, their visual representation on the app (what the user actually clicks to select a different option) can be any valid HTML element. See `?radioButtons` for a small example. ([#1521](https://github.com/rstudio/shiny/pull/1521))

* Updated `tools/README.md` with more detailed instructions. ([#1616](https://github.com/rstudio/shiny/pull/1616))

* Fixed [#1565](https://github.com/rstudio/shiny/issues/1565), which meant that resources with spaces in their names return HTTP 404. ([#1566](https://github.com/rstudio/shiny/pull/1566))

* Exported `session$user` (if it exists) to the client-side; it's accessible in the Shiny object: `Shiny.user`. ([#1563](https://github.com/rstudio/shiny/pull/1563))

* Added support for HTML5's `pushState` which allows for pseudo-navigation
in shiny apps. For more info, see the documentation (`?updateQueryString` and `?getQueryString`). ([#1447](https://github.com/rstudio/shiny/pull/1447))

* Fixed [#1121](https://github.com/rstudio/shiny/issues/1121): plot interactions with ggplot2 now support `coord_fixed()`. ([#1525](https://github.com/rstudio/shiny/pull/1525))

* Added `snapshotExclude` function, which marks an output so that it is not recorded in a test snapshot. ([#1559](https://github.com/rstudio/shiny/pull/1559))

* Added `shiny:filedownload` JavaScript event, which is triggered when a `downloadButton` or `downloadLink` is clicked. Also, the values of `downloadHandler`s are not recorded in test snapshots, because the values change every time the application is run. ([#1559](https://github.com/rstudio/shiny/pull/1559))

* Added support for plot interactions with ggplot2 > 2.2.1. ([#1578](https://github.com/rstudio/shiny/pull/1578))

* Fixed [#1577](https://github.com/rstudio/shiny/issues/1577): Improved `escapeHTML` (util.js) in terms of the order dependency of replacing, XSS risk attack and performance. ([#1579](https://github.com/rstudio/shiny/pull/1579))

* The `shiny:inputchanged` JavaScript event now includes two new fields, `binding` and `el`, which contain the input binding and DOM element, respectively. Additionally, `Shiny.onInputChange()` now accepts an optional argument, `opts`, which can contain the same fields. ([#1596](https://github.com/rstudio/shiny/pull/1596))

* The `NS()` function now returns a vectorized function. ([#1613](https://github.com/rstudio/shiny/pull/1613))

* Fixed [#1617](https://github.com/rstudio/shiny/issues/1617): `fileInput` can have customized text for the button and the placeholder. ([#1619](https://github.com/rstudio/shiny/pull/1619))

### Bug fixes

* Fixed [#1511](https://github.com/rstudio/shiny/issues/1511): `fileInput`s did not trigger the `shiny:inputchanged` event on the client. Also removed `shiny:fileuploaded` JavaScript event, because it is no longer needed after this fix. ([#1541](https://github.com/rstudio/shiny/pull/1541), [#1570](https://github.com/rstudio/shiny/pull/1570))

* Fixed [#1472](https://github.com/rstudio/shiny/issues/1472): With a Progress object, calling `set(value=NULL)` made the progress bar go to 100%. Now it does not change the value of the progress bar. The documentation also incorrectly said that setting the `value` to `NULL` would hide the progress bar. ([#1547](https://github.com/rstudio/shiny/pull/1547))

* Fixed [#162](https://github.com/rstudio/shiny/issues/162): When a dynamically-generated input changed to a different `inputType`, it might be incorrectly deduplicated.  ([#1594](https://github.com/rstudio/shiny/pull/1594))

* Removed redundant call to `inputs.setInput`. ([#1595](https://github.com/rstudio/shiny/pull/1595))

* Fixed bug where `dateRangeInput` did not respect `weekstart` argument. ([#1592](https://github.com/rstudio/shiny/pull/1592))

* Fixed [#1598](https://github.com/rstudio/shiny/issues/1598): `setBookmarkExclude()` did not work properly inside of modules. ([#1599](https://github.com/rstudio/shiny/pull/1599))

* Fixed [#1605](https://github.com/rstudio/shiny/issues/1605): sliders did not move when clicked on the bar area. ([#1610](https://github.com/rstudio/shiny/pull/1610))

* Fixed [#1621](https://github.com/rstudio/shiny/issues/1621): if a `reactiveTimer`'s session was closed before the first time that the `reactiveTimer` fired, then the `reactiveTimer` would not get cleared and would keep firing indefinitely. ([#1623](https://github.com/rstudio/shiny/pull/1623))

* Fixed [#1634](https://github.com/rstudio/shiny/issues/1634): If brushing on a plot causes the plot to redraw, then the redraw could in turn trigger the plot to redraw again and again. This was due to spurious changes in values of floating point numbers. ([#1641](https://github.com/rstudio/shiny/pull/1641))

### Library updates

* Closed [#1500](https://github.com/rstudio/shiny/issues/1500): Updated ion.rangeSlider to 2.1.6. ([#1540](https://github.com/rstudio/shiny/pull/1540))


shiny 1.0.0
===========

Shiny has reached a milestone: version 1.0.0! In the last year, we've added two major features that we considered essential for a 1.0.0 release: bookmarking, and support for testing Shiny applications. As usual, this version of Shiny also includes many minor features and bug fixes.

Here are some highlights from this release. For more details, see the full changelog below.

## Support for testing Shiny applications

Shiny now supports automated testing of applications, with the [shinytest](https://github.com/rstudio/shinytest) package. Shinytest has not yet been released on CRAN, but will be soon. ([#18](https://github.com/rstudio/shiny/issues/18), [#1464](https://github.com/rstudio/shiny/pull/1464))

## Debounce/throttle reactives

Now there's an official way to slow down reactive values and expressions that invalidate too quickly. Pass a reactive expression to the new `debounce` or `throttle` function, and get back a modified reactive expression that doesn't invalidate as often. ([#1510](https://github.com/rstudio/shiny/pull/1510))

## Full changelog

### Breaking changes

* Added a new `placeholder` argument to `verbatimTextOutput()`. The default is `FALSE`, which means that, if there is no content for this output, no representation of this slot will be made in the UI. Previsouly, even if there was no content, you'd see an empty rectangle in the UI that served as a placeholder. You can set `placeholder = TRUE` to revert back to that look. ([#1480](https://github.com/rstudio/shiny/pull/1480))

### New features

* Added support for testing Shiny applications with the shinytest package. ([#18](https://github.com/rstudio/shiny/issues/18), [#1464](https://github.com/rstudio/shiny/pull/1464))

* Added `debounce` and `throttle` functions, to control the rate at which reactive values and expressions invalidate. ([#1510](https://github.com/rstudio/shiny/pull/1510))

### Minor new features and improvements

* Addressed [#1486](https://github.com/rstudio/shiny/issues/1486) by adding a new argument to `observeEvent` and `eventReactive`, called `ignoreInit` (defaults to `FALSE` for backwards compatibility). When set to `TRUE`, the action (i.e. the second argument: `handlerExpr` and `valueExpr`, respectively) will not be triggered when the observer/reactive is first created/initialized. In other words, `ignoreInit = TRUE` ensures that the `observeEvent` (or `eventReactive`) is *never* run right away. For more info, see the documentation (`?observeEvent`). ([#1494](https://github.com/rstudio/shiny/pull/1494))
    
* Added a new argument to `observeEvent` called `once`. When set to `TRUE`, it results in the observer being destroyed (stop observing) after the first time that `handlerExpr` is run (i.e. `once = TRUE` guarantees that the observer only runs, at most, once). For more info, see the documentation (`?observeEvent`). ([#1494](https://github.com/rstudio/shiny/pull/1494))

* Addressed [#1358](https://github.com/rstudio/shiny/issues/1358): more informative error message when calling `runApp()` inside of an app's app.R (or inside ui.R or server.R). ([#1482](https://github.com/rstudio/shiny/pull/1482))

* Added a more descriptive JS warning for `insertUI()` when the selector argument does not match anything in DOM. ([#1488](https://github.com/rstudio/shiny/pull/1488))

* Added support for injecting JavaScript code when the `shiny.testmode` option is set to `TRUE`. This makes it possible to record test events interactively. ([#1464](https://github.com/rstudio/shiny/pull/1464))

* Added ability through arguments to the `a` tag function called inside `downloadButton()` and `downloadLink()`. Closes [#986](https://github.com/rstudio/shiny/issues/986). ([#1492](https://github.com/rstudio/shiny/pulls/1492))

* Implemented [#1512](https://github.com/rstudio/shiny/issues/1512): added a `userData` environment to `session`, for storing arbitrary session-related variables. Generally, session-scoped variables are created just by declaring normal variables that are local to the Shiny server function, but `session$userData` may be more convenient for some advanced scenarios. ([#1513](https://github.com/rstudio/shiny/pull/1513))

* Relaxed naming requirements for `addResourcePath()` (the first character no longer needs to be a letter). ([#1529](https://github.com/rstudio/shiny/pull/1529))

### Bug fixes

* Fixed [#969](https://github.com/rstudio/shiny/issues/969): allow navbarPage's `fluid` param to control both containers. ([#1481](https://github.com/rstudio/shiny/pull/1481))

* Fixed [#1438](https://github.com/rstudio/shiny/issues/1438): `unbindAll()` should not be called when inserting content with `insertUI()` ([#1449](https://github.com/rstudio/shiny/pull/1449))

* Fixed bug causing `<meta>` tags associated with HTML dependencies of Shiny R Markdown files to be rendered incorrectly. ([#1463](https://github.com/rstudio/shiny/pull/1463))

* Fixed [#1359](https://github.com/rstudio/shiny/issues/1359): `shinyApp()` options argument ignored when passed to `runApp()`. ([#1483](https://github.com/rstudio/shiny/pull/1483))

* Fixed [#117](https://github.com/rstudio/shiny/issues/117): Reactive expressions now release references to cached values as soon as they are invalidated, potentially making those cached values eligible for garbage collection sooner. Previously, this would not occur until the next cached value was calculated and stored. ([#1504](https://github.com/rstudio/shiny/pull/1504/files))

* Fixed [#1013](https://github.com/rstudio/shiny/issues/1013): `flushReact` should be called after app loads. Observers set up outside of server functions were not running until after the first user connects. ([#1503](https://github.com/rstudio/shiny/pull/1503))

* Fixed [#1453](https://github.com/rstudio/shiny/issues/1453): When using a modal dialog with `easyClose=TRUE` in a Shiny gadget, pressing Esc would close both the modal and the gadget. Now pressing Esc only closes the modal. ([#1523](https://github.com/rstudio/shiny/pull/1523))

### Library updates

* Updated to Font Awesome 4.7.0.


shiny 0.14.2
============

This is a maintenance release of Shiny, with some bug fixes and minor new features.

## Full changelog

### Minor new features and improvements

* Added a `fade` argument to `modalDialog()` -- setting it to `FALSE` will remove the usual fade-in animation for that modal window. ([#1414](https://github.com/rstudio/shiny/pull/1414))

* Fixed a "duplicate binding" error that occurred in some edge cases involving `insertUI` and nested `uiOutput`. ([#1402](https://github.com/rstudio/shiny/pull/1402))

* Fixed [#1422](https://github.com/rstudio/shiny/issues/1422): When using the `shiny.trace` option, allow specifying to only log SEND or RECV messages, or both. (PR [#1428](https://github.com/rstudio/shiny/pull/1428))

* Fixed [#1419](https://github.com/rstudio/shiny/issues/1419): Allow overriding a JS custom message handler. (PR [#1445](https://github.com/rstudio/shiny/pull/1445))

* Added `exportTestValues()` function, which allows a test driver to query the session for values internal to an application's server function. This only has an effect if the `shiny.testmode` option is set to `TRUE`. ([#1436](https://github.com/rstudio/shiny/pull/1436))

### Bug fixes

* Fixed [#1427](https://github.com/rstudio/shiny/issues/1427): make sure that modals do not close incorrectly when an element inside them is triggered as hidden. ([#1430](https://github.com/rstudio/shiny/pull/1430))

* Fixed [#1404](https://github.com/rstudio/shiny/issues/1404): stack trace tests were not compatible with the byte-code compiler in R-devel, which now tracks source references.

* `sliderInputBinding.setValue()` now sends a slider's value immediately, instead of waiting for the usual 250ms debounce delay. ([#1429](https://github.com/rstudio/shiny/pull/1429))

* Fixed a bug where, in versions of R before 3.2, Shiny applications could crash due to a bug in R's implementation of `list2env()`. ([#1446](https://github.com/rstudio/shiny/pull/1446))

shiny 0.14.1
============

This is a maintenance release of Shiny, with some bug fixes and minor new features.

## Full changelog

### Minor new features and improvements

* Restored file inputs are now copied on restore, so that the restored application can't modify the bookmarked file. ([#1370](https://github.com/rstudio/shiny/issues/1370))

* Added support for plot interaction in the development version of ggplot2, 2.1.0.9000. Also added support for ggplot2 plots with `coord_flip()` (in the development version of ggplot2). ([hadley/ggplot2#1781](https://github.com/hadley/ggplot2/issues/1781), [#1392](https://github.com/rstudio/shiny/pull/1392))


### Bug fixes

* Fixed [#1093](https://github.com/rstudio/shiny/issues/1093) better: `updateRadioButtons()` and `updateCheckboxGroupInput()` were not working correctly if the choices were given as a numeric vector. This had been solved in [#1291](https://github.com/rstudio/shiny/pull/1291), but that introduced a different bug [#1396](https://github.com/rstudio/shiny/issues/1396) that this better fix avoids. ([#1370](https://github.com/rstudio/shiny/pull/1397))

* Fixed [#1368](https://github.com/rstudio/shiny/issues/1368): If an app with a file input was bookmarked and restored, and then the restored app was bookmarked and restored (without uploading a new file), then it would fail to restore the file the second time. ([#1370](https://github.com/rstudio/shiny/pull/1370))

* Fixed [#1369](https://github.com/rstudio/shiny/issues/1369): `sliderInput()` did not allow showing numbers without a thousands separator.

* Fixed [#1346](https://github.com/rstudio/shiny/issues/1346) and [#1107](https://github.com/rstudio/shiny/issues/1107) : jQuery UI's datepicker conflicted with the bootstrap-datepicker used by Shiny's `dateInput()` and `dateRangeInput()`. ([#1374](https://github.com/rstudio/shiny/pull/1374))

### Library updates

* Updated to bootstrap-datepicker 1.6.4. ([#1218](https://github.com/rstudio/shiny/issues/1218), [#1374](https://github.com/rstudio/shiny/pull/1374))

* Updated to jQuery UI 1.12.1. Previously, Shiny included a build of 1.11.4 which was missing the datepicker component due to a conflict with the bootstrap-datepicker used by Shiny's `dateInput()` and `dateRangeInput()`. ([#1374](https://github.com/rstudio/shiny/pull/1374))


shiny 0.14
==========

A new Shiny release is upon us! There are many new exciting features, bug fixes, and library updates. We'll just highlight the most important changes here, but you can browse through the full changelog below for details. This will likely be the last release before shiny 1.0, so get out your party hats!

## Bookmarkable state

Shiny now supports bookmarkable state: users can save the state of an application and get a URL which will restore the application with that state. There are two types of bookmarking: encoding the state in a URL, and saving the state to the server. With an encoded state, the entire state of the application is contained in the URL’s query string. You can see this in action with this app: https://gallery.shinyapps.io/113-bookmarking-url/. An example of a bookmark URL for this app is https://gallery.shinyapps.io/113-bookmarking-url/?_inputs_&n=200. When the state is saved to the server, the URL might look something like: https://gallery.shinyapps.io/bookmark-saved/?_state_id_=d80625dc681e913a (note that this URL is not for an active app).

**_Important note_:**
> Saved-to-server bookmarking currently works with Shiny Server Open Source. Support on Shiny Server Pro, RStudio Connect, and shinyapps.io is under development and testing. However, URL-encoded bookmarking works on all hosting platforms.

See [this article](http://shiny.rstudio.com/articles/bookmarking-state.html) to get started with bookmarkable state. There is also an [advanced-level article](http://shiny.rstudio.com/articles/advanced-bookmarking.html) (for apps that have a complex state), and [a modules article](http://shiny.rstudio.com/articles/bookmarking-modules.html) that details how to use bookmarking in conjunction with modules.

## Notifications

Shiny can now display notifications on the client browser by using the `showNotification()` function. Use [this demo app](https://gallery.shinyapps.io/116-notifications/) to play around with the notification API. Here's a screenshot of a very simple notification (shown when the button is clicked):

<p align="center">
<img src="http://shiny.rstudio.com/images/notification.png" alt="notification" width="50%"/>
</p>

[Here](http://shiny.rstudio.com/articles/notifications.html)'s our article about it, and the [reference documentation](http://shiny.rstudio.com/reference/shiny/latest/showNotification.html).

## Progress indicators

If your Shiny app contains computations that take a long time to complete, a progress bar can improve the user experience by communicating how far along the computation is, and how much is left. Progress bars were added in Shiny 0.10.2. In Shiny 0.14, they were changed to use the notifications system, which gives them a different look.

**_Important note_:**
> If you were already using progress bars and had customized them with your own CSS, you can add the `style = "old"` argument to your `withProgress()` call (or `Progress$new()`). This will result in the same appearance as before. You can also call `shinyOptions(progress.style = "old")` in your app's server function to make all progress indicators use the old styling.

To see new progress bars in action, see [this app](https://gallery.shinyapps.io/085-progress/) in the gallery. You can also learn more about this in [our article](http://shiny.rstudio.com/articles/progress.html) and in the reference documentation (either for the easier [`withProgress` functional API](http://shiny.rstudio.com/reference/shiny/latest/withProgress.html) or the more complicated, but more powerful, [`Progress` object-oriented API](http://shiny.rstudio.com/reference/shiny/latest/Progress.html).

## Reconnection

Shiny can now automatically reconnect to your Shiny session if you temporarily lose network access.

## Modal windows

Shiny has now built-in support for displaying modal dialogs like the one below ([live app here](https://gallery.shinyapps.io/114-modal-dialog/)):

<p align="center">
<img src="http://shiny.rstudio.com/images/modal-dialog.png" alt="modal-dialog" width="50%"/>
</p>

To learn more about this, read [our article](http://shiny.rstudio.com/articles/modal-dialogs.html) and the [reference documentation](http://shiny.rstudio.com/reference/shiny/latest/modalDialog.html).

## `insertUI` and `removeUI`

Sometimes in a Shiny app, arbitrary HTML UI may need to be created on-the-fly in response to user input. The existing `uiOutput` and `renderUI` functions let you continue using reactive logic to call UI functions and make the results appear in a predetermined place in the UI. The `insertUI` and `removeUI` functions, which are used in the server code, allow you to use imperative logic to add and remove arbitrary chunks of HTML (all independent from one another), as many times as you want, whenever you want, wherever you want. This option may be more convenient when you want to, for example, add a new model to your app each time the user selects a different option (and leave previous models unchanged, rather than substitute the previous one for the latest one).

See [this simple demo app](https://gallery.shinyapps.io/111-insert-ui/) of how one could use `insertUI` and `removeUI` to insert and remove text elements using a queue. Also see [this other app](https://gallery.shinyapps.io/insertUI/) that demonstrates how to insert and remove a few common Shiny input objects. Finally, [this app](https://gallery.shinyapps.io/insertUI-modules/) shows how to dynamically insert modules using `insertUI`.

For more, read [our article](http://shiny.rstudio.com/articles/dynamic-ui.html) about dynamic UI generation and the reference documentation about [`insertUI`](http://shiny.rstudio.com/reference/shiny/latest/insertUI.html) and [`removeUI`](http://shiny.rstudio.com/reference/shiny/latest/removeUI.html).

## Documentation for connecting to an external database

Many Shiny users have asked about best practices for accessing external databases from their Shiny applications. Although database access has long been possible using various database connector packages in R, it can be challenging to use them robustly in the dynamic environment that Shiny provides. So far, it has been mostly up to application authors to find the appropriate database drivers and to discover how to manage the database connections within an application. In order to demystify this process, we wrote a series of articles ([first one here](http://shiny.rstudio.com/articles/overview.html)) that covers the basics of connecting to an external database, as well as some security precautions to keep in mind (e.g. [how to avoid SQL injection attacks](http://shiny.rstudio.com/articles/sql-injections.html)).

There are a few packages that you should look at if you're using a relational database in a Shiny app: the `dplyr` and `DBI` packages (both featured in the article linked to above), and the brand new `pool` package, which provides a further layer of abstraction to make it easier and safer to use either `DBI` or `dplyr`. `pool` is not yet on CRAN. In particular, `pool` will take care of managing connections, preventing memory leaks, and ensuring the best performance. See this [`pool` basics article](http://shiny.rstudio.com/articles/pool-basics.html) and the [more advanced-level article](http://shiny.rstudio.com/articles/pool-advanced.html) if you're feeling adventurous! (Both of these articles contain Shiny app examples that use `DBI` to connect to an external MySQL database.) If you are more comfortable with `dplyr` than `DBI`, don't miss the article about the [integration of `pool` and `dplyr`](http://shiny.rstudio.com/articles/pool-dplyr.html).

If you're new to databases in the Shiny world, we recommend using `dplyr` and `pool` if possible. If you need greater control than `dplyr` offers (for example, if you need to modify data in the database or use transactions), then use `DBI` and `pool`. The `pool` package was introduced to make your life easier, but in no way constrains you, so we don't envision any situation in which you'd be better off *not* using it. The only caveat is that `pool` is not yet on CRAN, so you may prefer to wait for that.

## Others

There are many more minor features, small improvements, and bug fixes than we can cover here, so we'll just mention a few of the more noteworthy ones (the full changelog, with links to all the relevant issues and pull requests, is right below this section):

*    **Error Sanitization**: you now have the option to sanitize error messages; in other words, the content of the original error message can be suppressed so that it doesn't leak any sensitive information. To sanitize errors everywhere in your app, just add `options(shiny.sanitize.errors = TRUE)` somewhere in your app. Read [this article](http://shiny.rstudio.com/articles/sanitize-errors.html) for more, or play with the [demo app](https://gallery.shinyapps.io/110-error-sanitization/).

*    **Code Diagnostics**: if there is an error parsing `ui.R`, `server.R`, `app.R`, or `global.R`, Shiny will search the code for missing commas, extra commas, and unmatched braces, parens, and brackets, and will print out messages pointing out those problems. ([#1126](https://github.com/rstudio/shiny/pull/1126))

*    **Reactlog visualization**: by default, the [`showReactLog()` function](http://shiny.rstudio.com/reference/shiny/latest/showReactLog.html) (which brings up the reactive graph) also displays the time that each reactive and observer were active for:

      <p align="center">
      <img src="http://shiny.rstudio.com/images/reactlog.png" alt="modal-dialog" width="75%"/>
      </p>

      This new feature can be turned off with `showReactLog(time = FALSE)`. This may be convenient if you have a large graph and don't want to have this new information cluttering it up. The elapsed time info shows up above each relevant node's label, and the time is also coded by color: the slowest reactive will be dark red and the fastest will be light red.

      Additionally, to organize the graph, you can now drag any of the nodes to a specific position and leave it there.

*    **Nicer-looking tables**: we've made tables generated with `renderTable()` look cleaner and more modern. While this won't break any older code, the finished look of your table will be quite a bit different, as the following image shows:

      <p align="center">
      <img src="http://shiny.rstudio.com/images/render-table.png" alt="render-table" width="75%"/>
      </p>

      For more, read our [short article](http://shiny.rstudio.com/articles/render-table.html) about this update, experiment with all the new features in this [demo app](https://gallery.shinyapps.io/109-render-table/), or check out the [reference documentation](http://shiny.rstudio.com/reference/shiny/latest/renderTable.html).

## Full changelog

### Breaking changes

* Progress indicators can now either use the new notification API, using `style = "notification"` (default), or be displayed with the previous styling, using `style = "old"`. You can also call `shinyOptions(progress.style = "old")` in the server function to make all progress indicators use the old styling. Note that if you had customized your progress indicators with additional CSS, you'll need to use the old style if you want your UI to look the same ([#1160](https://github.com/rstudio/shiny/pull/1160) and [#1329](https://github.com/rstudio/shiny/pull/1329)).

* Closed [#1161](https://github.com/rstudio/shiny/issues/1161): Deprecated the `position` argument to `tabsetPanel()` since Bootstrap 3 stopped supporting this feature.

* The long-deprecated ability to pass a `func` argument to many of the `render` functions has been removed.

### New features

* Added the ability to bookmark and restore application state. (main PR: [#1209](https://github.com/rstudio/shiny/pull/1209))

* Added a new notification API. From R, there are new functions `showNotification` and `hideNotification`. From JavaScript, there is a new `Shiny.notification` object that controls notifications. ([#1141](https://github.com/rstudio/shiny/pull/1141))

* Progress indicators now use the notification API. ([#1160](https://github.com/rstudio/shiny/pull/1160))

* Added the ability for the client browser to reconnect to a new session on the server, by setting `session$allowReconnect(TRUE)`. This requires a version of Shiny Server that supports reconnections. ([#1074](https://github.com/rstudio/shiny/pull/1074))

* Added modal dialogs. ([#1157](https://github.com/rstudio/shiny/pull/1157))

* Added insertUI and removeUI functions to be able to add and remove chunks of UI, standalone, and all independent of one another. ([#1174](https://github.com/rstudio/shiny/pull/1174) and [#1189](https://github.com/rstudio/shiny/pull/1189))

* Improved `renderTable()` function to make the tables look prettier and also provide the user with a lot more parameters to customize their tables with. ([#1129](https://github.com/rstudio/shiny/pull/1129))

* Added support for the `pool` package (use Shiny's timer/scheduler). ([#1226](https://github.com/rstudio/shiny/pull/1226))

### Minor new features and improvements

* Added `cancelOutput` argument to `req()`. This causes the currently executing reactive to cancel its execution, and leave its previous state alone (as opposed to clearing the output). ([#1272](https://github.com/rstudio/shiny/pull/1272))

* `Display: Showcase` now displays the .js, .html and .css files in the `www` directory by default. In order to use showcase mode and not display these, include a new line in your Description file: `IncludeWWW: False`. ([#1185](https://github.com/rstudio/shiny/pull/1185))

* Added an error sanitization option: `options(shiny.sanitize.errors = TRUE)`. By default, this option is `FALSE`. When `TRUE`, normal errors will be sanitized, displaying only a generic error message. This changes the look of an app when errors are printed (but the console log remains the same). ([#1156](https://github.com/rstudio/shiny/pull/1156))

* Added the option of passing arguments to an `xxxOutput()` function through the corresponding `renderXXX()` function via an `outputArgs` parameter to the latter. This is only valid for snippets of Shiny code in an interactive `runtime: shiny` Rmd document (never for full apps, even if embedded in an Rmd). ([#1443](https://github.com/rstudio/shiny/pull/1143))

* Added `updateActionButton()` function, so the user can change an `actionButton`'s (or `actionLink`'s) label and/or icon. It also checks that the icon argument (for both creation and updating of a button) is valid and throws a warning otherwise. ([#1134](https://github.com/rstudio/shiny/pull/1134))

* Added code diagnostics: if there is an error parsing ui.R, server.R, app.R, or global.R, Shiny will search the code for missing commas, extra commas, and unmatched braces, parens, and brackets, and will print out messages pointing out those problems. ([#1126](https://github.com/rstudio/shiny/pull/1126))

* Added support for horizontal dividers in `navbarMenu`. ([#1147](https://github.com/rstudio/shiny/pull/1147))

* Added `placeholder` option to `passwordInput`. ([#1152](https://github.com/rstudio/shiny/pull/1152))

* Added `session$resetBrush(brushId)` (R) and `Shiny.resetBrush(brushId)` (JS) to programatically clear brushes from `imageOutput`/`plotOutput`. ([#1197](https://github.com/rstudio/shiny/pull/1197))

* Added textAreaInput. (thanks, [@nuno-agostinho](https://github.com/nuno-agostinho)! [#1300](https://github.com/rstudio/shiny/pull/1300))

* Added `session$sendBinaryMessage(type, message)` method for sending custom binary data to the client. See `?session`. (thanks, [@daef](https://github.com/daef)! [#1316](https://github.com/rstudio/shiny/pull/1316) and [#1320](https://github.com/rstudio/shiny/pull/1320))

* Almost all code examples now have a runnable example with `shinyApp()`, so that users can run the examples and see them in action. ([#1158](https://github.com/rstudio/shiny/pull/1158))

* When resized, plots are drawn with `replayPlot()`, instead of re-executing all plotting code. This results in faster plot rendering. ([#1112](https://github.com/rstudio/shiny/pull/1112))

* Exported the `isTruthy()` function. (part of PR [#1272](https://github.com/rstudio/shiny/pull/1272))

* Reactive log now shows elapsed time for reactives and observers. ([#1132](https://github.com/rstudio/shiny/pull/1132))

* Nodes in the reactlog visualization are now sticky if the user drags them. ([#1283](https://github.com/rstudio/shiny/pull/1283))

### Bug fixes

* Fixed [#1350](https://github.com/rstudio/shiny/issues/1350): Highlighting of reactives didn't work in showcase mode.

* Fixed [#1331](https://github.com/rstudio/shiny/issues/1331): `renderPlot()` now correctly records and replays plots when `execOnResize = FALSE`.

* `updateDateInput()` and `updateDateRangeInput()` can now clear the date input fields. (thanks, [@gaborcsardi](https://github.com/gaborcsardi)! [#1299](https://github.com/rstudio/shiny/pull/1299), [#1315](https://github.com/rstudio/shiny/pull/1315) and  [#1317](https://github.com/rstudio/shiny/pull/1317))

* Fixed [#561](https://github.com/rstudio/shiny/issues/561): DataTables previously might pop up a warning when the data was updated extremely frequently.

* Fixed [#776](https://github.com/rstudio/shiny/issues/776): In some browsers, plots sometimes flickered when updated.

* Fixed [#543](https://github.com/rstudio/shiny/issues/543) and [#855](https://github.com/rstudio/shiny/issues/855): When `navbarPage()` had a `navbarMenu()` as the first item, it did not automatically select an item.

* Fixed [#970](https://github.com/rstudio/shiny/issues/970): `navbarPage()` previously did not have an option to set the selected tab.

* Fixed [#1253](https://github.com/rstudio/shiny/issues/1253): Memory could leak when an observer was destroyed without first being invalidated.

* Fixed [#931](https://github.com/rstudio/shiny/issues/931): Nested observers could leak memory.

* Fixed [#1144](https://github.com/rstudio/shiny/issues/1144): `updateRadioButton()` and `updateCheckboxGroupInput()` broke controls when used in modules (thanks, [@sipemu](https://github.com/sipemu)!).

* Fixed [#1093](https://github.com/rstudio/shiny/issues/1093): `updateRadioButtons()` and `updateCheckboxGroupInput()` didn't work if `choices` was numeric vector.

* Fixed [#1122](https://github.com/rstudio/shiny/issues/1122): `downloadHandler()` popped up empty browser window if the file wasn't present. It now gives a 404 error code.

* Fixed [#1278](https://github.com/rstudio/shiny/issues/1278): Reactive system was being flushed too often (usually this just means a more-expensive no-op than necessary).

* Fixed [#803](https://github.com/rstudio/shiny/issues/803) and [#1179](https://github.com/rstudio/shiny/issues/1179): handling malformed dates in `dateInput` and `updateDateInput()`.

* Fixed [#1257](https://github.com/rstudio/shiny/issues/1257): `updateSelectInput()` didn't work correctly in IE 11 and Edge.

* Fixed [#971](https://github.com/rstudio/shiny/issues/971): `runApp()` would give confusing error if `port` was not numeric.

* Shiny now avoids using ports that Chrome deems unsafe. ([#1222](https://github.com/rstudio/shiny/pull/1222))

* Added workaround for quartz graphics device resolution bug, where resolution is hard-coded to 72 ppi.

### Library updates

* Updated to ion.RangeSlider 2.1.2.

* Updated to Font Awesome 4.6.3.

* Updated to Bootstrap 3.3.7.

* Updated to jQuery 1.12.4.


shiny 0.13.2
============

* Updated documentation for `htmlTemplate`.


shiny 0.13.1
============

* `flexCol` did not work on RStudio for Windows or Linux.

* Fixed RStudio debugger integration.

* BREAKING CHANGE: The long-deprecated ability to pass functions (rather than expressions) to reactive() and observe() has finally been removed.


shiny 0.13.0
============

* Fixed #962: plot interactions did not work with the development version of ggplot2 (after ggplot2 1.0.1).

* Fixed #902: the `drag_drop` plugin of the selectize input did not work.

* Fixed #933: `updateSliderInput()` does not work when only the label is updated.

* Multiple imageOutput/plotOutput calls can now share the same brush id. Shiny will ensure that performing a brush operation will clear any other brush with the same id.

* Added `placeholder` option to `textInput`.

* Improved support for Unicode characters on Windows (#968).

* Fixed bug in `selectInput` and `selectizeInput` where values with double quotes were not properly escaped.

* `runApp()` can now take a path to any .R file that yields a `shinyApp` object; previously, the path had to be a directory that contained an app.R file (or server.R if using separately defined server and UI). Similarly, introduced `shinyAppFile()` function which creates a `shinyApp` object for an .R file path, just as `shinyAppDir()` does for a directory path.

* Introduced Shiny Modules, which are designed to 1) simplify the reuse of Shiny UI/server logic and 2) make authoring and maintaining complex Shiny apps much easier. See the article linked from `?callModule`.

* `invalidateLater` and `reactiveTimer` no longer require an explicit `session` argument; the default value uses the current session.

* Added `session$reload()` method, the equivalent of hitting the browser's Reload button.

* Added `shiny.autoreload` option, which will automatically cause browsers to reload whenever Shiny app files change on disk. This is intended to shorten the feedback cycle when tweaking UI code.

* Errors are now printed with stack traces! This should make it tremendously easier to track down the causes of errors in Shiny. Try it by calling `stop("message")` from within an output, reactive, or observer. Shiny itself adds a lot of noise to the call stack, so by default, it attempts to hide all but the relevant levels of the call stack. You can turn off this behavior by setting `options(shiny.fullstacktrace=TRUE)` before or during app startup.

* Fixed #1018: the selected value of a selectize input is guaranteed to be selected in server-side mode.

* Added `req` function, which provides a simple way to prevent a reactive, observer, or output from executing until all required inputs and values are available. (Similar functionality has been available for a while using validate/need, but req provides a much simpler and more direct interface.)

* Improve stability with Shiny Server when many subapps are used, by deferring the loading of subapp iframes until a connection has first been established with the server.

* Upgrade to Font Awesome 4.5.0.

* Upgraded to Bootstrap 3.3.5.

* Upgraded to jQuery 1.12.4

* Switched to an almost-complete build of jQuery UI with the exception of the datepicker extension, which conflicts with Shiny's date picker.

* Added `fillPage` function, an alternative to `fluidPage`, `fixedPage`, etc. that is designed for apps that fill the entire available page width/height.

* Added `fillRow` and `fillCol` functions, for laying out proportional grids in `fillPage`. For modern browsers only.

* Added `runGadget`, `paneViewer`, `dialogViewer`, and `browserViewer` functions to support Shiny Gadgets. More detailed docs about gadgets coming soon.

* Added support for the new htmltools 0.3 feature `htmlTemplate`. It's now possible to use regular HTML markup to design your UI, but still use R expressions to define inputs, outputs, and HTML widgets.


shiny 0.12.2
============

* GitHub changed URLs for gists from .tar.gz to .zip, so `runGist` was updated to work with the new URLs.

* Callbacks from the session object are now guaranteed to execute in the order in which registration occurred.

* Minor bugs in sliderInput's animation behavior have been fixed. (#852)

* Updated to ion.rangeSlider to 2.0.12.

* Added `shiny.minified` option, which controls whether the minified version of shiny.js is used. Setting it to FALSe can be useful for debugging. (#826, #850)

* Fixed an issue for outputting plots from ggplot objects which also have an additional class whose print method takes precedence over `print.ggplot`. (#840, 841)

* Added `width` option to Shiny's input functions. (#589, #834)

* Added two alias functions of `updateTabsetPanel()` to update the selected tab: `updateNavbarPage()` and `updateNavlistPanel()`. (#881)

* All non-base functions are now explicitly namespaced, to pass checks in R-devel.

* Shiny now correctly handles HTTP HEAD requests. (#876)


shiny 0.12.1
============

* Fixed an issue where unbindAll() causes subsequent bindAll() to be ignored for previously bound outputs. (#856)

* Undeprecate `dataTableOutput` and `renderDataTable`, which had been deprecated in favor of the new DT package. The DT package is a bit too new and has a slightly different API, we were too hasty in deprecating the existing Shiny functions.


shiny 0.12.0
============

In addition to the changes listed below (in the *Full Changelog* section), there is an infrastructure change that could affect existing Shiny apps. 

### JSON serialization

In Shiny 0.12.0, we've switched from RJSONIO to jsonlite. For the vast majority of users, this will result in no noticeable changes; however, if you use any packages in your Shiny apps which rely on the [htmlwidgets](http://www.htmlwidgets.org/), you will also need to update htmlwidgets to 0.4.0. Both of these packages will issue a message when loaded, if the other package needs to be upgraded.

POSIXt objects are now serialized to JSON in UTC8601 format (like
"2015-03-20T20:00:00Z"), instead of as seconds from the epoch. If you have a Shiny app which uses `sendCustomMessage()` to send datetime (POSIXt) objects, then you may need to modify your Javascript code to receive time data in this format.

### A note about Data Tables

Shiny 0.12.0 deprecated Shiny's dataTableOutput and renderDataTable functions and instructed you to migrate to the nascent [DT](https://rstudio.github.io/DT/) package instead. (We'll talk more about DT in a future blog post.) User feedback has indicated this transition was too sudden and abrupt, so we've undeprecated these functions in 0.12.1. We'll continue to support these functions until DT has had more time to mature.

## Full Changelog

* Switched from RJSONIO to jsonlite. This improves consistency and speed when converting between R data structures and JSON. One notable change is that POSIXt objects are now serialized to JSON in UTC8601 format (like "2015-03-20T20:00:00Z"), instead of as seconds from the epoch).

* In addition to the existing support for clicking and hovering on plots created by base graphics, added support for double-clicking and brushing. (#769)

* Added support for clicking, hovering, double-clicking, and brushing for plots created by ggplot2, including support for facets. (#802)

* Added `nearPoints` and `brushedPoints` functions for easily selecting rows of data that are clicked/hovered, or brushed. (#802)

* Added `shiny.port` option. If this is option is set, `runApp()` will listen on this port by default. (#756)

* `runUrl`, `runGist`, and `runGitHub` now can save downloaded applications, with the `destdir` argument. (#688)

* Restored ability to set labels for `selectInput`. (#741)

* Travis continuous integration now uses Travis's native R support.

* Fixed encoding issue when the server receives data from the client browser. (#742)

* The `session` object now has class `ShinySession`, making it easier to test whether an object is indeed a session object. (#720, #746)

* Fix JavaScript error when an output appears in nested uiOutputs. (Thanks, Gregory Zhang. #749)

* Eliminate delay on receiving new value when `updateSliderInput(value=...)` is called.

* Updated to DataTables (Javascript library) 1.10.5.

* Fixed downloading of files that have no filename extension. (#575, #753)

* Fixed bug where nested UI outputs broke outputs. (#749, #750)

* Removed unneeded HTML ID attributes for `checkboxGroupInputs` and `radioButtons`. (#684)

* Fixed bug where checkboxes were still active even after `Shiny.unbindAll()` was called. (#206)

* The server side selectize input will load the first 1000 options by default before users start to type and search in the box. (#823)

* renderDataTable() and dataTableOutput() have been deprecated in shiny and will be removed in future versions of shiny. Please use the DT package instead: http://rstudio.github.io/DT/ (#807)


shiny 0.11.1
============

* Major client-side performance improvements for pages that have many conditionalPanels, tabPanels, and plotOutputs. (#693, #717, #723)

* `tabPanel`s now use the `title` for `value` by default. This fixes a bug in which an icon in the title caused problems with a conditionalPanel's test condition. (#725, #728)

* `selectInput` now has a `size` argument to control the height of the input box. (#729)

* `navbarPage` no longer includes a first row of extra whitespace when `header=NULL`. (#722)

* `selectInput`s now use Bootstrap styling when `selectize=FALSE`. (#724)

* Better vertical spacing of label for checkbox groups and radio buttons.

* `selectInput` correctly uses width for both selectize and non-selectize inputs. (#702)

* The wrapper tag generated by `htmlOutput` and `uiOutput` can now be any type of HTML tag, instead of just span and div. Also, custom classes are now allowed on the tag. (#704)

* Slider problems in IE 11 and Chrome on touchscreen-equipped Windows computers have been fixed. (#700)

* Sliders now work correctly with draggable panels. (#711)

* Fixed arguments in `fixedPanel`. (#709)

* downloadHandler content callback functions are now invoked with a temp file name that has the same extension as the final filename that will be used by the download. This is to deal with the fact that some file writing functions in R will auto-append the extension for their file type (pdf, zip).


shiny 0.11
==========

Shiny 0.11 switches away from the Bootstrap 2 web framework to the next version, Bootstrap 3. This is in part because Bootstrap 2 is no longer being developed, and in part because it allows us to tap into the ecosystem of Bootstrap 3 themes.


### Known issues for migration

*    In Bootstrap 3, images in `<img>` tags are no longer automatically scaled to the width of their container. If you use `img()` in your UI code, or `<img>` tags in your raw HTML source, it's possible that they will be too large in the new version of Shiny. To address this you can add the `img-responsive` class:
    
    ```r
    img(src = "picture.png", class = "img-responsive")
    ```
    
    The R code above will generate the following HTML:
    
    ```html
    <img src="picture.png" class="img-responsive">
    ```


*    The sliders have been replaced. Previously, Shiny used the [jslider](https://github.com/egorkhmelev/jslider) library, but now it uses [ion.RangeSlider](https://github.com/IonDen/ion.rangeSlider). The new sliders have an updated appearance, and they have allowed us to fix many long-standing interface issues with the sliders.

  * The `sliderInput()` function no longer uses the `format` or `locale` options. Instead, you can use `pre`, `post`, and `sep` options to control the prefix, postfix, and thousands separator.


  * `updateSliderInput()` can now control the min, max, value, and step size of a slider. Previously, only the value could be controlled this way, and if you wanted to change other values, you needed to use Shiny's dynamic UI.


*    If in your HTML you are using custom CSS classes that are specific to Bootstrap, you may need to update them for Bootstrap 3. See the Bootstrap [migration guide](http://getbootstrap.com/migration/).


If you encounter other migration issues, please let us know on the [shiny-discuss](https://groups.google.com/forum/#!forum/shiny-discuss) mailing list, or on the Shiny [issue tracker](https://github.com/rstudio/shiny/issues).

### Using shinybootstrap2

If you would like to use Shiny 0.11 with Bootstrap 2, you can use the **shinybootstrap2** package. Installation and usage instructions are on available on the [project page](https://github.com/rstudio/shinybootstrap2). We recommend that you do this only as a temporary solution because  future development on Shiny will use Bootstrap 3.

### Installing an older version of Shiny

If you want to install a specific version of Shiny other than the latest CRAN release, you can use the `install_version()` function from devtools:

```r
# Install devtools if you don't already have it:
install.package("devtools")

# Install the last version of Shiny prior to 0.11
devtools::install_version("shiny", "0.10.2.2")
```

### Themes

Along with the release of Shiny 0.11, we've packaged up some Bootstrap 3 themes in the [shinythemes](http://rstudio.github.io/shinythemes/) package. This package makes it easy to use Bootstrap themes with Shiny.

## Full Changelog

* Changed sliders from jquery-slider to ion.rangeSlider. These sliders have an improved appearance, support updating more properties from the server, and can be controlled with keyboard input.

* Switched from Bootstrap 2 to Bootstrap 3. For most users, this will work seamlessly, but some users may need to use the shinybootstrap2 package for backward compatibility.

* The UI of a Shiny app can now have a body tag. This is useful for CSS templates that use classes on the body tag.

* `actionButton` and `actionLink` now pass their `...` arguments to the underlying tag function. (#607)

* Added `observeEvent` and `eventReactive` functions for clearer, more concise handling of `actionButton`, plot clicks, and other naturally-imperative inputs.

* Errors that happen in reactives no longer prevent any remaining pending observers from executing. It is also now possible for users to control how errors are handled, with the 'shiny.observer.error' global option. (#603, #604)

* Added an `escape` argument to `renderDataTable()` to escape the HTML entities in the data table for security reasons. This might break tables from previous versions of shiny that use raw HTML in the table content, and the old behavior can be brought back by `escape = FALSE` if you are aware of the security implications. (#627)

* Changed the URI encoding/decoding functions internally to use `encodeURI()`, `encodeURIComponent()`, and `decodeURIComponent()` from the httpuv package instead of `utils::URLencode()` and `utils::URLdecode()`. (#630)

* Shiny's web assets are now minified.

* The default reactive domain is now available in event handler functions. (#669)

* Password input fields can now be used, with `passwordInput()`. (#672)


shiny 0.10.2.2
==============

* Remove use of `rstudio::viewer` in a code example, for R CMD check.


shiny 0.10.2.1
==============

* Changed some examples to use \donttest instead of \dontrun.


shiny 0.10.2
============

* The minimal version of R required for the shiny package is 3.0.0 now.

* Shiny apps can now consist of a single file, app.R, instead of ui.R and server.R.

* Upgraded DataTables from 1.9.4 to 1.10.2. This might be a breaking change if you have customized the DataTables options in your apps. (More info: https://github.com/rstudio/shiny/pull/558)

* File uploading via `fileInput()` works for Internet Explorer 8 and 9 now. Note: IE8/9 do not support multiple files from a single file input. If you need to upload multiple files, you have to use one file input for each file.

* Switched away from reference classes to R6.

* Reactive log performance has been greatly improved.

* Added `Progress` and `withProgress`, to display the progress of computation on the client browser.

* Fixed #557: updateSelectizeInput(choices, server = TRUE) did not work when `choices` is a character vector.

* Searching in DataTables is case-insensitive and the search strings are not treated as regular expressions by default now. If you want case-sensitive searching or regular expressions, you can use the configuration options `search$caseInsensitive` and `search$regex`, e.g. `renderDataTable(..., options = list(search = list(caseInsensitve = FALSE, regex = TRUE)))`.

* Added support for `htmltools::htmlDependency`'s new `attachment` parameter to `renderUI`/`uiOutput`.

* Exported `createWebDependency`. It takes an `htmltools::htmlDependency` object and makes it available over Shiny's built-in web server.

* Custom output bindings can now render `htmltools::htmlDependency` objects at runtime using `Shiny.renderDependencies()`.

* Fixes to rounding behavior of sliderInput. (#301, #502)

* Updated selectize.js to version 0.11.2. (#596)

* Added `position` parameter to `navbarPage`.


shiny 0.10.1
============

* Added Unicode support for Windows. Shiny apps running on Windows must use the UTF-8 encoding for ui.R and server.R (also the optional global.R) if they contain non-ASCII characters. See this article for details and examples: http://shiny.rstudio.com/gallery/unicode-characters.html (#516)

* `runGitHub()` also allows the 'username/repo' syntax now, which is equivalent to `runGitHub('repo', 'username')`. (#427)

* `navbarPage()` now accepts a `windowTitle` parameter to set the web browser page title to something other than the title displayed in the navbar.

* Added an `inline` argument to `textOutput()`, `imageOutput()`, `plotOutput()`, and `htmlOutput()`. When `inline = TRUE`, these outputs will be put in `span()` instead of the default `div()`. This occurs automatically when these outputs are created via the inline expressions (e.g. `r renderText(expr)`) in R Markdown documents. See an R Markdown example at http://shiny.rstudio.com/gallery/inline-output.html (#512)

* Added support for option groups in the select/selectize inputs. When the `choices` argument for `selectInput()`/`selectizeInput()` is a list of sub-lists and any sub-list is of length greater than 1, the HTML tag `<optgroup>` will be used. See an example at http://shiny.rstudio.com/gallery/option-groups-for-selectize-input.html (#542)


shiny 0.10.0
============

* BREAKING CHANGE: By default, observers now terminate themselves if they were created during a session and that session ends. See ?domains for more details.

* Shiny can now be used in R Markdown v2 documents, to create "Shiny Docs": reports and presentations that combine narrative, statically computed output, and fully dynamic inputs and outputs. For more info, including examples, see http://rmarkdown.rstudio.com/authoring_shiny.html.

* The `session` object that can be passed into a server function (e.g. shinyServer(function(input, output, session) {...})) is now documented: see `?session`.

* Most inputs can now accept `NULL` label values to omit the label altogether.

* New `actionLink` input control; like `actionButton`, but with the appearance of a normal link.

* `renderPlot` now calls `print` on its result if it's visible (i.e. no more explicit `print()` required for ggplot2).

* Introduced Shiny app objects (see `?shinyApp`). These essentially replace the little-advertised ability for `runApp` to take a `list(ui=..., server=...)` as the first argument instead of a directory (though that ability remains for backward compatibility). Unlike those lists, Shiny app objects are tagged with class `shiny.appobj` so they can be run simply by printing them.

* Added `maskReactiveContext` function. It blocks the current reactive context, to evaluate expressions that shouldn't use reactive sources directly. (This should not be commonly needed.)

* Added `flowLayout`, `splitLayout`, and `inputPanel` functions for putting UI elements side by side. `flowLayout` lays out its children in a left-to-right, top-to-bottom arrangement. `splitLayout` evenly divides its horizontal space among its children (or unevenly divides if `cellWidths` argument is provided). `inputPanel` is like `flowPanel`, but with a light grey background, and is intended to be used to encapsulate small input controls wherever vertical space is at a premium.

* Added `serverInfo` to obtain info about the Shiny Server if the app is served through it.

* Added an `inline` argument (TRUE/FALSE) in `checkboxGroupInput()` and `radioButtons()` to allow the horizontal layout (inline = TRUE) of checkboxes or radio buttons. (Thanks, @saurfang, #481)

* `sliderInput` and `selectizeInput`/`selectInput` now use a standard horizontal size instead of filling up all available horizontal space. Pass `width="100%"` explicitly for the old behavior.

* Added the `updateSelectizeInput()` function to make it possible to process searching on the server side (i.e. using R), which can be much faster than the client side processing (i.e. using HTML and JavaScript). See the article at http://shiny.rstudio.com/articles/selectize.html for a detailed introduction.

* Fixed a bug of renderDataTable() when the data object only has 1 row and 1 column. (Thanks, ZJ Dai, #429)

* `renderPrint` gained a new argument 'width' to control the width of the text output, e.g. renderPrint({mtcars}, width = 40).

* Fixed #220: the zip file for a directory created by some programs may not have the directory name as its first entry, in which case runUrl() can fail. (#220)

* `runGitHub()` can also take a value of the form "username/repo" in its first argument, e.g. both runGitHub("shiny_example", "rstudio") and runGitHub("rstudio/shiny_example") are valid ways to run the GitHub repo.


shiny 0.9.1
===========

* Fixed warning 'Error in Context$new : could not find function "loadMethod"' that was happening to dependent packages on "R CMD check".


shiny 0.9.0
===========

* BREAKING CHANGE: Added a `host` parameter to runApp() and runExample(), which defaults to the shiny.host option if it is non-NULL, or "127.0.0.1" otherwise. This means that by default, Shiny applications can only be accessed on the same machine from which they are served. To allow other clients to connect, as in previous versions of Shiny, use "0.0.0.0" (or the IP address of one of your network interfaces, if you care to be explicit about it).

* Added a new function `selectizeInput()` to use the JavaScript library selectize.js (https://github.com/brianreavis/selectize.js), which extends the basic select input in many aspects.

* The `selectInput()` function also gained a new argument `selectize = TRUE` to makes use of selectize.js by default. If you want to revert back to the original select input, you have to call selectInput(..., selectize = FALSE).

* Added Showcase mode, which displays the R code for an app right in the app itself. You can invoke Showcase mode by passing `display.mode="showcase"` to the `runApp()` function. Or, if an app is designed to run in Showcase mode by default, add a DESCRIPTION file in the app dir with Title, Author, and License fields; with "Type: Shiny"; and with "DisplayMode: Showcase".

* Upgraded to Bootstrap 2.3.2 and jQuery 1.11.0.

* Make `tags$head()` and `singleton()` behave correctly when used with `renderUI()` and `uiOutput()`. Previously, "hoisting content to the head" and "only rendering items a single time" were features that worked only when the page was initially loading, not in dynamic rendering.

* Files are now sourced with the `keep.source` option, to help with debugging and profiling.

* Support user-defined input parsers for data coming in from JavaScript using the parseShinyInput method.

* Fixed the bug #299: renderDataTable() can deal with 0-row data frames now. (reported by Harlan Harris)

* Added `navbarPage()` and `navbarMenu()` functions to create applications with multiple top level panels.

* Added `navlistPanel()` function to create layouts with a bootstrap navlist on the left and tabPanels on the right

* Added `type` parameter to `tabsetPanel()` to enable the use of pill style tabs in addition to the standard ones.

* Added `position` paramter to `tabsetPanel()` to enable positioning of tabs above, below, left, or right of tab content.

* Added `fluidPage()` and `fixedPage()` functions as well as related row and column layout functions for creating arbitrary bootstrap grid layouts.

* Added `hr()` builder function for creating horizontal rules.

* Automatically concatenate duplicate attributes in tag definitions

* Added `responsive` parameter to page building functions for opting-out of bootstrap responsive css.

* Added `theme` parameter to page building functions for specifying alternate bootstrap css styles.

* Added `icon()` function for embedding icons from the [font awesome](http://fontawesome.io/) icon library

* Added `makeReactiveBinding` function to turn a "regular" variable into a reactive one (i.e. reading the variable makes the current reactive context dependent on it, and setting the variable is a source of reactivity).

* Added a function `withMathJax()` to include the MathJax library in an app.

* The argument `selected` in checkboxGroupInput(), selectInput(), and radioButtons() refers to the value(s) instead of the name(s) of the argument `choices` now. For example, the value of the `selected` argument in selectInput(..., choices = c('Label 1' = 'x1', 'Label 2' = 'x2'), selected = 'Label 2') must be updated to 'x2', although names/labels will be automatically converted to values internally for backward compatibility. The same change applies to updateCheckboxGroupInput(), updateSelectInput(), and updateRadioButtons() as well. (#340)

* Now it is possible to only update the value of a checkbox group, select input, or radio buttons using the `selected` argument without providing the `choices` argument in updateCheckboxGroupInput(), updateSelectInput(), and updateRadioButtons(), respectively. (#340)

* Added `absolutePanel` and `fixedPanel` functions for creating absolute- and fixed-position panels. They can be easily made user-draggable by specifying `draggable = TRUE`.

* For the `options` argument of the function `renderDataTable()`, we can pass literal JavaScript code to the DataTables library via `I()`. This makes it possible to use any JavaScript object in the options, e.g. a JavaScript function (which is not supported in JSON). See `?renderDataTable` for details and examples.

* DataTables also works under IE8 now.

* Fixed a bug in DataTables pagination when searching is turned on, which caused failures for matrices as well as empty rows when displaying data frames using renderDataTable().

* The `options` argument in `renderDataTable()` can also take a function that returns a list. This makes it possible to use reactive values in the options. (#392)

* `renderDataTable()` respects more DataTables options now: (1) either bPaginate = FALSE or iDisplayLength = -1 will disable pagination (i.e. all rows are returned from the data); besides, this means we can also use -1 in the length menu, e.g. aLengthMenu = list(c(10, 30, -1), list(10, 30, 'All')); (2) we can disable searching for individual columns through the bSearchable option, e.g. aoColumns = list(list(bSearchable = FALSE), list(bSearchable = TRUE),...) (the search box for the first column is hidden); (3) we can turn off searching entirely (for both global searching and individual columns) using the option bFilter = FALSE.

* Added an argument `callback` in `renderDataTable()` so that a custom JavaScript function can be applied to the DataTable object. This makes it much easier to use DataTables plug-ins.

* For numeric columns in a DataTable, the search boxes support lower and upper bounds now: a search query of the form "lower,upper" (without quotes) indicates the limits [lower, upper]. For a column X, this means the rows corresponding to X >= lower & X <= upper are returned. If we omit either the lower limit or the upper limit, only the other limit will be used, e.g. ",upper" means X <= upper.

* `updateNumericInput(value)` tries to preserve numeric precision by avoiding scientific notation when possible, e.g. 102145 is no longer rounded to 1.0214e+05 = 102140. (Thanks, Martin Loos. #401)

* `sliderInput()` no longer treats a label wrapped in HTML() as plain text, e.g. the label in sliderInput(..., label = HTML('<em>A Label</em>')) will not be escaped any more. (#119)

* Fixed #306: the trailing slash in a path could fail `addResourcePath()` under Windows. (Thanks, ZJ Dai)

* Dots are now legal characters for inputId/outputId. (Thanks, Kevin Lindquist. #358)


shiny 0.8.0
===========

* Debug hooks are registered on all user-provided functions and (reactive) expressions (e.g., in renderPlot()), which makes it possible to set breakpoints in these functions using the latest version of the RStudio IDE, and the RStudio visual debugging tools can be used to debug Shiny apps. Internally, the registration is done via installExprFunction(), which is a new function introduced in this version to replace exprToFunction() so that the registration can be automatically done.

* Added a new function renderDataTable() to display tables using the JavaScript library DataTables. It includes basic features like pagination, searching (global search or search by individual columns), sorting (by single or multiple columns). All these features are implemented on the R side; for example, we can use R regular expressions for searching. Besides, it also uses the Bootstrap CSS style. See the full documentation and examples in the tutorial: http://rstudio.github.io/shiny/tutorial/#datatables

* Added a new option `shiny.error` which can take a function as an error handler. It is called when an error occurs in an app (in user-provided code), e.g., after we set options(shiny.error = recover), we can enter a specified environment in the call stack to debug our code after an error occurs.

* The argument `launch.browser` in runApp() can also be a function, which takes the URL of the shiny app as its input value.

* runApp() uses a random port between 3000 and 8000 instead of 8100 now. It will try up to 20 ports in case certain ports are not available.

* Fixed a bug for conditional panels: the value `input.id` in the condition was not correctly retrieved when the input widget had a type, such as numericInput(). (reported by Jason Bryer)

* Fixed two bugs in plotOutput(); clickId and hoverId did not give correct coordinates in Firefox, or when the axis limits of the plot were changed. (reported by Chris Warth and Greg D)

* The minimal required version for the httpuv package was increased to 1.2 (on CRAN now).


shiny 0.7.0
===========

* Stopped sending websocket subprotocol. This fixes a compatibility issue with Google Chrome 30.

* The `input` and `output` objects are now also accessible via `session$input` and `session$output`.

* Added click and hover events for static plots; see `?plotOutput` for details.

* Added optional logging of the execution states of a reactive program, and tools for visualizing the log data. To use, start a new R session and call `options(shiny.reactlog=TRUE)`. Then launch a Shiny app and interact with it. Press Ctrl+F3 (or for Mac, Cmd+F3) in the browser to launch an interactive visualization of the reactivity that has occurred. See `?showReactLog` for more information.

* Added `includeScript()` and `includeCSS()` functions.

* Reactive expressions now have class="reactive" attribute. Also added `is.reactive()` and `is.reactivevalues()` functions.

* New `stopApp()` function, which stops an app and returns a value to the caller of `runApp()`.

* Added the `shiny.usecairo` option, which can be used to tell Shiny not to use Cairo for PNG output even when it is installed. (Defaults to `TRUE`.)

* Speed increases for `selectInput()` and `radioButtons()`, and their corresponding updater functions, for when they have many options.

* Added `tagSetChildren()` and `tagAppendChildren()` functions.

* The HTTP request object that created the websocket is now accessible from the `session` object, as `session$request`. This is a Rook-like request environment that can be used to access HTTP headers, among other things. (Note: When running in a Shiny Server environment, the request will reflect the proxy HTTP request that was made from the Shiny Server process to the R process, not the request that was made from the web browser to Shiny Server.)

* Fix `getComputedStyle` issue, for IE8 browser compatibility (#196). Note: Shiny Server is still required for IE8/9 compatibility.

* Add shiny.sharedSecret option, to require the HTTP header Shiny-Shared-Secret to be set to the given value.


shiny 0.6.0
===========

* `tabsetPanel()` can be directed to start with a specific tab selected.

* Fix bug where multiple file uploads with 3 or more files result in incorrect data.

* Add `withTags()` function.

* Add dateInput and dateRangeInput.

* `shinyServer()` now takes an optional `session` argument, which is used for communication with the session object.

* Add functions to update values of existing inputs on a page, instead of replacing them entirely.

* Allow listening on domain sockets.

* Added `actionButton()` to Shiny.

* The server can now send custom JSON messages to the client. On the client side, functions can be registered to handle these messages.

* Callbacks can be registered to be called at the end of a client session.

* Add ability to set priority of observers and outputs. Each priority level gets its own queue.

* Fix bug where the presence of a submit button would prevent sending of metadata until the button was clicked.

* `reactiveTimer()` and `invalidateLater()` by default no longer invalidate reactive objects after the client session has closed.

* Shiny apps can be run without a server.r and ui.r file.


shiny 0.5.0
===========

* Switch from websockets package for handling websocket connections to httpuv.

* New method for detecting hidden output objects. Instead of checking that height and width are 0, it checks that the object or any ancestor in the DOM has style display:none.

* Add `clientData` reactive values object, which carries information about the client. This includes the hidden status of output objects, height/width plot output objects, and the URL of the browser.

* Add `parseQueryString()` function.

* Add `renderImage()` function for sending arbitrary image files to the client, and its counterpart, `imageOutput()`.

* Add support for high-resolution (Retina) displays.

* Fix bug #55, where `renderTable()` would throw error with an empty data frame.


shiny 0.4.1
===========

* Fix bug where width and height weren't passed along properly from `reactivePlot` to `renderPlot`.

* Fix bug where infinite recursion would happen when `reactivePlot` was passed a function for width or height.


shiny 0.4.0
===========

* Added suspend/resume capability to observers.

* Output objects are automatically suspended when they are hidden on the user's web browser.

* `runGist()` accepts GitHub's new URL format, which includes the username.

* `reactive()` and `observe()` now take expressions instead of functions.

* `reactiveText()`, `reactivePlot()`, and so on, have been renamed to `renderText()`, `renderPlot()`, etc.  They also now take expressions instead of functions.

* Fixed a bug where empty values in a numericInput were sent to the R process as 0. They are now sent as NA.


shiny 0.3.1
===========

* Fix issue #91: bug where downloading files did not work.

* Add [[<- operator for shinyoutput object, making it possible to assign values with `output[['plot1']] <- ...`.

* Reactive functions now preserve the visible/invisible state of their returned values.


shiny 0.3.0
===========

* Reactive functions are now evaluated lazily.

* Add `reactiveValues()`.

* Using `as.list()` to convert a reactivevalues object (like `input`) to a list is deprecated. The new function `reactiveValuesToList()` should be used instead.

* Add `isolate()`. This function is used for accessing reactive functions, without them invalidating their parent contexts.

* Fix issue #58: bug where reactive functions are not re-run when all items in a checkboxGroup are unchecked.

* Fix issue #71, where `reactiveTable()` would return blank if the first element of a data frame was NA.

* In `plotOutput`, better validation for CSS units when specifying width and height.

* `reactivePrint()` no longer displays invisible output.

* `reactiveText()` no longer displays printed output, only the return value from a function.

* The `runGitHub()` and `runUrl()` functions have been added, for running Shiny apps from GitHub repositories and zip/tar files at remote URLs.

* Fix issue #64, where pressing Enter in a textbox would cause a form to submit.


shiny 0.2.4
===========

* `runGist` has been updated to use the new download URLs from https://gist.github.com.

* Shiny now uses `CairoPNG()` for output, when the Cairo package is available. This provides better-looking output on Linux and Windows.


shiny 0.2.3
===========

* Ignore request variables for routing purposes


shiny 0.2.2
===========

* Fix CRAN warning (assigning to global environment)


shiny 0.2.1
===========

* [BREAKING] Modify API of `downloadHandler`: The `content` function now takes a file path, not writable connection, as an argument. This makes it much easier to work with APIs that only write to file paths, not connections.


shiny 0.2.0
===========

* Fix subtle name resolution bug--the usual symptom being S4 methods not being invoked correctly when called from inside of ui.R or server.R


shiny 0.1.14
===========

* Fix slider animator, which broke in 0.1.10


shiny 0.1.13
===========

* Fix temp file leak in reactivePlot


shiny 0.1.12
===========

* Fix problems with runGist on Windows

* Add feature for on-the-fly file downloads (e.g. CSV data, PDFs)

* Add CSS hooks for app-wide busy indicators


shiny 0.1.11
===========

* Fix input binding with IE8 on Shiny Server

* Fix issue #41: reactiveTable should allow print options too

* Allow dynamic sizing of reactivePlot (i.e. using a function instead of a fixed value)


shiny 0.1.10
===========

* Support more MIME types when serving out of www

* Fix issue #35: Allow modification of untar args

* headerPanel can take an explicit window title parameter

* checkboxInput uses correct attribute `checked` instead of `selected`

* Fix plot rendering with IE8 on Shiny Server


shiny 0.1.9
===========

* Much less flicker when updating plots

* More customizable error display

* Add `includeText`, `includeHTML`, and `includeMarkdown` functions for putting text, HTML, and Markdown content from external files in the application's UI.


shiny 0.1.8
===========

* Add `runGist` function for conveniently running a Shiny app that is published on gist.github.com.

* Fix issue #27: Warnings cause reactive functions to stop executing.

* The server.R and ui.R filenames are now case insensitive.

* Add `wellPanel` function for creating inset areas on the page.

* Add `bootstrapPage` function for creating new Bootstrap based layouts from scratch.


shiny 0.1.7
===========

* Fix issue #26: Shiny.OutputBindings not correctly exported.

* Add `repeatable` function for making easily repeatable versions of random number generating functions.

* Transcode JSON into UTF-8 (prevents non-ASCII reactivePrint values from causing errors on Windows).


shiny 0.1.6
===========

* Import package dependencies, instead of attaching them (with the exception of websockets, which doesn't currently work unless attached).

* conditionalPanel was animated, now it is not.

* bindAll was not correctly sending initial values to the server; fixed.


shiny 0.1.5
===========

* BREAKING CHANGE: JS APIs Shiny.bindInput and Shiny.bindOutput removed and replaced with Shiny.bindAll; Shiny.unbindInput and Shiny.unbindOutput removed and replaced with Shiny.unbindAll.

* Add file upload support (currently only works with Chrome and Firefox). Use a normal HTML file input, or call the `fileInput` UI function.

* Shiny.unbindOutputs did not work, now it does.

* Generally improved robustness of dynamic input/output bindings.

* Add conditionalPanel UI function to allow showing/hiding UI based on a JS expression; for example, whether an input is a particular value. Also works in raw HTML (add the `data-display-if` attribute to the element that should be shown/hidden).

* htmlOutput (CSS class `shiny-html-output`) can contain inputs and outputs.


shiny 0.1.4
===========

* Allow Bootstrap tabsets to act as reactive inputs; their value indicates which tab is active

* Upgrade to Bootstrap 2.1

* Add `checkboxGroupInput` control, which presents a list of checkboxes and returns a vector of the selected values

* Add `addResourcePath`, intended for reusable component authors to access CSS, JavaScript, image files, etc. from their package directories

* Add Shiny.bindInputs(scope), .unbindInputs(scope), .bindOutputs(scope), and .unbindOutputs(scope) JS API calls to allow dynamic binding/unbinding of HTML elements


shiny 0.1.3
===========

* Introduce Shiny.inputBindings.register JS API and InputBinding class, for creating custom input controls

* Add `step` parameter to numericInput

* Read names of input using `names(input)`

* Access snapshot of input as a list using `as.list(input)`

* Fix issue #10: Plots in tabsets not rendered


shiny 0.1.2
===========

* Initial private beta release!
