<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset this.events = [
	{ 'name' = 'pluginLoaded', 'type' = 'async', 'priority' = '100' },
	{ 'name' = 'mainPagesNav', 'type' = 'sync', 'priority' = '5' },
	{	'name' = 'mainPostsNav', 'type' = 'sync', 'priority' = '5' },
	{	'name' = 'pagesNav', 'type' = 'sync', 'priority' = '5' },
	{	'name' = 'postsNav', 'type' = 'sync', 'priority' = '5' },
	{	'name' = 'mainNav', 'type' = 'sync', 'priority' = '5' }
		] />
<cfset variables.queues = structnew() />
<cfset variables.queues["post"] = createobject("component","Queue") />
<cfset variables.queues["page"] = createobject("component","Queue") />
<cfset variables.queues["secondarypage"] = createobject("component","Queue") />
<cfset variables.queues["secondarypost"] = createobject("component","Queue") />

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />

		<cfset super.init(arguments.mainManager, arguments.preferences) />
		<cfset initSkinPanels() />

		<cfreturn this/>
	</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var eventName 	= arguments.event.getName() />
		<cfset var local 		= structnew() />
		<cfset var data 		= arguments.event.data />
		<cfset var manager		= getManager() />

		<cfif eventName EQ "pluginLoaded">
			<cfset local.factory = manager.getObjectFactory() />
			<cfset local.admin = manager.getAdministrator() />
			<cfset local.path = manager.getBlog().getBasePath() & "admin/assets/plugins/" />
			
			<!--- check if this plugin has any custom panel to show --->
			<cfloop from="1" to="#arraylen(data.pluginDescriptor.customPanels)#" index="local.i">
				<cfset local.pluginPath = manager.getBlog().getSetting("pluginsDir") & "#data.pluginType#/" & data.pluginDescriptor.package &  '/'/>
				<cffile action="read" file="#local.pluginPath##data.pluginDescriptor.customPanels[local.i].xmlFile#" variable="local.xml">
				<cfset local.panel = local.factory.createAdminCustomPanel() />
				<cfset local.panel.initFromXML(local.xml) />
				<cfif len(local.panel.iconImage)>
					<cfset local.panel.iconImage = local.path & data.pluginDescriptor.package & "/" & local.panel.iconImage />
				</cfif>

				<cfset local.admin.addCustomPanel(local.panel) />
				<cfif local.panel.showInMenu EQ "primary">
					<cfset variables.queues[local.panel.type].addElement(local.panel, -local.panel.order) />
				<cfelseif local.panel.showInMenu EQ "secondary">
					<cfset variables.queues['secondary' & local.panel.type].addElement(local.panel, -local.panel.order) />
				</cfif>
				
			</cfloop>
		</cfif>
		
		<cfreturn arguments.event />
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var eventName 	= arguments.event.getName() />
		<cfset var local 		= structnew() />
		<cfset var manager		= getManager() />

		<cfif (eventName EQ "mainPagesNav" OR eventName EQ "mainPostsNav" OR eventName EQ "postsNav" OR eventName EQ "pagesNav") 
				AND manager.isCurrentUserLoggedIn()>
			<cfif eventName EQ "mainPagesNav">
				<cfset local.queue = variables.queues['page'] />
			<cfelseif eventName EQ "mainPostsNav">
				<cfset local.queue = variables.queues['post'] />
			<cfelseif eventName EQ "postsNav">
				<cfset local.queue = variables.queues['secondarypost'] />
			<cfelseif eventName EQ "pagesNav">
				<cfset local.queue = variables.queues['secondarypage'] />
			</cfif>

			<cfif local.queue.getTotalElements() GT 0>
				<cfset local.elements = local.queue.getElements() />
				<cfloop from="1" to="#arraylen(local.elements)#" index="local.i">
					<cfif NOT len(local.elements[local.i].requiresPermission) OR (len(local.elements[local.i].requiresPermission) AND 
						listfind(manager.getCurrentUser().getCurrentrole(manager.getBlog().getId()).permissions, local.elements[local.i].requiresPermission))>
						<cfset local.link = { 'owner' = local.elements[local.i].id, 'address' = local.elements[local.i].address,
								title = local.elements[local.i].label, icon = local.elements[local.i].icon  } />
						<cfset arguments.event.addLink(local.link)>
					</cfif>
				</cfloop>
			
			</cfif>
		</cfif>
		
		<cfreturn arguments.event />
		
	</cffunction>

	<cfscript>
		private function initSkinPanels(){
			var admin = getManager().getAdministrator();
			var panels = admin.getCustomPanels();
			for ( var panelId in panels ){//it's a struct
				var panel = panels[ panelId ];
				if ( panel.showInMenu EQ "primary" )
					variables.queues[ panel.type ].addElement( panel, -panel.order );
				else if ( panel.showInMenu EQ "secondary" )
					variables.queues['secondary' & panel.type].addElement( panel, -panel.order );
			}
		}
	</cfscript>

</cfcomponent>