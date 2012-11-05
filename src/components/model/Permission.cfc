<cfcomponent output="false" alias="org.mangoblog.model.Permission">

	<cfproperty name="id" type="string" default="">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="isCustom" type="boolean" default="false">

	<cfscript>
		this.id = "";
		this.name = "";
		this.description = "";
		this.isCustom = false;
	</cfscript>

	<cffunction name="init" output="false" returntype="any">
		<cfreturn this>
	</cffunction>

	<cffunction name="getId" output="false" access="public" returntype="any">
		<cfreturn this.Id>
	</cffunction>

	<cffunction name="setId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.Id = arguments.val>
	</cffunction>

	<cffunction name="getName" output="false" access="public" returntype="any">
		<cfreturn this.name>
	</cffunction>

	<cffunction name="setName" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.Name = arguments.val>
	</cffunction>

	<cffunction name="getDescription" output="false" access="public" returntype="any">
		<cfreturn this.description>
	</cffunction>

	<cffunction name="setDescription" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.Description = arguments.val>
	</cffunction>

	<cffunction name="getIsCustom" output="false" access="public" returntype="boolean">
		<cfreturn this.isCustom>
	</cffunction>

	<cffunction name="setIsCustom" output="false" access="public" returntype="void">
		<cfargument name="val" required="true" type="boolean">
		<cfset this.IsCustom = arguments.val>
		
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