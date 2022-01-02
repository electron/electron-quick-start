const ipcRenderer = require("electron").ipcRenderer;
let name = document.getElementById("name");

document.getElementById("btnStart").addEventListener("click", fnStart);

function fnStart() {
  localStorage.setItem("presenter", "MLT");
  localStorage.setItem("setTime", "5");
}

ButtonSendName = document.getElementById("sendName");
ButtonSendName.addEventListener("click", (event) => {
  ipcRenderer.send("nameMsg", name.value);
  console.log(name.value);
});

ipcRenderer.on("nameReply", (event, arg) => {
  console.log(arg); // why/what is not right..
});
