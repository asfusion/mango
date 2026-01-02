<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	<cfparam name="panel" default="">
	<cfparam name="ownerMainMenu" default="Pages">
	
	<cfset pagetitle = request.i18n.getValue("All Pages") />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset pagesManager = request.blogManager.getPagesManager() />
	<cfset preferences = currentRole.preferences.get("admin","menuItems","") />
	
	<cfif structkeyexists(url,"action") AND url.action EQ "delete">
		<cfset result = request.formHandler.handleDeletePage(url) />
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	
	<cfset panelData = request.administrator.getCustomPanel(panel,'page') />
	<cfset request.panelData = panelData />
	
	<!--- get posts --->
	<cfif NOT len(panel)>
		<cfif listfind(currentRole.permissions, "manage_all_pages")>
			<cfset posts = request.administrator.getPages() />
		<cfelse>
			<cfset posts = pagesManager.getPagesByAuthor(currentAuthor.id,1,0,true) />
		</cfif>
	<cfelse>		
		<cfset posts = pagesManager.getPagesByCustomField("entryType",panel,1,0,true,false) />
		<cfset pageTitle = request.i18n.getValue("{1}: All", panelData.label) />
	</cfif>

	<cfif panelData.showInMenu EQ "primary">
		<cfset ownerMainMenu = panel />
	</cfif>
</cfsilent>
<cf_layout page="#ownerMainMenu#" title="#panelData.label#">
<cfif listfind(currentRole.permissions, "manage_all_pages") OR
		listfind(currentRole.permissions, "manage_pages")>
		<cfoutput>
		<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
		<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

		<div class="table-settings mb-4">
			<div class="row align-items-center justify-content-between">
				<div class="col-4 col-md-2 ">
				<cfif NOT len(preferences) OR listfind(preferences,"categories_new")>
					<a href="page.cfm?panel=#panel#&amp;owner=#panel#"><button class="btn btn-secondary" type="button">
								<i class="bi bi-plus"></i><cfif panel EQ "">#request.i18n.getValue("Create New Page")#<cfelse>#request.i18n.getValue("Create New")#</cfif></button></a>
				</cfif>
				</div>
			</div>
		</div>

		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
		<div class="card card-body border-0 shadow table-wrapper table-responsive">
		<table class="table table-hover">
			<thead>
			<tr>
				<th class="border-gray-200">#request.i18n.getValue("Title")#</th>
				<th class="border-gray-200">#request.i18n.getValue("Status")#</th>
				<th class="border-gray-200">#request.i18n.getValue("Comments")#</th>
				<th class="border-gray-200">#request.i18n.getValue("Actions")#</th>
			</tr>
			</thead>
		<tbody>
		<!-- Item -->
			<cfloop from="1" to="#arraylen(posts)#" index="i">
<!--- since this is used by list of posts of a custom panel, we need to check if the user has enough permissions --->
				<cfif listfind(currentRole.permissions, "manage_all_pages") OR posts[i].getauthorId() EQ currentAuthor.id>
					<cfset currentTitle = xmlformat(posts[i].getTitle()) />
					<cfset status = posts[i].getStatus() />
					<tr>
					<td><a href="page.cfm?id=#posts[i].getId()#&amp;owner=#panel#" class="fw-bold">#currentTitle#</a></td>
				<td><span class="fw-normal <cfif status EQ "published">text-success<cfelse>text-warning</cfif>">#request.i18n.getValue(posts[i].getStatus())#</span></td>
				<td><span class="fw-normal badge bg-info"><a href="comments.cfm?entry_id=#posts[i].getId()#">#posts[i].getCommentCount()#</a></span></td>
				<td>
						<a href="pages.cfm?action=delete&amp;id=#posts[i].getId()#&amp;panel=#panel#&amp;owner=#panel#"  class="deleteButton"><button class="btn btn-outline-danger btn-sm" type="button">#request.i18n.getValue("Delete")#</button></a>
				</td>
				</tr>
				</cfif>
			</cfloop>

			</tbody>
			</table>

			</div>
			</div>
		</cfoutput>

<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert">#request.i18n.getValue("Your role does not allow you to edit posts")#</div>
</cfif>
</cf_layout>