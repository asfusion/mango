<cfcomponent name="blog" hint="Gateway for blog">

 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="datasource" required="true" type="struct">
		
		<cfset variables.datasource = arguments.datasource />
		<cfset variables.dsn = arguments.datasource.name />
		<cfset variables.prefix = arguments.datasource.tablePrefix />
		<cfset variables.username = arguments.datasource.username />
		<cfset variables.password = arguments.datasource.password />
		<cfreturn this />
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByID" output="false" hint="Gets a query with only one record corresponding tor ID" access="public" returntype="query">
	<cfargument name="id" required="true" type="string" hint="Primary key"/>

	<cfset var q_blog = "" />
	
	<cfquery name="q_blog" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	id, title, description, tagline, skin, url, charset, basePath, plugins, systemplugins, url as urlString
		FROM	#variables.prefix#blog as blog
		WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR"/>
	</cfquery>

	<cfreturn q_blog />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getAll" output="false" hint="Gets all the records" access="public" returntype="query">

	<cfset var q_blog = "" />
	
	<cfquery name="q_blog" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	id, title, description, tagline, skin, url, charset, basePath, plugins, systemplugins, url as urlString
		FROM	#variables.prefix#blog		
	</cfquery>

	<cfreturn q_blog />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByAuthor" output="false" hint="Gets all the records" access="public" returntype="query">
	<cfargument name="author_id" required="true" type="string" hint="Author key"/>
	
	<cfset var q_blog = "" />
	
	<cfquery name="q_blog" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	id, title, description, tagline, skin, url, charset, basePath, plugins, systemplugins, url as urlString
		FROM	#variables.prefix#author_blog as author_blog INNER JOIN
                     #variables.prefix#blog as blog ON author_blog.blog_id = blog.id
		WHERE author_blog.author_id = <cfqueryparam value="#arguments.author_id#" cfsqltype="CF_SQL_VARCHAR"/>
	</cfquery>

	<cfreturn q_blog />
</cffunction>

</cfcomponent>