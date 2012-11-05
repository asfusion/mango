<cfcomponent>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
		<cfargument name="accessObject" required="true" type="any">
			
			<cfset variables.accessObject = arguments.accessObject.getSettingsGateway()>
			<cfset variables.daoObject = arguments.accessObject.getSettingsManager()>
			<cfset variables.blogid = arguments.mainApp.getBlogId() />
			
			<cfreturn this />
	</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="get" access="public" output="false" returntype="any" hint="Returns the value associated with the specified key in this preference node. Returns the specified default if there is no value associated with the key.">
		<cfargument name="pathName" type="String" required="false" hint="Path to preference node" />
		<cfargument name="key" type="String" required="true" hint="key whose associated value is to be returned" />
		<cfargument name="default" type="String" required="false" default="" hint="the value to be returned in the event that this preference node has no value associated with key" />
		<cfargument name="blog" type="String" required="false" hint="Blog id" />
		
			<cfset var preference = arguments.default />
			<cfset var blogId = variables.blogid />
			<cfset var storedPreference = "" />
			
			<cfif structkeyexists(arguments, "blog")>
				<cfset blogId = arguments.blog />
			</cfif>
			
			<!--- get it from database if it exists --->
			<cfset storedPreference = variables.accessObject.getById(arguments.pathName, arguments.key, blogId) />
			<cfif storedPreference.recordcount>
				<cfset preference = storedPreference.value />
			</cfif>
			
		<cfreturn preference />
	</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="remove" access="public" output="false" returntype="void" hint="Removes the value associated with the specified key in this preference node, if any.">
		<cfargument name="pathName" type="String" required="false" hint="Path to preference node" />
		<cfargument name="key" type="String" required="true" hint="key whose mapping is to be removed from the preference node." />
		<cfargument name="blog" type="String" required="false" hint="Blog id" />
		
		<cfset var blogId = variables.blogid />
			
		<cfif structkeyexists(arguments, "blog")>
			<cfset blogId = arguments.blog />
		</cfif>
			
		<cfset variables.daoObject.delete(arguments.pathName, arguments.key, blogId) />
					
		<cfreturn />
	</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="nodeExists" access="public" output="false" returntype="boolean">
		<cfargument name="pathName" type="String" required="false" />
		<cfargument name="blog" type="String" required="false" hint="Blog id" />
		
		<cfset var blogId = variables.blogid />
			
		<cfif structkeyexists(arguments, "blog")>
			<cfset blogId = arguments.blog />
		</cfif>
		
		<cfreturn variables.accessObject.pathExists(arguments.pathName, blogId) />
		
	</cffunction>
	

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="put" access="public" output="false" returntype="void" hint="Associates the specified value with the specified key in the given preference node">
		<cfargument name="pathName" type="String" required="false" hint="Path to preference node" />
		<cfargument name="key" type="String" required="true" hint="Key with which the specified value is to be associated." />
		<cfargument name="value" type="String" required="false" hint="Value to be associated with the specified key" />
		<cfargument name="blog" type="String" required="false" hint="Blog id" />
		
		<cfset var blogId = variables.blogid />
		<cfset var exists = false />
		
		<cfif structkeyexists(arguments, "blog")>
			<cfset blogId = arguments.blog />
		</cfif>
		
		<cfset exists = variables.accessObject.getById(arguments.pathName, arguments.key, blogId) />
		<cfif NOT exists.recordcount>
			<cfset variables.daoObject.create(arguments.pathName, arguments.key, arguments.value, blogId) />
		<cfelse>
			<cfset variables.daoObject.update(arguments.pathName, arguments.key, arguments.value, blogId) />
		</cfif>
			
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="removeNode" access="public" output="false" returntype="void" hint="Removes the given preference node and all of its descendants">
		<cfargument name="pathName" type="String" required="true" hint="Path to node to remove" />
		<cfargument name="blog" type="String" required="false" hint="Blog id" />
		
		<cfset var blogId = variables.blogid />
		
		<cfif structkeyexists(arguments, "blog")>
			<cfset blogId = arguments.blog />
		</cfif>
		
		<cfset variables.daoObject.deleteByPath(arguments.pathName, blogId, true) />
		
	</cffunction>

	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="exportSubtreeAsStruct" access="public" output="false" returntype="struct" hint="Returns a structure containing the keys and values of the preferences from given node">
		<cfargument name="pathName" type="String" required="false" default="/" hint="Path to node from which to export" />
		<cfargument name="blog" type="String" required="false" hint="Blog id" />
		
		<cfset var blogId = variables.blogid />
		<cfset var allEntries = "" />
		<cfset var map = structnew() />
		<cfset var leafValues = "" />
		<cfset var shortenPath = "" />
		
		<cfif structkeyexists(arguments, "blog")>
			<cfset blogId = arguments.blog />
		</cfif>
		
		<cfset allEntries = variables.accessObject.getByPath(arguments.pathName, blogId, true) />
		
		<cfoutput query="allEntries" group="path">
			<!--- we need to remove the root of the path --->
			<cfset shortenPath = replace(path, arguments.pathName, '', "one") />
			<cfset leafValues = structnew() />
			<cfoutput>
				<cfset leafValues[name] = value />
			</cfoutput>
			<cfif len(shortenPath)>
				<cfset map = makeTree(shortenPath, map, leafValues) />
			<cfelse>
				<cfset map = leafValues />
			</cfif>
		</cfoutput>
		
		<cfreturn map />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
<cffunction name="makeTree" access="private" output="false" returntype="struct" 
			hint="Makes a tree with the path given (path is node/node2/node3)">
	<cfargument name="path" required="true" type="string" />
	<cfargument name="tree" required="false" default="#structnew()#" type="struct" />
	<cfargument name="value" required="false" default="#structnew()#" type="struct" />
	
	<cfset var firstKey = listFirst(arguments.path, "/") />
	
	<cfif NOT structkeyexists(arguments.tree, firstKey)>
		<cfif listlen(arguments.path, "/") GT 1>
			<cfset arguments.tree[firstkey] = structnew() />
		<cfelse>
			<cfset arguments.tree[firstkey] = arguments.value />
		</cfif>
	</cfif>
	
	<cfif listlen(arguments.path, "/") GT 1>
		<cfset makeTree(listDeleteAt(arguments.path,1,"/"), arguments.tree[firstkey], arguments.value)>
	</cfif>

	<cfreturn arguments.tree>
</cffunction>
</cfcomponent>