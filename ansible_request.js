var request = require('request');
var url="https://mms.transock.com/api/v2/job_templates/7/launch/";
var requestData={"extra_vars": {"gamehost": "172.31.16.89"}};

module.exports.task = function(task_id,ip){
    var url = "https://mms.transock.com/api/v2/job_templates/"+task_id+"/launch/";
    request({
        url: url,
        method: "POST",
        json: true,
        auth: {
          user: 'admin',
          password: 'awxlink!@#$'
        },
        rejectUnauthorized:false,
        json: {"extra_vars": {"gamehost": ip}}
    }, function(error, response, body) {
        if (!error && response.statusCode >= 200 && response.statusCode <= 300) {
            console.log('ok')
        }else{
            console.log('error')
        }
    }); 
}
