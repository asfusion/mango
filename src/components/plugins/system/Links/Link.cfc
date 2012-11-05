<cfcomponent>

	<cfproperty name="id" type="string" default="">
	<cfproperty name="title" type="string" default="">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="address" type="string" default="">
	<cfproperty name="categoryId" type="string" default="">
	<cfproperty name="showOrder" type="numeric" default="0">

	<cfscript>
		this.id = "";
		this.title = "";
		this.description = "";
		this.address = "";
		this.categoryId = "";
		this.showOrder = 0;
	</cfscript>

	<cffunction name="init" output="false" returntype="Link">
		<cfreturn this>
	</cffunction>
	<cffunction name="getId" output="false" access="public" returntype="any">
		<cfreturn this.Id>
	</cffunction>

	<cffunction name="setId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset variables.Id = arguments.val>
	</cffunction>

	<cffunction name="getTitle" output="false" access="public" returntype="any">
		<cfreturn this.Title>
	</cffunction>

	<cffunction name="setTitle" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.Title = arguments.val>
	</cffunction>

	<cffunction name="getDescription" output="false" access="public" returntype="any">
		<cfreturn this.Description>
	</cffunction>

	<cffunction name="setDescription" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.Description = arguments.val>
	</cffunction>

	<cffunction name="getAddress" output="false" access="public" returntype="any">
		<cfreturn this.Address>
	</cffunction>

	<cffunction name="setAddress" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.Address = arguments.val>
	</cffunction>

	<cffunction name="getCategoryId" output="false" access="public" returntype="any">
		<cfreturn this.CategoryId>
	</cffunction>

	<cffunction name="setCategoryId" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfset this.CategoryId = arguments.val>
	</cffunction>

	<cffunction name="getShowOrder" output="false" access="public" returntype="any">
		<cfreturn this.ShowOrder>
	</cffunction>

	<cffunction name="setShowOrder" output="false" access="public" returntype="void">
		<cfargument name="val" required="true">
		<cfif (IsNumeric(arguments.val)) OR (arguments.val EQ "")>
			<cfset this.ShowOrder = arguments.val>
		<cfelse>
			<cfthrow message="'#arguments.val#' is not a valid numeric"/>
		</cfif>
	</cffunction>



</cfcomponent>