<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfimport prefix="partials" taglib="partials">
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
	<cfset adminSettings = request.administrator.getAdminSettings()/>
	<cfset locales = request.i18n.getLoadedBundles() />
</cfsilent>
<cf_layout page="Settings" title="#request.i18n.getValue("Settings")#">
	<cfoutput>
<cfif listfind(currentRole.permissions, "manage_settings") OR
		listfind(currentRole.permissions, "manage_plugin_prefs")>

	<nav class="nav navbar-dashboard navbar-dark flex-column flex-sm-row mb-4">
	<cfif listfind(currentRole.permissions, "manage_settings")>
		<a href="settings.cfm" class="nav-link active">#request.i18n.getValue("General")#</a>
	</cfif>
	<cfif listfind(currentRole.permissions, "manage_plugin_prefs")>
		<mangoAdmin:SecondaryMenuEvent name="settingsNav" includewrapper="false" />
	</cfif>
	</nav>

	<!-- END INNER NAV IF NEEDED -->
	<cfif listfind(currentRole.permissions, "manage_settings")>
	
	<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
	<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

<form method="post" action="#cgi.SCRIPT_NAME#" name="settingsForm" id="settingsForm">
	<div class="row">
	<div class="col-12 col-xl-9">
	<div class="card card-body border-0 shadow mb-4">
	<div class="mb-3">
		<label for="title">#request.i18n.getValue("Title")#</label>
			<input type="text" id="title" name="title" value="#htmleditformat(title)#" size="30" class="form-control  required"/>
		<div class="form-text hint">#request.i18n.getValue("title_hint")#</div>
	</div>

	<div class="mb-3">
		<label for="tagline">#request.i18n.getValue("Tagline")#</label>
			<input type="text" id="tagline" name="tagline" value="#htmleditformat(tagline)#" size="40" class="form-control"/>
		<div class="form-text hint">#request.i18n.getValue("tagline_hint")#</div>
	</div>

	<div class="mb-3">
		<label for="description">#request.i18n.getValue("Description")#</label>
	<textarea cols="60" rows="5" id="description" name="description" class="form-control">#htmleditformat(description)#</textarea>
		<div class="form-text hint">#request.i18n.getValue("description_hint")#</div>
	</div>

	<div class="mb-3">
		<label for="address">#request.i18n.getValue("Address")#</label>
			<input type="text" id="address" name="address" value="#htmleditformat(address)#" size="40" class="required url2 form-control"/>
		<div class="form-text hint">#request.i18n.getValue("address_hint")#</div>
	</div>

	<div class="mb-3">
		<label for="locale">#request.i18n.getValue("Locale")#</label>
		<select id="locale" name="locale" class="form-select">
			<cfloop array="#locales#" index="opt">
				<option value="#opt.locale#" <cfif opt.locale EQ blog.getLocale()>selected</cfif>>#opt.name#</option>
			</cfloop>
		</select>
	</div>
	</div><!--- endcard--->

	<div class="card card-body border-0 shadow mb-4 mb-xl-0">
		<h2 class="h5 mb-4">#request.i18n.getValue("Administration settings")#</h2>

		<cfset editorOptions = [ {'label' = request.i18n.getValue("None"), id="" }, {'label' = 'TinyMCE', id="tinymce" }, {'label' = 'CKEditor', id="ckeditor" } ]/>
		<cfset fieldsOptions = [ {'label' = request.i18n.getValue("Show"), id="1" }, {'label' = request.i18n.getValue("Hide"), id="0" } ]/>
		<partials:form_field id="editor" type="singlechoice" options="#editorOptions#"
				label="#request.i18n.getValue("HTML editor")#" value="#adminSettings.htmleditor.editor#" required="true" />
		<partials:form_field id="post_customfield" type="switch" checkValue="1"
				 label="#request.i18n.getValue("Show custom fields section in posts form")#" value="#adminSettings.posts.fields.customfields#" />
		<partials:form_field id="page_customfield" type="switch" checkValue="1"
									 label="#request.i18n.getValue("Show custom fields section in pages form")#" value="#adminSettings.pages.fields.customfields#" />
		<partials:form_field id="post_name" type="switch" checkValue="1"
							 label="#request.i18n.getValue("Show URL safe name in post form")#" value="#adminSettings.posts.fields.name#" />
		<partials:form_field id="page_name" type="switch" checkValue="1"
							 label="#request.i18n.getValue("Show URL safe name in page form")#" value="#adminSettings.pages.fields.name#" />
	</div><!--- end admin card --->


	</div><!--- end col --->
	</div><!--- end row --->

	<div class="mt-3 align-content-end"><button class="btn btn-primary mt-2 mb-5 animate-up-2" type="submit">#request.i18n.getValue("Save")#</button></div>
	<input type="hidden" id="submit" name="submit" value="Save"/>

	</form>

	
	<cfelse><!--- not authorized --->
		<div class="alert alert-info" role="alert">#request.i18n.getValue("Choose an item from the menu above")#</div>
	</cfif>

<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert">#request.i18n.getValue("settings-permission-error")#</div>
</cfif>
</cfoutput>
</cf_layout>
