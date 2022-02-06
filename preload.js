// Isolated World
// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.
const { contextBridge } = require("electron");

window.addEventListener("DOMContentLoaded", () => {
  const replaceText = (selector, text) => {
    const element = document.getElementById(selector);
    if (element) element.innerText = text;
  };

  for (const type of ["chrome", "node", "electron"]) {
    replaceText(`${type}-version`, process.versions[type]);
  }
});

// All apis from preload script will be available
// inside renderer process via contextbridge.
contextBridge.exposeInMainWorld("electron", {
  newApi: () => {
    return "Hello from main process";
  },
});
// Access apis in rederer proses by
// window.electron.newApi();
