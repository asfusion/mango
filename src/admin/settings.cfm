<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	
	<cfparam name="id" default="0" />		
	<cfparam name="title" default="" />
	<cfparam name="description" default="" />
	<cfparam name="tagline" default="" />
	<cfparam name="skin" default="" />
	<cfparam name="address" default="" />
	<cfparam name="charset" default="" />
	
	<cfif structkeyexists(form,"submit")>
		<cfset result = request.formHandler.handleEditBlog(form) />
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
			<!--- todo: remove this hack --->
			<cfset application.currentSkin = request.administrator.getSkin(request.administrator.getBlog().getSkin())>
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	
	<!--- get post by id --->
	<cfif NOT len(error)>
	<cftry>
		<cfset blog = request.administrator.getBlog() />
		<cfset title = blog.getTitle() />
		<cfset description = blog.getdescription() />
		<cfset tagline = blog.gettagline() />
		<cfset address = blog.geturl() />
		
	<cfcatch type="any">
		<cfset error = cfcatch.message />
	</cfcatch>
	</cftry> 
	
	</cfif>
	
	<cfset skins = request.administrator.getSkins() />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
</cfsilent>
<cf_layout page="Settings" title="Settings">
<div id="wrapper">
<cfif listfind(currentRole.permissions, "manage_settings") OR
		listfind(currentRole.permissions, "manage_plugin_prefs")>
	<div id="submenucontainer">
		<ul id="submenu">
			<cfif listfind(currentRole.permissions, "manage_settings")>
			<li><a href="settings.cfm" class="current">General</a></li>
			</cfif>
			<cfif listfind(currentRole.permissions, "manage_plugin_prefs")>
			<mangoAdmin:MenuEvent name="settingsNav" />
			</cfif>
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle">Settings</h2>		
		<div id="innercontent">
		<cfif len(error)>
			<p class="error"><cfoutput>#error#</cfoutput></p>
		</cfif>
		<cfif len(message)>
			<p class="message"><cfoutput>#message#</cfoutput></p>
		</cfif>
		<cfif listfind(currentRole.permissions, "manage_settings")>
		<cfoutput>

<form method="post" action="#cgi.SCRIPT_NAME#" name="settingsForm" id="settingsForm">
	
	<fieldset id="settingsForm_general">
		<legend>General settings</legend>
		
		<p>
			<label for="title">Title</label>
			<span class="hint">The title of your blog. It usually appears in the blog header and in the browser window's title</span>
			<span class="field"><input type="text" id="title" name="title" value="#htmleditformat(title)#" size="30" class="required"/></span>
		</p>
		
		<p>
			<label for="tagline">Tagline</label>
			<span class="hint">A catchy tagline. Whether or not it is shown in your blog depends on the current template</span>
			<span class="field"><input type="text" id="tagline" name="tagline" value="#htmleditformat(tagline)#" size="40" class=""/></span>
		</p>
		
		<p>
			<label for="description">Description</label>
			<span class="hint">A small description of what your blog is about</span>
			<span class="field"><textarea cols="60" rows="5" id="description" name="description" class="">#htmleditformat(description)#</textarea></span>
		</p>
		
		<p>
			<label for="address">Address</label>
			<span class="hint">The address of your blog (do not change unless you are changing domain name or are moving your blog)</span>
			<span class="field"><input type="text" id="address" name="address" value="#htmleditformat(address)#" size="40" class="required url2"/></span>
		</p>
	</fieldset>
	
	<div class="actions">
		<input type="submit" class="primaryAction" id="submit" name="submit" value="Save"/>
	</div>

</form>
</cfoutput>
<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="message">Choose an item from the menu above</p>
</div></div>
</cfif>
	</div>
</div>
<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow you to edit settings</p>
</div></div>
</cfif>
</div>
</cf_layout>