<cfcomponent>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
		<cfargument name="accessObject" required="true" type="any">
			
			<cfset variables.mainApp = arguments.mainApp />
			<cfset variables.accessObject = arguments.accessObject.getLogsGateway()>
			<cfset variables.daoObject = arguments.accessObject.getLogsManager()>

			<cfreturn this />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getLogCount" output="false" hint="Gets total of records" access="public" returntype="numeric">
		<cfargument name="level" required="false" default="" type="any">
		<cfargument name="category" required="false" default="" type="any">
		<cfargument name="owner" required="false" default="" type="any">
		
		<cfset var blogId = variables.mainApp.getBlog().getId() />
		<cfreturn variables.accessObject.getCount(blogId, arguments.level, arguments.category, arguments.owner) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="search" output="false" hint="Gets all the records" access="public" returntype="array">
		<cfargument name="level" required="false" default="" type="any">
		<cfargument name="category" required="false" default="" type="any">
		<cfargument name="owner" required="false" default="" type="any">
		
		<cfset var blogId = variables.mainApp.getBlog().getId() />
		<cfset var logs = variables.accessObject.search(blogId, arguments.level, arguments.category, arguments.owner) />
		<!--- convert to pseudo objects to keep it consistent with other managers --->
		<cfset var logRecords = arraynew(1) />
		<cfset var record = "" />
		
		<cfoutput query="logs">
			<cfset record = structnew() />
			<cfset record["level"] = logs.level />
			<cfset record["category"] = logs.category />
			<cfset record["message"] = message />
			<cfset record["logged_on"] = logged_on />
			<cfset record["owner"] = logs.owner />
			<cfset arrayappend(logRecords, record) />
		</cfoutput>
	
		<cfreturn logRecords />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteByCriteria" access="public" output="false" returntype="void">
		<cfargument name="level" required="false" default="" type="any">
		<cfargument name="category" required="false" default="" type="any">
		<cfargument name="olderThan" required="false" default="" type="any">
		<cfargument name="owner" required="false" default="" type="any">
		
		<cfset var blogId = variables.mainApp.getBlog().getId() />
		<cfset variables.daoObject.deleteByCriteria(blogId, arguments.level, arguments.category, arguments.olderThan, arguments.owner) />
		
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="publish" output="false" hint="Logs the specified message" access="public" returntype="void">
		<cfargument name="logRecord" required="true" />
			
		<cfset var blogId = variables.mainApp.getBlog().getId() />
		<cfset variables.daoObject.create(blogId, arguments.logRecord) />
			
	</cffunction>
	
</cfcomponent>