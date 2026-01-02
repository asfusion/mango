<!--- <cfsilent> --->
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
	<cfparam name="designer" default="">

	<cfset pageUrl = '' />

	<cfset pagetitle = request.i18n.getValue("New page") />
	<cfset pluginQueue = request.blogManager.getpluginQueue() />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset preferences = currentRole.preferences.get( "admin","menuItems","" ) />

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
			<cfset pagetitle = request.i18n.getValue("Editing {1}", htmlEditFormat(page.getTitle()))>
			
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
		<cfset request.displayData = panelData /><!--- new more generic name --->

<!--- send event to give opportunity to plugins to pre-populate a default page --->
	<cfset args = structnew() />
	<cfset args.item = page />
	<cfset args.formName = "pageForm" />
	<cfset args.request = request />
	<cfset args.formScope = form />
	<cfset args.status = mode />
	<cfset args.display = request.displayData />
	<cfset event = pluginQueue.createEvent("beforeAdminPageFormDisplay",args,"AdminForm") />
	<cfset event = pluginQueue.broadcastEvent(event) />

	<cfset page = event.item />

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
		
	<!--- also create the event that will be used to show extra data at the end of the form, show at the end of form by using event.getOutputdata() --->
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
		<cfelseif page.id NEQ "" AND structKeyExists( customFormFields[i], 'value' )><!--- 	 set default value  --->
			<cfset customFormFields[i].value = customFormFields[i].value />
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

<cfset skinBlockInfo = request.administrator.getPageSkinInfo( page )>
<cfset templates = skinBlockInfo.availableTemplates />
<!--- </cfsilent> --->
<cfset breadcrumb = [ { 'link' = 'pages.cfm?panel=#panel#&amp;owner=#panel#', 'title' = panelData.label },
{ 'title' = ( mode EQ "update" ) ? request.i18n.getValue("Editing") : request.i18n.getValue("New") } ] />

<cf_layout page="#ownerMainMenu#" title="#panelData.label#" hierarchy="#breadcrumb#">
	<script type="text/javascript" src="assets/scripts/keep-alive.js" ></script>
<cfif listfind(currentRole.permissions, "manage_all_pages") OR
		(listfind(currentRole.permissions, "manage_pages") AND (mode EQ "new" OR page.authorId EQ currentAuthor.id))>
		<cfoutput>
			<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
			<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

		<form method="post" action="#cgi.SCRIPT_NAME#" name="pageForm" id="pageForm">
		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
			<h4 class="h4">#pageTitle#</h4>
			<div>
				<input type="submit" class="btn btn-primary d-inline-flex align-items-center me-2 animate-up-2" name="submit" value="#request.i18n.getValue("Save")#" />
				<cfif mode EQ "update" AND skinBlockInfo.hasBlocks>
						<a href="pageBuilder.cfm?panel=#panel#&amp;owner=#ownerMainMenu#&id=#id#"><button type="button" class="btn btn-tertiary d-inline-flex align-items-center me-2">#request.i18n.getValue("Designer")#</button></a>
				</cfif>
				<cfif len( pageUrl )>
					<a href="#pageUrl#" target="_blank"><button type="button" class="btn btn-outline-info d-inline-flex align-items-center me-2">#request.i18n.getValue("View")#</button></a>
				</cfif>
			</div>
		</div>

		<cfif len(panelData.template)>
			<cfinclude template="#panelData.template#">
		<cfelse>
			<cfinclude template="pageForm.cfm">
		</cfif>
			<mangoAdmin:Event name="beforeAdminPageContentEnd" item="#page#" />
		</form>
		</cfoutput>
<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert"><cfif mode EQ "new">#request.i18n.getValue("Your role does not allow adding new pages")#<cfelse>#request.i18n.getValue("Your role does not allow editing this page")#</cfif></div>
</cfif>
</cf_layout>