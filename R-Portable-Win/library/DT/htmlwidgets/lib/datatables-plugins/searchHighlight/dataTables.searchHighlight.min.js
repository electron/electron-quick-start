/*!
   Copyright 2014 SpryMedia Ltd.

 License      MIT - http://datatables.net/license/mit

 This feature plug-in for DataTables will highlight search terms in the
 DataTable as they are entered into the main search input element, or via the
 `search()` API method.

 It depends upon the jQuery Highlight plug-in by Bartek Szopka:
    http://bartaz.github.io/sandbox.js/jquery.highlight.js

 Search highlighting in DataTables can be enabled by:

 * Adding the class `searchHighlight` to the HTML table
 * Setting the `searchHighlight` parameter in the DataTables initialisation to
   be true
 * Setting the `searchHighlight` parameter to be true in the DataTables
   defaults (thus causing all tables to have this feature) - i.e.
   `$.fn.dataTable.defaults.searchHighlight = true`.

 For more detailed information please see:
     http://datatables.net/blog/2014-10-22
 SearchHighlight for DataTables v1.0.1
 2014 SpryMedia Ltd - datatables.net/license
*/
(function(h,e,a){function f(d,c){d.unhighlight();c.rows({filter:"applied"}).data().length&&(c.columns().every(function(){this.nodes().flatten().to$().unhighlight({className:"column_highlight"});this.nodes().flatten().to$().highlight(a.trim(this.search()).split(/\s+/),{className:"column_highlight"})}),d.highlight(a.trim(c.search()).split(/\s+/)))}a(e).on("init.dt.dth",function(d,c,e){if("dt"===d.namespace){var b=new a.fn.dataTable.Api(c),g=a(b.table().body());if(a(b.table().node()).hasClass("searchHighlight")||
c.oInit.searchHighlight||a.fn.dataTable.defaults.searchHighlight)b.on("draw.dt.dth column-visibility.dt.dth column-reorder.dt.dth",function(){f(g,b)}).on("destroy",function(){b.off("draw.dt.dth column-visibility.dt.dth column-reorder.dt.dth")}),b.search()&&f(g,b)}})})(window,document,jQuery);
