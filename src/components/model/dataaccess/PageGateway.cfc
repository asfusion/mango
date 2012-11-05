<cfcomponent name="PagesGateway" hint="Gateway for pages">

 <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="datasource" required="true" type="struct">
	<cfargument name="cacheMinutes" required="false" default="0" type="numeric" hint="Number of minutes to cache">
		
		<cfset variables.datasource = arguments.datasource />
		<cfset variables.dsn = arguments.datasource.name />
		<cfset variables.cacheMinutes = arguments.cacheMinutes />
		<cfset variables.prefix = arguments.datasource.tablePrefix />
		<cfset variables.username = arguments.datasource.username />
		<cfset variables.password = arguments.datasource.password />
		
		<cfreturn this />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByID" output="false" hint="Gets a query with only one record corresponding tor ID" access="public" returntype="query">
	<cfargument name="id" required="true" type="string" hint="Primary key"/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>

	<cfset var q_post = "" />
	
	<cfquery name="q_post" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				author.name AS author, author.email AS author_email, entry_custom_field.id AS field_id, entry_custom_field.name AS field_name, 
                entry_custom_field.field_value AS field_value,
				page.template, page.parent_page_id, page.hierarchy, page.sort_order
		FROM 
				#variables.prefix#entry_custom_field as entry_custom_field RIGHT OUTER JOIN             
                #variables.prefix#author as author INNER JOIN
                #variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
                #variables.prefix#page as page ON entry.id = page.id ON entry_custom_field.entry_id = entry.id
		WHERE entry.id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		<cfif NOT adminMode>
			 AND entry.status = 'published'
		</cfif>
	</cfquery>
	<cfreturn addCommentCount(q_post) />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getAll" output="false" hint="Gets all the records" access="public" returntype="query">
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
	
	<cfset var q_pageGatewayGetAll = "" />

	<cfquery name="q_pageGatewayGetAll" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				author.name AS author, author.email AS author_email, entry_custom_field.id AS field_id, entry_custom_field.name AS field_name, 
                entry_custom_field.field_value AS field_value,
				page.template, page.parent_page_id, page.hierarchy, page.sort_order
			FROM 
				#variables.prefix#entry_custom_field as entry_custom_field RIGHT OUTER JOIN             
                #variables.prefix#author as author INNER JOIN
                #variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
                #variables.prefix#page as page ON entry.id = page.id ON entry_custom_field.entry_id = entry.id
			WHERE entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif NOT adminMode>
			 AND entry.status = 'published'
		</cfif>
	 ORDER BY parent_page_id,sort_order, title
	</cfquery>
	
	<cfreturn addCommentCount(q_pageGatewayGetAll) />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByParent" output="false" hint="Gets the children of a given page (by id)" access="public" returntype="query">
	<cfargument name="parent_id" required="true" type="string" hint="Parent key"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>

	<cfset var q_getByParent = "" />
	
	<cfquery name="q_getByParent" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				author.name AS author, author.email AS author_email, entry_custom_field.id AS field_id, entry_custom_field.name AS field_name, 
                entry_custom_field.field_value AS field_value,
				page.template, page.parent_page_id, page.hierarchy, page.sort_order
			FROM 
				#variables.prefix#entry_custom_field as entry_custom_field RIGHT OUTER JOIN             
                #variables.prefix#author as author INNER JOIN
                #variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
                #variables.prefix#page as page ON entry.id = page.id ON entry_custom_field.entry_id = entry.id
		<cfif len(arguments.parent_id)>
		WHERE page.parent_page_id = <cfqueryparam value="#arguments.parent_id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		<cfelse>
			WHERE (page.parent_page_id IS NULL	OR page.parent_page_id = '')
		</cfif>
		<cfif NOT adminMode>
			 AND entry.status = 'published'
		</cfif>
			AND entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		ORDER BY sort_order, title
	</cfquery>
	<cfreturn addCommentCount(q_getByParent) />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="addCommentCount" output="false" hint="Adds comment count to a query of posts" access="public" returntype="query">
	<cfargument name="postsQuery" required="true" type="query" hint="Query of posts"/>
	
	<cfset var q_post = arguments.postsQuery />
	<cfset var q_comments  = "">

	<!--- join with comment count --->
	<cfquery name="q_comments" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT COUNT(comment.id) AS comment_count, page.id
		FROM #variables.prefix#page as page LEFT OUTER JOIN
					#variables.prefix#comment as comment ON page.id = comment.entry_id
		GROUP BY page.id
	</cfquery>

	<!--- join with comment count --->
	<cfquery name="q_post" dbtype="query">
		SELECT    * 
		FROM q_post, q_comments
		WHERE q_post.id = q_comments.id
		ORDER BY hierarchy, sort_order, title
	</cfquery>

	<cfreturn q_post />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCount" output="false" hint="Gets the number of pages" access="public" returntype="numeric">
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getCount = "" />

	<cfquery name="q_getCount" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT   count(entry.id) as total
		FROM     #variables.prefix#entry as entry INNER JOIN
                       #variables.prefix#page as page ON entry.id = page.id
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/><!--- '#listgetat(arguments.blogid,1," ")#'we trust the blogid we get --->
		<cfif NOT adminMode>
			AND entry.status = 'published'
		</cfif>
	</cfquery>
	
	<cfreturn q_getCount.total />
	
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByName" output="false" access="public" returntype="query">
		<cfargument name="name" required="true" type="string" default="" hint="Name"/>
		<cfargument name="blogid" type="string" required="false" default="default" />
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>

	<cfset var q_getByName = "" />
	
	<cfquery name="q_getByName" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				author.name AS author, author.email AS author_email, entry_custom_field.id AS field_id, entry_custom_field.name AS field_name, 
                entry_custom_field.field_value AS field_value,
				page.template, page.parent_page_id, page.hierarchy, page.sort_order
			FROM 
				#variables.prefix#entry_custom_field as entry_custom_field RIGHT OUTER JOIN             
                #variables.prefix#author as author INNER JOIN
                #variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
                #variables.prefix#page as page ON entry.id = page.id ON entry_custom_field.entry_id = entry.id
		WHERE entry.name = <cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="150"/>
		AND entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif NOT adminMode>
			 AND entry.status = 'published'
		</cfif>
	</cfquery>

	<cfreturn addCommentCount(q_getByName) />
