<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	<cfparam name="itemsPerPage" default="20" />
	<cfparam name="page" default="0" />
	<cfparam name="search" default="" />
	
	<cfset manager = request.blogManager.getAuthorsManager() />
	<cfset blogId = request.blogManager.getBlog().getId() />
	<!--- get authors --->
	<cfset authors = manager.getAuthorsByKeyword(search,blogId, (page * itemsPerPage) + 1, itemsPerPage, true) />
	<!--- since I can't get the total, I'll make another query for the first next item,
				if there is one, then there are more pages --->
	<cfset hasNextPage = arraylen(manager.getAuthorsByKeyword(search, blogId, ((page + 1) * itemsPerPage) + 1, 1,true)) />

	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset preferences = currentRole.preferences.get("admin","menuItems","") />

</cfsilent>
<cf_layout page="Users" title="#request.i18n.getValue("Users")#">
<cfif listfind(currentRole.permissions, "manage_users")>
	<cfoutput>
		<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
		<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

	<nav class="nav navbar-dashboard navbar-dark flex-column flex-sm-row mb-4">
		<a href="author.cfm?profile=1" class="nav-link">#request.i18n.getValue("My Profile")#</a>
	<cfif listfind(currentRole.permissions, "manage_users")>
		<cfif NOT len(preferences) OR listfind(preferences,"users_edit")>
			<a class="nav-link active" href="authors.cfm">#request.i18n.getValue("Users")#</a>
		</cfif>
		<cfif NOT len(preferences) OR listfind(preferences,"roles")>
				<a class="nav-link" href="roles.cfm">#request.i18n.getValue("Roles")#</a>
		</cfif>
			<mangoAdmin:MenuEvent name="authorsNav" />
	</cfif>
	</nav>

	<div class="table-settings my-4">
		<div class="row align-items-center justify-content-between">
		<div class="col-4 col-md-2">
		<cfif NOT len(preferences) OR listfind(preferences,"users_new")>
				<button class="btn btn-secondary" type="button"><a href="author.cfm"><i class="bi bi-plus"></i>#request.i18n.getValue("New User")#</a></button>
		</cfif>
		</div>

			<div class="col col-md-6 col-lg-3 col-xl-4">
				<form action="authors.cfm">
					<div class="input-group me-2 me-lg-3 fmxw-400">
						<span class="input-group-text"> <i class="bi bi-search icon icon-xs"></i> </span>
						<input type="text" class="form-control" placeholder="Search users" name="search" id="search">
					</div>
				</form>
			</div>
		</div>
	</div>
	<h4 class="h4">#request.i18n.getValue("All Users")#</h4>

	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
	<div class="card card-body border-0 shadow table-wrapper table-responsive">
	<table class="table table-hover">
		<thead>
		<tr>
			<th>#request.i18n.getValue("Name")#</th>
			<th>#request.i18n.getValue("Email")#</th>
			<th>#request.i18n.getValue("Role")#</th>
			<th>#request.i18n.getValue("Active")#</th>
			<th class="border-gray-200">#request.i18n.getValue("Actions")#</th>
		</tr>
		</thead>
	<tbody>
	<!-- Item -->
	<cfloop from="1" to="#arraylen(authors)#" index="i">
		<tr>

			<td><a href="author.cfm?id=#authors[i].getId()#" >#xmlformat(authors[i].getName())#</a></td>
			<td >#xmlformat(authors[i].getEmail())#</td>
			<td>#xmlformat(authors[i].getCurrentRole(currentBlogId).name)#</td>
			<td><cfif NOT authors[i].active>#request.i18n.getValue("Not Active")#<cfelse>#request.i18n.getValue("Active")#</cfif></td>
			<td>
				<a href="author.cfm?id=#authors[i].getId()#" class="editButton">#request.i18n.getValue("Edit")#</a>
			</td>
			</td>
		</tr>
	</cfloop>

	</tbody>
	</table>

	</div>
	</div>





		<div class="pagingLinks">
			<cfif page NEQ 0>&lt; <a href="authors.cfm?search=#search#&page=#page-1#">Previous</a></cfif>
			<cfif hasNextPage>&nbsp;&nbsp;<a href="authors.cfm?search=#search#&page=#page+1#">Next </a> &gt;</cfif>
		</div>
		</cfoutput>
		
		</div>
	</div>
	<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert">Your role does not allow you to manage users</div>
</cfif>

</cf_layout>