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

	<cfset pagetitle = "New user" />
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
			<cfset password = author.getpassword() />
			<cfset email = author.getemail() />
			<cfset active = author.active />
			<cfset description = author.getdescription() />
			<cfset shortdescription = author.getshortdescription() />
			<cfset picture = author.getpicture() />			
			<cfset role = author.getCurrentRole(currentBlogId).id />
			<cfset pagetitle = 'Editing user: "#xmlformat(name)# (#xmlformat(username)#)"'>
			<cfif mode EQ "profile">
				<cfset pagetitle = 'Your User Profile'>
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
<cf_layout page="Users" title="User">

<div id="wrapper">
	<div id="submenucontainer">
		<ul id="submenu">
			<cfoutput><li><a href="author.cfm?profile=1"<cfif mode EQ "profile"> class="current"</cfif>>My Profile</a></li></cfoutput>
			<cfif listfind(currentRole.permissions, "manage_users")>			
			<cfif NOT len(preferences) OR listfind(preferences,"users_new")>
			<li><a href="author.cfm"<cfif mode EQ "new"> class="current"</cfif>>New User</a></li>
			</cfif>
			<cfif NOT len(preferences) OR listfind(preferences,"users_edit")>
			<li><a href="authors.cfm"<cfif mode EQ "update"> class="current"</cfif>>Edit User</a></li>
			</cfif>
			<cfif NOT len(preferences) OR listfind(preferences,"roles")>
			<li><a href="roles.cfm">Roles</a></li>
			</cfif>
			<mangoAdmin:MenuEvent name="authorsNav" />
			</cfif>
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle"><cfoutput>#pageTitle#</cfoutput></h2>
		
		<div id="innercontent">
		<cfif len(error)>
			<p class="error"><cfoutput>#error#</cfoutput></p>
		</cfif>
		<cfif len(message)>
			<p class="message"><cfoutput>#message#</cfoutput></p>
		</cfif>
		
		<cfoutput><form method="post" action="#cgi.SCRIPT_NAME#" id="authorForm">
		
			<fieldset>
				<legend>User</legend>
				<p>
					<label for="name">Name</label>
					<span class="hint">User's name as it will appear in posts</span>
					<span class="field"><input type="text" id="name" name="name" value="#htmleditformat(name)#" size="30" class="required"/></span>
				</p>
				
				<p>
					<label for="username">Username</label>
					<span class="hint">A unique username for authentication purposes</span>
					<span class="field"><input type="text" id="username" name="username" value="#htmleditformat(username)#" size="20" class="validate-alphanum required"/></span>
				</p>
				
				<p>
					<label for="password">Password</label>
					<span class="field"><input type="password" id="password" name="password" value="#htmleditformat(password)#" size="30" class="required"/></span>
				</p>
				
				<p>
					<label for="email">E-mail</label>
					<span class="hint">An email address that identifies the user. It is also used to email notifications, forgotten password, etc.</span>
					<span class="field"><input type="text" id="email" name="email" value="#htmleditformat(email)#" size="50" class="email required"/></span>
				</p>
				
				
				<cfif mode NEQ "profile">
				<p>
					<label for="role">Role</label>
					<span class="field"><select id="role" name="role" class="required">
						<cfloop from="1" to="#arraylen(roles)#" index="i">
						<option value="#roles[i].id#" <cfif role EQ roles[i].id>selected="selected"</cfif>>#xmlformat(roles[i].name)#</option></cfloop>
					</select></span>
				</p>
				
				<p>
					<input type="checkbox" value="1" id="active" name="active" <cfif active>checked="checked" </cfif>/>
					<label for="active">Active</label>
				</p>
				</cfif>
				
				<p>
					<label for="shortdescription">Short Description</label>
					<span class="field"><textarea cols="40" rows="4" id="shortdescription" name="shortdescription">#htmleditformat(shortdescription)#</textarea></span>
				</p>
				
				<p>
					<label for="authorDescription">Description</label>
					<span class="hint">Text to show in author's page</span>
					<span class="field"><textarea cols="60" rows="10" id="authorDescription" name="description" class="htmlEditor"  style="width: 100%">#htmleditformat(description)#</textarea></span>
				</p>
				
				<p>
					<label for="picture">Picture</label>
					<span class="hint">Author's photo or profile image</span>
					<span class="field"><input type="text" id="picture" name="picture" value="#htmleditformat(picture)#" size="50" class="assetSelector"/></span>
				</p>
			</fieldset>
			
			<p class="actions">
				<input type="hidden" name="id" value="#id#"/>
				<input type="hidden" name="profile" value="#profile#"/>
				<cfif mode EQ "profile">
				<input type="hidden" name="role" value="#role#"/>
				<input type="hidden" name="active" value="#active#"/>
				</cfif>
				<input type="submit" class="primaryAction" id="submit" name="submit" value="Save"/>
			</p>
		
		</form>
		</cfoutput>
		
		</div>
	</div>
</div>

</cf_layout>