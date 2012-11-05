<cfcomponent name="PageManager">

	<cfset variables.accessObject = "">
	<cfset variables.mainApp = "" />
	<cfset variables.daoObject = "" />
	<cfset variables.pageNames = structnew() /><!--- ids as keys, names as values --->
	<cfset variables.pageIds = structnew() /><!--- names as keys, ids as values --->
	<cfset variables.childrenCache = createObject("component","utilities.Cache") />
	<cfset variables.itemsCache = createObject("component","utilities.Cache") />

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
			
			<cfset variables.factory = arguments.mainApp.getDataAccessFactory() />
			<cfset variables.accessObject = variables.factory.getPagesGateway() />		
			<cfset variables.mainApp = arguments.mainApp />
			<cfset variables.daoObject = variables.factory.getPageManager() />
			<cfset variables.pluginQueue = variables.mainApp.getPluginQueue() />
			<cfset variables.blogid = arguments.mainApp.getBlog().id />
			<cfset variables.objectFactory = variables.mainApp.getObjectFactory()>

		<cfreturn this />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPages" access="public" output="false" returntype="array">	
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the page wrapper"/>
		
		<cfset var pagesQuery = variables.accessObject.getAll(variables.blogid, arguments.adminMode) />

		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		<cfreturn packageObjects(pagesQuery, arguments.from, arguments.count, arguments.useWrapper, NOT arguments.adminMode) />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPagesByParent" access="public" output="false" returntype="array">
		<cfargument name="parent_page_id" required="true" type="string" hint="Parent page"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the page wrapper"/>
		
		<cfset var pagesQuery = "" />
		<cfset var pages = "" />
		<cfset var cacheresult = variables.childrenCache.checkAndRetrieve(arguments.parent_page_id)>		
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif cacheresult.contains>
			<cfset pagesQuery = cacheresult.value />
		<cfelse>
			<cfset pagesQuery = variables.accessObject.getByParent(arguments.parent_page_id,variables.blogid,arguments.adminMode) />
			<cfset variables.childrenCache.store(arguments.parent_page_id,pagesQuery) />
		</cfif>		
			
		<cfset pages = packageObjects(pagesQuery,arguments.from,arguments.count, arguments.useWrapper, NOT arguments.adminMode) />		
		
		<cfset eventObj.collection = pages />
		<cfset eventObj.query = pagesQuery />
		<cfset eventObj.arguments = arguments />	
		<cfset event = variables.pluginQueue.createEvent("getPagesByParent",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.collection />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPageByName" access="public" output="false" returntype="any">
		<cfargument name="name" required="true" type="string" hint="Name"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the page wrapper"/>
		
		<cfset var id = "" />
		<!--- sanitize input --->
		<cfset arguments.name = ReReplaceNoCase(arguments.name, "<[^>]*>", "", "ALL") />
		<cfset id = getPageIdFromCache(arguments.name,arguments.adminMode) />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<!--- let getById handle request --->
		<cfif id NEQ "">	
			<cftry>
				<cfreturn getPageById(id, arguments.adminMode, arguments.useWrapper) />
				
				<cfcatch type="PageNotFound">
					<cfthrow errorcode="PageNotFound" message="Page #arguments.name# was not found" type="PageNotFound">
				</cfcatch>
			</cftry>
		<cfelse>
			<!--- page not found --->
			<cfthrow errorcode="PageNotFound" message="Page #arguments.name# was not found" type="PageNotFound">
		</cfif>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPageById" access="public" output="false" returntype="any">
		<cfargument name="id" required="true" type="string" hint="Id"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the page wrapper"/>
		
		<!--- admin mode does not use cache --->
		<cfset var pagesQuery = "" />
		<cfset var pages = "" />
		<cfset var cacheresult = variables.itemsCache.checkAndRetrieve(arguments.id) />
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif NOT arguments.adminMode AND cacheresult.contains>
			<cfif arguments.useWrapper>
				<cfreturn createObject("component","PageWrapper").init(variables.pluginQueue, variables.objectFactory, cacheresult.value) />
			<cfelse>
				<cfreturn cacheresult.value />
			</cfif>
		<cfelse>
			<!--- not in cache, we must get it from db --->
			<cfset pagesQuery = variables.accessObject.getById(arguments.id,arguments.adminMode) />
			<cfset pages = packageObjects(pagesQuery,1,1, arguments.useWrapper, NOT arguments.adminMode) />
			<cfif NOT pagesQuery.recordcount>
				<cfthrow errorcode="PageNotFound" message="Page was not found" type="PageNotFound">
			</cfif>
			
			<cfset eventObj.collection = pages />
			<cfset eventObj.query = pagesQuery />
			<cfset eventObj.arguments = arguments />	
			<cfset event = variables.pluginQueue.createEvent("getPageById",eventObj,"Collection") />
			<cfset event = variables.pluginQueue.broadcastEvent(event) />
			
			<cfreturn pages[1] />
		</cfif>
		
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getPageCount" output="false" hint="Gets the number of posts" access="public" returntype="numeric">
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		
	<cfreturn variables.accessObject.getCount(variables.blogid, arguments.adminMode) />
</cffunction>

 <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPagesByAuthor" access="public" output="false" returntype="array">
		<cfargument name="author_id" required="true" type="string" hint="Author"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the page wrapper"/>
		
		<cfset var pagesQuery = variables.accessObject.getByAuthor(arguments.author_id,variables.blogid, arguments.adminMode) />
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfreturn packageObjects(pagesQuery,arguments.from,arguments.count, arguments.useWrapper, NOT arguments.adminMode) />		
		
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
<cffunction name="getPagesByCustomField" access="public" output="false" returntype="array">
		<cfargument name="customField" required="true" type="string" hint="Custom field key"/>
		<cfargument name="customFieldValue" required="false" default="" type="string" hint="Custom field value to match. If empty, then get all pages with that custom field key, regardless of value"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the post wrapper"/>
		
		<cfset var pagesQuery = variables.accessObject.getByCustomField(arguments.customField, arguments.customFieldValue, variables.blogid, arguments.adminMode) />

		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		<cfreturn packageObjects(pagesQuery, arguments.from, arguments.count, arguments.useWrapper, NOT arguments.adminMode) />

</cffunction>

 <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- 	search --->	
	<!--- <cffunction name="getPagesByKeyword" access="public" output="false" returntype="array">
		<cfargument name="keyword" required="true" type="string" default="" hint="Keyword"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the page wrapper"/>
		
		<cfset var pagesQuery = variables.accessObject.search(arguments.keyword) />
		<cfset var pages = packageObjects(pagesQuery,arguments.from,arguments.count) />			
		
		<cfreturn pages />
	</cffunction>	 --->		


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="pageAllowsComments" output="false" 
			hint="Determines whether a page allows adding comments to it. If page does not exist, it will return false" 
			access="public" returntype="boolean">
	<cfargument name="id" required="true" type="string" hint="Id"/>
	
	<cfset var allowed = false />
	<cfset var pagesQuery = variables.accessObject.getById(arguments.id, false) />
	<cfif pagesQuery.recordcount>
		<cfset allowed = pagesQuery.comments_allowed />
	</cfif>
	
	<cfreturn allowed />
</cffunction>


 <!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="packageObjects" access="private" output="false" returntype="array">
		<cfargument name="pagesQuery" required="true" type="query">
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="useWrapper" required="false" default="true" type="boolean" hint="Whether to use page wrapper"/>
		<cfargument name="useCache" required="false" type="boolean" hint="Whether to use the page cache"/>
		
		<cfset var pages = arraynew(1) />
		<cfset var thisPage = "" />
		<cfset var urlString = "" />
		<cfset var parent = 0 />
		<cfset var i = 0/>
		<cfset var thisid = "" />
		<cfset var hierarchyNames = "" />
		<cfset var wrappedPage = "" />
		<cfset var cacheCheck = "" />
		<cfset var createNewPage = true />
		<cfset var pageUrl = "" />
		<cfset var blogUrl = "" />
		<cfset var blog = "" />
		
		<cfif NOT structkeyexists(arguments, 'useCache')>
			<cfset arguments.useCache = arguments.useWrapper />
		</cfif>
		
		<cfif arguments.count EQ 0>
			<cfset arguments.count = pagesQuery.recordcount />
		</cfif>
		
		<cfif pagesQuery.recordcount>
			<cfset blog = variables.mainApp.getBlog() />
			<cfset pageUrl = blog.getSetting("pageUrl") />
			<cfset blogUrl = blog.getUrl() />
			
			<cfoutput query="arguments.pagesQuery" group="id">
				<cfset i = i + 1 />
				<cfset hierarchyNames = ""/>
				<cfset createNewPage = true />
				<cfif i GTE arguments.from AND i LT (arguments.count + arguments.from)>
					<!--- check the cache --->
					<cfif arguments.useCache>
						<cfset cacheCheck = variables.itemsCache.checkAndRetrieve(id) />
						<cfif cacheCheck.contains>
							<cfset thisPage = cacheCheck.value />
							<cfset createNewPage = false />
						</cfif>
					</cfif>
					
					<cfif createNewPage>
						<cfset thisPage = variables.objectFactory.createPage() />

						<cfif NOT len(parent_page_id)>
							<cfset parent = 0 />
						<cfelse>
							<cfset parent = parent_page_id />
						</cfif>
					
						<cfscript>
							thisPage.parentPageId = parent_page_id;
							thisPage.template = template;
							thisPage.hierarchy = hierarchy;
							thisPage.id = id;
							thisPage.name = name;
							thisPage.title = title;
							thisPage.content = content;
							thisPage.excerpt = excerpt;
							thisPage.authorId = author_id;
							thisPage.author = author;
							thisPage.commentsAllowed = comments_allowed;
							thisPage.status = status;
							thisPage.lastModified = last_modified;
							thisPage.commentCount = comment_count;
							thisPage.sortOrder = sort_order;
							thisPage.blogId = blog_id;
						</cfscript>
					
						<cfoutput group="field_id">
							<cfif len(field_id)>
								<cfset thisPage.customFields[field_id] = structnew() />
								<cfset thisPage.customFields[field_id]["key"] = field_id  />
								<cfset thisPage.customFields[field_id]["name"] = field_name  />
								<cfset thisPage.customFields[field_id]["value"] = field_value  />
								<!--- the above should have been done this way, but I am trying to avoid function calls to make it faster --->
								<!--- <cfset thisPage.setCustomField(field_id,field_name,field_value) /> --->
							</cfif>
						</cfoutput>
						
						<!--- replace hierarchy ids for names --->
						<cfloop list="#hierarchy#" index="thisid" delimiters="/">
							<cfset hierarchyNames = listappend(hierarchyNames,getPageNameFromCache(thisid),"/") />						
						</cfloop>
						
						<cfif len(hierarchyNames)>
							<cfset hierarchyNames = hierarchyNames & "/"/>
						</cfif>
						<!--- set URL with setting from blog --->
						<cfset urlString = replacenocase(replacenocase(replacenocase(pageUrl,"{pageid}",id),
									"{pageName}",name),
									"{pageHierarchyNames}",hierarchyNames) />
						
						<cfset thisPage.urlString = urlString />
						<cfset thisPage.permalink = blogUrl & urlString />
					</cfif>
					
					
					<cfif arguments.useWrapper>
						<cfset wrappedPage = createObject("component","PageWrapper").init(variables.pluginQueue, variables.objectFactory, thisPage) />
					<cfelse>
						<cfset wrappedPage = thisPage />
					</cfif>
					<cfif createNewPage AND arguments.useCache>
						<!--- store in cache (only if we are not in admin mode and we have not retrieved it from the cache already) --->
						<cfset variables.itemsCache.store(id,thisPage) />
					</cfif>
					
					<cfset arrayappend(pages,wrappedPage)>
				</cfif>
				
			</cfoutput>
		</cfif>
		<cfreturn pages />
	</cffunction>
	
<!---::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPageNameFromCache" access="private" output="false" returntype="string">
		<cfargument name="id" required="true" type="string" hint="Id"/>
		
		<cfset var pagesQuery = "" />		
		<cfif structkeyexists(variables.pageNames,arguments.id)>
			<cfreturn variables.pageNames[arguments.id] />
		<cfelse>
			<cfset pagesQuery = variables.accessObject.getById(arguments.id) />		
		
			<cfif pagesQuery.recordcount>
				<cfset variables.pageNames[arguments.id] = pagesQuery.name />
				<cfset variables.pageIds[pagesQuery.name] = arguments.id />
				<cfreturn pagesQuery.name />
			
			<cfelse>
				<cfreturn "" />
			</cfif>
		</cfif>
	</cffunction>

<!---::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPageIdFromCache" access="private" output="false" returntype="string">
		<cfargument name="name" required="true" type="string" hint="Name"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		
		<cfset var pagesQuery = "" />		
		<cfif structkeyexists(variables.pageIds,arguments.name)>
			<cfreturn variables.pageIds[arguments.name] />
		<cfelse>
			<cfset pagesQuery = variables.accessObject.getByName(arguments.name,variables.blogid, arguments.adminMode) />		
		
			<cfif pagesQuery.recordcount>
				<cfset variables.pageNames[pagesQuery.id] = arguments.name />
				<cfset variables.pageIds[arguments.name] = pagesQuery.id />
				<cfreturn pagesQuery.id />
			
			<cfelse>
				<cfreturn "" />
			</cfif>
		</cfif>
	</cffunction>

<!---::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
<!--- Edit functions --->
	<cffunction name="addPage" access="package" output="false" returntype="struct">
		<cfargument name="page" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any">
			
			<cfscript>
				var thisObject = arguments.page;
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
				
				message.setType("page");

				if(NOT len(thisObject.getName()) and thisObject.getStatus() is "published"){
					thisObject.setName(util.makeCleanString(thisObject.getTitle()));				
				}
				
				if (NOT structkeyexists(arguments,"user")){
					arguments.user = authorManager.getAuthorById(arguments.page.getAuthorId(),true);
				}
				
				//call plugins
				eventObj.page = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.newItem = arguments.page;
				eventObj.changeByUser = arguments.user;
				event = variables.pluginQueue.createEvent("beforePageAdd",eventObj,"Update");
				event.setMessage(message);
				event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getNewItem();
				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();	
					if(valid.status){					
						newResult = variables.daoObject.store(thisObject);					
						
						
						if(newResult.status){
							status = "success";
							event = variables.pluginQueue.createEvent("afterPageAdd",eventObj,"Update");
							event = variables.pluginQueue.broadcastEvent(event);
							thisObject = event.getNewItem();
							// @TODO: finish this list
							
							updateEvent('clear');
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
		<cfset returnObj.newPage = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

	<cffunction name="editPage" access="package" output="false" returntype="struct">
		<cfargument name="page" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any">
			
			<cfscript>
				var thisObject = arguments.page;
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
				
				message.setType("page");

				thisObject.setLastModified(now());				
				
				if(NOT len(thisObject.getName()) and thisObject.getStatus() is "published"){
					thisObject.setName(util.makeCleanString(thisObject.getTitle()));				
				}
				
				if (NOT structkeyexists(arguments,"user")){
					arguments.user = authorManager.getAuthorById(arguments.page.getAuthorId(),true);
				}
				
				//call plugins
				eventObj.page = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.newItem = arguments.page;
				eventObj.oldItem = getPageById(arguments.page.getId(),true);
				eventObj.changeByUser = arguments.user;

				event = variables.pluginQueue.createEvent("beforePageUpdate",eventObj,"Update");
				event.setMessage(message);
				event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getnewItem();
				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();	
					if(valid.status){					
						newResult = variables.daoObject.store(thisObject);					
						
						
						if(newResult.status){
							status = "success";
							event = variables.pluginQueue.createEvent("afterPageUpdate",eventObj,"Update");
							event = variables.pluginQueue.broadcastEvent(event);
							thisObject = event.getnewItem();
							// @TODO: finish this list
							
							updateEvent('clear');
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
		<cfset returnObj.newPage = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

	<cffunction name="deletePage" access="package" output="false" returntype="struct">
		<cfargument name="page" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any">
			
			<cfscript>
				var thisObject = arguments.page;
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
				
				message.setType("page");
			
				if (NOT structkeyexists(arguments,"user")){
					arguments.user = authorManager.getAuthorById(arguments.page.getAuthorId(),true);
				}
				
				//call plugins
				eventObj.page = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.oldItem = thisObject;
				eventObj.changeByUser = arguments.user;
				
				event = variables.pluginQueue.createEvent("beforePageDelete",eventObj,"Delete");
				event.setMessage(message);
				event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getoldItem();
				if(event.getContinueProcess()){
			
						newResult = variables.daoObject.delete(thisObject.getId());					
						
						
						if(newResult.status){
							status = "success";
							event = variables.pluginQueue.createEvent("afterPageDelete",eventObj,"Delete");
							event = variables.pluginQueue.broadcastEvent(event);
							thisObject = event.getoldItem();
							
							updateEvent('clear');
						}
						else{
							status = "error";
						}
						message.setStatus(status);
						message.setText(newResult.message);				
				}
			</cfscript>
		<cfset returnObj.data = rawData />	
		<cfset returnObj.oldPage = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editCustomField" access="package" output="false" returntype="any">
		<cfargument name="pageId" required="true" type="any">
		<cfargument name="customField" required="true" type="struct">
		
		<cfset var newResult = variables.daoObject.setCustomField(arguments.pageId,
													arguments.customField['key'], 
													arguments.customField['name'],
													arguments.customField['value'])	/>
		<cfset var returnObj = structnew()>
		<cfset var status = "success" />
		<cfset var message = createObject("component","Message")>
		
		<cfscript>
			if(newResult.status){
				variables.itemsCache.clear(arguments.pageId);
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

		<cffunction name="updateEvent" access="public" output="false" returntype="void">
		<cfargument name="event" type="String" required="true" />
			<cfset var obj = "" />
		
			<cfswitch expression="#listgetat(arguments.event,1,'|')#">
					<cfcase value="pageAdded">
						<cfset obj = getPageById(listgetat(arguments.event,2,"|")) />
						<cfset variables.childrenCache.clear(obj.getParentPageId()) />
					</cfcase>
					<cfcase value="pageUpdated">
						<cfset obj = getPageById(listgetat(arguments.event,2,"|")) />
						<cfset variables.childrenCache.clear(obj.getId()) />
						<cfset variables.itemsCache.clear(obj.getId()) />
						<cfset variables.childrenCache.clear(obj.getParentPageId()) />
					</cfcase>
					<cfcase value="pageDeleted">
						<cfset variables.childrenCache.clear(listgetat(arguments.event,2,"|")) />
						<cfset variables.itemsCache.clear(listgetat(arguments.event,2,"|")) />
					</cfcase>
					<cfdefaultcase>
						<cfset variables.childrenCache.clearAll() />
						<cfset variables.itemsCache.clearAll() />
					</cfdefaultcase>
				</cfswitch>
	</cffunction>
	
<!--- Cache management --->
<!---::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCache" access="public" output="false" returntype="any">
		<cfreturn variables.itemsCache />
	</cffunction>
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getChildrenCache" access="public" output="false" returntype="any">
		<cfreturn variables.childrenCache />
	</cffunction>		
</cfcomponent>