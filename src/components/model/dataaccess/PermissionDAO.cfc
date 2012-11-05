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
		<cfargument name="permission" required="true" type="any">

		<cfscript>
			var q_insertpermission = "";
			var returnObj = structnew();
			returnObj["status"] = false;
			returnObj["message"] = "";
		</cfscript>
	
		<cftry>
			<cfquery name="q_insertpermission"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			insert into #variables.prefix#permission(id, name, description, is_custom)
			values (
				<cfqueryparam value="#arguments.permission.id#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.permission.name#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.permission.description#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.permission.isCustom#" cfsqltype="cf_sql_bit" />)
			</cfquery>
			
			
			<cfset returnObj["status"] = true/>
	
			<cfcatch type="Any">
				<cfset returnObj["status"] = false/>
				<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
			</cfcatch>
		</cftry>
	
		<cfif returnObj["status"]>
			<cfset returnObj["message"] = "Permission added"/>
			<cfset returnObj["data"] = arguments.permission />
		</cfif>
	
		<cfreturn returnObj/>
		
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="update" output="false" hint="Updates a record" access="public" returntype="struct">
	<cfargument name="permission" required="true" type="any" hint="permission object"/>

    <cfscript>
		var q_updatepermission = "";
		var q_updatePermissionRoles = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>		
		<cfquery name="q_updatepermission"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			update #variables.prefix#permission
			set id = <cfqueryparam value="#arguments.permission.id#" cfsqltype="CF_SQL_VARCHAR" />,
				name = <cfqueryparam value="#arguments.permission.name#" cfsqltype="CF_SQL_VARCHAR" />,
				description = <cfqueryparam value="#arguments.permission.description#" cfsqltype="CF_SQL_VARCHAR" />,
				is_custom = <cfqueryparam value="#arguments.permission.isCustom#" cfsqltype="cf_sql_bit" />
			where id = <cfqueryparam value="#arguments.permission.oldId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<!--- Make sure the changes cascade --->
		<cfquery name="q_updatePermissionRoles"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			UPDATE #variables.prefix#role_permission
			SET permission_id = <cfqueryparam value="#arguments.permission.id#" cfsqltype="CF_SQL_VARCHAR" />
			WHERE id = <cfqueryparam value="#arguments.permission.oldId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
				
		<cfset returnObj["status"] = true/>

	<cfcatch type="Any">
			<cfset returnObj["status"] = false/>
			<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
		</cfcatch>
	</cftry>

	<cfif returnObj["status"]>
		<cfset returnObj["message"] = "Update successful"/>
		<cfset returnObj["data"] = arguments.permission />
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="delete" output="false" access="public" returntype="void">
	<cfargument name="permission" required="true" type="any">
	<cfset var q_deletepermission = "" />
	<cfset var q_updateRolePermissions = "" />
	
	<cfquery name="q_updateRolePermissions"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		DELETE FROM #variables.prefix#role_permission			
		where permission_id = <cfqueryparam value="#arguments.permission.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	
	
	<cfquery name="q_deletepermission"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		delete
		from #variables.prefix#permission
		where id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.permission.id#" />
	</cfquery>
	
</cffunction>

</cfcomponent>