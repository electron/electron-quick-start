// local variables
var $WI_imagePath
var $WI_editor
var $WI_schema = {
    "title": "Install Windows",
    "type": "object",
    "format": "grid-strict",
    "description": "This program is designed to be used with a PE Environment Only. Used to provide a gui assisted installation of windows. NOTE: Only compatible with windows 10 and server 2016 or newer",
    "required": [
        "DiskNumber",
        "ImageLocation",
        "ImageIndex"
    ],
    "properties": {
        "ImageLocation": {
            "type": "string",
            "title": "Image Location",
            "options": {
                "grid_columns": 12
            }
        },
        "Profile": {
            "type": "string",
            "default": "deploy",
            "options": {
                "grid_columns": 12,
                "hidden": true,

            }
        },
        "Phase2": {
            "type": "boolean",
            "default": false,
            "options": {
                "grid_columns": 12,
                "hidden": true,
            }
        },
        "DiskNumber": {
            "title": "Disk to be Wiped",
            "type": "integer",
            "format": "array",
            "enum": [],
            "default": 0,
            "options": {
                "grid_columns": 12,
                "dependencies": {
                    "Phase2": true
                },
                "enum_titles": []
            }
        },
        "ImageIndex": {
            "title": "Windows Edition",
            "type": "integer",
            "format": "array",
            "enum": [],
            "default": 6,
            "options": {
                "grid_columns": 12,
                "dependencies": {
                    "Phase2": true
                },
                "enum_titles": []
            }
        },
        "ComputerName": {
            "title": "Computer Name",
            "type": "string",
            "minLength": 1,
            "maxLength": 15,
            "pattern": "[^.:|\\\\/*?<>\"][^:|\\\\/*?<>\"]*$",
            "options": {
                "grid_columns": 12,
                "dependencies": {
                    "Phase2": true
                },
                "patternmessage": "The name must follow microsoft guidelines: (https://support.microsoft.com/en-au/help/909264/naming-conventions-in-active-directory-for-computers-domains-sites-and)",
                "inputAttributes": {
                    "placeholder": "CDCVICxx-xxxxx"
                },
                "infoText": "The name you want the computer to have upon installation. See wiki for naming conventions."
            },
        },
        "Installers": {
            "title": "Install Programs",
            "type": "array",
            "uniqueItems": true,
            "format": "selectize",
            "items": {
                "type": "string",
                "enum": []
            },
            "options": {
                "grid_columns": 12,
                "dependencies": {
                    "Phase2": true
                },
                "selectize": {
                    "create": false
                }
            }
        },
        "UEFIMode": {
            "title": "UEFI Mode",
            "type": "boolean",
            "format": "checkbox",
            "default": true,
            "options": {
                "grid_columns": 12,
                "dependencies": {
                    "Phase2": true
                },
                "infoText": "Decide whether or not to install in UEFI mode. Unchecked defaults to MBR mode"
            }
        },
        "EnableJoinDomain": {
            "title": "Join a Domain",
            "type": "boolean",
            "format": "checkbox",
            "default": false,
            "options": {
                "grid_columns": 12,
                "dependencies": {
                    "Phase2": true
                }
            }
        },
        "Domain": {
            "title": "Domain FQDN",
            "type": "string",
            "pattern": "^(?!:\\/\\/)(?=.{1,255}$)((.{1,63}\\.){1,127}(?![0-9]*$)[a-z0-9-]+\\.?)$",
            "format": "url",
            "minLength": 1,
            "options": {
                "patternmessage": "The domain should follow FQDN guidelines (https://regexr.com/3g5j0)",
                "grid_columns": 6,
                "inputAttributes": {
                    "placeholder": "domain.com.au"
                },
                "dependencies": {
                    "EnableJoinDomain": true,
                    "Phase2": true
                },
                "infoText": "The full FQDN (fully qualified domain name) for the domain we are joining"
            }
        },
        "username": {
            "title": "Username",
            "type": "string",
            "minLength": 1,
            "options": {
                "grid_columns": 6,
                "inputAttributes": {
                    "placeholder": "firstname.lastname"
                },
                "dependencies": {
                    "EnableJoinDomain": true,
                    "Phase2": true
                },
                "infoText": "The username and password for the user who has permissions to join people to the domain"
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
                    "EnableJoinDomain": true,
                    "Phase2": true
                }
            }
        },
        "IntegrateDrivers": {
            "title": "Integrate Drivers",
            "type": "boolean",
            "format": "checkbox",
            "default": false,
            "options": {
                "grid_columns": 12,
                "dependencies": {
                    "Phase2": true
                },
                "infoText": "If you have a folder of drivers to integrate, you can enable that option"
            }
        },
        "DriverFolder": {
            "title": "Path to Drivers",
            "type": "string",
            "minLength": 1,
            "options": {
                "grid_columns": 12,
                "inputAttributes": {
                    "placeholder": "D:\\drivers"
                },
                "dependencies": {
                    "IntegrateDrivers": true,
                    "Phase2": true
                },
                "infoText": "the path of to the folder containing drivers. Example: D:\\ (for root) or D:\\subfolder"
            }
        },
        "Wifi": {
            "title": "Include Wifi Profile",
            "type": "boolean",
            "format": "checkbox",
            "default": false,
            "options": {
                "grid_columns": 12,
                "dependencies": {
                    "Phase2": true
                },
                "infoText": "Include the wifi profiles associated with CDC"
            }
        }
    }
}

