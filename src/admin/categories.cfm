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
	
</cfsilent>
<cf_layout page="Categories" title="Categories">
	<div id="wrapper">
	<cfif listfind(currentRole.permissions, "manage_categories")>
	<div id="submenucontainer">
		<ul id="submenu">
			<cfif NOT len(preferences) OR listfind(preferences,"categories_new")>
			<li><a href="category.cfm">New Category</a></li>	
			</cfif>
			<li><a href="categories.cfm" class="current">Edit Category</a></li>
			<mangoAdmin:MenuEvent name="categoriesNav" />
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle">All categories</h2>
		
		<div id="innercontent">
		<cfif len(error)>
			<p class="error"><cfoutput>#error#</cfoutput></p>
		</cfif>
		<cfif len(message)>
			<p class="message"><cfoutput>#message#</cfoutput></p>
		</cfif>
		
		<cfoutput>
		<table cellspacing="0">
			<tr><th class="buttonColumn">Edit</th><th>Name</th><th>Delete</th></tr>
			<cfloop from="1" to="#arraylen(categories)#" index="i">
				<tr>					
					<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="category.cfm?id=#categories[i].getId()#" class="editButton">Edit</a></td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#xmlformat(categories[i].getTitle())#</td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="categories.cfm?action=delete&amp;id=#categories[i].getId()#"  class="deleteButton">Delete</a></td>
				</tr>
			</cfloop>
		</table>
		</cfoutput>
		
		</div>
	</div>
<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow you to edit categories</p>
</div></div>
</cfif>
</div>
</cf_layout>