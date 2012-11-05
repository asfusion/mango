<cfcomponent extends="PluginQueue">

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="broadcastEvent" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
			<cfset var allPlugins = "" />
			<cfset var thisPlugin = "" />
			<cfset var i = "" />
			<cfset var eventName = arguments.event.name />
			<cfset var cfthread = "" />
			<cfset var pluginId = "">
			<cfset var logger = ""/>
			
			<cfif structkeyexists(variables.queues,eventName)>
				<cfset allPlugins = variables.queues[eventName].getElements() />
				
				<cfloop from="1" to="#arraylen(allPlugins)#" index="i">
					<cfset thisPlugin = allPlugins[i].plugin />
					<cfif allPlugins[i].eventType EQ "synch">
						<cftry>
							<cfset arguments.event = thisPlugin.processEvent(arguments.event) />
							<cfcatch type="any">
								<cfset variables.logger.logObject("debug",cfcatch, "Debug information for plugin error",'plugin','PluginQueue') />
								<cfset variables.logger.logMessage("error", 
												"Error while calling plugin #thisPlugin.getId()#: #cfcatch.Detail#",'plugin','PluginQueue') />
								<!--- if plugin fails, silently continue --->
							</cfcatch>
						</cftry>
						
						<cfif NOT arguments.event.continueProcess>
							<cfbreak>
						</cfif>
					<cfelseif allPlugins[i].eventType EQ "asynch">
						<cfset pluginId = thisPlugin.getId() />
						
						<cftry>
							<cfthread action="run" name="thread#i##randrange(1,10000)#" pluginId="#pluginId#" 
										event="#arguments.event#" logger="#variables.logger#">
								<cfset var thisPlugin = variables.plugins[attributes.pluginId]>
								
								<cftry>
									<cfset thisPlugin.handleEvent(attributes.event) />
									<cfcatch type="any">
										<cfset attributes.logger.logMessage("error", 
												"Error while calling plugin #attributes.pluginId#: #cfcatch.Detail#",'plugin','PluginQueue') />
										<cfset attributes.logger.logObject("debug",cfcatch, "Debug information for plugin error",'plugin','PluginQueue') />
									</cfcatch>
								</cftry>
							</cfthread>
							
							<cfcatch type="any">
								<!--- sometimes, threads throw errors when trying to duplicate the event, I don't know why
								that is, probably a bug... in that case, just call the method as normal  --->
								<cftry>
									<cfset thisPlugin.handleEvent(arguments.event) />
									<cfcatch type="any">
										<cfset attributes.logger.logMessage("error", 
												"Error while calling plugin: #cfcatch.Detail#",'plugin','PluginQueue') />
										<cfset attributes.logger.logObject("debug",cfcatch, "Debug information for plugin error",'plugin','PluginQueue') />
										<!--- if plugin fails, silently continue --->
									</cfcatch>
								</cftry>
					
							</cfcatch>
						</cftry>
					</cfif>
				</cfloop>
				
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>
	
</cfcomponent>