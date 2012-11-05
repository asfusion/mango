<cfcomponent name="author" hint="Gateway for author">

 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="datasource" required="true" type="struct">
	<cfargument name="cacheMinutes" required="false" default="360" type="numeric" hint="Number of minutes to cache">
		
		<cfset variables.datasource = arguments.datasource />
		<cfset variables.dsn = arguments.datasource.name />
		<cfset variables.cacheMinutes = arguments.cacheMinutes />
		<cfset variables.prefix = arguments.datasource.tablePrefix />
		<cfset variables.username = arguments.datasource.username />
		<cfset variables.password = arguments.datasource.password />
		
		<cfreturn this />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByID" output="false" hint="Gets a query with only one record corresponding tor ID" access="public" returntype="query">
	<cfargument name="id" required="true" type="string" hint="Primary key"/>

	<cfset var q_getByID = "" />
	
	<cfquery name="q_getByID" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	author.id, author.username, author.password, author.name, author.email,
				author.description, author.shortdescription, author.picture, author.alias,
				author.active, author_blog.role, author_blog.blog_id
		FROM	#variables.prefix#author as author
				INNER JOIN #variables.prefix#author_blog as author_blog
				ON author.id = author_blog.author_id
		WHERE author.id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
	</cfquery>

	<cfreturn q_getByID />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getAll" output="false" hint="Gets all the records" access="public" returntype="query">
	<cfargument name="activeOnly" required="false" default="true" type="boolean" hint="Returned only active users"/>
	
	<cfset var q_getAll = "" />
	
	<cfquery name="q_getAll" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	author.id, author.username, author.password, author.name, author.email,
				author.description, author.shortdescription, author.picture, author.alias,
				author.active, author_blog.role, author_blog.blog_id
		FROM	#variables.prefix#author as author
				INNER JOIN #variables.prefix#author_blog as author_blog
				ON author.id = author_blog.author_id
		<cfif arguments.activeOnly>
		WHERE author.active = 1
		</cfif>
		ORDER BY name
	</cfquery>

	<cfreturn q_getAll />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByBlog" output="false" hint="Gets all the authors authorized for a given blog" access="public" returntype="query">
	<cfargument name="blogId" required="true" type="string" hint="Blog primary key"/>
	
	<cfset var q_getByBlogId = "" />
	
	<cfquery name="q_getByBlogId" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	author.id, author.username, author.password, author.name, author.email,
				author.description, author.shortdescription, author.picture, author.alias,
				author.active, author_blog.role, author_blog.blog_id
		FROM	#variables.prefix#author as author
				INNER JOIN #variables.prefix#author_blog as author_blog
				ON author.id = author_blog.author_id
		WHERE author_blog.blog_id = <cfqueryparam value="#arguments.blogId#" cfsqltype="CF_SQL_VARCHAR" />
		ORDER BY name
	</cfquery>

	<cfreturn q_getByBlogId />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByKeyword" output="false" hint="Gets all the authors authorized for a given blog matching the keyword" 
			access="public" returntype="query">
	<cfargument name="keyword" required="true" type="string" default="" hint="Keyword"/>
	<cfargument name="blogId" required="false" type="string" hint="Blog primary key"/>
	
	<cfset var q_getByBlogId = "" />
	
	<cfquery name="q_getByBlogId" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	author.id, author.username, author.password, author.name, author.email,
				author.description, author.shortdescription, author.picture, author.alias,
				author.active, author_blog.role, author_blog.blog_id
		FROM	#variables.prefix#author as author
				INNER JOIN #variables.prefix#author_blog as author_blog
				ON author.id = author_blog.author_id
		WHERE (author.name LIKE <cfqueryparam value="%#arguments.keyword#%" cfsqltype="CF_SQL_VARCHAR" />
			OR author.email LIKE <cfqueryparam value="%#arguments.keyword#%" cfsqltype="CF_SQL_VARCHAR" />
			OR author.username LIKE <cfqueryparam value="%#arguments.keyword#%" cfsqltype="CF_SQL_VARCHAR" />
		)
		<cfif len(arguments.blogId)>
			AND author_blog.blog_id = <cfqueryparam value="#arguments.blogId#" cfsqltype="CF_SQL_VARCHAR" />
		</cfif>
		ORDER BY name
	</cfquery>

	<cfreturn q_getByBlogId />
</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByUsername" output="false" access="public" returntype="query">
		<cfargument name="username" required="true" type="string" hint="Name"/>

	<cfset var q_getByUsername = "" />
	
	<cfquery name="q_getByUsername" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	author.id, author.username, author.password, author.name, author.email,
				author.description, author.shortdescription, author.picture, author.alias,
				author.active, author_blog.role, author_blog.blog_id
		FROM	#variables.prefix#author as author
				INNER JOIN #variables.prefix#author_blog as author_blog
				ON author.id = author_blog.author_id
		WHERE username = <cfqueryparam value="#arguments.username#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>
	</cfquery>

	<cfreturn q_getByUsername />
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByAlias" output="false" access="public" returntype="query">
		<cfargument name="alias" required="true" type="string" hint="Alias"/>

	<cfset var q_author = "" />
	
	<cfquery name="q_author" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	author.id, author.username, author.password, author.name, author.email,
				author.description, author.shortdescription, author.picture, author.alias,
				author.active, author_blog.role, author_blog.blog_id
		FROM	#variables.prefix#author as author
				INNER JOIN #variables.prefix#author_blog as author_blog
				ON author.id = author_blog.author_id
		WHERE alias = <cfqueryparam value="#arguments.alias#" cfsqltype="CF_SQL_VARCHAR" maxlength="100"/>
	</cfquery>

	<cfreturn q_author />
</cffunction>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByemail" output="false" access="public" returntype="query">
		<cfargument name="email" required="true" type="string" hint="Email"/>

	<cfset var q_author = "" />
	
	<cfquery name="q_author" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	author.id, author.username, author.password, author.name, author.email,
				author.description, author.shortdescription, author.picture, author.alias,
				author.active, author_blog.role, author_blog.blog_id
		FROM	#variables.prefix#author as author
				INNER JOIN #variables.prefix#author_blog as author_blog
				ON author.id = author_blog.author_id
		WHERE email = <cfqueryparam value="#arguments.email#" cfsqltype="CF_SQL_VARCHAR" maxlength="255"/>
	ORDER BY name
	</cfquery>

	<cfreturn q_author />
</cffunction>

	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getIdByEmail" output="false" access="public" returntype="string">
		<cfargument name="email" required="true" type="string" hint="Email"/>

	<cfset var q_author = getByemail(arguments.email) />

	<cfif q_author.recordcount>
		<cfreturn q_author.id />
	<cfelse>
		<cfreturn "" />
	</cfif>
	
</cffunction>


</cfcomponent>