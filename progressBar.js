// console.log(localStorage.getItem("presenter"));
// console.log(localStorage.getItem("setTime"));

// document.getElementById("presenterName").value =
//   localStorage.getItem("presenter");
// document.getElementById("presenter").value = localStorage.getItem("setTime");

const { ipcRenderer } = require("electron");

showName = document.getElementById("showName");
ipcRenderer.on("forWin2", function (event, arg) {
  console.log(arg);
  showName.innerHTML = arg;
});
console.log("I'm Window2");
