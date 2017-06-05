// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

const electron = require('electron');
const shell = electron.shell;

const fs = require('fs');
const os = require('os');
const path = require('path');
const $ = require('jquery');
const next1 = document.getElementById('next1');
const next2 = document.getElementById('next2');
const input1 = document.getElementById('imageInput1');
let currImageList = [];
let currImagePath = "";

input1.addEventListener("change", function () {
    if (this.files && this.files[0]) {
        const reader = new FileReader();
        currImagePath = this.files.item(0).path;
        const regpattern = /(.*)(\\)(.*)(.png)/;
        const imgFolder = currImagePath.replace(regpattern, '$1');
        console.log(imgFolder);
        currImageList = [];
        fs.readdir(imgFolder, function (err, fileslist) {
            if (fileslist.length > 0) {
                fileslist.forEach(function (val, index) {
                    currImageList.push(imgFolder + '\\' + val)
                });
            }
        });
        reader.onload = imageIsLoaded1;
        next1.addEventListener('click', function (event) {
            let currImageIndex = currImageList.findIndex(function (ele, index) {
                return ele === currImagePath;
            });
            let nextImagePath = 0;
            if (currImageIndex === 0) {
                nextImagePath = currImageList[1]
            } else if (currImageIndex) {
                nextImagePath = currImageList[currImageIndex + 1]
            }
            // debugger;
            console.log(nextImagePath);
            currImagePath = nextImagePath;
            document.getElementById('imgView1').setAttribute('src', nextImagePath);
        });
        reader.readAsDataURL(this.files[0]);
    }
}, false);

function imageIsLoaded1(e) {
    $('#imgView1').attr('src', e.target.result);
}

function imageIsLoaded2(e) {
    $('#imgView2').attr('src', e.target.result);
}
