<cfsilent><!--- the code for this template can be greatly improved... --->
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="id" default="" />		
	<cfparam name="title" default="" />
	<cfparam name="name" default="" />
	<cfparam name="content" default="" />
	<cfparam name="excerpt" default="" />
	<cfparam name="error" default="" />
	<cfparam name="message" default="" />
	<cfparam name="sortOrder" default="1" />
	<cfparam name="template" default="page.cfm" />
	<cfparam name="allowComments" default="false" />
	<cfparam name="publish" default="published" />
	<cfparam name="parent" default="" />
	<cfparam name="mode" default="new" />
	<cfparam name="customFields" default="#arraynew(1)#">
	<cfparam name="customFormFields" default="#arraynew(1)#">
	<cfparam name="totalCustomFields" default="1">
	<cfparam name="panel" default="">
	<cfparam name="ownerMainMenu" default="Pages">
		
	<cfset templates = request.administrator.getPageTemplates() />
	<cfset pagetitle = "New page" />
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
			<cfset result = request.formHandler.handleEditPage(form) />
		<cfelse>
			<cfset result = request.formHandler.handleAddPage(form) />
			<cfif StructKeyExists(result,"newpage")>
				<cfset id = result.newpage.id />
				<cfset mode = "update" />
			</cfif>
		</cfif>
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
		
	<cftry>
		<cfif mode EQ "update">
			<!--- get post by id --->
			<cfset page = request.administrator.getPage(id) />
			
			<cfif Len(page.getName())>
				<cfset pageUrl = request.blogManager.getBlog().geturl() & page.getUrl() />
			<cfelse>
				<cfset pageUrl = request.blogManager.getBlog().geturl() & replacenocase(rereplacenocase(request.blogManager.getBlog().getSetting("pageUrl"),"{page(name|id)}",page.getId()),"{pageHierarchyNames}","") />
			</cfif>
			<cfif page.status NEQ "published">
				<cfif val(request.blogManager.getBlog().getSetting("useFriendlyUrls"))>
					<cfset pageUrl = pageUrl & "?preview=1">
				<cfelse>
					<cfset pageUrl = pageUrl & "&preview=1">
				</cfif>
			</cfif>
			<cfset pagetitle = 'Editing "<a href="#pageUrl#" target="_blank">#xmlformat(page.getTitle())#</a>"'>
			
		<cfelse>
			<cfset page = request.blogManager.getObjectFactory().createPage() />
		</cfif>	
		
		<cfif page.customFieldExists("entryType")>
			<cfset panel = page.getCustomField("entryType").value />		
		</cfif>
	<cfcatch type="any">
			<cfset error = cfcatch.message />
			<cfset page = request.blogManager.getObjectFactory().createPage() />
		</cfcatch>
	</cftry>
	
		<cfset panelData = request.administrator.getCustomPanel(panel,'page') />
		<cfset request.panelData = panelData />
		
		<cfif mode EQ "new">
			<!--- use default value from panel data --->
			<cfset page.setTitle(panelData.standardFields['title'].value) />
			<cfset page.setName(panelData.standardFields['name'].value) />
			<cfset page.setContent(panelData.standardFields['content'].value) />
			<cfset page.setExcerpt(panelData.standardFields['excerpt'].value) />
			<cfset page.setCommentsAllowed(panelData.standardFields['comments_allowed'].value) />
			<!--- set default publishing permission if user doesn't have permissions --->
			<cfif listfind(currentRole.permissions, "publish_pages")>
				<cfset page.setStatus(panelData.standardFields['status'].value) />
			<cfelse>
				<cfset page.setStatus("draft") />
			</cfif>
			<cfset page.setParentPageId(panelData.standardFields['parent'].value) />
			<cfset page.setTemplate(panelData.standardFields['template'].value) />
			<cfset page.setSortOrder(panelData.standardFields['sortOrder'].value) />
		</cfif>
		
		<!--- send event to give opportunity to plugins to pre-populate a default page --->
		<cfset args = structnew() />
		<cfset args.item = page />
		<cfset args.formName = "pageForm" />
		<cfset args.request = request />
		<cfset args.formScope = form />
		<cfset args.status = mode />
		<cfset event = pluginQueue.createEvent("beforeAdminPageFormDisplay",args,"AdminForm") />
		<cfset event = pluginQueue.broadcastEvent(event) />
			
		<cfset page = event.item />
	
		<!--- also create the event that will be used to show extra data at the end of the form --->
		<cfset event = pluginQueue.createEvent("beforeAdminPageFormEnd",args,"AdminForm") />
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
			<cfif page.customFieldExists(customFormFields[i].id)>
				<cfset customFormFields[i].value = page.getCustomField(customFormFields[i].id).value />
			<cfelseif page.id NEQ "">
				<cfset customFormFields[i].value = "">
			</cfif>
			<cfset page.removeCustomField(customFormFields[i].id) />
		</cfloop>		
		
		<cfset customFields = page.getCustomFieldsAsArray() />
		
		<cfif NOT len(error)>			
			<cfset title = page.getTitle() />
			<cfset name = page.getName() />
			<cfset content = page.getContent() />
			<cfset excerpt = page.getExcerpt() />
			<cfset allowComments = page.getCommentsAllowed() />
			<!--- keep the original status regardless of permissions --->
			<cfset publish = page.getStatus() />
			<cfset parent = page.getParentPageId() />
			<cfset template = page.getTemplate() />
			<cfset sortOrder = page.getSortOrder() />			
		</cfif>
	
	<!--- remove publish settings if user doesn't have permissions --->
	<cfif NOT listfind(currentRole.permissions, "publish_pages") AND listfind(showFields, "status")>
		<cfset showFields = listdeleteat(showFields, listfind(showFields, "status")) />
	</cfif>
	
	<cfset totalCustomFields = arraylen(customFields) + arraylen(customFormFields) + 1 />
	
	<!--- get pages --->
	<cfset pages = request.administrator.getPages() />
	
	<cfif panelData.showInMenu EQ "primary">
		<cfset ownerMainMenu = panel />
	</cfif>
