// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

const electron = require('electron');
const shell = electron.shell;

const fs = require('fs');
const os = require('os');
const path = require('path');
const $ = require('jquery');
const imgviewport = document.getElementById('imgviewport');
let currImageList = [];

$(function () {
    $("#imageInput1").change(function () {
        if (this.files && this.files[0]) {
            const reader = new FileReader();
            const imgpath = this.files.item(0).path;
            const regpattern = /(.*)(\\)(.*)(.png)/;
            const imgFolder = imgpath.replace(regpattern, '$1');
            console.log(imgFolder);
            fs.readdir(imgFolder, function (err, fileslist) {
                if (fileslist.length > 0) {
                    debugger;
                }
            });
            reader.onload = imageIsLoaded1;
            reader.readAsDataURL(this.files[0]);
        }
    });
        $("#imageInput2").change(function () {
        if (this.files && this.files[0]) {
            const reader = new FileReader();
            const imgpath = this.files.item(0).path;
            const regpattern = /(.*)(\\)(.*)(.png)/;
            const imgFolder = imgpath.replace(regpattern, '$1');
            console.log(imgFolder);
            fs.readdir(imgFolder, function (err, fileslist) {
                if (fileslist.length > 0) {
                    debugger;
                }
            });
            reader.onload = imageIsLoaded2;
            reader.readAsDataURL(this.files[0]);
        }
    });
});

function imageIsLoaded1(e) {
    $('#imgView1').attr('src', e.target.result);
}

function imageIsLoaded2(e) {
    $('#imgView2').attr('src', e.target.result);
}

