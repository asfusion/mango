<cfcomponent extends="EntryWrapper">

<cfscript>
	variables.eventNames = structnew();
	variables.eventNames["getId"] = "postGetId";
	variables.eventNames["getName"] = "postGetName";
	variables.eventNames["getTitle"] = "postGetTitle";
	variables.eventNames["getContent"] = "postGetContent";
	variables.eventNames["getExcerpt"] = "postGetExcerpt";
	variables.eventNames["getAuthorId"] = "postGetAuthorId";
	variables.eventNames["getAuthor"] = "postGetAuthor";
	variables.eventNames["getCommentsAllowed"] = "postGetCommentsAllowed";
	variables.eventNames["getStatus"] = "postGetStatus";
	variables.eventNames["getLastModified"] = "postGetLastModified";
	variables.eventNames["getUrl"] = "postGetUrl";
	variables.eventNames["getCommentCount"] = "postGetCommentCount";
	variables.eventNames["getInstanceData"] = "postGetInstanceData";
	variables.eventNames["getPostedOn"] = "postGetPostedOn";
	variables.eventNames["getCategories"] = "postGetCategories";
	variables.eventNames["getCustomField"] = "postGetCustomField";
	variables.eventNames["getPermalink"] = "postGetPermalink";
</cfscript>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" output="false" returntype="any" access="public">
		<cfargument name="pluginQueue" type="any" required="true" />
		<cfargument name="objectFactory" type="any" required="true" />
		<cfargument name="post" type="any" required="false" default="#CreateObject('component', 'ObjectFactory').createPost()#" />
		
		<cfscript>
			variables.pluginQueue = arguments.pluginQueue;
			variables.objectFactory = arguments.objectFactory;

			setInstance(arguments.post);
			return this;
		</cfscript>
 	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setInstance" output="false" returntype="any" access="package">
		<cfargument name="myObject" type="any" required="true" />
		
			<cfset variables.myObject = arguments.myObject />
			<cfset variables.myObjectClone = variables.myObject.clone(variables.objectFactory.createPost()) />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPostedOn" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.postedOn = variables.myObject.postedOn />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getPostedOn"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.postedOn />
				
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setPostedOn" access="public" returntype="void" output="false">
		<cfargument name="posted_on" type="string" required="true" />
			
			<cfset variables.myObject.postedOn = arguments.posted_on />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCategories" access="public" returntype="array" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.categories = variables.myObject.categories />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getCategories"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.categories />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setCategories" access="public" returntype="void" output="false">
		<cfargument name="categories" type="array" required="true" />
		<cfset variables.myObject.setCategories(arguments.categories) />
	</cffunction>

</cfcomponent>