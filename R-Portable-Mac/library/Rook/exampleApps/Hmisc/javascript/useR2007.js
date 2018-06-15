function RePlot(){
	var p1 = document.spower.p1.value;
	var p2 = document.spower.p2.value;
	var mo = document.spower.mo.value;

	new  Ajax.Updater( 'plot', 'useR2007plot.rhtml',
		{
			'method': 'get', 
			'parameters': {'p1': p1, 'p2': p2, 'mo': mo},
		}
	);
}
function ReSimulate(){
	var p1 = document.spower.p1.value;
	var p2 = document.spower.p2.value;
	var mo = document.spower.mo.value;

	Element.show('spinner');
	new  Ajax.Updater( 'spowerResult', 'useR2007sim.rhtml',
		{
			'method': 'get', 
			'parameters': {'p1': p1, 'p2': p2, 'mo': mo},
			'onSuccess': function(r){Element.hide('spinner')}
		}
	);
}
