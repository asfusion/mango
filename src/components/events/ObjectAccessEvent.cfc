<cfcomponent name="ObjectAccessEvent" hint="Represents an event that is broadcasted when an object is accessed via getter functions" extends="Event" alias="org.mangoblog.event.ObjectAccessEvent">
	<cfproperty name="name" type="string" default="" />
	<cfproperty name="data" type="any" />
	<cfproperty name="outputdata" type="any" />
	<cfproperty name="continueProcess" type="boolean" default="true" />
	<cfproperty name="message" type="struct" />
	<cfproperty name="type" type="string">
	<cfproperty name="originalObject" type="any" />
	<cfproperty name="accessObject" type="any" />
	
	<cfset this.type = "ObjectAccessEvent" />
	<cfset this.originalObject = "" />
	<cfset this.accessObject = "" />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
			<cfif isstruct(arguments.data)>
				<cfif structkeyexists(arguments.data,"originalObject")>
					<cfset setOriginalObject(arguments.data.originalObject) />
				</cfif>
				<cfif structkeyexists(arguments.data,"accessObject")>
					<cfset setAccessObject(arguments.data.accessObject) />
				</cfif>
			</cfif>
		<cfset this.data = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getOriginalObject" access="public" output="false" returntype="any">
		<cfreturn this.originalObject />
	</cffunction>
		
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setOriginalObject" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.originalObject = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setAccessObject" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.accessObject = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getAccessObject" access="public" output="false" returntype="any">
		<cfreturn this.accessObject />
	</cffunction>


</cfcomponent>