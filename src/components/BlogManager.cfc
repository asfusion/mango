<cfcomponent name="BlogManager">
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
			<cfset variables.mainApp = arguments.mainApp />
			<cfset variables.blogGateway = variables.mainApp.getDataAccessFactory().getblogGateway() />
			<cfset variables.blogDao = variables.mainApp.getDataAccessFactory().getblogmanager() />
			<cfset variables.objectFactory = variables.mainApp.getObjectFactory()>
		<cfreturn this />
	</cffunction>


<cffunction name="getBlogs" output="false" hint="Gets all the records" access="public" returntype="array">

	<cfset var blog =  "" />
	<cfset var blogsQuery = variables.blogGateway.getAll() />
	<cfset var blogs = arraynew(1) />

		<cfoutput query="blogsQuery">
			<cfscript>
				blog = variables.objectFactory.createBlog();
				blog.setId(id);
				blog.setTitle(title);
				blog.setUrl(urlString);
				blog.setDescription(description);
				blog.setTagline(tagline);
				blog.setSkin(skin);
				blog.setBasePath(basepath);
				blog.setCharset(charset);
				blog.setPlugins(plugins);
				blog.setSystemPlugins(systemPlugins);
				arrayappend(blogs,blog);
			</cfscript>
		</cfoutput>

	<cfreturn blogs />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getBlogsByAuthor" output="false" hint="Gets the blogs for which a given user has access to" access="public" returntype="array">
	<cfargument name="author_id" required="true" type="string" hint="Author key"/>
	
	<cfset var blog =  "" />
	<cfset var blogsQuery = variables.blogGateway.getByAuthor(arguments.author_id) />
	<cfset var blogs = arraynew(1) />
		
		<cfoutput query="blogsQuery">
			<cfscript>
				blog = variables.objectFactory.createBlog();
				blog.setId(id);
				blog.setTitle(title);
				blog.setUrl(urlString);
				blog.setDescription(description);
				blog.setTagline(tagline);
				blog.setSkin(skin);
				blog.setBasePath(basepath);
				blog.setCharset(charset);
				blog.setPlugins(plugins);
				blog.setSystemPlugins(systemPlugins);
				arrayappend(blogs,blog);
			</cfscript>
		</cfoutput>

	<cfreturn blogs />
</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getBlog" access="public" output="false" returntype="any">
		<cfargument name="id" required="false" default="default" type="string" hint="Primary key"/>
		<cfargument name="config"  required="false" default="#structnew()#" type="struct" hint="Various configuration settings"/>

		<cfset var blog = variables.objectFactory.createBlog() />
		<cfset var settings = variables.blogGateway.getByID(arguments.id) />
		
		<cfoutput query="settings" maxrows="1">
			<cfscript>
				blog.setId(id);
				blog.setTitle(title);
				blog.setUrl(urlString);
				blog.setDescription(description);
				blog.setTagline(tagline);
				blog.setSkin(skin);
				blog.setBasePath(basepath);
				blog.setCharset(charset);
				blog.setPlugins(plugins);
				blog.setSystemPlugins(systemPlugins);
				blog.setSettings(arguments.config);				
			</cfscript>
		</cfoutput>
		
		
		<cfreturn blog />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="activatePlugin" access="public" output="false" returntype="any">
		<cfargument name="blogId" required="false" default="default" type="string" hint="Primary key"/>
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="pluginId" type="string" required="false" default="" />
		<cfargument name="type" required="true" default="user" hint="system or user">
		
		<cfset var message = createObject("component","Message") />
		<cfset var result = variables.blogDao.addPlugin(arguments.blogId, arguments.plugin, arguments.type) />
		
		<cfif result>
			<cfset message.setText("Plugin activated") />
		<cfelse>
			<cfset message.setStatus("error") />
			<cfset message.setText("Plugin was already active") />
		</cfif>
		
		<cfreturn message />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deActivatePlugin" access="public" output="false" returntype="any">
		<cfargument name="blogId" required="false" default="default" type="string" hint="Primary key"/>
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="pluginId" type="string" required="true" />
		<cfargument name="type" required="true" default="user" hint="system or user">
		
		<cfset var message = createObject("component","Message") />
		<cfset var result = variables.blogDao.removePlugin(arguments.blogId, arguments.plugin, arguments.type) />
		
		<cfif result>
			<cfset message.setText("Plugin de-activated") />
		<cfelse>
			<cfset message.setStatus("error") />
			<cfset message.setText("Plugin was not active") />
		</cfif>
		
		<cfreturn message />
	</cffunction>

<!--- @TODO add events to this function --->
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="addBlog" access="public" output="false" returntype="any">
		<cfargument name="blog" required="true" type="any" />
		<cfargument name="config" required="false" default="#structnew()#" type="struct" hint="Various configuration settings"/>
		
		<cfset var result = variables.blogDao.create(arguments.blog) />
		
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editBlog" access="public" output="false" returntype="any">
		<cfargument name="blog" required="true" type="any" />
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="config" required="false" default="#structnew()#" type="struct" hint="Various configuration settings"/>
		<cfargument name="user" required="false" type="any">
		
		<cfscript>
				var thisObject = arguments.blog;
				var valid = "";
				var event = "";
				var newResult = "";
				var message = createObject("component","Message");
				var status = "";
				var returnObj = structnew();
				var msgText = "";
				var eventObj = structnew();
				var data = structnew();
				var pluginQueue = variables.mainApp.getPluginQueue();
				var i = 0;
				
				message.setType("blog");
				
				eventObj.blog = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.newItem = arguments.blog;
				eventObj.oldItem = getBlog(arguments.blog.getId());
				eventObj.changeByUser = arguments.user;

				event = pluginQueue.createEvent("beforeBlogUpdate",eventObj,"Update");
				event = pluginQueue.broadcastEvent(event);
			
				thisObject = event.getnewItem();

				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();	
					if(valid.status){					
						newResult = variables.blogDao.update(thisObject);					
						
						
						if(newResult.status){
							status = "success";
							event = pluginQueue.createEvent("afterBlogUpdate",eventObj,"Update");
							event = pluginQueue.broadcastEvent(event);
							thisObject = event.getnewItem();
							
							variables.mainApp.reloadConfig();
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
		<cfset returnObj.blog = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />

	</cffunction>

</cfcomponent>