<cfcomponent hint="Represents an event that is broadcasted to add pod items" extends="TemplateEvent" alias="org.mangoblog.event.PodEvent">
	<cfproperty name="name" type="string" default="" />
	<cfproperty name="data" type="any" />
	<cfproperty name="outputdata" type="any" />
	<cfproperty name="continueProcess" type="boolean" default="true" />
	<cfproperty name="message" type="struct" />
	<cfproperty name="type" type="string">
	<cfproperty name="requestdata" type="any" />
	<cfproperty name="contextdata" type="any" />
	<cfproperty name="pods" type="array" />
	<cfproperty name="locationId" type="string" />
	<cfproperty name="allowedPodIds" type="string" />
	
	<cfset this.type = "PodEvent" />
	<cfset this.pods = arraynew(1) />
	<cfset this.locationId = 0 />
	<cfset this.allowedPodIds =  "*"/>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		
			<cfset super.setData(arguments.data)/>
			<cfif isstruct(arguments.data)>
				<cfif structkeyexists(arguments.data,"pods")>
					<cfset setPods(arguments.data.pods) />
				</cfif>
				<cfif structkeyexists(arguments.data,"locationId")>
					<cfset this.locationId = arguments.data.locationId />
				</cfif>
			</cfif>
		<cfset this.data = arguments.data />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPods" access="public" output="false" returntype="any">
		<cfreturn this.pods />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setPods" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		<cfset this.pods = arguments.data />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="addPod" access="public" output="false" returntype="boolean">
		<cfargument name="data" type="any" required="true" />
		<!--- only add it if it is allowed --->
		<cfif this.allowedPodIds EQ "*" OR listfindnocase(this.allowedPodIds, data.id)>
			<cfset arrayappend(this.pods, arguments.data) />
			<cfreturn true />
		</cfif>
		<cfreturn false />
	</cffunction>
</cfcomponent>