//generate the form
var $WI_element = $("#WI_Form")[0]
var $WI_editor = new JSONEditor($WI_element, {schema: $WI_schema});
$WI_editor.getEditor('root.ImageLocation').disable();

//We make a copy of the schema for phase 2,
//so the original is available if we reset the form
$WI_schema2 = JSON.parse(JSON.stringify($WI_schema));

function generateForm($imagePath) {
    exec(`"${psPath}" -noninteractive -executionpolicy bypass "${$rootDir}\\scripts\\install-windows\\gui\\wi-gather-data.ps1" ${$imagePath}`, (error, stdout, stderr) => {
        if (stdout) {
            gatheredData = JSON.parse(stdout);
            // console.log(gatheredData)

            //generate form based off gathered information
            $WI_schema2.properties.ImageIndex.enum = gatheredData.imageIndex;
            $WI_schema2.properties.ImageIndex.options.enum_titles = gatheredData.imageName;
            $WI_schema2.properties.DiskNumber.enum = gatheredData.driveIndex;
            $WI_schema2.properties.DiskNumber.options.enum_titles = gatheredData.driveCaption;
            $WI_schema2.properties.Installers.items.enum = gatheredData.Installers
            $WI_schema2.properties.Phase2.default = true

            $("#WI_Autodetect").css("display", "none");
            $("#WI_Browse").css("display", "none");
            $("#WI_Validate").css("display", "initial");
            $("#WI_Run").css("display", "initial");
            
            $WI_editor.destroy();
            $WI_editor = new JSONEditor($WI_element, {schema: $WI_schema2});
            $WI_editor.getEditor('root.ImageLocation').disable();
            return;
        }
        if (stderr) {
            console.error(stderr);
            return;
        }
        if (error) {
            console.error(error);
            return;
        }
    });
}


$("#WI_Browse").click(function () {

    $("#WI_Browse").attr("disabled", true);
    $("#WI_Autodetect").attr("disabled", true);

    dialog.showOpenDialog({ properties: ['openFile'], filters: [{ name: 'Image Files', extensions: ['wim', 'swm'] }] }).then(result => {
        if (result.filePaths.length != 0) {
            $WI_schema2.properties.ImageLocation.default = result.filePaths[0];
            generateForm(result.filePaths[0]);
        } else {
            $("#WI_Browse").attr("disabled", false);
            $("#WI_Autodetect").attr("disabled", false);
        }
    });
});

