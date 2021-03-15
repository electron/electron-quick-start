// Modules to control application life and create native browser window
const {app, ipcMain, BrowserWindow} = require('electron')
const path = require('path')

function createWindow () {
  // Create the browser window.
  const mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  })

  // and load the index.html of the app.
  mainWindow.loadFile('index.html')
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {
  // Prepare for child processes to indicate test results.
  ipcMain.on('test-done', () => finishTest(true))
  app.on('child-process-gone', (ev, details) => failTestIfBadProcess(details))
  app.on('render-process-gone', (ev, webContents, details) => failTestIfBadProcess(details))

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

function finishTest (success) {
  process.exit(success ? 0 : 1)
}
function failTestIfBadProcess (details) {
  if (details.reason !== 'clean-exit') finishTest(false)
}
