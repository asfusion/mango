<cfcomponent name="category" hint="Gateway for category">

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
	<cfargument name="blogid" type="string" required="false" default="default" />
	
	<cfset var q_category = "" />
	
	<cfquery name="q_category" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	category.id, category.name, category.title, category.description,
				category.created_on, category.parent_category_id,category.blog_id
		FROM	#variables.prefix#category as category
		WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		AND category.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
	</cfquery>

	<cfreturn q_category />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByName" output="false" hint="Gets a query with only one record corresponding to Name" access="public" returntype="query">
	<cfargument name="name" required="true" type="string" hint="Category Name (alias)"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	
	<cfset var q_categoryGetByName = "" />
	
	<cfquery name="q_categoryGetByName" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	category.id, category.name, category.title, category.description,
				category.created_on, category.parent_category_id,category.blog_id
		FROM	#variables.prefix#category as category
		WHERE name = <cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar"/>
		AND category.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
	</cfquery>

	<cfreturn q_categoryGetByName />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getAll" output="false" hint="Gets all the records" access="public" returntype="query">
	<cfargument name="blogid" type="string" required="false" default="default" hint="Blog for which to get all categories" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_categoryGetAll = "" />
	<cfset var cacheMin = variables.cacheMinutes />
	
	<cfif arguments.adminMode>
		<cfset cacheMin = 0 />
	</cfif>
	
	<cfquery name="q_categoryGetAll" datasource="#variables.dsn#"  username="#variables.username#" password="#variables.password#" 
			cachedwithin="#CreateTimeSpan(0, 0, cacheMin, 0)#">
		SELECT	category.id, category.name, category.title, category.description,
				category.created_on, category.parent_category_id,category.blog_id
		FROM	#variables.prefix#category as category
		WHERE category.blog_id = '#arguments.blogid#'
		ORDER BY name		
	</cfquery>

	<cfreturn q_categoryGetAll />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPostCount" output="false" hint="Gets all the records" access="public" returntype="query">
	<cfargument name="blogid" type="string" required="false" default="default" hint="Blog for which to get all categories" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_categoryGetPostCount = "" />
	<cfif NOT adminMode>
		<cfquery name="q_categoryGetPostCount" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT     COUNT(post_category.post_id) AS post_count, category.id AS category_id
		FROM         #variables.prefix#post_category as post_category RIGHT OUTER JOIN
                      #variables.prefix#category as category ON post_category.category_id = category.id
		WHERE     (post_category.post_id IN
                          (SELECT     post.id
                            FROM       #variables.prefix#entry as entry INNER JOIN
                                              #variables.prefix#post as post ON entry.id = post.id
                            WHERE      (post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />) 
										AND (entry.status = 'published')))
			AND category.blog_id = '#arguments.blogid#'
		GROUP BY category.id
	</cfquery>
	
	<cfelse>
		<cfquery name="q_categoryGetPostCount" datasource="#variables.dsn#"  username="#variables.username#" password="#variables.password#" cachedwithin="#CreateTimeSpan(0, 0, variables.cacheMinutes, 0)#">
		SELECT     COUNT(post_category.post_id) AS post_count, category.id AS category_id
		FROM       #variables.prefix#post_category as post_category RIGHT OUTER JOIN
                      #variables.prefix#category as category  ON post_category.category_id = category.id
		WHERE category.blog_id = '#arguments.blogid#'
		GROUP BY category.id		
	</cfquery>

	</cfif>

	<cfreturn q_categoryGetPostCount />
</cffunction>

 <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
 <cffunction name="refresh" output="false" hint="Refreshes cached data" access="public" returntype="void">
	<cfargument name="blogid" type="string" required="false" default="default" hint="Blog for which to refresh data" />
	
	<cfset var oldCacheTime = variables.cacheMinutes />
	<cfset variables.cacheMinutes = 0 />
	<cfset getPostCount(arguments.blogid,true) />
	<cfset getPostCount(arguments.blogid,false) />
	<cfset getAll(arguments.blogid) />

	<cfset variables.cacheMinutes = oldCacheTime />
  </cffunction>

</cfcomponent>