var to;
$().ready(function() {
	to = setTimeout("timedOut()", 300000);
});

function timedOut() {
	$.post( "datasets/sessionRefresh.cfm", null,
		function(data) {
			to = setTimeout("timedOut()", 300000);
		}
	);
}