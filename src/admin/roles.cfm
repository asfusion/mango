<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	<cfparam name="mode" default="new">
	<cfparam name="id" default="">
	<cfparam name="name" default="">
	<cfparam name="description" default="">
	<cfparam name="permissionsList" default="">
	<cfparam name="formtitle" default="New Role">
	<cfparam name="showMenuList" default="all">
	
	<cfif id NEQ "">
		<cfset mode = "update" />
	</cfif>
	
	<cfif structkeyexists(form,"submit")>
		<cfif mode EQ "update">
			<cfset result = request.formHandler.handleEditRole(form) />
			<cfif result.message.getStatus() EQ "success">
				<cfset id = result.newRole.id />
			</cfif>
		<cfelse>
			<cfset result = request.formHandler.handleAddRole(form) />
			<cfif result.message.getStatus() EQ "success">
				<cfset name = "" />
				<cfset permissionsList = "" />
				<cfset id = "" />
			</cfif>
		</cfif>
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	
	<cfset manager = request.blogManager.getRolesManager() />
	
	<cfif NOT len(error)>
		<cfif mode EQ "update">
		<cftry>
			<cfset role = manager.getRoleById(id) />
			<cfset name = role.name />
			<cfset description = role.description />
			<cfset permissionsList = role.permissions />
			<cfset showMenuList = role.preferences.get("admin","menuItems","all") />
			<cfset formtitle = 'Editing role: "#xmlformat(name)#"'>
			
			<cfcatch type="any">
				<cfset error = cfcatch.message />
			</cfcatch>
		</cftry>
	</cfif>
	</cfif>
	
	
	<!--- get roles --->
	<cfset roles = manager.getRoles() />
	<!--- get permissions --->
	<cfset permissions = manager.getPermissions() />	
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset preferences = currentRole.preferences.get("admin","menuItems","") />
	
</cfsilent>
<cf_layout page="Users" title="Roles">
<cfif listfind(currentRole.permissions, "manage_users")>
<div id="wrapper">
	<div id="submenucontainer">
		<ul id="submenu">
			<li><a href="author.cfm?profile=1">My Profile</a></li>
			<cfif NOT len(preferences) OR listfind(preferences,"users_new")>
			<li><a href="author.cfm">New User</a></li>
			</cfif>
			<cfif NOT len(preferences) OR listfind(preferences,"users_edit")>
			<li><a href="authors.cfm">Edit User</a></li>
			</cfif>
			<cfif NOT len(preferences) OR listfind(preferences,"roles")>
			<li><a href="roles.cfm" class="current">Roles</a></li>
			</cfif>			
			<mangoAdmin:MenuEvent name="authorsNav" />
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle">Roles</h2>	

		<div id="innercontent">
		<cfif len(error)>
			<p class="error"><cfoutput>#error#</cfoutput></p>
		</cfif>
		<cfif len(message)>
			<p class="message"><cfoutput>#message#</cfoutput></p>
		</cfif>
		
		<cfoutput>
			<div>
		<cfif mode EQ "update"><p class="buttonBar"><a href="roles.cfm" class="editButton">Create New Role</a></p></cfif>
		<table cellspacing="0">
			<tr><th class="buttonColumn">Edit</th><th>Name</th><th>Description</th></tr>
			<cfloop from="1" to="#arraylen(roles)#" index="i">
				<tr>
					<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="roles.cfm?id=#roles[i].getId()#" class="editButton">Edit</a></td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#xmlformat(roles[i].getName())#</td>
					<td <cfif NOT i mod 2>class="alternate"</cfif>>#xmlformat(roles[i].getDescription())#</td>
				</tr>
			</cfloop>
		</table>
		</div>
		<div>
			<form action="roles.cfm" method="POST">
				<input type="hidden" name="id" value="#id#">
				<fieldset id="roleFieldset">
		      		<legend>#formtitle#</legend>
					<p>
						<label for="name">Name</label>
						<span class="field"><input type="text" id="name" name="name" value="#htmleditformat(name)#" size="30" class="required"></span>
					</p>
					
					<p>
						<label for="description">Description</label>
						<span class="field"><textarea id="description" name="description" rows="3" cols="60">#htmleditformat(description)#</textarea></span>
					</p>
				
					<div class="column1">
						<h3>Permissions</h3>
						<h4>What can a user with this role do?</h4>
						<ol>
							<cfloop from="1" to="#arraylen(permissions)#" index="i">
							<li>
								<input type="checkbox" value="#permissions[i].id#" id="permissions_#permissions[i].id#" 
									name="permissions" <cfif listfind(permissionsList,permissions[i].id)>checked="checked"</cfif>/>
								<label for="permissions_#permissions[i].id#" id="permissions_#permissions[i].id#-L" class="postField">#xmlformat(permissions[i].name)#</label>
								<span class="hint">#xmlformat(permissions[i].description)#</span>
							</li>
							</cfloop>
						</ol>
					</div><!--- /column1 --->
					
					<div class="column2">
						<h3>Preferences</h3>
						<h4>Menu items to show in admin:</h4>
						<p class="hint">Removing a menu item only hides it from the menu but it does not revoke permissions</p>
						
						<cfset options =
								"posts,Posts," &
								"posts_new,Posts Submenu: New Post," &
								"pages,Pages," &
								"pages_new,Pages Submenu: New Page," &
								"links,Links," &
								"categories,Categories," &
								"categories_new,Categories Submenu: New Category," &
								"files,Files," &
								"themes,Themes," &
								"plugins,Plugins," &
								"users,Users/My Profile," &
								"users_new,Users Submenu: New User," &
								"users_edit,Users Submenu: Edit User," &
								"roles,Users Submenu: Roles," &
								"cache,Cache," &
								"settings,Settings" />
						<ol>
							<cfloop from="1" to="#listlen(options)#" step="2" index="i">
							<li>
								<input type="checkbox" value="#ListGetAt(options,i)#" id="menuItems_#ListGetAt(options,i)#" 
									name="menuItems" <cfif listfind(showMenuList,ListGetAt(options,i)) OR showMenuList EQ "all">checked="checked"</cfif>/>
								<label for="menuItems_#ListGetAt(options,i)#">#ListGetAt(options,i+1)#</label>
							</li>
							</cfloop>
						</ol>
					</div><!--- /column2 --->
					
				</fieldset>
				
				<div class="actions">
					<input type="submit" class="primaryAction" name="submit" id="submit" value="Submit">
				</div>
			</form>
		</div>
		</cfoutput>
		</div>
	</div>
		<cfelse>
		<div id="wrapper">
		<!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow you to manage user roles</p>
</div></div></div>
</cfif>
</div>
</cf_layout>