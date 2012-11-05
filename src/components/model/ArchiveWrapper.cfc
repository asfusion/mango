<cfcomponent output="false">
<cfscript>
	variables.eventNames = structnew();
	variables.eventNames["getPageSize"] = "archiveGetPageSize";
	variables.eventNames["getTitle"] = "archiveGetTitle";
	variables.eventNames["getUrlString"] = "archiveGetUrlString";
	variables.eventNames["getPostCount"] = "archiveGetPostCount";
</cfscript>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" output="false" returntype="any" access="public">
		<cfargument name="pluginQueue" type="any" required="true" />
		<cfargument name="objectFactory" type="any" required="true" />
		<cfargument name="archive" type="any" required="false" />

		<cfscript>
			variables.pluginQueue = arguments.pluginQueue;

			variables.objectFactory = arguments.objectFactory;
			if(NOT structKeyExists(arguments, "archive"))
			{
				arguments.archive = variables.objectFactory.createArchive();
			}

			setInstance(arguments.archive);
			return this;
		</cfscript>
 	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setInstance" output="false" returntype="void" access="package">
		<cfargument name="myObject" type="any" required="true" />
		
			<cfset variables.myObject = arguments.myObject />
			<cfset variables.myObjectClone = variables.myObject.clone(variables.objectFactory.createArchive()) />

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="reInitInstance" output="false" returntype="void" access="package">
		
		<cfset variables.myObjectClone = variables.myObject.clone(variables.objectFactory.createArchive()) />
	</cffunction>	


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setType" access="public" returntype="void" output="false">
		<cfargument name="type" type="string" required="true" />
		<cfset variables.myObject.type = arguments.type />
		<cfset variables.myObjectClone.type = arguments.type />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn variables.myObject.type />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setTitle" access="public" returntype="void" output="false">
		<cfargument name="title" type="string" required="true" />
		<cfset variables.myObject.title = arguments.title />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getTitle" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.title = variables.myObject.title />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getTitle"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.title />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setPageSize" access="public" returntype="void" output="false">
		<cfargument name="pageSize" type="numeric" required="true" />
		<cfset variables.myObject.pageSize = arguments.pageSize />
		<cfset variables.myObjectClone.pageSize = arguments.pageSize />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPageSize" access="public" returntype="any" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.pageSize = variables.myObject.pageSize />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getPageSize"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.pageSize />
		
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setPostCount" access="public" returntype="void" output="false">
		<cfargument name="postCount" type="string" required="true" />
		<cfset variables.myObject.postCount = arguments.postCount />
		<cfset variables.myObjectClone.postCount />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPostCount" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.postCount = variables.myObject.postCount />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getPostCount"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.postCount />

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setUrl" access="public" returntype="void" output="false">
		<cfargument name="urlString" type="string" required="true" />
		<cfset variables.myObject.urlString = urlString />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getUrl" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.urlString = variables.myObject.urlString />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getUrlString"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.urlString />
	</cffunction>


</cfcomponent>