<cfcomponent name="PostManager">

	<cfset variables.accessObject = "">
	<cfset variables.mainApp = "" />
	<cfset variables.daoObject = "" />
	<cfset variables.postIds = structnew() /><!--- names as keys, ids as values --->
	<cfset variables.itemsCache = createObject("component","utilities.Cache") />
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
			
			<cfset variables.factory = arguments.mainApp.getDataAccessFactory() />
			<cfset variables.accessObject = variables.factory.getPostsGateway() />		
			<cfset variables.mainApp = arguments.mainApp />
			<cfset variables.daoObject = variables.factory.getPostManager() />
			<cfset variables.pluginQueue = variables.mainApp.getPluginQueue() />
			<cfset variables.blogid = arguments.mainApp.getBlog().getId() />
			<cfset variables.objectFactory = variables.mainApp.getObjectFactory()>

		<cfreturn this />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="getPosts" access="public" output="false" returntype="array">	
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		<cfargument name="orderBy" required="false" type="string" default="DATE-DESC" hint="How to order the posts, defaults by DATE-DESC"/>
		
		<cfset var postsIds = variables.accessObject.getAllIds(variables.blogid,arguments.adminMode, arguments.orderBy) />
		<cfset var posts = "" />
		<cfset var ids = "" />
		<cfset var postsQuery = "" />
		<cfset var cached = "">
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif arguments.count EQ 0 AND postsIds.recordcount GT 0>
			<cfset arguments.count = postsIds.recordcount />
		<cfelseif arguments.count EQ 0>
			<cfset arguments.count = 1 />
		</cfif>
		
		<!--- if recorcount was 0, just return empty array --->
		<cfif postsIds.recordcount EQ 0>
			<cfreturn arraynew(1)/>
		</cfif>
		
		<!--- else, continue --->
		<cfoutput query="postsIds" startrow="#arguments.from#" maxrows="#arguments.count#">
			<cfset ids = listappend(ids,id) />
		</cfoutput>
		
		<cfset cached = getPostsFromCache(ids, arguments.useWrapper)/>
		<cfif arraylen(cached)><!--- meaning all posts were cached --->
			<cfset posts = cached />
		<cfelse>
			<!--- else, some posts were not cached,  make the full query --->
			<cfset postsQuery = variables.accessObject.getByIds(ids,querynew("key"),arguments.adminMode, arguments.orderBy) />
			<cfset posts = packageObjects(postsQuery,1,0, arguments.useWrapper, NOT arguments.adminMode) />
		</cfif>
		
		<cfset eventObj.collection = posts />
		<cfset eventObj.query = postsQuery />
		<cfset eventObj.arguments = arguments />	
		<cfset event = variables.pluginQueue.createEvent("getPosts",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.collection />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPostCount" output="false" hint="Gets the number of posts" access="public" returntype="numeric">
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		
	<cfreturn variables.accessObject.getCount(variables.blogid, arguments.adminMode) />
</cffunction>	

<!--- 	getByCategory --->
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="getPostsByCategory" access="public" output="false" returntype="array">
		<cfargument name="category" required="true" type="string" hint="Category Name (alias). We also accept a comma delimited list."/>
		<cfargument name="match" required="false" default="any" type="string" hint="Whether to match any category in list (for multiple categories) or all"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		
		<cfset var posts = "" />
		<cfset var ids = "" />
		<cfset var postsQuery = "" />
		<cfset var categoryIds = "" />
		<cfset var categoryManager = variables.mainApp.getCategoriesManager() />
		<cfset var postsIds = "" />
		<cfset var cached = "" />		
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		<cfset var categoryItem = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif listlen(arguments.category) EQ 1>
			<!--- normal case, only one category --->
			<cfset categoryIds = categoryManager.getCategoryByName(arguments.category, arguments.adminMode).getId() />
			<cfset postsIds = variables.accessObject.getIdsByCategory(categoryIds, variables.blogid, arguments.adminMode) />
		<cfelse>
			<!--- multiple categories, used by feeds --->
			<cfloop list="#arguments.category#" index="categoryItem">
				<cfset categoryIds = listappend(categoryIds,categoryManager.getCategoryByName(categoryItem, arguments.adminMode).getId())>
			</cfloop>
			<cfset postsIds = variables.accessObject.getIdsByMultiCategory(categoryIds, arguments.match, variables.blogid, arguments.adminMode) />
		</cfif>
		
		<cfif arguments.count GT 0>
			<cfoutput query="postsIds" startrow="#arguments.from#" maxrows="#arguments.count#">
				<cfset ids = listappend(ids,id) />
			</cfoutput>
		<cfelse>
			<cfset ids = valueList(postsIds.id) />			
		</cfif>
		
		<cfset cached = getPostsFromCache(ids, arguments.useWrapper)/>
		<cfif arraylen(cached)><!--- meaning all posts were cached --->
			<cfset posts = cached />
		<cfelse>
			<!--- else, some posts were not cached,  make the full query --->
			<cfif listlen(ids)>
				<cfset postsQuery = variables.accessObject.getByIds(ids,querynew("key"), arguments.adminMode) />
			<cfelse>
				<cfset postsQuery = querynew("id") />
			</cfif>
			<cfset posts = packageObjects(postsQuery,1,0, arguments.useWrapper, NOT arguments.adminMode) />
		</cfif>
		
		<cfset eventObj.collection = posts />
		<cfset eventObj.query = postsQuery />
		<cfset eventObj.arguments = arguments />
		<cfset event = variables.pluginQueue.createEvent("getPostsByCategory",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.collection />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPostCountByCategory" output="false" hint="Gets the number of posts with given category/categories" 
			access="public" returntype="numeric">
	<cfargument name="category" required="true" type="string" hint="Category Name (alias). We also accept a comma delimited list."/>
	<cfargument name="match" required="false" default="any" type="string" hint=""/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		
		<cfset var categoryItem = "" />
		<cfset var categoryIds = "" />
		<cfset var categoryManager = variables.mainApp.getCategoriesManager() />
		
		<cfloop list="#arguments.category#" index="categoryItem">
			<cfset categoryIds = listappend(categoryIds,categoryManager.getCategoryByName(categoryItem, arguments.adminMode).getId())>
		</cfloop>
		<cfreturn variables.accessObject.getCountByMultiCategory(categoryIds, arguments.match, variables.blogid, arguments.adminMode) />
</cffunction>

<!--- 	getByName --->
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="getPostByName" access="public" output="false" returntype="any">
		<cfargument name="name" required="true" type="string" hint="Name"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		
		<cfset var id = "" />
		<!--- sanitize input --->
		<cfset arguments.name = ReReplaceNoCase(arguments.name, "<[^>]*>", "", "ALL") />
		<cfset id = getPostIdFromCache(arguments.name, arguments.adminMode) />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif id NEQ "">
			<cftry>
				<!--- let getById handle request --->
				<cfreturn getPostById(id, arguments.adminMode, arguments.useWrapper) />
			
				<cfcatch type="PostNotFound">
					<cfthrow errorcode="PostNotFound" message="Post #arguments.name# was not found" type="PostNotFound">
				</cfcatch>
			</cftry>
		<cfelse>
			<!--- post not found --->
			<cfthrow errorcode="PostNotFound" message="Post #arguments.name# was not found" type="PostNotFound">
		</cfif>
	</cffunction>	
	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="getPostById" access="public" output="false" returntype="any">
		<cfargument name="id" required="true" type="string" hint="Id"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		
		<!--- admin mode does not use cache --->
		<cfset var postsQuery = "" />
		<cfset var posts = "" />
		<cfset var cacheresult = variables.itemsCache.checkAndRetrieve(arguments.id)>
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif NOT arguments.adminMode AND cacheresult.contains>
			<cfif arguments.useWrapper>
				<cfreturn createObject("component","PostWrapper").init(variables.pluginQueue, variables.objectFactory, cacheresult.value) />
			<cfelse>
				<cfreturn cacheresult.value />
			</cfif>
		<cfelse>
			<!--- not in cache, we must get it from db --->
			<cfset postsQuery = variables.accessObject.getById(arguments.id,arguments.adminMode) />
			<cfset posts = packageObjects(postsQuery,1,1, arguments.useWrapper, NOT arguments.adminMode)  />
			<cfif NOT postsQuery.recordcount>
				<cfthrow errorcode="PostNotFound" message="Post was not found" type="PostNotFound">
			</cfif>
			
			<cfset eventObj.collection = posts />
			<cfset eventObj.query = postsQuery />
			<cfset eventObj.arguments = arguments />	
			<cfset event = variables.pluginQueue.createEvent("getPostById",eventObj,"Collection") />
			<cfset event = variables.pluginQueue.broadcastEvent(event) />
			
			<cfreturn posts[1] />
		</cfif>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="getPostsByDate" access="public" output="false" returntype="array">
		<cfargument name="year" required="true" type="numeric" hint="Year"/>
		<cfargument name="month" required="true" type="numeric" hint="Month"/>
		<cfargument name="day" required="true" type="numeric" hint="Day"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		<cfset var postsQuery = variables.accessObject.getByDate(argumentCollection=arguments,blogid=variables.blogid) />
		<cfset var posts = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfset posts = packageObjects(postsQuery,arguments.from,arguments.count, arguments.useWrapper, NOT arguments.adminMode) />
		
		<cfset eventObj.collection = posts />
		<cfset eventObj.query = postsQuery />
		<cfset eventObj.arguments = arguments />	
		<cfset event = variables.pluginQueue.createEvent("getPostsByDate",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />		
		
		<cfreturn posts />
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="getPostsByCustomField" access="public" output="false" returntype="array">
		<cfargument name="customField" required="true" type="string" hint="Custom field key"/>
		<cfargument name="customFieldValue" required="false" default="" type="string" hint="Custom field value to match. If empty, then get all posts with that custom field key, regardless of value"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		<cfargument name="orderBy" required="false" type="string" default="DATE-DESC" hint="How to order the posts, defaults by DATE-DESC"/>
		
		<cfset var posts = "" />
		<cfset var ids = "" />
		<cfset var postsQuery = "" />
		<cfset var categoryIds = "" />
		<cfset var postsIds = "" />
		<cfset var cached = "" />		
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		<cfset var orderedPosts = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfset postsIds = variables.accessObject.getIdsByCustomField(arguments.customField, arguments.customFieldValue, variables.blogid, arguments.adminMode, arguments.orderBy) />
		
		<cfif arguments.count GT 0>
			<cfoutput query="postsIds" startrow="#arguments.from#" maxrows="#arguments.count#">
				<cfset ids = listappend(ids,id) />
			</cfoutput>
		<cfelse>
			<cfset ids = valueList(postsIds.id) />			
		</cfif>
		
		<cfset cached = getPostsFromCache(ids, arguments.useWrapper)/>
		<cfif arraylen(cached)><!--- meaning all posts were cached --->
			<cfreturn cached />
		</cfif>
		
		<cfif listlen(ids)>
			<cfset postsQuery = variables.accessObject.getByIds(ids,querynew("key"), arguments.adminMode, arguments.orderBy) />
		<cfelse>
			<cfset postsQuery = querynew("id") />
		</cfif>
		<cfset posts = packageObjects(postsQuery,1,0, arguments.useWrapper, NOT arguments.adminMode) />
		
		<cfset orderedPosts = arraynew(1) />
		<!--- if ordering by custom field, we need to re-order them --->
		<cfif findnocase('CUSTOMFIELD',arguments.orderBy) EQ 1>
			<cfloop list="#ids#" index="i">
				<cfloop from="1" to="#arraylen(posts)#" index="j">
					<cfif posts[j].getId() EQ i>
						<cfset arrayappend(orderedPosts, posts[j]) />
						<cfset arraydeleteat(posts,j) />
						<cfbreak />
					</cfif>
				</cfloop>
			</cfloop>
		<cfelse>
			<cfset orderedPosts = posts />
		</cfif>
		<cfset eventObj.collection = orderedPosts />
		<cfset eventObj.query = postsQuery />
		<cfset eventObj.arguments = arguments />
		<cfset event = variables.pluginQueue.createEvent("getPostsByCustomField",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn orderedPosts />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPostCountByDate" output="false" hint="Gets the number of posts in a given date" access="public" returntype="numeric">
	<cfargument name="year" required="true" type="numeric" hint="Year" />
	<cfargument name="month" required="true" type="numeric" hint="Month"/>
	<cfargument name="day" required="true" type="numeric" hint="Day"/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		
	<cfreturn variables.accessObject.getCountByDate(argumentCollection=arguments,blogid=variables.blogid) />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPostsByAuthor" access="public" output="false" returntype="array">
		<cfargument name="author_id" required="true" type="string" hint="Author"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		
		<cfset var posts = "" />
		<cfset var ids = "" />
		<cfset var postsQuery = "" />
		<cfset var categoryIds = "" />
		<cfset var postsIds = "" />
		<cfset var cached = "" />		
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfset postsIds = variables.accessObject.getIdsByAuthor(arguments.author_id, variables.blogid, arguments.adminMode) />
		
		<cfif arguments.count GT 0>
			<cfoutput query="postsIds" startrow="#arguments.from#" maxrows="#arguments.count#">
				<cfset ids = listappend(ids,id) />
			</cfoutput>
		<cfelse>
			<cfset ids = valueList(postsIds.id) />			
		</cfif>
		
		<cfset cached = getPostsFromCache(ids, arguments.useWrapper)/>
		<cfif arraylen(cached)><!--- meaning all posts were cached --->
			<cfreturn cached />
		</cfif>
		
		<cfif listlen(ids)>
			<cfset postsQuery = variables.accessObject.getByIds(ids,querynew("key"), arguments.adminMode) />
		<cfelse>
			<cfset postsQuery = querynew("id") />
		</cfif>
		<cfset posts = packageObjects(postsQuery,1,0, arguments.useWrapper, NOT arguments.adminMode) />
		
		<cfset eventObj.collection = posts />
		<cfset eventObj.query = postsQuery />
		<cfset eventObj.arguments = arguments />
		<cfset event = variables.pluginQueue.createEvent("getPostsByAuthor",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn posts />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPostCountByAuthor" output="false" hint="Gets the number of posts by a given author" 
			access="public" returntype="numeric">
	<cfargument name="author_id" required="true" type="string" hint="Author"/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		
	<cfreturn variables.accessObject.getCountByAuthor(argumentCollection=arguments,blogid=variables.blogid) />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPostsByIds" access="public" output="false" returntype="array">
		<cfargument name="ids" required="true" type="string" hint="IDs"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		
		<cfset var posts = "" />
		<cfset var newIds = "" />
		<cfset var postsQuery = "" />
		<cfset var status = "" />
		<cfset var postsIds = "" />
		<cfset var cached = "" />		
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif arguments.adminMode>
			<cfset status = 'published' />
		</cfif>
		
		<!--- make sure we don't retrieve posts that are drafts if we are not admins --->
		<cfset postsIds = variables.accessObject.getIdsByStatus(status, arguments.ids, variables.blogid, arguments.adminMode) />
		
		<cfif arguments.count GT 0>
			<cfoutput query="postsIds" startrow="#arguments.from#" maxrows="#arguments.count#">
				<cfset newIds = listappend(newIds,id) />
			</cfoutput>
		<cfelse>
			<cfset newIds = valueList(postsIds.id) />			
		</cfif>
		
		<cfset cached = getPostsFromCache(newIds, arguments.useWrapper)/>
		<cfif arraylen(cached)><!--- meaning all posts were cached --->
			<cfreturn cached />
		</cfif>
		
		<cfif listlen(newIds)>
			<cfset postsQuery = variables.accessObject.getByIds(newIds,querynew("key"), arguments.adminMode) />
		<cfelse>
			<cfset postsQuery = querynew("id") />
		</cfif>
		<cfset posts = packageObjects(postsQuery,1,0, arguments.useWrapper, NOT arguments.adminMode) />
		
		<cfset eventObj.collection = posts />
		<cfset eventObj.query = postsQuery />
		<cfset eventObj.arguments = arguments />
		<cfset event = variables.pluginQueue.createEvent("getPostsByIds",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn posts />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="getPostsByStatus" access="public" output="false" returntype="array">
		<cfargument name="status" required="true" type="string" hint=""/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		
		<cfset var postsIds = variables.accessObject.getAllIds(variables.blogid,arguments.adminMode) />
		<cfset var posts = "" />
		<cfset var ids = "" />
		<cfset var postsQuery = "" />
		<cfset var cached = "">
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif arguments.count EQ 0 AND postsIds.recordcount GT 0>
			<cfset arguments.count = postsIds.recordcount />
		<cfelseif arguments.count EQ 0>
			<cfset arguments.count = 1 />
		</cfif>
		
		<!--- if recorcount was 0, just return empty array --->
		<cfif postsIds.recordcount EQ 0>
			<cfreturn arraynew(1)/>
		</cfif>
		
		<!--- else, continue --->
		<cfoutput query="postsIds" startrow="#arguments.from#" maxrows="#arguments.count#">
			<cfset ids = listappend(ids,id) />
		</cfoutput>
		
		<cfset cached = getPostsFromCache(ids, arguments.useWrapper)/>
		<cfif arraylen(cached)><!--- meaning all posts were cached --->
			<cfreturn cached />
		</cfif>
		
		<!--- else, some posts were not cached,  make the full query --->
		<cfset postsQuery = variables.accessObject.getByIds(ids,querynew("key"),arguments.adminMode) />
		<cfset posts = packageObjects(postsQuery,1,0, arguments.useWrapper, NOT arguments.adminMode) />
		
		<cfset eventObj.collection = posts />
		<cfset eventObj.query = postsQuery />
		<cfset eventObj.arguments = arguments />	
		<cfset event = variables.pluginQueue.createEvent("getPosts",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn posts />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPostsByKeyword" access="public" output="false" returntype="array">
		<cfargument name="keyword" required="true" type="string" default="" hint="Keyword"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		
		<cfset var postsQuery =  ""/>
		<cfset var posts =  ""/>		
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<!--- @TODO implement a better way to deal with verity problems --->
		<cftry>
			<cfset postsQuery = variables.mainApp.getSearcher().searchPosts(keyword,'','',variables.blogid) />
			<cfif postsQuery.recordcount>
				<cfset postsQuery = variables.accessObject.getByIds("",postsQuery,arguments.adminMode) />
			</cfif>		
			
			<cfcatch type="any">
				<cfset postsQuery = variables.accessObject.getIdsByKeyword(keyword,variables.blogid,arguments.adminMode) />
				<cfset postsQuery = variables.accessObject.getByIds(idslist=valueList(postsQuery.id),adminMode=arguments.adminMode) />
			</cfcatch>
		</cftry>
		
		<cfif postsQuery.recordcount>
			<cfset posts = packageObjects(postsQuery,arguments.from,arguments.count, arguments.useWrapper, NOT arguments.adminMode) />
		<cfelse>
			<cfset posts = arraynew(1) />
		</cfif>		
				
		<cfset eventObj.collection = posts />
		<cfset eventObj.query = postsQuery />
		<cfset eventObj.arguments = arguments />	
		<cfset event = variables.pluginQueue.createEvent("getPostsByKeyword",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />	
		
		<cfreturn posts />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPostCountByKeyword" output="false" hint="Gets the number of posts in a given date" access="public" returntype="numeric">
	<cfargument name="keyword" required="true" type="string" default="" hint="Keyword"/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
	
	<!--- @TODO implement a better way to deal with verity problems --->
	<cfset var postsQuery =  ""/>
	<cftry>
		<cfset postsQuery = variables.mainApp.getSearcher().searchPosts(keyword) />
		
		<cfif postsQuery.recordcount AND NOT adminMode>
			<!--- if we are not in admin mode, remove drafts --->
			<cfset postsQuery = variables.accessObject.getByIds("",postsQuery,arguments.adminMode) />
		</cfif>
		
		<cfcatch type="any">
			<cfset postsQuery = variables.accessObject.getIdsByKeyword(keyword,variables.blogid,arguments.adminMode) />			
		</cfcatch>
	</cftry>
	
	<cfreturn postsQuery.recordcount/>
</cffunction>		
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="packageObjects" access="private" output="false" returntype="array">
		<cfargument name="postsQuery" required="true" type="query">
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="useWrapper" required="false" default="true" type="boolean" hint="Whether to use post wrapper"/>
		<cfargument name="useCache" required="false" type="boolean" hint="Whether to use the page cache"/>
		
		<cfset var posts = arraynew(1) />
		<cfset var thisPost = "" />
		<cfset var categories = "" />
		<cfset var category = "" />
		<cfset var urlString = "" />
		<cfset var parent = 0 />
		<cfset var i = 0/>
		<cfset var categoryManager = variables.mainApp.getCategoriesManager() />
		<cfset var wrappedPost = "" />
		<cfset var cacheCheck = "" />
		<cfset var createNewPost = true />
		<cfset var postUrl = "">
		<cfset var blogUrl = "">

		<cfif arguments.count EQ 0>
			<cfset arguments.count = postsQuery.recordcount />
		</cfif>

		<cfif NOT structkeyexists(arguments, 'useCache')>
			<cfset arguments.useCache = arguments.useWrapper />
		</cfif>

		<cfif postsQuery.recordcount>
			<cfset postUrl = variables.mainApp.getBlog().getSetting("postUrl") />
			<cfset blogUrl = variables.mainApp.getBlog().getUrl() />
		
			<cfoutput query="arguments.postsQuery" group="id">
				<cfset i = i + 1 />
				<cfset createNewPost = true />
				<cfif i GTE arguments.from AND i LT (arguments.count + arguments.from)>
				
					<!--- check the cache --->
					<cfif arguments.useCache>
						<cfset cacheCheck = variables.itemsCache.checkAndRetrieve(id) />
						<cfif cacheCheck.contains>
							<cfset thisPost = cacheCheck.value />
							<cfset createNewPost = false />
						</cfif>
					</cfif>
					
				<!--- only do all this if we are creating a new post object --->
				<cfif createNewPost>
					<cfset thisPost = variables.objectFactory.createPost() />

					<!--- populate the array with categories --->
					<cfset categories = arraynew(1) />
					<cfoutput group="category_id">
						<cfif len(category_id)>			
							 <!--- I can do this only because I know that categoryManager is caching categories, otherwise, this would be crazy --->
							 <cftry>
						 		<cfset category = categoryManager.getCategoryById(category_id, true) />
						 		<cfset arrayappend(categories, category) />
							 	<cfcatch type="CategoryNotFound"></cfcatch>
							 </cftry>
						</cfif>
					</cfoutput>
							
					<cfscript>
						thisPost.id = id;
						thisPost.name = name;
						thisPost.title = title;
						thisPost.content = content;
						thisPost.excerpt = excerpt;
						thisPost.authorId = author_id;
						thisPost.author = author;
						thisPost.commentsAllowed = comments_allowed;
						thisPost.status = status;
						thisPost.lastModified = last_modified;
						thisPost.commentCount = comment_count;
						thisPost.postedOn = posted_on;
						thisPost.blogId = blog_id;
					</cfscript>
					
					<cfset thisPost.categories = categories />
					
					<cfoutput group="field_id">
						<cfif len(field_id)>
							<cfset thisPost.customFields[field_id] = structnew() />
							<cfset thisPost.customFields[field_id]["key"] = field_id  />
							<cfset thisPost.customFields[field_id]["name"] = field_name  />
							<cfset thisPost.customFields[field_id]["value"] = field_value  />
							<!--- the above should have been done this way, but I am trying to avoid function calls to make it faster --->
							<!--- <cfset thisPost.setCustomField(field_id,field_name,field_value) /> --->
						</cfif>
					</cfoutput>
					
					<!--- set URL with setting from blog --->
					<cfset urlString = replacenocase(replacenocase(postUrl,"{postid}",id),"{postName}",name) />
					
					<cfset thisPost.urlString = urlString />
					<cfset thisPost.permalink = blogUrl & urlString />
				</cfif>
				
				<cfif arguments.useWrapper>
					<cfset wrappedPost = createObject("component","PostWrapper").init(variables.pluginQueue, variables.objectFactory, thisPost) />
				<cfelse>
					<cfset wrappedPost = thisPost />
				</cfif>
				<cfif createNewPost AND arguments.useCache>
					<!--- store in cache (only if we are not in admin mode and we have not retrieved it from the cache already) --->
					<cfset variables.itemsCache.store(id,thisPost) />
				</cfif>
				
				<cfset arrayappend(posts,wrappedPost)>
			</cfif>

			</cfoutput>
		</cfif>
		<cfreturn posts />
	</cffunction>

<!---::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPostsFromCache" access="private" output="false" returntype="array">
		<cfargument name="ids" required="true" type="string" hint="list of ids"/>
		<cfargument name="useWrapper" required="false" default="true" type="boolean" hint="Whether to use post wrapper"/>
		
		<cfset var id = ""/>
		<cfset var cacheCheck = ""/>
		<cfset var posts = arraynew(1) />
		<cfset var thisPost = "">
		
		<cfloop list="#arguments.ids#" index="id">
			<cfset cacheCheck = variables.itemsCache.checkAndRetrieve(id) />
			<cfif cacheCheck.contains>
				<cfif arguments.useWrapper>
					<cfset thisPost = createObject("component","PostWrapper").init(variables.pluginQueue, variables.objectFactory, cacheCheck.value) />
				<cfelse>
					<cfset thisPost = cacheCheck.value />
				</cfif>

				<cfset arrayappend(posts,thisPost)>
			<cfelse>
				<cfreturn arraynew(1)/>
			</cfif>
		</cfloop>
		
		<cfreturn posts/>
		
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPostIdFromCache" access="private" output="false" returntype="string">
		<cfargument name="name" required="true" type="string" hint="Name"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		
		<cfset var id = "" />		
		<cfif structkeyexists(variables.postIds,arguments.name)>
			<cfreturn variables.postIds[arguments.name] />
		<cfelse>
			<cfset id = variables.accessObject.getIdByName(arguments.name, variables.blogid, arguments.adminMode) />		
		
			<cfif len(id)>
				<cfset variables.postIds[arguments.name] = id />
			</cfif>
			<cfreturn id />
		</cfif>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="postAllowsComments" output="false" 
			hint="Determines whether a post allows adding comments to it. If post does not exist, it will return false" 
			access="public" returntype="boolean">
	<cfargument name="id" required="true" type="string" hint="Id"/>
	
	<cfset var allowed = false />
	<cfset var postsQuery = variables.accessObject.getById(arguments.id, false) />
	<cfif postsQuery.recordcount>
		<cfset allowed = postsQuery.comments_allowed />
	</cfif>
	
	<cfreturn allowed />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
<!--- Edit functions --->
	<cffunction name="addPost" access="package" output="false" returntype="struct">
		<cfargument name="post" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any">
		
			<cfscript>
				var local = structnew();
				var thisObject = arguments.post;
				var authorManager = variables.mainApp.getAuthorsManager();
				var valid = "";
				var event = "";
				var newResult = "";
				var message = createObject("component","Message");
				var status = "";
				var returnObj = structnew();
				var msgText = "";
				var eventObj = structnew();
				var data = structnew();
				var util = createObject("component","Utilities");
				var i = 0;
				
				message.setType("post");
				
				if (NOT structkeyexists(arguments,"user")){
					arguments.user = authorManager.getAuthorById(arguments.post.getAuthorId(),true);
				}
				
				//call plugins
				eventObj.post = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.newItem = arguments.post;
				eventObj.changeByUser = arguments.user;
				event = variables.pluginQueue.createEvent("beforePostAdd",eventObj,"Update");
				event.setMessage(message);
				event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getNewItem();
				
				if(NOT len(thisObject.getName()) and thisObject.getStatus() is "published"){
					thisObject.setName(util.makeCleanString(thisObject.getTitle()));				
				}
				
				if(NOT isdate(thisObject.getPostedOn())){
					thisObject.setPostedOn(now());				
				}
				
				
				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();
					if(valid.status){					
						newResult = variables.daoObject.create(thisObject);					
						
						if(newResult.status){
							local.list = arraynew(1);
							local.categories = thisObject.getCategories();
							//save the categories
							for (i = 1; i LTE arraylen(local.categories); i = i + 1) {
								arrayappend(local.list, local.categories[i].getId()); 
							}
							setPostCategories(thisObject.getId(), local.list);
							
							status = "success";
							event = variables.pluginQueue.createEvent("afterPostAdd",eventObj,"Update");
							event = variables.pluginQueue.broadcastEvent(event);
							thisObject = event.getNewItem();
						}
						else{
							status = "error";
						}
						message.setStatus(status);
						message.setText(newResult.message);
					}
					else {
						for (i = 1; i LTE arraylen(valid.errors);i=i+1){
							msgText = msgText & "<br />" & valid.errors[i];
						}
						message.setStatus("error");
						message.setText(msgText);
					}
				}
			</cfscript>
		<cfset returnObj.data = rawData />	
		<cfset returnObj.newPost = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

	<cffunction name="editPost" access="package" output="false" returntype="struct">
		<cfargument name="post" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any">
			
			<cfscript>
				var local = structnew();
				var thisObject = arguments.post;
				var authorManager = variables.mainApp.getAuthorsManager();
				var valid = "";
				var event = "";
				var newResult = "";
				var message = createObject("component","Message");
				var status = "";
				var returnObj = structnew();
				var msgText = "";
				var eventObj = structnew();
				var data = structnew();
				var i = 0;
				var util = createObject("component","Utilities");
				var oldItem = getPostById(arguments.post.getId(),true);
				
				message.setType("post");
				thisObject.setLastModified(now());
				
				if (NOT structkeyexists(arguments,"user")){
					arguments.user = authorManager.getAuthorById(arguments.post.getAuthorId(),true);
				}
				
				//call plugins
				eventObj.post = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.newItem = arguments.post;
				eventObj.oldItem = oldItem;
				eventObj.changeByUser = arguments.user;

				event = variables.pluginQueue.createEvent("beforePostUpdate",eventObj,"Update");
				event.setMessage(message);
				event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getnewItem();
				
				if(NOT len(thisObject.getName()) and thisObject.getStatus() is "published"){
					thisObject.setName(util.makeCleanString(thisObject.getTitle()));				
				}		
				
				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();	
					if(valid.status){					
						newResult = variables.daoObject.store(thisObject);					
						
						if(newResult.status){
							local.list = arraynew(1);
							local.categories = thisObject.getCategories();
							//save the categories
							for (i = 1; i LTE arraylen(local.categories); i = i + 1) {
								arrayappend(local.list, local.categories[i].getId()); 
							}
							setPostCategories(thisObject.getId(), local.list);
							
							status = "success";
							event = variables.pluginQueue.createEvent("afterPostUpdate",eventObj,"Update");
							event = variables.pluginQueue.broadcastEvent(event);
							thisObject = event.getnewItem();
						}
						else{
							status = "error";
						}
						message.setStatus(status);
						message.setText(newResult.message);
					}
					else {
						for (i = 1; i LTE arraylen(valid.errors);i=i+1){
							msgText = msgText & "<br />" & valid.errors[i];
						}
						message.setStatus("error");
						message.setText(msgText);
					}
				}
				
				variables.itemsCache.clearAll();
			</cfscript>
		<cfset returnObj.data = rawData />	
		<cfset returnObj.post = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePost" access="package" output="false" returntype="struct">
		<cfargument name="post" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any">
			
			<cfscript>
				var thisObject = arguments.post;
				var authorManager = variables.mainApp.getAuthorsManager();
				var valid = "";
				var event = "";
				var newResult = "";
				var message = createObject("component","Message");
				var status = "";
				var returnObj = structnew();
				var msgText = "";
				var eventObj = structnew();
				var data = structnew();
				
				message.setType("post");
				
				if (NOT structkeyexists(arguments,"user")){
					arguments.user = authorManager.getAuthorById(arguments.post.getAuthorId(),true);
				}
			
				//call plugins
				eventObj.post = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.oldItem = thisObject;
				eventObj.changeByUser = arguments.user;
				
				event = variables.pluginQueue.createEvent("beforePostDelete",eventObj,"Delete");
				event.setMessage(message);
				event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getoldItem();
				
				if(event.getContinueProcess()){
			
						newResult = variables.daoObject.delete(thisObject.getId());					
						
						if(newResult.status){
							status = "success";
							event = variables.pluginQueue.createEvent("afterPostDelete",eventObj,"Delete");
							event = variables.pluginQueue.broadcastEvent(event);
							thisObject = event.getoldItem();
						}
						else{
							status = "error";
						}
						message.setStatus(status);
						message.setText(newResult.message);				
				}
				variables.itemsCache.clearAll();
			</cfscript>
		<cfset returnObj.data = rawData />	
		<cfset returnObj.newPost = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setPostCategories" access="package" output="false" returntype="struct">
		<cfargument name="postId" type="String" required="true" />
		<cfargument name="categories" type="array" required="true" />
		
		<cfset var newResult = variables.daoObject.setCategories(arguments.postId,arguments.categories)	 />		
		<cfset var returnObj = structnew()>
		<cfset var status = "" />
		<cfset var message = createObject("component","Message")>
		
		<cfscript>
			if(newResult.status){
				status = "success";
				variables.itemsCache.clearAll();
			}
			else{
				status = "error";
			}
			message.setStatus(status);
			message.setText(newResult.message);		
		</cfscript>
		<cfset returnObj.data = arguments />	
		<cfset returnObj.message = message />
		<cfreturn returnObj />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editCustomField" access="package" output="false" returntype="any">
		<cfargument name="postId" required="true" type="any">
		<cfargument name="customField" required="true" type="struct">
		
		<cfset var newResult = variables.daoObject.setCustomField(arguments.postId,
													arguments.customField['key'], 
													arguments.customField['name'],
													arguments.customField['value'])	/>
		<cfset var returnObj = structnew()>
		<cfset var status = "success" />
		<cfset var message = createObject("component","Message")>
		
		<cfscript>
			if(newResult.status){
				variables.itemsCache.clear(arguments.postId);
			}
			else{
				status = "error";
			}
			message.setStatus(status);
			message.setText(newResult.message);		
		</cfscript>
		<cfset returnObj.data = arguments />	
		<cfset returnObj.message = message />
		<cfreturn returnObj />
		
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="updateEvent" access="public" output="false" returntype="void">
		<cfargument name="event" type="String" required="true" />
		
			<cfswitch expression="#listgetat(arguments.event,1,'|')#">
				<cfcase value="postAdded">
					<!--- we don't need to do anything --->
				</cfcase>
				<cfcase value="postUpdated">
					<!--- clear object from cache --->
					<cfset variables.itemsCache.clear(listgetat(arguments.event,2,"|")) />
				</cfcase>
				<cfcase value="postDeleted">
					<cfset variables.itemsCache.clear(listgetat(arguments.event,2,"|")) />
				</cfcase>
				<cfdefaultcase>
					<cfset variables.itemsCache.clearAll() />
				</cfdefaultcase>
			</cfswitch>
	</cffunction>			
	

<!--- Cache management --->
<!---::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCache" access="public" output="false" returntype="any">
		<cfreturn variables.itemsCache />
	</cffunction>

</cfcomponent>