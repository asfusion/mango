<cfcomponent name="RequestEvent" hint="Represents an event that is broadcasted via a GET or POST request" extends="Event" 
			alias="org.mangoblog.event.RequestEvent">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="data" type="any">
	<cfproperty name="outputData" type="any">
	<cfproperty name="continueProcess" type="boolean" default="true">
	<cfproperty name="message" type="struct">
	<cfproperty name="type" type="string">
	<cfproperty name="externalData" type="struct">

	<cfset this.type = "RequestEvent" />
	<cfset this.externalData = structnew() />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		
			<cfset super.setData(arguments.data)/>
			<cfif isstruct(arguments.data)>
				<cfif structkeyexists(arguments.data,"externalData")>
					<cfset this.externalData = arguments.data.externalData />
				</cfif>
			</cfif>
		<cfset this.data = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getExternalData" access="public" output="false" returntype="any">
		<cfreturn this.externalData />
	</cffunction>
		
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setExternalData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.externalData = arguments.data />
	</cffunction>

</cfcomponent>