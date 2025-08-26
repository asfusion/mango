component {
	
	// ----------------------------------------------------------------------------------------
	public array function queryToArray( required query q, required columns, maxItems = 0 ) output="false"
	{
		var result = [];
		var row = {};
		if ( NOT isarray( columns ))
			columns = listToArray( columns );
			
		var numCols = arrayLen( arguments.columns );
		if ( maxItems EQ 0 ){
			maxItems = arguments.q.recordCount;
		}
		
		for ( var rowIndex = 1; rowIndex <= maxItems; rowIndex++){
			row = {};
			
			for ( var columnIndex = 1; columnIndex LTE numCols; columnIndex++){
				var columnName = trim( columns[ columnIndex ] );
				row[ columnName ] = arguments.q[ columnName ][rowIndex ];
			}
			arrayAppend( result, row );
		}
		return result;
	}
	
}