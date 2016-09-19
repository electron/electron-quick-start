// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

'use strict';
const java = require('java');

var list1 = java.newInstanceSync("java.util.ArrayList");
console.log(list1.sizeSync()); // 0
list1.addSync('item1');

module.exports = list1.sizeSync();