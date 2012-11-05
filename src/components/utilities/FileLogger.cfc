<cfcomponent>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="settings" type="struct" default="#structnew()#" required="false" />
		<cfargument name="blogid" type="string" required="false" default="default" />
		
		<cfset variables.directory = arguments.settings.directory />
		<cfset variables.blogId = arguments.blogId />
		
		<cfif NOT len(variables.directory)>
			<cfset variables.directory = getDirectoryFromPath(GetCurrentTemplatePath()) &  "logs"/>
		</cfif>
		
		<cfreturn this/>
	</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="publish" output="false" hint="Logs the specified message" access="public" returntype="void">
		<cfargument name="logRecord" required="true" />
		
		<cffile action="APPEND" file="#variables.directory#/#variables.blogId#_#arguments.logRecord.level#_log.html" 
				output="#arguments.logRecord.message#" addnewline="Yes" fixnewline="No">
		
	</cffunction>

</cfcomponent>
