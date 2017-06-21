This example demonstrates the following concepts:

* **Global variables**: The `mpgData` variable is declared outside the `shinyServer` function. This makes it available anywhere inside `shinyServer`. The code in `server.R` outside `shinyServer` is only run once when the app starts up, so it can't contain user input.
* **Reactive expressions**: `formulaText` is a reactive expression. Note how it re-evaluates when the Variable field is changed, but not when the Show Outliers box is ticked. 
