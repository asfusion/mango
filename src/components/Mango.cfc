<cfcomponent name="Mango">

	<cfset variables.blog = "" />
	<cfset variables.version = "1.6" />
	<cfset variables.pluginQueue = "" />
	<cfset variables.config = "" />
	<cfset variables.blogId = "default" />
	<cfset variables.preferences = structnew() />
	<cfset variables.settings = structnew() />
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="configFile" required="false" type="string" default="" hint="Path to config file"/>
		<cfargument name="id" required="false" default="default" type="string" hint="Blog"/>
		<cfargument name="baseDirectory" required="false" type="string" hint="Path to main blog directory" />			
		
			<cfset var settings = "" />
			<cfset var blogSettings = structnew() />
			<cfset var preferences = createObject("component", "utilities.PreferencesFile")/>
			
			<cfset variables.config = arguments.configFile/>
			<cfset variables.blogId = arguments.id />
			<cfset variables.settings["baseDirectory"] = arguments.baseDirectory />
			

			<!--- check for the config file --->
			<cfif fileexists(variables.config)>
				<cfset preferences.init(variables.config)/>
			<cfelse>
				<cfthrow type="MissingConfigFile" errorcode="MissingConfigFile" detail="Configuration file could not be read">
			</cfif>
			
	 	<cfscript>
	 		variables.objectFactory = createobject("component","ObjectFactory");
			
			settings = preferences.exportSubtreeAsStruct("");
			variables.settings["datasource"] = settings.generalSettings.dataSource;
			variables.dataAccessFactory = createobject("component","model.dataaccess.DataAccessFactory").init(variables.settings["dataSource"]);		
			
			//get all other settings from database
			settingsManager = createObject("component","SettingManager").init(this, variables.dataAccessFactory);
			
			//get global settings
			settings = settingsManager.exportSubtreeAsStruct("system","");
			
			//overwrite global settings by any blog-specific setting
			structBlend(settings, settingsManager.exportSubtreeAsStruct("system",variables.blogId));
			
			if (settings.engine.enableThreads EQ "1") {
				variables.pluginQueue = createObject("component","PluginQueueThreaded");
			}
			else {
				variables.pluginQueue = createObject("component","PluginQueue");
			}
			
			settings.plugins.directory = replaceDirectoryPlaceHolders(settings.plugins.directory);

			//replace the {baseDirectory} variable
		 	settings.assets.directory = replaceDirectoryPlaceHolders(settings.assets.directory);
		 	settings.skins.directory = replaceDirectoryPlaceHolders(settings.skins.directory);
		 	
		 	variables.settings["authorization"] = settings.authorization;
		 	variables.settings["mailServer"] = settings.mail;
		 	
	 		variables.blogManager = createobject("component","BlogManager").init(this);
			
			blogSettings['assets'] = settings.assets;
			blogSettings['skins'] = settings.skins;
			blogSettings['plugins'] = settings.plugins;
			blogSettings['urls'] = settings.urls;
			structBlend(blogSettings, settings.urls);
			
			variables.blog = variables.blogManager.getBlog(variables.blogId, blogSettings);		
			variables.blog.setSetting("pluginsDir", settings.plugins.directory);
			variables.blog.setSetting("pluginsPath", settings.plugins.path);
			
			variables.postsManager = createobject("component","PostManager").init(this);
			variables.categoriesManager = createobject("component","CategoryManager").init(this);
			variables.rolesManager = createobject("component","RoleManager").init(this,variables.dataAccessFactory,variables.pluginQueue);
			variables.archivesManager = createobject("component","ArchivesManager").init(this,variables.dataAccessFactory);
			variables.authorsManager = createobject("component","AuthorManager").init(this);
			variables.pagesManager = createobject("component","PageManager").init(this);
			variables.commentsManager = createobject("component","CommentManager").init(this,variables.dataAccessFactory,variables.pluginQueue);
			
			variables.logsManager = createobject("component","LogManager").init(this, variables.dataAccessFactory);
			
			variables.logger = createobject("component","utilities.Logger");
			variables.logger.setLevel(settings.engine.logging.level);
			//add default handler
			variables.logger.addHandler(variables.logsManager);
			
			//add custom handler, if any
			if (structkeyexists(settings.engine.logging,"component")) {
				try {
					variables.logger.addHandler(createobject("component",
							settings.engine.logging.component).init(settings.engine.logging.settings,variables.blogId));
				}
				catch (var e) {}
			}
			
			variables.pluginQueue.init(variables.logger);
			
			try {
				variables.searcher = createobject("component", settings.search.component).init(settings.search.settings, 'en', variables.blogId);
			}
			catch (var e) {}
			
			variables.preferences["plugins"] = createObject("component","SettingManager").init(this, variables.dataAccessFactory);
			
			loadPlugins(settings.plugins.directory,settings.plugins.path);
		</cfscript>
		
		
		<cfreturn this />
	</cffunction>

	<!--- this method gets called every time a page is rendered.
	It is used to put variables into scope
	 --->
	<cffunction name="parseVariables" access="private" output="true" returntype="struct">		
		<cfargument name="urlvars" type="struct" required="false" />
		<cfargument name="formvars" type="struct" required="false" />
		
		<cfscript>
			var basePath = variables.blog.getBasePath();
			var returnData = structnew();
			var seoUrl = "";
			var externalData = structnew();
			externalData.raw = arraynew(1);
			if (isDefined("CGI.path_info")) {
				seoUrl = CGI.path_info;
			} 
 			externalData.raw = listtoarray(seoUrl,"/");
 			
 			/* default request.postContext variable */
 			returnData.postContext = "recent";
 			
 			/* default request.message variable */
 			returnData.message = createObject("component","Message");
 			
 			/* Add url variables */
 			structappend(externalData,arguments.urlVars,true);
 			
 			/* Add form variables */
 			structappend(externalData,arguments.formvars,true);
 			
 			returnData.externalData = externalData;
		</cfscript>
		
		<cfreturn returnData />
	</cffunction>

	<!--- this function handles special requests such as comment posting or form post that requires plugin intervention --->
	<cffunction name="handleRequest" access="public" output="true" returntype="struct">		
		<cfargument name="targetPage" type="String" required="true" />
		<cfargument name="urlvars" type="struct" required="false" />
		<cfargument name="formvars" type="struct" required="false" />
				
		<cfset var results = parseVariables(arguments.urlvars,arguments.formvars)>		
		<cfset var temp = "" />

			<!--- look for action key  --->
			<cfif structkeyexists(results.externaldata,"action") AND results.externaldata.action EQ "addComment">
					<cfset temp = variables.commentsManager.addCommentFromRawData(results.externaldata) />
					<cfset structappend(results.externaldata,temp.data)/>
					<cfset results.message = temp.message />
					<cfset results.newcomment = temp.newcomment />
			</cfif>	
				
			<cfif structkeyexists(results.externaldata,"event")>
				<cfset temp = structnew() />
				<!--- data sent to the plugin should be the external data --->
				<cfset temp = duplicate(results.externaldata) />
				<!--- add the external data structure in the case the plugin wants to change something --->
				<cfset temp.externaldata = results.externaldata />
				<!--- for backwards compatibility, leave the message --->
				<cfset temp.message = results.message />
				<cfset variables.pluginQueue.broadcastEvent(variables.pluginQueue.createEvent(results.externaldata.event,temp, "Request", results.message))/>
			</cfif>

		<cfreturn results />
	</cffunction>


	<cffunction name="getBlog" access="public" output="false" returntype="any">		
		<cfreturn variables.blog />
	</cffunction>
	
	<cffunction name="getBlogsManager" access="public" output="false" returntype="any">		
		<cfreturn variables.blogManager />
	</cffunction>
		
	<cffunction name="getPostsManager" access="public" output="false" returntype="any">		
		<cfreturn variables.postsManager />
	</cffunction>

	<cffunction name="getPagesManager" access="public" output="false" returntype="any">		
		<cfreturn variables.pagesManager />
	</cffunction>

	<cffunction name="getCategoriesManager" access="public" output="false" returntype="any">		
		<cfreturn variables.categoriesManager />
	</cffunction>

	<cffunction name="getCommentsManager" access="public" output="false" returntype="any">		
		<cfreturn variables.commentsManager />
	</cffunction>

	<cffunction name="getArchivesManager" access="public" output="false" returntype="any">		
		<cfreturn variables.archivesManager />
	</cffunction>

	<cffunction name="getAuthorsManager" access="public" output="false" returntype="any">		
		<cfreturn variables.authorsManager />
	</cffunction>
	
	<cffunction name="getRolesManager" access="public" output="false" returntype="any">		
		<cfreturn variables.rolesManager />
	</cffunction>
	
	<cffunction name="getLogsManager" access="public" output="false" returntype="any">		
		<cfreturn variables.logsManager />
	</cffunction>
	
	<cffunction name="getSettingsManager" access="public" output="false" returntype="any">		
		<cfreturn variables.preferences["plugins"] />
	</cffunction>

	<cffunction name="getSearcher" access="public" output="false" returntype="any">		
		<cfreturn variables.searcher />
	</cffunction>

	<cffunction name="getDataAccessFactory" access="package" output="false" returntype="any">		
		<cfreturn variables.dataAccessFactory />
	</cffunction>

	<cffunction name="getObjectFactory" access="public" output="false" returntype="any">		
		<cfreturn variables.objectFactory />
	</cffunction>

	<cffunction name="getPlugin" access="public" output="false" returntype="any">
		<cfargument name="name" type="any" hint="Name of plugin" required="false" />
			
			<cfreturn variables.pluginQueue.getPlugin(arguments.name) />
	</cffunction>

	<cffunction name="getPluginQueue" access="public" output="false" returntype="any">
		<cfreturn variables.pluginQueue />
	
	</cffunction>
	
	<cffunction name="getAdministrator" access="public" output="false" returntype="any">
		<cfif NOT structkeyexists(variables,'adminUtil')>
			<cfset variables.adminUtil = createObject("component", "AdminUtil").init(this) />
		</cfif>
		<cfreturn variables.adminUtil />
	</cffunction>
	
	<cffunction name="getAuthorizer" access="public" output="false" returntype="any">
		<cfreturn createObject("component", "Authorizer").init(this, variables.settings['authorization']) />	
	</cffunction>

	<cffunction name="getUpdater" access="public" output="false" returntype="any">
		<cfreturn createObject("component", "Updater").init(this, variables.config, variables.settings["baseDirectory"]) />	
	</cffunction>

	<cffunction name="getMailer" access="public" output="false" returntype="any">
		<cfreturn createObject("component", "utilities.Mailer").init(argumentCollection=variables.settings["mailServer"]) />	
	</cffunction>
	
	<cffunction name="getLogger" access="public" output="false" returntype="any">
		<cfreturn variables.logger />	
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getQueryInterface" access="public" output="false" returntype="any">
		<cfreturn createObject("component", "utilities.QueryInterface").init(variables.settings["datasource"]) />	
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="reloadConfig" access="public" output="false" returntype="void">
		<cfset var facade = createobject("component", "MangoFacade") />
		<!--- this creates a new mango instance and sets it as the default instance --->
		<cfset facade.setMango(createobject("component", "Mango").init(
				variables.config, variables.blogId, variables.settings["baseDirectory"]), variables.blogId) />
		<!--- just so that current request also gets the new config, init this instance too --->
		<cfset init(variables.config, variables.blogId, variables.settings["baseDirectory"]) />
	</cffunction>
		

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="loadPlugins" access="private" output="false" returntype="void">
		<cfargument name="pluginsDir" type="String" required="true" />
		<cfargument name="pluginsPath" type="String" required="false" default="plugins." />
		
		<cfset CreateObject("component", "PluginLoader").loadPlugins(variables.blog.systemPlugins,variables.pluginQueue,
					arguments.pluginsDir & "system/",arguments.pluginsPath & "system." , this, variables.preferences["plugins"],'system') />
		<cfset CreateObject("component", "PluginLoader").loadPlugins(variables.blog.plugins,variables.pluginQueue,
					arguments.pluginsDir & "user/", arguments.pluginsPath & "user.", this, variables.preferences["plugins"],'user') />
	
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="loadPlugin" access="public" output="false" returntype="string" hint="returns the name of the plugin if successfully loaded">
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="type" type="string" required="false" default="user" />

		<cfreturn createObject("component", "PluginLoader").loadPlugins(plugin,variables.pluginQueue,
					variables.blog.getSetting("pluginsDir") & arguments.type & "/",
					variables.blog.getSetting("pluginsPath") & arguments.type & "." , 
					this, variables.preferences["plugins"],arguments.type) />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getVersion" access="public" output="false" returntype="string">		
		<cfreturn variables.version />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getBlogId" access="public" output="false" returntype="string">		
		<cfreturn variables.blogId />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="isCurrentUserLoggedIn" output="false" description="Returns whether or not user is logged in" 
				access="public" returntype="boolean">
			
		<cfreturn structkeyexists(session,"user") />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCurrentUser" output="false" description="Returns the currently logged in user" 
						access="public" returntype="any">

			<cfif NOT structkeyexists(session,"user")>
				<cfthrow message="User is not logged in" type="NotLoggedIn" detail="NotLoggedIn">
			</cfif>
			
			<cfreturn session.user />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCurrentUser" output="false" description="Sets the currently logged in user" 
						access="public" returntype="void">
		<cfargument name="user" required="true" >
		<cfset session.user = arguments.user />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="removeCurrentUser" output="false" description="Logs user out" 
						access="public" returntype="void">

		<cfset structdelete(session,"user") />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="replaceDirectoryPlaceHolders" access="private">
		<cfargument name="data" type="string" />
		
		<cfset arguments.data = replacenocase(arguments.data,"{baseDirectory}",variables.settings["baseDirectory"]) />
		<cfreturn replacenocase(arguments.data,"{componentsDirectory}",getDirectoryFromPath(GetCurrentTemplatePath())) />
	</cffunction>
	
	<cfscript>
