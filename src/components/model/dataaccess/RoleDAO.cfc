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
		<cfargument name="role" required="true" type="any">

		<cfscript>
			var q_insertRole = "";
			var q_insertPermissions = "";
			var returnObj = structnew();
			var permission = "";
			returnObj["status"] = false;
			returnObj["message"] = "";
		</cfscript>
	
		<cftry>
			<cfquery name="q_insertRole"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			insert into #variables.prefix#role(id, name, description, preferences)
			values (
				<cfqueryparam value="#arguments.role.id#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.role.name#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.role.description#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#toString(arguments.role.preferences.exportSubtree())#" cfsqltype="CF_SQL_LONGVARCHAR" />)
			</cfquery>
			
			<!--- store the permissions too --->
			<cfloop list="#role.permissions#" index="permission">
				<cfquery name="q_insertPermissions"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				insert into #variables.prefix#role_permission(role_id, permission_id)
				values (
					<cfqueryparam value="#arguments.role.id#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#permission#" cfsqltype="CF_SQL_VARCHAR" />)
				</cfquery>
			</cfloop>
			<cfset returnObj["status"] = true/>
	
			<cfcatch type="Any">
				<cfset returnObj["status"] = false/>
				<cfset returnObj["message"] = CFCATCH.message & ": " & CFCATCH.detail/>
			</cfcatch>
		</cftry>
	
		<cfif returnObj["status"]>
			<cfset returnObj["message"] = "Role added"/>
			<cfset returnObj["data"] = arguments.role />
		</cfif>
	
		<cfreturn returnObj/>
		
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="update" output="false" hint="Updates a record" access="public" returntype="struct">
	<cfargument name="role" required="true" type="any" hint="Role object"/>

    <cfscript>
		var q_updateRole = "";
		var q_updateRolePermissions = "";
		var permission = "";
		var returnObj = structnew();
		returnObj["status"] = false;
		returnObj["message"] = "";
	</cfscript>

	<cftry>
		<!--- remove permissions first --->
		<cfquery name="q_updateRolePermissions"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			DELETE FROM #variables.prefix#role_permission			
			where role_id = <cfqueryparam value="#arguments.role.oldId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfquery name="q_updateRole"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
			update #variables.prefix#role
			set id = <cfqueryparam value="#arguments.role.id#" cfsqltype="CF_SQL_VARCHAR" />,
				name = <cfqueryparam value="#arguments.role.name#" cfsqltype="CF_SQL_VARCHAR" />,
				description = <cfqueryparam value="#arguments.role.description#" cfsqltype="CF_SQL_VARCHAR" />,
				preferences = <cfqueryparam value="#toString(arguments.role.preferences.exportSubtree())#" cfsqltype="CF_SQL_LONGVARCHAR" />
			where id = <cfqueryparam value="#arguments.role.oldId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<!--- store the permissions too --->
			<cfloop list="#role.permissions#" index="permission">
				<cfquery name="q_updateRolePermissions"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
				insert into #variables.prefix#role_permission(role_id, permission_id)
				values (
					<cfqueryparam value="#arguments.role.id#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#permission#" cfsqltype="CF_SQL_VARCHAR" />)
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
		<cfset returnObj["data"] = arguments.role />
	</cfif>

	<cfreturn returnObj/>
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="delete" output="false" access="public" returntype="void">
	<cfargument name="role" required="true" type="any">
	<cfset var q_deleteRole = "" />
	<cfset var q_updateRolePermissions = "" />
	
	<!--- delete the permissions --->
	<cfquery name="q_updateRolePermissions"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		DELETE FROM #variables.prefix#role_permission			
		where role_id = <cfqueryparam value="#arguments.role.id#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	
	<cfquery name="q_deleteRole"  datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		delete
		from role
		where id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.role.id#" />
	</cfquery>
	
</cffunction>

</cfcomponent>