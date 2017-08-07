# bindr 0.1 (2016-11-12)

Initial release.

- Functions `create_env()` and `populate_env()`.
    - Create or populate an environment with one or more active bindings, where the value is computed by calling a function and passing the name of the binding, and an arbitrary number of additional arguments (named or unnamed).
    - Not overwriting existing bindings or variables.
    - Names can be passed as symbols (`name`) or character strings (`character`), with warning if the conversion fails.
