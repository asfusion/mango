<cfcomponent hint="Represents an event that is broadcasted when a collection is retrieved from the db" extends="TemplateEvent" alias="org.mangoblog.event.CollectionEvent">
	<cfproperty name="name" type="string" default="" />
	<cfproperty name="data" type="any" />
	<cfproperty name="outputdata" type="any" />
	<cfproperty name="continueProcess" type="boolean" default="true" />
	<cfproperty name="message" type="struct" />
	<cfproperty name="requestdata" type="any" />
	<cfproperty name="contextdata" type="any" />
	<cfproperty name="type" type="string">
	<cfproperty name="query" type="any" />
	<cfproperty name="collection" type="any" />
	<cfproperty name="arguments" type="any" />
	
	<cfset this.type = "CollectionEvent" />
	<cfset this.query =  ""/>
	<cfset this.collection =  ""/>
	<cfset this.arguments =  structnew() />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		
			<cfset super.setData(arguments.data)/>
			<cfif isstruct(arguments.data)>
				<cfif structkeyexists(arguments.data,"query")>
					<cfset setQuery(arguments.data.query) />
				</cfif>
				<cfif structkeyexists(arguments.data,"collection")>
					<cfset setCollection(arguments.data.collection) />
				</cfif>
				<cfif structkeyexists(arguments.data,"arguments")>
					<cfset setArguments(arguments.data.arguments) />
				</cfif>
			</cfif>
		<cfset this.data = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getQuery" access="public" output="false" returntype="any">
		<cfreturn this.query />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setQuery" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.query = arguments.data />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCollection" access="public" output="false" returntype="any">
		<cfreturn this.collection />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setCollection" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.collection = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getArguments" access="public" output="false" returntype="any">
		<cfreturn this.arguments />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setArguments" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.arguments = arguments.data />
	</cffunction>
	
</cfcomponent>