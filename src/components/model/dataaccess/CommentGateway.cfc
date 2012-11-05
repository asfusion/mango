<cfcomponent name="comment" hint="Gateway for comment">

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

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByID" output="false" hint="Gets a query with only one record corresponding tor ID" access="public" returntype="query">
	<cfargument name="id" required="true" type="string" hint="Primary key"/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include non-approved comments"/>

	<cfset var q_comment = "" />
	
	<cfquery name="q_comment" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	comment.id, comment.entry_id, comment.content, comment.creator_name, comment.creator_email,
				comment.creator_url, comment.created_on, comment.approved, comment.author_id,
				comment.parent_comment_id, comment.rating, entry.title as entry_title,
				<!--- getting the id is redundant, but with this we can distinguish between a page and a post --->
				post.id as post_id
		FROM	#variables.prefix#comment as comment
		LEFT OUTER JOIN #variables.prefix#entry as entry ON comment.entry_id = entry.id
		LEFT OUTER JOIN #variables.prefix#post as post ON comment.entry_id = post.id
		WHERE comment.id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		<cfif NOT adminMode>
			AND comment.approved = 1
		</cfif>
	</cfquery>

	<cfreturn q_comment />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getRecent" output="false" hint="Gets all the records" access="public" returntype="query">
	<cfargument name="count" required="false" default="-1" type="numeric" hint=""/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include non-approved comments"/>
	
	<cfset var q_comment = "" />
	
	<cfquery name="q_comment" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#" maxRows="#arguments.count#">
		SELECT	comment.id, comment.entry_id, comment.content, comment.creator_name, comment.creator_email,
				comment.creator_url, comment.created_on, comment.approved, comment.author_id,
				comment.parent_comment_id, comment.rating, entry.title as entry_title,
				<!--- getting the id is redundant, but with this we can distinguish between a page and a post --->
				post.id as post_id
		FROM	#variables.prefix#comment as comment
		LEFT OUTER JOIN #variables.prefix#entry as entry ON comment.entry_id = entry.id
		LEFT OUTER JOIN #variables.prefix#post as post ON comment.entry_id = post.id	
		<cfif NOT adminMode>
			WHERE comment.approved = 1
			AND entry.status = 'published'
		</cfif>
		
		ORDER BY created_on desc
	</cfquery>

	<cfreturn q_comment />
</cffunction>

	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByPost" output="false" access="public" returntype="query">
	<cfargument name="entry_id" required="true" type="string" hint="Entry"/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include non-approved comments"/>
	<cfargument name="orderBy" required="false" type="string" default="DATE-ASC" hint="How to order the comments, defaults by date asc"/>
	
	<cfset var q_comment = "" />
	<cfset var order = "created_on ASC" />
		
	<cfif arguments.orderBy EQ "DATE-DESC">
		<cfset order = "created_on DESC" />
	</cfif>
	
	<cfquery name="q_comment" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	comment.id, comment.entry_id, comment.content, comment.creator_name, comment.creator_email,
				comment.creator_url, comment.created_on, comment.approved, comment.author_id,
				comment.parent_comment_id, comment.rating, entry.title as entry_title,
				<!--- getting the id is redundant, but with this we can distinguish between a page and a post --->
				post.id as post_id
		FROM	#variables.prefix#comment as comment
		LEFT OUTER JOIN #variables.prefix#entry as entry ON comment.entry_id = entry.id
		LEFT OUTER JOIN #variables.prefix#post as post ON comment.entry_id = post.id
		WHERE comment.entry_id = <cfqueryparam value="#arguments.entry_id#" cfsqltype="cf_sql_varchar"/>
		<cfif NOT adminMode>
			AND comment.approved = 1
		</cfif>
		ORDER BY #order#
	</cfquery>

	<cfreturn q_comment />
</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCount" output="false" hint="Gets the number of comments" access="public" returntype="numeric">
	<cfargument name="blogid" type="string" required="false" default="default" />
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<cfset var q_getCount = "" />

	<cfquery name="q_getCount" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT count(comment.id) as total
		FROM	#variables.prefix#comment as comment
		LEFT OUTER JOIN #variables.prefix#entry as entry ON comment.entry_id = entry.id
		WHERE entry.blog_id =  <cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar"/>
		<cfif NOT adminMode>
			AND comment.approved = 1
		</cfif>
	</cfquery>
	
	<cfreturn q_getCount.total />
	
