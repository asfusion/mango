<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
</cfsilent>
<cf_layout page="Settings" title="#request.i18n.getValue("Settings")#">
	<cfoutput>
<cfif listfind(currentRole.permissions, "manage_plugin_prefs")>

	<nav class="nav navbar-dashboard navbar-dark flex-column flex-sm-row mb-4">
	<cfif listfind(currentRole.permissions, "manage_settings")>
			<a href="settings.cfm" class="nav-link">#request.i18n.getValue("General")#</a>
	</cfif>
	<cfif listfind(currentRole.permissions, "manage_plugin_prefs")>
		<mangoAdmin:SecondaryMenuEvent name="settingsNav" includewrapper="false" />
	</cfif>
	</nav>

	<h4 class="h4"><mangoAdmin:Message title /></h4>
		
			<mangoAdmin:Message ifMessageExists type="settings" status="success">
				<div class="alert alert-success" role="alert"><mangoAdmin:Message text /></div>
			</mangoAdmin:Message>
			<mangoAdmin:Message ifMessageExists type="settings" status="error">
				<div class="alert alert-danger" role="alert"><mangoAdmin:Message text /></div>
			</mangoAdmin:Message>

			<mangoAdmin:Message data />
		
<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert">#request.i18n.getValue("settings-permission-error")#</div>
</cfif>
</cfoutput>
</cf_layout>