<cfcomponent name="Aministrator">
	
	<cfset variables.panelIds = structnew() />
	<cfset variables.defaultTemplates = {} />

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="applicationManager" required="true" type="any">

		<cfset variables.blogManager = arguments.applicationManager>
		<cfset variables.preferences = variables.blogManager.getSettingsManager() />
		<cfset variables.id =  variables.blogManager.getBlog().getId() />

		<cfset setGlobalPreferences() />
		<cfset loadCustomPanels() />
		<cfreturn this />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setGlobalPreferences" access="private" output="false" returntype="any">
		<cfset variables.adminSettings = getAdminSettings() />
		<cfset variables.panelBasePosts = {'name' = { "show" = 1 }, 'customFields' = { "show" = 1 }} />
		<cfset variables.panelBasePages = {'name' = { "show" = 1 }, 'customFields' = { "show" = 1 }} />

		<!--- apply custom panel settings --->
		<cfset variables.panelBasePosts = {
			'name' = { "show" = variables.adminSettings.posts.fields.name EQ 1 },
			'customFields' = { "show" = variables.adminSettings.posts.fields.customfields EQ 1 }
		} />
		<cfset variables.panelBasePages = {
			'name' = { "show" = variables.adminSettings.pages.fields.name EQ 1 },
			'customFields' = { "show" = variables.adminSettings.pages.fields.customfields EQ 1 }
		} />
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
		<cfset var authors =  authorsManager.getAuthorsByBlog( variables.id,
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
		<cfset post.setBlogId( variables.id ) />
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
		
		<cfset result = postsManager.addPost(post, arguments.rawData, arguments.user ) />
			
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
		<cfset var block = "" />

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
		<cfset page.setBlogId( variables.id ) />
		<cfset page.setExcerpt(arguments.excerpt) />
				
		<cfif arguments.publish>
			<cfset page.setStatus("published") />
		<cfelse>
			<cfset page.setStatus("draft") />
		</cfif>
		
		<cfif structkeyexists(arguments,"customFields")>
			<cfset page.customFields = arguments.customFields />
		</cfif>

		<!--- check to see if this template has any default blocks we should set --->
		<cfset var skinInfoForPage = getPageSkinInfo( page ) />
		<cfif skinInfoForPage.hasBlocks>
			<cfset var blocks = [] />
			<cfloop array="#skinInfoForPage.definition#" item="block">
				<cfif block.active>
					<cfset arrayAppend( blocks, { 'id' = block.id, "values" = {}, "active" = true } ) />
				</cfif>
			</cfloop>
			<cfif arraylen( blocks )>
				<cfset page.customFields[ 'blocks' ] = { 'key' = 'blocks',
					name = 'Blocks', value = serializeJSON( blocks )  }>
			</cfif>
		</cfif>

		<cfset result = pagesManager.addPage( page, arguments.rawData,getAuthor(arguments.authorId) ) />
		
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
			
			<cfset blog.id = variables.id />
			<cfset blog.role = roleManager.getRoleById(arguments.role) />

			<cfset blogsArray = arraynew(1) />
			<cfset blogsArray[1] = blog />
			<cfset author.setBlogs(blogsArray) />
		<!--- mango  no longer has an input for username, but we are leaving it for backward compat --->
			<cfset author.setUsername( createUUID() )/>
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

			<cfif len(arguments.role)>
				<!--- set the role for the current blog, if not empty --->
				<cfloop index="i" from="1" to="#arraylen(author.blogs)#">
					<cfif author.blogs[i].id EQ variables.id>
						<cfset author.blogs[i].role.id = arguments.role />
					</cfif>
				</cfloop>
			</cfif>
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
		<cfargument name="locale" required="false" type="string" default="en">
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
				<cfset blog.setLocale(arguments.locale) />
				
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

			<cfif result.message.getStatus() EQ "success">
				<cfset result.message.setText( 'Theme updated! <a href="#blog.getUrl()#" target="_blank"><button class="btn btn-outline-primary ms-4">Look at the change</button></a>' )>
			</cfif>
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
		<cfargument name="user" required="false" type="any" default="{}}">

			<cfset var category = variables.blogManager.getObjectFactory().createCategory() />
			<cfset var result = "" />
				
				<cfset category.setTitle(arguments.title) />
				<cfset category.setdescription(arguments.description) />
				<cfset category.setBlogId( variables.id ) />

				<cfset result =  variables.blogManager.getCategoriesManager().addCategory(category,structnew(), arguments.user ) />
		
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
			<cfset var newSkin = getSkin( name ) />
			<cfif isStruct( newSkin )>
				<cfset arrayappend(skins, newSkin ) />
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
		<cfargument name="id" type="string" required="false" default="" />
		<cfargument name="withSettings" type="boolean" required="false" default="false" />

			<cfset var skindata = "" />
			<cfset var dir = getSkinDirectory() />
			<cfif NOT len( arguments.id )>
				<cfset arguments.id = getBlog().getSkin() />
			</cfif>
			<!--- try json modern version first --->
			<cfset var file = dir & "/" & arguments.id & "/skin.json" />

			<cfif fileExists( file )>
				<cffile action="read" file="#file#" variable="skindata">
				<cfset skindata = deserializeJSON( skindata ) />
				<!--- populate common blocks --->
				<cfset setupSkinData( skindata )/>
				<cfif arguments.withSettings>
					<cfset var paths = {} />
					<!--- populate skin setting values --->
					<cfset var setting = "" />

					<cfloop array="#skindata.settings#" item="setting">
						<cfset var defaults = {"name" = "", "default" = "", "type" = "text", "options" = [], "size" = "", "hint" = "", "value" = "" } />
						<cfset structAppend( setting, defaults , false )/>
						<cfif NOT structKeyExists( paths, setting.path )>
							<cfset paths[ setting.path ] = variables.preferences.exportSubtreeAsStruct( setting.path )/>
						</cfif>
						<cfif structKeyExists( paths[ setting.path ], setting.key )>
							<cfset setting.value = paths[ setting.path ][ setting.key ] />
						<cfelseif len( setting.default )>
							<cfset setting.value = setting.default />
						</cfif>

					</cfloop>
				</cfif>
			<cfelse>
				<cfset file = dir & "/" & arguments.id & "/skin.xml"/>
				<cfif fileExists( file )>
					<cfset skindata = parseXmlSkin( file )>
				</cfif>
			</cfif>

		<cfreturn skindata />
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
			<cfset var id = variables.id />
			<cfset var local = StructNew() />
			<cfset var isJsonConfig = true >
			
			<cftry>
				<cfif fileExists( "#blog.getSetting("pluginsDir")#user/#arguments.plugin#/plugin.json" )>
					<cfset pluginData = new PluginLoader().getPluginInfo( "#pluginPath#/plugin.json" )/>
				<cfelse>
					<cfset pluginData = new PluginLoader().getPluginInfo( "#pluginPath#/plugin.xml" )/>
						<cfset isJsonConfig = false>
				</cfif>

				<!--- Get the name of the installation directory from the plugin class --->
				<cfset pluginName = ListFirst(pluginData["class"],".") />

				<cfloop list="assets,assetsAdmin" index="assetType">
					<cfif assetType is "assets">
						<cfset assetBaseDir = expandPath("#blog.getBasePath()#/assets/plugins/#pluginName#") />
					<cfelse>
						<cfset assetBaseDir = expandPath("#blog.getBasePath()#/admin/assets/plugins/#pluginName#") />
					</cfif>
					
					<cfif structkeyexists(pluginData,assetType) and arraylen(pluginData[assetType])>
						<!--- Create assets directory --->
						<cfif not directoryExists(assetBaseDir)>
							<cfdirectory action="create" directory="#assetBaseDir#" />
						</cfif>
						<!--- Loop over assets and copy them --->
						<cfloop index="i" from="1" to="#arraylen(pluginData[assetType])#">
							<cfif isJsonConfig>

								<cfif structkeyexists(pluginData[assetType][i],"dest")>
									<cfset assetDir = assetBaseDir & "/" & pluginData[assetType][i].dest />
									<cfif not directoryExists(assetDir)>
										<cfdirectory action="create" directory="#assetDir#" />
									</cfif>
								<cfelse>
									<cfset assetDir = assetBaseDir />
								</cfif>

								<cfif structkeyexists(pluginData[assetType][i],"file")>
									<cfset source = pluginData[assetType][i]["file"] />
									<cffile action="copy" source="#pluginPath#/#source#" destination="#assetDir#/#ListLast(source,"\/")#" />
<!--- ...or copy directory --->
									<cfelseif StructKeyExists(pluginData[assetType][i],"dir")>
									<cfset source = pluginData[assetType][i]["dir"] />
									<cfset copyDirectory(pluginPath & "/" & source,assetDir & "/" & ListLast(source,"\/")) />
								</cfif>
							<cfelse>
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
			<cfset var id = variables.id />
			<cfset var xml = ""/>
			<cfset var data = ""/>
			<cfset var local = structnew() />

			<cftry>
				<cfif fileExists( "#blog.getSetting("pluginsDir")#user/#arguments.plugin#/plugin.json" )>
					<cfset data = new PluginLoader().getPluginInfo( "#blog.getSetting("pluginsDir")#user/#arguments.plugin#/plugin.json" )/>
				<cfelse>
					<cfset data = new PluginLoader().getPluginInfo( "#blog.getSetting("pluginsDir")#user/#arguments.plugin#/plugin.xml" )/>
				</cfif>

				<!--- Get the name of the installation directory from the plugin class --->
				<cfset local.pluginDir = ListFirst( data["class"],"." ) />
				
				<!--- Delete the assets folders, only if defined in plugin.xml --->
				<cfif structkeyexists(data,"assets") and arraylen(data.assets)>
					<cfif directoryExists(expandPath("#blog.getBasePath()#/assets/plugins/#local.pluginDir#"))>
						<cfdirectory action="delete" recurse="true" directory="#expandPath("#blog.getBasePath()#/assets/plugins/#local.pluginDir#")#" />
					</cfif>
				</cfif>
				
				<cfif structkeyexists(data,"assetsAdmin") and arraylen(data.assetsAdmin)>
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
				<cfset local.activateResult = variables.blogManager.getBlogsManager().activatePlugin( variables.id, arguments.plugin, arguments.pluginId, arguments.type) />

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
			
			<cfset local.activateResult = variables.blogManager.getBlogsManager().deActivatePlugin( variables.id, arguments.plugin, arguments.pluginId, arguments.type) />
			
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

		<cfset var templates = [] />
		<cfset var template = "" />
		<cfset var templateInfo = getSkin( )/>
		<!--- old skins --->
		<cfif structKeyExists( templateInfo, "pageTemplates" )>
			<cfset templates = templateInfo.pageTemplates />
		</cfif>
		<!--- new skins --->
		<cfif structKeyExists( templateInfo, "templates" ) and structKeyExists( templateInfo.templates, 'page' )>
			<cfset templates = templateInfo.templates.page />
		</cfif>

		<cfloop array="#templates#" item="template">
			<cfset template.isDefault = template.file EQ "page.cfm" />
			<cfset template.hasBlocks = structKeyExists( template, 'blocks' ) AND arraylen( template.blocks )>
		</cfloop>
		<cfreturn templates />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getAllTemplates" access="public" output="false">

		<cfset var templates = {} />
		<cfset var template = "" />
		<cfset var templateInfo = getSkin( )/>
		<cfif structKeyExists( templateInfo, "templates" )>
			<cfloop collection="#templateInfo.templates#" item="category">
				<cfloop array="#templateInfo.templates[category]#" item="template">
					<cfset template['isDefault'] = template.file EQ "page.cfm" />
					<cfset template['hasBlocks'] = structKeyExists( template, 'blocks' ) AND arraylen( template.blocks )>
				</cfloop>
			</cfloop>
			<cfreturn templateInfo.templates />
		</cfif>
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
		<cfargument name="id" default="" type="string" />
		<cfargument name="type" default="post" type="string" />

		<cfif NOT len( arguments.id )>
			<cfset arguments.id = arguments.type />
		</cfif>
		<cfif structkeyexists(variables.panelIds,arguments.id)>
			<cfreturn variables.panelIds[arguments.id].clone() />
		<cfelseif structkeyexists( variables.panelIds,arguments.type )>
			<cfreturn variables.panelIds[ arguments.type ].clone() />
		<cfelse>
			<cfset var panel = createobject("component","model.AdminCustomPanel").init(arguments.type) />
			<cfset var base = duplicate( panelBasePosts )/>
			<cfif type EQ "page">
				<cfset base = duplicate( panelBasePages ) />
			</cfif>
			<cfloop collection="#base#" item="local.key">
				<cfset structAppend( panel.standardFields[ local.key ], base[ local.key ] ) />
			</cfloop>
			<cfreturn panel />
		</cfif>

	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="addCustomPanel" access="public" output="false" returntype="void">
		<cfargument name="customPanel" />
		<cfset variables.panelIds[arguments.customPanel.id] = arguments.customPanel />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="getCustomPanels" access="public" output="false">
		<cfreturn variables.panelIds />
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

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="parseXmlSkin" access="public" output="false" returntype="any">
		<cfargument name="xmlFile" type="String" required="true" />
		<cfset var skin = "" />
		<cfset var skindata = "" />
		<cfset var i = 0 />
		<cfset var j = 0 />
		<cfset var pagetemplate = "" />
		<cfset var podLocation = "" />
		<cfset var pods = "" />
		<cfset var pod = "" />
		<cfset var dir = getSkinDirectory() />

		<cfset var defaults = { "requires" = [], "settings" = [], "templates" = [] }/>

		<cffile action="read" file="#xmlFile#" variable="skindata">
		<cfset skindata = xmlparse(skindata).skin />
		<cfset skin = defaults />
		<cfset skin.name = skindata.xmlAttributes.name />
		<cfset skin.id = skindata.xmlAttributes.id />
		<cfset skin.lastModified = skindata.xmlAttributes.lastModified />
		<cfset skin.version = skindata.xmlAttributes.version />
		<cfset skin.description = skindata.description.xmltext />
		<cfset skin.thumbnail = skindata.thumbnail.xmltext />
		<cfset skin.adminEditorCss = skindata.adminEditorCss.xmltext />
		<cfset skin.license = skindata.license.xmltext />
		<cfset skin.author = skindata.author.xmltext />
		<cfset skin.authorUrl = skindata.authorUrl.xmltext />
		<cfset skin.designAuthor = skindata.designAuthor.xmltext />
		<cfset skin.designAuthorUrl = skindata.designAuthorUrl.xmltext />

		<cfset skin.pageTemplates = arraynew(1) />

		<cfloop from="1" to="#arraylen(skindata.pageTemplates.xmlchildren)#" index="i">
			<cfset pagetemplate = structnew() />
			<cfset pagetemplate.file = skindata.pageTemplates.xmlchildren[i].xmlattributes.file />
			<cfset pagetemplate.name = skindata.pageTemplates.xmlchildren[i].xmlattributes.name />
			<cfif fileexists("#dir#/#skin.id#/#pagetemplate.file#")>
				<cfset skin.pageTemplates[i] = pagetemplate />
			</cfif>
		</cfloop>

		<cfset skin.adminPageTemplates = structnew() />

		<cfif structkeyexists(skindata,"adminPageTemplates")>
			<cfloop from="1" to="#arraylen(skindata.adminPageTemplates.xmlchildren)#" index="i">
				<cfset pagetemplate = structnew() />
				<cfset pagetemplate.file = skindata.adminPageTemplates.xmlchildren[i].xmlattributes.file />
				<cfset pagetemplate.id = skindata.adminPageTemplates.xmlchildren[i].xmlattributes.id />
				<cfif fileexists("#dir#/#skin.id#/#pagetemplate.file#")>
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

	<cfscript>
// ------------------------------------------
		function getAdminPageTemplates(){
			var templates = {};
			var id = variables.blogManager.getBlog().getSkin();
			var skin = getSkin( variables.blogManager.getBlog().getSkin() );
			if ( structKeyExists( skin, 'adminPageTemplates' )){
				templates = getSkin(id).adminPageTemplates;
			}
			else if ( structKeyExists( skin, "templates" )){
				var names = "login,login_reset,login_forgot";
				for ( var item in skin.templates ){
					if ( listFindNoCase( names, item )){//it's an admin template
						templates[ item ] = skin.templates[ item ][ 1 ];//choose the first one in array until we have a template chooser
					}
				}
			}

			return templates;
		}

	// ------------------------------------------
	function setupSkinData( data ){
		if ( structKeyExists( data, "blocks")){
			if ( structKeyExists( data, "pageTemplates" ) ){
			for ( var item in data.pageTemplates ){
				if ( structKeyExists( item, 'blocks' )){
					for ( var block in item.blocks ){
						if ( NOT structKeyExists( block, 'title' ) AND structKeyExists( data.blocks, block.id )){
							structAppend( block, data.blocks[ block.id ] );
						}
					}
				}
			}
			}
			if ( structKeyExists( data, "templates" ) ){
				for ( var item in data.templates ){
					for ( var template in data.templates[ item ]){
						if ( structKeyExists( template, 'blocks' )){
							for ( var block in template.blocks ){
								if ( NOT structKeyExists( block, 'title' ) AND structKeyExists( data.blocks, block.id )){
									structAppend( block, data.blocks[ block.id ] );
								}
							}
						}
					}
				}
			}
		}
		if ( NOT structKeyExists( data, "settings" )){
			data.settings = [];
		}
		if ( NOT structKeyExists( data, "podLocations" )){
			data.podLocations = [];
		}
		return data;
	}

	// ------------------------------------------
	function getPageSkinInfo( pageObject )
	{
		var pageCurrent = pageObject.getTemplate();
		var result = { 'template' = pageCurrent, 'hasBlocks' = false, 'availableTemplates' = [], 'definition' = {} };
		var panelId = '';
		var panelDef = {};
		var templateRef = '';
		var pageTemplates = getPageTemplates();
		//check if has entry type and entry type has its own templates
		if (pageObject.customFieldExists("entryType")){
			panelId = pageObject.getCustomField("entryType").value;
			panelDef = getCustomPanel(panelId,'page');
		}
		result.panelDef = panelDef;
		if ( len( panelId ) AND arraylen( panelDef.templates )){
			pageTemplates = panelDef.templates;
			result.rr = pageTemplates;
		}

		for ( var info in pageTemplates ){
			if ( NOT info.isDefault ){
				arrayappend( result.availableTemplates, info );
			}
			if ( info.file EQ pageCurrent OR ( info.isDefault AND pageCurrent EQ "" )){
				result.hasBlocks = info.hasblocks;
				if ( info.hasblocks )
					result.definition = info.blocks;
				else
					result.definition = [];
			}
		}
		return result;
	}

	// ------------------------------------------
	function saveSetting( path, key, value ){
		var result = {};
		result.message = createObject("component","Message");
		variables.preferences.put( path, key, value, variables.id );

		return result;
	}

// ------------------------------------------
		function removeSetting( path, key ){
			var result = {};
			result.message = createObject("component","Message");
			variables.preferences.remove( path, key, variables.id );

			return result;
		}

// ------------------------------------------
		function saveTemplateBlocks( templateId, blocks ){
			var result = {};
			result.message = createObject("component","Message");
			variables.preferences.put( "blocks", templateId, serializeJSON( blocks ), variables.id, 'json' );

			return result;
		}

	// ------------------------------------------
	function getCurrentTemplates(){
		var templates = [];
		var data = getSkin();
		var names = { "index" = "Home", "archives" = "Archives", "login" = "Admin Login" };

		if ( structKeyExists( data, "templates" ) ){
			for ( var item in data.templates ){ //index, archives, etc
				//only add allowed ones
				if ( NOT structKeyExists( names, item )){
					continue;
				}
				//current one
				var currentTemplate = variables.preferences.get( "system/skins/templates", item, "", variables.id, false );
				if ( NOT len( currentTemplate )){
					currentTemplate = item & ".cfm";
				}
				for ( var template in data.templates[ item ] ) {
					if ( currentTemplate EQ template.file ){
						template.label = names[ item ];
						template.template = item;
						arrayAppend( templates, template );
					}
				}
			}
		}
		return templates;
	}

	// ------------------------------------------
	function getAdminSettings(){
		var currentAdmin = variables.preferences.exportSubtreeAsStruct( "system/admin/", variables.id );
		//set defaults just in case they aren't in the db
		if ( NOT structKeyExists( currentAdmin ,'posts' )){
			currentAdmin.posts.fields.customfields = 1;
			currentAdmin.posts.fields.name = 1;
		}
		if ( NOT structKeyExists( currentAdmin, 'pages' )){
			currentAdmin.pages.fields.customfields = 1;
			currentAdmin.pages.fields.name = 1;
		}

		return currentAdmin;
	}

	// ------------------------------------------
	function getCurrentTemplate( templateId ){
		var templates = getCurrentTemplates();
		for ( var item in templates ){
			if ( item.template EQ templateId )
				return item;
		}
		return {};
	}

	// ------------------------------------------
	function getBlockValues( templateId ) {
		return variables.preferences.get( "blocks", templateId, {}, variables.id, false );
	}

	// ------------------------------------------
	function prepareBlocksForEdit( definition, values ) {
		var blocks = [];
		var blockDictionary = {};

		for ( var def in definition ){
			blockDictionary[ def.id ] = def;
			def.used = 0;
			def.canDelete = false;
		}

		//merge with definition
		for ( var item in values ){
			//find corresponding definition
			if ( structKeyExists( blockDictionary, item.id )){
				var baseDef = blockDictionary[ item.id ];
				var newDef = duplicate( baseDef );
				newDef.isEmpty = NOT blockHasValues( item.values );
				newDef.active = structKeyExists( item, 'active' ) ? item.active : true;
				for ( var field in newDef.fields ) {
					populateBlockDefinition( field, item.values );
				}
				arrayAppend( blocks, newDef );
				baseDef.used = baseDef.used + 1;
			}
		}

		for ( var block in blocks ){
			if ( blockDictionary[ block.id ].used GT 1 AND NOT block.active ){
				block.canDelete = true;
			}
		}

		for ( var def in definition ){
			if ( def.used EQ 0 ){
				def.active = false;
				arrayAppend( blocks, def );
			}
		}

		addFormIds( blocks );
		return blocks;
	}

		function populateBlockDefinition( definition, values ){
			if ( definition.type NEQ 'array' ) {
				definition.value = structKeyExists(values, definition.id) ? values[ definition.id ] : ( structKeyExists(definition, 'default') ? definition.default : '' );

			}
			else {
				if ( structKeyExists( values, definition.id )) {
					var fieldSetArray = [];
					var originalFieldSetDef = definition.fields[ 1 ];//definition will just have 1 item with the set of fields
					for ( var item in values[ definition.id ] ){  //iterate over number of current fieldsets
						var newFieldSet = duplicate( originalFieldSetDef );

						arrayAppend( fieldSetArray, newFieldSet );
						for ( var field in newFieldSet ){
							populateBlockDefinition( field, item );
						}
//@todo check there is no max-items
// if ( not structKeyExists( ) ){

//}
					}
					arrayAppend( fieldSetArray, duplicate( originalFieldSetDef ));
					definition.fields = fieldSetArray;
				}
			}
			return definition;
		}

		// ------------------------------------------------------------
		function addEmptyBlock( blocks, definition, type, position ){
			var selection = {};
			var found = false;
			for ( var def in definition ){
				if (  def.id EQ type ){
					selection = def;
					found = true;
				}
			}
			if ( found ) {
				arrayinsertat( blocks, position + 1, {'id' = type, 'active' = false, 'values' = {}} );
			}
			return blocks;
		}

		// ------------------------------------------------------------
		function loadCustomPanels(){
			var skin = getSkin( );
			var base = duplicate( panelBasePosts );
			var i18n = variables.blogManager.getInternationalizer();
			var i = 0;
			if ( structKeyExists( skin, "entryTypes" ) AND isArray( skin.entryTypes )){
				for ( var panel in skin.entryTypes ){
					i++;
					var customPanelObj = variables.blogManager.getObjectFactory().createAdminCustomPanel().init( panel.type );
					customPanelObj.order = i;

					//first init with global settings, then apply skin's
					if ( panel.type EQ "page" ){
						base = duplicate( panelBasePages );
					}
					for ( var key in base ){
						structAppend( customPanelObj.standardFields[ local.key ], base[ local.key ] );
					}

					customPanelObj.initFromJson( panel );
					//check for built-in types
					if ( customPanelObj.id EQ "post"){
						customPanelObj.address = 'posts.cfm?owner=post';
						customPanelObj.owner = 'post';
						if ( NOT structKeyExists( panel, "icon" ))
							customPanelObj.icon = 'bi-file-earmark-fill';
					}
					else if ( customPanelObj.id EQ "page"){
						customPanelObj.address = 'pages.cfm?owner=page';
						customPanelObj.owner = 'page';

						if ( NOT structKeyExists( panel, "icon" ))
							customPanelObj.icon = 'bi-file-earmark-text-fill';
					}
					customPanelObj.label = i18n.getValue(customPanelObj.label);

					//add info from templates reference
					var alltemplates = getAllTemplates();
					if ( structKeyExists( panel, "templates" )){
						customPanelObj.templates = alltemplates[ panel.templates ];
					}
					else if ( structKeyExists( alltemplates, panel.type )){
						customPanelObj.templates = alltemplates[ panel.type ];
					}
					addCustomPanel( customPanelObj );
				}
			}
			//if not found, set up defaults
			else {
				var customPanelObj = variables.blogManager.getObjectFactory().createAdminCustomPanel().init( 'post' );
				for ( var key in base ){
					structAppend( customPanelObj.standardFields[ local.key ], base[ local.key ] );
				}
				customPanelObj.address = 'posts.cfm?owner=post';
				customPanelObj.requiresPermission = 'manage_posts';
				customPanelObj.icon = 'bi-file-earmark-fill';
				customPanelObj.label = i18n.getValue(customPanelObj.label);
				addCustomPanel( customPanelObj );
				base = duplicate( panelBasePages );
				customPanelObj = variables.blogManager.getObjectFactory().createAdminCustomPanel().init( 'page' );
				for ( var key in base ){
					structAppend( customPanelObj.standardFields[ local.key ], base[ local.key ] );
				}
				customPanelObj.address = 'pages.cfm?owner=page';
				customPanelObj.icon = 'bi-file-earmark-text-fill';
				customPanelObj.requiresPermission = 'manage_pages';
				customPanelObj.label = i18n.getValue(customPanelObj.label);
				addCustomPanel( customPanelObj );
			}
		}

		// ------------------------------------------------------------
		function addFormIds( blocks ){
			var prefix = "block_";
			var i = 1;
			for ( var block in blocks ){
				addFieldFormIds( block.fields, prefix & i, '"#i#"."' & block.id & '"' );
				i++;
			}
		}
		function addFieldFormIds( definition, prefix, path ){
			var i = 1;
			for ( var field in definition ){
				var fieldprefix = prefix & "_" & i;
				if ( field.type NEQ "array" ){
					field.form_id = fieldprefix;
					field.path = path & '."' & field.id & '"';
					field.basepath = path;
				}
				else {
					var j = 1;
					for ( var fieldSet in field.fields ) {
						var newpath = path & '."' & field.id & '"' & '."' & j & '"';
						var fieldprefixinner = fieldprefix & "_" & j;
						addFieldFormIds( fieldSet, fieldprefixinner, newpath );
						j++;
					}
				}
				i++;
			}
		}


// ------------------------------------------------------------
		function blockHasValues( fields ){
			var hasValues = false;
			for ( var key in fields ) {
				if ( NOT isArray( fields[ key ] ) ){
					if ( len( fields[ key ] )){
						return true;
					}
				}
				else {
					if ( arraylen( fields[ key ] ) GT 0 ){
						for ( var i = arraylen( fields[ key ] ); i GT 0; i--) {
							hasValues = blockHasValues( fields[ key ][ i ] );
							if ( hasValues )
								return true;
						}
					}
				}
			}

			return hasValues;
		}

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
