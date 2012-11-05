<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
</cfsilent>
<cf_layout page="Settings" title="Settings">
<div id="wrapper">
<cfif listfind(currentRole.permissions, "manage_plugin_prefs")>
	<div id="submenucontainer">
		<ul id="submenu">
			<cfif listfind(currentRole.permissions, "manage_settings")>
			<li><a href="settings.cfm">General</a></li>
			</cfif>
			<cfif listfind(currentRole.permissions, "manage_plugin_prefs")>
			<mangoAdmin:MenuEvent name="settingsNav" />
			</cfif>
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle"><mangoAdmin:Message title /></h2>
		
		<div id="innercontent">
		<cfoutput>
			<mangoAdmin:Message ifMessageExists type="settings" status="error">
				<p class="error"><mangoAdmin:Message text /></p>
			</mangoAdmin:Message>
			<mangoAdmin:Message ifMessageExists type="settings" status="success">
				<p class="message"><mangoAdmin:Message text /></p>
			</mangoAdmin:Message>

			<mangoAdmin:Message data />
		</cfoutput>
		</div>
	</div>
<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="message">Your role does not allow you to edit settings</p>
</div></div>
</cfif>
</div>
</cf_layout>