<!--- This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

In order to comply with the attribution clause of the Creative Commons License, 
please do not remove this and the "Developed by Blue Instant" notice

Use this application at your own risk

<rdf:RDF xmlns="http://web.resource.org/cc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
		<Work rdf:about="">
			<license rdf:resource="http://creativecommons.org/licenses/by-sa/2.5/" />
	<dc:title>File Explorer</dc:title>
	<dc:date>2006</dc:date>
	<dc:creator><Agent><dc:title>Laura Arguello and Nahuel Foronda</dc:title></Agent></dc:creator>
	<dc:rights><Agent><dc:title>Laura Arguello and Nahuel Foronda</dc:title></Agent></dc:rights>
	<dc:source rdf:resource="http://www.asfusion.com/projects/fileexplorer" />
		</Work>
		<License rdf:about="http://creativecommons.org/licenses/by-sa/2.5/"><permits rdf:resource="http://web.resource.org/cc/Reproduction"/><permits rdf:resource="http://web.resource.org/cc/Distribution"/><requires rdf:resource="http://web.resource.org/cc/Notice"/><requires rdf:resource="http://web.resource.org/cc/Attribution"/><permits rdf:resource="http://web.resource.org/cc/DerivativeWorks"/><requires rdf:resource="http://web.resource.org/cc/ShareAlike"/></License></rdf:RDF>
 --->

<cfcomponent name="fileManager" access="public" description="Component that manages all directory and file operations. ">

<cfset variables.basePath = ""/>
<cfset variables.messages = structnew()/>
<cfset variables.messages["FolderNotExist"] = "Folder does not exist"/>
<cfset variables.messages["FileNotExist"] = "File does not exist"/>

 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="settings" required="true" type="struct">
	
		<cfset var rootDir = createObject("java","java.io.File").init(arguments.settings.rootDirectory)/>
		<cfset variables.basePath = rootDir.getCanonicalPath()/>
		<cfset this.path = variables.basePath/>
		
		<!--- check that the base path exists --->
		<cfif NOT directoryexists(variables.basePath)>
			<cfthrow message="Base path does not exist"/>
		</cfif>

		<cfset variables.extensions = arguments.settings.allowedExtensions />
		
		<cfif NOT structkeyexists(arguments.settings,'rootUrl')>
			<cfset arguments.settings.rootUrl = '' />
		</cfif>
		
		<cfset variables.rootUrl = arguments.settings.rootUrl />
		
		<!--- get the system file separator --->
		<cfset variables.fileSeparator = createObject("java","java.io.File").separator />
		
		<cfreturn this />
