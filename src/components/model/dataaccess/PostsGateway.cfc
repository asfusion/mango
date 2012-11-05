<cfcomponent name="PostsGateway" hint="Gateway for posts">

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
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfreturn getByIds(idslist=arguments.id,adminMode=arguments.adminMode) />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getAll" output="false" hint="Gets all the records" access="public" returntype="query">
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		
	<cfset var q_getAll = "" />

	<cfquery name="q_getAll" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				post.posted_on AS posted_on, category.name AS category_name, author.name AS author,
        		entry_custom_field.field_value AS field_value, author.email AS author_email, entry_custom_field.id AS field_id, 
        		entry_custom_field.name AS field_name, category.id AS category_id, category.title AS category_title, 
        		category.description AS category_description, category.created_on AS category_created_on
		FROM	#variables.prefix#category as category RIGHT OUTER JOIN
        		#variables.prefix#post_category as post_category ON category.id = post_category.category_id RIGHT OUTER JOIN
        		#variables.prefix#author as author INNER JOIN
        		#variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
        		#variables.prefix#post as post ON entry.id = post.id ON post_category.post_id = post.id LEFT OUTER JOIN
        		#variables.prefix#entry_custom_field as entry_custom_field ON entry.id = entry_custom_field.entry_id
		WHERE entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
		</cfif>
	</cfquery>
	
	<cfreturn addCommentCount(q_getAll, arguments.adminMode) />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getAllIds" output="false" hint="Gets all the records" access="public" returntype="query">
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	<cfargument name="orderBy" required="false" type="string" default="DATE-DESC" hint="How to order the posts, defaults by date desc"/>
	
	<cfset var q_getAllIds = "" />
	<cfset var order = "post.posted_on DESC" />
		
	<cfif arguments.orderBy EQ "DATE-ASC">
		<cfset order = "post.posted_on ASC" />
	<cfelseif arguments.orderBy EQ "TITLE-ASC">
		<cfset order = "entry.title ASC" />
	<cfelseif arguments.orderBy EQ "TITLE-DESC">
		<cfset order = "entry.title DESC" />
	<cfelseif arguments.orderBy EQ "COMMENTCOUNT-DESC">
		<cfset order = "comment_count DESC, post.posted_on DESC" />
	<cfelseif arguments.orderBy EQ "COMMENTCOUNT-ASC">
		<cfset order = "comment_count ASC, post.posted_on DESC" />
	<cfelseif arguments.orderBy EQ "COMMENTACTIVITY-DESC">
		<cfset order = "comment_date DESC, post.posted_on DESC" />
	<cfelseif arguments.orderBy EQ "COMMENTACTIVITY-ASC">
		<cfset order = "comment_date ASC, post.posted_on DESC" />
	</cfif>

	<cfquery name="q_getAllIds" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT     entry.id <cfif arguments.orderBy EQ "COMMENTCOUNT-DESC" OR arguments.orderBy EQ "COMMENTCOUNT-ASC">
					, (SELECT count(comment.id) FROM #variables.prefix#comment AS comment WHERE comment.entry_id = post.id
			      <cfif NOT adminMode>
			         AND comment.approved = 1
			      </cfif>) AS comment_count</cfif>
			      <cfif arguments.orderBy EQ "COMMENTACTIVITY-DESC" OR arguments.orderBy EQ "COMMENTACTIVITY-ASC">
					, (SELECT MAX(comment.created_on) FROM #variables.prefix#comment AS comment WHERE comment.entry_id = post.id
			      <cfif NOT adminMode>
			         AND comment.approved = 1
			      </cfif>) AS comment_date</cfif>
		FROM     #variables.prefix#entry as entry INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
		</cfif>
		ORDER BY entry.status, #order#
	</cfquery>
	
	<cfreturn q_getAllIds />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCount" output="false" hint="Gets the number of posts" access="public" returntype="numeric">
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getCount = "" />

	<cfquery name="q_getCount" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT   count(entry.id) as total
		FROM     #variables.prefix#entry as entry INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/><!--- '#listgetat(arguments.blogid,1," ")#'we trust the blogid we get --->
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
		</cfif>
	</cfquery>
	
	<cfreturn q_getCount.total />
	
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getIdsByCategory" output="false" hint="Gets all the posts in a given category" access="public" returntype="query">
	<cfargument name="category" required="true" type="string" hint="Category ID"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getIdsByCategory  = "">
	
		<cfquery name="q_getIdsByCategory" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT     entry.id
		FROM     #variables.prefix#entry as entry INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id INNER JOIN
                      #variables.prefix#post_category as post_category ON post.id = post_category.post_id					
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		AND (post_category.category_id = <cfqueryparam value="#arguments.category#" cfsqltype="cf_sql_varchar" maxlength="150" />)
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
		</cfif>
		ORDER BY post.posted_on DESC
	</cfquery>

	<cfreturn q_getIdsByCategory />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getIdsByMultiCategory" output="false" hint="Gets all the posts in a given category" access="public" returntype="query">
	<cfargument name="category" required="true" type="string" hint="Category IDs"/>
	<cfargument name="match" required="false" default="any" type="string" hint="Whether to match any category in list (for multiple categories) or all"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getIdsByMultiCategory = "">
	
		<cfquery name="q_getIdsByMultiCategory" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT     entry.id
		FROM     #variables.prefix#entry as entry INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id INNER JOIN
                      #variables.prefix#post_category as post_category ON post.id = post_category.post_id					
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
			AND post_category.category_id IN (<cfqueryparam value="#arguments.category#" cfsqltype="cf_sql_varchar" list="true" />)
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
		</cfif>
		
		GROUP BY entry.id, post.posted_on
		<cfif arguments.match EQ "all">
			HAVING COUNT(*) = #listlen(arguments.category)#
		</cfif>
		ORDER BY post.posted_on DESC
	</cfquery>

	<cfreturn q_getIdsByMultiCategory />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCountByMultiCategory" output="false" hint="Gets the number of posts with given categories" 
			access="public" returntype="numeric">
	<cfargument name="category" required="true" type="string" hint="Category IDs"/>
	<cfargument name="match" required="false" default="any" type="string" hint="Whether to match any category in list (for multiple categories) or all"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
		<cfreturn getIdsByMultiCategory(argumentCollection=arguments).recordcount />
	
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getIdsByKeyword" output="false" hint="Gets all the posts that have the keyword in title or body" access="public" returntype="query">
	<cfargument name="keyword" required="true" type="string" hint="Keyword"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getIdsByKeyword  = "">
	
		<cfquery name="q_getIdsByKeyword" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT     entry.id
		FROM     #variables.prefix#entry as entry INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id				
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/> AND
		(entry.title LIKE <cfqueryparam value="%#arguments.keyword#%" cfsqltype="CF_SQL_VARCHAR"/> 
			OR entry.content LIKE <cfqueryparam value="%#arguments.keyword#%" cfsqltype="CF_SQL_VARCHAR"/> 
			OR entry.excerpt LIKE <cfqueryparam value="%#arguments.keyword#%" cfsqltype="CF_SQL_VARCHAR"/> )
		<cfif NOT arguments.adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
		</cfif>
		ORDER BY post.posted_on DESC
	</cfquery>

	<cfreturn q_getIdsByKeyword />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByDate" output="false" hint="Gets all the posts in a given category" access="public" returntype="query">
	<cfargument name="year" required="true" type="numeric" hint="Year" />
		<cfargument name="month" required="true" type="numeric" hint="Month"/>
		<cfargument name="day" required="true" type="numeric" hint="Day"/>
		<cfargument name="blogid" type="string" required="false" default="default" />
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	
	<cfset var q_getByDate  = "">
	
		<cfquery name="q_getByDate" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT     entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				post.posted_on AS posted_on, category.name AS category_name, author.name AS author,
                      entry_custom_field.field_value AS field_value, author.email AS author_email, entry_custom_field.id AS field_id, 
                      entry_custom_field.name AS field_name, category.id AS category_id, category.title AS category_title, 
                      category.description AS category_description, category.created_on AS category_created_on
		FROM          #variables.prefix#category as category RIGHT OUTER JOIN
                     #variables.prefix#post_category as post_category ON category.id = post_category.category_id RIGHT OUTER JOIN
                      #variables.prefix#author as author INNER JOIN
                       #variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id ON post_category.post_id = post.id LEFT OUTER JOIN
                      #variables.prefix#entry_custom_field as entry_custom_field ON entry.id = entry_custom_field.entry_id

			WHERE entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
					<cfif arguments.year NEQ 0>
						AND year(posted_on) like <cfqueryparam value="#arguments.year#" cfsqltype="cf_sql_integer"/>
					</cfif>
			 <cfif arguments.month NEQ 0>
						AND month(posted_on) like <cfqueryparam value="#arguments.month#" cfsqltype="cf_sql_integer"/>
			</cfif>
			 <cfif arguments.day NEQ 0>
						AND day(posted_on) like <cfqueryparam value="#arguments.day#" cfsqltype="cf_sql_integer"/>
			</cfif>
			<cfif NOT adminMode>
						AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
					 AND entry.status = 'published'
			</cfif>

		</cfquery>
	
	<cfreturn addCommentCount(q_getByDate, arguments.adminMode) />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCountByDate" output="false" hint="Gets the number of posts in a given date" access="public" returntype="numeric">
	<cfargument name="year" required="true" type="numeric" hint="Year" />
	<cfargument name="month" required="true" type="numeric" hint="Month"/>
	<cfargument name="day" required="true" type="numeric" hint="Day"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getCountByDate  = "">
	
		<cfquery name="q_getCountByDate" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT   count(entry.id) as total
			FROM     #variables.prefix#entry as entry INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id				
			WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
			<cfif arguments.year NEQ 0>
				AND year(posted_on) like <cfqueryparam value="#arguments.year#" cfsqltype="cf_sql_integer"/>
			</cfif>
			<cfif arguments.month NEQ 0>
					AND month(posted_on) like <cfqueryparam value="#arguments.month#" cfsqltype="cf_sql_integer"/>
			</cfif>
			 <cfif arguments.day NEQ 0>
					AND day(posted_on) like <cfqueryparam value="#arguments.day#" cfsqltype="cf_sql_integer"/>
			</cfif>
			<cfif NOT adminMode>
				AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
				 AND entry.status = 'published'
			</cfif>

		</cfquery>
	
	<cfreturn q_getCountByDate.total />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="addCommentCount" output="false" hint="Adds comment count to a query of posts" access="public" returntype="query">
	<cfargument name="postsQuery" required="true" type="query" hint="Query of posts"/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include not approved comments"/>
	
	<cfset var q_post = arguments.postsQuery />
	<cfset var q_addCommentCount  = "">

	<!--- join with comment count --->
	<cfquery name="q_addCommentCount" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		<!--- SELECT COUNT(comment.id) AS comment_count, post.id
		FROM #variables.prefix#post as post LEFT OUTER JOIN
					#variables.prefix#comment as comment ON post.id = comment.entry_id
		GROUP BY post.id --->
		
		SELECT
      	(SELECT count(comment.id) FROM #variables.prefix#comment AS comment WHERE comment.entry_id = post.id
      <cfif NOT adminMode>
         AND comment.approved = 1
      </cfif>) AS comment_count, post.id
   		FROM #variables.prefix#post as post
	</cfquery>

	<!--- join with comment count --->
	<cfquery name="q_post" dbtype="query">
		SELECT    * 
		FROM q_post, q_addCommentCount
		WHERE q_post.id = q_addCommentCount.id
		ORDER BY status, posted_on DESC
	</cfquery>

	<cfreturn q_post />
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByName" output="false" access="public" returntype="query">
	<cfargument name="name" required="true" type="string" default="" hint="Name"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var id = getIdByName(arguments.name, arguments.blogid,arguments.adminMode) />
	<cfreturn getByIds(idslist=id, adminMode=arguments.adminMode) />
	
