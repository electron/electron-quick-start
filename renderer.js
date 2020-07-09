// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// No Node.js APIs are available in this process because
// `nodeIntegration` is turned off. Use `preload.js` to
// selectively enable features needed in the rendering
// process.

//modules
const fs = require('fs');
var exec = require('child_process').exec;
var spawn = require('child_process').spawn;
const remote = require('electron').remote;
const dialog = remote.dialog;

//local variables
var $rootDir = ""
var $scripts = new Object();
$scripts['menu-install-windows'] = "scripts\\install-windows\\gui\\install-windows";
$scripts['menu-install-kiosk'] = "scripts\\install-kiosk\\gui\\install-kiosk";
$scripts['menu-install-trbonet'] = "scripts\\install-trbonet\\gui\\install-trbonet";

//other options
JSONEditor.defaults.options.theme = 'bootstrap4';
JSONEditor.defaults.options.disable_collapse = true;
JSONEditor.defaults.options.disable_properties = true;
JSONEditor.defaults.options.prompt_before_delete = false;
JSONEditor.defaults.options.disable_array_delete_last_row = true;
JSONEditor.defaults.options.disable_array_delete_all_rows = true;
JSONEditor.defaults.options.disable_array_reorder = true;
JSONEditor.defaults.options.array_controls_top = true;

/**
 * getRootDir dynamically determines the path of the folder *outside* of the executable
 * This is needed because it changes based on if we are running in dev, or a packaged executable
 **/
function getRootDir() {
    let $directories = __dirname.split("\\");
    let $directoriesIndex = $directories.length;

    if ($directories[$directories.length - 1] == 'app.asar' && $directories[$directories.length - 2] == 'resources') {
        $directoriesIndex = $directories.length - 2;
    }

    for (let index = 0; index < $directoriesIndex; index++) {
        $rootDir += $directories[index] + "\\";
    }
    return $rootDir.slice(0, -1);

}


//searchable section menu
$("#section-input").selectize({create: false, maxItems: 1,
    sortField: 'text',
onItemAdd(value) {
    $(`#${value}`).trigger('click');
}})

$rootDir = getRootDir();

var psPath = $rootDir + "\\tools\\pwsh\\pwsh.exe";

//let's import our subcategories
for (var key in $scripts) {
    //add each section to the search box
    $("#section-input")[0].selectize.addOption({value: (key), text: ($('#'+ key).text())});

    var $targetHTML = $rootDir + "\\" + $scripts[key] + ".html";
    var data = fs.readFileSync($targetHTML);
    $("#main").append(data.toString());

    var $targetJS = $rootDir + "\\" + $scripts[key] + ".js";
    $.getScript($targetJS);
}

$("#section-input")[0].selectize.refreshItems();

// //Activate the home section
$("#home").css("display", "");

//main menu button actions
$("#menu-install-windows").click(function () {
    $("section").css("display", "none");
    $("#install-windows").css("display", "");
});

$("#menu-home").click(function () {
    $("section").css("display", "none");
    $("#home").css("display", "");
});

$("#menu-install-kiosk").click(function () {
    $("section").css("display", "none");
    $("#install-kiosk").css("display", "");
});

$("#menu-install-trbonet").click(function () {
    $("section").css("display", "none");
    $("#install-trbonet").css("display", "");
});

exec(`"${psPath}" -noninteractive -executionpolicy bypass "${$rootDir}\\scripts\\gather-computer-info.ps1"`, (error, stdout, stderr) => {
    if (stdout) {
        $("#Home_Data").html(stdout);
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