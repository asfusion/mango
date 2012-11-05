<cfcomponent name="CommentManager">

	<cfset variables.accessObject = ""> 
	<cfset variables.itemsCache = createObject("component","utilities.Cache") />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
		<cfargument name="accessObject" required="true" type="any">
		<cfargument name="pluginQueue" required="true" type="PluginQueue">
			
			<cfset variables.factory = arguments.accessObject />
			<cfset variables.accessObject = arguments.accessObject.getCommentsGateway()>
			<cfset variables.daoObject = arguments.accessObject.getCommentsManager()>
			<cfset variables.pluginQueue = arguments.pluginQueue />
			
			<cfset variables.mainApp = arguments.mainApp />
			<cfset variables.pagesManager = variables.mainApp.getPagesManager() />
			<cfset variables.postsManager = variables.mainApp.getPostsManager() />
			<cfset variables.objectFactory = variables.mainApp.getObjectFactory()>

			<cfreturn this />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getRecentComments" access="public" output="false" returntype="array">
		<cfargument name="count" required="false" default="5" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the page wrapper"/>
		
		<cfset var commentsQuery = variables.accessObject.getRecent(arguments.count, arguments.adminMode) />
		<cfset var comments =  "" />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfset comments = packageObjects(commentsQuery, 1, 0, arguments.useWrapper, true) />
		
		<cfreturn comments />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- 	getByPost --->	
	<cffunction name="getCommentsByPost" access="public" output="false" returntype="array">
		<cfargument name="entry_id" required="true" type="string" hint="Entry ID"/>
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include non-approved comments"/>
		<cfargument name="useWrapper" required="false" type="boolean" hint="Whether to use the page wrapper"/>
		<cfargument name="orderBy" required="false" type="string" default="DATE-ASC" hint="How to order the comments, defaults to DATE-ASC"/>
		
		<cfset var key = arguments.entry_id />
		<cfset var cached = '' />
		<cfset var commentsQuery = '' />
		<cfset var comments = arraynew(1) />
		<cfset var i = 0 />
		<cfset var to = 0 />
		<cfset var reinit = false />
		<cfset var current = 0 />
		<cfset var start = 0 />
		
		<cfif NOT structkeyexists(arguments, 'useWrapper')>
			<cfset arguments.useWrapper = NOT arguments.adminMode />
		</cfif>
		
		<cfif NOT arguments.adminMode>
			<cfif arguments.useWrapper>
				<cfset key = key & "_1" />
			<cfelse>
				<cfset key = key & "_0" />
			</cfif>
			
			<cfset cached = variables.itemsCache.checkAndRetrieve(key) />
			<cfset reinit = cached.contains AND arguments.useWrapper />
			
			<cfif NOT cached.contains>
				
				<!--- retrieve and cache --->
				<cfset commentsQuery = variables.accessObject.getByPost(arguments.entry_id, false) />
				<cfset cached.value = packageObjects(commentsQuery, 1, 0, arguments.useWrapper) />
				<cfset variables.itemsCache.store(key, cached.value) />
			</cfif>
			
				<!--- create the array we will return --->
				<cfif arguments.count EQ 0>
					<cfset arguments.count = arraylen(cached.value) />
				</cfif>
		
				<cfset to = min(arguments.count + arguments.from - 1, arraylen(cached.value))/>
			
			<!--- if this is a wrapped object, then we need to re-initialize the instance so that the clone is brand new --->
			<cfloop from="#arguments.from#" to="#to#" index="i">
				<cfset current = i />
				<cfif arguments.orderBy EQ "DATE-DESC">
					<cfset current = arraylen(cached.value) - i + 1 />
				</cfif>
				<cfif reinit>
					<cfset cached.value[current].reInitInstance() />
				</cfif>
				<cfset arrayappend(comments, cached.value[current]) />
			</cfloop>
			
			<cfreturn comments />
		<cfelse>
			<cfset commentsQuery = variables.accessObject.getByPost(arguments.entry_id,arguments.adminMode, arguments.orderBy) />
			<cfreturn packageObjects(commentsQuery, arguments.from, arguments.count, arguments.useWrapper) />		
		</cfif>

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCommentById" access="public" output="false" returntype="any">
		<cfargument name="id" required="true" type="string" hint="Id"/>
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include non-approved comments"/>
		
		<cfset var commentsQuery = variables.accessObject.getByID(arguments.id, arguments.adminMode) />
		<cfset var comments = packageObjects(commentsQuery,1,0,NOT arguments.adminMode, true) />
		<cfif NOT commentsQuery.recordcount>
			<cfthrow errorcode="CommentNotFound" message="Comment was not found" type="CommentNotFound">
		</cfif>
		<cfreturn comments[1] />		
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="isDuplicate" access="public" output="false" returntype="boolean">
		<cfargument name="entry_id" required="true" type="string" hint="Entry"/>
		<cfargument name="content" required="true" type="string"  hint="Content to match (exact match)"/>
		<cfargument name="creator_email" required="true" type="string"  hint="Email to match (exact match)"/>
		
		<cfset var commentsQuery = variables.accessObject.search(argumentCollection=arguments) />
		
		<cfreturn commentsQuery.recordcount GT 0 />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="packageObjects" access="private" output="false" returntype="array">
		<cfargument name="objectsQuery" required="true" type="query">
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		<cfargument name="useWrapper" required="false" default="true" type="boolean" hint="Whether to use wrapper"/>
		<cfargument name="addEntry" required="false" default="false" type="boolean" hint="Whether to add entry information (this is very resource intensive, use sparingly)"/>
		
		<cfset var comments = arraynew(1) />
		<cfset var thisObject = "" />
		<cfset var wrapper = "" />
		<cfset var factory =  variables.objectFactory />
		<cfset var entry = "" />
		<cfset var i = 0 />
		<cfset var entries = structnew() />
		<cfset var to = 0 />
		
		<cfif arguments.count EQ 0>
			<cfset arguments.count = objectsQuery.recordcount />
		</cfif>
		
		<cfset to = arguments.count + arguments.from />
		
		<cfoutput query="arguments.objectsQuery">
			<cfset i = i + 1 />
			<cfif i GTE arguments.from AND i LT to>
			
				<cfif arguments.addEntry>
					<cfif NOT structkeyexists(entries, entry_id)>
						<cfif post_id NEQ ""><!--- this is a post, not a page --->
							<cfset entry = variables.postsManager.getPostById(entry_id, NOT arguments.useWrapper, arguments.useWrapper) />
						<cfelse>
							<cfset entry = variables.pagesManager.getPageById(entry_id, NOT arguments.useWrapper, arguments.useWrapper) />
						</cfif>
						<cfset entries[entry_id] = entry />
					</cfif>
					<cfset entry = entries[entry_id] />
				<cfelse>
					<cfset entry = "" />
				</cfif>
				
				<cfset thisObject = factory.createComment() />
				<cfset thisObject.init(id, entry_id, content, creator_name, creator_email, creator_url, created_on, approved, author_id, parent_comment_id, rating, entry) />
				
				<cfif arguments.useWrapper>
					<cfset wrapper =  createObject("component","CommentWrapper").init(variables.pluginQueue, variables.objectFactory, thisObject) />
					<cfset arrayappend(comments,wrapper) />
				<cfelse>
					<cfset arrayappend(comments,thisObject) />
				</cfif>
			</cfif>
		</cfoutput>
		
		<cfreturn comments />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="createEmptyComment" access="public" output="false" returntype="any">
		<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include non-approved comments"/>
		
		<cfset var commentsQuery = querynew("id,entry_id,content,creator_name,creator_email,creator_url,created_on,approved,author_id,parent_comment_id") />
		<cfset var package = "" />
		<cfset queryaddrow(commentsQuery,1) />
		<cfset querysetcell(commentsQuery,"created_on",now()) />
		<cfset package = packageObjects(commentsQuery,1,1,NOT arguments.adminMode) />
		<cfreturn package[1] />		

	</cffunction>	
	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<cffunction name="getCommentCount" output="false" hint="Gets the number of posts" access="public" returntype="numeric">
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include drafts and future posts"/>
		
	<cfreturn variables.accessObject.getCount(variables.mainApp.getBlog().id, arguments.adminMode) />
