var $IT_schema = {
    "title": "Install TRBOnet",
    "type": "object",
    "properties": {
        "ComputerName": {
            "type": "string",
            "title": "Computer Name",
            "minLength": 1,
            "propertyOrder": 1,
            "options": {
                "inputAttributes": {
                    "placeholder": "cdcvicws-00001"
                },
                "infoText": "Name of the remote computer we will be installing TRBOnet on"
            }
        },
        "Username": {
            "type": "string",
            "propertyOrder": 2,
            "title": "Login Username",
            "minLength": 1,
            "options": {
                "inputAttributes": {
                    "placeholder": "christopher.bisset"
                },
                "infoText": "Your username. Used to map the shared drive. Required because of double hop problems"
            }
        },
        "PlainTextPassword": {
            "type": "string",
            "format": "password",
            "title": "Login Password",
            "minLength": 1,
            "propertyOrder": 3,
            "options": {
                "inputAttributes": {
                    "placeholder": "hunter2"
                }
            }
        },
        "NasName": {
            "type": "string",
            "propertyOrder": 4,
            "title": "Local NAS Name/IP",
            "minLength": 1,
            "options": {
                "inputAttributes": {
                    "placeholder": "wyndhamnas.westbus.com.au"
                }
            }
        },
    }
}

//initializations
var $IT_element = $("#IT_Form")[0]
var $IT_editor = new JSONEditor($IT_element, {
    schema: $IT_schema
});

$("#IT_Validate").click(function () {
    if (!($IT_editor.validate().length)) {
        $("#IT_Run").prop("disabled", false);
        $("#IT_Edit").css("display", "initial");
        $("#IT_Validate").css("display", "none");
        $IT_editor.disable();
    }
    $IT_finalJSON = $IT_editor.getValue();
    $IT_editor.options.show_errors = "always"
    $IT_editor.onChange();
});

$("#IT_Edit").click(function () {
    $("#IT_Edit").css("display", "none");
    $("#IT_Validate").css("display", "initial");
    $("#IT_Run").prop("disabled", true);
    $IT_editor.enable();
});

$("#IT_Run").click(function () {
    // $('#IT_Log').prepend(JSON.stringify($IT_finalJSON));
    // Disable form controls
    $("#IT_Reset").prop("disabled", true);
    $("#IT_Run").prop("disabled", true);

    // spawn the final script
    var args = ["-noninteractive", "-executionpolicy", "bypass", "-file", `${$rootDir}\\scripts\\install-trbonet\\install-trbonet.ps1`, "-json", JSON.stringify($IT_finalJSON)];
    $IT_scriptProcess = spawn(psPath, args);


    $("#IT_Nav2").trigger('click');

    $IT_scriptProcess.stdout.on('data', (data) => {
        if (data) {
            data = data.toString('utf8');
            $('#IT_Log').prepend(data);
            // console.log(data);
        }
    });

    $IT_scriptProcess.stderr.on('data', (data) => {
        if (data) {
            data = data.toString('utf8');
            $('#IT_Log').prepend(data);
            // console.log(data);
        }
    });

    $IT_scriptProcess.on('close', (code) => {
        $('#IT_Log').prepend(`finished with code ${code}\n`);
        $("#IT_Run").prop("disabled", false);
        $("#IT_Reset").prop("disabled", false);
        $IT_scriptProcess = null
    });
});

$("#IT_Abort").click(function () {
    if ($IT_scriptProcess) {
        process.kill($IT_scriptProcess.pid);
        $IT_scriptProcess = null
    }
    $("#IT_Run").prop("disabled", false);
    $("#IT_Reset").prop("disabled", false);
    $("#IT_Edit").prop("disabled", false);
});

$("#IT_Reset").click(function () {
    $("#IT_Nav1").trigger('click');
    $IT_editor.destroy();
    $IT_editor = new JSONEditor($IT_element, {
        schema: $IT_schema
    });
    $("#IT_Validate").prop("disabled", false);
    $("#IT_Run").prop("disabled", true);
});