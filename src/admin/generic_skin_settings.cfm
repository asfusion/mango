	<cfimport prefix="mangoAdmin" taglib="tags">

	<cfset blog = request.administrator.getBlog() />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = blog.getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset skin = blog.getSkin() />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentRole = currentAuthor.getCurrentRole( currentBlogId )/>
	<cfset currentSkin = request.administrator.getSkin( skin, true ) />
	<cfset currentTemplates = request.administrator.getCurrentTemplates( ) />

	<cfset breadcrumb = request.message.getHierarchy() />

<cf_layout page="Themes" title="Design" hierarchy="#breadcrumb#">
<cfif listfind(currentRole.permissions, "manage_plugin_prefs")>

	<nav class="nav navbar-dashboard navbar-dark flex-column flex-sm-row mb-4">
		<a href="skins.cfm" class="nav-link">
			<span class="sidebar-icon"><i class="bi icon icon-xs"></i></span>
			<span class="sidebar-text">Themes</span>
		</a>
	<cfif arraylen( currentSkin.settings )>
			<a href="skins_settings.cfm" class="nav-link">
			<span class="sidebar-icon"><i class="bi icon icon-xs"></i></span>
			<span class="sidebar-text">Theme settings</span>
		</a>
	</cfif>
	<cfif arraylen( currentTemplates )>
		<cfoutput>
			<cfloop array="#currentTemplates#" item="templateitem">
				<a href="skins_settings.cfm?template=#templateitem.template#" class="nav-link">
					<span class="sidebar-icon"><i class="bi icon icon-xs"></i></span>
					<span class="sidebar-text">#templateitem.label# settings</span>
				</a>
			</cfloop>
		</cfoutput>
	</cfif>
		<mangoAdmin:SecondaryMenuEvent name="skinsNav" includewrapper="false" />
	</nav>

	<h4 class="h4"><mangoAdmin:Message title /></h4>
		<cfoutput>
			<mangoAdmin:Message ifMessageExists type="generic" status="success">
				<div class="alert alert-success" role="alert"><mangoAdmin:Message text /></div>
			</mangoAdmin:Message>
			<mangoAdmin:Message ifMessageExists type="generic" status="error">
				<div class="alert alert-danger" role="alert"><mangoAdmin:Message text /></div>
			</mangoAdmin:Message>

			<mangoAdmin:Message data />
		</cfoutput>
<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert">Your role does not allow you to edit settings</div>
</cfif>
</cf_layout>