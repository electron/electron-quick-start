var $BU_schema = {
    "title": "Backup User Profiles",
    "type": "object",
    "format": "grid-strict",
    "description": "This program will give you a list of users detected on the target computer. Then we can back them up to a remote location to restore on another computer/windows install",
    "properties": {
        "ComputerName": {
            "type": "string",
            "title": "Computer Name",
            "minLength": 1,
            "options": {
                "grid_columns": 12,
                "inputAttributes": {
                    "placeholder": "cdcvicws-00001"
                },
                "infoText": "Name of the remote computer we will be backing up the user profiles",
                "dependencies": {
                    "LocalHost": false
                }
            }
        },
        "LocalHost": {
            "type": "boolean",
            "format": "checkbox",
            "title": "Run Script Locally",
            "options": {
                "grid_columns": 12
            },
            "default": false
        },
        "Phase2": {
            "type": "boolean",
            "default": false,
            "options": {
                "hidden": true
            }
        },
        "Users": {
            "title": "Users to Back Up",
            "type": "array",
            "minItems": 1,
            "uniqueItems": true,
            "format": "selectize",
            "items": {
                "type": "string",
                "enum": [],
                "options": {
                    "enum_titles": []
                }
            },
            "options": {
                "grid_columns": 12,
                "selectize": {
                    "create": false
                },
                "dependencies": {
                    "Phase2": true
                }
            }
        },
        "RadioButtons": {
            "type": "string",
            "format": "radio",
            "title": "Backup Location",
            "enum": ["Local Drive", "Network Drive"],
            "options": {
                "grid_columns": 12,
                "dependencies": {
                    "Phase2": true
                }
            }
        },
        "LocalDrive": {
            "title": "Local Drive Path",
            "minLength": 1,
            "type": "string",
            "options": {
                "grid_columns": 6,
                "inputAttributes": {
                    "placeholder": "D:\\Backups"
                },
                "dependencies": {
                    "RadioButtons": "Local Drive",
                    "Phase2": true
                },
                "infoText": "The local folder *on the target machine* that you want to save the profile data"
            }
        },
        "NetworkDrive": {
            "title": "Network Drive Path",
            "minLength": 1,
            "type": "string",
            "pattern": "\\\\\\\\[a-zA-Z0-9\\.\\-_]{1,}(\\\\[a-zA-Z0-9\\-_]{1,}){1,}[\\$]{0,1}",
            "options": {
                "grid_columns": 6,
                "patternmessage": "The path should follow UNC path guidelines (\\\\server\\path)",
                "inputAttributes": {
                    "placeholder": "\\\\networkdrive\\backup"
                },
                "dependencies": {
                    "RadioButtons": "Network Drive",
                    "Phase2": true
                },
                "infoText": "The network path of where you want to save the backup."
            }
        },
        "BackupName": {
            "title": "Backup Name",
            "minLength": 1,
            "type": "string",
            "options": {
                "grid_columns": 6,
                "inputAttributes": {
                    "placeholder": "Name Of Backup"
                },
                "dependencies": {
                    "Phase2": true
                },
                "infoText": "The name of the backup (folder will be created if it does not exist)"
            }
        },
        "username": {
            "title": "Username",
            "type": "string",
            "minLength": 1,
            "options": {
                "grid_columns": 6,
                "inputAttributes": {
                    "placeholder": "domain.com.au\\firstname.lastname"
                },
                "dependencies": {
                    "RadioButtons": "Network Drive",
                    "Phase2": true
                },
                "infoText": "The username and password for the user who has permissions to map the network drive. This is required (even if you have permissions) due to double hop rules"
            }
        },
        "PlainTextPassword": {
            "title": "Password",
            "minLength": 1,
            "type": "string",
            "format": "password",
            "options": {
                "inputAttributes": {
                    "placeholder": "hunter2"
                },
                "grid_columns": 6,
                "dependencies": {
                    "RadioButtons": "Network Drive",
                    "Phase2": true
                }
            }
        }
    }
}



//initializations
var $BU_element = $("#BU_Form")[0]
var $BU_editor = new JSONEditor($BU_element, { schema: $BU_schema });
var $BU_log = ace.edit("BU_Log");
$BU_log.setTheme("ace/theme/xcode");
$BU_log.session.setMode("ace/mode/mediawiki");
$BU_log.setReadOnly(true);
$BU_log.setAutoScrollEditorIntoView(true);

