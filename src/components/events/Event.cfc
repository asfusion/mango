<cfcomponent name="Event" hint="Represents an event" alias="org.mangoblog.events.Event">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="data" type="any">
	<cfproperty name="outputData" type="any">
	<cfproperty name="continueProcess" type="boolean" default="true">
	<cfproperty name="message" type="struct">
	<cfproperty name="type" type="string">
	
	<cfset this.type = "Event" />
	<cfset this.name = "" />
	<cfset this.data = "" />
	<cfset this.outputData = "" />
	<cfset this.continueProcess = true />
	<cfset this.message = structnew() />

	<cffunction name="init" hint="Constructor" access="public" output="false" returntype="any">
		<cfargument name="name" type="any" required="true" />
		<cfargument name="data" type="any" required="true" hint="Data needed for the plugins to process the event" />
		<cfargument name="message" type="struct" required="false" default="#structnew()#" />
		
			<cfset setName(arguments.name) />
			<cfset setData(arguments.data) />
			<cfset setMessage(arguments.message) />
			
		<cfreturn this />
	</cffunction>	
	
	<cffunction name="getName" access="public" output="false" returntype="any">
		<cfreturn this.name />
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="any" required="true" />
		<cfset this.name = arguments.name />
		<cfreturn />
	</cffunction>

	<cffunction name="getData" access="public" output="false" returntype="any">
		<cfreturn this.data />
	</cffunction>

	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.data = arguments.data />
	</cffunction>

	<cffunction name="getOutputData" access="public" output="false" returntype="any">
		<cfreturn this.outputdata />
	</cffunction>

	<cffunction name="setOutputData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.outputdata = arguments.data />
	</cffunction>

	<cffunction name="getContinueProcess" access="public" output="false" returntype="boolean">
		<cfreturn this.continueProcess />
	</cffunction>

	<cffunction name="setContinueProcess" access="public" output="false" returntype="void">
		<cfargument name="continueProcess" type="boolean" required="true" />
		<cfset this.continueProcess = arguments.continueProcess />
	</cffunction>

	<cffunction name="getMessage" access="public" output="false" returntype="struct">
		<cfreturn this.message />
	</cffunction>

	<cffunction name="setMessage" access="public" output="false" returntype="void">
		<cfargument name="message" type="struct" required="true" />
		<cfset this.message = arguments.message />
	</cffunction>


	<cffunction name="getType" access="public" output="false" returntype="string">
		<cfreturn this.type />
	</cffunction>

	<cffunction name="setType" access="public" output="false" returntype="void">
		<cfargument name="type" type="string" required="true" />
		<cfset this.type = arguments.type />
	</cffunction>
</cfcomponent>