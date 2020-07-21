// Modules to control application life and create native browser window
const { app, BrowserWindow } = require('electron');
const fs = require('fs');
const path = require('path')
const https  = require('https')
global.sharedObject = {
  someProperty: `value from main process: I know you started program from: ${path.resolve(__dirname)}`,
  fnInMainProcess: () => {
    return new Promise((resolve) => {
      
      https.get('https://www.baidu.com', (res) => {
        console.log('statusCode:', res.statusCode);
        console.log('headers:', res.headers);
        res.on('data', (d) => {
          resolve(d.length)
        });
      
      }).on('error', (e) => {
        console.error(e);
      });
    })
  }
}
function createWindow () {
  // Create the browser window.
  const mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      webSecurity: false,
      nodeIntegration: true,
      preload: path.join(__dirname, 'preload.js')
    }
  })

  // and load the index.html of the app.
  mainWindow.loadFile('index.html')

  // Open the DevTools.
  // mainWindow.webContents.openDevTools()
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

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