</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getIdByName" output="false" access="public" returntype="string">
	<cfargument name="name" required="true" type="string" default="" hint="Name"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getIdByName = "" />
	
		<cfquery name="q_getIdByName" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT     entry.id
		FROM     #variables.prefix#entry as entry INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id					
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
		</cfif>
		AND entry.name = <cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="150"/>
	</cfquery>
	<cfif q_getIdByName.recordcount>
	<cfreturn q_getIdByName.id />
	<cfelse> <cfreturn "">
	</cfif>
</cffunction>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getActiveYears" output="false" access="public" returntype="query">
	<cfargument name="blogid" type="string" required="false" default="default" />	
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getActiveYears = "" />
	
	<cfquery name="q_getActiveYears" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT     COUNT(post.id) AS post_count, YEAR(posted_on) AS year
		FROM     #variables.prefix#post as post INNER JOIN
                      #variables.prefix#entry as entry ON entry.id = post.id
		WHERE entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
			 AND entry.status = 'published'
		</cfif>
		GROUP BY YEAR(posted_on)
		ORDER BY  year(posted_on) DESC
	</cfquery>

	<cfreturn q_getActiveYears />
</cffunction>	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getActiveMonths" output="false" access="public" returntype="query">
	<cfargument name="year" required="false" default="0" type="numeric" hint="Year" />
	<cfargument name="blogid" type="string" required="false" default="default" />	
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getActiveMonths = "" />
	
	<cfquery name="q_getActiveMonths" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT      COUNT(post.id) AS post_count, YEAR(posted_on) AS year, MONTH(posted_on) AS month
		FROM     #variables.prefix#post as post INNER JOIN
                      #variables.prefix#entry as entry ON entry.id = post.id
		WHERE entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif arguments.year NEQ 0>
			year(posted_on) = <cfqueryparam value="#arguments.year#" cfsqltype="cf_sql_integer" />
		</cfif>
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
			 AND entry.status = 'published'
		</cfif>
		GROUP BY month(posted_on), year(posted_on)
		ORDER BY year(posted_on) DESC, month(posted_on)  DESC
	</cfquery>

	<cfreturn q_getActiveMonths />
