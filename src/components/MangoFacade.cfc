<cfcomponent name="MangoFacade">
	
	<cfset variables.configFile = '' />
	<cfset variables.baseDirectory = '' />
	<cfset variables.defaultId = 'default' />
	<cfset variables.blogInstances = structnew() />
	
	<cffunction name="init" access="public" output="false" returntype="any" hint="Always override if extending from this component">
		<cfargument name="configFile" required="false" type="string" default="" hint="Path to config file"/>
		<cfargument name="baseDirectory" required="true" type="string" hint="Path to main blog directory" />	
		<cfargument name="id" required="false" default="default" type="string" hint="Blog"/>
		
		<cfset var preferences = createObject("component", "utilities.PreferencesFile") />
		<cfset var facadeComponent = '' />
		<cfset var facadeInstance = "" />
		
		<!--- Read the configuration to see if we need to use a different facade, if so, create it
			and send that back instead of this --->
			
		<!--- check for the config file --->
		<cfif fileexists(arguments.configFile)>
			<cfset preferences.init(arguments.configFile)/>
		<cfelse>
			<cfthrow type="MissingConfigFile" errorcode="MissingConfigFile" detail="Configuration file could not be read">
		</cfif>
		
		<cfset facadeComponent = preferences.get("generalSettings/facade","component",'') />
		<cfif NOT len(facadeComponent)>
			<cfset variables.configFile = arguments.configFile />
			<cfset variables.baseDirectory = arguments.baseDirectory />
			<cfset variables.defaultId = arguments.id />
			<cfset facadeInstance = this />
		<cfelse>
			<!--- since there is a component definition, use it instead --->
			<cfset facadeInstance = createObject("component",facadeComponent).init(arguments.configFile, arguments.baseDirectory, 
						arguments.id, preferences.exportSubtreeAsStruct("generalSettings/facade/settings") ) />
		</cfif>
		
		<cfreturn facadeInstance />
	</cffunction>


	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getMango" access="public" output="false" returntype="Mango">
		<cfargument name="id" required="false" type="string" hint="Optional blog id"/>
		<cfif NOT structkeyexists(arguments, "id")>
			<cfset arguments.id = variables.defaultId />
		</cfif>
		<cfif NOT structkeyexists(variables.blogInstances, arguments.id)>
			<cfset variables.blogInstances[arguments.id] = createobject("component", "Mango").init(
							variables.configFile, arguments.id, variables.baseDirectory) />
		</cfif>
		<cfreturn variables.blogInstances[arguments.id] />
	</cffunction>


	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setMango" access="public" output="false" returntype="void">
		<cfargument name="mango" type="Mango" required="true" />
		<cfargument name="id" required="false" type="string" hint="Optional blog id"/>
		
		<cfif NOT structkeyexists(arguments, "id")>
			<cfset arguments.id = variables.defaultId />
		</cfif>
		<cfset variables.blogInstances[arguments.id] = arguments.mango />
	</cffunction>
	
</cfcomponent>