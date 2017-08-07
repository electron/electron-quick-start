/*!
 SearchHighlight for DataTables v1.0.1
 2014 SpryMedia Ltd - datatables.net/license
*/
(function(h,g,b){function e(d,c){d.unhighlight();c.rows({filter:"applied"}).data().length&&d.highlight(b.trim(c.search()).split(/\s+/))}b(g).on("init.dt.dth",function(d,c){if("dt"===d.namespace){var a=new b.fn.dataTable.Api(c),f=b(a.table().body());if(b(a.table().node()).hasClass("searchHighlight")||c.oInit.searchHighlight||b.fn.dataTable.defaults.searchHighlight)a.on("draw.dt.dth column-visibility.dt.dth column-reorder.dt.dth",function(){e(f,a)}).on("destroy",function(){a.off("draw.dt.dth column-visibility.dt.dth column-reorder.dt.dth")}),
a.search()&&e(f,a)}})})(window,document,jQuery);
