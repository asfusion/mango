<cfcomponent name="Aministrator">
	
	<cfset variables.panelIds = structnew() />
	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="applicationManager" required="true" type="any">

			<cfset variables.blogManager = arguments.applicationManager>
		<cfreturn this />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getUsersBlogs" access="public" output="false" returntype="array">
		<cfargument name="username" type="String" required="true" />

			<cfset var blogsManager = variables.blogManager.getBlogsManager() />
			<cfset var blogs =  ""/>
			<cfset var authorsManager = variables.blogManager.getauthorsManager() />
			<cfset var author =  authorsManager.getAuthorByUsername(arguments.username,true) />
			
			<cfset blogs =  blogsManager.getBlogsByAuthor(author.getId()) />
			
		<cfreturn blogs />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="getBlog" access="public" output="false" returntype="any">
		<cfreturn variables.blogManager.getBlog() />			
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthors" access="public" output="false" returntype="array">
		<cfargument name="from" required="false" default="1" type="numeric" hint=""/>
		<cfargument name="count" required="false" default="0" type="numeric" hint=""/>
		
		<cfset var authorsManager = variables.blogManager.getauthorsManager() />
		<cfset var authors =  authorsManager.getAuthorsByBlog(variables.blogManager.getBlog().getId(), 
				arguments.from, arguments.count, true) />
			
		<cfreturn authors />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthor" access="public" output="false" returntype="any">
		<cfargument name="id" type="String" required="true" />
		
			<cfset var authorsManager = variables.blogManager.getauthorsManager() />
			<cfset var author =  authorsManager.getAuthorById(arguments.id,true) />
			
		<cfreturn author />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAuthorByUsername" access="public" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />
		
			<cfset var authorsManager = variables.blogManager.getauthorsManager() />
			<cfset var author =  authorsManager.getAuthorByUsername(arguments.username,true) />
			
		<cfreturn author />
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPages" access="public" output="false" returntype="array">
		<cfargument name="from" type="numeric" default="1" required="false" />
		<cfargument name="count" type="numeric" default="0" required="false" />
				
			<cfset var pagesManager = variables.blogManager.getPagesManager() />
			<cfset var pages = pagesManager.getPages(arguments.from,arguments.count,true) />			
		
		<cfreturn pages />
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getRecentPosts" access="public" output="false" returntype="array">
		<cfargument name="maxCount" type="numeric" default="0" required="false" />
				
			<cfset var postsManager = variables.blogManager.getPostsManager() />
			<cfset var posts = postsManager.getPosts(1,arguments.maxCount,true) />			
		
		<cfreturn posts />
	</cffunction>	

	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPost" access="public" output="false" returntype="any">
		<cfargument name="postId" type="String" required="true" />
					
			<cfset var postsManager = variables.blogManager.getPostsManager() />
			<cfset var post = postsManager.getPostById(arguments.postId,true) />
	
		<cfreturn post />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPage" access="public" output="false" returntype="any">
		<cfargument name="pageId" type="String" required="true" />
					
			<cfset var pagesManager = variables.blogManager.getPagesManager() />
			<cfset var page = pagesManager.getPageById(arguments.pageId,true) />
	
		<cfreturn page />
	</cffunction>		
	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newPost" access="public" output="false" returntype="struct">		
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="excerpt" type="string" required="false" default="" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		<cfargument name="authorId" type="String" required="false" default="1" hint="" />
		<cfargument name="allowComments" type="boolean" required="false" default="true" hint="" />
		<cfargument name="postedOn" type="string" required="false" default="#now()#" hint="" />
		<cfargument name="user" required="false" type="any">
		<cfargument name="customFields" required="false" type="struct">
		<cfargument name="rawData" default="#structnew()#" required="false" type="any">
		<cfargument name="name" type="string" required="false" />
		<cfargument name="categories" type="array" required="false" default="#arraynew(1)#" />
		
		<cfset var postsManager = variables.blogManager.getPostsManager() />
		<cfset var authors = variables.blogManager.getAuthorsManager() />
		<cfset var post = variables.blogManager.getObjectFactory().createPost() />
		<cfset var result = "" />
		<cfset var categoriesManager = variables.blogManager.getCategoriesManager() />
		<cfset var categoryItems = arraynew(1) />
		<cfset var i = 0 />
		<cfset var category = "" />

		<!---make a new post --->
		<cfset post.setAuthorId(arguments.authorId) />
		<cfset post.setContent(arguments.content) />
		<cfset post.setTitle(arguments.title) />
		<cfif structkeyexists(arguments,"name")>
			<cfset post.setName(arguments.name) />
		</cfif>
		<cfset post.setBlogId(variables.blogManager.getBlog().getId()) />
		<cfset post.setCommentsAllowed(arguments.allowComments) />
		<cfset post.setPostedOn(arguments.postedOn) />
		<cfset post.setExcerpt(arguments.excerpt) />
				
		<cfif arguments.publish>
			<cfset post.setStatus("published") />
		<cfelse>
			<cfset post.setStatus("draft") />
		</cfif>
				
		<cfif structkeyexists(arguments,"customFields")>
			<cfset post.customFields = arguments.customFields />
		</cfif>
		
		<!--- ensure we are passed category ids --->
			<cfloop from="1" to="#arraylen(arguments.categories)#" index="i">
				<cftry>
					<cfset category = categoriesManager.getCategoryById(arguments.categories[i], true) />
					<cfset arrayappend(categoryItems,category) />
				<cfcatch type="any">
					<cftry>
						<cfset category = categoriesManager.getCategoryByName(arguments.categories[i], true) />
						<cfset arrayappend(categoryItems,category) />
					<cfcatch type="any"></cfcatch>
					</cftry>
				</cfcatch>
				</cftry>
				
			</cfloop>
			
			<cfset post.setCategories(categoryItems) />
		
		<cfset result = postsManager.addPost(post, arguments.rawData) />
			
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editPost" access="public" output="false" returntype="any">		
		<cfargument name="postId" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="excerpt" type="string" required="false"  />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		<cfargument name="allowComments" type="boolean" required="false" hint="" />
		<cfargument name="postedOn" type="string" required="false" hint="When this post is to be published" />
		<cfargument name="user" required="false" type="any">
		<cfargument name="customFields" required="false" type="struct">
		<cfargument name="rawData" default="#structnew()#" required="false" type="any">
		<cfargument name="name" type="string" required="false" />
		<cfargument name="categories" type="array" required="false" />
		
			<cfset var postsManager = variables.blogManager.getPostsManager() />
			<cfset var post = postsManager.getPostById(arguments.postId,true) />
			<cfset var result = "" />
			<cfset var categoriesManager = variables.blogManager.getCategoriesManager() />
			<cfset var categoryItems = arraynew(1) />
			<cfset var i = 0 />
			<cfset var category = "" />
			
			<!--- populate post --->
			<cfset post.setContent(arguments.content) />
			<cfset post.setTitle(arguments.title) />
			<cfif structkeyexists(arguments,"name")>
				<cfset post.setName(arguments.name) />
			</cfif>

			<cfif structkeyexists(arguments,"excerpt")>
				<cfset post.setExcerpt(arguments.excerpt) />
			</cfif>
				
			<cfif structkeyexists(arguments,"allowComments")>
				<cfset post.setCommentsAllowed(arguments.allowComments) />
			</cfif>
				
			<cfif structkeyexists(arguments,"postedOn")>
				<cfset post.setPostedOn(arguments.postedOn) />
			</cfif>
			
			<cfif structkeyexists(arguments,"customFields")>
				<cfset post.customFields = arguments.customFields />
			</cfif>
			
			<cfif arguments.publish>
				<cfset post.setStatus("published") />
			<cfelse>
				<cfset post.setStatus("draft") />
			</cfif>
			
			<!--- if we aren't passed a category array, then we will keep the old categories --->
			<cfif structkeyexists(arguments,"categories")>
				<!--- ensure we are passed category ids --->
				<cfloop from="1" to="#arraylen(arguments.categories)#" index="i">
					<cftry>
						<cfset category = categoriesManager.getCategoryById(arguments.categories[i], true) />
						<cfset arrayappend(categoryItems,category) />
					<cfcatch type="any">
						<cftry>
							<cfset category = categoriesManager.getCategoryByName(arguments.categories[i], true) />
							<cfset arrayappend(categoryItems,category) />
						<cfcatch type="any"></cfcatch>
						</cftry>
					</cfcatch>
					</cftry>
					
				</cfloop>
				
				<cfset post.setCategories(categoryItems) />
			</cfif>
			<cfif variables.blogManager.isCurrentUserLoggedIn()>
				<cfset result = postsManager.editPost(post, arguments.rawData, variables.blogManager.getCurrentUser()) />
			<cfelse>
				<cfset result = postsManager.editPost(post, arguments.rawData) />
			</cfif>
			
		
		<cfreturn result />
	</cffunction>		

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePost" access="public" output="false" returntype="any">		
		<cfargument name="postId" type="String" required="true" />
		<cfargument name="user" required="false" type="any">
		
			<cfset var postsManager = variables.blogManager.getPostsManager() />
			<cfset var post = postsManager.getPostById(arguments.postId,true) />
			<cfset var result = "" />			
										
				<!--- populate post --->
				<cfset post.setId(arguments.postId) />

				<!--- @TODO decide what to do with raw data argument --->
				<cfset result = postsManager.deletePost(post,structnew()) />
		
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newPage" access="public" output="false" returntype="struct">
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="excerpt" type="string" required="false" default="" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		<cfargument name="parentPage" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="sortOrder" type="numeric" required="false" default="1" />
		<cfargument name="authorId" type="String" required="false" default="1" hint="" />
		<cfargument name="allowComments" type="boolean" required="false" default="true" hint="" />
		<cfargument name="user" required="false" type="any">
		<cfargument name="customFields" required="false" type="struct">
		<cfargument name="rawData" default="#structnew()#" required="false" type="any">
		<cfargument name="name" type="string" required="false" />
		
		<cfset var pagesManager = variables.blogManager.getPagesManager() />
		<cfset var page = variables.blogManager.getObjectFactory().createPage() />
		<cfset var result = "" />

		<!---make a new page --->
		<cfset page.setAuthorId(arguments.authorId) />
		<cfset page.setContent(arguments.content) />
		<cfset page.setTitle(arguments.title) />
		<cfif structkeyexists(arguments,"name")>
			<cfset page.setName(arguments.name) />
		</cfif>
		<cfset page.setTemplate(arguments.template) />
		<cfset page.setParentPageId(arguments.parentPage) />
		<cfset page.setSortOrder(arguments.sortOrder) />
		<cfset page.setCommentsAllowed(arguments.allowComments) />
		<cfset page.setBlogId(variables.blogManager.getBlog().getId()) />
		<cfset page.setExcerpt(arguments.excerpt) />
				
		<cfif arguments.publish>
			<cfset page.setStatus("published") />
		<cfelse>
			<cfset page.setStatus("draft") />
		</cfif>
		
		<cfif structkeyexists(arguments,"customFields")>
			<cfset page.customFields = arguments.customFields />
		</cfif>
				
		<cfset result = pagesManager.addPage(page, arguments.rawData,getAuthor(arguments.authorId)) />
		
		<cfreturn result />
	</cffunction>	
	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editPage" access="public" output="false" returntype="any">		
		<cfargument name="pageId" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="excerpt" type="string" required="false" default="" />
		<cfargument name="publish" type="boolean" required="false" default="true" hint="If false, post will be saved as draft" />		
		<cfargument name="parentPage" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="sortOrder" type="numeric" required="false" default="1" />
		<cfargument name="allowComments" type="boolean" required="false" default="true" hint="" />
		<cfargument name="user" required="false" type="any">
		<cfargument name="customFields" required="false" type="struct">
		<cfargument name="rawData" default="#structnew()#" required="false" type="any">
		<cfargument name="name" type="string" required="false" />
		
		<cfset var pagesManager = variables.blogManager.getPagesManager() />
		<cfset var page = pagesManager.getPageById(arguments.pageId,true) />
		<cfset var result = "" />
							
		<!--- populate post --->
		<cfset page.setContent(arguments.content) />
		<cfset page.setTitle(arguments.title) />
		<cfif structkeyexists(arguments,"name")>
			<cfset page.setName(arguments.name) />
		</cfif>
		<cfset page.setCommentsAllowed(arguments.allowComments) />
		<cfset page.setSortOrder(arguments.sortOrder) />
		<cfset page.setParentPageId(arguments.parentPage) />
		<cfset page.setExcerpt(arguments.excerpt) />
		<cfset page.setTemplate(arguments.template) />
				
		<cfif arguments.publish>
			<cfset page.setStatus("published") />
		<cfelse>
			<cfset page.setStatus("draft") />
		</cfif>
		
		<cfif structkeyexists(arguments,"customFields")>
			<cfset page.customFields = arguments.customFields />
		</cfif>
		
		<cfif variables.blogManager.isCurrentUserLoggedIn()>
			<cfset result = pagesManager.editPage(page, arguments.rawData, variables.blogManager.getCurrentUser()) />
		<cfelse>
			<cfset result = pagesManager.editPage(page, arguments.rawData) />
		</cfif>
			
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePage" access="public" output="false" returntype="any">		
		<cfargument name="pageId" type="String" required="true" />
		<cfargument name="user" required="false" type="any">
		
			<cfset var manager = variables.blogManager.getPagesManager() />
			<cfset var page = manager.getPageById(arguments.pageId,true) />
			<cfset var result = "" />			
										
				<!--- populate post --->
				<cfset page.setId(arguments.pageId) />

				<!--- @TODO decide what to do with raw data argument --->
				<cfset result = manager.deletePage(page,structnew()) />
		
		<cfreturn result />
	</cffunction>	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newAuthor" access="public" output="false" returntype="struct">		
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		<cfargument name="name" type="string" required="true"  />
		<cfargument name="email" type="string" required="true" />
		<cfargument name="description" type="string" required="false" default="" />
		<cfargument name="shortdescription" type="string" required="false" default="" />
		<cfargument name="picture" type="string" required="false" default="" />
		<cfargument name="role" type="string" required="false" default="" />
		<cfargument name="active" type="boolean" required="false" default="true" />
		<cfargument name="user" required="false" type="any">
		
			<cfset var authorsManager = variables.blogManager.getauthorsManager() />
			<cfset var author = variables.blogManager.getObjectFactory().createAuthor() />
			<cfset var result = "" />
			<cfset var blog = structnew()>
			<cfset var blogsArray = arraynew(1) />
			<cfset var roleManager = variables.blogManager.getRolesManager() />
			
			<cfset blog.id = variables.blogManager.getBlog().getId() />
			<cfset blog.role = roleManager.getRoleById(arguments.role) />

			<cfset blogsArray = arraynew(1) />
			<cfset blogsArray[1] = blog />
			<cfset author.setBlogs(blogsArray) />
			<cfset author.setUsername(arguments.username)/>
			<cfset author.setPassword(arguments.password) />
			<cfset author.setName(arguments.name) />
			<cfset author.setEmail(arguments.email) />
			<cfset author.setDescription(arguments.description) />
			<cfset author.setShortDescription(arguments.shortdescription) />
			<cfset author.setPicture(arguments.picture) />			
			<cfset author.active = arguments.active />
			
			<cfset result = authorsManager.addAuthor(author,structnew()) />
		
		<cfreturn result />
	</cffunction>
	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editAuthor" access="public" output="false" returntype="struct">		
		<cfargument name="id" type="string" required="true" />
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		<cfargument name="name" type="string" required="true"  />
		<cfargument name="email" type="string" required="true" />
		<cfargument name="description" type="string" required="false" default="" />
		<cfargument name="shortdescription" type="string" required="false" default="" />
		<cfargument name="picture" type="string" required="false" default="" />
		<cfargument name="role" type="string" required="false" default="" />
		<cfargument name="active" type="boolean" required="false" default="true" />
		<cfargument name="user" required="false" type="any">
		
			<cfset var authorsManager = variables.blogManager.getauthorsManager() />
			<cfset var author = getAuthor(arguments.id) />
			<cfset var result = "" />
			<cfset var i = 0 />
			<cfset var blogid = variables.blogManager.getBlog().getId() />
			
			<cfif len(arguments.role)>
				<!--- set the role for the current blog, if not empty --->
				<cfloop index="i" from="1" to="#arraylen(author.blogs)#">
					<cfif author.blogs[i].id EQ blogid>
						<cfset author.blogs[i].role.id = arguments.role />
					</cfif>
				</cfloop>
			</cfif>
			<cfset author.setUsername(arguments.username)/>
			<cfset author.setPassword(arguments.password) />
			<cfset author.setName(arguments.name) />
			<cfset author.setEmail(arguments.email) />
			<cfset author.setDescription(arguments.description) />
			<cfset author.setShortDescription(arguments.shortdescription) />
			<cfset author.setPicture(arguments.picture) />			
			<cfset author.active = arguments.active />
			<cfset result = authorsManager.editAuthor(author,structnew()) />
		
		<cfreturn result />
	</cffunction>		
		

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editBlog" access="public" output="false" returntype="any">		
		<cfargument name="title" type="string" required="true" />
		<cfargument name="tagline" type="string" required="true" />
		<cfargument name="description" type="string" required="false" default="" />
		<cfargument name="url" type="string" required="false" default="true" hint="" />		
		<cfargument name="skin" type="string" required="false" default="" hint="" />
		<cfargument name="user" required="false" type="any">

			<cfset var blog = variables.blogManager.getBlog().clone() />
			<cfset var result = "" />
				
				<cfif right(arguments.url,1) NEQ "/">
					<cfset arguments.url = arguments.url & "/">
				</cfif>
								
				<cfset blog.setTagline(arguments.tagline) />
				<cfset blog.setTitle(arguments.title) />
				<cfset blog.setdescription(arguments.description) />
				<cfset blog.setUrl(arguments.url) />
				
				<cfif len(arguments.skin)>
					<cfset blog.setSkin(arguments.skin) />
				</cfif>
				
				<cfset blog.setBasePath(GetPathFromURL(arguments.url)) />
				
				<!--- @TODO decide what to do with raw data argument --->
				<cfset result =  variables.blogManager.getBlogsManager().editBlog(blog,structnew(),structnew(),arguments.user) />
			
				<!--- reload app to see changes in live site --->
				<cfset variables.blogManager.reloadConfig() />
		<cfreturn result />
	</cffunction>		

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editSkin" access="public" output="false" returntype="any">		
		<cfargument name="skin" type="string" required="true" />
		<cfargument name="action" type="string" required="true" />
		<cfargument name="user" required="false" type="any">
		
		<cfset var blog =  ""/>
		<cfset var result = "" />
		<cfset var dir = getSkinDirectory() />
		
		<cfif action EQ "set">
			<cfset blog = variables.blogManager.getBlog().clone() />
			<cfset blog.setSkin(arguments.skin) />
			<cfset result =  variables.blogManager.getBlogsManager().editBlog(blog,structnew(),structnew(),arguments.user) />
			<cfset variables.blogManager.reloadConfig() />
		<cfelseif action EQ "delete">
			<!--- delete directory --->
			<cfset result = structnew()/>
			<cfset result.message = createObject("component","Message") />
			
			<cfset result.message.setstatus("success") />
			<cfset result.message.setText("Skin deleted") />
			
			<cftry>
				<cfdirectory directory="#dir##skin#" action="delete" recurse="true">
				<cfcatch type="any">
					<cfset result.message.setStatus("error") />
					<cfset result.message.setText(cfcatch.Message) />
				</cfcatch>
			</cftry>
			
			
		</cfif>
				
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editCategory" access="public" output="false" returntype="any">
		<cfargument name="id" type="String" required="true" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="description" type="string" required="false" default="" />
		<cfargument name="user" required="false" type="any">

			<cfset var category = getCategory(arguments.id) />
			<cfset var result = "" />
				
				<cfset category.setTitle(arguments.title) />
				<cfset category.setdescription(arguments.description) />

				<!--- @TODO decide what to do with raw data argument --->
				<cfset result =  variables.blogManager.getCategoriesManager().editCategory(category,structnew()) />
		
		<cfreturn result />
	</cffunction>


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newCategory" access="public" output="false" returntype="any">
		<cfargument name="title" type="string" required="true" />
		<cfargument name="description" type="string" required="false" default="" />
		<cfargument name="user" required="false" type="any">

			<cfset var category = variables.blogManager.getObjectFactory().createCategory() />
			<cfset var result = "" />
				
				<cfset category.setTitle(arguments.title) />
				<cfset category.setdescription(arguments.description) />
				<cfset category.setBlogId(variables.blogManager.getBlog().getId()) />

				<cfset result =  variables.blogManager.getCategoriesManager().addCategory(category,structnew()) />
		
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteCategory" access="public" output="false" returntype="any">		
		<cfargument name="categoryId" type="String" required="true" />
		<cfargument name="user" required="false" type="any">
		
			<cfset var manager = variables.blogManager.getCategoriesManager() />
			<cfset var category = ""/>
			<cfset var result = structnew() />
			
			<cftry>
				<cfset category = manager.getCategoryById(arguments.categoryId,true) />
				<cfset result = manager.deleteCategory(category, structnew(), arguments.user) />
				
				<cfcatch type="any">
					<cfset result.message = createObject("component","Message") />
					<cfset result.message.setStatus("error") />
					<cfset result.message.setText(cfcatch.Message) />
				</cfcatch>
			</cftry>
		
		<cfreturn result />
	</cffunction>	


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!---	<cffunction name="getUserInfo" access="remote" output="false" returntype="any">
		<cfargument name="username" type="String" required="true" />

			<cfset var author = variables.blogManager.getObjectFactory().createAuthor() />
			<cfset var authors = variables.blogManager.getAuthorsManager() />

				<cfset author = authors.getAuthorByUsername(arguments.username) />

		<cfreturn author />
	</cffunction> --->
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCategory" access="public" output="false" returntype="any">
		<cfargument name="categoryId" type="String" required="true" />
					
			<cfset var categoriesManager = variables.blogManager.getCategoriesManager() />
			<cfset var categories = categoriesManager.getCategoryById(arguments.categoryId,true) />	
			
		<cfreturn categories />
	</cffunction>		

	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCategories" access="public" output="false" returntype="any">
		<cfargument name="blogid" type="String" required="false" default="default" hint="Ignored" />

			<cfset var categoriesManager = variables.blogManager.getCategoriesManager() />
			<cfset var categories = categoriesManager.getCategories("name",true) />	
			
		<cfreturn categories />
	</cffunction>		

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setPostCategories" access="public" output="false" returntype="any">
		<cfargument name="postId" type="String" required="true" />
		<cfargument name="categories" type="array" required="true" />
		
			<cfset var postsManager = variables.blogManager.getPostsManager() />
			<cfset var categoriesManager = variables.blogManager.getCategoriesManager() />
			<cfset var result = "" />
			<cfset var categoryIds = arraynew(1) />
			<cfset var i = 0 />
			<cfset var category = "" />
			<!--- ensure we are passed category ids --->
			<cfloop from="1" to="#arraylen(arguments.categories)#" index="i">
				<cftry>
					<cfset category = categoriesManager.getCategoryById(arguments.categories[i], true) />
					<cfset arrayappend(categoryIds,category.id) />
				<cfcatch type="any">
					<cftry>
						<cfset category = categoriesManager.getCategoryByName(arguments.categories[i], true) />
						<cfset arrayappend(categoryIds,category.id) />
					<cfcatch type="any"></cfcatch>
					</cftry>
				</cfcatch>
				</cftry>
				
			</cfloop>
			
			<cfset result = postsManager.setPostCategories(arguments.postId, categoryIds) />

		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setPostCustomField" access="public" output="false" returntype="any">
		<cfargument name="postId" type="String" required="true" />
		<cfargument name="customField" type="struct" required="true" />
		
			<cfset var postsManager = variables.blogManager.getPostsManager() />
			<cfreturn postsManager.editCustomField(arguments.postId, arguments.customField) />
				
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setPageCustomField" access="public" output="false" returntype="any">
		<cfargument name="pageId" type="String" required="true" />
		<cfargument name="customField" type="struct" required="true" />
		
			<cfset var manager = variables.blogManager.getPagesManager() />
			<cfreturn manager.editCustomField(arguments.pageId, arguments.customField) />
	
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPostComments" access="public" output="false" returntype="array">
		<cfargument name="entry_id" type="string" required="true" />
				
			<cfset var commentsManager = variables.blogManager.getCommentsmanager() />
			<cfset var comments = commentsManager.getCommentsByPost(arguments.entry_id,1,0,true) />			
		
		<cfreturn comments />
	</cffunction>

	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getComment" access="public" output="false" returntype="any">
		<cfargument name="commentId" type="String" required="true" />
					
			<cfset var commentsManager = variables.blogManager.getCommentsManager() />
			<cfset var comment = commentsManager.getCommentById(arguments.commentId,true) />
	
		<cfreturn comment />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newComment" access="public" output="false" returntype="struct">
		<cfargument name="entryId" type="String" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="creatorName" type="string" required="true" />
		<cfargument name="creatorEmail" type="string" required="true" />
		<cfargument name="creatorUrl" type="string" required="false" default="" />		
		<cfargument name="approved" type="string" required="false" default="" />		
		<cfargument name="isImport" required="false" type="boolean" default="false" />
		<cfargument name="createdOn" required="false" type="date" default="#now()#" />
		<cfargument name="user" required="false" type="any">
		
			<cfset var commentsManager = variables.blogManager.getCommentsManager() />
			<cfset var comment = variables.blogManager.getObjectFactory().createComment() />
			<cfset var result = "" />
			<cfset var rawdata = structnew() />
			
			<cfset rawdata.isImport = arguments.isImport />

				<!---make a new page --->
				<cfset comment.setEntryId(arguments.entryId) />
				<cfset comment.setContent(arguments.content) />
				<cfset comment.setcreatorName(arguments.creatorName) />
				<cfset comment.setcreatorEmail(arguments.creatorEmail) />
				<cfset comment.setcreatorUrl(arguments.creatorUrl) />
				<cfset comment.setapproved(arguments.approved) />
				<cfset comment.setCreatedOn(arguments.createdOn) />
				
				<cfif structkeyexists(arguments,"user")>
					<cfset result = commentsManager.addComment(comment,rawdata,arguments.user) />
				<cfelse>
					<cfset result = commentsManager.addComment(comment, rawdata) />
				</cfif>
		
		<cfreturn result />
	</cffunction>	
	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editComment" access="public" output="false" returntype="any">		
		<cfargument name="commentId" type="String" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="creatorName" type="string" required="true" />
		<cfargument name="creatorEmail" type="string" required="true" />
		<cfargument name="creatorUrl" type="string" required="false" default="" />		
		<cfargument name="approved" type="string" required="false" default="" />
		<cfargument name="user" required="false" type="any">
		
			<cfset var commentsManager = variables.blogManager.getCommentsManager() />
			<cfset var comment = commentsManager.getCommentById(arguments.commentId,true) />
			<cfset var result = "" />
							
				<!--- populate post --->
				<cfset comment.setContent(arguments.content) />
				<cfset comment.setCreatorEmail(arguments.creatorEmail) />
				<cfset comment.setCreatorUrl(arguments.creatorUrl) />
				<cfset comment.setCreatorName(arguments.creatorName) />
				<cfset comment.setApproved(arguments.approved) />
				
				<!--- @TODO decide what to do with raw data argument --->
				<cfset result = commentsManager.editComment(comment,structnew(),arguments.user) />
		
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deleteComment" access="public" output="false" returntype="any">		
		<cfargument name="commentId" type="String" required="true" />
		<cfargument name="user" required="false" type="any">
		
			<cfset var manager = variables.blogManager.getCommentsManager() />
			<cfset var comment = ""/>
			<cfset var result = structnew() />
			
			<cftry>
				<cfset comment = manager.getCommentById(arguments.commentId,true) />
				<!--- @TODO decide what to do with raw data argument --->
				<cfset result = manager.deleteComment(comment,structnew(), arguments.user) />
				
				<cfcatch type="any">
					<cfset result.message = createObject("component","Message") />
					<cfset result.message.setStatus("error") />
					<cfset result.message.setText(cfcatch.Message) />
				</cfcatch>
			</cftry>
		
		<cfreturn result />
	</cffunction>	


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="newRole" access="public" output="false" returntype="struct">
		<cfargument name="name" type="String" required="true" />
		<cfargument name="description" type="string" required="true" />
		<cfargument name="permissions" type="string" required="true" />
		<cfargument name="preferences" type="struct" required="false" default="#structnew()#" />
		<cfargument name="rawData" default="#structnew()#" required="false" type="any">
		
			<cfset var rolesManager = variables.blogManager.getRolesManager() />
			<cfset var role = variables.blogManager.getObjectFactory().createRole() />
			<cfset var result = "" />
			
			<cfset role.name = arguments.name />
			<cfset role.description = arguments.description />
			<cfset role.permissions = arguments.permissions />
			<cfset role.preferences = createObject("component","utilities.Preferences").init() />
			<cfif structkeyexists(arguments.preferences,"menuItems")>
				<cfset role.preferences.put("admin","menuItems",arguments.preferences.menuItems) />
			</cfif>
			<cfset result = rolesManager.addRole(role, arguments.rawdata) />
					
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="editRole" access="public" output="false" returntype="struct">
		<cfargument name="id" type="String" required="true" />
		<cfargument name="name" type="String" required="true" />
		<cfargument name="description" type="string" required="true" />
		<cfargument name="permissions" type="string" required="true" />
		<cfargument name="preferences" type="struct" required="false" default="#structnew()#" />
		<cfargument name="rawData" default="#structnew()#" required="false" type="any">
		
			<cfset var rolesManager = variables.blogManager.getRolesManager() />
			<cfset var role = rolesManager.getRoleById(arguments.id) />
			<cfset var result = "" />
			<cfset role.id = arguments.id />
			<cfset role.name = arguments.name />
			<cfset role.description = arguments.description />
			<cfset role.permissions = arguments.permissions />
			
			<cfif structkeyexists(arguments.preferences,"menuItems")>
				<cfset role.preferences.put("admin","menuItems",arguments.preferences.menuItems) />
			</cfif>
			
			<cfset result = rolesManager.editRole(role, arguments.rawdata) />
					
		<cfreturn result />
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getSkins" access="public" output="false" returntype="array">
		<cfset var skins = arraynew(1) />
		<cfset var skin = "" />
		<cfset var dirs = "" />
		<cfset var skindata = "" />
		<cfset var skinxmlfile = "" />
		<cfset var dir = getSkinDirectory() />
			
		<cfdirectory name="dirs" directory="#dir#" action="list">
		
		<cfoutput query="dirs">
			<cfset skinxmlfile = directory & "/" & name & "/skin.xml"/>
			<cfif fileexists(skinxmlfile)>
				<cffile action="read" file="#skinxmlfile#" variable="skindata">
				<cfset skindata = xmlparse(skindata).skin />
				<cfset skin = structnew() />
				<cfset skin.name = skindata.xmlAttributes.name />
				<cfset skin.id = skindata.xmlAttributes.id />
				<cfset skin.lastModified = skindata.xmlAttributes.lastModified />
				<cfset skin.version = skindata.xmlAttributes.version />
				<cfset skin.description = skindata.description.xmltext />
				<cfset skin.thumbnail = skindata.thumbnail.xmltext />
				<cfset skin.author = skindata.author.xmltext />
				<cfset skin.authorUrl = skindata.authorUrl.xmltext />
				<cfset skin.designAuthor = skindata.designAuthor.xmltext />
				<cfset skin.designAuthorUrl = skindata.designAuthorUrl.xmltext />
				<cfif structkeyexists(skindata,"requiresVersion")>
					<cfset skin.requiresVersion = skindata.requiresVersion.xmltext />
				<cfelse><cfset skin.requiresVersion = ""></cfif>
				<cfif structkeyexists(skindata,"license")>
					<cfset skin.license = skindata.license.xmltext />
				<cfelse><cfset skin.license = ""></cfif>
				<cfset arrayappend(skins,skin) />
			</cfif>
		</cfoutput>
		<cfreturn skins />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPlugins" access="public" output="false" returntype="array">
		<cfargument name="type" type="String" required="false" default="user" />
		
			<cfset var dir = variables.blogManager.getBlog().getSetting('plugins').directory & "/#arguments.type#/"/>
			<cfset var allPlugins = createObject("component","PluginLoader").findPlugins(dir) />
			<cfset var activePlugins = arraytolist(variables.blogManager.getPluginQueue().getPluginNames())/>
			<cfset var i = 0/>
			<cfloop from="1" to="#arraylen(allPlugins)#" index="i">
				<cfif listfind(activePlugins,allPlugins[i].id)>
					<cfset allPlugins[i].active = true />
				<cfelse>
					<cfset allPlugins[i].active = false />
				</cfif>
			</cfloop>
			
		<cfreturn allPlugins />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getSkin" access="public" output="false" returntype="any">
		<cfargument name="id" type="String" required="true" />
			<cfset var skin = "" />
			<cfset var skindata = "" />
			<cfset var skinxmlfile = "" />
			<cfset var dir = getSkinDirectory() />
			<cfset var i = 0 />
			<cfset var j = 0 />
			<cfset var pagetemplate = "" />
			<cfset var podLocation = "" />
			<cfset var pods = "" />
			<cfset var pod = "" />
			
			<cfset skinxmlfile = dir & "/" & arguments.id & "/skin.xml"/>
				<cffile action="read" file="#skinxmlfile#" variable="skindata">
				<cfset skindata = xmlparse(skindata).skin />
				<cfset skin = structnew() />
				<cfset skin.name = skindata.xmlAttributes.name />
				<cfset skin.id = skindata.xmlAttributes.id />
				<cfset skin.lastModified = skindata.xmlAttributes.lastModified />
				<cfset skin.version = skindata.xmlAttributes.version />
				<cfset skin.description = skindata.description.xmltext />
				<cfset skin.thumbnail = skindata.thumbnail.xmltext />
				<cfset skin.adminEditorCss = skindata.adminEditorCss.xmltext />
				<cfset skin.license = skindata.license.xmltext />
				<cfset skin.pageTemplates = arraynew(1) />
				
				<cfloop from="1" to="#arraylen(skindata.pageTemplates.xmlchildren)#" index="i">
					<cfset pagetemplate = structnew() />
					<cfset pagetemplate.file = skindata.pageTemplates.xmlchildren[i].xmlattributes.file />
					<cfset pagetemplate.name = skindata.pageTemplates.xmlchildren[i].xmlattributes.name />
					<cfif fileexists("#dir#/#arguments.id#/#pagetemplate.file#")>
						<cfset skin.pageTemplates[i] = pagetemplate />
					</cfif>
				</cfloop>
				
				<cfset skin.adminPageTemplates = structnew() />
				
				<cfif structkeyexists(skindata,"adminPageTemplates")>
					<cfloop from="1" to="#arraylen(skindata.adminPageTemplates.xmlchildren)#" index="i">
						<cfset pagetemplate = structnew() />
						<cfset pagetemplate.file = skindata.adminPageTemplates.xmlchildren[i].xmlattributes.file />
						<cfset pagetemplate.id = skindata.adminPageTemplates.xmlchildren[i].xmlattributes.id />
						<cfif fileexists("#dir#/#arguments.id#/#pagetemplate.file#")>
							<cfset skin.adminPageTemplates[pagetemplate.id] = pagetemplate />
						</cfif>
					</cfloop>
				</cfif>
				
				<cfset skin.podLocations = arraynew(1) />
				
				<cfif structkeyexists(skindata,"podLocations")>
					<cfloop from="1" to="#arraylen(skindata.podLocations.xmlchildren)#" index="i">
						<cfset podLocation = structnew() />
						<cfset podLocation.id = skindata.podLocations.xmlchildren[i].xmlattributes.id />
						<cfset podLocation.name = skindata.podLocations.xmlchildren[i].xmlattributes.name />
						<cfset pods = arraynew(1) />
						
						<cfloop from="1" to="#arraylen(skindata.podLocations.xmlchildren[i].xmlchildren)#" index="j">
							<cfset pod = structnew() />
							<cfset pod.id = skindata.podLocations.xmlchildren[i].xmlchildren[j].xmlattributes.id />
							<cfset pod.title = skindata.podLocations.xmlchildren[i].xmlchildren[j].xmltext />
							<cfset arrayappend(pods,pod) />
						</cfloop>

						<cfset podLocation.pods = pods />
						<cfset skin.podLocations[i] = podLocation />
					</cfloop>
				</cfif>
				
		<cfreturn skin />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="downloadPlugin" access="public" output="false" returntype="any">
		<cfargument name="pluginUrl" type="string" required="true" />
		<cfargument name="user" type="any" required="true" />
			<cfset var updater = variables.blogManager.getUpdater() />
			<cfreturn updater.downloadPlugin(arguments.pluginUrl,arguments.user) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="copyPluginAssets" access="private" output="false" returntype="any">
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="pluginId" type="string" required="true" />
		<cfargument name="type" type="String" required="false" default="user" />
		
			<cfset var blog = variables.blogManager.getBlog()/>
			<cfset var pluginPath = blog.getSetting("pluginsDir") & "#arguments.type#/" & arguments.plugin />
			<cfset var pluginName = ""/>
			<cfset var pluginData = ""/>
			<cfset var xml = ""/>
			<cfset var assetBaseDir = ""/>
			<cfset var assetDir = ""/>
			<cfset var source = ""/>
			<cfset var i = ""/>
			<cfset var assetType = ""/>
			<cfset var result = structnew()/>
			<cfset var id = blog.getId()/>
			<cfset var local = StructNew() />
			
			<cftry>
				<cffile action="read" file="#pluginPath#/plugin.xml" variable="xml" />
				<cfset pluginData = xmlparse(xml).plugin />
				
				<!--- Get the name of the installation directory from the plugin class --->
				<cfset pluginName = ListFirst(pluginData.xmlattributes["class"],".") />
				
				<cfloop list="assets,assetsAdmin" index="assetType">
					<cfif assetType is "assets">
						<cfset assetBaseDir = expandPath("#blog.getBasePath()#/assets/plugins/#pluginName#") />
					<cfelse>
						<cfset assetBaseDir = expandPath("#blog.getBasePath()#/admin/assets/plugins/#pluginName#") />
					</cfif>
					
					<cfif structkeyexists(pluginData,assetType) and arraylen(pluginData[assetType].xmlChildren)>
						<!--- Create assets directory --->
						<cfif not directoryExists(assetBaseDir)>
							<cfdirectory action="create" directory="#assetBaseDir#" />
						</cfif>
						<!--- Loop over assets and copy them --->
						<cfloop index="i" from="1" to="#arraylen(pluginData[assetType].xmlChildren)#">
							<!--- Is the file destination specified? --->
							<cfif structkeyexists(pluginData[assetType].xmlChildren[i].xmlattributes,"dest")>
								<cfset assetDir = assetBaseDir & "/" & pluginData[assetType].xmlChildren[i].xmlattributes["dest"] />
								<cfif not directoryExists(assetDir)>
									<cfdirectory action="create" directory="#assetDir#" />
								</cfif>
							<cfelse>
								<cfset assetDir = assetBaseDir />
							</cfif>
							
							<!--- Copy file... --->
							<cfif structkeyexists(pluginData[assetType].xmlChildren[i].xmlattributes,"file")>
								<cfset source = pluginData[assetType].xmlChildren[i].xmlattributes["file"] />
								<cffile action="copy" source="#pluginPath#/#source#" destination="#assetDir#/#ListLast(source,"\/")#" />
							<!--- ...or copy directory --->
							<cfelseif StructKeyExists(pluginData[assetType].xmlChildren[i].xmlattributes,"dir")>
								<cfset source = pluginData[assetType].xmlChildren[i].xmlattributes["dir"] />
								<cfset copyDirectory(pluginPath & "/" & source,assetDir & "/" & ListLast(source,"\/")) />
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
		
				<cfcatch type="any">
					<!--- log the error --->
					<cfset local.logger = variables.blogManager.getLogger() />
					<cfset local.logger.logObject("warning",cfcatch,"Error while copying assets for plugin #arguments.plugin#",'plugin','PluginInstaller') />
				</cfcatch>
			</cftry>
		
	</cffunction>
		
	<cffunction name="copyDirectory" access="private" output="false" returntype="any">
		<cfargument name="source" type="string" required="true" />
		<cfargument name="dest" type="string" required="true" />
		
		<cfset var list = "" />
		
		<cfdirectory directory="#arguments.source#" action="list" recurse="false" name="list" />
		
		<cfif not directoryExists(arguments.dest)>
			<cfdirectory action="create" directory="#arguments.dest#" />
		</cfif>
		
		<cfloop query="list">
			<cfif list.type is "file">
				<cffile action="copy" source="#arguments.source#/#list.name#" destination="#arguments.dest#/#list.name#" />
			<cfelseif list.type is "dir">
				<cfset copyDirectory(arguments.source & "/" & list.name,arguments.dest & "/" & list.name) />
			</cfif>		
		</cfloop>
	
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deletePluginAssets" access="private" output="false" returntype="any">
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="pluginId" type="string" required="true" />
			<cfset var blog = variables.blogManager.getBlog()/>
			<cfset var id = blog.getId()/>
			<cfset var xml = ""/>
			<cfset var data = ""/>
			<cfset var local = structnew() />

			<cftry>
				<cffile action="read" file="#blog.getSetting("pluginsDir")#user/#arguments.plugin#/plugin.xml" variable="xml" />
				<cfset data = xmlparse(xml).plugin />
				
				<!--- Get the name of the installation directory from the plugin class --->
				<cfset local.pluginDir = ListFirst(data.xmlattributes["class"],".") />
				
				<!--- Delete the assets folders, only if defined in plugin.xml --->
				<cfif structkeyexists(data,"assets") and arraylen(data.assets.xmlChildren)>
					<cfif directoryExists(expandPath("#blog.getBasePath()#/assets/plugins/#local.pluginDir#"))>
						<cfdirectory action="delete" recurse="true" directory="#expandPath("#blog.getBasePath()#/assets/plugins/#local.pluginDir#")#" />
					</cfif>
				</cfif>
				
				<cfif structkeyexists(data,"assetsAdmin") and arraylen(data.assetsAdmin.xmlChildren)>
					<cfif directoryExists(expandPath("#blog.getBasePath()#/admin/assets/plugins/#local.pluginDir#"))>
						<cfdirectory action="delete" recurse="true" directory="#expandPath("#blog.getBasePath()#/admin/assets/plugins/#local.pluginDir#")#" />
					</cfif>
				</cfif>
				
				<cfcatch type="any">
					<!--- log the error --->
					<cfset local.logger = variables.blogManager.getLogger() />
					<cfset local.logger.logObject("warning",cfcatch,"Error while deleting assets for plugin #arguments.plugin#", 'plugin', 'PluginInstaller') />
				</cfcatch>
			</cftry>
		
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="activatePlugin" access="public" output="false" returntype="any">
		<cfargument name="plugin" type="string" required="true" />
		<cfargument name="pluginId" type="string" required="true" />
		<cfargument name="user" required="false" type="any">
		<cfargument name="type" type="String" required="false" default="user" />
			
			<cfset var local = structnew() />
			<cfset var result = structnew()/>
			
			<cfset result.message = createObject("component","Message") />
			
			<!--- try loading the plugin, if ok, then store it in db --->
			<cfset local.pluginLoaded = variables.blogManager.loadPlugin(arguments.plugin, arguments.type) />
			<cfif len(local.pluginLoaded)>
				<cfset local.pluginQueue = variables.blogManager.getPluginQueue() />
				<cfset local.pluginObj = local.pluginQueue.getPlugin(arguments.pluginId)/>
			
				<!--- setup ok, save --->
				<cfset local.activateResult = variables.blogManager.getBlogsManager().activatePlugin(
						variables.blogManager.getBlog().getId(), arguments.plugin, arguments.pluginId, arguments.type) />
				
				<cfif local.activateResult.status EQ "success">
					<cftry>
						<cfset local.pluginResult = local.pluginObj.setup()/>
				
						<cfif structkeyexists(local,"pluginResult") AND isvalid('String', local.pluginResult)>
							<cfset result.message.settext(local.pluginResult)/>
						<cfelse>
							<cfset result.message.settext("Plugin activated")/>
						</cfif>
						<cfset result.message.setstatus("success") />
						
						<!--- Install any plugin assets --->
						<cfset copyPluginAssets(arguments.plugin,arguments.pluginId,arguments.type) />
						
						<cfset variables.blogManager.reloadConfig()/>
						<cfcatch type="any">
							<cfset result.message.setstatus("success") />
							<cfset result.message.settext("Plugin was activated, but it could not be setup: " & cfcatch.Message)/>
							<cfset variables.blogManager.getLogger().logObject("debug",cfcatch, "Error while setting up plugin",'plugin','AdminUtil') />
						</cfcatch>
					</cftry>
				<cfelse>
					<cfset result.message.setstatus("error") />
					<cfset result.message.settext("Plugin was already active")/>
				</cfif>
			<cfelse>
				<cfset result.message.setstatus("error") />
				<cfset result.message.settext("Plugin could not be activated")/>
			</cfif>
			
		<cfreturn result />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="deactivatePlugin" access="public" output="false" returntype="any">
		<cfargument name="plugin" type="String" required="true" />
		<cfargument name="pluginId" type="String" required="true" />
		<cfargument name="type" type="String" required="false" default="user" />

			<cfset var local = structnew() />
			<cfset var result = structnew()/>
		
			<cfset var pluginObj = ""/>
			
			<cfset result.message = createObject("component","Message") />
			<cfset result.message.setstatus("success") />
			<cfset result.message.settext("Plugin de-activated")/>
				
			<cfset pluginObj = variables.blogManager.getPluginQueue().getPlugin(arguments.pluginId)/>
			<cftry>
				<cfset pluginObj.unsetup()/>
				<cfcatch type="any">
					<cfset result.message.settext("Plugin was de-activated, but it was not able to clean up: " & cfcatch.Message)/>
				</cfcatch>
			</cftry>
				
			<!--- Remove any plugin assets --->
			<cfset deletePluginAssets(arguments.plugin,arguments.pluginId) />
			
			<cfset local.activateResult = variables.blogManager.getBlogsManager().deActivatePlugin(
						variables.blogManager.getBlog().getId(), arguments.plugin, arguments.pluginId, arguments.type) />
			
			<cfif local.activateResult.status NEQ "success">
				<cfset result.message.setstatus("error") />
				<cfset result.message.settext("Plugin was not active")/>
			</cfif>
			<cfset variables.blogManager.reloadConfig()/>
			
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="updatePlugin" access="public" output="false" returntype="any">
		<cfargument name="plugin" type="String" required="true" />
		<cfargument name="pluginId" type="String" required="true" />
		<cfargument name="oldVersion" type="String" required="true" />

			<cfset var local = structnew() />
			<cfset var result = structnew()/>
		
			<cfset var pluginObj = ""/>
			
			<cfset result.message = createObject("component","Message") />
			<cfset result.message.setstatus("success") />
			<cfset result.message.settext("Plugin updated")/>
				
			<cfset pluginObj = variables.blogManager.getPluginQueue().getPlugin(arguments.pluginId)/>
			<cftry>
				<cfset pluginObj.upgrade(arguments.oldVersion)/>
				<cfcatch type="any">
					<cfset result.message.setstatus("error") />
					<cfset result.message.settext(cfcatch.Message)/>
				</cfcatch>
			</cftry>
				
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="removePlugin" access="public" output="false" returntype="any">
		<cfargument name="plugin" type="String" required="true" />
		<cfargument name="pluginId" type="String" required="true" />
		<cfargument name="user" required="false" type="any">
			<cfset var blog = variables.blogManager.getBlog()/>
			<cfset var pluginsDir = blog.getSetting('pluginsDir')/>
			<cfset var pluginPrefs = createObject("component","SettingManager").init(variables.blogManager, variables.blogManager.getDataAccessFactory()) />
			<cfset var result = structnew()/>
			<cfset var pluginDirectory = pluginsDir & "user/" & arguments.plugin/>
			<cfset var tempQueue = createObject("component","PluginQueue") />
			<cfset var tempLoader = createObject("component","PluginLoader") />
			
			<cfset tempLoader.loadPlugins(arguments.plugin, tempQueue, pluginsDir & "user/", blog.getSetting('pluginsPath') & "user.",
					variables.blogManager, pluginPrefs) />
			
			<cfset result.message = createObject("component","Message") />
			<cfset result.message.setstatus("success") />
			<cfset result.message.settext("Plugin removed")/>
			
			<cfset pluginObj = tempQueue.getPlugin(arguments.pluginId)/>
			<cftry>
				<cfset pluginObj.remove()/>
				<cfcatch type="any">
					<cfset result.message.settext("Plugin was removed, but it was not able to clean up: " & cfcatch.Message)/>
				</cfcatch>
			</cftry>
			
			<!--- delete dir if possible --->
			<cfif directoryExists(pluginDirectory)>
				<cftry>
					<cfdirectory action="delete" recurse="true" directory="#pluginDirectory#">
					<cfcatch type="any">
					<cfset result.message.settext("Plugin was not deleted, please delete manually")/>
					</cfcatch>
				</cftry>
			</cfif>
			
		<cfreturn result />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getPageTemplates" access="public" output="false" returntype="array">

			<cfset var templates = "" />
			<cfset var id = variables.blogManager.getBlog().getSkin() />
			<cfset templates = getSkin(id).pageTemplates />
		
			
		<cfreturn templates />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAdminPageTemplates" access="public" output="false" returntype="struct">

			<cfset var templates = "" />
			<cfset var id = variables.blogManager.getBlog().getSkin() />
			<cfset templates = getSkin(id).adminPageTemplates />
			
		<cfreturn templates />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="downloadSkin" access="public" output="false" returntype="struct">
		<cfargument name="skin" type="String" required="true" />
			<cfset var updater = variables.blogManager.getUpdater() />
			<cfreturn updater.downloadSkin(arguments.skin) />
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="checkCredentials" access="public" output="false" returntype="boolean">
		<cfargument name="username" type="String" required="true" />
		<cfargument name="password" type="String" required="true" />
		<cfargument name="soft" type="boolean" required="false" default="false" />
		
			<cfset var authors = variables.blogManager.getAuthorsManager() />
			<cfif NOT arguments.soft>
				<cfreturn authors.checkCredentials(arguments.username,arguments.password) />
			<cfelse>
				<cfreturn authors.checkSoftCredentials(arguments.username,arguments.password) />
			</cfif>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getSkinDirectory" access="public" output="true" returntype="string">
		<cfset var dir = variables.blogManager.getBlog().getSetting('skins').directory />
		<cfif NOT len(dir)>
			<!--- use default --->
			<cfset dir = replacenocase(GetDirectoryFromPath(GetCurrentTemplatePath()),"components","skins") />
		</cfif>
		<cfreturn dir />
	</cffunction>	

	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCustomPanel" access="public" output="false" returntype="any">
		<cfargument name="id" default="true" type="string" />
		<cfargument name="entryType" default="post" type="string" />
		
		<cfif structkeyexists(variables.panelIds,arguments.id)>
			<cfreturn variables.panelIds[arguments.id].clone() />
		<cfelse>
			<cfreturn createobject("component","model.AdminCustomPanel").init(arguments.entryType) />	
		</cfif>
		
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="addCustomPanel" access="public" output="false" returntype="void">
		<cfargument name="customPanel" />

		<cfset variables.panelIds[arguments.customPanel.id] = arguments.customPanel />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="ftpcopy" access="private" output="false">
		<cfargument name="server" required="true" type="any">
		<cfargument name="username" required="true" type="string">
		<cfargument name="password" required="true" type="string">
		<cfargument name="dir" required="true" type="any">
		<cfargument name="localdir" required="true" type="string">
		
		<cfset var dirs = "" />
		
		<!--- create local dir if needed --->
		<cfif NOT directoryExists(arguments.localdir & arguments.dir)>
			<cfdirectory action="create" directory="#arguments.localdir##arguments.dir#">
		</cfif>
		
		<cfftp server="#arguments.server#"  username="#arguments.username#"  passive="true"
				password="#arguments.password#" action="listdir" name="dirs" directory="#arguments.dir#">
				
		<cfoutput query="dirs">
			<cfif isDirectory>
				<!--- copy folder --->
				<cfset ftpcopy(arguments.server, arguments.username, arguments.password,
						Path, arguments.localdir)>
			<cfelse>
				<!--- copy file --->
				<cfftp server="#arguments.server#"  username="#arguments.username#" 
				password="#arguments.password#"  passive="true"
				action="getFile" localfile="#arguments.localdir##path#"
				remotefile="#path#"
 				failifexists="No">
			</cfif>
			
		</cfoutput>
		
	</cffunction>
	

	<cfscript>
