/**
 * Data can often be a complicated mix of numbers and letters (file names
 * are a common example) and sorting them in a natural manner is quite a
 * difficult problem.
 * 
 * Fortunately a deal of work has already been done in this area by other
 * authors - the following plug-in uses the [naturalSort() function by Jim
 * Palmer](http://www.overset.com/2008/09/01/javascript-natural-sort-algorithm-with-unicode-support) to provide natural sorting in DataTables.
 *
 *  @name Natural sorting
 *  @summary Sort data with a mix of numbers and letters _naturally_.
 *  @author [Jim Palmer](http://www.overset.com/2008/09/01/javascript-natural-sort-algorithm-with-unicode-support)
 *  @author [Michael Buehler] (https://github.com/AnimusMachina)
 *
 *  @example
 *    $('#example').dataTable( {
 *       columnDefs: [
 *         { type: 'natural', targets: 0 }
 *       ]
 *    } );
 *
 *    Html can be stripped from sorting by using 'natural-nohtml' such as
 *
 *    $('#example').dataTable( {
 *       columnDefs: [
 *    	   { type: 'natural-nohtml', targets: 0 }
 *       ]
 *    } );
 *
 */

(function() {

/*
 * Natural Sort algorithm for Javascript - Version 0.7 - Released under MIT license
 * Author: Jim Palmer (based on chunking idea from Dave Koelle)
 * Contributors: Mike Grier (mgrier.com), Clint Priest, Kyle Adams, guillermo
 * See: http://js-naturalsort.googlecode.com/svn/trunk/naturalSort.js
 */
function naturalSort (a, b, html) {
	var re = /(^-?[0-9]+(\.?[0-9]*)[df]?e?[0-9]?%?$|^0x[0-9a-f]+$|[0-9]+)/gi,
		sre = /(^[ ]*|[ ]*$)/g,
		dre = /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[\/\-]\d{1,4}[\/\-]\d{1,4}|^\w+, \w+ \d+, \d{4})/,
		hre = /^0x[0-9a-f]+$/i,
		ore = /^0/,
		htmre = /(<([^>]+)>)/ig,
		// convert all to strings and trim()
		x = a.toString().replace(sre, '') || '',
		y = b.toString().replace(sre, '') || '';
		// remove html from strings if desired
		if (!html) {
			x = x.replace(htmre, '');
			y = y.replace(htmre, '');
		}
		// chunk/tokenize
	var	xN = x.replace(re, '\0$1\0').replace(/\0$/,'').replace(/^\0/,'').split('\0'),
		yN = y.replace(re, '\0$1\0').replace(/\0$/,'').replace(/^\0/,'').split('\0'),
		// numeric, hex or date detection
		xD = parseInt(x.match(hre), 10) || (xN.length !== 1 && x.match(dre) && Date.parse(x)),
		yD = parseInt(y.match(hre), 10) || xD && y.match(dre) && Date.parse(y) || null;

	// first try and sort Hex codes or Dates
	if (yD) {
		if ( xD < yD ) {
			return -1;
		}
		else if ( xD > yD )	{
			return 1;
		}
	}

	// natural sorting through split numeric strings and default strings
	for(var cLoc=0, numS=Math.max(xN.length, yN.length); cLoc < numS; cLoc++) {
		// find floats not starting with '0', string or 0 if not defined (Clint Priest)
		var oFxNcL = !(xN[cLoc] || '').match(ore) && parseFloat(xN[cLoc], 10) || xN[cLoc] || 0;
		var oFyNcL = !(yN[cLoc] || '').match(ore) && parseFloat(yN[cLoc], 10) || yN[cLoc] || 0;
		// handle numeric vs string comparison - number < string - (Kyle Adams)
		if (isNaN(oFxNcL) !== isNaN(oFyNcL)) {
			return (isNaN(oFxNcL)) ? 1 : -1;
		}
		// rely on string comparison if different types - i.e. '02' < 2 != '02' < '2'
		else if (typeof oFxNcL !== typeof oFyNcL) {
			oFxNcL += '';
			oFyNcL += '';
		}
		if (oFxNcL < oFyNcL) {
			return -1;
		}
		if (oFxNcL > oFyNcL) {
			return 1;
		}
	}
	return 0;
}

jQuery.extend( jQuery.fn.dataTableExt.oSort, {
	"natural-asc": function ( a, b ) {
		return naturalSort(a,b,true);
	},

	"natural-desc": function ( a, b ) {
		return naturalSort(a,b,true) * -1;
	},

	"natural-nohtml-asc": function( a, b ) {
		return naturalSort(a,b,false);
	},

	"natural-nohtml-desc": function( a, b ) {
		return naturalSort(a,b,false) * -1;
	},

	"natural-ci-asc": function( a, b ) {
		a = a.toString().toLowerCase();
		b = b.toString().toLowerCase();

		return naturalSort(a,b,true);
	},

	"natural-ci-desc": function( a, b ) {
		a = a.toString().toLowerCase();
		b = b.toString().toLowerCase();

		return naturalSort(a,b,true) * -1;
	}
} );

}());
