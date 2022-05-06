function getDimension () {
    const dimension = document.querySelector('.dimension').value;
    console.log(dimension);
  }

function getSpeed() {
    const speed = document.querySelector('.speed').value;
    console.log(speed);
  }

function calculateTime () {
    var timeSeconds;
    const multiplier = 1024;
    timeSeconds = (dimension * multiplier) / speed;
    querySelector('timeSeconds').document.write(timeSeconds);
}