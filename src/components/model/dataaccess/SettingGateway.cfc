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
<cffunction name="getById" output="false" access="public" returntype="query">
	<cfargument name="path" required="true" type="any">
	<cfargument name="name" type="String" required="true" hint="Key with which the specified value is to be associated." />
	<cfargument name="blog_id" type="String" required="false" default="" hint="Id of blog, can be just an empty string" />
	
	<cfset var q_getSettingById = "" />
	
	<cfquery name="q_getSettingById"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT path, name, value, blog_id
		FROM #variables.prefix#setting		
		WHERE path = <cfqueryparam value="#arguments.path#" cfsqltype="CF_SQL_VARCHAR" /> AND
			<cfif len(arguments.blog_id)>
				blog_id = <cfqueryparam value="#arguments.blog_id#" cfsqltype="CF_SQL_VARCHAR" />
			<cfelse>
				(blog_id = '' OR blog_id IS NULL)
			</cfif> AND
			name = <cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" />
	</cfquery>
	
	<cfreturn q_getSettingById />
	
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByPath" output="false" access="public" returntype="query">
	<cfargument name="path" required="true" type="any">
	<cfargument name="blog_id" type="String" required="false" default="" hint="Id of blog, can be just an empty string" />
	<cfargument name="includeChildren" required="false" default="true" type="boolean">
	
	<cfset var q_getSettingByPath = "" />
	<cfset var operator = '=' />
	
	<cfif arguments.includeChildren>
		<cfset arguments.path = arguments.path & "%">
		<cfset operator = 'LIKE' />
	</cfif>
	
	<cfquery name="q_getSettingByPath"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT path, name, value, blog_id
		FROM #variables.prefix#setting			
		WHERE path #operator# <cfqueryparam value="#arguments.path#" cfsqltype="CF_SQL_VARCHAR" /> AND
			<cfif len(arguments.blog_id)>
				blog_id = <cfqueryparam value="#arguments.blog_id#" cfsqltype="CF_SQL_VARCHAR" />
			<cfelse>
				(blog_id = '' OR blog_id IS NULL)
			</cfif>
		ORDER BY path, name
	</cfquery>
	
	<cfreturn q_getSettingByPath />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="pathExists" output="false" access="public" returntype="boolean">
	<cfargument name="path" required="true" type="any">
	<cfargument name="blog_id" type="String" required="false" default="" hint="Id of blog, can be just an empty string" />
	
	<cfset var q_getSettingByPath = "" />
	
	<cfquery name="q_getSettingByPath"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT count(path) as total
		FROM #variables.prefix#setting			
		WHERE path = <cfqueryparam value="#arguments.path#" cfsqltype="CF_SQL_VARCHAR" /> AND
			<cfif len(arguments.blog_id)>
				blog_id = <cfqueryparam value="#arguments.blog_id#" cfsqltype="CF_SQL_VARCHAR" />
			<cfelse>
				(blog_id = '' OR blog_id IS NULL)
			</cfif>
	</cfquery>
	
	<cfreturn q_getSettingByPath.total GT 0 />
</cffunction>

</cfcomponent>