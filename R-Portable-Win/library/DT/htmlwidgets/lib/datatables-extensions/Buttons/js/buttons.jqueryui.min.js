/*!
 jQuery UI integration for DataTables' Buttons
 ©2016 SpryMedia Ltd - datatables.net/license
*/
(function(c){"function"===typeof define&&define.amd?define(["jquery","datatables.net-jqui","datatables.net-buttons"],function(a){return c(a,window,document)}):"object"===typeof exports?module.exports=function(a,b){a||(a=window);if(!b||!b.fn.dataTable)b=require("datatables.net-jqui")(a,b).$;b.fn.dataTable.Buttons||require("datatables.net-buttons")(a,b);return c(b,a,a.document)}:c(jQuery,window,document)})(function(c){var a=c.fn.dataTable;c.extend(!0,a.Buttons.defaults,{dom:{container:{className:"dt-buttons ui-buttonset"},
button:{className:"dt-button ui-button ui-state-default ui-button-text-only",disabled:"ui-state-disabled",active:"ui-state-active"},buttonLiner:{tag:"span",className:"ui-button-text"}}});a.ext.buttons.collection.text=function(a){return a.i18n("buttons.collection",'Collection <span class="ui-button-icon-primary ui-icon ui-icon-triangle-1-s"/>')};return a.Buttons});
