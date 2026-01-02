<cfcomponent>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="false" />
		
		<cfset blogManager = arguments.mainManager />

		<cfset var blog = blogManager.getBlog() />
		<cfset var assetsInfo = blog.getSetting('assets') />
		
		<cfset variables.settings = assetsInfo />
	
		<cfset variables.settings.rootDirectory = assetsInfo.directory />
		<cfif findnocase("/",assetsInfo.path) NEQ 1 AND findnocase("http",assetsInfo.path) NEQ 1>
		 	<cfset variables.settings.rootUrl = blog.getBasePath() & assetsInfo.path />
		 <cfelse>
		 	<cfset variables.settings.rootUrl = assetsInfo.path />
	 	</cfif>
	 	<cfif NOT structkeyexists(assetsInfo, "extensions")>
			<cfset assetsInfo.extensions = "*" />
		</cfif>
	 	<cfset variables.settings.allowedExtensions = assetsInfo.extensions />
	 	<cfif NOT structkeyexists(assetsInfo, "fileManager")>
			<cfset assetsInfo.fileManager = "FileManager" />
		</cfif>

		<cfif find("/", assetsInfo.path) EQ 1>
			<!--- absolute path, prepend only domain --->
			<cfset variables.fileUrl = host & assetsInfo.path />
		<cfelseif find("http",assetsInfo.path) EQ 1>
			<cfset variables.fileUrl = assetsInfo.path />
		<cfelse>
			<cfset variables.fileUrl = blog.getUrl() & assetsInfo.path />
		</cfif>

	 	<cfset variables.settings.fileManager = assetsInfo.fileManager />
		<cfset getFileManager()>
		<cfreturn this>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getFileManager" access="public" output="false" returntype="any">
		<cfif NOT structkeyexists(variables,"filemanager")>
			<cfset variables.fileManager = createObject("component",variables.settings.fileManager).init(variables.settings)/>
		</cfif>
		<cfreturn variables.fileManager />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setFileManager" access="public" output="false" returntype="any">
		<cfargument name="filemanager">
		<cfset variables.fileManager = arguments.filemanager>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getDirectories" output="false" description="Returns the list of directories in given path - starting from root path"
			access="public">
		<cfargument name="path" required="false" type="string" default=""/>
		<cfargument name="addHasDirs" required="false" type="boolean" default="true"/>
		<cfargument name="format" required="false" type="string" default="ARRAY"/>

		<cfset var result = variables.filemanager.getDirectories( path, addHasDirs )/>
		<cfif result.status>
			<cfif arguments.format EQ "ARRAY" OR arguments.format EQ "JSON">
				<cfloop from="1" to="#arraylen( result.data )#" index="local.i">
					<cfset result.data[ i ] = { 'name' = result.data[ local.i ].name,
											'path' = path, 'fullpath' = path & '/' & result.data[ local.i ].name,
											'url' = variables.fileUrl & path & result.data[ local.i ].name } />
				</cfloop>
			</cfif>
		</cfif>

		<cfif arguments.format EQ "JSON">
			<cfset result = serializeJSON( result ) />
		</cfif>
		<cfreturn result />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getFiles" output="false" description="Returns the list of files in given path - starting from root path"
			access="public">
		<cfargument name="path" required="false" type="string" default=""/>
		<cfargument name="format" required="false" type="string" default="ARRAY"/>

		<cfset var result = variables.filemanager.getFiles( path )/>
		<cfif result.status>
			<cfset var dataArray = [] />
			<cfif arguments.format EQ "ARRAY" OR arguments.format EQ "JSON">
				<cfset var rootUrlContainsSlash = right( variables.settings.rootUrl, 1 ) eq '/'>
				<cfloop from="1" to="#arraylen( result.data )#" index="local.i">
					<cfif rootUrlContainsSlash and find( '/', path ) EQ 1>
						<cfset path = removeChars( path, 1, 1  )/>
					</cfif>
						<cfif find( '/', path ) EQ 1>
						<cfset path = removeChars( path, 1, 1  )/>
					</cfif>
						<cfif len( path ) and right( path, 1 ) neq '/'>
						<cfset path = path & '/' />
					</cfif>
						<cfset arrayAppend( dataArray, { 'name' = result.data[ local.i ].name,
						'path' = path,
						'url' = variables.settings.rootUrl & path &  result.data[ local.i ].name,
						'relativePath' = variables.settings.rootUrl & path &  result.data[ local.i ].name,
						'isImage' = variables.fileManager.isImage( result.data[ local.i ].name ),
						'extension' = variables.fileManager.getExtension( result.data[ local.i ].name ) })>
				</cfloop>
				<cfset result.data = dataArray />
			</cfif>
		</cfif>

		<cfif arguments.format EQ "JSON">
			<cfset result = serializeJSON( result ) />
		</cfif>
		<cfreturn result />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="removeFile" output="false" description="Deletes a file">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>

		<cfreturn result = variables.filemanager.removeFile( path, name )/>
	</cffunction>

	<cfscript>
		// -----------------------------------------------------------
		function uploadFile( filefield, path="", filename, accept = '' ) {
			var result = { "status" = true, "message" = "File uploaded" };
			try {
				var uploadedFile = variables.fileManager.uploadFile( filefield, path, filename, accept );
				result['data'] = {'url': getUrl( path & uploadedFile.serverfile )};
			}
			catch( any e ){
				result["status"] = false;
				result["message"] = cfcatch.message;
			}

			return result;
		}
		// -----------------------------------------------------------
		function createFolder( path, name ) {
			try {
				result = variables.fileManager.createFolder( path, name );
			}
			catch( any e ){
				result["status"] = false;
				result["message"] = cfcatch.message;
			}

			return result;
		}
		// -----------------------------------------------------------
		function removeFolder( path ) {
			try {
				result = variables.fileManager.removeFolder( path );
			}
			catch( any e ){
				result["status"] = false;
				result["message"] = cfcatch.message;
			}

			return result;
		}
		// -----------------------------------------------------------
		function renameFolder( path, name, newName ) {
			try {
				result = variables.fileManager.renameFolder( path, name, newName );
			}
			catch( any e ){
				result["status"] = false;
				result["message"] = cfcatch.message;
			}

			return result;
		}
		// -----------------------------------------------------------
		public function importFile( path, name, file ) {
			try {
				result = variables.fileManager.importFile( path, name, file );
				result['data'] = {'url': getUrl( result.data.path )};
			}
			catch( any e ){
				result["status"] = false;
				result["message"] = cfcatch.message;
			}

			return result;
		}

		// -----------------------------------------------------------
		public function getUrl( filename, relative = false ) {
			var rootUrlContainsSlash = right( variables.settings.rootUrl, 1 ) eq '/';
			var base = variables.settings.rootUrl;

			if ( rootUrlContainsSlash && find( "/", filename ) == 1 ) {
				filename = removeChars( filename, 1, 1 );
			}
			return base & filename;
		}
	</cfscript>
</cfcomponent>