<cfparam name="attributes.page" default="">
<cfimport prefix="mangoAdmin" taglib="tags">
<cfset page = attributes.page>
<cfset currentAuthor = request.blogManager.getCurrentUser() />
<cfset currentBlogId = request.blogManager.getBlog().getId() />
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

<div id="menucontainer">
<ul title="Main navigation menu" id="adminmenu">
	
	<li id="overviewMenuItem"<cfif attributes.page is "overview"> class="current"</cfif>><a href="index.cfm">Overview</a></li>
	
	<cfif showMenuItem("manage_all_posts,manage_posts","posts")>
	<li id="postsMenuItem"<cfif attributes.page is "posts"> class="current"</cfif>><a href="posts.cfm">Posts</a></li>
	</cfif>
	<cfif showMenuItem("manage_all_posts,manage_posts","")>
	<mangoAdmin:MenuEvent name="mainPostsNav" />
	</cfif>
	
	<cfif showMenuItem("manage_all_pages,manage_pages","pages")>
	<li id="pagesMenuItem"<cfif attributes.page is "pages"> class="current"</cfif>><a href="pages.cfm">Pages</a></li>
	</cfif>
	<cfif showMenuItem("manage_all_pages,manage_pages","")>
	<mangoAdmin:MenuEvent name="mainPagesNav" />
	</cfif>
	
	<cfif showMenuItem("manage_links","links")>
	<li id="linksMenuItem"<cfif attributes.page is "links"> class="current"</cfif>><a href="generic.cfm?event=links-showLinksSettings&amp;selected=links-showLinksSettings&amp;owner=Links">Links</a></li>
	</cfif>
	
	<cfif showMenuItem("manage_categories","categories")>
	<li id="categoriesMenuItem"<cfif attributes.page is "Categories"> class="current"</cfif>><a href="categories.cfm">Categories</a></li>
	</cfif>
	
	<cfif showMenuItem("manage_files","files")>
	<li id="filesMenuItem"<cfif attributes.page is "File Explorer"> class="current"</cfif>><a href="files.cfm">Files</a></li>
	</cfif>
	
	<cfif showMenuItem("manage_themes,set_themes","themes")>
	<li id="themesMenuItem"<cfif attributes.page is "Themes"> class="current"</cfif>><a href="skins.cfm">Themes</a></li>
	</cfif>
	
	<cfif showMenuItem("manage_plugins,set_plugins","plugins")>
	<li id="pluginsMenuItem"<cfif attributes.page is "Plugins"> class="current"</cfif>><a href="addons.cfm">Plugins</a></li>
	</cfif>
	
	<cfif showMenuItem("manage_users","users")>
		<cfset usersTitle = "Users">
	<cfelseif showMenuItem("set_profile","")>
		<cfset usersTitle = "My Profile">
	</cfif>
	<cfif showMenuItem("manage_users,set_profile","users")>
	<cfoutput><li id="authorsMenuItem"<cfif attributes.page is "Users"> class="current"</cfif>><a href="author.cfm?profile=1">#usersTitle#</a></li></cfoutput>
	</cfif>
	<cfif showMenuItem("manage_system","cache")>
	<li id="cacheMenuItem"<cfif attributes.page is "Cache"> class="current"</cfif>><a href="cache.cfm">Cache</a></li>
	</cfif>
	
	<cfif showMenuItem("manage_settings,manage_plugin_prefs","settings")>
	<li id="settingsMenuItem"<cfif attributes.page is "settings"> class="current"</cfif>><a href="settings.cfm">Settings</a></li>
	</cfif>

	<mangoAdmin:MenuEvent name="mainNav" />
	
	<li id="logoutMenuItem" class="last"><a href="index.cfm?logout=1">Logout</a></li>
</ul>
</div>