<cfcomponent name="UpdateEvent" hint="Represents an event that is broadcasted when an item is updated" extends="Event" alias="org.mangoblog.event.UpdateEvent">
	<cfproperty name="name" type="string" default="" />
	<cfproperty name="data" type="any" />
	<cfproperty name="outputData" type="any" />
	<cfproperty name="continueProcess" type="boolean" default="true" />
	<cfproperty name="message" type="struct" />
	<cfproperty name="type" type="string">
	<cfproperty name="oldItem" type="any" />
	<cfproperty name="newItem" type="any" />
	<cfproperty name="changeByUser" type="any" />

	<cfset this.type = "UpdateEvent" />
	<cfset this.oldItem = "" />
	<cfset this.newItem = "" />
	<cfset this.changeByUser = "" />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
			<cfif isstruct(arguments.data)>
				<cfif structkeyexists(arguments.data,"oldItem")>
					<cfset setOldItem(arguments.data.oldItem) />
				</cfif>
				<cfif structkeyexists(arguments.data,"newItem")>
					<cfset setNewItem(arguments.data.newItem) />
				</cfif>
				<cfif structkeyexists(arguments.data,"changeByUser")>
					<cfset setChangeByUser(arguments.data.changeByUser) />
				</cfif>
			</cfif>
		<cfset this.data = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getOldItem" access="public" output="false" returntype="any">
		<cfreturn this.oldItem />
	</cffunction>
		
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setOldItem" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.oldItem = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setNewItem" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.newItem = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getNewItem" access="public" output="false" returntype="any">
		<cfreturn this.newItem />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setChangeByUser" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.changeByUser = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getChangeByUser" access="public" output="false" returntype="any">
		<cfreturn this.changeByUser />
	</cffunction>

</cfcomponent>