/**
 * Blends all nested structs, arrays, and variables in a struct to another.
 * 
 * @param struct1 	 The first struct. (Required)
 * @param struct2 	 The second sturct. (Required)
 * @param overwriteflag 	 Determines if keys are overwritten. Defaults to true. (Optional)
 * @return Returns a boolean. 
 * @author Raymond Compton (usaRaydar@gmail.com) 
 * @version 2, October 30, 2008 
 */
function structBlend(Struct1,Struct2) {
	var i = 1;
	var OverwriteFlag = true;
	var StructKeyAr = listToArray(structKeyList(Struct2));
	var Success = true;
  	if ( arrayLen(arguments) gt 2 AND isBoolean(Arguments[3]) ) // Optional 3rd argument "OverwriteFlag"
  		OverwriteFlag = Arguments[3];
		try {
			for ( i=1; i lte structCount(Struct2); i=i+1 ) {
				if ( not isDefined('Struct1.#StructKeyAr[i]#') )  // If structkey doesn't exist in Struct1
					Struct1[StructKeyAr[i]] = Struct2[StructKeyAr[i]]; // Copy all as is.
				else if ( isStruct(struct2[StructKeyAr[i]]) )			// else if key is another struct
					Success = structBlend(Struct1[StructKeyAr[i]],Struct2[StructKeyAr[i]],OverwriteFlag);  // Recall function
				else if ( OverwriteFlag )	// if Overwrite
					Struct1[StructKeyAr[i]] = Struct2[StructKeyAr[i]];  // set Struct1 Key with Struct2 value.
			}
		}
		catch(any excpt) { Success = false; }
	return Success;
}
</cfscript>
</cfcomponent>