import { app, BrowserWindow } from "electron";
import path from "path";

import { registMainHandles } from "./apps/registMainHandles";

export const isDev = process.env.NODE_ENV === "development";

main();

async function main() {
  await app.whenReady();
  app.on("window-all-closed", function () {
    if (process.platform !== "darwin") app.quit();
  });
  app.on("activate", function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });

  const mainWindow = createWindow();
  registMainHandles(mainWindow);
}

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

  return mainWindow;
}
