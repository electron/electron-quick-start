This example demonstrates the `tabsetPanel` and `tabPanel` widgets.

Notice that outputs that are not visible are not re-evaluated until they become visible. Try this: 

1. Scroll to the bottom of `server.R`
2. Change the number of observations, and observe that only `output$plot` is evaluated.
3. Click the Summary tab, and observe that `output$summary` is evaluated.
4. Change the number of observations again, and observe that now only `output$summary` is evaluated.

