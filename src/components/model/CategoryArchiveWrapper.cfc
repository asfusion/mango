<cfcomponent output="false" extends="ArchiveWrapper">
<cfscript>
	variables.eventNames = structnew();
	variables.eventNames["getPageSize"] = "categoryArchiveGetPageSize";
	variables.eventNames["getTitle"] = "categoryArchiveGetTitle";
	variables.eventNames["getUrlString"] = "categoryArchiveGetUrlString";
	variables.eventNames["getPostCount"] = "categoryArchiveGetPostCount";
	variables.eventNames["getMatch"] = "categoryArchiveGetMatch";
	variables.eventNames["getCategory"] = "categoryArchiveGetCategory";
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
				arguments.archive = variables.objectFactory.createCategoryArchive();
			}

			setInstance(arguments.archive);
			return this;
		</cfscript>
 	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setInstance" output="false" returntype="void" access="package">
		<cfargument name="myObject" type="any" required="true" />
		
			<cfset variables.myObject = arguments.myObject />
			<cfset variables.myObjectClone = variables.myObject.clone(variables.objectFactory.createCategoryArchive()) />

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="reInitInstance" output="false" returntype="void" access="package">
		
		<cfset variables.myObjectClone = variables.myObject.clone(variables.objectFactory.createCategoryArchive()) />
	</cffunction>	


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCategory" access="public" returntype="void" output="false">
		<cfargument name="category" type="Category" required="true" />
		<cfset variables.myObject.category = arguments.category />
		<cfset variables.myObjectClone.category = arguments.category />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCategory" access="public" returntype="Category" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.category = variables.myObject.category />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getCategory"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.category />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setMatch" access="public" returntype="void" output="false">
		<cfargument name="match" required="true" />
		<cfset variables.myObject.match = arguments.match />
		<cfset variables.myObjectClone.match = arguments.match />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getMatch" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />		
		
		<cfset variables.myObjectClone.match = variables.myObject.match />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getMatch"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.match />
		
	</cffunction>

</cfcomponent>