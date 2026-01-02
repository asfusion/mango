component {
    variables.bundles = {};
    variables.currentLocale = '';
    variables.fallbackLocale = '';
    variables.systemLocale = '';
    variables.availableLocales = {};

    // -------------------------------------------
    public function init( locale = '', resourcesDir = '' ){
        variables.currentLocale = arguments.locale;
        if ( listLen( locale, '_' ) GT 1 ){
            variables.fallbackLocale = listFirst( locale, '_' );
            variables.bundles[ variables.fallbackLocale ] = new utilities.i18helper();
        }
        if ( structKeyExists( variables.systemlocales, variables.currentLocale ) ){
            variables.systemLocale = variables.systemlocales[ variables.currentLocale ];
        }
        else if ( structKeyExists( variables.systemlocales, variables.fallbackLocale ) ){
            variables.systemLocale = variables.systemlocales[ variables.fallbackLocale ];
        }
        autoLoad( resourcesDir );
        return this;
    }

    // -------------------------------------------
    public function setRequest(){
        if ( len( variables.systemLocale )){
            setLocale( variables.systemLocale );
        }
    }

    // -------------------------------------------
    public function loadFromDir( directory ){
        autoLoad( directory );
    }

    // -------------------------------------------
    public function registerLocale( file, locale ){ //use json simple key=value with {placeholders}
        if ( NOT structKeyExists( variables.bundles, locale )) {
            variables.bundles[ locale ] = new utilities.i18helper();
        }
        variables.bundles[ locale ].loadLocale( file, locale );
        //set up language fallback
        if ( listLen( locale, '_' ) GT 1 ){
            var lang = listFirst( locale, "_" );
            if ( NOT structKeyExists( variables.bundles, lang )){
                variables.bundles[ lang ] = new utilities.i18helper();
                variables.bundles[ lang ].loadLocale( file, locale );
            }
        }
    }

// -------------------------------------------
    public function addValues( locale, values ){ //use json simple key=value with {placeholders}
        if ( structKeyExists( variables.bundles, locale )){
            variables.bundles[ locale ].loadStrings( values, false );
        }
        else if ( listLen( locale, '_' ) GT 1 AND structKeyExists( variables.bundles, listfirst( locale, '_' ) ) ){
            variables.bundles[ listfirst( locale, '_' ) ].loadStrings( values, false );
        }
        else {
            variables.bundles[ locale ] = new utilities.i18helper();
            variables.bundles[ locale ].loadStrings( values, false );
        }
    }

    // -------------------------------------------
    public function getLocale()
    {
        return variables.currentLocale;
    }

    // -------------------------------------------
    public function getValue( required key, values = '' )
    {
        var locale = variables.currentLocale;
        if ( NOT structKeyExists( variables.bundles , variables.currentLocale ) and structKeyExists( variables.bundles, variables.fallbackLocale )){
            locale = variables.fallbackLocale;
        }
        if ( structKeyExists( variables.bundles, locale ) )
            return variables.bundles[ locale ].getValue( key, values );
        else
            return new utilities.i18helper().getValue( key, values );
    }

    // -------------------------------------------
    public function getLoadedBundles(){
        var result = [];
        for ( var code in variables.availableLocales ){
            var name = getLocaleDisplayName( code );
            arrayAppend( result, { locale = code, name = name } );
        }
        return result;
    }

    // -------------------------------------------
    private function autoLoad( dir )
    {
       if ( directoryExists( dir )) {
           var fileList = directoryList( dir, false, "name");
           for ( var file in fileList ) {
               if ( listLast(file, '.') EQ 'json' ) {
                   var filelocale = listFirst(file, '.');
                   if ( listFirst( filelocale, '_') EQ listFirst( variables.currentLocale, "_" )) {
                       registerLocale( dir & file, filelocale );
                   }
                   availableLocales[ filelocale ] = '';
               }
           }
       }
    }

// -------------------------------------------
    variables.systemlocales = {
        'en' = 'english',
        'es' = 'spanish'
    };
}