</cffunction>

	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getFiles" output="false" description="Returns the list of files in given path - starting from root path" 
					access="public" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	
		<cfset var files = ""/>
		<cfset var basedir = ""/>
		<cfset var allElements = ""/>
		<cfset var result = structnew()/>
		<cfset result["status"] = true />
		
		<cftry>
		<cfset basedir = getResolvedPathWithValidation(arguments.path) />
				<cfdirectory action="LIST" directory="#basedir#" name="allElements">
		
				<cfquery name="files" dbtype="query">
					SELECT *, '#arguments.path#' as Path
					FROM allElements
					WHERE type = 'File'
				</cfquery>
		
				<cfset result["files"] = files />
				<cfset result["message"] = files.recordcount & " files found" />
				
			<cfcatch type="Any">
					<cfset result["files"] = queryNew("Name") />
					<cfset result["status"] = false />
					<cfset result["message"] = cfcatch.message  />
				</cfcatch>
			</cftry>
		
		<cfreturn result />
		
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getDirectories" output="false" description="Returns the list of directories in given path - starting from root path" 
					access="public" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="addHasDirs" required="false" type="boolean" default="true"/>
	
		<cfset var dirs = ""/>
		<cfset var allElements = ""/>
		<cfset var subdirs = ""/>
		<cfset var basedir = ""/>
		<cfset var result = structnew()/>
		<cfset result["status"] = true />
		
		<cftry>
		<cfset basedir = getResolvedPathWithValidation(arguments.path) />

				<cfdirectory action="LIST" directory="#basedir#" name="allElements">
		
				<cfquery name="dirs" dbtype="query">
					SELECT *, '#arguments.path#/' + Name as Path <cfif arguments.addHasDirs>, 0 as hasDirs</cfif>
					FROM allElements
					WHERE type = 'Dir'
					AND Name != '__thumbnails'
				</cfquery>
		
				<cfif arguments.addHasDirs>
					<!--- recurse once to add whether it has sub dirs --->
					<cfoutput query="dirs">
						<cfset subdirs = getDirectories(dirs.Path,false).directories />
						<cfif subdirs.recordcount>
							<cfset querysetcell(dirs,"hasDirs",1,currentrow)/>
						</cfif>
					</cfoutput>
				</cfif>
				
				<cfset result["message"] = dirs.recordcount & " sub-directories found" />
				<cfset result["directories"] = dirs/>
								
			<cfcatch type="Any">
					<cfset result["directories"] = queryNew("Name") />
					<cfset result["status"] = false />
					<cfset result["message"] = cfcatch.message />
				</cfcatch>
			</cftry>
		
		<cfreturn result />
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="createFolder" output="false" description="Creates a folder under the given path" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>	

		<cfset var basedir = ""/>
		<cfset var newdir = ""/>
		<cfset var result = structnew()/>
		<cfset result["status"] = false />
		
		<cftry>
			<cfset basedir = getResolvedPathWithValidation(arguments.path) />
			<cfset newdir = getResolvedPathWithValidation(arguments.path & variables.fileSeparator & arguments.name,false) />
			
			<cfif NOT DirectoryExists(newdir)>
				<cftry>
					<cfdirectory action="CREATE" directory="#newdir#">
					
					<cfset result["completepath"] = "#arguments.path##variables.fileSeparator##arguments.name#" />
					<cfset result["status"] = true />
					<cfset result["message"] = 'Folder "#arguments.name#" created' />
					
					<cfcatch type="Any">						
						<cfset result["message"] = cfcatch.message />
					</cfcatch>
				</cftry>
				
			<cfelse>
				<!--- this folder already exists --->	
				<cfset result["message"] = 'Folder "#arguments.name#" already exists' />
			</cfif>
			
		<cfcatch type="Any">
				<cfset result["message"] = cfcatch.message/>
			</cfcatch>
		</cftry>

		<cfreturn result/>
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="removeFolder" output="false" description="Deletes a folder" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
		
		<cfset var basedir = ""/>
		<cfset var result = structnew()/>
		<cfset result["status"] = false />
		
		<cftry>
			<cfset basedir = getResolvedPathWithValidation(arguments.path) />
			
			<cfif basedir NEQ variables.basePath>
				<cfdirectory action="DELETE" directory="#variables.basePath##arguments.path#" recurse="Yes">
			
				<cfset result["status"] = true />
				<cfset result["message"] = 'Folder "#listlast(arguments.path,variables.fileSeparator)#" and its contents deleted' />
			<cfelse>
				<cfset result["message"] = "Cannot delete base directory" />
			</cfif>
			<cfcatch type="Any">
				<cfset result["message"] = cfcatch.message />
			</cfcatch>
		</cftry>
		<cfreturn result/>
		
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="renameFolder" output="false" description="Renames a folder" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>	
	<cfargument name="newname" required="false" type="string" default=""/>	

		<cfset var olddir = ""/>
		<cfset var basedir = ""/>
		<cfset var newdir = ""/>
		
		<cfset var result = structnew()/>
		<cfset result["status"] = false />
		<cfset result["oldpath"] = "#arguments.path##variables.fileSeparator##arguments.name#" />
		<cfset result["renamedpath"] = "#arguments.path##variables.fileSeparator##arguments.newname#" />
		
		<cftry>
			<cfset basedir = getResolvedPathWithValidation(arguments.path) />
			<cfset olddir = getResolvedPathWithValidation(arguments.path & variables.fileSeparator & arguments.name)/>
			<cfset newdir = getResolvedPathWithValidation(arguments.path & variables.fileSeparator & arguments.newname,false) />
			
			<cfif NOT DirectoryExists("#basedir##variables.fileSeparator##arguments.newname#")>
			
				<cfif olddir NEQ variables.basePath>
					<cfdirectory action="RENAME" directory="#olddir#" 
							newdirectory="#basedir##variables.fileSeparator##arguments.newname#">
												
						<cfset result["status"] = true />					
						<cfset result["message"] = 'Folder "#arguments.name#" renamed to "#arguments.newname#"' />			
						
				<cfelse>
					<cfset result["message"] = "Cannot rename base directory" />
				</cfif>
					
				<cfelse>
					<cfset result["message"] = 'A folder called "#arguments.newname#" already exists, cannot rename "#arguments.name#"' />
				</cfif>
		
			<cfcatch type="Any">
				<cfset result["message"] = cfcatch.message />
			</cfcatch>
		</cftry>
		
		<cfreturn result/>
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="removeFile" output="false" description="Deletes a file" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>	

		<cfset var result = structnew()/>
		<cfset var basedir = ""/>
		<cfset result["status"] = false />
		
		<cftry>
			<cfset basedir = getResolvedPathWithValidation(arguments.path) />
		
			<cfif fileExists("#basedir##variables.fileSeparator##arguments.name#")>
			
				<cffile action="delete" file="#basedir##variables.fileSeparator##arguments.name#">
											
				<cfset result["status"] = true />
				<cfset result["message"] = 'File "#arguments.name#" deleted' />		
			
			<cfelse>			
				<cfset result["message"] = variables.messages["FileNotExist"] />
			</cfif>	
		
			<cfcatch type="Any">
				<cfset result["message"] = cfcatch.message />
			</cfcatch>
		</cftry>
		<cfreturn result/>
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="renameFile" output="false" description="Renames a file" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>	
	<cfargument name="newname" required="false" type="string" default=""/>	

		<cfset var result = structnew()/>
		<cfset var basedir = ""/>
		<cfset result["status"] = false />
		<cftry>
			<cfset basedir = getResolvedPathWithValidation(arguments.path) />
		
			<cfif fileExists("#basedir##variables.fileSeparator##arguments.name#")>
				<!--- check for valid extension --->
				<cfif isAllowedExtension(arguments.newname)>
				
					<cfif NOT fileExists("#basedir##variables.fileSeparator##arguments.newname#")>
						
							<cffile action="rename" source="#basedir##variables.fileSeparator##arguments.name#" destination="#basedir##variables.fileSeparator##arguments.newname#">
		
						<cfset result["status"] = true />
						<cfset result["message"] = 'File "#arguments.name#" has been renamed to "#arguments.newname#"' />
		
						
					<cfelse>
						<cfset result["message"] = 'A file called "#arguments.newname#" already exists, cannot rename "#arguments.name#"' />
					</cfif>
				
				<cfelse>
						<cfset result["message"] = '"#getExtension(arguments.newname)#" is not a valid extension. File "#arguments.name#" cannot be renamed.' />
				</cfif>
			<cfelse>			
				<cfset result["message"] = variables.messages["FileNotExist"] />
			</cfif>	
		
			<cfcatch type="Any">
				<cfset result["message"] = cfcatch.message />
			</cfcatch>
		</cftry>
							
		<cfreturn result/>
		
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="uploadFile" output="false" description="Uploads a file in the given folder" 
					access="public" returntype="void">
	<cfargument name="filefield" required="true" />
	<cfargument name="path" required="false" type="string" default=""/>	
	<cfargument name="filename" type="string" required="true" />

	<cfset var basedir = getResolvedPathWithValidation(arguments.path, true) />
	
		<cfif len(arguments.filename) AND isAllowedExtension(arguments.filename)>
			<cffile action="UPLOAD" filefield="#arguments.filefield#" 
					destination="#basedir##variables.fileSeparator#" nameconflict="OVERWRITE">  
		
		<cfelse>			
			<cfthrow message='"#getExtension(arguments.filename)#" is not a valid extension.' />
		</cfif>
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="copyFile" output="false" description="Renames a file" 
					access="remote" returntype="struct">
	<cfargument name="path" required="false" type="string" default=""/>
	<cfargument name="name" required="false" type="string" default=""/>	
	<cfargument name="newpath" required="false" type="string" default=""/>	

		<cfset var result = structnew()/>
		<cfset var basedir = ""/>
		<cfset var newBaseDir = ""/>
		<cfset result["status"] = false />
		<cftry>
			<cfset basedir = getResolvedPathWithValidation(arguments.path) />
			<cfset newBaseDir = getResolvedPathWithValidation(arguments.newpath) />
		
			<cfif fileExists("#basedir##variables.fileSeparator##arguments.name#")>
				<!--- check for valid extension --->
				<cfif isAllowedExtension(arguments.name)>
				
					<cfif NOT fileExists("#newBaseDir##variables.fileSeparator##arguments.name#")>
						
							<cffile action="copy" source="#basedir##variables.fileSeparator##arguments.name#" destination="#newBaseDir##variables.fileSeparator##arguments.name#">
		
						<cfset result["status"] = true />
						<cfset result["message"] = 'File "#arguments.name#" has been copied to "#arguments.newpath#"' />
						
					<cfelse>
						<cfset result["message"] = 'A file called "#arguments.name#" already exists in directory #arguments.newpath#. File cannot be copied' />
					</cfif>
				
				<cfelse>
						<cfset result["message"] = '"#getExtension(arguments.name)#" is not a valid extension. File "#arguments.name#" cannot be copied.' />
				</cfif>
			<cfelse>			
				<cfset result["message"] = variables.messages["FileNotExist"] />
			</cfif>	
		
			<cfcatch type="Any">
				<cfset result["message"] = cfcatch.message />
			</cfcatch>
		</cftry>
							
		<cfreturn result/>
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getFile" output="false" description="Downloads a file" 
					access="public" returntype="any">
	<cfargument name="path" required="false" type="string" default=""/>	
	<cfargument name="filename" type="string" required="true" />
	<cfargument name="redirect" type="boolean" required="false" default="true" hint="Allows this function to do a cflocation to where the thumbnail is located whenever possible" />
	
	<cfset var basedir = getResolvedPathWithValidation(arguments.path, true) />
	<cfset var filecontent = ""/>
	<cfset var urlPath = replace("#variables.rootUrl##arguments.path##variables.fileSeparator##arguments.filename#", '//','/') />
	
	<cfif fileExists("#basedir##variables.fileSeparator##arguments.filename#")>
		<cfif len(variables.rootUrl) AND arguments.redirect>
			<cflocation url="#urlPath#" addtoken="false">
		<cfelse>
			<cffile action="readbinary" file="#basedir##variables.fileSeparator##arguments.filename#" variable="filecontent">
		</cfif>
	<cfelse>
			<cfthrow message='#variables.messages["FileNotExist"]#' />
	</cfif>
	
	<cfreturn filecontent />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getResolvedPathWithValidation" output="false" description="Returns the aboslute path if is it valid (within root)" 
					access="private" returntype="string">
	<cfargument name="path" required="true" type="string"  />
	<cfargument name="checkExists" required="false" default="true" type="boolean"  />

		<cfset var dir = getResolvedPath(arguments.path) />
		<cfif find(variables.basePath,dir) EQ 1 AND (NOT arguments.checkExists OR DirectoryExists(dir))>
			<cfreturn dir />
		<cfelse>
			<cfthrow message='#variables.messages["FolderNotExist"]#'>
		</cfif>
		
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getResolvedPath" output="false" description="Returns the aboslute path" 
					access="private" returntype="string">
	<cfargument name="path" required="true" type="string"  />

		<cfset var dir = createObject("java","java.io.File").init(variables.basePath & arguments.path) />
		<cfreturn dir.getCanonicalPath() />
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="isAllowedExtension" output="false" description="Checks whether this is not an allowed extension" 
					access="private" returntype="boolean">
	<cfargument name="filename" type="string" required="true" />
		
		<cfif variables.extensions EQ "*">
			<cfreturn true />
		</cfif>
		<cfreturn listfindnocase(variables.extensions,getExtension(arguments.filename)) />
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getExtension" output="false" description="Returns the extension of a file" 
					access="private" returntype="string">
	<cfargument name="name" type="string" required="true" />

		<cfif find(".",arguments.name)>
			<cfreturn listlast(arguments.name,".")/>
		<cfelse>
			<cfreturn ""/>
		</cfif>
		
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
<cffunction name="getAllowedExtensions" output="false" description="Returns the list of extensions" 
					access="public" returntype="string">

	<cfreturn variables.extensions />
		
</cffunction>

</cfcomponent>