const electron = require("electron");

export function ipcInvoke(channel: string, ...args: any[]) {
  return electron.ipcRenderer.invoke(channel, ...args);
}
