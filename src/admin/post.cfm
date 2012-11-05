<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<!--- the code for this template can be greatly improved... --->
	<cfparam name="id" default="" />		
	<cfparam name="title" default="" />
	<cfparam name="name" default="" />
	<cfparam name="content" default="" />
	<cfparam name="excerpt" default="" />
	<cfparam name="postedOn" default="#dateformat(now(),'mm/dd/yy')# #timeformat(now(),'medium')#" />
	<cfparam name="error" default="" />
	<cfparam name="message" default="" />
	<cfparam name="allowComments" default="true" />
	<cfparam name="publish" default="published" />
	<cfparam name="categoriesList" default="">
	<cfparam name="customFields" default="#arraynew(1)#">
	<cfparam name="mode" default="new" />
	<cfparam name="customFormFields" default="#arraynew(1)#">
	<cfparam name="totalCustomFields" default="1">
	<cfparam name="panel" default="">
	<cfparam name="ownerMainMenu" default="Posts">
	
	<cfset pagetitle = "New post" />
	<cfset pluginQueue = request.blogManager.getpluginQueue() />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset preferences = currentRole.preferences.get("admin","menuItems","") />
	
	<cfif id NEQ "">
		<cfset mode = "update" />
	</cfif>
	
	<cfif structkeyexists(form,"submit")>
		<cfif mode EQ "update">
			<cfset result = request.formHandler.handleEditPost(form) />
		<cfelse>
			<cfset result = request.formHandler.handleAddPost(form) />
		</cfif>
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
			<cfif StructKeyExists(result,"newpost")>
				<cfset id = result.newpost.id />
				<cfset mode = "update" />
			</cfif>
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	
	<cftry>
		<cfif mode EQ "update">
			<!--- get post by id --->
			<cfset post = request.administrator.getPost(id) />
			<cfif Len(post.getName())>
				<cfset postUrl = request.blogManager.getBlog().geturl() & post.getUrl() />
			<cfelse>
				<cfset postUrl = request.blogManager.getBlog().geturl() & rereplacenocase(request.blogManager.getBlog().getSetting("postUrl"),"{post(name|id)}",post.getId()) />
			</cfif>
			<cfif post.status NEQ "published" or dateDiff('n',now(), post.postedOn) gt 0>
				<cfif val(request.blogManager.getBlog().getSetting("useFriendlyUrls"))>
					<cfset postUrl = postUrl & "?preview=1">
				<cfelse>
					<cfset postUrl = postUrl & "&preview=1">
				</cfif>
			</cfif>
			<cfset pagetitle = 'Editing "<a href="#postUrl#" target="_blank">#xmlformat(post.getTitle())#</a>"'>
		<cfelse>
			<cfset post = request.blogManager.getObjectFactory().createPost() />
		</cfif>	
		
		<cfif post.customFieldExists("entryType")>
			<cfset panel = post.getCustomField("entryType").value />		
		</cfif>
	<cfcatch type="any">
		<cfset error = cfcatch.message />
		<cfset post = request.blogManager.getObjectFactory().createPost() />
	</cfcatch>
	</cftry>
	
		<cfset panelData = request.administrator.getCustomPanel(panel,'post') />
		<cfset request.panelData = panelData />
		
		<cfif mode EQ "new">
			<!--- use default value from panel data --->
			<cfset post.setTitle(panelData.standardFields['title'].value) />
			<cfset post.setName(panelData.standardFields['name'].value) />
			<cfset post.setContent(panelData.standardFields['content'].value) />
			<cfset post.setExcerpt(panelData.standardFields['excerpt'].value) />
			<cfset post.setCommentsAllowed(panelData.standardFields['comments_allowed'].value) />
			<!--- set default publishing permission if user doesn't have permissions --->
			<cfif listfind(currentRole.permissions, "publish_posts")>
				<cfset post.setStatus(panelData.standardFields['status'].value) />
			<cfelse>
				<cfset post.setStatus("draft") />
			</cfif>
			<!--- add categories and date --->
			<cfif len(panelData.standardFields['posted_on'].value)>
				<cfset post.setPostedOn(panelData.standardFields['posted_on'].value) />
			</cfif>
			<cfif len(panelData.standardFields['categories'].value)>
				<cfset categoriesArray = arraynew(1) />
				<cfloop list="#panelData.standardFields['categories'].value#" index="catItem">
					<cfset catData = structnew() />
					<cfset catData.id = catItem />
					<cfset arrayappend(categoriesArray,catData) />
				</cfloop>
				<cfset post.setCategories(categoriesArray) />
			</cfif>
		</cfif>

		<!--- send event to give opportunity to plugins to pre-populate the post --->
		<cfset args = structnew() />
		<cfset args.item = post />
		<cfset args.formName = "postForm" />
		<cfset args.request = request />
		<cfset args.formScope = form />
		<cfset args.status = mode />
		<cfset event = pluginQueue.createEvent("beforeAdminPostFormDisplay",args,"AdminForm") />
		<cfset event = pluginQueue.broadcastEvent(event) />
		
		<cfset post = event.item />
		
		<!--- also create the event that will be used to show extra data at the end of the form --->
		<cfset event = pluginQueue.createEvent("beforeAdminPostFormEnd",args,"AdminForm") />
		<cfset event = pluginQueue.broadcastEvent(event) />
		
		<!--- now remove the custom fields that are shown in the panel to avoid duplication --->		
		<cfset customFormFields = panelData.customFields />
		<cfset showFields = panelData.getShowFields() />
		
		<cfset hiddenPanelField = structnew() />
		<cfset hiddenPanelField["id"] = "entryType" />
		<cfset hiddenPanelField["value"] = panel />
		<cfset hiddenPanelField["name"] = "Entry Type"/>
		<cfset hiddenPanelField["inputType"] = "hidden">
		<cfset arrayappend(customFormFields,hiddenPanelField)>
		
		<cfloop from="1" to="#arraylen(customFormFields)#" index="i">
			<cfif post.customFieldExists(customFormFields[i].id)>
				<cfset customFormFields[i].value = post.getCustomField(customFormFields[i].id).value />
			<cfelseif post.id NEQ "">
				<cfset customFormFields[i].value = "">
			</cfif>
			<cfset post.removeCustomField(customFormFields[i].id) />
		</cfloop>		
		
		<cfset customFields = post.getCustomFieldsAsArray() />
		
		<!--- get post by id --->
	<cfif NOT len(error)>
		<cfset title = post.getTitle() />
		<cfset name = post.getName() />
		<cfset content = post.getContent() />
		<cfset excerpt = post.getExcerpt() />
		<cfset allowComments = post.getCommentsAllowed() />
		<!--- keep the original status regardless of permissions --->
		<cfset publish = post.getStatus() />
		<cfset postedOn = dateformat(post.getPostedOn(),'short') & " " & timeformat(post.getPostedOn(),'medium') />
		<cfset categories = post.getCategories() />
		<cfset categoriesList = "" />
				
		<cfloop from="1" to="#arraylen(categories)#" index="i">
			<cfset categoriesList = listappend(categoriesList,categories[i].id) />
		</cfloop>
	</cfif>
	<!--- remove publish settings if user doesn't have permissions --->
	<cfif NOT listfind(currentRole.permissions, "publish_posts") AND listfind(showFields, "status")>
		<cfset showFields = listdeleteat(showFields, listfind(showFields, "status")) />
	</cfif>
	
	<cfset totalCustomFields = arraylen(customFields) + arraylen(customFormFields) + 1 />
	<!--- get categories --->
	<cfset categories = request.administrator.getCategories() />

	<cfif panelData.showInMenu EQ "primary">
		<cfset ownerMainMenu = panel />
	</cfif>
