<cfcomponent extends="EntryDAO">

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="read" output="false" access="public" returntype="any">
		<cfargument name="page" required="true" type="any" hint="Page object to populate"/>
		
		<cfset var qRead="">
		<cfset arguments.page = super.read(arguments.page) />

		<cfquery name="qRead" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			select 	id, parent_page_id, template,hierarchy,sort_order
			from #variables.prefix#page
			where id = <cfqueryparam value="#arguments.page.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>

		<cfscript>
			arguments.page.setparentPageId(qRead.parent_page_id);
			arguments.page.settemplate(qRead.template);
			arguments.page.setHierarchy(qRead.hierarchy);
			arguments.page.setSortOrder(val(qRead.sort_order));
			return arguments.page;
		</cfscript>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="create" output="false" hint="Inserts a new record" access="public" returntype="struct">
	<cfargument name="page" required="true" type="any" hint="Page object"/>

	<cfscript>
		var qinsertpost = "";
		var parent = "";
		var returnObj = structnew();
		var parentId = arguments.page.getParentPageId();
		var hierarchy = parentId;		
		var counter = 0;
		var name = arguments.page.getName();
		var tempName = name;
		var blogid = arguments.page.getBlogId();
		var id = "";
		
		//check for duplicate names; loop until unique
		if (len(page.getName()) and page.getStatus() is "published") {
			id = getIdByName(tempName,blogid);
			
			while(id NEQ ""){
				counter = counter + 1;
				tempName = name & "-" & counter;
				id = getIdByName(tempName, blogid);
			}
		}
		
		arguments.page.setName(tempName);
		
		if (parentId NEQ ""){
			//get parent's hierarchy to add to this page's
			parent = page.clone();
			parent.setId(parentId);
			read(parent);
			if(len(hierarchy))
				hierarchy = listprepend(hierarchy,parent.getHierarchy(),"/");
		}
		
		returnObj = super.create(arguments.page);		
	</cfscript>
	
	<cfif returnObj["status"]>
		<cftry>
			<cfquery name="qinsertpost"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				INSERT INTO #variables.prefix#page
				(id, parent_page_id, template,hierarchy,sort_order)
				VALUES (
				<cfqueryparam value="#arguments.page.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
				<cfqueryparam value="#arguments.page.getParentPageId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
				<cfqueryparam value="#arguments.page.gettemplate()#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#hierarchy#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.page.getSortOrder()#" cfsqltype="cf_sql_integer" />
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
			<cfset returnObj["data"] = arguments.page />
		</cfif>
	
	</cfif>
	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="update" output="false" hint="Updates a record" access="public" returntype="struct">
	<cfargument name="page" required="true" type="any" hint="Page object"/>

    <cfscript>
		var qupdatepost = "";
		var returnObj = super.update(arguments.page);
		var parent = "";
		var parentId = arguments.page.getParentPageId();
		var hierarchy = parentId;
		
		if (parentId NEQ ""){
			//get parent's hierarchy to add to this page's
			parent = page.clone();
			parent.setId(parentId);
			read(parent);
			if(len(hierarchy))
				hierarchy = listprepend(hierarchy,parent.getHierarchy(),"/");
		}
	</cfscript>
	
	<cfif returnObj["status"]>
	<cftry>
		<cfquery name="qupdatepost"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		UPDATE #variables.prefix#page
		SET
			parent_page_id = <cfqueryparam value="#arguments.page.getParentPageId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
			template = <cfqueryparam value="#arguments.page.gettemplate()#" cfsqltype="CF_SQL_VARCHAR" />,
			hierarchy = <cfqueryparam value="#hierarchy#" cfsqltype="CF_SQL_VARCHAR" />,
			sort_order = <cfqueryparam value="#arguments.page.getSortOrder()#" cfsqltype="cf_sql_integer" />
		WHERE id = <cfqueryparam value="#arguments.page.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>

		<cfset returnObj["status"] = true/>

		<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset returnObj["message"] = "Update successful"/>
		<cfset returnObj["data"] = arguments.page />
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
            DELETE FROM #variables.prefix#page
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
<cffunction name="getIdByName" output="false" hint="Deletes a record" access="public" returntype="string">
<cfargument name="name" required="true" type="string" hint="Name"/>
    <cfargument name="blogid" required="true" type="string" hint="Blog"/>
	
		<cfset var qexists = ""/>

		<cfquery name="qexists"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
         	SELECT 
				entry.id
			FROM #variables.prefix#page as page INNER JOIN
                #variables.prefix#entry as entry ON page.id = entry.id
			WHERE entry.name = <cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="150"/>
				AND entry.blog_id = <cfqueryparam value="#arguments.blogid#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>
		</cfquery>
	
   
	<cfreturn qexists.id />
</cffunction>

</cfcomponent>