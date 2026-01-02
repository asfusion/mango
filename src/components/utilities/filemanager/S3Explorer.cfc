<cfcomponent name="fileManager" access="public" description="Component that manages all directory and file operations. "
		extends="filemanager">

<cfset variables.basePath = ""/>
<cfset variables.messages = structnew()/>
<cfset variables.messages["FolderNotExist"] = "Folder does not exist"/>
<cfset variables.messages["FileNotExist"] = "File does not exist"/>

 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="settings" required="true" type="struct">
	
		<cfset variables.basePath = arguments.settings.rootDirectory />

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
		<cfset variables.fileSeparator = '/' />

		<cfset variables.resizer = createObject("component", "Thumbnailer") />

		<cfreturn this />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getResolvedPath" output="false" description="Returns the aboslute path"
			access="private" returntype="string">
		<cfargument name="path" required="true" type="string"  />
		<cfreturn variables.basePath & arguments.path />
	</cffunction>

</cfcomponent>