/**
 * Returns the path from a specified URL.
 * 
 * @param this_url 	 URL to parse. 
 * @return Returns a string. 
 * @author Shawn Seley (shawnse@aol.com) 
 * @version 1, February 21, 2002 
 */
function GetPathFromURL(this_url) {
	var first_char        = "";
	var re_found_struct   = "";
	var path              = "";
	var i                 = 0;
	var cnt               = 0;
	
	this_url = trim(this_url);
	
	first_char = Left(this_url, 1);
	if (Find(first_char, "./")) {
		// relative URL (ex: "../dir1/filename.html" or "/dir1/filename.html")
		re_found_struct = REFind("[^##\?]+", this_url, 1, "True");
	} else if(Find("://", this_url)){
		// absolute URL    (ex: "ftp://user:pass@ftp.host.com")
		re_found_struct = REFind("/[^##\?]*", this_url, Find("://", this_url)+3, "True");
	} else {
		// abbreviated URL (ex: "user:pass@ftp.host.com")
		re_found_struct = REFind("/[^##\?]*", this_url, 1, "True");
	}
	
	if (re_found_struct.pos[1] GT 0)  {
		// get path with filename (if exists)
		path = Mid(this_url, re_found_struct.pos[1], re_found_struct.len[1]);
		
		// chop off the filename
 		if(find("/", path)) {
			i = len(path) - find("/" ,reverse(path)) +1;
			cnt = len(path) -i;
			if (cnt LT 1) cnt =1;
			if (REFind("[^##\?]+\.[^##\?]+", Right(path, cnt))){
				// if the part after the last slash is a file name then chop it off
				path = Left(path, i);
			}
		}
		return path;
	} else {
		return "";
	}
}

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

