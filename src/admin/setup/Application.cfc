<cfcomponent displayname="Application">
<!--- 
	Author   : Laura Arguello
	Date   : 01/29/06
--->
	<cfscript>
		this.name = "setup";
		this.setclientcookies="No";
		this.sessionmanagement="no";	
	</cfscript>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="OnApplicationStart" output="false">
		
	</cffunction>
	

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="onRequestStart" returnType="boolean" output="false">
		<cfargument type="String" name="targetPage" required="true" />
			<cfsetting requesttimeout="3600">
		<cfreturn true>
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!---  	<cffunction name="onError" returnType="void">
		<cfargument name="Exception" required="true" />
		<cfargument name="EventName" type="String" required="true"/>
		<cfcontent reset="yes">
		<cfinclude template="error.cfm">
		
	</cffunction>  --->
	
	
</cfcomponent>
