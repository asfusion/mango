<cfcomponent name="comment" hint="Manages comment">
      
 <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="datasource" required="true" type="struct">
		
		<cfset variables.datasource = arguments.datasource />
		<cfset variables.dsn = arguments.datasource.name />
		<cfset variables.prefix = arguments.datasource.tablePrefix />
		<cfset variables.username = arguments.datasource.username />
		<cfset variables.password = arguments.datasource.password />
		<cfreturn this />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="fetch" output="false" hint="" access="public" returntype="query">
<cfargument name="id" required="true" type="numeric" hint="Primary key"/>
	<cfargument name="columns" required="false" type="string" default="*" hint="Columns to include in the query. All by default"/>

	<cfset var qgetcomment = ""/>

		<cfquery name="qgetcomment"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT #arguments.columns# FROM comment
		WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>

	<cfreturn qgetcomment/>
</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="create" output="false" hint="Inserts a new record" access="public" returntype="struct">
	<cfargument name="commentData" required="true" type="any" hint="Comment object"/>

	<cfscript>
		var qinsertcomment = "";
		var returnObj = structnew();
		var id = arguments.commentData.getId();
		if (NOT len(id)){
			id = createUUID();
		}
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<cfquery name="qinsertcomment"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		INSERT INTO #variables.prefix#comment
		(id, entry_id,content,creator_name,creator_email,creator_url,created_on,approved,author_id,parent_comment_id,rating)
		VALUES (
		<cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
		<cfqueryparam value="#arguments.commentData.getEntryId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
		<cfqueryparam value="#arguments.commentData.getcontent()#" cfsqltype="cf_sql_longvarchar" />,
		<cfqueryparam value="#arguments.commentData.getcreatorName()#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>,
		<cfqueryparam value="#arguments.commentData.getcreatorEmail()#" cfsqltype="CF_SQL_VARCHAR" maxlength="100"/>,
		<cfqueryparam value="#arguments.commentData.getcreatorUrl()#" cfsqltype="CF_SQL_VARCHAR" maxlength="255"/>,
		<cfqueryparam value="#arguments.commentData.getcreatedOn()#" cfsqltype="cf_sql_timestamp"/>,
		<cfqueryparam value="#arguments.commentData.getapproved()#" cfsqltype="cf_sql_tinyint"/>,
		<cfqueryparam value="#arguments.commentData.getAuthorId()#" cfsqltype="CF_SQL_VARCHAR" null="#NOT len(arguments.commentData.getAuthorId())#"  maxlength="35"/>,
		<cfqueryparam value="#arguments.commentData.getparentCommentId()#" cfsqltype="CF_SQL_INTEGER"  null="#NOT len(arguments.commentData.getparentCommentId())#" />,
		<cfqueryparam value="#arguments.commentData.getRating()#" cfsqltype="cf_sql_float" />)
		  </cfquery>

		<cfset returnObj["status"] = true/>

		<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset arguments.commentData.setId(id)/>
		<cfset returnObj["message"] = "Insert successful"/>
		<cfset returnObj["data"] = arguments.commentData />
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="update" output="false" hint="Updates a record" access="public" returntype="struct">
	<cfargument name="comment" required="true" type="any">

    <cfscript>
		var qinsertcomment = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
		returnObj["id"] = arguments.comment.getid();
	</cfscript>

	<cftry>

		<cfquery name="qinsertcomment" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			update #variables.prefix#comment
			set 
				entry_id = <cfqueryparam value="#arguments.comment.getEntryId()#" cfsqltype="CF_SQL_VARCHAR" />,
				content = <cfqueryparam value="#arguments.comment.getcontent()#" cfsqltype="CF_SQL_LONGVARCHAR" />,
				creator_name = <cfqueryparam value="#arguments.comment.getcreatorName()#" cfsqltype="CF_SQL_VARCHAR" />,
				creator_email = <cfqueryparam value="#arguments.comment.getcreatorEmail()#" cfsqltype="CF_SQL_VARCHAR" />,
				creator_url = <cfqueryparam value="#arguments.comment.getcreatorUrl()#" cfsqltype="CF_SQL_VARCHAR" />,
				created_on = <cfqueryparam value="#arguments.comment.getcreatedOn()#" cfsqltype="CF_SQL_TIMESTAMP" />,
				approved = <cfqueryparam value="#arguments.comment.getapproved()#" cfsqltype="cf_sql_tinyint" />,
				author_id = <cfqueryparam value="#arguments.comment.getAuthorId()#" cfsqltype="CF_SQL_VARCHAR" null="#NOT len(arguments.comment.getAuthorId())#" />,
				parent_comment_id = <cfqueryparam value="#arguments.comment.getparentCommentId()#" cfsqltype="CF_SQL_VARCHAR" null="#NOT len(arguments.comment.getparentCommentId())#"/>,
				rating = <cfqueryparam value="#arguments.comment.getrating()#" cfsqltype="CF_SQL_FLOAT" />
			where id = <cfqueryparam value="#arguments.comment.getid()#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfset returnObj["status"] = true/>

		<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset returnObj["message"] = "Update successful"/>
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="delete" output="false" hint="Deletes a record" access="public" returntype="struct">
<cfargument name="id" required="true" type="string" hint="Primary key"/>
    
    <cfscript>
		var qdeletecomment = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
		returnObj["id"] = arguments.id;
	</cfscript>

	<cftry>
		<cfquery name="qdeletecomment"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
            DELETE FROM #variables.prefix#comment
			WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
    
		<cfset returnObj["status"] = true/>
		
    	<cfcatch type="Any">
    		<cfset returnObj["status"] = false/>
     	   <cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry>
    						
	<cfif returnObj["status"]>
    	<cfset returnObj["message"] = "Delete successful"/>
    </cfif>
    
	<cfreturn returnObj/>
</cffunction>

</cfcomponent>