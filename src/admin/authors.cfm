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
<cf_layout page="Users" title="Users">
<div id="wrapper">
<cfif listfind(currentRole.permissions, "manage_users")>
	<div id="submenucontainer">
		<ul id="submenu">
			<cfoutput><li><a href="author.cfm?profile=1">My Profile</a></li></cfoutput>
			<cfif NOT len(preferences) OR listfind(preferences,"users_new")>
			<li><a href="author.cfm">New User</a></li>
			</cfif>
			<cfif NOT len(preferences) OR listfind(preferences,"users_edit")>
			<li><a href="authors.cfm" class="current">Edit User</a></li>
			</cfif>
			<cfif NOT len(preferences) OR listfind(preferences,"roles")>
			<li><a href="roles.cfm">Roles</a></li>
			</cfif>
			<mangoAdmin:MenuEvent name="authorsNav" />
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle">All Users
		<span class="search">Search users: <form class="inline-form" action="authors.cfm">
			<input name="search" id="search"/></form>
		</span></h2>	

		<div id="innercontent">
		<cfif len(error)>
			<p class="error"><cfoutput>#error#</cfoutput></p>
		</cfif>
		<cfif len(message)>
			<p class="message"><cfoutput>#message#</cfoutput></p>
		</cfif>
		
		<cfoutput>
		<div class="pagingLinks">
			<cfif page NEQ 0>&lt; <a href="authors.cfm?search=#search#&page=#page-1#">Previous</a></cfif>
			<cfif hasNextPage>&nbsp;&nbsp;<a href="authors.cfm?search=#search#&page=#page+1#">Next </a> &gt;</cfif>
		</div>
		<p class="buttonBar"><a href="author.cfm" class="editButton">Create New User</a></p>
		<table cellspacing="0">
			<tr><th class="buttonColumn">Edit</th><th>Name</th><th>Email</th><th>Role</th><th>Active</th></tr>
			<cfloop from="1" to="#arraylen(authors)#" index="i">
				<tr>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="author.cfm?id=#authors[i].getId()#" class="editButton">Edit</a></td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#xmlformat(authors[i].getName())#</td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#xmlformat(authors[i].getEmail())#</td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#xmlformat(authors[i].getCurrentRole(currentBlogId).name)#</td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><cfif NOT authors[i].active>Not </cfif>Active</td>
				</tr>
			</cfloop>
		</table>
		<div class="pagingLinks">
			<cfif page NEQ 0>&lt; <a href="authors.cfm?search=#search#&page=#page-1#">Previous</a></cfif>
			<cfif hasNextPage>&nbsp;&nbsp;<a href="authors.cfm?search=#search#&page=#page+1#">Next </a> &gt;</cfif>
		</div>
		</cfoutput>
		
		</div>
	</div>
	<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow you to manage users</p>
</div></div>
</cfif>
</div>
</cf_layout>