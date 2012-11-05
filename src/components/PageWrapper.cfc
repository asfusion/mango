<cfcomponent extends="EntryWrapper" hint="This is a wrapper for Page objects. It has the same interface as the normal Page, but does other things such as calling plugins">

<cfscript>
	variables.eventNames = structnew();
	variables.eventNames["getId"] = "pageGetId";
	variables.eventNames["getName"] = "pageGetName";
	variables.eventNames["getTitle"] = "pageGetTitle";
	variables.eventNames["getContent"] = "pageGetContent";
	variables.eventNames["getExcerpt"] = "pageGetExcerpt";
	variables.eventNames["getAuthorId"] = "pageGetAuthorId";
	variables.eventNames["getAuthor"] = "pageGetAuthor";
	variables.eventNames["getCommentsAllowed"] = "pageGetCommentsAllowed";
	variables.eventNames["getStatus"] = "pageGetStatus";
	variables.eventNames["getLastModified"] = "pageGetLastModified";
	variables.eventNames["getUrl"] = "pageGetUrl";
	variables.eventNames["getCommentCount"] = "pageGetCommentCount";
	variables.eventNames["getInstanceData"] = "pageGetInstanceData";
	variables.eventNames["getHierarchy"] = "pageGetHierarchy";
	variables.eventNames["getParentPageId"] = "pageGetParentPageId";
	variables.eventNames["getTemplate"] = "pageGetTemplate";
	variables.eventNames["getSortOrder"] = "pageSetSortOrder";	
	variables.eventNames["getCustomField"] = "pageGetCustomField";
	variables.eventNames["getPermalink"] = "pageGetPermalink";
</cfscript>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" output="false" returntype="any" access="public">
		<cfargument name="pluginQueue" type="any" required="true" />
		<cfargument name="objectFactory" type="any" required="true" />
		<cfargument name="page" type="any" required="false" />

		<cfscript>
			variables.pluginQueue = arguments.pluginQueue;

			variables.objectFactory = arguments.objectFactory;
			if(NOT structKeyExists(arguments, "page"))
			{
				arguments.page = variables.objectFactory.createPage();
			}

			setInstance(arguments.page);
			return this;
		</cfscript>
 	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setInstance" output="false" returntype="any" access="package">
		<cfargument name="myObject" type="any" required="true" />
		
			<cfset variables.myObject = arguments.myObject />
			<cfset variables.myObjectClone = variables.myObject.clone(variables.objectFactory.createPage()) />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getParentPageId" output="false" access="public" returntype="string">
		
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.setParentPageId(variables.myObject.getParentPageId()) />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getParentPageId"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().getParentPageId() />
				
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setParentPageId" output="false" access="public" returntype="void">
		<cfargument name="parent_id" required="true" type="string">
			
			<cfset variables.myObject.setParentPageId(arguments.parent_id) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getTemplate" output="false" access="public" returntype="any">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.setTemplate(variables.myObject.getTemplate()) />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getTemplate"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().getTemplate() />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setTemplate" output="false" access="public" returntype="void">
		<cfargument name="template" required="true">
		<cfset variables.myObject.setTemplate(arguments.template) />
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getHierarchy" output="false" access="public" returntype="any">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.setHierarchy(variables.myObject.getHierarchy()) />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getHierarchy"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().getHierarchy() />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setHierarchy" output="false" access="public" returntype="void">
		<cfargument name="hierarchy" required="true" type="string">
		<cfset variables.myObject.setHierarchy(arguments.hierarchy) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->		
	<cffunction name="getSortOrder" output="false" access="public" returntype="numeric">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.setSortOrder(variables.myObject.getSortOrder()) />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getSortOrder"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().getSortOrder() />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setSortOrder" output="false" access="public" returntype="void">
		<cfargument name="sortOrder" required="true" type="numeric">
		<cfset variables.myObject.setSortOrder(arguments.sortOrder) />
	</cffunction>	


</cfcomponent>