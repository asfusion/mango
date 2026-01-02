<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="" />
	<cfparam name="message" default="" />
	<cfparam name="panel" default="" />
	<cfparam name="ownerMainMenu" default="Posts" />
	<cfparam name="page" default="0" />
	<cfparam name="itemsPerPage" default="20" />
	<cfparam name="search" default="" />
	
	<cfset pagetitle = "All Posts" />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset preferences = currentRole.preferences.get( "admin","menuItems" ) />
	<cfset postsManager = request.blogManager.getPostsManager() />
	<cfset permissions = currentRole.permissions />

	<cffunction name="showMenuItem" returntype="boolean">
		<cfargument name="permissionsAllowed">
		<cfargument name="preferenceAllowed">
		<cfset var i = 0 />
		<cfset var show = NOT len(arguments.permissionsAllowed) />

		<cfloop list="#arguments.permissionsAllowed#" index="i">
			<cfif listfind(permissions,i)>
				<cfset show = true />
				<cfbreak>
			</cfif>
		</cfloop>

		<cfreturn show AND (NOT len(arguments.preferenceAllowed) OR listfind(preferences,arguments.preferenceAllowed) OR NOT len(preferences )) />
	</cffunction>

	<cfif structkeyexists(url,"action") AND url.action EQ "delete">
		<cfset result = request.formHandler.handleDeletePost(url) />
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	
	<cfset panelData = request.administrator.getCustomPanel(panel,'post') />
	<cfset request.panelData = panelData />
	
	<cfset totalPosts = 0 />

	<!--- get posts --->
	<cfif NOT len(panel)>
		<cfif len(search)>
			<cfset posts = postsManager.getPostsByKeyword(search, (page * itemsPerPage) + 1, itemsPerPage,true) />
			<!--- since I can't get the total, I'll make another query for the first next item,
			if there is one, then there are more pages --->
			<cfset hasNextPage = arraylen(postsManager.getPostsByKeyword(search, ((page + 1) * itemsPerPage) + 1, 1,true)) />
			<cfset pageTitle = request.i18n.getValue('Searching posts for "{1}"', search) />
		<cfelseif listfind(currentRole.permissions, "manage_all_posts")>
			<cfset totalPosts = postsManager.getPostCount(true) />
			<cfset posts = postsManager.getPosts((page * itemsPerPage) + 1, itemsPerPage, true, false) />
			<cfset hasNextPage = totalPosts GT ((page + 1) * itemsPerPage)>
			<cfset pageTitle = request.i18n.getValue("All Posts") />
		<cfelse>
			<cfset posts = postsManager.getPostsByAuthor(currentAuthor.id, (page * itemsPerPage) + 1, itemsPerPage,true) />
			<!--- since I can't get the total, I'll make another query for the first next item,
			if there is one, then there are more pages --->
			<cfset hasNextPage = arraylen(postsManager.getPostsByAuthor(currentAuthor.id, ((page + 1) * itemsPerPage) + 1, 1,true)) />
			<cfset pageTitle = request.i18n.getValue("All Posts") />
		</cfif>
	<cfelse>
		<cfset posts = postsManager.getPostsByCustomField("entryType",panel, (page * itemsPerPage) + 1, itemsPerPage,true,false) />
		<cfset pageTitle = request.i18n.getValue("{1}: All", panelData.label) />
		<!--- since I can't get the total, I'll make another query for the first next item,
			if there is one, then there are more pages --->
		<cfset hasNextPage = arraylen(postsManager.getPostsByCustomField("entryType",panel, ((page + 1) * itemsPerPage) + 1, 1,true,false)) />
	</cfif>
	
	<cfif panelData.showInMenu EQ "primary">
		<cfset ownerMainMenu = panel />
	</cfif>
