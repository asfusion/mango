<cfcomponent name="AuthorManager">

	<cfset variables.accessObject = "">

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
			
			<cfset var factory = arguments.mainApp.getDataAccessFactory() />
			<cfset variables.accessObject = factory.getAuthorsGateway() />	
			<cfset variables.daoObject = factory.getAuthorManager()>
			<cfset variables.pluginQueue = arguments.mainApp.getPluginQueue() />
			<cfset variables.mainApp = arguments.mainApp />
			<cfset variables.objectFactory = variables.mainApp.getObjectFactory()>

		<cfreturn this />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthors" access="public" output="false" returntype="array">
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" />
		
		<cfset var authorsQuery = variables.accessObject.getAll(NOT arguments.adminMode) />
		<cfset var authors ="" />
		
		<cfset authors = packageObjects(authorsQuery, arguments.from, arguments.count, arguments.adminMode) />
		<cfreturn authors />
	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthorsByBlog" access="public" output="false" returntype="array">	
		<cfargument name="blogId" required="true" type="string" hint="Blog primary key"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" />
		
		<cfset var authorsQuery = variables.accessObject.getByBlog(arguments.blogId) />
		<cfset var authors ="" />
		
		<cfset authors = packageObjects(authorsQuery, arguments.from, arguments.count, arguments.adminMode) />
		<cfreturn authors />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthorsByKeyword" access="public" output="false" returntype="array">
		<cfargument name="keyword" required="true" type="string" default="" hint="Keyword"/>
		<cfargument name="blogId" required="false" default="" type="string" hint="Blog primary key"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" />
		
		<cfset var authorsQuery = variables.accessObject.getByKeyword(arguments.keyword, arguments.blogId) />
		
		<cfreturn packageObjects(authorsQuery, arguments.from, arguments.count, arguments.adminMode) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthorById" access="public" output="false" returntype="any">	
		<cfargument name="id" required="true" type="string" hint="Primary key"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include permission information"/>
		
		<cfset var aQuery = variables.accessObject.getById(arguments.id) />
		<cfset var authors =  packageObjects(aQuery,1, 0, arguments.adminMode)  />
		
		<cfif aQuery.recordcount>
			<cfreturn authors[1]/>
		<cfelse>
			<cfreturn variables.objectFactory.createAuthor() />
		</cfif>

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getAuthorByAlias" access="public" output="false" returntype="any">	
		<cfargument name="alias" required="true" type="string" />
		
		<cfset var aQuery = variables.accessObject.getByAlias(arguments.alias) />
		<cfset var authors =  packageObjects(aQuery)  />
		
		<cfif aQuery.recordcount>
			<cfreturn authors[1]/>
		<cfelse>
			<cfreturn variables.objectFactory.createAuthor() />
		</cfif>

	</cffunction>	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getAuthorByUsername" access="public" output="false" returntype="any">	
		<cfargument name="username" type="string" required="true" />
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include permission information"/>
		
		<cfset var authorQuery = variables.accessObject.getByUsername(arguments.username) />
		<cfset var authors =  packageObjects(authorQuery, 1, 0, arguments.adminMode)  />
		
		<cfif authorQuery.recordcount>
			<cfreturn authors[1]/>
		<cfelse>
			<cfreturn variables.objectFactory.createAuthor()  />
		</cfif>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="checkCredentials" access="public" output="false" returntype="boolean">	
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfset var authorQuery = variables.accessObject.getByUsername(arguments.username) />
		<cfreturn authorQuery.recordcount AND 
					authorQuery.password EQ hash(authorQuery.id & arguments.password,"SHA")
					AND authorQuery.active />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="checkSoftCredentials" access="public" output="false" returntype="boolean">	
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfset var authorQuery = variables.accessObject.getByUsername(arguments.username) />
		<cfreturn authorQuery.recordcount AND authorQuery.password EQ arguments.password />
	</cffunction>
	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="packageObjects" access="private" output="false" returntype="array">
		<cfargument name="objectsQuery" required="true" type="query">
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="includeBlogs" required="false" default="false" type="boolean"/>
		
		<cfset var authors = arraynew(1) />
		<cfset var thisObject = "" />
		<cfset var blog = "" />
		<cfset var currentBlog = variables.mainApp.getBlog() />
		<cfset var urlString = "" />
		<cfset var urlSetting = currentBlog.getSetting("authorUrl") />
		<cfset var archivesUrlSetting = currentBlog.getSetting("archivesUrl") />
		<cfset var roleManager = variables.mainApp.getRolesManager() />
		<cfset var friendlyUrls = currentBlog.getSetting("useFriendlyUrls") />
		<cfset var i = 0/>
		
		<cfif arguments.count EQ 0>
			<cfset arguments.count = objectsQuery.recordcount />
		</cfif>
		<cfoutput query="arguments.objectsQuery" group="id">
			<cfset i = i + 1 />
			
			<cfif i GTE arguments.from AND i LT (arguments.count + arguments.from)>
				<cfset thisObject = variables.objectFactory.createAuthor() />
				<cfset thisObject.init(id,username,password,name,email,description,shortdescription, picture, alias,active)  />
				<!--- set URL with setting from blog --->
				<cfset urlString = replacenocase(urlSetting,"{authorId}",id) />
				<cfset urlString = replacenocase(urlString,"{authorAlias}",alias) />
				<cfset thisObject.urlString = urlString  />
				<cfif friendlyUrls>
					<cfset thisObject.archivesUrlString = archivesUrlSetting & "author/" & alias />
				<cfelse>
					<cfset thisObject.archivesUrlString = archivesUrlSetting & alias />
				</cfif>
				<cfset thisObject.archivesUrlString = replacenocase(thisObject.archivesUrlString, "{archiveType}", "author","all") />
				
				<cfif arguments.includeBlogs>
					<cfoutput>
						<cfset blog = structnew() />
						<cfset blog.id = blog_id />
						<cfset blog.role = roleManager.getRoleById(role) />
						<cfset arrayappend(thisObject.blogs, blog) />
					</cfoutput>
				<cfelse>
					<cfoutput>
						<cfif currentBlog.id EQ blog_id>
							<cfset blog = structnew() />
							<cfset blog.id = blog_id />
							<cfset blog.role = roleManager.getRoleById(role) />
							<cfset arrayappend(thisObject.blogs, blog) />
						</cfif>
					</cfoutput>
				</cfif>
				<cfset arrayappend(authors,thisObject)>
			</cfif>
		</cfoutput>
		
		<cfreturn authors />
	</cffunction>
	
	<!---:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
