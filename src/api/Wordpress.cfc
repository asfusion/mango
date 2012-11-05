<cfcomponent extends="API">

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPage" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<!--- 
			blog_id
    		page_id
    		username
    		password
 			--->
			<cfset var result = arraynew(1) />
			<cfset var post =  ""/>
			<cfset result[1] = structnew() />
			
			<cftry>
				<cfset post = super.getPage(arguments.data[3], arguments.data[4], arguments.data[2]) />
				<cfcatch type="PageNotFound">
					<cfset result[1]["faultCode"] = 0 />
					<cfset result[1]["faultString"] = "Page not found" />
					<cfreturn result />
				</cfcatch>
			</cftry>
			
			<cfset result[1] = makePageResult(post) />
			
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPages" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<!--- 
			 blogid
			usrename
			password
			--->
			<cfset var posts = "" />
			<cfset var i = 1 />
			<cfset var result = arraynew(1) />
			
			<cfset posts = super.getPages(arguments.data[2],arguments.data[3],arguments.data[1]) />
			
			<cfset result[1] = arraynew(1) />
			
			<cfloop index="i" from="1" to="#arraylen(posts)#">
				<cfset result[1][i] = makePageResult(posts[i]) />
			</cfloop>
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPageList" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<!--- 
			 blogid
			usrename
			password
			--->
			<cfset var posts = "" />
			<cfset var i = 1 />
			<cfset var result = arraynew(1) />
			
			<cfset posts = super.getPages(arguments.data[2],arguments.data[3],arguments.data[1]) />
			
			<cfset result[1] = arraynew(1) />
			
			<cfloop index="i" from="1" to="#arraylen(posts)#">
				<cfset result[1][i] = makePageResult(posts[i],"simple") />
			</cfloop>
		<cfreturn result />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newPage" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />

			<cfset var blogId = arguments.data[1] />
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var content = arguments.data[4]  />
			<cfset var publish = 0  />
			<cfset var result = arraynew(1) />
			<cfset var postResult = "" />
			<cfset var local = structnew() />
			
			<cfscript>
				if (arraylen(arguments.data) GTE 5) {
					publish = arguments.data[5];
				}
				
				if (structkeyexists(content, "mt_excerpt"))
					local.excerpt = content.mt_excerpt;
				else 
					local.excerpt = '';
				
				if (structkeyexists(content, "wp_page_parent_id") AND content.wp_page_parent_id NEQ 0)
					local.page_parent_id = content.wp_page_parent_id;
				else
					local.page_parent_id = '';
				
				if (structkeyexists(content, "description"))
					local.description = content.description;
				else 
					local.description = '';
				
				if (structkeyexists(content, "wp_page_order"))
					local.order = content.wp_page_order;
				else 
					local.order = 1;
				
				if (structkeyexists(content, "mt_allow_comments"))
					local.comments_allowed = content.mt_allow_comments;
				else 
					local.comments_allowed = 0;
					
				if (structkeyexists(content, "customFields"))
					local.customFields = content.customFields;
				else 
					local.customFields = structnew();
			</cfscript>
			
			<cfset postResult = super.newPage(username,password,
						content.title,
						local.description,
						local.excerpt,
						publish,
						local.page_parent_id,
						local.order,
						local.comments_allowed,	
						local.customFields,
						blogId) />

			<cfset result[1] = "(string)" & postResult />

		<cfreturn result />
	</cffunction>
	
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePage" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var result = arraynew(1) />
			<cfset var postResult = "" />
			
			<cfset postResult = super.deletePage(arguments.data[2], arguments.data[3], arguments.data[4]) />
			<cfif postResult>
				<cfset result[1] =  "(int) 1" />
			<cfelse>
				<cfset result[1] =  "(int) 0" />
			</cfif>

		<cfreturn result />
	</cffunction>
	
	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editPage" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var blogId = arguments.data[1] />
			<cfset var pageId = arguments.data[2]>
			<cfset var username = arguments.data[3] />
			<cfset var password = arguments.data[4] />
			<cfset var content = arguments.data[5]  />
			<cfset var publish = 0  />
			<cfset var result = arraynew(1) />
			<cfset var postResult = "" />
			<cfset var local = structnew() />
			
			<cfscript>
				if (arraylen(arguments.data) GTE 6) {
					publish = arguments.data[6];
				}
				
				if (structkeyexists(content, "mt_excerpt"))
					local.excerpt = content.mt_excerpt;
				else 
					local.excerpt = '';
				
				if (structkeyexists(content, "wp_page_parent_id") AND content.wp_page_parent_id NEQ 0)
					local.page_parent_id = content.wp_page_parent_id;
				else
					local.page_parent_id = '';
				
				if (structkeyexists(content, "description"))
					local.description = content.description;
				else 
					local.description = '';
				
				if (structkeyexists(content, "wp_page_order"))
					local.order = content.wp_page_order;
				else 
					local.order = 1;
				
				if (structkeyexists(content, "mt_allow_comments"))
					local.comments_allowed = content.mt_allow_comments;
				else 
					local.comments_allowed = 0;
					
				if (structkeyexists(content, "customFields"))
					local.customFields = content.customFields;
				else 
					local.customFields = structnew();
			</cfscript>
			
			<cfset postResult = super.editPage(username,password,pageId,
						content.title,
						local.description,
						local.excerpt,
						publish,
						local.page_parent_id,
						local.order,
						local.comments_allowed,	
						local.customFields,
						blogId) />
			
			<cfif postResult>
				<cfset result[1] =  "(int) 1" />
			<cfelse>
				<cfset result[1] =  "(int) 0" />
			</cfif>

		<cfreturn result />
	</cffunction>
	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthors" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var count = 0 />
			<cfset var authors = super.getAuthors(username,password) />
			<cfset var i = 0 />
			<cfset var result = arraynew(1) />
			<cfset result[1] = arraynew(1) />
						
			<cfloop index="i" from="1" to="#arraylen(authors)#">
				<cfscript>
				result[1][i] = structnew();
				result[1][i]["user_id"] = "(string)" & authors[i].id;
				result[1][i]["user_login"] = "(string)" & authors[i].username;
				result[1][i]["display_name"] = authors[i].name;
				result[1][i]["user_email"] = "(string)" & authors[i].email;
			</cfscript>	
		</cfloop>	
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCategories" access="remote" output="false" returntype="any">
		<cfargument name="data" required="true" type="array" />

			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />

			<cfset var categories = super.getCategories(username,password) />
			<cfset var i = 0 />
			<cfset var result = arraynew(1) />
			<cfset result[1] = arraynew(1) />
						
			<cfloop index="i" from="1" to="#arraylen(categories)#">
				<cfscript>
				result[1][i] = structnew();
				result[1][i]["categoryId"] = "(string)" & categories[i].id;
				result[1][i]["parentId"] = 0;
				result[1][i]["title"] = "(string)" & categories[i].title;
				result[1][i]["description"] = categories[i].description;
				result[1][i]["htmlUrl"] = "(string)" & categories[i].url;
				result[1][i]["rssUrl"] = "(string)" & categories[i].url;		
			</cfscript>	
			</cfloop>	
			<cfreturn result />
	</cffunction>		
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newCategory" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />

			<cfset var blogId = arguments.data[1] />
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var content = arguments.data[4]  />
			<cfset var result = arraynew(1) />
			<cfset var postResult = "" />
			<cfset var local = structnew() />
			
			<cfscript>
				if (structkeyexists(content, "name"))
					local.name = content.name;
				else 
					local.name = '';
				
				if (structkeyexists(content, "description"))
					local.description = content.description;
				else 
					local.description = '';
			</cfscript>
			
			<cfset postResult = super.newCategory(username,password,
						local.name,
						local.description,
						blogId) />

			<cfset result[1] = "(string)" & postResult />

		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteCategory" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var result = arraynew(1) />
			<cfset var postResult = "" />
			
			<cfset postResult = super.deleteCategory(arguments.data[2],arguments.data[3],arguments.data[4],arguments.data[1]) />
			<cfif postResult>
				<cfset result[1] =  "(int) 1" />
			<cfelse>
				<cfset result[1] =  "(int) 0" />
			</cfif>

		<cfreturn result />
	</cffunction>

	<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="uploadFile" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />

			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var object = arguments.data[4]  />
			<cfset var result = arraynew(1) />
			<cfset result[1] = structnew() />
			
			<cfset result[1]["url"] = super.newMediaObject(username, password, object) />

         <cfreturn result />
   </cffunction>

	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getComment" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<cfset var result = arraynew(1) />
			<cfset var obj =  ""/>
			<cfset result[1] = structnew() />
			
			<cftry>
				<cfset obj = super.getComment(arguments.data[2], arguments.data[3], arguments.data[4], arguments.data[1]) />
				<cfcatch type="CommentNotFound">
					<cfset result[1]["faultCode"] = 0 />
					<cfset result[1]["faultString"] = "Comment not found" />
					<cfreturn result />
				</cfcatch>
			</cftry>
			
			<cfset result[1] = makeCommentResult(obj) />
			
		<cfreturn result />
	</cffunction>
	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getComments" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<!--- 
			blog_id, username, password, struct:
    		* post_id
    		* status (approve is good. blank means ALL)
    		* offset
    		* number
			--->
			<cfset var posts = "" />
			<cfset var i = 1 />
			<cfset var count = 10 />
			<cfset var result = arraynew(1) />
			
			<cfif structkeyexists(arguments.data[4], "number")>
				<cfset count = arguments.data[4].number />
			</cfif>
			
			<!--- if no post id, then show all last #number# comments --->
			<cfif structkeyexists(arguments.data[4], "post_id")>
				<cfset posts = super.getComments(arguments.data[2],arguments.data[3],arguments.data[4].post_id,'-1',arguments.data[1]) />
			<cfelse>
				<cfset posts = super.getComments(arguments.data[2],arguments.data[3],'', count,arguments.data[1]) />
			</cfif>
			
			<cfset result[1] = arraynew(1) />
			
			<cfloop index="i" from="1" to="#arraylen(posts)#">
				<cfset result[1][i] = makeCommentResult(posts[i]) />
			</cfloop>
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- wp.deleteComment(blog_id, username, password, comment_id) --->
	<cffunction name="deleteComment" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var result = arraynew(1) />
			<cfset var postResult = "" />
			
			<cfset postResult = super.deleteComment(arguments.data[2],arguments.data[3],arguments.data[4],arguments.data[1]) />
			<cfif postResult>
				<cfset result[1] =  "(int) 1" />
			<cfelse>
				<cfset result[1] =  "(int) 0" />
			</cfif>

		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- wp.editComment(blog_id, username, password, comment_id, {status,
date_created_gmt, content, author, author_url, author_email, })--->
	<cffunction name="editComment" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			
			<cfset var blogId = arguments.data[1] />
			<cfset var commentId = arguments.data[4]>
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var content = arguments.data[5]  />
			<cfset var result = arraynew(1) />
			<cfset var postResult = "" />
			<cfset var local = structnew() />
			
			<cfscript>				
				if (structkeyexists(content, "content"))
					local.description = content.content;
				else 
					local.description = '';
				
				if (structkeyexists(content, "author_email"))
					local.email = content.author_email;
				else 
					local.email = "";
					
				if (structkeyexists(content, "author"))
					local.author = content.author;
				else 
					local.author = "";
				
				if (structkeyexists(content, "author_url"))
					local.author_url = content.author_url;
				else 
					local.author_url = "";
				
				if (structkeyexists(content, "status") AND (content.status EQ "approve" OR content.status EQ 1))
					local.status = 1;
				else 
					local.status = 0;
			</cfscript>
			
			<cfset postResult = super.editComment(username,password,commentId,
						local.description,
						local.author,
						local.email,
						local.author_url,
						local.status,
						blogId) />
			
			<cfif postResult>
				<cfset result[1] =  "(int) 1" />
			<cfelse>
				<cfset result[1] =  "(int) 0" />
			</cfif>

		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- wp.newComment(blog_id, username, password, post, {content, author,
author_email, author_url})
// author info is optional if authorization is successful. User must auth. --->
	<cffunction name="newComment" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />

			<cfset var blogId = arguments.data[1] />
			<cfset var username = arguments.data[2] />
			<cfset var password = arguments.data[3] />
			<cfset var post = arguments.data[4] />
			<cfset var content = arguments.data[5]  />
			<cfset var result = arraynew(1) />
			<cfset var postResult = "" />
			<cfset var local = structnew() />
			<cfset var authorInfo = getUserInfo(username, password) />
			
			<cfscript>
				if (structkeyexists(content, "author"))
					local.name = content.author;
				else 
					local.name = authorInfo.name;
					
				if (structkeyexists(content, "author_email"))
					local.email = content.author_email;
				else 
					local.email = authorInfo.email;
					
				if (structkeyexists(content, "author_url"))
					local.url = content.author_url;
				else 
					local.url = '';
				
				if (structkeyexists(content, "content"))
					local.description = content.content;
				else 
					local.description = '';
			</cfscript>
			
			<cfset postResult = super.newComment(username,password,post,
						local.description,
						local.name,
						local.email,
						local.url,
						true) />

			<cfset result[1] = "(string)" & postResult />

		<cfreturn result />
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPostStatusList" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<cfset var result = arraynew(1) />
			<cfset var obj =  structnew() />
			
			<cfset obj["published"] = "Published">
			<cfset obj["draft"] = "Draft">
			
			<cfset result[1] = obj />						
			
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPageStatusList" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<cfset var result = arraynew(1) />
			<cfset var obj =  structnew() />
			
			<cfset obj["published"] = "Published">
			<cfset obj["draft"] = "Draft">
			
			<cfset result[1] = obj />						
			
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!--- wp.getCommentStatusList(blog_id, username, password) --->
	<cffunction name="getCommentStatusList" access="remote" output="false" returntype="array">
		<cfargument name="data" required="true" type="array" />
			<cfset var result = arraynew(1) />
			<cfset var obj =  structnew() />
			
			<cfset obj["hold"] = "Not Approved">
			<cfset obj["approve"] = "Approved">
			
			<cfset result[1] = obj />						
			
		<cfreturn result />
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="makePageResult" access="private">
		<cfargument name="page" required="true" />
		<cfargument name="mode" required="false" default="full" />
			
			<cfset var i = 1 />
			<cfset var result = structnew() />
			<cfset var key = "" />
			<cfset var customFields = arraynew(1) />
			
			<cfloop collection="#page.customFields#" item="key">
				<cfset arrayappend(customFields, page.customFields[key]) />
			</cfloop>
			
			<cfscript>
				result["dateCreated"] = "(dateTime.iso8601)" & now(); //we need to make up a date, since our pages do not have date created
				result["page_parent_id"] = "(string)" & page.parentPageId;
				result["title"] = page.title;
				result["page_id"] = "(string)" & page.id;
				result["date_created_gmt"] = "(dateTime.iso8601)" & now(); //we need to make up a date, since our pages do not have date created
				
				if (mode EQ "full") {
					result["userid"] ="(string)" & page.authorId;
					result["page_status"] = "(string)" & page.status;
					result["link"] = page.permalink;
					result["permalink"] = page.permalink;
					result["description"] = "(string)" & page.content;
					result["excerpt"] = "(string)" & page.excerpt;
					result["text_more"] = "";
					result["wp_slug"] ="(string)" & page.name;
					result["wp_password"] = '';
					result["wp_author"] = page.author;
					result["wp_page_parent_id"] = "(string)" & page.parentPageId;
					result["wp_page_parent_title"] = "";//@TODO not implemented
					result["wp_page_order"] = page.sortOrder;
					result["wp_author_id"] ="(string)" & page.authorId;
					result["wp_author_display_name"] ="(string)" & page.author;
					result["wp_page_template"] ="(string)" & page.template;
					
					if (page.commentsAllowed) 
						result["mt_allow_comments"] = "(int) 1";
					else
						result["mt_allow_comments"] = "(int) 0";
					
					/* @TODO
					trackbacks not yet implemented
					if (page.trackbacks_allowed) {
						result["mt_allow_pings"] = "(int) 1";
					}
					else {
						result["mt_allow_pings"] = "(int) 0";
					} */
					result["mt_allow_pings"] = "(int) 0";
					
					result["categories"] = arraynew(1);
					result["custom_fields"] = arraynew(1);
				
					for (i = 1; i LTE arraylen(customFields); i = i + 1){
						result["custom_fields"][i] = structnew();
						result["custom_fields"][i]["id"] = customFields[i].key;
						result["custom_fields"][i]["key"] = customFields[i].key;
						result["custom_fields"][i]["value"] = customFields[i].value;
					}
				}
				return result;
			</cfscript>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="makeCommentResult" access="private">
		<cfargument name="comment" required="true" />
		
		<cfscript>
			var result = structnew();
			
			result["dateCreated"] = "(dateTime.iso8601)" & comment.createdOn;
			result["parent"] = "(string)" & comment.parentCommentId;
			result["comment_id"] = "(string)" & comment.id;
			result["content"] = comment.content;
			result["post_id"] = "(string)" & comment.entryId;
			result["user_id"] ="(string)" & comment.authorId;
			result["link"] = "";
			
			if (comment.approved) {
				result["status"] = "approve";
				if (isstruct(comment.entry))
					result["link"] = "(string)" & comment.entry.url;
			}
			else {
				result["status"] = "hold";
			}
			
			if (isstruct(comment.entry))
				result["post_title"] = comment.entry.title;
				
			result["author_url"] = comment.creatorUrl;
			result["author"] = comment.creatorName;
			result["author_email"] = comment.creatorEmail;
			result["author_ip"] = "";
			
			return result;
		</cfscript>
	</cffunction>
	
</cfcomponent>