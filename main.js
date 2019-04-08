// Modules to control application life and create native browser window
const {app, BrowserWindow, Menu} = require('electron')


// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow
Menu.setApplicationMenu(null)
function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({width: 600, height: 800})
  
  mainWindow.loadFile('login/login.html')


  // mainWindow.loadFile('cms/index.html')

  // mainWindow.webContents.openDevTools()

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  })
}

function createBarWindow () {
  // Create the browser window.
  barWindow = new BrowserWindow({width: 1920, height: 1680})

  barWindow.loadFile('cms/index.html')



  // barWindow.webContents.openDevTools()

  // Emitted when the window is closed.
  barWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    barWindow = null
  })
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On macOS it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function () {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow()
  }
})


const ipcMain = require('electron').ipcMain;

ipcMain.on('synchronous-message', function(event, arg) {
  console.log(arg);  // prints "ping"
  //event.returnValue = 'pong';
  createBarWindow()
  mainWindow.close()
});

ipcMain.on('user-logout', function(event, arg) {
  console.log(arg);  // prints "ping"
  //event.returnValue = 'pong';
  createWindow()
  barWindow.close()
  

});
