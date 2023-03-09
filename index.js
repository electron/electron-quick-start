const logTimeButton = document.getElementById('start-end-btn');
const pjtSelect = document.getElementById('project-select');
// const durationInput = document.getElementById('duration-input');

let logs = [];

logTimeButton.addEventListener('click', () => {
  const pjt = pjtSelect.value;
  //const duration = parseInt(durationInput.value, 10);
  const startTime = new Date();

  logs.push({ pjt, startTime});
  window.electronAPI.sendLog(logs);
});

const logTable = document.getElementById('log-table').getElementsByTagName('tbody')[0];

window.electronAPI.getLog((event,data) => {
    if (data) {
        data.forEach(log => {
            const row = logTable.insertRow(-1);
            row.insertCell(0).textContent = log.name;
            row.insertCell(1).textContent = log.startTime.toLocaleString();
        });
    } else {
        console.error('Error retrieving log data');
    }
});
