import { app, BrowserWindow, ipcMain } from "electron";
import path from "path";
import { sum } from "../global/modules/sum/sum";

console.log("sum", sum(50, 50));

export const isDev = process.env.NODE_ENV === "development";

function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });

  if (isDev) mainWindow.loadURL("http://localhost:3000");
  else mainWindow.loadFile(path.join("build_vite", "index.html"));
}

app.whenReady().then(() => {
  createWindow();

  app.on("activate", function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", function () {
  if (process.platform !== "darwin") app.quit();
});

ipcMain.handle("ipcChecker", () => {
  return 1;
});