$("#BU_GetUsers").click(function () {
    if (!($BU_editor.validate().length)) {

        //disable the button we just clicked
        $("#BU_GetUsers").prop("disabled", true);
        $("#BU_GetUsersAlert").css("display", "none");
        //disable the form
        $BU_editor.disable();

        //get the form data
        Phase2Data = $BU_editor.getValue()

        //run the powershell script that gets our users
        var args = ["-noninteractive", "-executionpolicy", "bypass", "-file", `${$rootDir}\\scripts\\backup-user-profiles\\gui\\bu-get-users.ps1`, "-json", JSON.stringify(Phase2Data)];
        execFile(psPath, args, (error, stdout, stderr) => {
            if (stdout) {
                gatheredData = JSON.parse(stdout);

                //generate a new form based on the first form's schema.
                //We make a copy so the original is available if we reset the form
                $BU_schema2 = JSON.parse(JSON.stringify($BU_schema));

                //use the output to set our next form's values.
                //The Phase2 boolean unlocks the rest of our form
                $BU_schema2.properties.Users.items.enum = gatheredData.name;
                $BU_schema2.properties.Users.items.options.enum_titles = gatheredData.description;
                $BU_schema2.properties.Phase2.default = true;
                $BU_schema2.properties.ComputerName.default = Phase2Data.ComputerName
                $BU_schema2.properties.LocalHost.default = Phase2Data.LocalHost

                //create the form again with the updated schema
                $BU_editor.destroy();
                $BU_editor = new JSONEditor($BU_element, { schema: $BU_schema2 });

                //disable the parts we've already determined
                $BU_editor.getEditor('root.ComputerName').disable();
                $BU_editor.getEditor('root.LocalHost').disable();

                //Show our new buttons
                $("#BU_Validate").css("display", "initial");
                $("#BU_Run").css("display", "initial");
                $("#BU_GetUsers").css("display", "none");
            }
            if (stderr) {
                console.error(stderr);
                //enable the button we just clicked
                $("#BU_GetUsers").prop("disabled", false);
                //display an alert
                $("#BU_GetUsersAlert").css("display", "initial");

                //enable the form
                $BU_editor.enable();
                return;
            }
            if (error) {
                //enable the button we just clicked
                $("#BU_GetUsers").prop("disabled", false);
                //display an alert
                $("#BU_GetUsersAlert").css("display", "initial");

                //enable the form
                $BU_editor.enable();
                console.error(error);
                return;
            }
        });
    }

    //If we didn't validate properly, show that in our form
    $BU_editor.options.show_errors = "always"
    $BU_editor.onChange();
});



$("#BU_Validate").click(function () {
    if (!($BU_editor.validate().length)) {
        $("#BU_Run").prop("disabled", false);
        $("#BU_Edit").css("display", "initial");
        $("#BU_Validate").css("display", "none");
        $BU_editor.disable();
    }
    $BU_finalJSON = $BU_editor.getValue();
    $BU_editor.options.show_errors = "always"
    $BU_editor.onChange();
});

$("#BU_Edit").click(function () {
    $("#BU_Edit").css("display", "none");
    $("#BU_Validate").css("display", "initial");
    $("#BU_Run").prop("disabled", true);
    $BU_editor.enable();
    $BU_editor.getEditor('root.ComputerName').disable();
    $BU_editor.getEditor('root.LocalHost').disable();
});

$("#BU_Run").click(function () {
    // $('#BU_Log').append(JSON.stringify($BU_finalJSON));
    // Disable form controls
    $("#BU_Reset").prop("disabled", true);
    $("#BU_Run").prop("disabled", true);

    // spawn the final script
    var args = ["-noninteractive", "-executionpolicy", "bypass", "-file", `${$rootDir}\\scripts\\backup-user-profiles\\backup-user-profiles.ps1`, "-json", JSON.stringify($BU_finalJSON)];
    $BU_scriptProcess = spawn(psPath, args);


    $("#BU_Nav2").trigger('click');

    $BU_scriptProcess.stdout.on('data', (data) => {
        data = cleanString(data.toString('utf8'));
        if (data.length > 0) {
            $BU_log.session.insert({
                row: $BU_log.session.getLength(),
                column: 0
            }, (data + "\n"));

            if ($("#BU_Autoscroll")[0].checked) {
                $BU_log.gotoLine($BU_log.session.getLength());
            }
        }
    });

    $BU_scriptProcess.stderr.on('data', (data) => {
        if (data.length > 0) {
            $BU_log.session.insert({
                row: $BU_log.session.getLength(),
                column: 0
            }, (data + "\n"));

            if ($("#BU_Autoscroll")[0].checked) {
                $BU_log.gotoLine($BU_log.session.getLength());
            }
        }
    });

    $BU_scriptProcess.on('close', (code) => {
        $BU_log.session.insert({
            row: $BU_log.session.getLength(),
            column: 0
        }, (`finished with code ${code}\n`));
        if ($("#BU_Autoscroll")[0].checked) {
            $BU_log.gotoLine($BU_log.session.getLength());
        }
        $("#BU_Run").prop("disabled", false);
        $("#BU_Reset").prop("disabled", false);
        $BU_scriptProcess = null
    });
});

$("#BU_Abort").click(function () {
    if ($BU_scriptProcess) {
        process.kill($BU_scriptProcess.pid);
        $BU_scriptProcess = null
    }
    $("#BU_Run").prop("disabled", false);
    $("#BU_Reset").prop("disabled", false);
    $("#BU_Edit").prop("disabled", false);
});

$("#BU_Reset").click(function () {
    $("#BU_Nav1").trigger('click');
    $BU_editor.destroy();
    $BU_editor = new JSONEditor($BU_element, {
        schema: $BU_schema
    });
    $("#BU_Validate").prop("disabled", false);
    $("#BU_Run").prop("disabled", true);

    //show initial button state new buttons
    $("#BU_Validate").css("display", "none");
    $("#BU_Run").css("display", "none");
    $("#BU_GetUsers").css("display", "initial");
    $("#BU_GetUsers").prop("disabled", false);
});