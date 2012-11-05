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
<cf_layout page="Categories" title="Categories">
<div id="wrapper">
<cfif listfind(currentRole.permissions, "manage_categories")>
	<div id="submenucontainer">
		<ul id="submenu">
			<cfif NOT len(preferences) OR listfind(preferences,"categories_new")>
			<li><a href="category.cfm"<cfif mode EQ "new"> class="current"</cfif>>New Category</a></li>
			</cfif>	
			<li><a href="categories.cfm"<cfif mode EQ "update"> class="current"</cfif>>Edit Category</a></li>
			<mangoAdmin:MenuEvent name="categoriesNav" />
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle"><cfoutput>#pagetitle#</cfoutput></h2>
		
		<div id="innercontent">
		<cfif len(error)>
			<p class="error"><cfoutput>#error#</cfoutput></p>
		</cfif>
		<cfif len(message)>
			<p class="message"><cfoutput>#message#</cfoutput></p>
		</cfif>
		
		<cfoutput><form method="post" action="#cgi.SCRIPT_NAME#" name="categoryForm" id="categoryForm">

			<fieldset>
				<legend>Category</legend>
				<p>
					<label for="title">Title</label>
					<span class="field"><input type="text" id="title" name="title" value="#htmleditformat(title)#" size="30" class="required"/></span>
				</p>
				
				<p>
					<label for="description">Description</label>
					<span class="hint">What this category is about. Whether or not this is shown in the blog depends on the skin used</span>
					<span class="field"><textarea cols="40" rows="4" id="description" name="description">#htmleditformat(description)#</textarea></span>
				</p>
			</fieldset>
			
			<div class="actions">
				<input type="submit" class="primaryAction" id="submit" name="submit" value="Save"/>
				<input type="hidden" name="id" value="#htmleditformat(id)#">
			</div>
			</form></cfoutput>
		</div>
	</div>
<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow you to edit categories</p>
</div></div>
</cfif>
</div>

</cf_layout>