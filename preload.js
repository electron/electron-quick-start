// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.

// Test helpers
const test = {
  allPassed: () => test.done(true),
  assert: (ok, ...logs) => ok || test.fail(...logs),
  done: (success, ...logs) => require('electron').ipcRenderer.send('test-done', success, ...logs),
  fail: (...logs) => test.done(false, new Error('trace'), ...logs)
}

// Example test: check that process.versions.electron
// - is defined in the renderer process
// - has major, minor, and patch numbers
// - the numbers are non-negative
try {
  const ver = process.versions.electron
  const tokens = process.versions.electron.split('.', 3)
  test.assert(tokens.length === 3)
  for (const token of tokens) {
    const num = Number.parseInt(token)
    test.assert(num !== NaN)
    test.assert(num >= 0)
  }
  test.allPassed()
} catch (err) {
  test.fail(err)
}
