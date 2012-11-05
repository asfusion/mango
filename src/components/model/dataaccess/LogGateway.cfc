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
<cffunction name="getCount" output="false" hint="Gets total by serch criteria" access="public" returntype="numeric">
	<cfargument name="blogId" required="true" type="any">
	<cfargument name="level" required="false" default="" type="any">
	<cfargument name="category" required="false" default="" type="any">
	<cfargument name="owner" required="false" default="" type="any">
	
	<cfset var q_count = "" />
	
	<cfquery name="q_count" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT count(level) as total
		FROM	#variables.prefix#log
		
		where blog_id = <cfqueryparam value="#arguments.blogId#" cfsqltype="CF_SQL_VARCHAR">
		<cfif len(arguments.level)>
			AND level = <cfqueryparam value="#arguments.level#"  cfsqltype="cf_sql_varchar" />
		</cfif>
		<cfif len(arguments.category)>
			AND category = <cfqueryparam value="#arguments.category#"  cfsqltype="cf_sql_varchar" />
		</cfif>
		<cfif len(arguments.owner)>
			AND owner = <cfqueryparam value="#arguments.owner#"  cfsqltype="cf_sql_varchar" />
		</cfif>
	</cfquery>

	<cfreturn q_count.total />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="search" output="false" hint="Gets by serch criteria" access="public" returntype="query">
	<cfargument name="blogId" required="true" type="any">
	<cfargument name="level" required="false" default="" type="any">
	<cfargument name="category" required="false" default="" type="any">
	<cfargument name="owner" required="false" default="" type="any">
	
	<cfset var q_search = "" />
	
	<cfquery name="q_search" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT level, category, message, logged_on, blog_id, owner
		FROM	#variables.prefix#log
		
		where blog_id = <cfqueryparam value="#arguments.blogId#" cfsqltype="CF_SQL_VARCHAR">
		<cfif len(arguments.level)>
			AND level = <cfqueryparam value="#arguments.level#"  cfsqltype="cf_sql_varchar" />
		</cfif>
		<cfif len(arguments.category)>
			AND category = <cfqueryparam value="#arguments.category#"  cfsqltype="cf_sql_varchar" />
		</cfif>
		<cfif len(arguments.owner)>
			AND owner = <cfqueryparam value="#arguments.owner#"  cfsqltype="cf_sql_varchar" />
		</cfif>
		ORDER BY logged_on DESC
	</cfquery>

	<cfreturn q_search />
</cffunction>


</cfcomponent>