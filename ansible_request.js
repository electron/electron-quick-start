var request = require('request');
//var url="https://mms.transock.com/api/v2/job_templates/7/launch/";
//var requestData={"extra_vars": {"gamehost": "172.31.16.89"}};

module.exports.task = function(task_id,ip){
	if(task_id == 10){
		//关机
		var url ="http://status.golgaming.com:8443/api/v1/launch?jtname=shutdown&jthost="+ip;
	}
    //var url = "https://ims.golgaming.com/api/v2/job_templates/"+task_id+"/launch/";
    request({
        url: url,
        method: "POST"
    }, function(error, response, body) {
        if (!error && response.statusCode >= 200 && response.statusCode <= 300) {
            console.log('ok')
        }else{
            console.log('error')
        }
    }); 
}

module.exports.taskopen = function(ip,mac){
	var url = "http://status.golgaming.com:8443/api/v1/launch?jtname=wakeonlan&macaddr="+mac;
    //var url = "https://ims.golgaming.com/api/v2/job_templates/14/launch/";
    request({
        url: url,
        method: "POST"
    }, function(error, response, body) {
        if (!error && response.statusCode >= 200 && response.statusCode <= 300) {
            console.log('ok')
        }else{
            console.log('error')
        }
    }); 
}
