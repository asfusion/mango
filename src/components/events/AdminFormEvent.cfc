<cfcomponent hint="Represents an event that is broadcasted in the admin forms" extends="Event" alias="org.mangoblog.event.AdminFormEvent">
	<cfproperty name="name" type="string" default="" />
	<cfproperty name="data" type="any" />
	<cfproperty name="outputdata" type="any" />
	<cfproperty name="continueProcess" type="boolean" default="true" />
	<cfproperty name="message" type="struct" />
	<cfproperty name="type" type="string">
	<cfproperty name="formName" type="string" />
	<cfproperty name="item" type="any" />
	<cfproperty name="status" type="string" />
	<cfproperty name="formScope" type="any" />
	
	<cfset this.type = "AdminFormEvent" />
	<cfset this.formName = "" />
	<cfset this.item = "" />
	<cfset this.status = "new" /><!--- new or update --->
	<cfset this.formScope = structnew() />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setData" access="public" output="false" returntype="void">
		<cfargument name="data" type="any" required="true" />
		
		<cfset super.setData(arguments.data)/>
		<cfif isstruct(arguments.data)>
			<cfif structkeyexists(arguments.data,"formName")>
				<cfset this.formName = arguments.data.formName />
			</cfif>
			<cfif structkeyexists(arguments.data,"item")>
				<cfset this.item = arguments.data.item />
			</cfif>
			<cfif structkeyexists(arguments.data,"formScope")>
				<cfset this.formScope = arguments.data.formScope />
			</cfif>
			<cfif structkeyexists(arguments.data,"status")>
				<cfset this.status = arguments.data.status />
			</cfif>
		</cfif>
		<cfset this.data = arguments.data />
	</cffunction>
</cfcomponent>