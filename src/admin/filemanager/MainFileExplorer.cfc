<cfcomponent>
	<cfset variables.arrayUtil = createObject( 'utilities.ArrayUtil' ) />

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getInstance" output="false" description="Returns an object of this class" 
					access="public" returntype="any">
						
		<cfset var newinstance = "" />
		<cfset var currentBlogId = application.blogFacade.getMango().getBlog().getId() />
		
		<cfif NOT structkeyexists(application,"_fileExplorerInstances")>
			<cfset application._fileExplorerInstances = structnew() />
		</cfif>
		
		<cfif NOT structkeyexists(application._fileExplorerInstances, currentBlogId)> 
			<cfset newinstance = createObject("component", "MainFileExplorer").init() />
			<cfset application._fileExplorerInstances[currentBlogId] = newinstance />
		 </cfif> 

		<cfreturn application._fileExplorerInstances[currentBlogId] />
	</cffunction>	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" output="false" returntype="any">
		<!--- making a dependency on Mango here, but at least I can remove the 
		reference in application.cfc --->
		<cfset var blogManager = application.blogFacade.getMango() />
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
		<cfset getFileManager() /><!--- @todo remove --->
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

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
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

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
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

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="removeFile" output="false" description="Deletes a file">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>

		<cfreturn result = variables.filemanager.removeFile( path, name )/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="uploadFile" output="false" description="Uploads a file in the given folder" access="public" >
		<cfargument name="filefield" required="true" />
		<cfargument name="path" required="false" type="string" default=""/>
		<cfargument name="filename" type="string" required="true" />

		<cfset result["status"] = true />
		<cfset result["message"] = "File uploaded" />

		<cftry>
		<cfset variables.fileManager.uploadFile( filefield, path, filename) />
			<cfcatch type="any">
				<cfset result["status"] = false />
				<cfset result["message"] = cfcatch.message />
			</cfcatch>
		</cftry>

		<cfreturn result />
	</cffunction>

	<cfscript>
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
	</cfscript>
</cfcomponent>