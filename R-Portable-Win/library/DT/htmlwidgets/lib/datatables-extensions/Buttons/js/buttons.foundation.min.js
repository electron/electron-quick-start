/*!
 Foundation integration for DataTables' Buttons
 ©2016 SpryMedia Ltd - datatables.net/license
*/
(function(c){"function"===typeof define&&define.amd?define(["jquery","datatables.net-zf","datatables.net-buttons"],function(a){return c(a,window,document)}):"object"===typeof exports?module.exports=function(a,b){a||(a=window);if(!b||!b.fn.dataTable)b=require("datatables.net-zf")(a,b).$;b.fn.dataTable.Buttons||require("datatables.net-buttons")(a,b);return c(b,a,a.document)}:c(jQuery,window,document)})(function(c){var a=c.fn.dataTable;c.extend(!0,a.Buttons.defaults,{dom:{container:{tag:"div",className:"dt-buttons button-group"},
buttonContainer:{tag:null,className:""},button:{tag:"a",className:"button small"},buttonLiner:{tag:null},collection:6===a.ext.foundationVersion?{tag:"div",className:"dt-button-collection dropdown-pane is-open button-group stacked"}:{tag:"ul",className:"dt-button-collection f-dropdown open dropdown-pane is-open",button:{tag:"li",className:"small"},buttonLiner:{tag:"a"}}}});a.ext.buttons.collection.className="buttons-collection dropdown";return a.Buttons});