<!--- Edit functions --->
	<cffunction name="addAuthor" access="public" output="false" returntype="struct">
		<cfargument name="author" required="true" type="any">
		<cfargument name="rawData" required="false" default="#structnew()#" type="struct">
			
			<cfscript>
				var thisObject = arguments.author;
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
				
				message.setType("author");
				
				if(NOT len(thisObject.getAlias())){
					thisObject.setAlias(util.makeCleanString(thisObject.getName()));				
				}
				
				//call plugins
				eventObj.author = thisObject;
				eventObj.rawdata = arguments.rawData;
					event = variables.pluginQueue.createEvent("beforeAuthorAdd",eventObj);
					event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getData().author;
				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();	
					if(valid.status){					
						newResult = variables.daoObject.store(thisObject);					
						
						
						if(newResult.status){
							status = "success";
							event = variables.pluginQueue.createEvent("afterAuthorAdd",thisObject);
							event = variables.pluginQueue.broadcastEvent(event);
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
		<cfset returnObj.newAuthor = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

	<cffunction name="editAuthor" access="public" output="false" returntype="struct">
		<cfargument name="author" required="true" type="any">
		<cfargument name="rawData" required="false" default="#structnew()#" type="struct">
			
			<cfscript>
				var thisObject = arguments.author;
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
				
				message.setType("author");

				
				//call plugins
				eventObj.author = thisObject;
				eventObj.rawdata = arguments.rawData;
					event = variables.pluginQueue.createEvent("beforeAuthorUpdate",eventObj);
					event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getData().author;
				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();	
					if(valid.status){					
						newResult = variables.daoObject.store(thisObject);					
												
						if(newResult.status){
							status = "success";
							event = variables.pluginQueue.createEvent("afterAuthorUpdate",thisObject);
							event = variables.pluginQueue.broadcastEvent(event);
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
		<cfset returnObj.author = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

</cfcomponent>