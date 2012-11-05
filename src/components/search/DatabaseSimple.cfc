<cfcomponent name="DatabaseSimple">

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="settings" type="struct" default="#structnew()#" required="false" />
		<cfargument name="language" type="string" default="English" required="false" />
		<cfargument name="blogid" type="string" required="false" default="default" />
		
		<cfset variables.dsn = arguments.settings.dataSource.name />
		<cfset variables.username = arguments.settings.dataSource.username />
		<cfset variables.password = arguments.settings.dataSource.password />
		<cfset variables.prefix = arguments.settings.dataSource.tablePrefix />
		
		<cfreturn this/>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="searchEntries" access="public" output="false" returntype="Any">
		<cfargument name="criteria" type="String" required="false" />
		<cfargument name="category" type="String" required="false" />
		<cfargument name="categoryTree" type="String" required="false" />
		<cfargument name="blogid" type="string" required="false" default="default" />
				
			<cfset var q_getIdsByKeyword  = "">
	
			<cfquery name="q_getIdsByKeyword" datasource="#variables.dsn#" username="#variables.username#" 
					password="#variables.password#">
			SELECT     entry.id as 'key'
			FROM     #variables.prefix#entry as entry LEFT OUTER JOIN
	                       #variables.prefix#post as post ON entry.id = post.id				
			WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/> AND
			(entry.title LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/> 
				OR entry.content LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/> 
				OR entry.excerpt LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/> )
			ORDER BY post.posted_on DESC, entry.title
		</cfquery>
	
		<cfreturn q_getIdsByKeyword />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="searchPosts" access="public" output="false" returntype="Any">
		<cfargument name="criteria" type="String" required="false" />
		<cfargument name="category" type="String" required="false" />
		<cfargument name="categoryTree" type="String" required="false" />
		<cfargument name="blogid" type="string" required="false" default="default" />
				
			<cfset var q_getIdsByKeyword  = "">
	
			<cfquery name="q_getIdsByKeyword" datasource="#variables.dsn#" username="#variables.username#" 
					password="#variables.password#">
			SELECT  entry.id as 'key'
			FROM    #variables.prefix#entry as entry INNER JOIN
	                #variables.prefix#post as post ON entry.id = post.id	
					LEFT OUTER JOIN #variables.prefix#comment as comment
					ON comment.entry_id = entry.id
			WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/> AND
			(entry.title LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/> 
				OR entry.content LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/> 
				OR entry.excerpt LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/> 
				OR comment.content LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/>)
			ORDER BY post.posted_on DESC, entry.title
		</cfquery>
	
		<cfreturn q_getIdsByKeyword />
	</cffunction>
	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="searchPages" access="public" output="false" returntype="Query">
		<cfargument name="criteria" type="String" required="true" />
		<cfargument name="parentTree" type="String" required="false" />
		<cfargument name="blogid" type="string" required="false" default="default" />
		
			<cfset var q_getIdsByKeyword  = "">
	
			<cfquery name="q_getIdsByKeyword" datasource="#variables.dsn#" username="#variables.username#" 
					password="#variables.password#">
			SELECT     entry.id as 'key'
			FROM     #variables.prefix#entry as entry INNER JOIN
	                 #variables.prefix#page as page ON entry.id = page.id		
	                 LEFT OUTER JOIN #variables.prefix#comment as comment
					ON comment.entry_id = entry.id		
			WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/> AND
			(entry.title LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/> 
				OR entry.content LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/> 
				OR entry.excerpt LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/> 
				OR comment.content LIKE <cfqueryparam value="%#arguments.criteria#%" cfsqltype="CF_SQL_VARCHAR"/>)
			ORDER BY page.parent_page_id, page.sort_order, entry.title
		</cfquery>
	
		<cfreturn q_getIdsByKeyword />
	</cffunction>	
	
</cfcomponent>

