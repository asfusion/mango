<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="id" default="" />		
	<cfparam name="title" default="" />		
	<cfparam name="description" default="" />
	<cfparam name="error" default="" />
	<cfparam name="message" default="" />	
	<cfparam name="mode" default="new" />
		
	<cfset pagetitle = "New category" />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfset currentRole = currentAuthor.getCurrentRole(currentBlogId)/>
	<cfset preferences = currentRole.preferences.get("admin","menuItems","") />
	
	<cfif id NEQ "">
		<cfset mode = "update" />
	</cfif>
	
	<cfif structkeyexists(form,"submit")>
		<cfif mode EQ "update">
			<cfset result = request.formHandler.handleEditCategory(form) />
		<cfelse>
			<cfset result = request.formHandler.handleAddCategory(form) />
		</cfif>		
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	
	<!--- get post by id --->
	<cfif NOT len(error)>
		<cfif mode EQ "update">
		<cftry>
			<cfset category = request.administrator.getCategory(id) />
			<cfset title = category.getTitle() />
			<cfset description = category.getdescription() />
			<cfset pagetitle = 'Editing category: "#xmlformat(title)#"'>
			
			<cfcatch type="any">
				<cfset error = cfcatch.message />
			</cfcatch>
		</cftry>
	</cfif>
	</cfif>
	
</cfsilent>
<cfset breadcrumb = [ { 'link' = 'posts.cfm', 'title' = "Posts" },
{ 'title' = 'Categories' } ] />
<cf_layout page="Posts" title="Categories" hierarchy="#breadcrumb#">
<cfif listfind(currentRole.permissions, "manage_categories")>

	<cfoutput>

	<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
	<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

	<h4 class="h4">#pagetitle#</h4>

	<mangoAdmin:MenuEvent name="categoriesNav" />

	</cfoutput>
<!---
	<div id="submenucontainer">
		<ul id="submenu">
			<cfif NOT len(preferences) OR listfind(preferences,"categories_new")>
			<li><a href="category.cfm"<cfif mode EQ "new"> class="current"</cfif>>New Category</a></li>
			</cfif>	
			<li><a href="categories.cfm"<cfif mode EQ "update"> class="current"</cfif>>Edit Category</a></li>
			<mangoAdmin:MenuEvent name="categoriesNav" />
		</ul>
	</div>
	--->

		<cfoutput><form method="post" action="#cgi.SCRIPT_NAME#" name="categoryForm" id="categoryForm">

		<div class="row">
		<div class="col-12 ">
		<div class="card card-body border-0 shadow mb-4">
			<div class="mb-3">
			<div>
				<label for="title">#request.i18n.getValue("Title")#</label>
				<input class="form-control" id="title" type="text" name="title" value="#htmleditformat(title)#" placeholder="Enter post title" required>
			</div>
			</div>

			<div class="mb-3">
				<label for="description">#request.i18n.getValue("Description")#</label>
				<textarea class="form-control" id="description" name="description" rows="4">#htmleditformat(description)#</textarea>

			<div class="form-text hint">What this category is about. Whether or not this is shown in the blog depends on the skin used</div>
			</div>

			<div class="mt-3"><button class="btn btn-gray-800 mt-2 animate-up-2" type="submit">Save</button></div>

				<input type="hidden" name="submit" value="Save">
				<input type="hidden" name="id" value="#htmleditformat(id)#">
		</div>
		</div>
		</div>
			</form>
		</cfoutput>

<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert">Your role does not allow you to edit categories</div>
</cfif>
</cf_layout>