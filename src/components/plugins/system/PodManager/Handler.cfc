<cfcomponent>

	<cfset variables.package = "org/mangoblog/plugins/PodManager"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
			<cfset var blogid = arguments.mainManager.getBlog().getId() />
			<cfset variables.path = blogid & "/" & variables.package />
			<cfset variables.preferencesManager = arguments.preferences />
			<cfset variables.manager = arguments.mainManager />
			<cfset variables.locations = structnew() />
			
		<cfreturn this/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />		
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var skin = "" />
			<cfset var skinName = "" />
			<cfset var locations = "" />
			<cfset var eventName = arguments.event.name />
			<cfset var link = "" />
			<cfset var locationTitle = "" />
			<cfset var locationId = "" />
			<cfset var i = 0 />
			<cfset var availableList = "" />
			<cfset var availableLabel = "" />
			<cfset var page = "" />
			<cfset var j = 0 />
			<cfset var pluginQueue = "" />
			<cfset var tempEvent = "" />
			<cfset var tempData = "" />
			<cfset var newList = "" />
			<cfset var data = "" />
			<cfset var path = "" />
			<cfset var local = structnew() />
			
			<!--- _____________________________________ --->
			<cfif eventName EQ "initializePodGroup">
				<cfif NOT structkeyexists(variables.locations, event.locationId)>
					<cfset variables.locations[event.locationId] = variables.preferencesManager.get(variables.path, event.locationId, "*") />
				</cfif>
				
				<cfset arguments.event.allowedPodIds = variables.locations[event.locationId] />
			
			<!--- _____________________________________ --->
			<cfelseif eventName EQ "getPods">
				<!--- order pods based on list --->
				<cfif arguments.event.allowedPodIds NEQ "*">
					<cfset tempData = structnew() />
					
					<cfloop from="1" to="#arraylen(arguments.event.pods)#" index="i">
						<cfset tempData[arguments.event.pods[i].id] = arguments.event.pods[i] />
					</cfloop>
					
					<cfset arguments.event.pods = arraynew(1) />
					<cfloop list="#arguments.event.allowedPodIds#" index="i">
						<cfif structkeyexists(tempData, i)>
							<cfset arrayappend(arguments.event.pods, tempData[i]) />
						</cfif>
					</cfloop>
				</cfif>
			
			<!--- _____________________________________ --->
			<!--- admin nav event --->
			<cfelseif eventName EQ "mainNav" 
						AND variables.manager.isCurrentUserLoggedIn() 
						AND listfind(variables.manager.getCurrentUser().getCurrentRole(variables.manager.getBlog().getId()).permissions, "manage_pods")>
					<cfset link = structnew() />
					<cfset link.owner = "PodManager">
					<cfset link.page = "generic" />
					<cfset link.title = "Pod Manager" />
					<cfset link.eventName = "podManager-showSettings" />
					<cfset link.icon = "assets/images/icons/pod_manager.png" />
					
					<cfset arguments.event.addLink(link)>

			<!--- _____________________________________ --->
			<!--- admin event --->
			<cfelseif eventName EQ "podManager-showSettings">
				<cfset data = arguments.event.getData() />
				<cfset local.blog = variables.manager.getBlog() />
				
				<cfif variables.manager.isCurrentUserLoggedIn() 
						AND listfind(variables.manager.getCurrentUser().getCurrentRole(local.blog.getId()).permissions, "manage_pods")>
						
					<!--- get skin pods and ask plugins to give a list of pods --->
					<cfset skinName = local.blog.getSkin() />
					<cfset skin = variables.manager.getAdministrator().getSkin(skinName) />
					<cfset locations = skin.podLocations />
					
					<cfset pluginQueue = variables.manager.getPluginQueue() />
					
					<cfif structkeyexists(data.externaldata,"apply")>
						<cfset newList = ListChangeDelims(data.externaldata.pods,",","#chr(13)##chr(10)#") />
						<cfset variables.preferencesManager.put(variables.path, data.externaldata.locationId, newList) />
						
						<cfset variables.locations[data.externaldata.locationId] = newList />
											
						<cfset data.message.setstatus("success") />
						<cfset data.message.setType("settings") />
						<cfset data.message.settext("Settings updated")/>
					</cfif>
					
					<cfsavecontent variable="page">
						<cfif NOT arraylen(locations)>
							<p class="message">Current theme doesn't have any pod locations or it is not Pod-enabled</p>
						</cfif>
						<!--- do this for every pod location --->
						<cfloop from="1" to="#arraylen(locations)#" index="i">
							<cfset locationTitle = locations[i].name />
							<cfset locationId = locations[i].id />
							<cfset newList = ListChangeDelims(variables.preferencesManager.get(variables.path, locationId, "*"),"#chr(13)##chr(10)#") />
							<cfset availableList = "" />
							<cfset tempData = structnew() />
							<cfset tempData.locationId = locationId />
							<cfset tempEvent = pluginQueue.createEvent("getPodsList", tempData,"Pod") />
							<cfset tempEvent = pluginQueue.broadcastEvent(tempEvent) />
							
							<cfsavecontent variable="availableLabel">
								<ul>
								<cfloop from="1" to="#arraylen(locations[i].pods)#" index="j">
									<cfoutput><li>#locations[i].pods[j].title# (id: #locations[i].pods[j].id#)</li></cfoutput>
									<cfset availableList = listappend(availableList, locations[i].pods[j].id, "#chr(13)##chr(10)#") />
								</cfloop>
								
								<cfloop from="1" to="#arraylen(tempEvent.pods)#" index="j">
									<cfoutput><li>#tempEvent.pods[j].title# (id: #tempEvent.pods[j].id#)</li></cfoutput>
									<cfset availableList = listappend(availableList, tempEvent.pods[j].id, "#chr(13)##chr(10)#") />
								</cfloop>
								</ul>
							</cfsavecontent>
							
							<cfif newList EQ "*">
								<cfset newList = availableList />
							</cfif>
							
							<cfinclude template="admin/manager.cfm">
						</cfloop>
					</cfsavecontent>
				<cfelse>
					<cfsavecontent variable="page">
						<p class="infomessage">Your role does not allow you to manage pods</p>
					</cfsavecontent>
				</cfif>
				
				<!--- change message --->
				<cfset data.message.setTitle("Pod Manager") />
				<cfset data.message.setData(page) />
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>

</cfcomponent>