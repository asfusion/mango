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
	<cfset isPost = true />
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
		<cfset entry_id = comment.getEntryId() >
		<cftry>
			<cfset post = request.administrator.getPost( entry_id ) />
			<cfcatch type="any">
				<cfset isPost = false />
				<cfset post = request.administrator.getPage( entry_id ) />
			</cfcatch>
		</cftry>
		<cfset found = true />
	<cfcatch type="any">
		<cfset error = cfcatch.message />
	</cfcatch>
	</cftry>
	</cfif>
	<cfset breadcrumb = [
	{ 'link' = isPost?'posts.cfm':'pages.cfm', 'title' = isPost?"Posts":"Pages" },
	{ 'link' = isPost?'post.cfm?id=#entry_id#':'page.cfm?id=#entry_id#', 'title' = isPost?"Post":"Page" },
	{ 'link' = 'comments.cfm?entry_id=#entry_id#', 'title' = 'Comments' },
	{ 'title' = 'Comment' }] />
</cfsilent>
<cf_layout page="Comments" hierarchy="#breadcrumb#">
	<cfif listfind(currentRole.permissions, "manage_comments")>
		<cfoutput>
	<cfif found>
			<a href="comments.cfm?entry_id=#post.getId()#" class=" text-primary d-inline-flex align-items-center"><i class="bi bi-arrow-left-circle p-2"></i>Back to comments</a>
		<h3 >Comment for entry <a href="#request.blogManager.getBlog().geturl()##post.getUrl()#">#xmlformat(post.getTitle())#</a></h3>
	</cfif>
	<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
	<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>
	<cfif found>
		<form method="post" action="comment_edit.cfm">
		<div class="card card-body">
			<div class="row">
				<div class="mb-3 col">
					<label for="creatorName">#request.i18n.getValue("Name")#</label>
					<input type="text" id="creatorName" name="creatorName" value="#htmleditformat(name)#" size="40" class="required form-control" required />
				</div>
				<div class="mb-3 col">
					<label for="creatorEmail">#request.i18n.getValue("Email")#</label>
					<input type="email" id="creatorEmail" name="creatorEmail" value="#htmleditformat(email)#" size="40" class="required form-control" required/>
				</div>
		</div>

		<div class="mb-3">
				<label for="creatorUrl">#request.i18n.getValue("Website")#</label>
				<input type="text" id="creatorUrl" name="creatorUrl" value="#htmleditformat(website)#" size="40" class="form-control"/>
			</div>

	<div class="mb-3">
				<label for="content">#request.i18n.getValue("Comment")#</label>
				<span class="field">
					<textarea cols="80" rows="10" id="content" name="content" class="required form-control" required>#htmleditformat(content)#</textarea></span>
			</div>

			<div class="mb-3 form-check form-switch">
				<input type="checkbox" id="approved" name="approved" class="form-check-input" value="yes" <cfif approved>checked="checked"</cfif>/>
				<label for="approved">#request.i18n.getValue("Approved")#</label>
			</div>

	</div>
				<input type="submit" class="btn btn-primary my-4" id="submit" name="submit" value="Submit">
				<input type="hidden" name="commentId" value="#id#">
				<input type="hidden" name="id" value="#id#">
</form>

</cfif>

		</cfoutput>
		
		</div>
		
		<cfelse>
			<div id="innercontent">
				<p class="infomessage">Your role does not allow you to manage comments</p>
			</div>
		</cfif>
</cf_layout>