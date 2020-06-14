var $IK_schema = {
    "title": "Install Kiosk",
    "type": "object",
    "description": "This program is designed to be used with a fresh installation of Ubuntu LTS or a fresh installation of a Raspberry Pi. Used in a variety of kiosk applications. See the wiki for more details",
    "properties": {
        "ComputerName": {
            "type": "string",
            "title": "Computer Name or IP Address",
            "minLength": 1,
            "propertyOrder": 1,
            "options": {
                "inputAttributes": {
                    "placeholder": "192.168.x.x"
                },
                "infoText": "Name or IP Address of the kiosk we are targeting"
            }
        },
        "Username": {
            "type": "string",
            "propertyOrder": 2,
            "title": "Login Username",
            "minLength": 1,
            "options": {
                "inputAttributes": {
                    "placeholder": "pi"
                },
                "infoText": "The username of the root or admin account. For first run on a pi, this will be pi. \
                For first run on ubuntu, it would be the username you specified during installation. Subsequent runs will be root"
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
                },
                "infoText": "The password of the root or admin account. For first run on a pi, this will be raspberry. \
                For first run on ubuntu, it will be the password specified during installation. Subsequent runs will be the kiosk password",
            }
        },
        "PlainTextKioskPassword": {
            "type": "string",
            "format": "password",
            "title": "Kiosk Password",
            "minLength": 1,
            "propertyOrder": 4,
            "options": {
                "infoText": "The password we want to set the root and kiosk account to use. Please see the wiki for password guidelines"
            }
        },
        "RadioButtons": {
            "type": "string",
            "format": "radio",
            "title": "Kiosk Options",
            "enum": ["Web Kiosk", "RDP Kiosk", "Xibo Kiosk"],
            "propertyOrder": 5
        },
        "BrowserURL": {
            "title": "Default URL",
            "minLength": 1,
            "type": "string",
            "format": "url",
            "options": {
                "inputAttributes": {
                    "placeholder": "https://intranet.cdcvictoria.com.au"
                },
                "dependencies": {
                    "RadioButtons": "Web Kiosk"
                },
                "infoText": "The homepage and default page of the web browser"
            },
            "propertyOrder": 6
        },
        "BrowserKioskMode": {
            "title": "Browser Kiosk Mode",
            "type": "boolean",
            "format": "checkbox",
            "options": {
                "dependencies": {
                    "RadioButtons": "Web Kiosk"
                },
                "infoText": "Put the browser into kiosk mode (no address bar and full screen)"
            },
            "propertyOrder": 7
        },
        "BrowserAutoRefresh": {
            "title": "Automatically Refresh Page",
            "type": "boolean",
            "format": "checkbox",
            "options": {
                "dependencies": {
                    "RadioButtons": "Web Kiosk"
                },
                "infoText": "Automatically refresh the page every ten minutes"
            },
            "propertyOrder": 8
        },
        "AutoHideCursor": {
            "title": "Automatically Hide Mouse Cursor",
            "type": "boolean",
            "format": "checkbox",
            "options": {
                "dependencies": {
                    "RadioButtons": "Web Kiosk"
                },
                "infoText": "Automatically hide the cursor while it is not moving"
            },
            "propertyOrder": 9
        },
        "BrowserURLWhitelist": {
            "title": "Browser Whitelist (leave empty to not use)",
            "type": "array",
            "format": "table",
            "uniqueItems": true,
            "items": {
                "type": "string",
                "title": "Domain Addresses"
            },
            "options": {
                "dependencies": {
                    "RadioButtons": "Web Kiosk"
                }
            },
            "propertyOrder": 10
        },
        "RDPURL": {
            "title": "Remote Host URL",
            "type": "string",
            "format": "url",
            "minLength": 1,
            "options": {
                "inputAttributes": {
                    "placeholder": "RDTS.contosso.com.au"
                },
                "dependencies": {
                    "RadioButtons": "RDP Kiosk"
                },
                "infoText": "the fully qualified domain name of the host you want the RDP to connect to"
            },
            "propertyOrder": 11
        },
        "RDPDomain": {
            "title": "User Domain",
            "type": "string",
            "minLength": 1,
            "format": "url",
            "options": {
                "inputAttributes": {
                    "placeholder": "contosso.com.au"
                },
                "dependencies": {
                    "RadioButtons": "RDP Kiosk"
                },
                "infoText": "The domain of the user who is connecting to RDP"
            },
            "propertyOrder": 12
        },
        "RDPUserName": {
            "title": "Username",
            "type": "string",
            "minLength": 1,
            "options": {
                "inputAttributes": {
                    "placeholder": "RDTSUser01"
                },
                "dependencies": {
                    "RadioButtons": "RDP Kiosk"
                },
                "infoText": "The username that is trying to connect to the server"
            },
            "propertyOrder": 13
        },
        "RDPPlainTextPassword": {
            "title": "Password",
            "format": "password",
            "minLength": 1,
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "hunter2"
                },
                "dependencies": {
                    "RadioButtons": "RDP Kiosk"
                },
                "infoText": "The password for the above user"
            },
            "propertyOrder": 14
        },
        "EnableMeshCentral": {
            "title": "Update or Install Meshcentral",
            "type": "boolean",
            "format": "checkbox",
            "propertyOrder": 15
        },
        "MeshCentralURL": {
            "title": "Mesh Central Site URL",
            "minLength": 1,
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "https://www.meshcentral.com"
                },
                "dependencies": {
                    "EnableMeshCentral": true
                },
                "infoText": "The address of the site you log in to remotely manage machines (IE: mesh.<domain>.com.au)"
            },
            "propertyOrder": 16
        },
        "MeshCentralGroupKey": {
            "title": "Mesh Central Group Key",
            "minLength": 1,
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "sDVzakfrtaM7u4NCau6jrR3WE2PxBSvFiXNp$KVRgVIBm5@8JwIcBjLBliCb$df0"
                },
                "dependencies": {
                    "EnableMeshCentral": true
                },
                "infoText": "The base64 encoded key that associates the client with a group. You can find this key by going into meshcentral, going to 'Add Agent' (next to the group),\
                and using the linux dropdown. The key is within there"
            },
            "propertyOrder": 17
        },
        "MeshCentralForceReinstall": {
            "title": "Force Update of Meshcentral",
            "type": "boolean",
            "format": "checkbox",
            "options": {
                "dependencies": {
                    "EnableMeshCentral": true
                }
            },
            "propertyOrder": 18
        }
    }
}

