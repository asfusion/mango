<cfcomponent name="Message">
	
	<cfset this.text = "">
	<cfset this.status = "success">
	<cfset this.type = "">
	<cfset this.data = "">
	<cfset this.title = "">
	<cfset this.hierarchy = []>
	
	<cffunction name="getText" access="public" output="false" returntype="string">
		<cfreturn this.text />
	</cffunction>

	<cffunction name="setText" access="public" output="false" returntype="void">
		<cfargument name="text" type="string" required="true" />
		<cfset this.text = arguments.text />
		<cfreturn />
	</cffunction>

	<cffunction name="getType" access="public" output="false" returntype="string">
		<cfreturn this.type />
	</cffunction>

	<cffunction name="setType" access="public" output="false" returntype="void">
		<cfargument name="type" type="string" required="true" />
		<cfset this.type = arguments.type />
		<cfreturn />
	</cffunction>
	
	<cffunction name="getStatus" access="public" output="false" returntype="string">
		<cfreturn this.status />
	</cffunction>

	<cffunction name="setStatus" access="public" output="false" returntype="void">
		<cfargument name="status" type="string" required="true" hint="success/error" />
		<cfset this.status = arguments.status />
		<cfreturn />
	</cffunction>
	
	<cffunction name="getTitle" access="public" output="false" returntype="string">
		<cfreturn this.title />
	</cffunction>

	<cffunction name="setTitle" access="public" output="false" returntype="void">
		<cfargument name="title" type="string" required="true" />
		<cfset this.title = arguments.title />
	</cffunction>
	
	<cffunction name="getData" access="public" output="false" returntype="any">
		<cfreturn this.data />
	</cffunction>

	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.data = arguments.data />
	</cffunction>

	<cffunction name="getHierarchy" access="public" output="false" returntype="any">
		<cfreturn this.hierarchy />
	</cffunction>

	<cffunction name="setHierarchy" access="public" output="false" returntype="void">
		<cfargument name="hierarchy" type="any" required="true" />
		<cfset this.hierarchy = arguments.hierarchy />
	</cffunction>
	
</cfcomponent>