</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getBycreated_on" output="false" access="public" returntype="query">
		<cfargument name="created_on" required="true" hint="Date"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include non-approved comments"/>

	<cfset var q_comment = "" />
	
	<cfquery name="q_comment" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	comment.id, comment.entry_id, comment.content, comment.creator_name, comment.creator_email,
				comment.creator_url, comment.created_on, comment.approved, comment.author_id,
				comment.parent_comment_id, comment.rating, entry.title as entry_title,
		FROM	#variables.prefix#comment as comment
		LEFT OUTER JOIN #variables.prefix#entry as entry ON comment.entry_id = entry.id
		WHERE comment.created_on = <cfqueryparam value="#arguments.created_on#" cfsqltype="CF_SQL_DATETIME"/>
		<cfif NOT adminMode>
			AND comment.approved = 1
		</cfif>
	</cfquery>

	<cfreturn q_comment />
</cffunction>

	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getByApproved" output="false" access="public" returntype="query">
		<cfargument name="approved" required="true" type="boolean" default="true" hint="Approved?"/>

	<cfset var q_comment = "" />
	
	<cfquery name="q_comment" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	comment.id, comment.entry_id, comment.content, comment.creator_name, comment.creator_email,
				comment.creator_url, comment.created_on, comment.approved, comment.author_id,
				comment.parent_comment_id, comment.rating, entry.title as entry_title,
				<!--- getting the id is redundant, but with this we can distinguish between a page and a post --->
				post.id as post_id
		FROM	#variables.prefix#comment as comment
		LEFT OUTER JOIN #variables.prefix#entry as entry ON comment.entry_id = entry.id
		LEFT OUTER JOIN #variables.prefix#post as post ON comment.entry_id = post.id
		WHERE approved = <cfqueryparam value="#arguments.approved#" cfsqltype="CF_SQL_BIT"/>
	</cfquery>

	<cfreturn q_comment />
</cffunction>

 
 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
 <cffunction name="search" output="false" hint="Search for comments matching the criteria" access="public" returntype="query">
	<cfargument name="entry_id" required="false" type="string" hint="Entry"/>
	<cfargument name="created_since" required="false" hint="Date"/>
	<cfargument name="approved" required="false" type="boolean"  hint="Approved?"/>
	<cfargument name="content" required="false" type="string"  hint="Content to match (exact match)"/>
	<cfargument name="creator_email" required="false" type="string"  hint="Email to match (exact match)"/>

	<cfset var q_search = "" />
	
	<cfquery name="q_search" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT	comment.id, comment.entry_id, comment.content, comment.creator_name, comment.creator_email,
				comment.creator_url, comment.created_on, comment.approved, comment.author_id,
				comment.parent_comment_id, comment.rating, entry.title as entry_title,
				<!--- getting the id is redundant, but with this we can distinguish between a page and a post --->
				post.id as post_id
		FROM	#variables.prefix#comment as comment
		LEFT OUTER JOIN #variables.prefix#entry as entry ON comment.entry_id = entry.id
		LEFT OUTER JOIN #variables.prefix#post as post ON comment.entry_id = post.id
		WHERE	0=0
	<cfif structkeyexists(arguments,"created_since") AND isDate(arguments.created_since)>
		AND comment.created_on >= <cfqueryparam value="#created_since#" cfsqltype="cf_sql_date" />
	</cfif>
	<cfif structkeyexists(arguments,"approved")>
		AND comment.approved = <cfqueryparam value="#arguments.approved#" cfsqltype="CF_SQL_BIT"/>
	</cfif>
	<cfif structkeyexists(arguments,"entry_id")>
		AND comment.entry_id = <cfqueryparam value="#arguments.entry_id#" cfsqltype="cf_sql_varchar"/>
	</cfif>
	<cfif structkeyexists(arguments,"content")>
		AND comment.content LIKE <cfqueryparam value="#arguments.content#" cfsqltype="cf_sql_longvarchar" />
	</cfif>
	<cfif structkeyexists(arguments,"creator_email")>
		AND  comment.creator_email = <cfqueryparam value="#arguments.creator_email#" cfsqltype="cf_sql_varchar" />
	</cfif>
	
	ORDER BY created_on
	</cfquery>

	<cfreturn q_search />

   </cffunction>

</cfcomponent>