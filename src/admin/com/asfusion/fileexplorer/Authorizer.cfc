<cfcomponent>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCurrentUser" output="false" access="remote" returntype="struct">
 		
		<cfset var user = createObject("component", "model.User").init() />
		<cfset var result = structnew()/>
		<cfset var key = '' />
		<cfset var canManageFiles = listfind(request.blogManager.getCurrentUser().getCurrentRole(request.blogManager.getBlog().getId()).permissions, "manage_files") GT 0 />

		<cfset result["status"] = true />
		<!--- simplify user into an structure so that web services can function --->
		<cfset result["user"] = structnew() />
		<cfset result["user"]["permissions"] = user.permissions />
		<cfloop collection="#result['user']['permissions']#" item="key">
			<cfset result['user']['permissions'][key] = javacast("boolean",canManageFiles) />
		</cfloop>
		<cfset result["user"]["allowedDirectories"] = user.allowedDirectories />
		
		<cfreturn result />
	</cffunction>

</cfcomponent>