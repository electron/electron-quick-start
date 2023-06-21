/**
 * The preload script runs before. It has access to web APIs
 * as well as Electron's renderer process modules and some
 * polyfilled Node.js functions.
 *
 * https://www.electronjs.org/docs/latest/tutorial/sandbox
 */

// Test helpers
const test = {
  assert: (ok, ...logs) => {
    if (!ok) test.fail(...logs)
  },
  fail: (...logs) => test.done(false, ...logs),
  done: (success = true, ...logs) => {
    if (!success) logs.unshift(new Error('test failed'))
    require('electron').ipcRenderer.send('test-done', success, ...logs)
  }
}

// Example test: check that process.versions.electron
// - is defined in the preload process
// - has major, minor, and patch numbers
// - the numbers are non-negative
try {
  const tokens = process.versions.electron.split('.', 3)
  test.assert(tokens.length === 3)
  for (const token of tokens) {
    const num = Number.parseInt(token)
    test.assert(!Number.isNaN(num))
    test.assert(num >= 0)
  }
  test.done()
} catch (err) {
  test.fail(err)
}
