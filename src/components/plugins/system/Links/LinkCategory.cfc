<cfcomponent>

	<cfproperty name="id" type="string" default="">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="parentCategoryId" type="string" default="">

	<cfscript>
		this.id = "";
		this.name = "";
		this.description = "";
		this.parentCategoryId = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="LinkCategory">
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
		<cfreturn this.Name>
	</cffunction>

	<cffunction name="setName" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.Name = arguments.val>
	</cffunction>

	<cffunction name="getDescription" output="false" access="public" returntype="any">
		<cfreturn this.Description>
	</cffunction>

	<cffunction name="setDescription" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.Description = arguments.val>
	</cffunction>

	<cffunction name="getParentCategoryId" output="false" access="public" returntype="any">
		<cfreturn this.ParentCategoryId>
	</cffunction>

	<cffunction name="setParentCategoryId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.ParentCategoryId = arguments.val>
	</cffunction>



</cfcomponent>