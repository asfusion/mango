<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	<cfparam name="panel" default="">
	<cfparam name="ownerMainMenu" default="Pages">
	
	<cfset pagetitle = "All Pages" />
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
		<cfset pageTitle = "#panelData.label#: All" />
	</cfif>

	<cfif panelData.showInMenu EQ "primary">
		<cfset ownerMainMenu = panel />
	</cfif>
</cfsilent>
<cf_layout page="#ownerMainMenu#" title="#panelData.label#">	
<div id="wrapper">
<cfif listfind(currentRole.permissions, "manage_all_pages") OR
		listfind(currentRole.permissions, "manage_pages")>
	<div id="submenucontainer">
		<ul id="submenu">
			<cfif panelData.showInMenu EQ "secondary">
			<cfif NOT len(preferences) OR listfind(preferences,"pages_new")>
			<li><a href="page.cfm">New Page</a></li>
			</cfif>	
			<li><a href="pages.cfm"<cfif panel EQ ""> class="current"</cfif>>Edit Page</a></li>
			<mangoAdmin:MenuEvent name="pagesNav" />
			<cfelse>
			<cfoutput><li><a href="page.cfm?panel=#panel#&amp;owner=#ownerMainMenu#">New</a></li></cfoutput>
			<li><a href="" class="current">Edit</a></li>
			<mangoAdmin:MenuEvent name="customPagesNav" owner="#panel#Panel"/>
			</cfif>
		</ul>
	</div>

	<div id="content">
		<h2 class="pageTitle"><cfoutput>#pageTitle#</cfoutput></h2>
		
		<div id="innercontent">
		<cfif len(error)><p class="error"><cfoutput>#error#</cfoutput></p></cfif>
		<cfif len(message)><p class="message"><cfoutput>#message#</cfoutput></p></cfif>
		<cfoutput>
		<p class="buttonBar"><a href="page.cfm?panel=#panel#&amp;owner=#panel#" class="editButton">Create New<cfif panel EQ ""> Page</cfif></a></p>
		<table cellspacing="0">
			<tr><th class="buttonColumn">Edit</th><th>Title</th><th>Status</th><th>Comments</th><th>Delete</th></tr>
			<cfloop from="1" to="#arraylen(posts)#" index="i">
				<!--- since this is used by list of posts of a custom panel,
				we need to check if the user has enough permissions --->
				<cfif listfind(currentRole.permissions, "manage_all_pages") OR
				posts[i].getauthorId() EQ currentAuthor.id>
				<cfset currentTitle = xmlformat(posts[i].getTitle()) />
				<tr>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="page.cfm?id=#posts[i].getId()#&amp;owner=#panel#" class="editButton">Edit</a></td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><cfif len(currentTitle)>#currentTitle#<cfelse>--Untitled--</cfif></td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#posts[i].getStatus()#</td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="comments.cfm?entry_id=#posts[i].getId()#">#posts[i].getCommentCount()#</a></td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="pages.cfm?action=delete&amp;id=#posts[i].getId()#&amp;panel=#panel#&amp;owner=#panel#"  class="deleteButton">Delete</a></td>
				</tr>
				</cfif>
			</cfloop>
		</table>
		</cfoutput>		
		</div>
	</div>
	<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow you to edit pages</p>
</div></div>
</cfif>
</div>
</cf_layout>