<cfcomponent>
		
	<cfset variables.id = "">
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		
		<cfset variables.manager = arguments.mainManager />
		<cfreturn this/>
	</cffunction>

	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>

	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>

	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
	</cffunction>
	
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method: add scheduled task to reindex/optimize --->
		<cfreturn />
	</cffunction>

	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<!--- TODO: Implement Method: try to remove collections --->
		<cfreturn />
	</cffunction>

	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var post = "" />
		<cfset var searcher = variables.manager.getSearcher() />
		<cfset var i = ""/>
		<cfset var posts = "" />

			<cfswitch expression="#arguments.event.getName()#">
				
				<cfcase value="afterPostAdd,afterPostUpdate">
					<cfset post = arguments.event.getNewItem() />
					<cfset searcher.indexPost(post) />
				</cfcase>
				
				<cfcase value="afterPageAdd,afterPageUpdate">
					<cfset post = arguments.event.getNewItem() />					
					<cfset searcher.indexPage(post) />					
				</cfcase>
				
				<cfcase value="afterPostDelete">
					<cfset post = arguments.event.getoldItem() />					
					<cfset searcher.deletePost(post) />					
				</cfcase>
				
				<cfcase value="afterPageDelete">
					<cfset post = arguments.event.getoldItem() />					
					<cfset searcher.deletePage(post) />					
				</cfcase>
				
				<cfcase value="searchIndexer-reindex">
					<cfset posts = variables.manager.getPostsManager().getPosts(adminMode=true) />
					<cfloop from="1" to="#arraylen(posts)#" index="i">
						<cfset searcher.indexPost(posts[i]) />
					</cfloop>					
					
					<cfset posts = variables.manager.getPagesManager().getPages(adminMode=true) />
					<cfloop from="1" to="#arraylen(posts)#" index="i">
						<cfset searcher.indexPage(posts[i]) />
					</cfloop>	
					
					<cfset searcher.optimize() />
					
				</cfcase>
				
				<cfcase value="searchIndexer-optimize">
					<cfset searcher.optimize() />
				</cfcase>
				
			</cfswitch>
		
		<cfreturn />
	</cffunction>

	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfreturn arguments.event />
	</cffunction>
	

</cfcomponent>