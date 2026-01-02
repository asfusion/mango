<cfparam name="attributes.page" default="">
<cfimport prefix="mangoAdmin" taglib="tags">
<cfset page = attributes.page>
<cfset blog = request.blogManager.getBlog() />
<cfset currentAuthor = request.blogManager.getCurrentUser() />
<cfset currentBlogId = blog.getId() />
<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
<cfset permissions = currentRole.permissions />
<cfset preferences = currentRole.preferences.get("admin","menuItems","all") />

<cffunction name="showMenuItem" returntype="boolean">
	<cfargument name="permissionsAllowed">
	<cfargument name="preferenceAllowed">
	<cfset var i = 0 />
	<cfset var show = NOT len(arguments.permissionsAllowed) />

	<cfloop list="#arguments.permissionsAllowed#" index="i">
		<cfif listfind(permissions,i)>
			<cfset show = true />
			<cfbreak>
		</cfif>
	</cfloop>

	<cfreturn show AND (NOT len(arguments.preferenceAllowed) OR listfind(preferences,arguments.preferenceAllowed) OR preferences EQ "all") />
</cffunction>

<cfoutput>
<nav class="navbar navbar-dark navbar-theme-primary px-4 col-12 d-lg-none">
	<a class="navbar-brand me-lg-5" href="index.cfm">
		<img class="navbar-brand-dark" src="assets/images/logo.svg" /> <img class="navbar-brand-light" src="assets/images/logo.svg" alt="Volt logo" />
	</a>
	<div class="d-flex align-items-center">
		<button class="navbar-toggler d-lg-none collapsed" type="button" data-bs-toggle="collapse" data-bs-target="##sidebarMenu" aria-controls="sidebarMenu" aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
	</div>
</nav>

<nav id="sidebarMenu" class="sidebar d-lg-block bg-gray-800 text-white collapse" data-simplebar>
	<div class="sidebar-inner px-4 pt-3">
		<div class="user-card d-flex d-md-none align-items-center justify-content-between justify-content-md-center pb-4">
			<div class="d-flex align-items-center">
				<div class="d-block">
					<h2 class="h5 mb-3">#request.i18n.getValue("Hi")#, #currentAuthor.name#</h2>
					<a href="index.cfm?logout=1" class="btn btn-secondary btn-sm d-inline-flex align-items-center">
						<svg class="icon icon-xxs me-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
						#request.i18n.getValue("Sign Out")#
					</a>
				</div>
			</div>
			<div class="collapse-close d-md-none">
				<a href="##sidebarMenu" data-bs-toggle="collapse"
				   data-bs-target="##sidebarMenu" aria-controls="sidebarMenu" aria-expanded="true"
				   aria-label="Toggle navigation">
					<svg class="icon icon-xs" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg>
				</a>
			</div>
		</div>

		<ul class="nav flex-column pt-3 pt-md-0">
<li class="nav-item">
		<a href="index.cfm" class="nav-link d-flex align-items-center">
          <span class="sidebar-icon">
            <img src="assets/images/logo.svg" height="20" width="20">
          </span>
			<span class="mt-1 ms-1 sidebar-text">#request.i18n.getValue("Dashboard")#</span>
		</a>
	</li>
		<cfif showMenuItem("manage_all_posts,manage_posts","")>
				<mangoAdmin:MenuEvent name="mainPostsNav" />
		</cfif>
	<cfif showMenuItem("manage_all_pages,manage_pages","")>
		<mangoAdmin:MenuEvent name="mainPagesNav" />
	</cfif>

<cfif showMenuItem("manage_files","files")>
	<li id="filesMenuItem" class="nav-item <cfif attributes.page is "Files"> active</cfif>">
	<a href="files.cfm" class="nav-link">
          <span class="sidebar-icon">
            <i class="bi bi-file-earmark-image-fill icon icon-xs"></i>
          </span>
		<span class="sidebar-text">#request.i18n.getValue("Files")#</span>
	</a>
</li>
</cfif>

<cfif showMenuItem("manage_themes,set_themes","themes")>
	<li id="themesMenuItem" class="nav-item <cfif attributes.page is "Themes"> active</cfif>">
	<a href="skins.cfm" class="nav-link">
          <span class="sidebar-icon">
            <i class="bi bi-palette-fill icon icon-xs"></i>
          </span>
		<span class="sidebar-text">#request.i18n.getValue("Design")#</span>
	</a>
</li>
</cfif>

<cfif showMenuItem("manage_plugins,set_plugins","plugins")>
	<li id="pluginsMenuItem" class="nav-item <cfif attributes.page is "Plugins"> active</cfif>">
	<a href="addons.cfm" class="nav-link">
        <span class="sidebar-icon"><i class="bi bi-plugin icon icon-xs"></i></span>
		<span class="sidebar-text">#request.i18n.getValue("Plugins")#</span>
	</a>
</li>
</cfif>

<cfif showMenuItem("manage_users","users")>
	<cfset usersTitle = request.i18n.getValue("Users")>
	<cfelseif showMenuItem("set_profile","")>
	<cfset usersTitle = request.i18n.getValue("My Profile")>
</cfif>
<cfif showMenuItem("manage_users,set_profile","users")>
	<li id="authorsMenuItem" class="nav-item <cfif attributes.page is "Users"> active</cfif>">
	<a href="author.cfm?profile=1" class="nav-link">
		<span class="sidebar-icon"><i class="bi bi-person-fill icon icon-xs"></i></span>
		<span class="sidebar-text">#usersTitle#</span>
	</a>
</li>
</cfif>

<li role="separator" class="dropdown-divider mt-4 mb-3 border-gray-700"></li>

<cfif showMenuItem("manage_settings,manage_plugin_prefs","settings")>
	<li id="settingsMenuItem" class="nav-item <cfif attributes.page is "settings"> active</cfif>">
	<a href="settings.cfm" class="nav-link">
		<span class="sidebar-icon"><i class="bi bi-gear-fill icon icon-xs"></i></span>
		<span class="sidebar-text">#request.i18n.getValue("Settings")#</span>
	</a>
</li>
</cfif>
<mangoAdmin:MenuEvent name="mainNav" />

		<li class="nav-item">
			<a href="#blog.getUrl()#" target="_blank" class="btn btn-secondary d-flex align-items-center justify-content-center btn-upgrade-pro">
          <span class="sidebar-icon d-inline-flex align-items-center justify-content-center">
            <svg class="icon icon-xs me-2" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M12.395 2.553a1 1 0 00-1.45-.385c-.345.23-.614.558-.822.88-.214.33-.403.713-.57 1.116-.334.804-.614 1.768-.84 2.734a31.365 31.365 0 00-.613 3.58 2.64 2.64 0 01-.945-1.067c-.328-.68-.398-1.534-.398-2.654A1 1 0 005.05 6.05 6.981 6.981 0 003 11a7 7 0 1011.95-4.95c-.592-.591-.98-.985-1.348-1.467-.363-.476-.724-1.063-1.207-2.03zM12.12 15.12A3 3 0 017 13s.879.5 2.5.5c0-1 .5-4 1.25-4.5.5 1 .786 1.293 1.371 1.879A2.99 2.99 0 0113 13a2.99 2.99 0 01-.879 2.121z" clip-rule="evenodd"></path></svg>
          </span>
			<span>#request.i18n.getValue("View Site")#</span>
			</a>
		</li>
		</ul>
	</div>
</nav>

</cfoutput>