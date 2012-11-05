<cfcomponent output="false">

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
			<cfset variables.mainManager = arguments.mainManager />
			<cfset variables.preferencesManager = arguments.preferences />
			
		<cfreturn this/>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getManager" access="public" output="false" returntype="any">
		<cfreturn variables.mainManager />
	</cffunction>

	<cffunction name="setManager" access="public" output="false" returntype="void">
		<cfargument name="mainManager" type="any" required="true" />
		<cfset variables.mainManager = arguments.mainManager />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPreferencesManager" access="public" output="false" returntype="any">
		<cfreturn variables.preferencesManager />
	</cffunction>

	<cffunction name="setPreferencesManager" access="public" output="false" returntype="void">
		<cfargument name="preferencesManager" type="any" required="true" />
		<cfset variables.preferencesManager = arguments.preferencesManager />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>
	
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfreturn "#variables.name# activated" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfreturn "#variables.name# de-activated" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		
		<cfreturn />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
			
		<cfreturn arguments.event />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="remove" hint="This is run when a plugin is removed" access="public" output="false" returntype="any">
		<!--- You should override this method, but at the very least, we clean up our preferences --->
		<cfif structkeyexists(variables,"package")>
			<cfset variables.preferencesManager.removeNode(variables.package) />
		</cfif>
		<cfreturn "#variables.name# removed" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="upgrade" hint="This is run when a plugin is upgraded" access="public" output="false" returntype="any">
		<cfargument name="fromVersion" type="string" />
		<cfreturn "#variables.name# upgraded" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPackage" access="public" output="false" returntype="any">
		<cfreturn variables.package />
	</cffunction>
	
	<cffunction name="setPackage" access="public" output="false" returntype="void">
		<cfargument name="package" type="any" required="true" />
		<cfset variables.package = arguments.package />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAssetPath" access="public" output="false" returntype="any">
		<cfreturn getManager().getBlog().getBasePath() & "assets/plugins/" & getPluginDirName() & "/" />
	</cffunction>

	<cffunction name="getAdminAssetPath" access="public" output="false" returntype="any">
		<cfreturn getManager().getBlog().getBasePath() & "admin/assets/plugins/" & getPluginDirName() & "/" />
	</cffunction>
	
	<cffunction name="getPluginDirName" access="private" output="false" returntype="any">
		<cfset var name = getMetaData(this).name />
		<cfset var dir = ListGetAt(name, ListLen(name, ".")-1, ".")>
		<cfreturn dir />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="initSettings" access="public" output="true" returntype="void">
		<cfset var key = "" />
		<cfset variables.settings = variables.preferencesManager.exportSubtreeAsStruct(variables.package) />
		<cfloop collection="#arguments#" item="key">
			<cfif NOT structkeyexists(variables.settings, key)>
				<cfset variables.settings[key] = arguments[key] />
			</cfif>
		</cfloop>	
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setSettings" access="public" output="false" returntype="void">
		<cfset var key = "" />
		<cfloop collection="#arguments#" item="key">
			<cfset variables.settings[key] = arguments[key] />
		</cfloop>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getSetting" access="public" output="false" returntype="any">
		<cfargument name="key" type="any" required="true" />
		<cfreturn variables.settings[arguments.key] />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="persistSettings" access="public" output="false" returntype="void">
		<cfset var key = "" />
		<cfloop collection="#variables.settings#" item="key">
			<cfset variables.preferencesManager.put( variables.package, key, variables.settings[key]) />
		</cfloop>
	</cffunction>

</cfcomponent>