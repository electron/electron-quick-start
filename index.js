document.getElementById("btnStart").addEventListener("click", fnStart);

function fnStart() {
  localStorage.setItem("presenter", "MLT");
  localStorage.setItem("setTime", "5");
}
