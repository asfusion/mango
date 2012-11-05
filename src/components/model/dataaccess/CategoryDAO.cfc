<cfcomponent name="category" hint="Manages category">
      
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
<cffunction name="fetch" output="false" hint="" access="public" returntype="query">
<cfargument name="id" required="true" type="string" hint="Primary key"/>
	<cfargument name="columns" required="false" type="string" default="*" hint="Columns to include in the query. All by default"/>

	<cfset var qgetcategory = ""/>

		<cfquery name="qgetcategory"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT #arguments.columns# FROM category
		WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>

	<cfreturn qgetcategory/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="store" output="false" hint="Inserts a new record" access="public" returntype="any">
<cfargument name="category" required="true" type="any" hint="Category object"/>

		<cfset var id = arguments.category.getId() />
		<cfif len(id)>
			<!--- update --->
			<cfreturn update(arguments.category) />
		<cfelse>
			<cfreturn create(arguments.category) />
		</cfif>	

</cffunction>	
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="create" output="false" hint="Inserts a new record" access="public" returntype="struct">
		<cfargument name="category" required="true" type="any" hint="Category object"/>

	<cfscript>
		var qinsertcategory = "";
		var returnObj = structnew();
		var id = arguments.category.getId();
		if (NOT len(id)){
			id = createUUID();
		}
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<cfquery name="qinsertcategory"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		INSERT INTO #variables.prefix#category
		(id, name,title,description,created_on, parent_category_id, blog_id)
		VALUES (
		<cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
		<cfqueryparam value="#arguments.category.getName()#" cfsqltype="CF_SQL_VARCHAR" maxlength="150"/>,
		<cfqueryparam value="#arguments.category.gettitle()#" cfsqltype="CF_SQL_VARCHAR" maxlength="150"/>,
		<cfqueryparam value="#arguments.category.getdescription()#" cfsqltype="CF_SQL_LONGVARCHAR" />,
		<cfqueryparam value="#arguments.category.getCreationDate()#" cfsqltype="CF_SQL_TIMESTAMP"/>,
		<cfif arguments.category.getParentCategoryId() EQ "">null<cfelse><cfqueryparam value="#arguments.category.getParentCategoryId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/></cfif>,
					<cfqueryparam value="#arguments.category.getblogId()#" cfsqltype="CF_SQL_VARCHAR" />)
		  </cfquery>

		<cfset returnObj["status"] = true/>

		<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset arguments.category.setId(id)/>
		<cfset returnObj["message"] = "Insert successful"/>
		<cfset returnObj["data"] = arguments.category />
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="update" output="false" hint="Updates a record" access="public" returntype="struct">
	<cfargument name="category" required="true" type="any" hint="Category object"/>

    <cfscript>
		var qupdatecategory = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<cfquery name="qupdatecategory"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		UPDATE #variables.prefix#category
		SET
		name = <cfqueryparam value="#arguments.category.getName()#" cfsqltype="CF_SQL_VARCHAR" maxlength="150"/>,
		title = <cfqueryparam value="#arguments.category.gettitle()#" cfsqltype="CF_SQL_VARCHAR" maxlength="150"/>,
		description = <cfqueryparam value="#arguments.category.getdescription()#" cfsqltype="cf_sql_longvarchar" /><!---,
		created_on = <cfqueryparam value="#arguments.category.getCreationDate()#" cfsqltype="CF_SQL_TIMESTAMP"/> --->
		WHERE id = <cfqueryparam value="#arguments.category.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>

		<cfset returnObj["status"] = true/>

	<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset returnObj["message"] = "Update successful"/>
		<cfset returnObj["data"] = arguments.category />
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="delete" output="false" hint="Deletes a record" access="public" returntype="struct">
<cfargument name="id" required="true" type="string" hint="Primary key"/>
    
    <cfscript>
		var qdeletecategory = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
		returnObj["id"] = arguments.id;
	</cfscript>

	<cftry>
		<!--- first remove all post-categories relationships --->
		<cfquery name="qdeletecategory"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
            DELETE FROM #variables.prefix#post_category
			WHERE category_id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
		
		<cfquery name="qdeletecategory"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
            DELETE FROM #variables.prefix#category
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