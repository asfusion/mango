<cfcomponent output="false" alias="org.mangoblog.model.Role">

	<cfproperty name="id" type="string" default="">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="description" type="string" default="">

	<cfscript>
		this.id = "";
		this.name = "";
		this.description = "";
		this.preferences = "";
		this.permissions = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="Role">
		<cfreturn this>
	</cffunction>
	<cffunction name="getId" output="false" access="public" returntype="any">
		<cfreturn this.id>
	</cffunction>

	<cffunction name="setId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.id = arguments.val>
	</cffunction>

	<cffunction name="getName" output="false" access="public" returntype="any">
		<cfreturn this.name>
	</cffunction>

	<cffunction name="setName" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.name = arguments.val>
	</cffunction>

	<cffunction name="getDescription" output="false" access="public" returntype="any">
		<cfreturn this.description>
	</cffunction>

	<cffunction name="setDescription" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.description = arguments.val>
	</cffunction>

	<cffunction name="getPreferences" output="false" access="public" returntype="any">
		<cfreturn this.preferences>
	</cffunction>

	<cffunction name="setPreferences" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.preferences = arguments.val>
	</cffunction>
	
	<cffunction name="getPermissions" output="false" access="public" returntype="any">
		<cfreturn this.permissions>
	</cffunction>

	<cffunction name="setPermissions" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.permissions = arguments.val>
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="isValidForSave" access="public" returntype="struct" output="false">
		<cfset var returnObj = structnew() />
		<cfset returnObj.status = true />
		<cfset returnObj.errors = arraynew(1) />

		<cfif NOT len(this.name)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"Name is required")/>			
		</cfif>
		<cfif NOT len(this.id)>
			<cfset returnObj.status = false />
			<cfset arrayappend(returnObj.errors,"ID is required")/>			
		</cfif>
		<cfreturn returnObj />
		
	</cffunction>

</cfcomponent>