</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByAuthor" output="false" access="public" returntype="query">
	<cfargument name="author_id" required="true" type="string" hint="Author"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
	
	<cfset var q_getByAuthor = "" />
	<cfquery name="q_getByAuthor" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				author.name AS author, author.email AS author_email, entry_custom_field.id AS field_id, entry_custom_field.name AS field_name, 
                entry_custom_field.field_value AS field_value,
				page.template, page.parent_page_id, page.hierarchy, page.sort_order
			FROM 
				#variables.prefix#entry_custom_field as entry_custom_field RIGHT OUTER JOIN             
                #variables.prefix#author as author INNER JOIN
                #variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
                #variables.prefix#page as page ON entry.id = page.id ON entry_custom_field.entry_id = entry.id
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		AND entry.author_id = <cfqueryparam value="#arguments.author_id#" cfsqltype="cf_sql_varchar" maxlength="35"/>
		<cfif NOT adminMode>
			 AND entry.status = 'published'
		</cfif>
		ORDER BY sort_order, title
	</cfquery>

	<cfreturn addCommentCount(q_getByAuthor) />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByCustomField" output="false" hint="Gets all the posts in a given category" access="public" returntype="query">
	<cfargument name="customField" required="true" type="string" hint="CustomField Key"/>
	<cfargument name="customFieldValue" required="false" default="" type="string" hint="CustomField value"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getByCustomField  = "">
	
	<cfquery name="q_getByCustomField" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				author.name AS author, author.email AS author_email, entry_custom_field.id AS field_id, entry_custom_field.name AS field_name, 
                entry_custom_field.field_value AS field_value,
				page.template, page.parent_page_id, page.hierarchy, page.sort_order
			FROM 
				#variables.prefix#entry_custom_field as entry_custom_field RIGHT OUTER JOIN
                #variables.prefix#author as author INNER JOIN
                #variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
                #variables.prefix#page as page ON entry.id = page.id ON entry_custom_field.entry_id = entry.id
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		AND entry_custom_field.id = <cfqueryparam value="#arguments.customField#" cfsqltype="cf_sql_varchar" maxlength="255" />
		<cfif len(arguments.customFieldValue)>
			AND entry_custom_field.field_value = <cfqueryparam value="#arguments.customFieldValue#" cfsqltype="cf_sql_varchar" />
		</cfif>
		<cfif NOT adminMode>
			 AND entry.status = 'published'
		</cfif>
		ORDER BY sort_order, title
	</cfquery>

	<cfreturn addCommentCount(q_getByCustomField) />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
 <cffunction name="search" output="false" hint="Search for post matching the criteria" access="public" returntype="query">
	<cfargument name="keyword" required="false" type="string" default="" hint="Keyword"/>
	<cfargument name="author_id" required="false" type="numeric" default="0" hint="Author"/>
	<cfargument name="status" required="false" type="string" default="" hint="Status"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
			 
	<cfargument name="orderby" required="false" default="posted_on desc" type="string" hint="Order in which the quiery will be returned. Only column names allowed, separated by commas"/>

	<cfset var q_post = "" />
	
	<cfquery name="q_post" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				author.name AS author, author.email AS author_email, entry_custom_field.id AS field_id, entry_custom_field.name AS field_name, 
                entry_custom_field.field_value AS field_value
			FROM 
				#variables.prefix#entry_custom_field as entry_custom_field RIGHT OUTER JOIN             
                #variables.prefix#author as author INNER JOIN
                #variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
                #variables.prefix#page as page ON entry.id = page.id ON entry_custom_field.entry_id = entry.id
			WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/> AND 
			(entry.title LIKE <cfqueryparam value="%#keyword#%" cfsqltype="CF_SQL_VARCHAR"/> 
			OR entry.content LIKE <cfqueryparam value="%#keyword#%" cfsqltype="CF_SQL_VARCHAR"/> 
			OR entry.excerpt LIKE <cfqueryparam value="%#keyword#%" cfsqltype="CF_SQL_VARCHAR"/> )
			AND entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif NOT adminMode>
			 AND entry.status = 'published'
		</cfif>
		ORDER BY #arguments.orderby#
	</cfquery>

	<cfreturn addCommentCount(q_post) />
   </cffunction>

</cfcomponent>