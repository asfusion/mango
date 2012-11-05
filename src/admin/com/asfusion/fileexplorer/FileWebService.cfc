<cfcomponent name="fileBrowser" access="public" description="Facade for directory and file management.">

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getFiles" output="false" description="Returns the list of files in given path - starting from root path" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
		
		<cfset var result = CreateObject("component", "MainFileExplorer").getInstance().getFileManager().getFiles(arguments.path) />
		<cfset var filesQuery = result["files"] />
		<!--- make a simpler structure form the query --->
		<cfset var files = arraynew(1) />
		
		<cfoutput query="filesQuery">
			<cfset files[currentrow] = structnew() />
			<cfset files[currentrow]["Path"] = filesQuery.Path[currentrow] />
			<cfset files[currentrow]["Size"] = size />
			<cfset files[currentrow]["Name"] = Name />
			<cfset files[currentrow]["DateLastModified"] = DateLastModified />
		</cfoutput>
		
		<cfset result["files"] = files />
		
		<cfset result["path"] = arguments.path/>
		<cfset result["status"] =  javacast("boolean",result["status"] )/>
		<!--- we don't want to show  a message --->
		<cfif result["status"]>
			<cfset result["message"] = ""/>
		</cfif>
		
		<cfset result["status"] =  javacast("boolean",result["status"] )/>
		<cfreturn result/>
		
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getDirectories" output="false" description="Returns the list of directories in given path - starting from root path" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>

		<cfset var result = CreateObject("component", "MainFileExplorer").getInstance().getFileManager().getDirectories(arguments.path) />
		<cfset var dirsQuery = result["directories"] />
		<!-- make a simpler structure form the query -->
		<cfset var dirs = arraynew(1) />
		
		<cfoutput query="dirsQuery">
			<cfset dirs[currentrow] = structnew() />
			<cfset dirs[currentrow]["Path"] = dirsQuery.Path[currentrow] />
			<cfset dirs[currentrow]["hasDirs"] = hasDirs />
			<cfset dirs[currentrow]["Name"] = Name />
		</cfoutput>
		
		<cfset result["directories"] = dirs />

		<cfset result["path"] = arguments.path/>
		<cfset result["status"] =  javacast("boolean",result["status"] )/>
		<!--- we don't want to show  a message --->
		<cfif result["status"]>
			<cfset result["message"] = ""/>
		</cfif>
		
		<cfset result["status"] =  javacast("boolean",result["status"] )/>
		<cfreturn result/>

</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="createFolder" output="false" description="Creates a folder under the given path" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>	
	
	<cfset var result = createObject("component", "MainFileExplorer").getInstance().getFileManager().createFolder(arguments.path, arguments.name) />
	
	<cfset result["status"] =  javacast("boolean",result["status"] )/>
	<cfreturn result />
	
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="removeFolder" output="false" description="Delete given folder" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	
	<cfset var result = createObject("component", "MainFileExplorer").getInstance().getFileManager().removeFolder(arguments.path) />
	
	<cfset result["status"] =  javacast("boolean",result["status"] )/>
	<cfreturn result/>
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="renameFolder" output="false" description="Renames a folder"
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>	
	<cfargument name="newname" required="false" type="string" default=""/>	
		
	<cfset var result = createObject("component", "MainFileExplorer").getInstance().getFileManager().renameFolder(arguments.path, arguments.name, arguments.newname) />
	
	<cfset result["status"] =  javacast("boolean",result["status"] )/>
	<cfreturn result/>
	
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="removeFile" output="false" description="Deletes a file" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>	
		
	<cfset var result = createObject("component", "MainFileExplorer").getInstance().getFileManager().removeFile(arguments.path, arguments.name) />
	
	<cfset result["status"] =  javacast("boolean",result["status"] )/>
	<cfreturn result/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="renameFile" output="false" description="Renames a file" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>	
	<cfargument name="newname" required="false" type="string" default=""/>
	
	<cfset var result = createObject("component", "MainFileExplorer").getInstance().getFileManager().renameFile(arguments.path, arguments.name, arguments.newname) />
	
	<cfset result["status"] =  javacast("boolean",result["status"] )/>
	<cfreturn result/>

</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="copyFiles" output="false" description="Copies files from one directory to another" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="fileNames" required="false" type="array" default=""/>	
	<cfargument name="newpath" required="false" type="string" default=""/>	
	
	<!--- check for permissions in this path --->
	<cfset var main = createObject("component", "MainFileExplorer").getInstance() />
	
	<!--- move one by one --->
	<cfset var result = structnew() />
	<cfset var fileMoveResult = '' />
	<cfset var i = 0 />
	<cfset var fileManager = main.getFileManager() />

	<cfset result['status'] = true />
	<cfset result['message'] = '' />
	
	<cfloop from="1" to="#arraylen(arguments.fileNames)#" index="i">
		<cfset fileMoveResult = fileManager.copyFile(arguments.path, arguments.fileNames[i],arguments.newpath) />
		<cfset result['status'] = result['status'] AND fileMoveResult['status'] />
		<cfif NOT fileMoveResult['status']>
			<cfset result['message'] = result['message'] & fileMoveResult['message']  & '<br>'/>
		</cfif>
	</cfloop>
	
	<cfif result['status']>
		<cfset result['message'] = "Files successfully moved" />
	</cfif>
	
	<cfset result["status"] =  javacast("boolean",result["status"] )/>
	<cfreturn result />
	
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="uploadFile" output="false" description="Uploads a file" 
					access="remote" returntype="struct">
	<cfargument name="filefield" required="true" />
	<cfargument name="path" required="false" type="string" default=""/>	
	<cfargument name="name" type="string" required="true" />
	
	<cfset var result = createObject("component", "MainFileExplorer").getInstance().getFileManager().uploadFile(arguments.filefield, arguments.path, arguments.name) />
	
	<cfset result["status"] =  javacast("boolean",result["status"] )/>
	<cfreturn result/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getAllowedExtensions" output="false" description="Returns the list of extensions allowed" 
					access="remote" returntype="string">		
		<cfreturn createObject("component", "MainFileExplorer").getInstance().getFileManager().getAllowedExtensions() />	
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getSessionToken" output="false" description="Returns the list of extensions allowed" 
					access="remote" returntype="string">
	<cftry>		
		<cfreturn session.URLToken />
	<cfcatch type="any">
		<cfreturn "" />
	</cfcatch>
	</cftry>	
</cffunction>

</cfcomponent>