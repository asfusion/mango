<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset preferences = currentRole.preferences.get("admin","menuItems","") />
	
	<cfif structkeyexists(url,"action") AND url.action EQ "delete">
		<cfset result = request.formHandler.handleDeleteCategory(url) />
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	
	<!--- get categories --->
	<cfset categories = request.administrator.getCategories() />
	<cfset breadcrumb = [ { 'link' = 'posts.cfm', 'title' = "Posts" },
	{ 'title' = 'Categories' } ] />
</cfsilent>
<cf_layout page="Posts" title="Categories" hierarchy="#breadcrumb#">
	<cfif listfind(currentRole.permissions, "manage_categories")>
		<cfoutput>

		<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
		<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

		<div class="table-settings mb-4">
			<div class="row align-items-center justify-content-between">
				<div class="col-4 col-md-2 ">
				<cfif NOT len(preferences) OR listfind(preferences,"categories_new")>
						<button class="btn btn-secondary" type="button"><a href="category.cfm"><i class="bi bi-plus"></i>New Category</a></button>
				</cfif>
				</div>
			</div>
		</div>

		<h4 class="h4">All categories</h4>

		<mangoAdmin:MenuEvent name="categoriesNav" />


		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
			<div class="card card-body border-0 shadow table-wrapper table-responsive">
			<table class="table table-hover">
				<thead>
				<tr>
					<th class="border-gray-200">#request.i18n.getValue("Name")#</th>
					<th class="border-gray-200">#request.i18n.getValue("Actions")#</th>
				</tr>
				</thead>
				<tbody>
				<!-- Item -->
				<cfloop from="1" to="#arraylen(categories)#" index="i">
				<tr>
					<td>
						<a href="category.cfm?id=#categories[i].getId()#" class="fw-bold">#xmlformat(categories[i].getTitle())#</a>
					</td>
					<td>
						<a href="category.cfm?id=#categories[i].getId()#" class="editButton"><button class="btn btn-outline-tertiary btn-sm" type="button">Edit</button></a>
						<a href="categories.cfm?action=delete&amp;id=#categories[i].getId()#"  class="deleteButton"><button class="btn btn-outline-danger btn-sm" type="button">Delete</button></a>
					</td>
			</tr>
		</cfloop>

		</tbody>
		</table>

		</div>
		</div>
		</cfoutput>

<cfelse><!--- not authorized --->
<div class="alert alert-info" role="alert">Your role does not allow you to edit categories</div>
</cfif>
</cf_layout>