</cfsilent>
<cf_layout page="#ownerMainMenu#" title="#panelData.label#">
<cfif listfind(currentRole.permissions, "manage_all_posts") OR
		listfind(currentRole.permissions, "manage_posts")>

	<cfoutput>
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
		<div>
		<cfif NOT len(preferences) OR listfind(preferences,"posts_new")>
			<button class="btn btn-secondary" type="button"><a href="post.cfm?panel=#panel#&amp;owner=#panel#"><svg class="icon icon-xs me-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>#request.i18n.getValue("Add New")#</a></button>
		</cfif>
		</div>
		<div class="btn-toolbar ">
			<form action="posts.cfm">
				<div class="input-group me-2 me-lg-3 fmxw-400">
					<span class="input-group-text"> <i class="bi bi-search icon icon-xs"></i> </span>
					<input type="text" class="form-control" placeholder="#request.i18n.getValue("Search posts")#" name="search" id="search">
				</div>
			</form>

		<cfif showMenuItem("manage_categories","categories")>
			<button class="btn btn-gray-800 d-inline-flex align-items-center dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
				#request.i18n.getValue("Post categories")# <svg class="icon icon-xs ms-2" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg></button>
				<div class="dropdown-menu dashboard-dropdown dropdown-menu-start mt-2 py-1">
					<a class="dropdown-item d-flex align-items-center" href="categories.cfm">
						<i class="bi bi-folder icon icon-xs me-2"></i>#request.i18n.getValue("View and edit")# </a>
					<a class="dropdown-item d-flex align-items-center" href="category.cfm"><i class="bi bi-plus icon icon-xs
					 me-2"></i> #request.i18n.getValue("New category")# </a>
				</div>
			</cfif>
		</div>
	</div>
		<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
		<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
			<div class="card card-body border-0 shadow table-wrapper table-responsive">
				<table class="table table-hover">
					<thead>
					<tr>
						<th class="border-gray-200">#request.i18n.getValue("Title")#</th>
						<th class="border-gray-200">#request.i18n.getValue("Date")#</th>
						<th class="border-gray-200">#request.i18n.getValue("Status")#</th>
						<th class="border-gray-200">#request.i18n.getValue("Comments")#</th>
						<th class="border-gray-200">#request.i18n.getValue("Author")#</th>
						<th class="border-gray-200">#request.i18n.getValue("Actions")#</th>
					</tr>
					</thead>
					<tbody>
					<!-- Item -->
					<cfloop from="1" to="#arraylen(posts)#" index="i">
					<!--- since this is used by list of posts of a custom panel,
					we need to check if the user has enough permissions --->
						<cfif listfind(currentRole.permissions, "manage_all_posts") OR posts[i].getauthorId() EQ currentAuthor.id>
							<cfset currentTitle = xmlformat(posts[i].getTitle()) />
							<cfif NOT len(currentTitle)><cfset currentTitle = "--" & request.i18n.getValue("Untitled") & "--"/></cfif>
							<cfset status = posts[i].getStatus() />
						<tr>
							<td>
								<a href="post.cfm?id=#posts[i].getId()#&amp;owner=#panel#" class="fw-bold">#currentTitle#</a>
							</td>
							<td>
								<span class="fw-normal">#lsdateformat(posts[i].getPostedOn(),'short')#</span>
							</td>
							<td><span class="fw-normal <cfif status EQ "published">text-success<cfelse>text-warning</cfif>">#request.i18n.getValue(uCase(left(status,1)) & right(status,len(status)-1))#</span></td>
							<td><span class="fw-normal badge bg-info"><a href="comments.cfm?entry_id=#posts[i].getId()#">#posts[i].getCommentCount()#</a></span></td>
							<td><span class="fw-bold">#posts[i].getAuthor()#</span></td>
						<td>
						<a href="posts.cfm?action=delete&amp;id=#posts[i].getId()#&amp;panel=#panel#&amp;owner=#panel#"  class="deleteButton"><button class="btn btn-outline-danger btn-sm" type="button">#request.i18n.getValue("Delete")#</button></a>
								<a href="#request.blogManager.getBlog().geturl()##posts[i].getUrl()#"><button class="btn btn-outline-info btn-sm" type="button">#request.i18n.getValue("View")#</button></a>
						</td>
						</tr>
						</cfif>
					</cfloop>

					</tbody>
				</table>
				<div class="card-footer px-3 border-0 d-flex flex-column flex-lg-row align-items-center justify-content-between">
					<nav aria-label="Page navigation">
						<ul class="pagination mb-0">

							<cfif page NEQ 0>
								<li class="page-item"><a class="page-link" href="posts.cfm?panel=#panel#&amp;owner=#panel#&page=#page-1#">#request.i18n.getValue("Previous")#</a></li>
							</cfif>
		<cfif hasNextPage>
							<li class="page-item">
								<a class="page-link" href="posts.cfm?panel=#panel#&amp;owner=#panel#&page=#page+1#">#request.i18n.getValue("Next")#</a>
							</li>
		</cfif>

						</ul>
					</nav>
					<!---<div class="fw-normal small mt-4 mt-lg-0">Showing <b>5</b> out of <b>25</b> entries</div>--->
				</div>
			</div>
		</div>

</cfoutput>

<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert">Your role does not allow you to edit posts</div>
</cfif>
</cf_layout>