</cfsilent>
<cf_layout page="#ownerMainMenu#" title="#panelData.label#">
	<script type="text/javascript" src="assets/scripts/keep-alive.js" ></script>
<div id="wrapper">
<cfif listfind(currentRole.permissions, "manage_all_posts") OR
		(listfind(currentRole.permissions, "manage_posts") AND 
			(mode EQ "new" OR post.authorId EQ currentAuthor.id))>
	<div id="submenucontainer">
		<ul id="submenu">
			<cfif panelData.showInMenu EQ "secondary">
			<cfif NOT len(preferences) OR listfind(preferences,"posts_new")>
			<li><a href="post.cfm"<cfif mode EQ "new" AND panel EQ ""> class="current"</cfif>>New Post</a></li>	
			</cfif>			
			<li><a href="posts.cfm"<cfif mode EQ "update" AND panel EQ ""> class="current"</cfif>>Edit Post</a></li>
			<mangoAdmin:MenuEvent name="postsNav" />
			<cfelse>
			<cfoutput><li><a href="post.cfm?panel=#panel#&amp;owner=#ownerMainMenu#"<cfif mode EQ "new" AND panel NEQ ""> class="current"</cfif>>New</a></li>	
			<li><a href="posts.cfm?panel=#panel#&amp;owner=#ownerMainMenu#"<cfif mode EQ "update" AND panel NEQ ""> class="current"</cfif>>Edit</a></li>
			<mangoAdmin:MenuEvent name="customPostsNav" owner="#panel#Panel"/></cfoutput>
			</cfif>
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle"><cfoutput>#pagetitle#</cfoutput></h2>
		
		<div id="innercontent">
		<cfif len(error)>
			<p class="error"><cfoutput>#error#</cfoutput></p>
		</cfif>
		<cfif len(message)>
			<p class="message"><cfoutput>#message#</cfoutput></p>
		</cfif>
		
		<cfif len(panelData.template)>
			<cfinclude template="#panelData.template#">
		<cfelse>
			<cfinclude template="postForm.cfm">
		</cfif>
		<mangoAdmin:Event name="beforeAdminPostContentEnd" item="#post#" />
		</div>
	</div>
		<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow <cfif mode EQ "new">adding new posts<cfelse>editing this post</cfif></p>
</div></div>
</cfif>
</div>
</cf_layout>