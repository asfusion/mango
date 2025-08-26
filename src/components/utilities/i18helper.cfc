component {
    variables.keys = this.k = {};

    // -------------------------------------------
    public function loadLocale( file ){//use json simple key=value
        var filecontent = fileRead( file );
        structAppend( variables.keys, deserializeJSON( filecontent ), true );
    }

    // -------------------------------------------
    public function loadStrings( values, overwrite = false ){
        structAppend( variables.keys, values, overwrite );
    }

    // -------------------------------------------
    public function getValue( required key, values = '' ){
        var value = arguments.key;
        if ( structKeyExists( variables.keys, arguments.key )){
            value = variables.keys[ arguments.key ];
        }

        if ( isArray( arguments.values ) ){
            for ( var i = 1; i LTE arraylen( arguments.values ); i++ ){
                value = replace( value, "{#i#}", arguments.values[ i ],"ALL" );
            }
        }
       else if ( isStruct( arguments.values )){
            for ( var i in arguments.values ){
                value = replace( value, "{#i#}", arguments.values[ i ],"ALL" );
            }
       }
        else if ( len( arguments.values )){
            value = replace( value, "{1}", arguments.values, "ALL");
        }
        return value;
    }
}