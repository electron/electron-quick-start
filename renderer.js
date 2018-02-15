// TODO retry connection on error
var ws = new WebSocket('ws://localhost:4000');

function updateSensors(data) {
  console.log(data);
  
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

  document.getElementById('heartbeat-1-status').innerText = 'Serialport ACTIVE.';
  document.getElementById('heartbeat-1-time').innerText = hours + ' : ' + minutes + ' : ' + seconds;

  heartbeatTimeouts.push(setTimeout(clearHeartBeat, 5000));
}

function clearHeartBeat() {
  document.getElementById('heartbeat-1-status').innerText = 'Serialport INACTIVE.';
  document.getElementById('heartbeat-1-time').innerText = 'Websocket connection timed out for > 5sec';
  // TODO retry websocket connection
}

ws.onmessage = function (message) {
  var data = JSON.parse(message.data);
  if (!data) {
    return;
  }

  // Heartbeat message
  if (data['heartbeat']) {
    return registerHeartBeat();
  }

  updateSensors(data);
};