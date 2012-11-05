<cfcomponent name="API">

<!--- use application to get to main Mango component --->
<cfset variables.blogManager = application.blogFacade.getMango() />
<cfset variables.administrator = variables.blogManager.getAdministrator() />

	<cffunction name="getUsersBlogs" access="remote" output="false" returntype="array">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />

			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var blogs = "" />	
			
			<cfif isAuthor>
				<cfset blogs =  variables.administrator.getUsersBlogs(arguments.username) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>	
			
		<cfreturn blogs />
	</cffunction>

	<cffunction name="getRecentPosts" access="remote" output="false" returntype="array">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="maxCount" type="numeric" default="0" required="false" />
		<cfargument name="blogid" type="String" required="false" default="1" hint="Ignored" />
			
			<!--- @TODO: check whether blogid is the same as current, if not, then switch --->
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var posts = variables.administrator.getRecentPosts(arguments.maxCount) />			
		
		<cfreturn posts />
	</cffunction>
	
	<cffunction name="getPages" access="remote" output="false" returntype="array">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="blogid" type="String" required="false" default="1" hint="Ignored" />
			
			<!--- @TODO: check whether blogid is the same as current, if not, then switch --->
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var posts = variables.administrator.getPages() />			
		
		<cfreturn posts />
	</cffunction>	

	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPost" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="postId" type="String" required="true" />
					
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var post = ""/>
			
			<cfif isAuthor>
				<cfset post = variables.administrator.getPost(arguments.postId) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			

		<cfreturn post />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPage" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="pageId" type="String" required="true" />
					
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var post = ""/>
			
			<cfif isAuthor>
				<cfset post = variables.administrator.getPage(arguments.pageId) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			

		<cfreturn post />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newPost" access="remote" output="false" returntype="struct">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		<cfargument name="blogid" type="String" required="false" default="default" hint="" />
		
		<!---@TODO add category array as argument --->
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var authorId = 0 />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset authorId = variables.administrator.getAuthorByUsername(arguments.username).getId() />
				<cfset result = variables.administrator.newPost(arguments.title,arguments.content,"",arguments.publish,authorId) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			
		
		<cfreturn result />
	</cffunction>
	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editPost" access="remote" output="false" returntype="any">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="postId" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		
		<!---@TODO add category array as argument --->
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset result = variables.administrator.editPost(argumentCollection=arguments) />			
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			
		
		<cfreturn result />
	</cffunction>		

	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editPage" access="remote" output="false" returntype="any">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="pageId" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		<cfargument name="parentPage" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="sortOrder" type="numeric" required="false" default="1" />
		<cfargument name="excerpt" type="string" required="false" default="" />
		<cfargument name="allowComments" type="boolean" required="false" default="true" hint="" />
		<cfargument name="customFields" required="false" type="struct">
		<cfargument name="blogid" type="String" required="true" />
		
		<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
		<cfset var result = "" />
			
		<cfif isAuthor>
			<cfset result = variables.administrator.editPage(argumentCollection=arguments) />			
		<cfelse>
			<!--- throw error --->
			<cfthrow message="Authentication failed." type="login.failed">
		</cfif>			
		
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePost" access="remote" output="false" returntype="any">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="postId" type="String" required="true" />
		
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset result = variables.administrator.deletePost(arguments.postId) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			
		
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePage" access="remote" output="false" returntype="any">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="pageId" type="String" required="true" />
		
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset result = variables.administrator.deletePage(arguments.pageId) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			
		
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newPage" access="remote" output="false" returntype="struct">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="blogid" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		<cfargument name="parentPage" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="sortOrder" type="numeric" required="false" default="1" />
		<cfargument name="excerpt" type="string" required="false" default="" />
		<cfargument name="allowComments" type="boolean" required="false" default="true" hint="" />
		<cfargument name="customFields" required="false" type="struct">
		
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset arguments.authorId = variables.administrator.getAuthorByUsername(arguments.username).getId() />				
				<cfset result = variables.administrator.newPage(argumentCollection=arguments) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			
		
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getUserInfo" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
			<cfset var author = ""/>
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfif isAuthor>
				<cfset author = variables.administrator.getAuthorByUsername(arguments.username) />
			</cfif>
			
		<cfreturn author />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthors" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
			<cfset var authors = ""/>
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfif isAuthor>
				<cfset authors = variables.administrator.getAuthors() />
			</cfif>
			
		<cfreturn authors />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCategories" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="blogid" type="String" required="false" default="1" hint="" />
			
			<cfreturn variables.administrator.getCategories(arguments.blogId) />
	</cffunction>		

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newCategory" access="remote" output="false" returntype="struct">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="description" type="string" required="true" />		
		<cfargument name="blogid" type="String" required="false" default="default" hint="" />
		
		
		<<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var authorId = 0 />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset authorId = variables.administrator.getAuthorByUsername(arguments.username).getId() />
				<cfset result = variables.administrator.newCategory(arguments.title,arguments.description) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>
		
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteCategory" access="remote" output="false" returntype="any">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="categoryId" type="String" required="true" />
		
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset result = variables.administrator.deleteCategory(arguments.categoryId,
						variables.administrator.getAuthorByUsername(arguments.username)) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			
		
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setPostCategories" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="postId" type="String" required="true" />
		<cfargument name="categories" type="array" required="true" />
		
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset result = variables.administrator.setPostCategories(arguments.postId,arguments.categories) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>		

		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getComment" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="commentId" type="String" required="true" />
					
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var post = ""/>
			
			<cfif isAuthor>
				<cfset post = variables.administrator.getComment(arguments.commentId) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			

		<cfreturn post />
	</cffunction>

	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getComments" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="entryId" type="String" required="false" default="" />
		<cfargument name="count" type="numeric" required="false" default="10" />
		
			<cfset var comments = ""/>
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfif isAuthor>
				<cfif entryId NEQ "">
					<cfset comments = variables.administrator.getPostComments(arguments.entryId) />
				<cfelse>
					<cfset comments = variables.administrator.getComments(arguments.count)>
				</cfif>
				
			</cfif>
			
		<cfreturn comments />
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editComment" access="remote" output="false" returntype="any">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="commentId" type="String" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="creatorName" type="string" required="true" />
		<cfargument name="creatorEmail" type="string" required="true" />
		<cfargument name="creatorUrl" type="string" required="false" default="" />		
		<cfargument name="approved" type="string" required="false" default="" />
		<cfargument name="blogid" type="String" required="true" />
		
		<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
		<cfset var result = "" />
			
		<cfif isAuthor>
			<cfset arguments.user =	variables.administrator.getAuthorByUsername(arguments.username) />
			<cfset result = variables.administrator.editComment(argumentCollection=arguments) />			
		<cfelse>
			<!--- throw error --->
			<cfthrow message="Authentication failed." type="login.failed">
		</cfif>			
		
		<cfreturn result />
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newComment" access="remote" output="false" returntype="struct">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />		
		<cfargument name="entryId" type="String" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="creatorName" type="string" required="true" />
		<cfargument name="creatorEmail" type="string" required="true" />
		<cfargument name="creatorUrl" type="string" required="false" default="" />		
		<cfargument name="approved" type="string" required="false" default="" />		
		<cfargument name="isImport" required="false" type="boolean" default="false" />
		<cfargument name="createdOn" required="false" type="date" default="#now()#" />
		<cfargument name="blogid" type="String" required="false" default="default" hint="" />
		
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset arguments.user =	variables.administrator.getAuthorByUsername(arguments.username) />
				<cfset result = variables.administrator.newComment(argumentCollection=arguments) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>
		
		<cfreturn result />
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteComment" access="remote" output="false" returntype="any">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="commentId" type="String" required="true" />
		
			<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
			<cfset var result = "" />
			
			<cfif isAuthor>
				<cfset result = variables.administrator.deleteComment(arguments.commentId,
						variables.administrator.getAuthorByUsername(arguments.username)) />
			<cfelse>
				<!--- throw error --->
				<cfthrow message="Authentication failed." type="login.failed">
			</cfif>			
		
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newMediaObject" access="remote" output="false" returntype="string">
      <cfargument name="username" type="String" required="true" />
      <cfargument name="password" type="String" required="true" />
      <cfargument name="object" type="struct" required="true" />

		<cfset var isAuthor = variables.administrator.checkCredentials(arguments.username,arguments.password) />
		<cfset var blog = variables.blogManager.getBlog() />
		<cfset var assetsSettings = blog.getSetting('assets') />
		<cfset var folder = assetsSettings.directory />
		<cfset var fileUrl = "" />
		
		<cfif find("/", assetsSettings.path) EQ 1>
			<!--- absolute path, prepend only domain --->
			<cfset fileUrl = GetHostFromURL(blog.getUrl()) & assetsSettings.path />
		<cfelse>
			<cfset fileUrl = blog.getUrl() & assetsSettings.path />
		</cfif>
		
		<cfif isAuthor>
			<cfif listfirst(arguments.object.type,"/") EQ "image">
				<cfset folder = folder & "images/" />
				<cfset fileUrl = fileUrl & "images/" />
				
				<cfif NOT directoryexists(folder)>
					<cfdirectory action="create" directory="#folder#">
				</cfif>
			</cfif>
			
			<cfset fileUrl = fileUrl & arguments.object.name />
         
            <!--- Save the bits to disk --->
            <cffile action="write" file="#folder##arguments.object.name#" output="#arguments.object.bits#" />
         <cfelse>
            <!--- throw error --->
            <cfthrow message="Authentication failed." type="login.failed">
         </cfif>

         <cfreturn fileUrl />
   </cffunction>
	
	<cfscript>
	/**
 * Returns the host from a specified URL.
 * RE fix for MX, thanks to Tom Lane
 * 
 * @param this_url 	 URL to parse. (Required)
 * @return Returns a string. 
 * @author Shawn Seley (shawnse@aol.com) 
 * @version 2, August 23, 2002 
 */
