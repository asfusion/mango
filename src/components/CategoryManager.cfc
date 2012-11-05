<cfcomponent name="CategoryManager">

	<cfset variables.cache = structnew() />
	<cfset variables.idsCache = structnew() />

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
			<cfset var factory = arguments.mainApp.getDataAccessFactory() />
			<cfset variables.accessObject = factory.getCategoriesGateway()>
			<cfset variables.mainApp = arguments.mainApp />
			<cfset variables.daoObject = factory.getcategoryManager()>
			<cfset variables.blogid = arguments.mainApp.getBlog().getId() />
			<cfset variables.objectFactory = variables.mainApp.getObjectFactory()>
			<cfset variables.pluginQueue = variables.mainApp.getPluginQueue() />

		<cfreturn this />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCategories" access="public" output="false" returntype="array">
		<cfargument name="orderBy" required="false" default="name" type="string" hint="Options: name, count"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include only categories with posts"/>
		
		<cfset var categoriesQuery = variables.accessObject.getAll(variables.blogid,arguments.adminMode) />
		<cfset var postsQuery = variables.accessObject.getPostCount(variables.blogid,arguments.adminMode) />
		<cfset var categories ="" />
		<cfset var eventObj =  structnew() />
		<cfset var event = "" />
		
			<!--- join with post count --->
			<cfquery name="categoriesQuery" dbtype="query">
				SELECT    *
				FROM categoriesQuery, postsQuery
				WHERE categoriesQuery.id = postsQuery.category_id
				<cfif NOT arguments.adminMode>
					AND post_count > 0
				</cfif>
				ORDER BY <cfif arguments.orderBy EQ "name">name<cfelseif arguments.orderBy EQ "count">post_count<cfelse>#arguments.orderBy#</cfif>
			</cfquery>
	
		<cfset categories = packageObjects(categoriesQuery) />
		
		<cfset eventObj.collection = categories />
		<cfset eventObj.query = categoriesQuery />
		<cfset eventObj.arguments = arguments />	
		<cfset event = variables.pluginQueue.createEvent("getCategories",eventObj,"Collection") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.collection />
	</cffunction>
	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCategoryByName" access="public" output="false" returntype="any" hint="Returns model.Category object">	
		<cfargument name="name" required="true" type="string" hint="Category Name (alias)"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include only categories with posts"/>
		
		<cfset var categoriesQuery = "" />
		<cfset var postsQuery = "" />
		<cfset var categories = arraynew(1) />
		
		<!--- check the cache first --->
		<cfif structkeyexists(variables.idsCache,arguments.name) AND structkeyexists(variables.cache,variables.idsCache[arguments.name])>
			<!--- use cached --->
			<cfset categories[1] = variables.cache[variables.idsCache[arguments.name]] />
		<cfelse>
			<!--- not in cache, make query --->		
			<cfset categoriesQuery = variables.accessObject.getByName(arguments.name,variables.blogid) />
			<cfset postsQuery = variables.accessObject.getPostCount(variables.blogid,arguments.adminMode) />
			
			<!--- join with post count --->
			<cfquery name="categoriesQuery" dbtype="query">
				SELECT    * 
				FROM categoriesQuery, postsQuery
				WHERE categoriesQuery.id = postsQuery.category_id
				<cfif NOT arguments.adminMode>
					AND post_count > 0
				</cfif>
				ORDER BY name
			</cfquery>
			
			<cfset categories = packageObjects(categoriesQuery) />
		</cfif>
		
		<cfif arraylen(categories)>
			<cfreturn categories[1] />
		<cfelse>
			<cfthrow errorcode="CategoryNotFound" message="Category was not found" type="CategoryNotFound">
		</cfif>
		
	</cffunction>	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCategoryById" access="public" output="false" returntype="any" hint="Returns model.Category object">	
		<cfargument name="id" required="true" type="string" hint="Category Name (alias)"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include only categories with posts"/>
		
		<cfset var categoriesQuery = "" />
		<cfset var postsQuery = "" />
		<cfset var categories = arraynew(1) />
		<!--- sanitize input --->
		<cfset arguments.id = ReReplaceNoCase(arguments.id, "<[^>]*>", "", "ALL") />
		
		<!--- check the cache first --->
		<cfif structkeyexists(variables.cache,arguments.id)>
			<!--- use cached --->
			<cfset categories[1] = variables.cache[arguments.id] />
		<cfelse>
		
			<cfset categoriesQuery = variables.accessObject.getByID(arguments.id, variables.blogid) />
			<cfset postsQuery = variables.accessObject.getPostCount(variables.blogid,arguments.adminMode) />
	
			<!--- join with post count --->
			<cfquery name="categoriesQuery" dbtype="query">
				SELECT    * 
				FROM categoriesQuery, postsQuery
				WHERE categoriesQuery.id = postsQuery.category_id
				<cfif NOT arguments.adminMode>
					AND post_count > 0
				</cfif>
				ORDER BY name
			</cfquery>
			
			<cfset categories = packageObjects(categoriesQuery) />
		</cfif>
		
		<cfif arraylen(categories)>
			<cfreturn categories[1] />
		<cfelse>
			<cfthrow errorcode="CategoryNotFound" message="Category '#arguments.id#' was not found" type="CategoryNotFound">
		</cfif>
		
	</cffunction>		
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="packageObjects" access="private" output="false" returntype="array">
		<cfargument name="objectsQuery" required="true" type="query">
		
		<cfset var categories = arraynew(1) />
		<cfset var thisObject = "" />
		<cfset var urlString = ""/>
		
		<cfoutput query="arguments.objectsQuery">
			<cfset thisObject = variables.objectFactory.createCategory() />
			<cfset thisObject.init(id,name,title,description,created_on,post_count)  />
			<cfset urlString = replacenocase(replacenocase(variables.mainApp.getBlog().getSetting("categoryUrl"),"{categoryId}",id),"{categoryName}",name) />
				
			<cfset thisObject.setUrl(urlString) />
			<!--- store it in cache --->
			<cfset variables.cache[id] = thisObject />
			<cfset variables.idsCache[name] = id />
			<cfset arrayappend(categories,thisObject)>
		</cfoutput>
		
		<cfreturn categories />
	</cffunction>
	

