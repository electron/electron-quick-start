const electron = require('electron')
// 控制应用生命周期的模块
const app = electron.app
// 创建原生浏览器窗口的模块
const BrowserWindow = electron.BrowserWindow

const path = require('path')
const url = require('url')

// 保持一个对于window对象的全局引用， 不然， 当JavaScript被GC
// window会自动关闭
let mainWindow

function createWindow () {
  // 创建一个浏览器窗口
  mainWindow = new BrowserWindow({width: 800, height: 600})

  // 加载应用的index.html
  mainWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true
  }))

  // 打开开发工具
  mainWindow.webContents.openDevTools()

  // 当window被关闭， 这个事件会被发出
  mainWindow.on('closed', function () {
    // 取消应用window对象，如果你的应用和支持多窗口的话
    // 通常会把多个window对象存放在一个数组里面
    // 但这次不是
    mainWindow = null
  })
}

// 当Electron完成了初始化并且准备创建浏览器窗口的时候，这个方法被调用
app.on('ready', createWindow)

// 当所有窗口被关闭了， 退出
app.on('window-all-closed', function () {
  // 在OS X上， 通常用户在明确地按下cmd + Q 之前
  // 应用会保持活动状态
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function () {
  // 重新创建一个窗口
  if (mainWindow === null) {
    createWindow()
  }
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
