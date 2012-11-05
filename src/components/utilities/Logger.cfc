<cfcomponent name="Logger">

<cfset variables.logLevels = "error"/>
<cfset variables.handlers = arraynew(1) />

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="logMessage" output="false" hint="Logs the specified message" access="public" returntype="void">
		<cfargument name="level" required="false" default="error" type="string" />
		<cfargument name="message" required="true" type="string" />
		<cfargument name="category" required="true" type="string" />
		<cfargument name="owner" required="false" default="anonymous" type="string" />
		
		<cfset var i = 0 />
		<cfset var record = structnew() />
		
		<!--- only log it if we are at that logging level --->
		<cfif listfind(variables.logLevels,arguments.level)>
			<!--- create a log record object. I would prefer an actual object, but to make it leaner, use a struct --->
			<cfset record['level'] = arguments.level />
			<cfset record['category'] = arguments.category />
			<cfset record['message'] = arguments.message />	
			<cfset record['owner'] = arguments.owner />			
						
			<!--- call all handlers --->
			<cfloop from="1" to="#arraylen(variables.handlers)#" index="i">
				<cftry>
					<cfset variables.handlers[i].publish(record) />
					<cfcatch type="any"><!--- we will ignore handler errors ---></cfcatch>
				</cftry>
			</cfloop>
			
		</cfif>
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="logObject" output="false" hint="Logs the specified object/struct" access="public" returntype="void">
		<cfargument name="level" required="false" default="error" type="string" />
		<cfargument name="obj" required="true" type="any" />
		<cfargument name="description" required="false" default="" type="string" />
		<cfargument name="category" required="true" type="string" />
		<cfargument name="owner" required="false" default="anonymous" type="string" />
		
			<cfset var message = ""/>
			<cfsavecontent variable="message">
				<cfdump var="#arguments.obj#">
			</cfsavecontent>
			
		<cfset logMessage(arguments.level,arguments.description & "<br />" & message, arguments.category, arguments.owner)/>
		
</cffunction>


<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="setLevel" output="false" hint="Sets the log level" access="public" returntype="void">
		<cfargument name="level" required="false" default="error" hint="Either error, warning, info and debug" type="string" />
		
		<cfswitch expression="#arguments.level#">
			<cfcase value="warning">
				<cfset variables.logLevels = "error,warning" />
			</cfcase>			
			<cfcase value="info">
				<cfset variables.logLevels = "error,warning,info" />
			</cfcase>
			<cfcase value="debug">
				<cfset variables.logLevels = "error,warning,info,debug" />
			</cfcase>
			<cfdefaultcase>
				<cfset variables.logLevels = "off" />
			</cfdefaultcase>			
		</cfswitch>
</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="addHandler" output="false" hint="Adds a handler that will be used to actually log the messages" access="public" returntype="void">
		<cfargument name="handler" required="true" type="any" />
			
		<cfset arrayappend(variables.handlers, arguments.handler) />
			
	</cffunction>

</cfcomponent>
