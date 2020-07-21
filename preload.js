
// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.
const {camera} = require('./camera');
const {ipcMain,ipcRenderer,dialog} = require("electron");
window.addEventListener('DOMContentLoaded', () => {
  const replaceText = (selector, text) => {
    const element = document.getElementById(selector)
    if (element) element.innerText = text
  }

  for (const type of ['chrome', 'node', 'electron']) {
    replaceText(`${type}-version`, process.versions[type])
  }

  camera();

  ipcRenderer.on('retrieve-practice-file-types',(event,data)=>{
    console.log(data)
    var select = document.createElement('select');
    select.id = 'file-type'
    data.forEach(element => {
      select.add(new Option(element.Description,element.SystemFileTypeId));
      document.body.append(select);
      //select.onselect((event))
    });
})


ipcRenderer.on('load-patient',(event,data)=>{

  var pre = document.createElement('pre').innerText = data;
  document.body.append(pre);
})






})


