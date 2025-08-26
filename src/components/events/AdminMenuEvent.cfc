<cfcomponent hint="Represents an event that is broadcasted in the admin to add menu items" extends="TemplateEvent" alias="org.mangoblog.event.AdminMenuEvent">
	<cfproperty name="name" type="string" default="" />
	<cfproperty name="data" type="any" />
	<cfproperty name="outputdata" type="any" />
	<cfproperty name="continueProcess" type="boolean" default="true" />
	<cfproperty name="message" type="struct" />
	<cfproperty name="type" type="string">
	<cfproperty name="requestdata" type="any" />
	<cfproperty name="contextdata" type="any" />
	<cfproperty name="links" type="array" />
	
	<cfset this.type = "AdminMenuEvent" />
	<cfset this.links = arraynew(1) />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		
			<cfset super.setData(arguments.data)/>
			<cfif isstruct(arguments.data)>
				<cfif structkeyexists(arguments.data,"links")>
					<cfset setLinks(arguments.data.links) />
				</cfif>
			</cfif>
		<cfset this.data = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getLinks" access="public" output="false" returntype="any">
		<cfreturn this.links />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setLinks" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfloop array="#arguments.data#" item="link">
			<cfset addLink( link )/><!--- doing this to ensure all links have an id --->
		</cfloop>
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="addLink" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfif NOT structKeyExists( arguments.data, 'id' ) AND structKeyExists( arguments.data, 'owner' )>
			<cfset arguments.data.id = arguments.data.owner />
		<cfelseif NOT structKeyExists( arguments.data, 'id' )>
			<cfset arguments.data.id = '' />
		</cfif>
		<cfset arrayappend(this.links, arguments.data) />
	</cffunction>
</cfcomponent>