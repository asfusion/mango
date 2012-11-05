<cfcomponent>

<!--- use application to get to main Mango component --->
<cfset variables.blogManager = application.blogFacade.getMango() />
<cfset variables.administrator = variables.blogManager.getAdministrator() />

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="login" access="remote" output="false" returntype="boolean">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		
		<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
		<cfset var author = "" />
			
		<cfif isAuthor>
			<cfset author = variables.administrator.getAuthorByUsername(arguments.username) />
			<!--- save this authentication --->
			<cfset variables.blogManager.setCurrentUser(author) />
		</cfif>
			
		<cfreturn isAuthor />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPage" access="remote" output="false" hint="Throws 'PageNotFound'">
		<cfargument name="name" type="String" required="true" />
		
		<!--- get and return the page --->
		<cfreturn variables.blogManager.getPagesManager().getPageByName(arguments.name, variables.blogManager.isCurrentUserLoggedIn(), false) />
				
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getChildPages" access="remote" output="false" hint="Throws 'PageNotFound'">
		<cfargument name="name" type="String" required="true" />
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		
		<!--- get parent id --->
		<cfset var pageManager = variables.blogManager.getPagesManager() />
		<cfset var parent = pageManager.getPageByName(arguments.name, true, false) />
		<cfreturn pageManager.getPagesByParent(parent.id, arguments.from, arguments.count, variables.blogManager.isCurrentUserLoggedIn(), false) />
				
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPosts" access="remote" output="false" returntype="array">
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		
		<!--- get the posts --->
		<cfreturn variables.blogManager.getPostsManager().getPosts(arguments.from, arguments.count, variables.blogManager.isCurrentUserLoggedIn(), false) />
				
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPostsByCategory" access="remote" output="false" returntype="array">
		<cfargument name="category" required="true" type="string" hint="Category Name (alias). We also accept a comma delimited list."/>
		<cfargument name="match" required="false" default="any" type="string" hint="Whether to match any category in list (for multiple categories) or all"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		
		<cfreturn variables.blogManager.getPostsManager().getPostsByCategory(
					arguments.category, arguments.match, arguments.from, arguments.count, variables.blogManager.isCurrentUserLoggedIn(), false) />
				
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="broadcastEvent" access="remote" output="false" returntype="any">
		<cfargument name="event" required="true" type="any" />
		
		<cfset arguments.event.type = "RemoteEvent" />
		<!--- dispatch the event --->
		<cfreturn variables.blogManager.getPluginQueue().broadcastEvent(arguments.event) />
		
	</cffunction>

</cfcomponent>