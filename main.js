// Modules to control application life and create native browser window
const {app, BrowserWindow, ipcMain,dialog, ipcRenderer,net} = require('electron')
const path = require('path')
const {session} = require('.\\session.js');
const {authenticate} = require('./authenticate')
const fs = require('fs');
const {intellefile} = require('./intellefile-proxy');
const { debug } = require('console');
const { v4 }  = require('uuid');
const machineGuid =  v4(); // ⇨ '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d'


let  mainWindow;
function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    name: 'main',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  })

  // and load the index.html of the app.
  mainWindow.loadFile('index.html')

  // Open the DevTools.
   mainWindow.webContents.openDevTools()
}


// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {
  let localSessionId;
  createWindow()
  authenticate()
    .then((sessionId)=> {
      localSessionId = sessionId;
      return intellefile(sessionId)
      .then(async (data)=>{
        ///fill dropdown list.
          mainWindow.webContents.send('retrieve-practice-file-types',data);
          console.info(data);
          return new Promise((resolve,reject)=>{
            var request =  net.request({
             method: 'POST',
             protocol: 'https:',
             hostname: 'localhost',
             port: 443,
             path: '/MDIWebMVC/API/intellefile/Load?sessionId=foo&patientId=10084&patientEncounterId=13818&machineId=7ff21451-b2fd-4e25-baa7-73b070d184fd',
             headers: {
                // Cookie: {"ASP.NET_SessionId": localSessionId}
             }
           })
     
           request.setHeader("Cookie", "ASP.NET_SessionId=" + localSessionId);
             
           request.on('response', (response) => {
             console.log(`STATUS: ${response}`);
         
             response.on('error', (error) => {
               console.log(`ERROR: ${JSON.stringify(error)}`)
               reject(error);
             })
         
             response.on('data', (chunk) => {
               var result = JSON.parse(chunk.toString()).PatientTitle;
                mainWindow.webContents.send('load-patient', JSON.stringify(result,null,2))
               resolve(result);
              
             })
         
           })
         
           request.end();
         })
  }) });
 app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    createWindow();

    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  })

  // Main  
}).catch((e) => {
  console.log(external)
e})

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit()
})


ipcMain.handle('save-webcam-file', async (event,imageBuffer)=>{
  await dialog.showSaveDialog({
   filters: [
       { name: 'Images', extensions: [imageBuffer.type.split('/')[1],'png','jpg','bmp',] },
   ]
}).then(async function (obj) {
      if (obj.filePath === undefined){
           console.log("You didn't save the file because you exit or didn't give a name");
           return;
      }
      // If the user gave a name to the file, then save it
      // using filesystem writeFile function
      await fs.writeFile(obj.filePath, imageBuffer.data, function(err) {
          if(err){
              console.log("Cannot save the file :'( time to cry !");
          }else{
              console.info("Image saved succesfully");
          }
      });
});
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