$("#WI_Autodetect").click(function () {
    $("#WI_Browse").attr("disabled", true);
    $("#WI_Autodetect").attr("disabled", true);

    exec(`"${psPath}" -noninteractive -executionpolicy bypass "${$rootDir}\\scripts\\install-windows\\gui\\wi-detect-image.ps1"`, (error, stdout, stderr) => {
        if (stdout) {
            $WI_schema2.properties.ImageLocation.default = stdout;
            generateForm(stdout);
            return;
        }
        if (stderr) {
            console.error(stderr);
            $("#WI_Browse").attr("disabled", false);
            $("#WI_Autodetect").attr("disabled", false);
            return;
        }
        if (error) {
            $("#WI_Browse").attr("disabled", false);
            $("#WI_Autodetect").attr("disabled", false);
            console.error(error);
            return;
        }
    });
});

$("#WI_Validate").click(function () {
    if (!($WI_editor.validate().length)) {
        $("#WI_Edit").css("display", "initial");
        $("#WI_Validate").css("display", "none");
        $("#WI_Run").prop("disabled", false);
        $WI_editor.disable();
    }
    $WI_finalJSON = $WI_editor.getValue();


    $WI_editor.options.show_errors = "always";
    $WI_editor.onChange();
});

$("#WI_Edit").click(function () {
    $("#WI_Edit").css("display", "none");
    $("#WI_Validate").css("display", "initial");
    $("#WI_Run").prop("disabled", true);
    $WI_editor.enable();
});

$("#WI_Reset").click(function () {
    $("#WI_Nav1").trigger('click');
    $WI_editor.destroy();

    //set buttons to initial values
    $("#WI_Validate").prop("disabled", false);
    $("#WI_Validate").css("display", "none");

    $("#WI_Run").prop("disabled", true);
    $("#WI_Run").css("display", "none");

    $("#WI_Edit").css("display", "none");

    $("#WI_Autodetect").attr("disabled", false);
    $("#WI_Autodetect").css("display", "initial");

    $("#WI_Browse").attr("disabled", false);
    $("#WI_Browse").css("display", "initial");

    //generate the form again
    $WI_editor = new JSONEditor($WI_element, {schema: $WI_schema});
    $WI_editor.getEditor('root.ImageLocation').disable();
});

$("#WI_Run").click(function () {
    // $('#WI_Log').prepend(JSON.stringify($WI_finalJSON));
    // Disable form controls
    $("#WI_Edit").prop("disabled", true);
    $("#WI_Run").prop("disabled", true);
    $("#WI_Reset").prop("disabled", true);

    // spawn the final script
    var args = ["-noninteractive", "-executionpolicy", "bypass", "-file", `${$rootDir}\\scripts\\install-windows\\Install-windows.ps1`, "-json", JSON.stringify($WI_finalJSON)];
    $WI_scriptProcess = spawn(psPath, args);


    $("#WI_Nav2").trigger('click');

    $WI_scriptProcess.stdout.on('data', (data) => {
        if (data) {
            data = data.toString('utf8');
            $('#WI_Log').prepend(data);
            // console.log(data);
        }
    });

    $WI_scriptProcess.stderr.on('data', (data) => {
        if (data) {
            data = data.toString('utf8');
            $('#WI_Log').prepend(data);
            // console.log(data);
        }
    });

    $WI_scriptProcess.on('close', (code) => {
        $('#WI_Log').prepend(`finished with code ${code}\n`);
        $("#WI_Reset").prop("disabled", false);
        $("#WI_Edit").prop("disabled", false);
        $("#WI_Run").prop("disabled", false);
        $WI_scriptProcess = null
    });
});

$("#WI_Abort").click(function () {
    if ($WI_scriptProcess) {
        process.kill($WI_scriptProcess.pid);
        $WI_scriptProcess = null
    }
    $("#WI_Run").prop("disabled", false);
    $("#WI_Edit").prop("disabled", false);
    $("#WI_Reset").prop("disabled", false);
});