</cfsilent>
<cf_layout page="#ownerMainMenu#" title="#panelData.label#">	
	<script type="text/javascript" src="assets/scripts/keep-alive.js" ></script>
<div id="wrapper">
<cfif listfind(currentRole.permissions, "manage_all_pages") OR
		(listfind(currentRole.permissions, "manage_pages") AND 
			(mode EQ "new" OR page.authorId EQ currentAuthor.id))>
	<div id="submenucontainer">
		<ul id="submenu">
			<cfif panelData.showInMenu EQ "secondary">
			<cfif NOT len(preferences) OR listfind(preferences,"pages_new")>
			<li><a href="page.cfm"<cfif mode EQ "new" AND panel EQ ""> class="current"</cfif>>New Page</a></li>
			</cfif>	
			<li><a href="pages.cfm"<cfif mode EQ "update" AND panel EQ ""> class="current"</cfif>>Edit Page</a></li>
			<mangoAdmin:MenuEvent name="pagesNav" />
			<cfelse>
			<cfoutput><li><a href="page.cfm?panel=#panel#&amp;owner=#ownerMainMenu#"<cfif mode EQ "new" AND panel NEQ ""> class="current"</cfif>>New</a></li>	
			<li><a href="pages.cfm?panel=#panel#&amp;owner=#ownerMainMenu#"<cfif mode EQ "update" AND panel NEQ ""> class="current"</cfif>>Edit</a></li>
			<mangoAdmin:MenuEvent name="customPagesNav" owner="#panel#Panel"/></cfoutput>
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
			<cfinclude template="pageForm.cfm">
		</cfif>
		<mangoAdmin:Event name="beforeAdminPageContentEnd" item="#page#" />
		
		</div>
	</div>
	<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow <cfif mode EQ "new">adding new pages<cfelse>editing this page</cfif></p>
</div></div>
</cfif>
</div>
</cf_layout>