function GetHostFromURL(this_url) {
	var first_char       = "";
	var re_found_struct  = "";
	var num_expressions  = 0;
	var num_dots         = 0;
	var this_host        = "";
	
	this_url = trim(this_url);
	
	first_char = Left(this_url, 1);
	if (Find(first_char, "./")) {
		return "";   // relative URL = no host   (ex: "../dir1/filename.html" or "/dir1/filename.html")
	} else if(Find("://", this_url)){
		// absolute URL    (ex: "pass@ftp.host.com">ftp://user:pass@ftp.host.com")
		re_found_struct = REFind("[^@]*@([^/:\?##]+)|([^/:\?##]+)", this_url, Find("://", this_url)+3, "True");
	} else {
		// abbreviated URL (ex: "user:pass@ftp.host.com")
		re_found_struct = REFind("[^@]*@([^/:\?##]+)|([^/:\?##]+)", this_url, 1, "True");
	}
	
	if (re_found_struct.pos[1] GT 0) {
		num_expressions = ArrayLen(re_found_struct.pos);
                if(re_found_struct.pos[num_expressions] is 0) num_expressions = num_expressions - 1;
		this_host = Mid(this_url, re_found_struct.pos[num_expressions], re_found_struct.len[num_expressions]);
		num_dots = (Len(this_host) - Len(Replace(this_host, ".", "", "ALL")));;
		if ((not FindOneOf("/@:", this_url)) and (num_dots LT 2)){
			// since this URL doesn't contain any "/" or "@" or ":" characters and since the "host" has fewer than two dots (".")
			// then it is probably actually a file name
			return ""; 
		}
		return this_host;
	} else {
		return "";
	}
}
</cfscript>
</cfcomponent>
