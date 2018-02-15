// TODO retry connection on error
var ws = new WebSocket('ws://localhost:4000');

var SENSOR_IDS = {
  'engine-temperature': 1,
  'latitude': 2,
  'longitude': 3,
  'speed': 4
}

function updateSensors(data) {
  let { sensor, value, ts } = data;
  if (!SENSOR_IDS[sensor]) {
    console.log('Invalid sensor id');
    return;
  }


  var sensorReadingElementId = 'sensor-' + SENSOR_IDS[sensor] + '-reading';
  var sensorTimeElementId = 'sensor-' + SENSOR_IDS[sensor] + '-reading-time';

  document.getElementById(sensorReadingElementId).innerText = value;
  document.getElementById(sensorTimeElementId).innerText = ts;

}

var heartbeatTimeouts = [];

function registerHeartBeat() {
  heartbeatTimeouts.forEach(function (id){
    clearTimeout(id);
  });
  heartbeatTimeouts = [];

  var time = new Date();
  var hours = time.getHours();
  var minutes = time.getMinutes();
  var seconds = time.getSeconds();

  document.getElementById('heartbeat-1-status').innerText = 'IntelaRacing ACTIVE.';
  document.getElementById('heartbeat-1-time').innerText = hours + ' : ' + minutes + ' : ' + seconds;

  heartbeatTimeouts.push(setTimeout(clearHeartBeat, 5000));
}

function clearHeartBeat() {
  document.getElementById('heartbeat-1-status').innerText = 'IntelaRacing INACTIVE.';
  document.getElementById('heartbeat-1-time').innerText = 'Websocket connection timed out for > 5sec';
  // TODO retry websocket connection
}

ws.onmessage = function (message) {
  var data;
  try {
    data = JSON.parse(message.data);
  } catch (err) {
    console.log(err);
    return;
  }
  
  if (!data) {
    return;
  }

  // Heartbeat message
  if (data['heartbeat']) {
    return registerHeartBeat();
  }

  // console.log(data);

  updateSensors(data);
};