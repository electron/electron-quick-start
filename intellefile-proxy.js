const {net} = require('electron'); 
const { ipcRenderer } = require('electron')


exports.intellefile = function(sessionId){

    return new Promise((resolve,reject)=>{
       var request =  net.request({
        method: 'GET',
        protocol: 'https:',
        hostname: 'localhost',
        port: 443,
        path: '/MDIWebMVC/API/intellefile/GetPracticeFileTypes?sessionId=1',
        headers: {
            //Cookie: {"ASP.NET_SessionId": sessionId}
        }
      })

     request.setHeader("Cookie", "ASP.NET_SessionId=" + sessionId);
        
      request.on('response', (response) => {
        console.log(`STATUS: ${response}`);
    
        response.on('error', (error) => {
          console.log(`ERROR: ${JSON.stringify(error)}`)
          reject(error);
        })
    
        response.on('data', (chunk) => {
          resolve(JSON.parse(chunk.toString()))
        })
    
      })
    
      request.end();
    })
}

