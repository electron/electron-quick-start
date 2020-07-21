const WebCamera = require('webcamjs');
const { ipcRenderer} = require('electron');

exports.camera = function(){
    // A flag to know when start or stop the camera
    var enabled = false;
// Use require to add webcamjs
if(!enabled){ // Start the camera !
    enabled = true;
    WebCamera.attach('#camdemo');
    console.log("The camera has been started");
  }else{ // Disable the camera !
    enabled = false;
    WebCamera.reset();
   console.log("The camera has been disabled");
  }



var fs = require('fs'); // Load the File System to execute our common tasks (CRUD)

// return an object with the processed base64image
function processBase64Image(dataString) {
      var matches = dataString.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/),response = {};

      if (matches.length !== 3) {
          return new Error('Invalid input string');
      }

      response.type = matches[1];
      response.data = new Buffer(matches[2], 'base64');

      return response;
}

document.getElementById("savefile").addEventListener('click',function(){
    if(enabled){
        var img = document.createElement('img');
        var fileType = document.getElementById('file-type');
        img.setAttribute('data-file-type', fileType.options[fileType.selectedIndex].value);
        WebCamera.snap(async function(data_uri) {
                // Save the image in a variable
                var imageBuffer = processBase64Image(data_uri);
                // Start the save dialog to give a name to the file
                const data =  await ipcRenderer.invoke('save-webcam-file',imageBuffer);
                img.src = 'data:image/jpeg;base64,' + imageBuffer.data.toString('base64');
               
             });
             document.body.appendChild(img);

     }else{
            console.log("Please enable the camera first to take the snapshot !");
     }
},false);
}