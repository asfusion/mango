<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	<cfparam name="mode" default="new">
	<cfparam name="id" default="">
	<cfparam name="name" default="">
	<cfparam name="description" default="">
	<cfparam name="permissionsList" default="">
	<cfparam name="formtitle" default="#request.i18n.getValue("New Role")#">
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
<cf_layout page="Users" title="#request.i18n.getValue("Roles")#">
<cfif listfind(currentRole.permissions, "manage_users")>
	<cfoutput>
		<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
		<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

		<nav class="nav navbar-dashboard navbar-dark flex-column flex-sm-row mb-4">
				<a href="author.cfm?profile=1" class="nav-link<cfif mode EQ "profile"> active</cfif>">#request.i18n.getValue("My Profile")#</a>
		<cfif listfind(currentRole.permissions, "manage_users")>
			<cfif NOT len(preferences) OR listfind(preferences,"users_edit")>
				<a class="nav-link" href="authors.cfm">#request.i18n.getValue("Users")#</a>
			</cfif>
			<cfif NOT len(preferences) OR listfind(preferences,"roles")>
				<a class="nav-link  active" href="roles.cfm">#request.i18n.getValue("Roles")#</a>
			</cfif>
				<mangoAdmin:MenuEvent name="authorsNav" />
		</cfif>
	</nav>

	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center">
	<div class="card card-body border-0 shadow table-wrapper table-responsive">
	<table class="table table-hover">
		<thead>
		<tr>
			<th>#request.i18n.getValue("Name")#</th>
			<th>#request.i18n.getValue("Description")#</th>
			<th class="border-gray-200">#request.i18n.getValue("Actions")#</th>
		</tr>
		</thead>
	<tbody>
	<!-- Item -->
		<cfloop from="1" to="#arraylen(roles)#" index="i">
			<tr>

				<td <cfif NOT i mod 2>class="alternate"</cfif>>#xmlformat(roles[i].getName())#</td>
				<td <cfif NOT i mod 2>class="alternate"</cfif>>#xmlformat(roles[i].getDescription())#</td>
				<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="roles.cfm?id=#roles[i].getId()#" class="editButton">#request.i18n.getValue("Edit")#</a></td>
		</tr>
		</cfloop>

		</tbody>
		</table>

		</div>
		</div><!--- END TABLE --->



		<cfif mode EQ "update"><p class="buttonBar"><a href="roles.cfm" class="editButton">#request.i18n.getValue("Create New Role")#</a></p></cfif>

			<form action="roles.cfm" method="POST">
				<input type="hidden" name="id" value="#id#">


	<h2>#formtitle#</h2>
	<div class="row">
		<div class="col-6">

		<div class="card card-body border-0 shadow mb-4">

			<div class="mb-3">
				<label for="name">#request.i18n.getValue("Name")#</label>
					<input type="text" id="name" name="name" value="#htmleditformat(name)#" size="30" class="form-control required"/>
			</div>

			<div class="mb-3">
				<label for="description">#request.i18n.getValue("Description")#</label>
				<textarea id="description" name="description" rows="3" cols="60" class="form-control">#htmleditformat(description)#</textarea>
			</div>
		</div>
		</div>
	</div>
	<div class="row">
	<div class="col-6">
	<div class="card card-body border-0 shadow mb-4">

	<div class="mb-3">
		<h2 class="h5 mb-4">#request.i18n.getValue("Permissions")#</h2>
		<p class="form-text">#request.i18n.getValue("What can a user with this role do?")#</p>

		<cfloop from="1" to="#arraylen(permissions)#" index="i">
			<div class="form-check">

			<input class="form-check-input" type="checkbox" value="#permissions[i].id#" id="permissions_#permissions[i].id#"
							   name="permissions" <cfif listfind(permissionsList,permissions[i].id)>checked="checked"</cfif>/>
			<label for="permissions_#permissions[i].id#" id="permissions_#permissions[i].id#-L" class="postField">#xmlformat(permissions[i].name)#</label>
			<span class="hint">#xmlformat(permissions[i].description)#</span>
			</div>
		</cfloop>

		</div>

		</div>
		</div>

		<div class="col-6">
		<div class="card card-body border-0 shadow mb-4">
			<h2 class="h5 mb-4">#request.i18n.getValue("Preferences")#</h2>
			<p class="form-text">#request.i18n.getValue("Menu items to show in admin:")#</p>
			<p class="hint">#request.i18n.getValue("Removing a menu item only hides it from the menu but it does not revoke permissions")#</p>
						
			<cfset options =
					"posts," & request.i18n.getValue("Posts") & "," &
					"posts_new," & request.i18n.getValue("Posts Submenu: New Post") & "," &
					"pages," & request.i18n.getValue("Pages") & "," &
					"pages_new," & request.i18n.getValue("Pages Submenu: New Page") & "," &
					"links," & request.i18n.getValue("Links") & "," &
					"categories," & request.i18n.getValue("Categories") & "," &
					"categories_new," & request.i18n.getValue("Categories Submenu: New Category") & "," &
					"files," & request.i18n.getValue("Files") & "," &
					"themes," & request.i18n.getValue("Themes") & "," &
					"plugins," & request.i18n.getValue("Plugins") & "," &
					"users," & request.i18n.getValue("Users/My Profile") & "," &
					"users_new," & request.i18n.getValue("Users Submenu: New User") & "," &
					"users_edit," & request.i18n.getValue("Users Submenu: Edit User") & "," &
					"roles," & request.i18n.getValue("Users Submenu: Roles") & "," &
					"settings," & request.i18n.getValue("Settings") />
				<cfloop from="1" to="#listlen(options)#" step="2" index="i">
					<div class="form-check">
					<input class="form-check-input" type="checkbox" value="#ListGetAt(options,i)#" id="menuItems_#ListGetAt(options,i)#"
						name="menuItems" <cfif listfind(showMenuList,ListGetAt(options,i)) OR showMenuList EQ "all">checked="checked"</cfif>/>
					<label for="menuItems_#ListGetAt(options,i)#">#ListGetAt(options,i+1)#</label>
				</div>
				</cfloop>
			</form>
		</div>
			<div class="mt-3 align-content-end"><button class="btn btn-gray-800 mt-2 animate-up-2" type="submit">#request.i18n.getValue("Save")#</button></div>
			<input type="hidden" name="submit" value="Submit">
		</cfoutput>
		</div>
	</div>
<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert">#request.i18n.getValue("Your role does not allow editing roles")#</div>
</cfif>
</cf_layout>