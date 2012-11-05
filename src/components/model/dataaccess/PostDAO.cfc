<cfcomponent name="PostDAO" hint="Manages posts" extends="EntryDAO">

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="create" output="false" hint="Inserts a new record" access="public" returntype="struct">
	<cfargument name="post" required="true" type="any" hint="Post object"/>

	<cfscript>
		var qinsertpost = "";
		var returnObj = structnew();
		var counter = 0;
		var name = arguments.post.getName();
		var tempName = name;
		var blogid = arguments.post.getBlogId();
		var id = "";
		
		//check for duplicate names; loop until unique
		if (len(post.getName()) and post.getStatus() is "published") {
			id = getIdByName(tempName,blogid);
			
			while(id NEQ ""){
				counter = counter + 1;
				tempName = name & "-" & counter;
				id = getIdByName(tempName,blogid);
			}
		}
		arguments.post.setName(tempName);
		returnObj = super.create(arguments.post);	
	</cfscript>
	
	<cfif returnObj["status"]>
		<cftry>
			<cfquery name="qinsertpost"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				INSERT INTO #variables.prefix#post
				(id, posted_on)
				VALUES (
				<cfqueryparam value="#arguments.post.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
				<cfqueryparam value="#arguments.post.getPostedOn()#" cfsqltype="cf_sql_timestamp" />
				)
			  </cfquery>

			<cfset returnObj["status"] = true/>
	
		<cfcatch type="Any">
				<cfset returnObj["status"] = false/>
				<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
			</cfcatch>
		</cftry>
	
		<cfif returnObj["status"]>
			<cfset returnObj["message"] = "Insert successful"/>
			<cfset returnObj["data"] = arguments.post />
		</cfif>
	
	</cfif>
	<cfreturn returnObj/>
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="update" output="false" hint="Updates a record" access="public" returntype="struct">
	<cfargument name="post" required="true" type="any" hint="Post object"/>

    <cfscript>
		var qupdatepost = "";
		var returnObj = super.update(arguments.post);
	</cfscript>
	
	<cfif returnObj["status"]>
	<cftry>
		<cfquery name="qupdatepost"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		UPDATE #variables.prefix#post
		SET
			posted_on = <cfqueryparam value="#arguments.post.getPostedOn()#" cfsqltype="cf_sql_timestamp"/>		
		WHERE id = <cfqueryparam value="#arguments.post.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>

		<cfset returnObj["status"] = true/>

		<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset returnObj["message"] = "Update successful"/>
		<cfset returnObj["data"] = arguments.post />
	</cfif>
</cfif>
	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="delete" output="false" hint="Deletes a record" access="public" returntype="struct">
<cfargument name="id" required="true" type="string" hint="Primary key"/>
    
    <cfscript>
		var qdeletepost = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<cfquery name="qdeletepost"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
            DELETE FROM #variables.prefix#post
			WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
    
		<cfset returnObj = super.delete(arguments.id) />
		
    	<cfcatch type="Any">
    		<cfset returnObj["status"] = false/>
     	   <cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry>
    						
	<cfif returnObj["status"]>
    	<cfset returnObj["message"] = "Delete successful"/>
		<cfset returnObj["data"] = arguments.id />
    </cfif>
    
	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="setCategories" output="false" hint="Deletes a record" access="public" returntype="struct">
	<cfargument name="id" required="true" type="string" hint="Primary key"/>
	<cfargument name="categories" type="array" required="true" />
    
	<cfscript>
		var i = 0;
		var qSetCategories = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

<!---	<cftry> --->
		<cfquery name="qSetCategories"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
            DELETE FROM #variables.prefix#post_category
			WHERE post_id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
    	
		<cfloop from="1" to="#arraylen(categories)#" index="i">
			<cfquery name="qSetCategories"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		        INSERT INTO #variables.prefix#post_category
		        (post_id, category_id)
		        VALUES ( <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>, 
		         <cfqueryparam value="#arguments.categories[i]#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>)
			</cfquery>
		</cfloop>
		<cfset returnObj["status"] = true/>
		
<!---    	<cfcatch type="Any">
    		<cfset returnObj["status"] = false/>
     	   <cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry> --->
    						
	<cfif returnObj["status"]>
    	<cfset returnObj["message"] = "Update successful"/>
		<cfset returnObj["data"] = arguments />
    </cfif>
    
	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getIdByName" output="false" hint="Deletes a record" access="public" returntype="string">
	<cfargument name="name" required="true" type="string" hint="Name"/>
	<cfargument name="blogid" required="true" type="string" hint="Blog"/>
    
		<cfset var qexists = ""/>

		<cfquery name="qexists"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
         	SELECT 
				entry.id
			FROM #variables.prefix#post as post INNER JOIN
                #variables.prefix#entry as entry ON post.id = entry.id
			WHERE entry.name = <cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="200"/>
			AND entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>
		</cfquery>
	
   
	<cfreturn qexists.id />
</cffunction>

</cfcomponent>