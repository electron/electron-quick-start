// Modules to control application life and create native browser window
const { app, BrowserWindow, webContents, ipcMain } = require("electron");
const path = require("path");

function createWindow1() {
  window1 = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true,
    },
  });
  window1.loadURL(`file://${__dirname}/index.html`);
  window1.webContents.openDevTools();
  window1.on("closed", function () {
    window1 = null;
  });
  return window1;
}

function createWindow2() {
  window2 = new BrowserWindow({
    width: 1000,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true,
    },
  });
  window2.loadURL(`file://${__dirname}/progressBar.html`);
  window2.webContents.openDevTools();
  window2.on("closed", function () {
    window2 = null;
  });
  return window2;
}

function createWindow3() {
  window3 = new BrowserWindow({
    width: 1000,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      nodeIntegration: true,
      contextIsolation: false,
      enableRemoteModule: true,
    },
  });
  window3.loadURL(`file://${__dirname}/settings.html`);
  window3.webContents.openDevTools();
  window3.on("closed", function () {
    window3 = null;
  });
  return window3;
}
// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on("ready", () => {
  window1 = createWindow1();
  window2 = createWindow2();
  window2 = createWindow3();

  ipcMain.on("nameMsg", (event, arg) => {
    console.log("name inside main process is: ", arg); // this comes form within window 1 -> and into the mainProcess
    event.sender.send("nameReply", { not_right: false }); // sends back/replies to window 1 - "event" is a reference to this chanel.
    window2.webContents.send("forWin2", arg); // sends the stuff from Window1 to Window2.
  });
});
