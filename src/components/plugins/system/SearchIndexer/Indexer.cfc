<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset this.events =
		[ { 'name' = 'afterPostAdd', 'type' = 'async', 'priority' = '5' },
	{ 'name' = 'afterPageAdd', 'type' = 'async', 'priority' = '5' },
	{ 'name' = 'afterPostUpdate', 'type' = 'async', 'priority' = '5' },
	{ 'name' = 'afterPageUpdate', 'type' = 'async', 'priority' = '5' },
	{ 'name' = 'afterPostDelete', 'type' = 'async', 'priority' = '5' },
	{ 'name' = 'afterPageDelete', 'type' = 'async', 'priority' = '5' },
	{ 'name' = 'searchIndexer-reindex', 'type' = 'async', 'priority' = '5' },
	{ 'name' = 'searchIndexer-optimize', 'type' = 'async', 'priority' = '5' }
		] />

	<cfset variables.id = "">
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		
		<cfset variables.manager = arguments.mainManager />
		<cfreturn this/>
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