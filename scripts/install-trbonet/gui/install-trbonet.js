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
        "trbonetPath": {
            "type": "string",
            "propertyOrder": 4,
            "title": "UNC Path of the TRBONet Installer",
            "minLength": 1,
            "options": {
                "inputAttributes": {
                    "placeholder": "\\\\wyndhamnas.westbus.com.au\\public\\trbonet.exe"
                },
                "infoText": "the network location of the installer. Note that the credentials you use for remoting will also be used for mounting the shared folder"
            }
        },
    }
}

//initializations
var $IT_element = $("#IT_Form")[0]
var $IT_editor = new JSONEditor($IT_element, {
    schema: $IT_schema
});
$IT_log.setTheme("ace/theme/xcode");
$IT_log.session.setMode("ace/mode/mediawiki");
$IT_log.setReadOnly(true);
$IT_log.setAutoScrollEditorIntoView(true);

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
    // $('#IT_Log').append(JSON.stringify($IT_finalJSON));
    // Disable form controls
    $("#IT_Reset").prop("disabled", true);
    $("#IT_Run").prop("disabled", true);

    // spawn the final script
    var args = ["-noninteractive", "-executionpolicy", "bypass", "-file", `${$rootDir}\\scripts\\install-trbonet\\install-trbonet.ps1`, "-json", JSON.stringify($IT_finalJSON)];
    $IT_scriptProcess = spawn(psPath, args);


    $("#IT_Nav2").trigger('click');

    $IT_scriptProcess.stdout.on('data', (data) => {
        data = cleanString(data.toString('utf8'));
        if (data.length > 0) {
            $IT_log.session.insert({
                row: $IT_log.session.getLength(),
                column: 0
            }, (data + "\n"));

            if ($("#IT_Autoscroll")[0].checked) {
                $IT_log.gotoLine($IT_log.session.getLength());
            }
        }
    });

    $IT_scriptProcess.stderr.on('data', (data) => {
        data = cleanString(data.toString('utf8'));
        if (data.length > 0) {
            $IT_log.session.insert({
                row: $IT_log.session.getLength(),
                column: 0
            }, (data + "\n"));

            if ($("#IT_Autoscroll")[0].checked) {
                $IT_log.gotoLine($IT_log.session.getLength());
            }
        }
    });

    $IT_scriptProcess.on('close', (code) => {
        $IT_log.session.insert({
            row: $IT_log.session.getLength(),
            column: 0
        }, (`finished with code ${code}\n`));
        if ($("#IT_Autoscroll")[0].checked) {
            $IT_log.gotoLine($IT_log.session.getLength());
        }
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