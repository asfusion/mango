<cfcomponent name="EntryWrapper">

<cfscript>
	variables.eventNames = structnew();
	variables.eventNames["getId"] = "entryGetId";
	variables.eventNames["getName"] = "entryGetName";
	variables.eventNames["getTitle"] = "getTitle";
	variables.eventNames["getContent"] = "getContent";
	variables.eventNames["getExcerpt"] = "getExcerpt";
	variables.eventNames["getAuthorId"] = "getAuthorId";
	variables.eventNames["getAuthor"] = "getAuthor";
	variables.eventNames["getCommentsAllowed"] = "getCommentsAllowed";
	variables.eventNames["getStatus"] = "getStatus";
	variables.eventNames["getLastModified"] = "getLastModified";
	variables.eventNames["getUrl"] = "getUrl";
	variables.eventNames["getCommentCount"] = "getCommentCount";
	variables.eventNames["getInstanceData"] = "getInstanceData";
	variables.eventNames["getCustomField"] = "getCustomField";
</cfscript>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" output="false" returntype="any" access="public">
		<cfargument name="pluginQueue" type="any" required="true" />
		<cfargument name="objectFactory" type="any" required="true" />
		<cfargument name="entry" type="any" required="false" />

		<cfscript>
			variables.pluginQueue = arguments.pluginQueue;
			variables.objectFactory = arguments.objectFactory;

			if(NOT structKeyExists(arguments, "entry"))
			{
				arguments.entry = variables.objectFactory.createEntry();
			}

			setInstance(arguments.entry);
			return this;
		</cfscript>
 	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setInstance" output="false" returntype="any" access="package">
		<cfargument name="myObject" type="any" required="true" />
		
			<cfset variables.myObject = arguments.myObject />
			<cfset variables.myObjectClone = variables.myObject.clone(variables.objectFactory.createEntry()) />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getId" access="public" returntype="string" output="false">
		
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.setId(variables.myObject.getId()) />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getId"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().getId() />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
<cffunction name="setId" access="public" returntype="void" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfset variables.myObject.setId(arguments.id) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPermalink" access="public" returntype="string" output="false">
		
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.permalink = variables.myObject.permalink />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getPermalink"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().permalink />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
<cffunction name="setPermalink" access="public" returntype="void" output="false">
		<cfargument name="permalink" type="string" required="true" />
		<cfset variables.myObject.permalink = arguments.permalink />
	</cffunction>	
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->		
	<cffunction name="getName" access="public" returntype="string" output="false">
		
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.name = variables.myObject.name />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getName"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().name />

	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setName" access="public" returntype="void" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.myObject.setName(arguments.name) />
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

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setTitle" access="public" returntype="void" output="false">
		<cfargument name="title" type="string" required="true" />
		
		<cfset variables.myObject.title = arguments.title />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setContent" access="public" returntype="void" output="false">
		<cfargument name="content" type="string" required="true" />
		<cfset variables.myObject.setContent(arguments.content) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getContent" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.content = variables.myObject.content />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getContent"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.content />
		
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setExcerpt" access="public" returntype="void" output="false">
		<cfargument name="excerpt" type="string" required="true" />
		<cfset variables.myObject.setExcerpt(arguments.excerpt) />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getExcerpt" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.excerpt = variables.myObject.Excerpt />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getExcerpt"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.excerpt />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setAuthorId" access="public" returntype="void" output="false">
		<cfargument name="author_id" type="string" required="true" />
		<cfset variables.myObject.setAuthorId(arguments.author_id) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getAuthorId" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.authorId = variables.myObject.AuthorId />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getAuthorId"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.AuthorId />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setAuthor" access="public" returntype="void" output="false">
		<cfargument name="author" type="string" required="true" />
		<cfset variables.myObject.setAuthor(arguments.author) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getAuthor" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.author = variables.myObject.Author/>
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getAuthor"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.Author />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setCommentsAllowed" access="public" returntype="void" output="false">
		<cfargument name="comments_allowed" type="string" required="true" />
		<cfset variables.myObject.setCommentsAllowed(arguments.comments_allowed) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCommentsAllowed" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.commentsAllowed = variables.myObject.commentsAllowed />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getCommentsAllowed"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.commentsAllowed />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setStatus" access="public" returntype="void" output="false">
		<cfargument name="status" type="string" required="true" />
		<cfset variables.myObject.setStatus(arguments.status) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getStatus" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.Status = variables.myObject.Status />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getStatus"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.Status />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setLastModified" access="public" returntype="void" output="false">
		<cfargument name="last_modified" type="date" required="true" />
		<cfset variables.myObject.setLastModified(arguments.last_modified) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getLastModified" access="public" returntype="date" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.lastModified = variables.myObject.LastModified />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getLastModified"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.LastModified />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setUrl" access="public" returntype="void" output="false">
		<cfargument name="urlString" type="string" required="true" />
		<cfset variables.myObject.setUrl(arguments.urlString) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getUrl" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.urlString = variables.myObject.urlString />

		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getUrl"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.urlString />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setCommentCount" access="public" returntype="void" output="false">
		<cfargument name="commentCount" type="string" required="true" />
		<cfset variables.myObject.setCommentCount(arguments.commentCount) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCommentCount" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.commentCount = variables.myObject.CommentCount />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getCommentCount"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.CommentCount />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setCustomField" access="public" returntype="void" output="false">
		<cfargument name="field_key" type="string" required="true" />
		<cfargument name="field_name" type="string" required="true" />
		<cfargument name="field_value" type="any" required="true" />
		
		<cfset variables.myObject.setCustomField(argumentcollection=arguments) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCustomField" access="public" returntype="struct" output="false">
		<cfargument name="field_key" type="string" required="true" />
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset var customField = variables.myObject.getCustomField(arguments.field_key)>
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.setCustomField(arguments.field_key,customField.name,customField.value) />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getCustomField"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.getCustomField(arguments.field_key) />
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="customFieldExists" access="public" returntype="boolean" output="false">
		<cfargument name="field_key" type="string" required="true" />
		
		<cfreturn variables.myObject.customFieldExists(arguments.field_key) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getInstanceData" access="public" returntype="struct" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset event = variables.pluginQueue.createEvent(variables.eventNames["getInstanceData"],eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.getInstanceData() />
		
	</cffunction>


</cfcomponent>