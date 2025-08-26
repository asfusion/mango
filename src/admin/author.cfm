<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="id" default="" />		
	<cfparam name="name" default="" />		
	<cfparam name="username" default="" />
	<cfparam name="password" default="" />
	<cfparam name="email" default="" />
	<cfparam name="active" default="1" />
	<cfparam name="error" default="" />
	<cfparam name="message" default="" />
	<cfparam name="description" default="" />
	<cfparam name="shortdescription" default="" />
	<cfparam name="role" default="" />
	<cfparam name="mode" default="new" />
	<cfparam name="profile" default="0" />
	<cfparam name="picture" default="" />	

	<cfset pagetitle = request.i18n.getValue("New user") />
	<cfset pluginQueue = request.blogManager.getpluginQueue() />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset preferences = currentRole.preferences.get("admin","menuItems","") />
	
	<cfif profile OR NOT listfind(currentRole.permissions, "manage_users")>
		<cfset id = currentAuthor.id />
		<cfset mode = "profile" />
	<cfelseif id NEQ "">
		<cfset mode = "update" />
	</cfif>
		
	<cfif structkeyexists(form,"submit")>
		<cfif mode EQ "update">
			<cfset result = request.formHandler.handleEditAuthor(form) />
		 <cfelseif mode EQ "profile">
			<cfset result = request.formHandler.handleEditProfile(form) />
		<cfelse>
			<cfset result = request.formHandler.handleAddAuthor(form) />
		</cfif>
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	
	<!--- get post by id --->
	<cfif NOT len(error)>
	<cftry>
		<cfif mode EQ "update" OR mode EQ "profile">
			<cfset author = request.administrator.getAuthor(id) />
			<cfset name = author.getName() />
			<cfset username = author.getusername() />
			<cfset password = '' />
			<cfset email = author.getemail() />
			<cfset active = author.active />
			<cfset description = author.getdescription() />
			<cfset shortdescription = author.getshortdescription() />
			<cfset picture = author.getpicture() />			
			<cfset role = author.getCurrentRole(currentBlogId).id />
			<cfset pagetitle = 'Editing user: "#xmlformat(name)# (#xmlformat(username)#)"'>
			<cfif mode EQ "profile">
				<cfset pagetitle = request.i18n.getValue('Your User Profile')>
			</cfif>
		</cfif>		
	<cfcatch type="any">
		<cfset error = cfcatch.message />
	</cfcatch>
	</cftry> 
	</cfif>
	
	<!--- get roles --->
	<cfset roles = request.blogManager.getRolesManager().getRoles() />
	
</cfsilent>
<cf_layout page="Users" title="#request.i18n.getValue("User")#">
	<cfoutput>
	<nav class="nav navbar-dashboard navbar-dark flex-column flex-sm-row mb-4">
		<a href="author.cfm?profile=1" class="nav-link<cfif mode EQ "profile"> active</cfif>">#request.i18n.getValue("My Profile")#</a>
	<cfif listfind(currentRole.permissions, "manage_users")>
		<cfif NOT len(preferences) OR listfind(preferences,"users_edit")>
				<a class="nav-link <cfif mode EQ "update" OR mode EQ "new"> active</cfif>" href="authors.cfm">#request.i18n.getValue("Users")#</a>
		</cfif>
		<cfif NOT len(preferences) OR listfind(preferences,"roles")>
				<a class="nav-link" href="roles.cfm">#request.i18n.getValue("Roles")#</a>
		</cfif>
			<mangoAdmin:MenuEvent name="authorsNav" />
	</cfif>
	</nav>
	<h4 class="h4"><cfoutput>#pageTitle#</cfoutput></h4>

	<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
	<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

	<form method="post" action="#cgi.SCRIPT_NAME#" id="authorForm">

	<div class="row">
		<div class="col-12 col-lg-4 col-xl-4">
			<div class="card card-body border-0 shadow mb-4">

		<div class="mb-3">
			<label for="name">#request.i18n.getValue("Name")#</label>
				<input type="text" id="name" name="name" value="#htmleditformat(name)#" size="30" class="form-control required"/>
			<div class="form-text hint">#request.i18n.getValue("users-name-hint")#</div>
		</div>

		<div class="mb-3">
			<label for="email">#request.i18n.getValue("Email")#</label>
			<span class="field"><input type="text" id="email" name="email" value="#htmleditformat(email)#" class="form-control email required"/></span>
			<span class="form-text hint">#request.i18n.getValue("users-email-hint")#</span>
		</div>
			<input type="hidden" id="username" name="username" value="#htmleditformat(username)#" />
<!---
		<div class="mb-3">
			<label for="username">#request.i18n.getValue("Username")#</label>
			<input type="text" id="username" name="username" value="#htmleditformat(username)#" size="30" class="form-control required validate-alphanum"/>
			<div class="form-text hint">A unique username for authentication purposes</div>
		</div>
--->
		<div class="mb-3">
			<label for="password">#request.i18n.getValue("Password")#</label>
			<input type="password" id="password" name="password" class="form-control"/></span>
		</div>

		<cfif mode NEQ "profile">
		<div class="mb-3">
			<label for="role">#request.i18n.getValue("Role")#</label>
			<select class="form-select mb-0 required" id="role" name="role">
			<cfloop from="1" to="#arraylen(roles)#" index="i">
				<option value="#roles[i].id#" <cfif role EQ roles[i].id>selected="selected"</cfif>>#xmlformat(roles[i].name)#</option></cfloop>
			</select>
		</div>
		<div class="mb-3">
			<div class="form-check form-switch">
					<input class="form-check-input" type="checkbox" value="1" id="active" name="active" <cfif active>checked="checked"</cfif>/>
				<label class="form-check-label" for="active">#request.i18n.getValue("Active")#</label>
	</div>
	</div>
		</cfif>

		</div><!-- end card -->
		</div>
		<div class="col-12 col-lg-8 col-xl-8">
			<div class="card card-body border-0 shadow mb-4">
			<div class="mb-3">
				<label for="shortdescription">#request.i18n.getValue("Short Description")#</label>
				<textarea rows="4" id="shortdescription" name="shortdescription" class="form-control" >#htmleditformat(shortdescription)#</textarea>
			</div>

			<div class="mb-3">
				<label for="authorDescription">#request.i18n.getValue("Description")#</label>
				<span class="field"><textarea rows="10" id="authorDescription" name="description" class="htmlEditor form-control"  style="width: 100%">#htmleditformat(description)#</textarea></span>
				<span class="form-text hint">Text to show in author's page</span>
			</div>

			<div class="mb-3">
				<label for="picture">#request.i18n.getValue("Picture")#</label>
				<div class="input-group">
					<input type="text" class="form-control assetSelector" id="picture" name="picture" value="#htmleditformat(picture)#" placeholder="#request.i18n.getValue("choose file")#">
					<!---<span class="input-group-text classselector-button">
						<i class="bi bi-file-fill icon icon-xs text-gray-600"></i>
					</span>--->
				</div>
					<span class="form-text hint">#request.i18n.getValue("user-picture-hint")#</span>
			</div>

			<div class="mt-3 align-content-end"><button class="btn btn-gray-800 mt-2 animate-up-2" type="submit">Save</button></div>
			</div>
		</div>

			<input type="hidden" name="id" value="#id#"/>
			<input type="hidden" name="profile" value="#profile#"/>
		<cfif mode EQ "profile">
			<input type="hidden" name="role" value="#role#"/>
			<input type="hidden" name="active" value="#active#"/>
		</cfif>

		<input type="hidden" name="submit" value="Save">
	</div>
	</div>
		</form>
		</cfoutput>
		
</cf_layout>