<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
<!--- Edit functions --->
	<cffunction name="addCategory" access="public" output="false" returntype="struct">
		<cfargument name="category" required="true" type="any">
		<cfargument name="rawData" required="false" default="#structnew()#" type="struct">
			
			<cfscript>
				var thisObject = arguments.category;
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
				var pluginQueue = variables.mainApp.getPluginQueue();
				var i = 0;
				
				message.setType("category");
				
				if(NOT len(thisObject.getName())){
					thisObject.setName(util.makeCleanString(thisObject.getTitle()));				
				}
				
				if(NOT isdate(thisObject.getCreationDate())){
					thisObject.setCreationDate(now());				
				}
				
				//call plugins
				eventObj.category = thisObject;
				eventObj.rawdata = arguments.rawData;
				event = pluginQueue.createEvent("beforeCategoryAdd",eventObj);
				event = pluginQueue.broadcastEvent(event);
			
				thisObject = event.getData().category;
				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();	
					if(valid.status){					
						newResult = variables.daoObject.store(thisObject);					
						
						
						if(newResult.status){
							status = "success";
							event = pluginQueue.createEvent("afterCategoryAdd",thisObject);
							event = pluginQueue.broadcastEvent(event);
							thisObject = event.getData();
							// @TODO: finish this list
							
							variables.accessObject.refresh(thisObject.getblogId());
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
		<cfset returnObj.newCategory = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>	

	<cffunction name="editCategory" access="public" output="false" returntype="struct">
		<cfargument name="category" required="true" type="any">
		<cfargument name="rawData" required="false" default="#structnew()#" type="struct">
			
			<cfscript>
				var thisObject = arguments.category;
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
				var pluginQueue = variables.mainApp.getPluginQueue();
				var i = 0;
				var oldItem = getCategoryById(arguments.category.getId(),true);
				
				message.setType("category");
				
				if (oldItem.getName() EQ thisObject.getName()) {
					//change the name if user has not attempted to change it (guess it)
					thisObject.setName(util.makeCleanString(thisObject.getTitle()));	
				}
				
				//call plugins
				eventObj.category = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.oldItem = oldItem;
				eventObj.newItem = thisObject;
				
				event = pluginQueue.createEvent("beforeCategoryUpdate",eventObj,"Update");
				event = pluginQueue.broadcastEvent(event);
			
				thisObject = event.getData().category;
				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();	
					if(valid.status){					
						newResult = variables.daoObject.store(thisObject);
						
						
						if(newResult.status){
							status = "success";
							event = pluginQueue.createEvent("afterCategoryUpdate",thisObject,"Update");
							event = pluginQueue.broadcastEvent(event);
							
							//refresh data
							variables.accessObject.refresh(thisObject.getblogId());
							variables.mainApp.getPostsManager().updateEvent("categoryUpdated");
							
							thisObject = event.getData();
							// @TODO: finish this list
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
		<cfset returnObj.category = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteCategory" access="package" output="false" returntype="struct">
		<cfargument name="category" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any">
			
			<cfscript>
				var thisObject = arguments.category;
				var event = "";
				var newResult = "";
				var message = createObject("component","Message");
				var status = "";
				var returnObj = structnew();
				var msgText = "";
				var eventObj = structnew();
				var data = structnew();
				var pluginQueue = variables.mainApp.getPluginQueue();
				
				message.setType("category");
				
				//call plugins
				eventObj.comment = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.oldItem = thisObject;
				eventObj.changeByUser = arguments.user;
				
				event = pluginQueue.createEvent("beforeCategoryDelete",eventObj,"Delete");
				event = pluginQueue.broadcastEvent(event);
			
				thisObject = event.getoldItem();
				if(event.getContinueProcess()){
			
						newResult = variables.daoObject.delete(thisObject.getId());				
						
						//refresh data
						variables.accessObject.refresh(thisObject.getblogId());
						
						if(newResult.status){
							status = "success";
							event = pluginQueue.createEvent("afterCategoryDelete",eventObj,"Delete");
							event = pluginQueue.broadcastEvent(event);
							thisObject = event.getoldItem();
							
							variables.mainApp.getPostsManager().updateEvent("categoryUpdated");
						}
						else{
							status = "error";
						}
						message.setStatus(status);
						message.setText(newResult.message);				
				}
			</cfscript>
		<cfset returnObj.data = rawData />	
		<cfset returnObj.comment = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>
	
</cfcomponent>