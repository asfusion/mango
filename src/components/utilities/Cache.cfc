<cfcomponent name="Cache">

	<cfproperty name="items" type="struct" />
	<cfproperty name="maxCacheTime" type="numeric" hint="time in minutes" />
	<cfproperty name="cacheTime" type="numeric" hint="time in minutes" />
	<cfproperty name="maxKeys" type="numeric" />
	
	<cfset variables.items = structnew() />
	<cfset variables.maxCacheTime = "300" />
	<cfset variables.cacheTime = "30" />
	<cfset variables.maxKeys = 100 />
	<cfset variables.lastCleanup = now() />
	<cfset variables.cleanupinterval = 5 />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="cacheTime" type="any" required="false" default="#variables.cacheTime#" hint="The time in minutes since last accessed to keep the keys" />
		<cfargument name="maxKeys" type="numeric" required="false" default="#variables.maxKeys#" hint="The maximum number of total keys to keep in cache" />
		<cfargument name="maxCacheTime" type="any" required="false" default="#variables.maxCacheTime#" hint="The maximum time in minutes since first stored (regardless of last time accessed) to keep keys" />
			<cfset variables.cacheTime = arguments.cacheTime />
			<cfset variables.maxKeys = arguments.maxKeys />
			<cfset variables.maxCacheTime = arguments.maxCacheTime />
		<cfreturn this />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="getMaxCacheTime" access="public" output="false" returntype="any">
		<cfreturn variables.maxCacheTime />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="setMaxCacheTime" access="public" output="false" returntype="void">
		<cfargument name="maxCacheTime" type="any" required="true" />
		<cfset variables.maxCacheTime = arguments.maxCacheTime />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="getMaxKeys" access="public" output="false" returntype="numeric">
		<cfreturn variables.maxKeys />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="setMaxKeys" access="public" output="false" returntype="void">
		<cfargument name="maxKeys" type="numeric" required="true" />
		<cfset variables.maxKeys = arguments.maxKeys />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="store" access="public" output="false" returntype="boolean">
		<cfargument name="key" type="String" required="true" />
		<cfargument name="value" type="any" required="true" />
			
			<!--- this is not the best solution, but just not store the item if we are over the max number of keys --->
			<cfif StructCount(variables.items) LT variables.maxKeys>
				<cfset variables.items[arguments.key] = structnew() />
				<cfset variables.items[arguments.key].value = arguments.value />
				<cfset variables.items[arguments.key].lastAccessed = now() />
				<cfset variables.items[arguments.key].storedOn = now() />
				<cfreturn true />
			<cfelse>
				<cfreturn false />
			</cfif>
		
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="retrieve" access="public" output="false" returntype="Any">
		<cfargument name="key" type="string" required="true" />
		<cfset variables.items[arguments.key].lastAccessed = now() />
		<cfreturn variables.items[arguments.key].value />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="clear" access="public" output="false" returntype="void">
		<cfargument name="key" type="string" required="true" />			
			<cfset StructDelete( variables.items, key)>		
			<!---<cfset variables.logger.logMessage("debug", "Clear key: " & arguments.key) /> --->
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="clearAll" access="public" output="false" returntype="void">	
		<cfset variables.items = structnew() />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="contains" access="public" output="false" returntype="boolean">
		<cfargument name="key" type="string" required="true" />
		<cfset cleanup() />
		<cfreturn structkeyexists(variables.items, arguments.key) />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="checkAndRetrieve" access="public" output="false" returntype="struct">
		<cfargument name="key" type="string" required="true" />
		<cfset var result = structnew() />
		<cfset cleanup() />
		
		<cfif structkeyexists(variables.items, arguments.key)>
			<cftry>
				<cfset result.value = retrieve(arguments.key) />
				<cfset result.contains = true />
				<cfcatch type="any">
					<cfset result.contains = false />
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset result.contains = false />
		</cfif>
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="cleanup" access="private" output="false" returntype="void">
		<cfif datediff("n",variables.lastCleanup,now()) GT variables.cleanupinterval>
			<cfset variables.lastCleanup = now() />
			<cfset evict() />			
		</cfif>
	</cffunction>	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->	
	<cffunction name="evict" access="private" output="false" returntype="void"><!---StructCount --->
		<cfset var item = "" />
		<cfloop collection="#variables.items#" item="item">
			<cfif datediff("n",variables.items[item].lastAccessed,now()) GT variables.cacheTime OR 
					datediff("n",variables.items[item].storedOn,now()) GT variables.maxCacheTime>
				<cfset structDelete(variables.items, item) />
			</cfif>
		</cfloop>		
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::--->
	<cffunction name="getStoredItems">
		<cfreturn variables.items />
	</cffunction>

</cfcomponent>