</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- adding a new comment --->
	<cffunction name="addCommentFromRawData" access="public" output="false" returntype="struct">
		<cfargument name="commentData" required="true" type="struct">
			
			<cfscript>
				var thisObject = "";
				var authorGateway = variables.factory.getAuthorsGateway();
				var authorId = "";
				var valid = "";
				var event = "";
				var newComment = "";
				var newCommentResult = "";
				var message = createObject("component","Message");
				var status = "";
				var returnObj = structnew();
				var msgText = "";
				var eventObj = structnew();
				var data = structnew();
				var i = 0;
				var commentAllowed = true;
				var isDuplicateComment = false;
				
				//get author by email address
				if (len(commentData.comment_email)){
					authorId = authorGateway.getIdByEmail(commentData.comment_email);
				}
				
				message.setType("comment");

				thisObject = createObject("component","model.Comment");
				thisObject.setEntryId(trim(arguments.commentData.comment_post_id));
				thisObject.setContent(trim(arguments.commentData.comment_content));
				thisObject.setCreatorName(trim(arguments.commentData.comment_name));
				thisObject.setCreatorEmail(trim(arguments.commentData.comment_email));
				if (len(arguments.commentData.comment_website) AND NOT findnocase("http://",arguments.commentData.comment_website))
					thisObject.setCreatorUrl("http://" & arguments.commentData.comment_website);
				else
					thisObject.setCreatorUrl(arguments.commentData.comment_website);
				
				if (NOT structkeyexists(arguments.commentData,"comment_created_on")){
					thisObject.setCreatedOn(now());
				}
				else{
					thisObject.setCreatedOn(arguments.commentData.comment_created_on);
				}
				
				thisObject.setApproved(true);
				
				thisObject.setAuthorId(authorId);
				if(structkeyexists(arguments.commentData,"comment_parent")){
					thisObject.setParentCommentId(arguments.commentData.comment_parent);
				}
							
				//call plugins
				eventObj.comment = thisObject;
				eventObj.rawdata = arguments.commentData;
				eventObj.newItem = thisObject;
				//eventObj.changeByUser = arguments.user;
				
				valid = thisObject.isValidForSave();	
				
				if(valid.status){
					//check for duplicates
					isDuplicateComment = isDuplicate(thisObject.getEntryId(), thisObject.getContent(), thisObject.getCreatorEmail());
					commentAllowed = variables.pagesManager.pageAllowsComments(thisObject.getEntryId()) OR 
									 variables.postsManager.postAllowsComments(thisObject.getEntryId());
					
					if (NOT isDuplicateComment AND commentAllowed) {
						event = variables.pluginQueue.createEvent("beforeCommentAdd",eventObj,"Update");
						event.setMessage(message);
						event = variables.pluginQueue.broadcastEvent(event);
				
						thisObject = event.getData().comment;
						valid = thisObject.isValidForSave();
						
						if(event.getContinueProcess() AND valid.status){
						
							newCommentResult = variables.daoObject.create(thisObject);					
								
							if(newCommentResult.status){
								status = "success";
								event = variables.pluginQueue.createEvent("afterCommentAdd",eventObj,"Update");
								event = variables.pluginQueue.broadcastEvent(event);
								thisObject = event.getNewItem();
								//clean up variables
								data.comment_content = "";
								data.comment_email = "";
								data.comment_website = "";
								data.comment_name = "";
								// @TODO: finish this list
									
								if (thisObject.getApproved()) {
									message.setText('Comment posted');
									variables.postsManager.updateEvent("postUpdated|" & thisObject.getEntryId());
									variables.pagesManager.updateEvent("commentUpdated|" & thisObject.getEntryId());
								}
								else if (thisObject.getRating() EQ -1){
									message.setText('Comment submitted but it will be reviewed for possible spam.');
								}
								else {
									message.setText('Comment submitted. You need to wait for moderator approval before comment is made public');
								}
								variables.itemsCache.clear(thisObject.getEntryId() & "_0");
								variables.itemsCache.clear(thisObject.getEntryId() & "_1");
							}
							else{
								status = "error";
								message.setText(newCommentResult.message);
							}
							message.setStatus(status);						
						}
					}			
				}
				
				if (isDuplicateComment) {
					message.setStatus("error");
					message.setText("It looks like you have already posted this comment");
				}
				if (NOT commentAllowed) {
					message.setStatus("error");
					message.setText("Comments not allowed");
				}
				
				if (NOT valid.status) {
					for (i = 1; i LTE arraylen(valid.errors);i=i+1){
						msgText = msgText & "<br />" & valid.errors[i];
					}
					message.setStatus("error");
					message.setText(msgText);
				}
				
			</cfscript>
		<cfset returnObj.data = data />	
		<cfset returnObj.newComment = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>
	