/**
 * Unzips a file to the specified directory.
 * 
 * @param zipFilePath 	 Path to the zip file (Required)
 * @param outputPath 	 Path where the unzipped file(s) should go (Required)
 * @return void 
 * @author Samuel Neff (sam@serndesign.com) 
 * @version 1, September 1, 2003 
 */
function unzipFile(zipFilePath, outputPath) {
	var zipFile = ""; // ZipFile
	var entries = ""; // Enumeration of ZipEntry
	var entry = ""; // ZipEntry
	var fil = ""; //File
	var inStream = "";
	var filOutStream = "";
	var bufOutStream = "";
	var nm = "";
	var pth = "";
	var lenPth = "";
	var buffer = "";
	var l = 0;
     
	zipFile = createObject("java", "java.util.zip.ZipFile");
	zipFile.init(zipFilePath);
	
	entries = zipFile.entries();
	
	while(entries.hasMoreElements()) {
		entry = entries.nextElement();
		if(NOT entry.isDirectory()) {
			nm = entry.getName(); 
			
			lenPth = len(nm) - len(getFileFromPath(nm));
			
			if (lenPth) {
			pth = outputPath & left(nm, lenPth);
		} else {
			pth = outputPath;
		}
		if (NOT directoryExists(pth)) {
			fil = createObject("java", "java.io.File");
			fil.init(pth);
			fil.mkdirs();
		}
		filOutStream = createObject(
			"java", 
			"java.io.FileOutputStream");
		
		filOutStream.init(outputPath & nm);
		
		bufOutStream = createObject(
			"java", 
			"java.io.BufferedOutputStream");
		
		bufOutStream.init(filOutStream);
		
		inStream = zipFile.getInputStream(entry);
		buffer = repeatString(" ",1024).getBytes(); 
		
		l = inStream.read(buffer);
		while(l GTE 0) {
			bufOutStream.write(buffer, 0, l);
			l = inStream.read(buffer);
		}
		inStream.close();
		bufOutStream.close();
		}
	}
	zipFile.close();
}
</cfscript>

</cfcomponent>