//initializations
var $IK_HelpTab1 = `${$rootDir}\\scripts\\install-kiosk\\gui\\kiosk-installation-guide-(ubuntu).html`;
fs.readFile($IK_HelpTab1, (err, data) => {
    if (err) throw err;
    $("#IK_HelpTab1").append(data.toString());
});

var $IK_HelpTab2 = `${$rootDir}\\scripts\\install-kiosk\\gui\\kiosk-installation-guide-(raspberry-pi).html`;
fs.readFile($IK_HelpTab2, (err, data) => {
    if (err) throw err;
    $("#IK_HelpTab2").append(data.toString());
});

var $IK_element = $("#IK_Form")[0]
var $IK_editor = new JSONEditor($IK_element, {
    schema: $IK_schema
});

$("#IK_Validate").click(function () {
    if (!($IK_editor.validate().length)) {
        $("#IK_Run").prop("disabled", false);
        $("#IK_Edit").css("display", "initial");
        $("#IK_Validate").css("display", "none");
        $IK_editor.disable();
    }
    $IK_finalJSON = $IK_editor.getValue();
    //convert radio buttons to correct json values
    switch ($IK_finalJSON.RadioButtons) {
        case "Web Kiosk":
            $IK_finalJSON.EnableBrowser = true;
            break;
        case "RDP Kiosk":
            $IK_finalJSON.EnableRDP = true;
            break;
        case "Xibo Kiosk":
            $IK_finalJSON.EnableXibo = true;
            break;
    }
    $IK_editor.options.show_errors = "always"
    $IK_editor.onChange();
});

$("#IK_Edit").click(function () {
    $("#IK_Edit").css("display", "none");
    $("#IK_Validate").css("display", "initial");
    $("#IK_Run").prop("disabled", true);
    $IK_editor.enable();
});

$("#IK_Run").click(function () {
    // $('#IK_Log').prepend(JSON.stringify($IK_finalJSON));
    // Disable form controls
    $("#IK_Reset").prop("disabled", true);
    $("#IK_Run").prop("disabled", true);
    
    // spawn the final script
    var args = ["-file", `${$rootDir}\\scripts\\install-kiosk\\Install-Kiosk.ps1`, "-json", JSON.stringify($IK_finalJSON)];
    $IK_scriptProcess = spawn(psPath, args);


    $("#IK_Nav2").trigger('click');

    $IK_scriptProcess.stdout.on('data', (data) => {
        if (data) {
            data = data.toString('utf8');
            $('#IK_Log').prepend(data);
            // console.log(data);
        }
    });

    $IK_scriptProcess.stderr.on('data', (data) => {
        if (data) {
            data = data.toString('utf8');
            $('#IK_Log').prepend(data);
            // console.log(data);
        }
    });

    $IK_scriptProcess.on('close', (code) => {
        $('#IK_Log').prepend(`finished with code ${code}\n`);
        $("#IK_Run").prop("disabled", false);
        $("#IK_Reset").prop("disabled", false);
        $IK_scriptProcess = null
    });
});

$("#IK_Abort").click(function () {
    if($IK_scriptProcess) {
        process.kill($IK_scriptProcess.pid);
        $IK_scriptProcess = null
    }
    $("#IK_Run").prop("disabled", false);
    $("#IK_Reset").prop("disabled", false);
    $("#IK_Edit").prop("disabled", false);
});

$("#IK_Reset").click(function() {
    $("#IK_Nav1").trigger('click');
    $IK_editor.destroy();
    $IK_editor = new JSONEditor($IK_element, {
        schema: $IK_schema
    });
    $("#IK_Validate").prop("disabled", false);
    $("#IK_Run").prop("disabled", true);
});