<cffunction name="addComment" access="package" output="false" returntype="struct">
		<cfargument name="comment" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any" default="#structnew()#">
			
			<cfscript>
				var thisObject = arguments.comment;
				var authorGateway = variables.factory.getAuthorsGateway();
				var valid = "";
				var event = "";
				var newResult = "";
				var authorId = "";
				var message = createObject("component","Message");
				var status = "";
				var returnObj = structnew();
				var msgText = "";
				var eventObj = structnew();
				var data = structnew();
				var i = 0;
				var isDuplicateComment = false;
				
				message.setType("comment");
				
				if (NOT isvalid("date",thisObject.getCreatedOn())) {
					thisObject.setCreatedOn(now());
				}
				
				eventObj.comment = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.newItem = thisObject;
				eventObj.changeByUser = arguments.user;
				if (len(thisObject.getCreatorEmail())){
					authorId = authorGateway.getIdByEmail(thisObject.getCreatorEmail());
				}
				thisObject.setAuthorId(authorId);
						
				valid = thisObject.isValidForSave();
				
				if(valid.status){
					//check for duplicates
					isDuplicateComment = isDuplicate(thisObject.getEntryId(), thisObject.getContent(), thisObject.getCreatorEmail());
					
					if (NOT isDuplicateComment) {
					//call plugins
						event = variables.pluginQueue.createEvent("beforeCommentAdd",eventObj,"Update");
						event = variables.pluginQueue.broadcastEvent(event);
				
						thisObject = event.getNewItem();
						valid = thisObject.isValidForSave();
						
						if(event.getContinueProcess() AND valid.status){//plugins must have continue and still valid
									
							newResult = variables.daoObject.create(thisObject);
								
							if(newResult.status){
								status = "success";
								event = variables.pluginQueue.createEvent("afterCommentAdd",eventObj,"Update");
								event = variables.pluginQueue.broadcastEvent(event);
								thisObject = event.getNewItem();
								// @TODO: finish this list
							
								if (thisObject.getApproved()) {
									message.setText('Comment submitted');
									variables.postsManager.updateEvent("postUpdated|" & thisObject.getEntryId());
									variables.pagesManager.updateEvent("commentUpdated|" & thisObject.getEntryId());
								}
								else if (thisObject.getRating() EQ -1){
									message.setText('Comment submitted but it will be moderated for possible spam.');
								}
								else {
									message.setText('Comment submitted. You need to wait for moderator approval before comment is made public');
								}
								variables.itemsCache.clear(thisObject.getEntryId() & "_0");
								variables.itemsCache.clear(thisObject.getEntryId() & "_1");
							}
							else{
								status = "error";
								message.setText(newResult.message);
							}						
							message.setStatus(status);
						}
					}
				}
				
				if (isDuplicateComment) {
					message.setStatus("error");
					message.setText("It looks like you have already posted this comment");
				}
				
				//not valid
				if (NOT valid.status) {
					for (i = 1; i LTE arraylen(valid.errors);i=i+1){
						msgText = msgText & "<br />" & valid.errors[i];
					}
					message.setStatus("error");
					message.setText(msgText);
				}
			</cfscript>
		<cfset returnObj.data = rawData />	
		<cfset returnObj.newComment = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
