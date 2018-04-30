// TODO retry connection on error
var ws = new WebSocket('ws://localhost:4000');

var SENSOR_IDS = {
  'engine_temperature': 1,
  'latitude': 2,
  'longitude': 3,
  'speed': 4,
  'brake_pedal': 5,
  'gas_pedal': 6,
  'suspension': 7,
  'transmission_temperature': 8,
  'rpm': 9,
  'sos': 10,
}

function updateSensors(data) {
  for (var key in data) {
    if (data.hasOwnProperty(key)) {
      let { type, value, ts, triggers } = data[key];
      if (!SENSOR_IDS[key]) {
        console.log('Invalid sensor id');
      } else {
        var sensorElementId = 'sensor-' + SENSOR_IDS[key];
        var sensorReadingElementId = 'sensor-' + SENSOR_IDS[key] + '-reading';
        var sensorTimeElementId = 'sensor-' + SENSOR_IDS[key] + '-reading-time';

        let changeColor = false;

        for (let i=0; i < triggers.length; i++) {
          if (type === "inactive") {
            changeColor = true;
            document.getElementById(sensorElementId).style.border = "3px solid #FF0054";
            break;
          } else if (key !== 'sos' && (value < triggers[i].value)) {
            changeColor = true;
            switch (triggers[i].name) {
              case("danger"):
                document.getElementById(sensorElementId).style.border = "3px solid #FF0054";
                break;
              case("warning"):
                document.getElementById(sensorElementId).style.border = "3px solid #FFAE42";
                break;
            }
            break;
          } else if (key === 'sos') {
            if (value === '1') {
              changeColor = true;
              document.getElementById(sensorElementId).style.border = "3px solid #FF0054";
            }
          }
        }

        if (!changeColor) {
          document.getElementById(sensorElementId).style.border = "3px solid #81D3B7";
        }
      
        document.getElementById(sensorReadingElementId).innerText = value;
        document.getElementById(sensorTimeElementId).innerText = ts;
      }
    }
  }
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

  updateSensors(data);
};