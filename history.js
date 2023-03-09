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

// ipcRenderer.send('get-logs');

// ipcRenderer.on('send-logs', (event, logs) => {
//   logs.forEach(log => {
//     const row = logTable.insertRow(-1);
//     row.insertCell(0).textContent = log.name;
//     row.insertCell(1).textContent = log.startTime.toLocaleString();
//   });
// });