<cffunction name="editComment" access="package" output="false" returntype="struct">
		<cfargument name="comment" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any">
			
			<cfscript>
				var thisObject = arguments.comment;
				var valid = "";
				var event = "";
				var newResult = "";
				var authorGateway = variables.factory.getAuthorsGateway();
				var message = createObject("component","Message");
				var status = "";
				var returnObj = structnew();
				var msgText = "";
				var eventObj = structnew();
				var data = structnew();
				var authorId = "";
				var i = 0;
				
				message.setType("comment");
				
				//call plugins
				eventObj.rawdata = arguments.rawData;
				eventObj.newItem = arguments.comment;
				eventObj.oldItem = getCommentById(arguments.comment.getId(),true);
				eventObj.changeByUser = arguments.user;
				
				if (len(thisObject.getCreatorEmail())){
					authorId = authorGateway.getIdByEmail(thisObject.getCreatorEmail());
				}
				thisObject.setAuthorId(authorId);
				
				event = variables.pluginQueue.createEvent("beforeCommentUpdate",eventObj,"Update");
				event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getnewItem();
				if(event.getContinueProcess()){
				
					valid = thisObject.isValidForSave();	
					if(valid.status){					
						newResult = variables.daoObject.update(thisObject);					
						
						if(newResult.status){
							status = "success";
							event = variables.pluginQueue.createEvent("afterCommentUpdate",eventObj,"Update");
							event = variables.pluginQueue.broadcastEvent(event);
							thisObject = event.getnewItem();
							// @TODO: finish this list
							
							variables.postsManager.updateEvent("postUpdated|" & thisObject.getEntryId());
							variables.pagesManager.updateEvent("commentUpdated|" & thisObject.getEntryId());
							
							variables.itemsCache.clear(thisObject.getEntryId() & "_0");
							variables.itemsCache.clear(thisObject.getEntryId() & "_1");	
						}
						else{
							status = "error";
						}
						message.setStatus(status);
						message.setText(newResult.message);
					}
					else {
						for (i = 1; i LTE arraylen(valid.errors);i=i+1){
							msgText = msgText & "<br />" & valid.errors[i];
						}
						message.setStatus("error");
						message.setText(msgText);
					}
				}
			</cfscript>
		<cfset returnObj.data = rawData />	
		<cfset returnObj.newComment = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteComment" access="package" output="false" returntype="struct">
		<cfargument name="comment" required="true" type="any">
		<cfargument name="rawData" required="true" type="struct">
		<cfargument name="user" required="false" type="any">
			
			<cfscript>
				var thisObject = arguments.comment;
				var event = "";
				var newResult = "";
				var message = createObject("component","Message");
				var status = "";
				var returnObj = structnew();
				var msgText = "";
				var eventObj = structnew();
				var data = structnew();
				
				message.setType("comment");
				
				//call plugins
				eventObj.comment = thisObject;
				eventObj.rawdata = arguments.rawData;
				eventObj.oldItem = thisObject;
				eventObj.changeByUser = arguments.user;
				
				event = variables.pluginQueue.createEvent("beforeCommentDelete",eventObj,"Delete");
				event = variables.pluginQueue.broadcastEvent(event);
			
				thisObject = event.getoldItem();
				if(event.getContinueProcess()){
			
						newResult = variables.daoObject.delete(thisObject.getId());					
						
						
						if(newResult.status){
							status = "success";
							event = variables.pluginQueue.createEvent("afterCommentDelete",eventObj,"Delete");
							event = variables.pluginQueue.broadcastEvent(event);
							thisObject = event.getoldItem();
							
							variables.postsManager.updateEvent("postUpdated|" & thisObject.getEntryId());
							variables.pagesManager.updateEvent("commentUpdated|" & thisObject.getEntryId());
							
							variables.itemsCache.clear(thisObject.getEntryId() & "_0");
							variables.itemsCache.clear(thisObject.getEntryId() & "_1");
						}
						else{
							status = "error";
						}
						message.setStatus(status);
						message.setText(newResult.message);				
				}
			</cfscript>
		<cfset returnObj.data = rawData />	
		<cfset returnObj.newComment = thisObject />
		<cfset returnObj.message = message />

		<cfreturn returnObj />
	</cffunction>
	
 <!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
 <cffunction name="search" output="false" hint="Search for comments matching the criteria" access="public" returntype="array">
	<cfargument name="entry_id" required="false" type="string" hint="Entry"/>
	<cfargument name="created_since" required="false" hint="Date"/>
	<cfargument name="approved" required="false" type="boolean"  hint="Approved?"/>
	<cfargument name="adminMode" required="false" default="false" type="boolean" hint="Whether to include non-approved comments"/>

	<cfset var commentsQuery = variables.accessObject.search(argumentCollection=arguments) />
	<cfset var comments = packageObjects(commentsQuery,1,0,NOT arguments.adminMode) />
		
	<cfreturn comments />

   </cffunction>

</cfcomponent>