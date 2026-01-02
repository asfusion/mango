	<cfimport prefix="mangoAdminPartials" taglib="partials">
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfimport prefix="partials" taglib="partials">
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	<cfparam name="template" default="global">

	<cfset blog = request.administrator.getBlog() />
	<cfset skin = blog.getSkin() />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentRole = currentAuthor.getCurrentRole(blog.getId())/>
	<cfset currentTemplates = request.administrator.getCurrentTemplates( ) />
	<cfset currentTemplate = request.administrator.getCurrentTemplate( template ) />

	<cfif structkeyexists( form,"submit" )>
		<cfif form.type EQ "global">
			<cfset result = request.formHandler.handleEditSkinSettings( form ) />
		<cfelse>
			<cfset result = request.formHandler.handleEditTemplateBlocks( form ) />
		</cfif>
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	<cfif structkeyexists( form,"add-block" )><!--- save values and add the block ---->
		<cfset result = request.formHandler.handleEditTemplateBlocks( form ) />
		<cfset newblocks = request.administrator.addEmptyBlock( request.administrator.getBlockValues( currentTemplate.id ), currentTemplate.blocks, listFirst( form[ 'add-block' ], '*' ), listlast( form[ 'add-block' ], '*' )) />
		<cfset request.administrator.saveTemplateBlocks( currentTemplate.id, newblocks )>
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>

	<cfif structkeyexists( form,"remove-block" )><!--- save values and remove the block ---->
		<cfset result = request.formHandler.handleEditTemplateBlocks( form, form[ 'remove-block' ] ) />
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>

	<cfset blocks = [] />
	<cfif structKeyExists( currentTemplate, 'blocks' )>
		<cfset blocks = request.administrator.prepareBlocksForEdit( currentTemplate.blocks, request.administrator.getBlockValues( currentTemplate.id ) ) />
	</cfif>

	<cfset currentSkin = request.administrator.getSkin( skin, true ) />
	<cfset breadcrumb = [ { 'link' = 'skins.cfm', 'title' = request.i18n.getValue("Design") },  { 'title' = request.i18n.getValue("Theme settings") } ] />

<cf_layout page="Themes" title="#request.i18n.getValue("Design")#" hierarchy="#breadcrumb#">
<cfoutput>
	<nav class="nav navbar-dashboard navbar-dark flex-column flex-sm-row mb-4">
		<a href="skins.cfm" class="nav-link">
			<span class="sidebar-icon">
				<i class="bi icon icon-xs"></i>
			</span>
			<span class="sidebar-text">#request.i18n.getValue("Themes")#</span>
		</a>
	<cfif arraylen( currentSkin.settings )>
			<a href="skins_settings.cfm" class="nav-link <cfif template EQ "global">active</cfif>">
			<span class="sidebar-icon">
				<i class="bi icon icon-xs"></i>
			</span>
			<span class="sidebar-text">#request.i18n.getValue("Theme settings")#</span>
			</a>
	</cfif>
	<cfif arraylen( currentTemplates )>
			<cfloop array="#currentTemplates#" item="templateitem">
					<a href="skins_settings.cfm?template=#templateitem.template#" class="nav-link <cfif template EQ templateitem.template>active</cfif>">
					<span class="sidebar-icon">
				<i class="bi icon icon-xs"></i>
			</span>
				<span class="sidebar-text">#request.i18n.getValue("{1} settings", [templateitem.label])#</span>
				</a>
			</cfloop>
	</cfif>
		<mangoAdmin:SecondaryMenuEvent name="skinsNav" includewrapper="false" />
	</nav>

	<cfif listfind(currentRole.permissions, "manage_themes") OR listfind(currentRole.permissions, "set_themes")>
			<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
			<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>
			<form method="post" action="#cgi.SCRIPT_NAME#">
			<cfif template EQ "global">
				<div class="card border-0 shadow mb-4">
				<div class="card-body">
					<div class="card-title">
						<h4 class="card-title">#request.i18n.getValue("Current theme settings")#</h4>
					</div>
					<cfset i = 0 />
					<div class="row mb-4">
					<cfloop array="#currentSkin.settings#" item="setting">
						<cfset i++>
						<cfset checkValue = ''/>
						<cfif structKeyExists( setting, 'checkValue' )>
							<cfset checkValue = setting.checkValue />
						</cfif>
						<partials:form_field id="setting_#i#_value" type="#setting.type#" options="#setting.options#"
									label="#request.i18n.getValue(setting.name)#" size="#setting.size#" hint="#setting.hint#" value="#setting.value#" checkValue="#checkValue#" />
							<input type="hidden" name="setting_#i#_key" value="#htmleditformat(setting.key)#" />
							<input type="hidden" name="setting_#i#_path" value="#htmleditformat(setting.path)#" />
							<input type="hidden" name="setting_#i#_type" value="#htmleditformat(setting.type)#" />
					</cfloop>
						<input type="hidden" name="total_fields" value="#i#" />
					</div>
				</div>
				<div class="card-footer text-end">
					<button class="btn btn-primary mt-2 animate-up-2" type="submit">#request.i18n.getValue("Save")#</button>
					<input type="hidden" name="submit" id="submit" value="submit" />
						<input type="hidden" name="type" value="global" />
				</div>
			</div>
			<cfelse>
				<div class="d-flex justify-content-end flex-wrap flex-md-nowrap align-items-center mb-4">
					<button type="submit" class="btn btn-primary d-inline-flex align-items-center me-2 animate-up-2" name="submit" value="all">#request.i18n.getValue("Save all")#</button>
				</div>
				<input type="hidden" name="id" value="#currentTemplate.id#" />
				<!--- template specific settings and blocks --->
				<mangoAdminPartials:blocks blocks="#blocks#" />
					<div class="d-flex justify-content-end flex-wrap flex-md-nowrap align-items-center py-4">
						<button type="submit" class="btn btn-primary d-inline-flex align-items-center me-2 animate-up-2" name="submit" value="all">#request.i18n.getValue("Save all")#</button>
					</div>
					<input type="hidden" name="type" value="template" />
					<input type="hidden" name="template" value="#template#" />
			</cfif>
			</form>

	<cfelse><!--- not authorized --->
		<div class="alert alert-info" role="alert">#request.i18n.getValue("Your role does not allow editing themes")#</div>
	</cfif>
</cfoutput>
</cf_layout>