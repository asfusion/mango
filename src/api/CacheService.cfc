<cfcomponent>
	<!--- DO NOT USE APPLICATION SCOPE! --->
	<cfset variables.blogManager = application.blogFacade.getMango() />
	<cfset variables.administrator = variables.blogManager.getAdministrator() />
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCachedPosts" returntype="array" access="remote">
		
		<cfset var cachedEntries = variables.blogManager.getPostsManager().getCache().getStoredItems() />
		<cfset var posts = arraynew(1) />
		<cfset var post = "" />
		<cfset var newpost = "">
		
		<cfloop collection="#cachedEntries#" item="post">
			<cfset newpost = structnew() />
			<cfset newpost["title"] = cachedEntries[post].value.title />
			<cfset newpost["id"] = cachedEntries[post].value.id />
			<cfset newpost["entryType"] = "POST" />
			<cfset arrayappend(posts,newpost)>
		</cfloop>
		
		<cfreturn posts />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCachedPages" returntype="array" access="remote">
		<cfset var cachedEntries = variables.blogManager.getPagesManager().getCache().getStoredItems() />
		<cfset var posts = arraynew(1) />
		<cfset var post = "" />
		<cfset var newpost = "">
		
		<cfloop collection="#cachedEntries#" item="post">
			<cfset newpost = structnew() />
			<cfset newpost["title"] = cachedEntries[post].value.title />
			<cfset newpost["id"] = cachedEntries[post].value.id />
			<cfset newpost["entryType"] = "PAGE" />
			<cfset arrayappend(posts,newpost)>
		</cfloop>
		
		<cfreturn posts />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="clearPost" access="remote" returntype="boolean">
		<cfargument name="id" />
		<cfargument name="username" type="String" required="false" default="" />
		<cfargument name="password" type="String" required="false" default="" />
		
		<cfif (variables.blogManager.isCurrentUserLoggedIn() AND 
				listFind(variables.blogManager.getCurrentUser().getCurrentrole(variables.blogManager.getBlog().getId()).permissions, "access_admin"))
				OR variables.administrator.checkCredentials(arguments.username,arguments.password)>
			<cfset variables.blogManager.getPostsManager().getCache().clear(id)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="clearPage" access="remote" returntype="boolean">
		<cfargument name="id" />
		<cfargument name="username" type="String" required="false" default="" />
		<cfargument name="password" type="String" required="false" default="" />
		
		<cfif (variables.blogManager.isCurrentUserLoggedIn() AND 
		listFind(variables.blogManager.getCurrentUser().getCurrentrole(variables.blogManager.getBlog().getId()).permissions, "access_admin"))
				OR variables.administrator.checkCredentials(arguments.username,arguments.password)>
			<cfset variables.blogManager.getPagesManager().getCache().clear(id)>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="clearAll" access="remote" returntype="boolean">
		<cfargument name="username" type="String" required="false" default="" />
		<cfargument name="password" type="String" required="false" default="" />
		
		<cfset var pagesManager = variables.blogManager.getPagesManager() />
		<cfif (variables.blogManager.isCurrentUserLoggedIn() AND 
			listFind(variables.blogManager.getCurrentUser().getCurrentrole(variables.blogManager.getBlog().getId()).permissions, "access_admin"))
				OR variables.administrator.checkCredentials(arguments.username,arguments.password)>
			<cfset variables.blogManager.getPostsManager().getCache().clearAll() />
			<cfset pagesManager.getCache().clearAll() />
			<cfset pagesManager.getChildrenCache().clearAll() />
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="reloadConfig" access="remote" returntype="boolean">
		<cfargument name="username" type="String" required="false" default="" />
		<cfargument name="password" type="String" required="false" default="" />
		
		<cfif (variables.blogManager.isCurrentUserLoggedIn() AND 
				listFind(variables.blogManager.getCurrentUser().getCurrentrole(variables.blogManager.getBlog().getId()).permissions, "access_admin"))
				OR variables.administrator.checkCredentials(arguments.username,arguments.password)>
			<cfset variables.blogManager.reloadConfig() />
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
</cfcomponent>