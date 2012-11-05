<cfcomponent output="false">
	
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

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="create" output="false" access="public">
		<cfargument name="path" required="true" type="any">
		<cfargument name="name" type="String" required="true" hint="Key with which the specified value is to be associated." />
		<cfargument name="value" type="String" required="true" hint="Value to be associated with the specified key" />
		<cfargument name="blog_id" type="String" required="false" default="" hint="Id of blog, can be just an empty string" />

		<cfscript>
			var q_insertSetting = "";
			var returnObj = structnew();
			returnObj["status"] = false;
			returnObj["message"] = "";
		</cfscript>
	
		<cftry>
			<cfquery name="q_insertSetting"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			insert into #variables.prefix#setting(path, name, value, blog_id)
			values (
				<cfqueryparam value="#arguments.path#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.value#" cfsqltype="CF_SQL_LONGVARCHAR" />,
				<cfqueryparam value="#arguments.blog_id#" cfsqltype="CF_SQL_VARCHAR" null="#len(arguments.blog_id) EQ 0#" />)
			</cfquery>
			
			<cfset returnObj["status"] = true/>
	
			<cfcatch type="Any">
				<cfset returnObj["status"] = false/>
				<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
			</cfcatch>
		</cftry>
	
		<cfif returnObj["status"]>
			<cfset returnObj["message"] = "Setting added"/>
			<cfset returnObj["data"] = arguments />
		</cfif>
	
		<cfreturn returnObj/>
		
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="update" output="false" hint="Updates a record" access="public" returntype="struct">
	<cfargument name="path" required="true" type="any">
	<cfargument name="name" type="String" required="true" hint="Key with which the specified value is to be associated." />
	<cfargument name="value" type="String" required="true" hint="Value to be associated with the specified key" />
	<cfargument name="blog_id" type="String" required="false" default="" hint="Id of blog, can be just an empty string" />

    <cfscript>
		var q_updateSetting = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<cfquery name="q_updateSetting"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			update #variables.prefix#setting
			set value = <cfqueryparam value="#arguments.value#" cfsqltype="CF_SQL_LONGVARCHAR" />
			where path = <cfqueryparam value="#arguments.path#" cfsqltype="CF_SQL_VARCHAR" /> AND
				name = <cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" /> AND
				<cfif len(arguments.blog_id)>
					blog_id = <cfqueryparam value="#arguments.blog_id#" cfsqltype="CF_SQL_VARCHAR" />
				<cfelse>
					(blog_id = '' OR blog_id IS NULL)
				</cfif>
		</cfquery>
		
		<cfset returnObj["status"] = true/>

	<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset returnObj["message"] = "Update successful"/>
		<cfset returnObj["data"] = arguments />
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="delete" output="false" access="public" returntype="void">
	<cfargument name="path" required="true" type="any">
	<cfargument name="name" type="String" required="true" hint="Key with which the specified value is to be associated." />
	<cfargument name="blog_id" type="String" required="false" default="" hint="Id of blog, can be just an empty string" />
	
	<cfset var q_deleteSetting = "" />
	
	<cfquery name="q_deleteSetting"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		DELETE FROM #variables.prefix#setting			
		where path = <cfqueryparam value="#arguments.path#" cfsqltype="CF_SQL_VARCHAR" /> AND
				name = <cfqueryparam value="#arguments.name#" cfsqltype="CF_SQL_VARCHAR" /> AND
				<cfif len(arguments.blog_id)>
					blog_id = <cfqueryparam value="#arguments.blog_id#" cfsqltype="CF_SQL_VARCHAR" />
				<cfelse>
					(blog_id = '' OR blog_id IS NULL)
				</cfif>
	</cfquery>
	
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="deleteByPath" output="false" access="public" returntype="void">
	<cfargument name="path" required="true" type="any">
	<cfargument name="blog_id" type="String" required="false" default="" hint="Id of blog, can be just an empty string" />
	<cfargument name="includeChildren" required="false" default="true" type="boolean">
	
	<cfset var q_deleteSetting = "" />
	<cfif arguments.includeChildren>
		<cfset arguments.path = arguments.path & "%">
	</cfif>
	
	<cfquery name="q_deleteSetting"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		DELETE FROM #variables.prefix#setting			
		where path LIKE <cfqueryparam value="#arguments.path#" cfsqltype="CF_SQL_VARCHAR" /> AND
			<cfif len(arguments.blog_id)>
				blog_id = <cfqueryparam value="#arguments.blog_id#" cfsqltype="CF_SQL_VARCHAR" />
			<cfelse>
				(blog_id = '' OR blog_id IS NULL)
			</cfif>
	</cfquery>
	
</cffunction>

</cfcomponent>