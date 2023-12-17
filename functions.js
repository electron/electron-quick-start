document.onkeydown = function (e) {
  const displayElement = document.getElementById("display");
  switch (e.keyCode) {
    case 48:
      document.getElementById("0").play();
      displayElement.innerText = "0";
      break;
    case 49:
      document.getElementById("1").play();
      displayElement.innerText = "1";
      break;
    case 50:
      document.getElementById("2").play();
      displayElement.innerText = "2";
      break;
    case 51:
      document.getElementById("3").play();
      displayElement.innerText = "3";
      break;
    case 52:
      document.getElementById("4").play();
      displayElement.innerText = "4";
      break;
    case 53:
      document.getElementById("5").play();
      displayElement.innerText = "5";
      break;
    case 54:
      document.getElementById("6").play();
      displayElement.innerText = "6";
      break;
    case 55:
      document.getElementById("7").play();
      displayElement.innerText = "7";
      break;
    case 56:
      document.getElementById("8").play();
      displayElement.innerText = "8";
      break;
    case 57:
      document.getElementById("9").play();
      displayElement.innerText = "9";
      break;
    case 65:
      document.getElementById("A").play();
      displayElement.innerText = "A";
      break;
    case 66:
      document.getElementById("B").play();
      displayElement.innerText = "B";
      break;
    case 67:
      document.getElementById("C").play();
      displayElement.innerText = "C";
      break;
    case 68:
      document.getElementById("D").play();
      displayElement.innerText = "D";
      break;
    case 69:
      document.getElementById("E").play();
      displayElement.innerText = "E";
      break;
    case 70:
      document.getElementById("F").play();
      displayElement.innerText = "F";
      break;
    case 71:
      document.getElementById("G").play();
      displayElement.innerText = "G";
      break;
    case 72:
      document.getElementById("H").play();
      displayElement.innerText = "H";
      break;
    case 73:
      document.getElementById("I").play();
      displayElement.innerText = "I";
      break;
    case 74:
      document.getElementById("J").play();
      displayElement.innerText = "J";
      break;
    case 75:
      document.getElementById("K").play();
      displayElement.innerText = "K";
      break;
    case 76:
      document.getElementById("L").play();
      displayElement.innerText = "L";
      break;
    case 77:
      document.getElementById("M").play();
      displayElement.innerText = "M";
      break;
    case 78:
      document.getElementById("N").play();
      displayElement.innerText = "N";
      break;
    case 79:
      document.getElementById("O").play();
      displayElement.innerText = "O";
      break;
    case 80:
      document.getElementById("P").play();
      displayElement.innerText = "P";
      break;
    case 81:
      document.getElementById("Q").play();
      displayElement.innerText = "Q";
      break;
    case 82:
      document.getElementById("R").play();
      displayElement.innerText = "R";
      break;
    case 83:
      document.getElementById("S").play();
      displayElement.innerText = "S";
      break;
    case 84:
      document.getElementById("T").play();
      displayElement.innerText = "T";
      break;
    case 85:
      document.getElementById("U").play();
      displayElement.innerText = "U";
      break;
    case 86:
      document.getElementById("V").play();
      displayElement.innerText = "V";
      break;
    case 87:
      document.getElementById("W").play();
      displayElement.innerText = "W";
      break;
    case 88:
      document.getElementById("X").play();
      displayElement.innerText = "X";
      break;
    case 89:
      document.getElementById("Y").play();
      displayElement.innerText = "Y";
      break;
    case 90:
      document.getElementById("Z").play();
      displayElement.innerText = "Z";
      break;
    default:
      alert("Клавиша на обнаружена!");
  }
};
