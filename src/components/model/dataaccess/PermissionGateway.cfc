<cfcomponent output="false">

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="datasource" required="true" type="struct">
		
		<cfset variables.datasource = arguments.datasource />
		<cfset variables.dsn = arguments.datasource.name />
		<cfset variables.prefix = arguments.datasource.tablePrefix />
		<cfset variables.username = arguments.datasource.username />
		<cfset variables.password = arguments.datasource.password />
		<cfreturn this />
</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getById" output="false" hint="Gets role" access="public" returntype="query">
	<cfargument name="id" required="true" type="string">
	<cfset var q_getById = "" />
	
	<cfquery name="q_getById" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT permission.id, permission.name, permission.description, permission.is_custom
		FROM	#variables.prefix#permission as permission
		WHERE permission.id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#">
	</cfquery>

	<cfreturn q_getById />
</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getAll" output="false" hint="Gets all the permissions" access="public" returntype="query">
	
	<cfset var q_getAll = "" />
	
	<cfquery name="q_getAll" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	permission.id, permission.name, permission.description, permission.is_custom
		FROM	#variables.prefix#permission as permission
	</cfquery>

	<cfreturn q_getAll />
</cffunction>

</cfcomponent>