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
		<cfargument name="blogId" required="true" type="any">
		<cfargument name="logRecord" required="true" type="any">

		<cfscript>
			var q_insertLog = "";
			var returnObj = structnew();
			returnObj["status"] = false;
			returnObj["message"] = "";
		</cfscript>
	
		<cftry>
			<cfquery name="q_insertLog"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				INSERT INTO #variables.prefix#log
				(level, category, message, logged_on, blog_id, owner)
				VALUES (
					<cfqueryparam value="#arguments.logRecord.level#"  cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.logRecord.category#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.logRecord.message#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp" />,
					<cfqueryparam value="#arguments.blogid#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.logRecord.owner#" cfsqltype="cf_sql_varchar" />
				)
			</cfquery>
			
			
			<cfset returnObj["status"] = true/>
	
			<cfcatch type="Any">
				<cfset returnObj["status"] = false/>
				<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
			</cfcatch>
		</cftry>
	
		<cfif returnObj["status"]>
			<cfset returnObj["message"] = "Log added"/>
			<cfset returnObj["data"] = arguments.logRecord />
		</cfif>
	
		<cfreturn returnObj/>
		
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="deleteByCriteria" output="false" access="public" returntype="void" 
			hint="Deletes logs. Carefull: if no criteria is specified, it will delete all">
	<cfargument name="blogId" required="true" type="any">
	<cfargument name="level" required="false" default="" type="any">
	<cfargument name="category" required="false" default="" type="any">
	<cfargument name="olderThan" required="false" default="" type="any">
	<cfargument name="owner" required="false" default="" type="any">
	
	<cfset var q_deleteLog = "" />
	
	<cfquery name="q_deleteLog"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		DELETE FROM #variables.prefix#log			
		where blog_id = <cfqueryparam value="#arguments.blogId#" cfsqltype="CF_SQL_VARCHAR">
		<cfif len(arguments.level)>
			AND level = <cfqueryparam value="#arguments.level#"  cfsqltype="cf_sql_varchar" />
		</cfif>
		<cfif len(arguments.category)>
			AND category = <cfqueryparam value="#arguments.category#"  cfsqltype="cf_sql_varchar" />
		</cfif>
		<cfif isdate(arguments.olderThan)>
			AND logged_on <= <cfqueryparam value="#arguments.olderThan#"  cfsqltype="cf_sql_date" />
		</cfif>
		<cfif len(arguments.owner)>
			AND owner = <cfqueryparam value="#arguments.owner#"  cfsqltype="cf_sql_varchar" />
		</cfif>
	</cfquery>
	
</cffunction>

</cfcomponent>