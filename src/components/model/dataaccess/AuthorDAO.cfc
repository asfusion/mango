<cfcomponent name="author" hint="Manages author">
      
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

	<cfset var qgetauthor = ""/>

		<cfquery name="qgetauthor"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT #arguments.columns# FROM #variables.prefix#author
		WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35" />
		</cfquery>

	<cfreturn qgetauthor/>
</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="store" output="false" hint="Inserts a new record" access="public" returntype="any">
	<cfargument name="author" required="true" type="any" hint="Author object"/>

		<cfset var id = arguments.author.getId() />
		<cfif len(id)>
			<!--- update --->
			<cfreturn update(arguments.author) />
		<cfelse>
			<cfreturn create(arguments.author) />
		</cfif>	

</cffunction>	
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="create" output="false" hint="Inserts a new record" access="public" returntype="struct">
	<cfargument name="author" required="true" type="any" hint="Author object"/>


	<cfscript>
		var qinsertauthor = "";
		var i = 0;
		var returnObj = structnew();
		var id = arguments.author.getId();
		var blogs = arguments.author.getBlogs();
		var active = 0;
		if (arguments.author.active)
			active = 1;
		if (NOT len(id)){
			id = createUUID();
		}
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<cfquery name="qinsertauthor"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			INSERT INTO #variables.prefix#author
			(id, username,password,name,email,description, shortdescription, picture, alias, active)
			VALUES (
			<cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
			<cfqueryparam value="#arguments.author.getUsername()#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>,
			<cfqueryparam value="#hash(id & arguments.author.getpassword(),'SHA')#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>,
			<cfqueryparam value="#arguments.author.getname()#" cfsqltype="CF_SQL_VARCHAR" maxlength="100"/>,
			<cfqueryparam value="#arguments.author.getemail()#" cfsqltype="CF_SQL_VARCHAR" maxlength="255"/>,
			<cfqueryparam value="#arguments.author.getdescription()#" />,
			<cfqueryparam value="#arguments.author.getshortdescription()#"  />,
			<cfqueryparam value="#arguments.author.getpicture()#" cfsqltype="CF_SQL_VARCHAR" maxlength="100"/>,
			<cfqueryparam value="#arguments.author.getalias()#" cfsqltype="CF_SQL_VARCHAR" maxlength="100"/>,
			<cfqueryparam value="#active#" />
			)
		  </cfquery>
		  
		 <cfloop index="i" from="1" to="#arraylen(blogs)#">
			<cfquery name="qinsertauthor" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				INSERT INTO #variables.prefix#author_blog
				(author_id, blog_id, role)
				VALUES (
				<cfqueryparam value="#id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
				<cfqueryparam value="#blogs[i].id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#blogs[i].role.id#" cfsqltype="CF_SQL_VARCHAR">)
			</cfquery>
		</cfloop>
		<cfset returnObj["status"] = true/>

		<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset arguments.author.setId(id)/>
		<cfset returnObj["message"] = "Insert successful"/>
		<cfset returnObj["data"] = arguments.author />
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="update" output="false" hint="Updates a record" access="public" returntype="struct">
	<cfargument name="author" required="true" type="any" hint="Author object"/>

    <cfscript>
		var qupdateauthor = "";
		var returnObj = structnew();
		var blogs = arguments.author.getBlogs();
		var i = 0;
		var password = hash(arguments.author.getId() & arguments.author.getpassword(),'SHA');
		var oldAuthor = fetch(arguments.author.getId());
		var active = 0;
		if (arguments.author.active)
			active = 1;
		returnObj["status"] = false;
		returnObj["message"] = "";
		if (oldAuthor.password EQ arguments.author.getpassword()){
			password = arguments.author.getpassword();
		}
	</cfscript>
	
	<cftry>
		<cfquery name="qupdateauthor"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		UPDATE #variables.prefix#author
		SET
		username = <cfqueryparam value="#arguments.author.getUsername()#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>,
		password = <cfqueryparam value="#password#" cfsqltype="CF_SQL_VARCHAR" maxlength="50"/>,
		name = <cfqueryparam value="#arguments.author.getname()#" cfsqltype="CF_SQL_VARCHAR" maxlength="100"/>,
		email = <cfqueryparam value="#arguments.author.getemail()#" cfsqltype="CF_SQL_VARCHAR" maxlength="255"/>,
		description = <cfqueryparam value="#arguments.author.getdescription()#" />,
		shortdescription = <cfqueryparam value="#arguments.author.getshortdescription()#" />,
		picture = <cfqueryparam value="#arguments.author.getpicture()#" cfsqltype="CF_SQL_VARCHAR" maxlength="100"/>,
		alias = <cfqueryparam value="#arguments.author.getalias()#" cfsqltype="CF_SQL_VARCHAR" maxlength="100"/>,
		active = <cfqueryparam value="#active#" />
		WHERE id = <cfqueryparam value="#arguments.author.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
		
		<!--- remove old blogs from author--->
		<cfquery name="qupdateauthor"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			DELETE FROM #variables.prefix#author_blog
			WHERE author_id = <cfqueryparam value="#arguments.author.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
		
		<cfloop index="i" from="1" to="#arraylen(blogs)#">
			<cfquery name="qupdateauthor"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				INSERT INTO #variables.prefix#author_blog
				(author_id, blog_id, role)
				VALUES (
				<cfqueryparam value="#arguments.author.getId()#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>,
				<cfqueryparam value="#blogs[i].id#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#blogs[i].role.id#" cfsqltype="CF_SQL_VARCHAR">)
			</cfquery>
		</cfloop>
		
		<cfset returnObj["status"] = true/>

		<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset returnObj["message"] = "Update successful"/>
		<cfset returnObj["data"] = arguments.author />
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="delete" output="false" hint="Deletes a record" access="public" returntype="struct">
<cfargument name="id" required="true" type="numeric" hint="Primary key"/>
    
    <cfscript>
		var qdeleteauthor = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["msg"] = "";
		returnObj["id"] = arguments.id;
	</cfscript>

	<cftry>
		<!--- remove old blogs from author--->
		<cfquery name="qdeleteauthor"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			DELETE FROM #variables.prefix#author_blog
			WHERE author_id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
		
		<cfquery name="qdeleteauthor"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
            DELETE FROM #variables.prefix#author
			WHERE id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35"/>
		</cfquery>
    
		<cfset returnObj["status"] = true/>
		
    	<cfcatch type="Any">
    		<cfset returnObj["status"] = false/>
     	   <cfset returnObj["msg"] = CFCATCH.message & ": " & CFCATCH.detail />
		</cfcatch>
	</cftry>
    						
	<cfif returnObj["status"]>
    	<cfset returnObj["msg"] = "Delete successful"/>
    </cfif>
    
	<cfreturn returnObj/>
</cffunction>

</cfcomponent>