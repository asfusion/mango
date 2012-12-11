<cfcomponent name="PluginQueue">

	<cfset variables.queues = StructNew() />
	<cfset variables.plugins = StructNew() />
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="logger" type="any" required="true" />

		<cfset variables.logger = arguments.logger />
		<cfreturn this />
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- type any just because we are not using mappings, so we cannot extend from Plugin --->
	<cffunction name="getPlugin" access="public" output="false" returntype="any">
		<cfargument name="name" type="string" required="true" />
			<cfif structkeyexists(variables.plugins,arguments.name)>
				<cfreturn variables.plugins[arguments.name] />
			<cfelse>
				<cfreturn />
			</cfif>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="pluginExists" access="public" output="false" returntype="boolean">
		<cfargument name="name" type="string" required="true" />
			<cfreturn structkeyexists(variables.plugins,arguments.name) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="addPlugin" access="public" output="false" returntype="boolean">
		<cfargument name="plugin" type="any" required="true" /><!--- type any just because we are not using mappings, so we cannot extend from Plugin --->
			<cfset variables.plugins[arguments.plugin.getId()] = arguments.plugin />
	
		<cfreturn true />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPluginNames" access="public" output="false" returntype="array">
		<cfreturn structKeyArray(variables.plugins) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="addListener" access="public" output="false" returntype="boolean">
		<cfargument name="plugin" type="any" required="true" /><!--- type any just because we are not using mappings, so we cannot extend from Plugin --->
		<cfargument name="eventName" type="string" required="true" />
		<cfargument name="eventType" type="string" required="false" default="synch" hint="synch/asynch" />
		<cfargument name="priority" type="any" required="false" default="5" />
		
		<cfset var id = arguments.plugin.getId() />
		<cfset var pluginContainer = structnew() />
		<cfset pluginContainer.plugin = arguments.plugin />
		<cfset pluginContainer.eventType = arguments.eventType />
			
		<cfset variables.plugins[id] = arguments.plugin />
			
			
		<!--- check to see if we already have a queue for this event name --->
		<cfif NOT structkeyexists(variables.queues,arguments.eventName)>
			<cfset variables.queues[arguments.eventName] = createObject("component","utilities.Queue") />
		</cfif>
			
		<cfset variables.queues[arguments.eventName].addElement(pluginContainer,arguments.priority, id) />	
				
		<cfreturn true />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="removeListener" access="public" output="false" returntype="boolean">
		<cfargument name="pluginId" type="any" required="true" />
		<cfargument name="eventName" type="string" required="true" />
		
			<cfif NOT structkeyexists(variables.queues,arguments.eventName)>
				<cfset variables.queues[arguments.eventName].removeElement( arguments.pluginId ) />	
			</cfif>
				
		<cfreturn true />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="broadcastEvent" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var allPlugins = "" />
			<cfset var thisPlugin = "" />
			<cfset var i = "" />
			<cfset var eventName = arguments.event.name />
			<cfset var logger = ""/>
			
			<cfif structkeyexists(variables.queues,eventName)>
				<cfset allPlugins = variables.queues[eventName].getElements() />
				
				<cfloop from="1" to="#arraylen(allPlugins)#" index="i">
					<cfset thisPlugin = allPlugins[i].plugin />
					<cfif allPlugins[i].eventType EQ "synch">
						<cftry>
							<cfset arguments.event = thisPlugin.processEvent(arguments.event) />
							<cfcatch type="any">
								<!--- if plugin fails, silently continue --->
								<cfset variables.logger.logMessage("error", 
												"Error while calling plugin #thisPlugin.getId()#: #cfcatch.Detail#",'plugin','PluginQueue') />
								<cfset variables.logger.logObject("debug",cfcatch, "Debug information for plugin error",'plugin','PluginQueue') />
							</cfcatch>
						</cftry>
						
						<cfif NOT arguments.event.continueProcess>
							<cfbreak>
						</cfif>
					<cfelseif allPlugins[i].eventType EQ "asynch">
						<cftry>
							<cfset thisPlugin.handleEvent(arguments.event) />
						<cfcatch type="any">
							<!--- if plugin fails, silently continue --->
							<cfset variables.logger.logMessage("error", 
												"Error while calling plugin #thisPlugin.getId()#: #cfcatch.Detail#",'plugin','PluginQueue') />
								<cfset variables.logger.logObject("debug",cfcatch, "Debug information for plugin error",'plugin','PluginQueue') />
						</cfcatch>
						</cftry>
						
					</cfif>
					
				</cfloop>
				
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="stringRepresentation" access="public" output="false" hint="A string representation of this object" returntype="string">
		<cfargument name="html" type="boolean" required="false" default="true" />
		<cfset var myString = "" />
		<cfset var allPlugins = "" />
		<cfset var thisPlugin = "" />
		<cfset var i = "" />
		<cfset var thisEvent = ""/>
		
		<cfif arguments.html>
			<cfsavecontent variable="myString">
				<table>
				<cfoutput><cfloop collection="#variables.queues#" item="thisEvent">
					<cfset allPlugins = variables.queues[thisEvent].getElements() />					
					<tr>
							<th>#thisEvent#</th>
						<td>
							<cfloop from="1" to="#arraylen(allPlugins)#" index="i">
								#allPlugins[i].plugin.getName()#: #allPlugins[i].eventType#<br />
							</cfloop>
						</td>
					</tr>				
				</cfloop></cfoutput>
				</table>
			</cfsavecontent>

		</cfif>
		<cfreturn myString />
	</cffunction>	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="createEvent" access="public" output="false" hint="Factory method for creating events" returntype="any">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="data" type="any" required="false" default="#structnew()#" />
		<cfargument name="type" type="string" required="false" default="" />
		<cfargument name="message" type="any" required="false" default="#structnew()#" />
		
		<cfreturn createObject("component","events.#arguments.type#Event").init( arguments.name,arguments.data,arguments.message) />
	</cffunction>
	
</cfcomponent>