</cffunction>	
	
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getActiveDays" output="false" access="public" returntype="query">
	<cfargument name="year" required="false" default="0" type="numeric" hint="Year" />
	<cfargument name="month" required="true" type="numeric" hint="Month"/>
	<cfargument name="blogid" type="string" required="false" default="default" />	
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getActiveDays = "" />
	
	<cfquery name="q_getActiveDays" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT      COUNT(post.id) AS post_count, YEAR(posted_on) AS year, MONTH(posted_on) AS month, DAY(posted_on) AS day
		FROM     #variables.prefix#post as post INNER JOIN
                      #variables.prefix#entry as entry ON entry.id = post.id
		WHERE month(posted_on) = #arguments.month#
		AND entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif arguments.year NEQ 0>
			 AND year(posted_on) = <cfqueryparam value="#arguments.year#" cfsqltype="cf_sql_integer" />
		</cfif>
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
			 AND entry.status = 'published'
		</cfif>
		GROUP BY month(posted_on), year(posted_on), DAY(posted_on)
		ORDER BY month(posted_on) DESC, year(posted_on) DESC, DAY(posted_on) DESC
	</cfquery>

	<cfreturn q_getActiveDays />
</cffunction>		
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getIdsByAuthor" output="false" access="public" returntype="query">
	<cfargument name="author_id" required="true" type="string" hint="Author"/>
	<cfargument name="blogid" type="string" required="false" default="default" />		
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getByAuthor = "" />

		<cfquery name="q_getByAuthor" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT	entry.id
			FROM	#variables.prefix#entry as entry INNER JOIN
                    #variables.prefix#post as post ON entry.id = post.id	
			WHERE	entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/> 
			AND		entry.author_id = <cfqueryparam value="#arguments.author_id#" cfsqltype="cf_sql_varchar" maxlength="35"/>
			<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
			</cfif>
			ORDER BY post.posted_on DESC
		</cfquery>

	<cfreturn q_getByAuthor />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCountByAuthor" output="false" hint="Gets the number of posts by a given author" 
			access="public" returntype="numeric">
	<cfargument name="author_id" required="true" type="string" hint="Author"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getCountByAuthor  = "">
	
		<cfquery name="q_getCountByAuthor" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT   count(entry.id) as total
			FROM	#variables.prefix#entry as entry INNER JOIN
                    #variables.prefix#post as post ON entry.id = post.id	
			WHERE	entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/> 
			AND		entry.author_id = <cfqueryparam value="#arguments.author_id#" cfsqltype="cf_sql_varchar" maxlength="35"/>
			<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
			</cfif>

		</cfquery>
	
	<cfreturn q_getCountByAuthor.total />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getIdsByStatus" output="false" access="public" returntype="query">
	<cfargument name="status" required="false" default="" type="string" hint="Status"/>
	<cfargument name="ids" required="false" default="" type="string" hint="list with ids in case we just want to filter those ids by status"/>
	<cfargument name="blogid" type="string" required="false" default="default" />		
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include future posts"/>
	
	<cfset var q_getIdsByStatus = "" />

		<cfquery name="q_getIdsByStatus" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			SELECT	entry.id
			FROM	#variables.prefix#entry as entry INNER JOIN
                    #variables.prefix#post as post ON entry.id = post.id	
			WHERE	entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/> 
			<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
			</cfif>
			<cfif len(arguments.ids)>
				AND entry.id IN (<cfqueryparam value="#arguments.ids#" list="true" />)
			</cfif>
			<cfif len(arguments.status)>
				AND entry.status = <cfqueryparam value="#arguments.status#" cfsqltype="cf_sql_varchar"/> 
			</cfif>
			ORDER BY post.posted_on DESC
		</cfquery>

	<cfreturn q_getIdsByStatus />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getIdsByCustomField" output="false" hint="Gets all the posts in a given category" access="public" returntype="query">
	<cfargument name="customField" required="true" type="string" hint="CustomField Key"/>
	<cfargument name="customFieldValue" required="false" default="" type="string" hint="CustomField value"/>
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	<cfargument name="orderBy" required="false" type="string" default="DATE-DESC" hint="How to order the posts, defaults by date desc"/>
	
	<cfset var q_getIdsByCustomField  = "">
	<cfset var order = "post.posted_on DESC" />
		
	<cfif arguments.orderBy EQ "DATE-ASC">
		<cfset order = "post.posted_on ASC" />
	<cfelseif arguments.orderBy EQ "TITLE-ASC">
		<cfset order = "entry.title ASC" />
	<cfelseif arguments.orderBy EQ "TITLE-DESC">
		<cfset order = "entry.title DESC" />
	<cfelseif arguments.orderBy EQ "COMMENTCOUNT-DESC">
		<cfset order = "comment_count DESC, post.posted_on DESC" />
	<cfelseif arguments.orderBy EQ "COMMENTCOUNT-ASC">
		<cfset order = "comment_count ASC, post.posted_on DESC" />
	<cfelseif arguments.orderBy EQ "COMMENTACTIVITY-DESC">
		<cfset order = "comment_date DESC, post.posted_on DESC" />
	<cfelseif arguments.orderBy EQ "COMMENTACTIVITY-ASC">
		<cfset order = "comment_date ASC, post.posted_on DESC" />
	<cfelseif arguments.orderBy EQ "CUSTOMFIELD-ASC">
		<cfset order = "entry_custom_field.field_value ASC, post.posted_on DESC" />
	<cfelseif arguments.orderBy EQ "CUSTOMFIELD-DESC">
		<cfset order = "entry_custom_field.field_value DESC, post.posted_on DESC" />
	</cfif>
	
	
		<cfquery name="q_getIdsByCustomField" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT     entry.id <cfif arguments.orderBy EQ "COMMENTCOUNT-DESC" OR arguments.orderBy EQ "COMMENTCOUNT-ASC">
					, (SELECT count(comment.id) FROM #variables.prefix#comment AS comment WHERE comment.entry_id = post.id
			      <cfif NOT adminMode>
			         AND comment.approved = 1
			      </cfif>) AS comment_count</cfif>
			      <cfif arguments.orderBy EQ "COMMENTACTIVITY-DESC" OR arguments.orderBy EQ "COMMENTACTIVITY-ASC">
					, (SELECT MAX(comment.created_on) FROM #variables.prefix#comment AS comment WHERE comment.entry_id = post.id
			      <cfif NOT adminMode>
			         AND comment.approved = 1
			      </cfif>) AS comment_date</cfif>
		FROM     #variables.prefix#entry as entry INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id INNER JOIN
                      #variables.prefix#entry_custom_field as entry_custom_field ON entry.id = entry_custom_field.entry_id				
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		AND entry_custom_field.id = <cfqueryparam value="#arguments.customField#" cfsqltype="cf_sql_varchar" maxlength="255" />
		<cfif len(arguments.customFieldValue)>
			AND entry_custom_field.field_value LIKE <cfqueryparam value="#arguments.customFieldValue#" cfsqltype="cf_sql_varchar" />
		</cfif>
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
						 AND entry.status = 'published'
		</cfif>
		ORDER BY entry.status, #order#
	</cfquery>

	<cfreturn q_getIdsByCustomField />
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByIds" output="false" hint="Gets all the records" access="public" returntype="query">
	<cfargument name="idslist" required="false" default="" type="string" hint="list with ids"/>
	<cfargument name="idsQuery" required="false" default="#querynew("key")#" type="query" hint="query with ids (key)"/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	<cfargument name="orderBy" required="false" type="string" default="DATE-DESC" hint="How to order the posts, defaults by date desc"/>
	
	<cfset var q_getByIds = "" />
	<cfset var ids = "" />
	<cfset var order = "post.posted_on DESC, category.title" />
		
	<cfif arguments.orderBy EQ "DATE-ASC">
		<cfset order = "post.posted_on ASC, category.title" />
	<cfelseif arguments.orderBy EQ "TITLE-ASC">
		<cfset order = "entry.title ASC, category.title" />
	<cfelseif arguments.orderBy EQ "TITLE-DESC">
		<cfset order = "entry.title DESC, category.title" />
	<cfelseif arguments.orderBy EQ "COMMENTCOUNT-DESC">
		<cfset order = "comment_count DESC, post.posted_on DESC, category.title" />
	<cfelseif arguments.orderBy EQ "COMMENTCOUNT-ASC">
		<cfset order = "comment_count ASC, post.posted_on DESC, category.title" />
	<cfelseif arguments.orderBy EQ "COMMENTACTIVITY-DESC">
		<cfset order = "comment_date DESC, post.posted_on DESC, category.title" />
	<cfelseif arguments.orderBy EQ "COMMENTACTIVITY-ASC">
		<cfset order = "comment_date ASC, post.posted_on DESC, category.title" />
	</cfif>
	
	<cfif len(arguments.idsList)>
		<cfset ids = arguments.idsList />
	<cfelse>
		<cfset ids = valueList(arguments.idsQuery.key) />
	</cfif>
	<!--- prevent the IN clause to fail if the ids where empty --->
	<cfif NOT listlen(ids)>
		<cfset ids = "0" />
	</cfif>
	<cfquery name="q_getByIds" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT     entry.id, entry.name, entry.title, entry.content, entry.excerpt, entry.author_id,
				entry.comments_allowed, entry.trackbacks_allowed, entry.status, entry.last_modified, entry.blog_id,
				post.posted_on AS posted_on, category.name AS category_name, author.name AS author,
                      entry_custom_field.field_value AS field_value, author.email AS author_email, entry_custom_field.id AS field_id, 
                      entry_custom_field.name AS field_name, category.id AS category_id, category.title AS category_title, 
                      category.description AS category_description, category.created_on AS category_created_on,
					(SELECT count(comment.id) FROM #variables.prefix#comment AS comment WHERE comment.entry_id = post.id
			      <cfif NOT adminMode>
			         AND comment.approved = 1
			      </cfif>) AS comment_count
			      <cfif arguments.orderBy EQ "COMMENTACTIVITY-DESC" OR arguments.orderBy EQ "COMMENTACTIVITY-ASC">
					, (SELECT MAX(comment.created_on) FROM #variables.prefix#comment AS comment WHERE comment.entry_id = post.id
			      <cfif NOT adminMode>
			         AND comment.approved = 1
			      </cfif>) AS comment_date</cfif>
		FROM          #variables.prefix#category as category RIGHT OUTER JOIN
                     #variables.prefix#post_category as post_category ON category.id = post_category.category_id RIGHT OUTER JOIN
                      #variables.prefix#author as author INNER JOIN
                       #variables.prefix#entry as entry ON author.id = entry.author_id INNER JOIN
                       #variables.prefix#post as post ON entry.id = post.id ON post_category.post_id = post.id LEFT OUTER JOIN
                      #variables.prefix#entry_custom_field as entry_custom_field ON entry.id = entry_custom_field.entry_id
		WHERE entry.id IN (<cfqueryparam value="#ids#" list="true" />)
		<cfif NOT adminMode>
			AND post.posted_on <= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />
			 AND entry.status = 'published'
		</cfif>
		ORDER BY status, #order#
	</cfquery>
	
	<cfreturn q_getByIds />
</cffunction>

</cfcomponent>