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
	<cftry>
		<cfset post = request.administrator.getPost(entry_id) />
		<cfcatch type="any">
			<cftry>
				<cfset post = request.administrator.getPage(entry_id) />
				
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
	return replace(str,chr(10),"<br />","ALL");
}

</cfscript>
</cfsilent>
<cf_layout page="Comments">

<div id="wrapper">
	
	<div id="content">
		<cfoutput><h2 class="pageTitle">Comments for entry 
			<a href="#request.blogManager.getBlog().geturl()##post.getUrl()#">#xmlformat(post.getTitle())#</a></h2></cfoutput>
		
		<div id="innercontent">
		<cfif len(error)>
			<p class="error"><cfoutput>#error#</cfoutput></p>
		</cfif>
		<cfif len(message)>
			<p class="message"><cfoutput>#message#</cfoutput></p>
		</cfif>
		<cfoutput>
		
		<cfif NOT arraylen(comments)><p>No comments</p></cfif>
		<cfloop from="1" to="#arraylen(comments)#" index="i">
			<div<cfif NOT comments[i].getApproved() AND comments[i].getRating() EQ -1> class="spam"<cfelseif NOT i mod 2> class="alternate"</cfif>><a name="#comments[i].getId()#"></a>
			<p><strong>Name:</strong> #comments[i].getCreatorName()# | <strong>E-mail:</strong> <a href='mailto:#comments[i].getCreatorEmail()#'>#comments[i].getCreatorEmail()#</a> | <strong>Website:</strong> <a href="#comments[i].getCreatorUrl()#">#comments[i].getCreatorUrl()#</a></p>
	
		#ParagraphFormat2(htmleditformat(comments[i].getContent()))#

        <p>Posted #dateformat(comments[i].getCreatedOn(),"medium")# #timeformat(comments[i].getCreatedOn(),"short")# | 
		<cfif listfind(currentRole.permissions, "manage_comments")><a href="comment_edit.cfm?id=#comments[i].getId()#">Edit</a> | <a href="#cgi.script_name#?action=delete&amp;id=#comments[i].getId()#&amp;entry_id=#entry_id#" class="deleteButton">Delete</a></cfif></p>
</div>
		</cfloop>
	
	<form method="post" action="comments.cfm">
		<fieldset>
			<legend>Add a comment</legend>
			<p>
				<label for="content">Comment</label>
				<span class="field"><textarea cols="60" rows="10" id="content" name="content" class="required"></textarea></span>
			</p>
			<p>
				<label for="creatorUrl">Website</label>
				<span class="field"><input type="text" id="creatorUrl" name="creatorUrl" size="40" class="url"/></span>
			</p>
								
			<div class="actions">
				<input type="submit" class="primaryAction" id="submit" name="submit" value="Submit" />
				<input type="hidden" name="entry_id" value="#entry_id#" />
			</div>
		</fieldset>
	</form>
		</cfoutput>
		
		</div>
	</div>
</div>

</cf_layout>