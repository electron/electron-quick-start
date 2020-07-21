const {net, dialog} = require('electron');
const FormData = require('form-data');
const fs  = require('fs');
exports.authenticate = function(){ 
    return new Promise((resolve,reject)=>{
    var formdata = new FormData();

    var credentials = fs.readFileSync('./.credentials').toString().split('\r\n');
    
    formdata.append("username", credentials[0]); 
    formdata.append("password", credentials[1]);
    formdata.append("practice", credentials[2]);

 


    
   var request =  net.request({
    method: 'POST',
    protocol: 'https:',
    hostname: 'localhost',
    port: 443,
    path: '/MDILogin/token.aspx',
    headers: formdata.getHeaders()
  })

  formdata.pipe(request);

  request.on('response', (response) => {
    console.log(`STATUS: ${response}`);

    response.on('error', (error) => {
      console.log(`ERROR: ${JSON.stringify(error)}`)
    })

    response.on('data', (chunk) => {
      resolve(JSON.parse(chunk.toString()).SessionID)
    })

  })

  request.end();
})
}