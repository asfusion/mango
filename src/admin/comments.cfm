<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	<cfparam name="entry_id" default="" />
	
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlogId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>

	<cfif listfind(currentRole.permissions, "manage_comments") AND structkeyexists(url,"action") AND url.action EQ "delete">
		<cfset result = request.formHandler.handleDeleteComment(url) />
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	
	<cfif structkeyexists(form,"submit")>
		<cfset result = request.formHandler.handleAddComment(form) />
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>

	<cfset comments = request.administrator.getPostComments(entry_id) />
	<cfset isPost = true />
	<cftry>
		<cfset post = request.administrator.getPost(entry_id) />
		<cfcatch type="any">
			<cftry>
				<cfset post = request.administrator.getPage(entry_id) />
				<cfset isPost = false />
				<cfcatch type="any">
					<cfset error = cfcatch.message/>
				</cfcatch>
			</cftry>
		</cfcatch>
	</cftry>
<cfscript>
/**
 * An &quot;enhanced&quot; version of ParagraphFormat.
 * Added replacement of tab with nonbreaking space char, idea by Mark R Andrachek.
 * Rewrite and multiOS support by Nathan Dintenfas.
 * 
 * @param string 	 The string to format. (Required)
 * @return Returns a string. 
 * @author Ben Forta (ben@forta.com) 
 * @version 3, June 26, 2002 
 */
function ParagraphFormat2(str) {
	//first make Windows style into Unix style
	str = replace(str,chr(13)&chr(10),chr(10),"ALL");
	//now make Macintosh style into Unix style
	str = replace(str,chr(13),chr(10),"ALL");
	//now fix tabs
	str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
	//now return the text formatted in HTML
	return replace(str,chr(10),"<br>","ALL");
}

	breadcrumb = [
		{ 'link' = isPost?'posts.cfm':'pages.cfm', 'title' = isPost?"Posts":"Pages" },
		{ 'link' = isPost?'post.cfm?id=#entry_id#':'page.cfm?id=#entry_id#', 'title' = isPost?"Post":"Page" },
		{ 'title' = 'Comments' }];
</cfscript>
</cfsilent>
<cf_layout page="Comments" hierarchy="#breadcrumb#">
	<cfoutput>
		<h3>Comments for <a href="#request.blogManager.getBlog().geturl()##post.getUrl()#">#htmlEditFormat(post.getTitle())#</a></h3>

	<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
	<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

		<cfif NOT arraylen(comments)><div class="alert alert-info">No comments</div></cfif>

		<cfloop from="1" to="#arraylen(comments)#" index="i">
			<div class="card mb-3">
			<div class="card-header border-bottom d-flex align-items-center justify-content-between"
				<cfif NOT comments[i].getApproved() AND comments[i].getRating() EQ -1> class="spam"
				<cfelseif NOT i mod 2> class="alternate"</cfif>>
				<div><a id="#comments[i].getId()#"></a>
			<strong>Name:</strong> #comments[i].getCreatorName()# | <strong>E-mail:</strong> <a href='mailto:#comments[i].getCreatorEmail()#'>#comments[i].getCreatorEmail()#</a> | <strong>Website:</strong> <a href="#comments[i].getCreatorUrl()#">#comments[i].getCreatorUrl()#</a></div>
			<div>
			<cfif listfind(currentRole.permissions, "manage_comments")><a href="comment_edit.cfm?id=#comments[i].getId()#"><button class="btn btn-outline-info">Edit</button></a>
				<a href="#cgi.script_name#?action=delete&amp;id=#comments[i].getId()#&amp;entry_id=#entry_id#" class="deleteButton">
					<button class="btn btn-outline-danger">Delete</button></a></cfif>
			</div>
		</div>
			<div class="card-body">
				#ParagraphFormat2(htmleditformat(comments[i].getContent()))#
			</div>
        <div class="card-footer">Posted #lsdateformat(comments[i].getCreatedOn(),"medium")# #lstimeformat(comments[i].getCreatedOn(),"short")#
		</div>
</div>
			</div><!--- card --->
		</cfloop>

		<div class="card card-body">
	<form method="post" action="comments.cfm">
		<fieldset>
			<h5>Add a comment</h5>
			<div class="mb-3">
				<textarea cols="60" rows="10" id="content" name="content" class="required form-control"></textarea>
			</div>

			<input type="hidden" name="creatorUrl" size="40" value="#request.blogManager.getBlog().getUrl()#" />

			<div class="actions">
				<input type="submit" class="btn btn-primary" id="submit" name="submit" value="Submit" />
				<input type="hidden" name="entry_id" value="#entry_id#" />
			</div>
		</fieldset>
	</form>
	</div>
	</cfoutput>

	</div>
</div>

</cf_layout>