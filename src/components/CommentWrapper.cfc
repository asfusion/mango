<cfcomponent name="CommentWrapper">

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" output="false" returntype="any" access="public">
		<cfargument name="pluginQueue" type="any" required="true" />
		<cfargument name="objectFactory" type="any" required="true" />
		<cfargument name="post" type="any" required="false" />

		<cfscript>
			variables.pluginQueue = arguments.pluginQueue;

			variables.objectFactory = arguments.objectFactory;
			if(NOT structKeyExists(arguments, "post"))
			{
				arguments.post = variables.objectFactory.createComment();
			}

			setInstance(arguments.post);
			return this;
		</cfscript>
 	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setInstance" output="false" returntype="void" access="package">
		<cfargument name="myObject" type="any" required="true" />
		
			<cfset variables.myObject = arguments.myObject />
			<cfset variables.myObjectClone = variables.myObject.clone(variables.objectFactory.createComment()) />

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="reInitInstance" output="false" returntype="void" access="package">
		
		<cfset variables.myObjectClone = variables.myObject.clone(variables.objectFactory.createComment()) />
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setId" access="public" returntype="void" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfset variables.myObject.id = arguments.id />
		<cfset variables.myObjectClone.id = arguments.id />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getId" access="public" returntype="string" output="false">
		<cfreturn variables.myObject.id />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setEntryId" access="public" returntype="void" output="false">
		<cfargument name="entry_id" type="string" required="true" />
		<cfset variables.myObject.setEntryId(arguments.entry_id) />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getEntryId" access="public" returntype="string" output="false">
		<cfreturn variables.myObject.entryId />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setContent" access="public" returntype="void" output="false">
		<cfargument name="content" type="string" required="true" />
		<cfset variables.myObject.content = arguments.content />
		<cfset variables.myObjectClone.content = arguments.content />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getContent" access="public" returntype="any" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />		
		
		<cfset event = variables.pluginQueue.createEvent("commentGetContent",eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.content />
		
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCreatorName" access="public" returntype="void" output="false">
		<cfargument name="creator_name" type="string" required="true" />
		<cfset variables.myObject.setCreatorName(arguments.creator_name) />
		<cfset variables.myObjectClone.setCreatorName(arguments.creator_name) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCreatorName" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
				
		<cfset event = variables.pluginQueue.createEvent("commentGetCreatorName",eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.creatorName />

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCreatorEmail" access="public" returntype="void" output="false">
		<cfargument name="creator_email" type="string" required="true" />
		<cfset variables.myObject.setCreatorEmail(arguments.creator_email) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCreatorEmail" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.creatorEmail = variables.myObject.creatorEmail />
		
		<cfset event = variables.pluginQueue.createEvent("commentGetCreatorEmail",eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.getCreatorEmail() />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCreatorUrl" access="public" returntype="void" output="false">
		<cfargument name="creator_url" type="string" required="true" />
		<cfset variables.myObject.setCreatorUrl(arguments.creator_url) />
		<cfset variables.myObjectClone.setCreatorUrl(arguments.creator_url) />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCreatorUrl" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
				
		<cfset event = variables.pluginQueue.createEvent("commentGetCreatorUrl",eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.CreatorUrl />
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setCreatedOn" access="public" returntype="void" output="false">
		<cfargument name="created_on" type="string" required="true" />
		<cfset variables.myObject.setCreatedOn(arguments.created_on) />
		<cfset variables.myObjectClone.setCreatedOn(arguments.created_on) />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getCreatedOn" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset event = variables.pluginQueue.createEvent("commentGetCreatedOn",eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.createdOn />

	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setRating" access="public" returntype="void" output="false">
		<cfargument name="rating" type="numeric" required="true" />
		<cfset variables.myObject.setRating(arguments.rating) />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getRating" access="public" returntype="numeric" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.setRating(variables.myObject.getRating()) />
		
		<cfset event = variables.pluginQueue.createEvent("commentGetRating",eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().getRating() />
		
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setApproved" access="public" returntype="void" output="false">
		<cfargument name="approved" type="string" required="true" />
		<cfset variables.myObject.setApproved(arguments.approved) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getApproved" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.setApproved(variables.myObject.getApproved()) />
		
		<cfset event = variables.pluginQueue.createEvent("commentGetApproved",eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().getApproved() />
	</cffunction>
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setAuthorId" access="public" returntype="void" output="false">
		<cfargument name="author_id" type="string" required="true" />
		<cfset variables.myObject.setAuthorId(arguments.author_id) />
		<cfset variables.myObjectClone.setAuthorId(arguments.author_id) />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthorId" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
				
		<cfset event = variables.pluginQueue.createEvent("commentGetAuthorId",eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.accessObject.authorId />
	</cffunction>
	
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setEntry" access="public" returntype="void" output="false">
		<cfargument name="entry" type="any" required="true" />
		<cfset variables.myObject.setEntry(arguments.entry) />
		<cfset variables.myObjectClone.setEntry(arguments.entry) />
	</cffunction>
	<cffunction name="getEntry" access="public" returntype="any" output="false">
		<cfreturn variables.myObject.entry />
	</cffunction>	

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setParentCommentId" access="public" returntype="void" output="false">
		<cfargument name="parent_comment_id" type="string" required="true" />
		<cfset variables.myObject.setParentCommentId(arguments.parent_comment_id) />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getParentCommentId" access="public" returntype="string" output="false">
		<cfset var event = ""/>
		<cfset var eventData = structnew() />
		<cfset eventData.originalObject = variables.myObject />
		<cfset eventData.accessObject = variables.myObjectClone />
		
		<cfset variables.myObjectClone.setParentCommentId(variables.myObject.getParentCommentId()) />
		
		<cfset event = variables.pluginQueue.createEvent("commentGetParentCommentId",eventData,"ObjectAccess") />
		<cfset event = variables.pluginQueue.broadcastEvent(event) />
		
		<cfreturn event.getAccessObject().getParentCommentId() />
	</cffunction>

</cfcomponent>