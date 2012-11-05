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
	<cfset preferences = currentRole.preferences.get("admin","menuItems","") />
	<cfset postsManager = request.blogManager.getPostsManager() />
	
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
			<cfset pageTitle = 'Searching posts for "#search#"' />
		<cfelseif listfind(currentRole.permissions, "manage_all_posts")>
			<cfset totalPosts = postsManager.getPostCount(true) />
			<cfset posts = postsManager.getPosts((page * itemsPerPage) + 1, itemsPerPage, true, false) />
			<cfset hasNextPage = totalPosts GT ((page + 1) * itemsPerPage)>
		<cfelse>
			<cfset posts = postsManager.getPostsByAuthor(currentAuthor.id, (page * itemsPerPage) + 1, itemsPerPage,true) />
			<!--- since I can't get the total, I'll make another query for the first next item,
			if there is one, then there are more pages --->
			<cfset hasNextPage = arraylen(postsManager.getPostsByAuthor(currentAuthor.id, ((page + 1) * itemsPerPage) + 1, 1,true)) />
		</cfif>
	<cfelse>
		<cfset posts = postsManager.getPostsByCustomField("entryType",panel, (page * itemsPerPage) + 1, itemsPerPage,true,false) />
		<cfset pageTitle = "#panelData.label#: All" />
		<!--- since I can't get the total, I'll make another query for the first next item,
			if there is one, then there are more pages --->
		<cfset hasNextPage = arraylen(postsManager.getPostsByCustomField("entryType",panel, ((page + 1) * itemsPerPage) + 1, 1,true,false)) />
	</cfif>
	
	
	<cfif panelData.showInMenu EQ "primary">
		<cfset ownerMainMenu = panel />
	</cfif>
</cfsilent>
<cf_layout page="#ownerMainMenu#" title="#panelData.label#">
<div id="wrapper">
<cfif listfind(currentRole.permissions, "manage_all_posts") OR
		listfind(currentRole.permissions, "manage_posts")>
	<div id="submenucontainer">
		<ul id="submenu">
			<cfif panelData.showInMenu EQ "secondary">
			<cfif NOT len(preferences) OR listfind(preferences,"posts_new")>
			<li><a href="post.cfm">New Post</a></li>
			</cfif>
			<li><a href="posts.cfm"<cfif panel EQ ""> class="current"</cfif>>Edit Post</a></li>
			<mangoAdmin:MenuEvent name="postsNav" />
			<cfelse>
			<cfoutput><li><a href="post.cfm?panel=#panel#&amp;owner=#ownerMainMenu#">New</a></li></cfoutput>
			<li><a href="" class="current">Edit</a></li>
			<mangoAdmin:MenuEvent name="customPostsNav" owner="#panel#Panel"/>
			</cfif>
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle"><cfoutput>#pageTitle#</cfoutput>
		<span class="search">Search posts: <form class="inline-form" action="posts.cfm">
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
			<cfif page NEQ 0>&lt; <a href="posts.cfm?panel=#panel#&amp;owner=#panel#&search=#search#&page=#page-1#">Previous</a></cfif>
			<cfif hasNextPage>&nbsp;&nbsp;<a href="posts.cfm?panel=#panel#&amp;owner=#panel#&search=#search#&page=#page+1#">Next </a> &gt;</cfif>
		</div>
		<cfif NOT len(preferences) OR listfind(preferences,"posts_new")><p class="buttonBar"><a href="post.cfm?panel=#panel#&amp;owner=#panel#" class="editButton">Create New<cfif panel EQ ""> Post</cfif></a></p><strong></strong>
		</cfif>
		<table cellspacing="0">
			<tr><th class="buttonColumn">Edit</th><th>Title</th><th>Date</th><th>Status</th><th>Comments</th><th>Author</th><th>Delete</th></tr>
			<cfloop from="1" to="#arraylen(posts)#" index="i">
				<!--- since this is used by list of posts of a custom panel,
				we need to check if the user has enough permissions --->
				<cfif listfind(currentRole.permissions, "manage_all_posts") OR
				posts[i].getauthorId() EQ currentAuthor.id>
				<cfset currentTitle = xmlformat(posts[i].getTitle()) />
				<tr>
					<td class="buttonColumn<cfif NOT i mod 2> alternate</cfif>"><a href="post.cfm?id=#posts[i].getId()#&amp;owner=#panel#" class="editButton">Edit</a></td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><cfif len(currentTitle)>#currentTitle#<cfelse>--Untitled--</cfif></td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#dateformat(posts[i].getPostedOn(),'short')#</td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#posts[i].getStatus()#</td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="comments.cfm?entry_id=#posts[i].getId()#">#posts[i].getCommentCount()#</a></td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#posts[i].getAuthor()#</td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="posts.cfm?action=delete&amp;id=#posts[i].getId()#&amp;panel=#panel#&amp;owner=#panel#"  class="deleteButton">Delete</a></td>
				</tr>
				</cfif>
			</cfloop>
		</table>
		<div class="pagingLinks">
			<cfif page NEQ 0>&lt; <a href="posts.cfm?panel=#panel#&amp;owner=#panel#&page=#page-1#">Previous</a></cfif>
			<cfif hasNextPage>&nbsp;&nbsp;<a href="posts.cfm?panel=#panel#&amp;owner=#panel#&page=#page+1#">Next </a> &gt;</cfif>
		</div>
		</cfoutput>
		</div>
	</div>
	<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow you to edit posts</p>
</div></div>
</cfif>
</div>
</cf_layout>