<cfcomponent name="DataAccessFactory" hint="Hub for all components to get the object instances">

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="init" output="false" returntype="any" hint="instantiates an object of this class" access="public">
	<cfargument name="datasource" required="true" type="struct">
	
		<cfset variables.datasource = arguments.datasource />
		<cfset variables.dbtype = arguments.datasource.type />
			
		<cfreturn this />
</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getauthorManager" output="false" access="public" hint="Gets the manager of author"> 
	<cfset var obj = createObject("component","AuthorDAO") />
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getAuthorsGateway" output="false" access="public" hint="Gets the manager of author"> 
	<cfreturn createObject("component","AuthorGateway").init(variables.datasource)  />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getcategoryManager" output="false" access="public" hint="Gets the manager of category"> 
	<cfset var obj = createObject("component","CategoryDAO") />
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCategoriesGateway" output="false" access="public" hint="Gets the manager of category"> 
	<cfreturn createObject("component","CategoryGateway").init(variables.datasource)  />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCommentsManager" output="false" access="public" hint="Gets the manager of comment"> 
	<cfset var obj = "" />
		<cfset obj = createObject("component","CommentDAO") />
	
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCommentsGateway" output="false" access="public" hint="Gets the manager of comment"> 
	<cfset var obj = createObject("component","CommentGateway").init(variables.datasource)  />
	<cfreturn obj />	

</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPostManager" output="false" access="public" hint="Gets the manager of post"> 
	<cfset var obj = createObject("component","PostDAO") />
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPostsGateway" output="false" access="public" hint="Gets the manager of post"> 
	
	<cfreturn createObject("component","PostsGateway").init(variables.datasource)  />

</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPageManager" output="false" access="public" hint="Gets the manager of pages"> 
	<cfset var obj = createObject("component","PageDAO") />
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPagesGateway" output="false" access="public" hint="Gets the manager of post"> 
	<cfreturn createObject("component","PageGateway").init(variables.datasource)  />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getRoleManager" output="false" access="public" hint="Gets the manager of roles"> 
	<cfset var obj = createObject("component","RoleDAO") />
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getRolesGateway" output="false" access="public" hint="Gets the manager of post"> 

	<cfreturn createObject("component","RoleGateway").init(variables.datasource)  />

</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPermissionManager" output="false" access="public" hint="Gets the manager of permissions"> 
	<cfset var obj = createObject("component","PermissionDAO") />
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPermissionsGateway" output="false" access="public" hint="Gets the manager of permissions"> 

	<cfreturn createObject("component","PermissionGateway").init(variables.datasource)  />

</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getLogsManager" output="false" access="public"> 
	<cfset var obj = createObject("component","LogDAO") />
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getLogsGateway" output="false" access="public"> 
	<cfreturn createObject("component","LogGateway").init(variables.datasource)  />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getblogManager" output="false" access="public" hint="Gets the manager of blog"> 
	<cfset var obj = createObject("component","BlogDAO") />
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getblogGateway" output="false" access="public" hint="Gets the manager of blog"> 
	<cfreturn createObject("component","BlogGateway").init(variables.datasource)  />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getSettingsManager" output="false" access="public" hint="Gets the manager of settings"> 
	<cfset var obj = createObject("component","SettingDAO") />
	<cfset obj.init(variables.datasource) />
	<cfreturn obj />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getSettingsGateway" output="false" access="public" hint="Gets the manager of settings"> 
	<cfreturn createObject("component","SettingGateway").init(variables.datasource)  />
</cffunction>

</cfcomponent>