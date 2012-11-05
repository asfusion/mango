<cfcomponent hint="Various functions that return structure-type objects">

<cfset variables.apiHelper = createObject("component","APIService") />

	<cffunction name="getUsersBlogs" access="remote" output="false" returntype="array">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
			
			<cfset var blogs = variables.apiHelper.getUsersBlogs(argumentCollection=arguments) />
			<cfset var result = arraynew(1) />
			<cfset var i = 0 />
			
			<cfloop index="i" from="1" to="#arraylen(blogs)#">
				<cfset result[i] = blogs[i].getInstanceData()/>
			</cfloop>
			
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getRecentPosts" access="remote" output="false" returntype="array">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="maxCount" type="numeric" default="0" required="false" />
		<cfargument name="blogid" type="String" required="false" default="default" hint="Ignored" />
					
			<cfset var posts = variables.apiHelper.getRecentPosts(argumentCollection=arguments) />
			<cfset var result = arraynew(1) />
			<cfset var i = 0 />
			
			<cfloop index="i" from="1" to="#arraylen(posts)#">
				<cfset result[i] = posts[i].getInstanceData()/>
			</cfloop>
			
		<cfreturn result />
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getPages" access="remote" output="false" returntype="array">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="blogid" type="String" required="false" default="default" hint="Ignored" />
					
			<cfset var posts = variables.apiHelper.getPages(argumentCollection=arguments) />
			<cfset var result = arraynew(1) />
			<cfset var i = 0 />
			
			<cfloop index="i" from="1" to="#arraylen(posts)#">
				<cfset result[i] = posts[i].getInstanceData()/>
			</cfloop>
			
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPost" access="remote" output="false" returntype="struct">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="postId" type="String" required="true" />
					
			<cfset var post = variables.apiHelper.getPost(argumentCollection=arguments).getInstanceData() />

		<cfreturn post />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPage" access="remote" output="false" returntype="struct">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="pageId" type="String" required="true" />
			
			<cfset var page = variables.apiHelper.getPage(argumentCollection=arguments).getInstanceData() />

		<cfreturn page />
	</cffunction>	
	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newPost" access="remote" output="false" returntype="string">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		<cfargument name="blogid" type="String" required="false" default="1" hint="Ignored" />
		
		<cfset var result = variables.apiHelper.newPost(argumentCollection=arguments) />
			<cfif result.message.getStatus() EQ "success">
			<cfreturn result.newPost.getId() />
		<cfelse>
			<cfreturn "">
		</cfif>

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newPage" access="remote" output="false" returntype="string">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="excerpt" type="string" required="false" default="" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />
		<cfargument name="parentPage" type="string" required="false" default="" />
		<cfargument name="sortOrder" type="numeric" required="false" default="1" />
		<cfargument name="allowComments" type="boolean" required="false" default="true" hint="" />
		<cfargument name="customFields" required="false" type="struct">
		<cfargument name="blogid" type="String" required="false" default="1" hint="Ignored" />
		
		<cfset var result = variables.apiHelper.newPage(argumentCollection=arguments) />
			<cfif result.message.getStatus() EQ "success">
			<cfreturn result.newPage.getId() />
		<cfelse>
			<cfreturn "">
		</cfif>

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editPage" access="remote" output="false" returntype="boolean">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="pageId" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="excerpt" type="string" required="false" default="" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />
		<cfargument name="parentPage" type="string" required="false" default="" />
		<cfargument name="sortOrder" type="numeric" required="false" default="1" />
		<cfargument name="allowComments" type="boolean" required="false" default="true" hint="" />
		<cfargument name="customFields" required="false" type="struct">
		<cfargument name="blogid" type="String" required="false" default="1" hint="Ignored" />	
		
		<cfset var result = variables.apiHelper.editPage(argumentCollection=arguments) />
		<cfreturn (result.message.getStatus() EQ "success") />

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editPost" access="remote" output="false" returntype="boolean">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="postId" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		
		<cfset var result = variables.apiHelper.editPost(argumentCollection=arguments) />
		<cfreturn (result.message.getStatus() EQ "success") />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePost" access="remote" output="false" returntype="boolean">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="postId" type="String" required="true" />
		
			<cfset var result = variables.apiHelper.deletePost(argumentCollection=arguments) />
			<cfreturn (result.message.getStatus() EQ "success") />

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePage" access="remote" output="false" returntype="boolean">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="pageId" type="String" required="true" />
		
			<cfset var result = variables.apiHelper.deletePage(argumentCollection=arguments) />
			<cfreturn (result.message.getStatus() EQ "success") />

	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getUserInfo" access="remote" output="false" returntype="struct">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
			
			<cfreturn variables.apiHelper.getUserInfo(argumentCollection=arguments).getInstanceData() />

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthors" access="remote" output="false" returntype="array">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
			
			<cfset var objs = variables.apiHelper.getAuthors(argumentCollection=arguments) />
			<cfset var result = arraynew(1) />
			<cfset var i = 0 />

			<cfloop index="i" from="1" to="#arraylen(objs)#">
				<cfset result[i] = objs[i].getInstanceData()/>
			</cfloop>

		<cfreturn result />

	</cffunction>	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCategories" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="blogid" type="String" required="false" default="1" hint="Ignored" />

			<cfset var categories = variables.apiHelper.getCategories(argumentCollection=arguments) />
			<cfset var result = arraynew(1) />
			<cfset var i = 0 />

			<cfloop index="i" from="1" to="#arraylen(categories)#">
				<cfset result[i] = categories[i].getInstanceData()/>
			</cfloop>

		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newCategory" access="remote" output="false" returntype="string">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="description" type="string" required="true" />
		<cfargument name="blogid" type="String" required="false" default="default" hint="Ignored" />
		
		<cfset var result = variables.apiHelper.newCategory(argumentCollection=arguments) />
			<cfif result.message.getStatus() EQ "success">
			<cfreturn result.newCategory.getId() />
		<cfelse>
			<cfreturn "">
		</cfif>

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteCategory" access="remote" output="false" returntype="boolean">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="categoryId" type="String" required="true" />
		<cfargument name="blogid" type="String" required="false" default="default" hint="Ignored" />
		
			<cfset var result = variables.apiHelper.deleteCategory(argumentCollection=arguments) />
			<cfreturn (result.message.getStatus() EQ "success") />

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setPostCategories" access="remote" output="false" returntype="boolean">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="postId" type="String" required="true" />
		<cfargument name="categories" type="array" required="true" />
	
		<cfset var result = variables.apiHelper.setPostCategories(argumentCollection=arguments) />
		<cfreturn (result.message.getStatus() EQ "success") />
		
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getComment" access="remote" output="false" returntype="struct">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="commentId" type="String" required="true" />
		<cfargument name="blogid" type="String" required="false" default="default" hint="Ignored" />

			<cfset var post = variables.apiHelper.getComment(argumentCollection=arguments).getInstanceData() />

		<cfreturn post />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getComments" access="remote" output="false" returntype="array">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="entryId" type="String" required="false" default="" />
		<cfargument name="count" type="numeric" required="false" default="10" />
		<cfargument name="blogid" type="String" required="false" default="default" hint="Ignored" />

			<cfset var objs = variables.apiHelper.getComments(argumentCollection=arguments) />
			<cfset var result = arraynew(1) />
			<cfset var i = 0 />

			<cfloop index="i" from="1" to="#arraylen(objs)#">
				<cfset result[i] = objs[i].getInstanceData()/>
			</cfloop>

		<cfreturn result />

		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newComment" access="remote" output="false" returntype="string">		
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
		
		<cfset var result = variables.apiHelper.newComment(argumentCollection=arguments) />
			<cfif result.message.getStatus() EQ "success">
			<cfreturn result.newComment.getId() />
		<cfelse>
			<cfreturn "">
		</cfif>

	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteComment" access="remote" output="false" returntype="boolean">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="commentId" type="String" required="true" />
		<cfargument name="blogid" type="String" required="false" default="default" hint="Ignored" />
		
			<cfset var result = variables.apiHelper.deleteComment(argumentCollection=arguments) />
			<cfreturn (result.message.getStatus() EQ "success") />

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editComment" access="remote" output="false" returntype="boolean">		
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="commentId" type="String" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="creatorName" type="string" required="true" />
		<cfargument name="creatorEmail" type="string" required="true" />
		<cfargument name="creatorUrl" type="string" required="false" default="" />		
		<cfargument name="approved" type="string" required="false" default="" />
		<cfargument name="blogid" type="String" required="true" />
		
		<cfset var result = variables.apiHelper.editComment(argumentCollection=arguments) />
		<cfreturn (result.message.getStatus() EQ "success") />

	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newMediaObject" access="remote" output="false" returntype="string">
      <cfargument name="username" type="String" required="true" />
      <cfargument name="password" type="String" required="true" />
      <cfargument name="object" type="struct" required="true" />

         <cfset var result = variables.apiHelper.newMediaObject(argumentCollection=arguments) />
         <cfreturn result />

   </cffunction>
</cfcomponent>