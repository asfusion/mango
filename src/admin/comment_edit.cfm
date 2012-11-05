<cfsilent>
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	<cfparam name="id" default="" />
	<cfparam name="found" default="false" />
	
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlogId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>

	<cfif listfind(currentRole.permissions, "manage_comments") AND structkeyexists(form,"submit")>
		<cfset result = request.formHandler.handleEditComment(form) />
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>

	<!--- get post by id --->
	<cfif NOT len(error)>
	<cftry>
		<cfset comment = request.administrator.getComment(id) />
		<cfset content = comment.getContent() />
		<cfset email = comment.getCreatorEmail() />
		<cfset name = comment.getCreatorName() />
		<cfset website = comment.getCreatorUrl() />
		<cfset approved = comment.getApproved() />
		<cfset createdOn = dateformat(comment.getCreatedOn(),'short') & " " & timeformat(comment.getCreatedOn(),'medium') />
		<cftry>
			<cfset post = request.administrator.getPost(comment.getEntryId()) />
			<cfcatch type="any">
				<cfset post = request.administrator.getPage(comment.getEntryId()) />
			</cfcatch>
		</cftry>
		<cfset found = true />
	<cfcatch type="any">
		<cfset error = cfcatch.message />
	</cfcatch>
	</cftry>
	
	</cfif>
</cfsilent>
<cf_layout page="Comments">

<div id="wrapper">
	
	<div id="content">
	<cfif listfind(currentRole.permissions, "manage_comments")>
	
	<cfif found>
	<cfoutput><h2 class="pageTitle">Comment for entry 
			<a href="#request.blogManager.getBlog().geturl()##post.getUrl()#">#xmlformat(post.getTitle())#</a></h2></cfoutput>
	</cfif>
		<div id="innercontent">
		<cfif len(error)>
			<p class="error"><cfoutput>#error#</cfoutput></p>
		</cfif>
		<cfif len(message)>
			<p class="message"><cfoutput>#message#</cfoutput></p>
		</cfif>
		<cfoutput>
	<cfif found>
		<form method="post" action="comment_edit.cfm">
			<p>
				<label for="creatorName">Name</label>
				<span class="field"><input type="text" id="creatorName" name="creatorName" value="#htmleditformat(name)#" size="40" class="required"/></span>
			</p>
			
			<p>
				<label for="creatorEmail">Email</label>
				<span class="field"><input type="text" id="creatorEmail" name="creatorEmail" value="#htmleditformat(email)#" size="40" class="required email"/></span>
			</p>
			
			<p>
				<label for="creatorUrl">Website</label>
				<span class="field"><input type="text" id="creatorUrl" name="creatorUrl" value="#htmleditformat(website)#" size="40" class="url"/></span>
			</p>
			
			<p>
				<label for="content">Comment</label>
				<span class="field">
					<textarea cols="80" rows="10" id="content" name="content" class="required">#htmleditformat(content)#</textarea></span>
			</p>

			<p>
				<input type="checkbox" id="approved" name="approved" value="yes" <cfif approved>checked="checked"</cfif>/><label for="approved">Approved?</label>
			</p>
				
				
			<div class="actions">
				
				<input type="submit" class="primaryAction" id="submit" name="submit" value="Submit">
				<input type="hidden" name="commentId" value="#id#">
				<input type="hidden" name="id" value="#id#">
				
				<a href="comments.cfm?action=delete&amp;id=#id#&amp;entry_id=#post.getId()#" class="deleteButton">Delete</a>
				<a href="comments.cfm?entry_id=#post.getId()#">Back to comments</a>
			</div>

</form>
</cfif>

		</cfoutput>
		
		</div>
		
		<cfelse>
			<div id="innercontent">
				<p class="infomessage">Your role does not allow you to manage comments</p>
			</div>
		</cfif>
	</div>
</div>

</cf_layout>