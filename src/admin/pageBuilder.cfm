<cfimport prefix="mangoAdmin" taglib="tags">
<cfimport prefix="mangoAdminPartials" taglib="partials">
<cfparam name="id" default="" />
<cfparam name="error" default="" />
<cfparam name="message" default="" />
<cfparam name="form.block_count" default="0" />
<cfparam name="ownerMainMenu" default="Pages">

	<cfset templates = request.administrator.getAllTemplates() />
	<cfset pagetitle = "" />
	<cfset pluginQueue = request.blogManager.getpluginQueue() />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset preferences = currentRole.preferences.get("admin","menuItems","") />

<cfif structkeyexists(form,"submit")>
    <cfset result = request.formHandler.handleEditPageBlocks( form ) />

	<cfif result.message.getStatus() EQ "success">
		<cfset message = result.message.getText() />
	<cfelse>
		<cfset error = result.message.getText() />
	</cfif>
</cfif>
<cfif structkeyexists( form,"add-block" )><!--- save values and add the block ---->
	<cfset page = request.administrator.getPage(id) />
	<cfset skinBlockInfo = request.administrator.getPageSkinInfo( page )>
	<cfset result = request.formHandler.handleEditPageBlocks( form ) />
	<cfset newblocks = request.administrator.addEmptyBlock( result.blocks, skinBlockInfo.definition, listFirst( form[ 'add-block' ], '*' ), listlast( form[ 'add-block' ], '*' )) />
	<cfset request.formHandler.handleEditPageBlocksParsed( id, newblocks )>
	<cfif result.message.getStatus() EQ "success">
		<cfset message = result.message.getText() />
	<cfelse>
		<cfset error = result.message.getText() />
	</cfif>
</cfif>

<cfif structkeyexists( form,"remove-block" )><!--- save values and remove the block ---->
	<cfset result = request.formHandler.handleEditPageBlocks( form, form[ 'remove-block' ] ) />
	<cfif result.message.getStatus() EQ "success">
		<cfset message = result.message.getText() />
	<cfelse>
		<cfset error = result.message.getText() />
	</cfif>
</cfif>

<cfset page = request.administrator.getPage(id) />
<cfif len(page.getName())>
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
<cfset pagetitle = request.i18n.getValue("Editing {1}", xmlformat(page.getTitle()))>
<cfset skinBlockInfo = request.administrator.getPageSkinInfo( page )>

<cfset pageBlocks = "*" />
<cfif page.customFieldExists( 'blocks' )>
	<cfset currentBlocks = page.getCustomField( 'blocks' ).value />

	<cfif isJSON( currentBlocks )>
		<cfset pageBlocks = deserializeJSON( currentBlocks ) />
	<cfelse>
		<cfset pageBlocks = "*" />
	</cfif>
<cfelse>

</cfif>
<cfif NOT isArray( pageBlocks ) AND pageBlocks EQ '*'>
<!--- use only definition with all active --->
	<cfset pageBlocks = [] />
	<cfelseif NOT isArray( pageBlocks )>
	<cfset pageBlocks = [] />
</cfif>

<cfset blocks = request.administrator.prepareBlocksForEdit( skinBlockInfo.definition, pageBlocks ) />

<cfset breadcrumb = [ { 'link' = 'pages.cfm?panel=#panel#&amp;owner=#panel#', 'title' = request.i18n.getValue("Pages") },
{ 'link' = 'page.cfm?id=#id#&amp;owner=#panel#', 'title' = request.i18n.getValue("Edit") },
{ 'title' = request.i18n.getValue("Page Designer") } ] />

<cf_layout page="#ownerMainMenu#" title="#request.i18n.getValue("Page Designer")#" hierarchy="#breadcrumb#">
<script type="text/javascript" src="assets/scripts/keep-alive.js" ></script>
<cfif listfind(currentRole.permissions, "manage_all_pages") OR
(listfind(currentRole.permissions, "manage_pages") AND (mode EQ "new" OR page.authorId EQ currentAuthor.id))>

	<form method="post" action="#cgi.SCRIPT_NAME#" name="pageForm" id="pageForm">
    <cfoutput>
		<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
			<h4 class="h4">#pageTitle#</h4>
			<div>
				<input type="submit" class="btn btn-primary d-inline-flex align-items-center me-2 animate-up-2" name="submit" value="#request.i18n.getValue("Save all")#" />
				<a href="#pageUrl#" target="_blank"><button type="button" class="btn btn-outline-info d-inline-flex align-items-center me-2">#request.i18n.getValue("View")#</button></a>
				<a href="page.cfm?id=#id#&amp;owner=#panel#" class="text-primary d-inline-flex align-items-center">#request.i18n.getValue("Back to Page Settings")# <i class="bi bi-arrow-right-circle p-2"></i></a>
			</div>
		</div>

		<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
		<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>
            <input type="hidden" name="id" value="#id#"/>
			<mangoAdminPartials:blocks  entry="#page#" blocks="#blocks#" />
        </form>
    </cfoutput>
<cfelse><!--- not authorized --->
    <div class="alert alert-info" role="alert">Your role does not allow <cfif mode EQ "new">adding new pages<cfelse>editing this page</cfif></div>
</cfif>

</cf_layout>