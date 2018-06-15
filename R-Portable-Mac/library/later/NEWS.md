## later 0.7.2

* Fixed [issue #48](https://github.com/r-lib/later/issues/48): Occasional timedwait errors from later::run_now. Thanks, @vnijs! [PR #49](https://github.com/r-lib/later/pull/49)

* Fixed a build warning on OS X 10.11 and earlier. [PR #54](https://github.com/r-lib/later/pull/54)

## later 0.7.1

* Fixed [issue #39](https://github.com/r-lib/later/issues/39): Calling the C++ function `later::later()` from a different thread could cause an R GC event to occur on that thread, leading to memory corruption. [PR #40](https://github.com/r-lib/later/pull/40)

* Decrease latency of repeated top-level execution.

## later 0.7 (unreleased)

* Fixed [issue #22](https://github.com/r-lib/later/issues/22): GC events could cause an error message: `Error: unimplemented type 'integer' in 'coerceToInteger'`. [PR #23](https://github.com/r-lib/later/pull/23)

* Fixed issues [#25](https://github.com/r-lib/later/issues/25), [#29](https://github.com/r-lib/later/issues/29), and [#31](https://github.com/r-lib/later/issues/31): If errors occurred when callbacks were executed by R's input handler (as opposed to by `run_now()`), then they would not be properly handled by R and put the terminal in a problematic state. [PR #33](https://github.com/r-lib/later/pull/33)

* Fixed [issue #37](https://github.com/r-lib/later/issues/37): High CPU usage on Linux. [PR #38](https://github.com/r-lib/later/pull/38)

* Fixed [issue #36](https://github.com/r-lib/later/issues/36): Failure to build on OS X <=10.12 (thanks @mingwandroid). [PR #21](https://github.com/r-lib/later/pull/21)

## later 0.6

* Fix a hang on address sanitized (ASAN) builds of R. [Issue #16](https://github.com/r-lib/later/issues/16), [PR #17](https://github.com/r-lib/later/pull/17)

* The `run_now()` function now takes a `timeoutSecs` argument. If no tasks are ready to run at the time `run_now(timeoutSecs)` is invoked, we will wait up to `timeoutSecs` for one to become ready. The default value of `0` means `run_now()` will return immediately if no tasks are ready, which is the same behavior as in previous releases. [PR #19](https://github.com/r-lib/later/pull/19)

* The `run_now()` function used to return only when it was unable to find any more tasks that were due. This means that if tasks were being scheduled at an interval faster than the tasks are executed, `run_now()` would never return. This release changes that behavior so that a timestamp is taken as `run_now()` begins executing, and only tasks whose timestamps are earlier or equal to it are run. [PR #18](https://github.com/r-lib/later/pull/18)

* Fix compilation errors on Solaris. Reported by Brian Ripley. [PR #20](https://github.com/r-lib/later/pull/20)

## later 0.5

* Fix a hang on Fedora 25+ which prevented the package from being installed successfully. Reported by @lepennec. [Issue #7](https://github.com/r-lib/later/issues/7), [PR #10](https://github.com/r-lib/later/pull/10)

* Fixed [issue #12](https://github.com/r-lib/later/issues/12): When an exception occurred in a callback function, it would cause future callbacks to not execute. [PR #13](https://github.com/r-lib/later/pull/13)

* Added `next_op_secs()` function to report the number of seconds before the next scheduled operation. [PR #15](https://github.com/r-lib/later/pull/15)

## later 0.4

* Add `loop_empty()` function, which returns `TRUE` if there are currently no callbacks that are scheduled to execute in the present or future.

* On POSIX platforms, fix an issue where socket connections hang when written to/read from while a later callback is scheduled. The fix required stopping the input handler from being called in several spurious situations: 1) when callbacks are already being run, 2) when R code is busy executing (we used to try as often as possible, now we space it out a bit), and 3) when all the scheduled callbacks are in the future. To accomplish this, we use a background thread that acts like a timer to poke the file descriptor whenever the input handler needs to be run--similar to what we already do for Windows. [Issue #4](https://github.com/r-lib/later/issues/4)

* On all platforms, don't invoke callbacks if callbacks are already being invoked (unless explicitly requested by a caller to `run_now()`).


## later 0.3

Initial release.
