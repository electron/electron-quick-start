// Modules to control application life and create native browser window
const {app, crashReporter, ipcMain, BrowserWindow} = require('electron')
const path = require('path')

function createWindow () {
  // Create the browser window.
  const mainWindow = new BrowserWindow({
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  })
  mainWindow.loadFile('index.html');
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {

  createWindow()
  
  app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit()
})


function testDone(success, ...logs) {
  console.log(`test ${success ? 'passed' : 'failed'}`)
  logs.forEach((i) => console.log(i))
  process.exit(success ? 0 : 1)
}

{
  crashReporter.start({ uploadToServer: false, submitURL: '' })
  ipcMain.on('test-done', (_, success, ...logs) => testDone(success, ...logs))
  const failIfBadExit = (details) => {
    if (details.reason !== 'clean-exit') testDone(false, new Error('trace'), details)
  }
  app.on('child-process-gone', (_ev, details) => test.failIfBadExit(details))
  app.on('render-process-gone', (_ev, _, details) => test.failIfBadExit(details))
}
