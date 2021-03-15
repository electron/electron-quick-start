// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.


// Example test: check that process.versions.electron
// - is defined in the renderer process
// - has major, minor, and patch numbers
// - the numbers are non-negative
try {
  const ver = process.versions.electron
  const tokens = process.versions.electron.split('.', 3)
  assert(tokens.length === 3)
  for (const token of tokens) {
    const num = Number.parseInt(token)
    assert(num !== NaN)
    assert(num >= 0)
  }
  testDone()
} catch (err) {
  fail()
}


// Test helper code

function fail () {
  process.exit(1)
}
function assert (ok) {
  if (!ok) fail()
}
function testDone() {
  const { ipcRenderer } = require('electron')
  ipcRenderer.send('test-done')
}
