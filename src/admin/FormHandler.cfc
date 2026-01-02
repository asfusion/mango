<cfcomponent name="FormHandler">

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="administrator" required="true" type="any">
		<cfargument name="user" required="true" type="any">
		
			<cfset variables.administrator = arguments.administrator>
			<cfset variables.user = arguments.user>
		
		<cfreturn this />
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleAddPost" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			<cfset var key = "" />
			<cfset var i = 0 />
			<cfset var categories = arraynew(1) />
			<cfset var listItem = "" />
			<cfset var newCategory = "" />
			
			<cfif structkeyexists(arguments.formFields,"category")>
				<cfset categories = listtoarray(arguments.formFields.category) />
			</cfif>
			
			<cfset data.title = arguments.formFields.title>
			<cfif StructKeyExists(arguments.formFields,"name")>
				<cfset data.name = arguments.formFields.name>
			</cfif>
			<cfset data.content = arguments.formFields.content>
			<cfif structkeyexists(arguments.formFields,"excerpt")>
				<cfset data.excerpt = arguments.formFields.excerpt>
			</cfif>
			
			<cfif structkeyexists(arguments.formFields,"allowComments")>
				<cfset data.allowComments = true />
			<cfelse>
				<cfset data.allowComments = false />
			</cfif>
			
			<cfif arguments.formFields.publish EQ "published">
				<cfset data.publish = true />
			<cfelse>
				<cfset data.publish = false />
			</cfif>
			
			<!--- add custom fields, make a structure --->
			<cfset data.customFields = structnew() />
			<cfif structkeyexists(arguments.formFields,"totalCustomFields")>
			<cfloop from="1" to="#arguments.formFields.totalCustomFields#" index="i">
				<cfif structkeyexists(arguments.formFields, "customField_#i#") AND
					structkeyexists(arguments.formFields, "customFieldKey_#i#")>
					<cfset key = arguments.formFields["customFieldKey_#i#"] />
					<cfset data.customFields[key] = structnew() />
					<cfset data.customFields[key].key = key />
					<cfset data.customFields[key].name = arguments.formFields["customFieldName_#i#"] />
					<cfset data.customFields[key].value = arguments.formFields["customField_#i#"] />
				</cfif>
			</cfloop>
			</cfif>
			
			<cfset data.authorId = variables.user.getId() />
			<cfset data.postedOn = arguments.formFields.postedOn />
			<cfset data.rawData = arguments.formFields />
			
			<!--- check if there was a set a new categories to add --->
				<cfif structkeyexists(arguments.formFields,"new_category") AND len(arguments.formFields.new_category)>
					<!--- there might be more than one, separated by commas --->
					<cfloop list="#arguments.formFields.new_category#" index="listItem">
						<cfset newCategory = variables.administrator.newCategory(listItem,"",variables.user) />
						<cfif newCategory.message.getStatus() EQ "success">
							<cfset arrayappend(categories, newCategory.newCategory.getId()) />
						</cfif>
					</cfloop>
				</cfif>
				
			<cfset data.categories = categories/>
			<cfset result = variables.administrator.newPost(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditPost" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			<cfset var categories = arraynew(1) />
			<cfset var i = 0 />
			<cfset var key = "" />
			<cfset var listItem = "" />
			<cfset var newCategory = "" />
			
			<cfif structkeyexists(arguments.formFields,"category")>
				<cfset categories = listtoarray(arguments.formFields.category) />
			</cfif>
			
			<cfset data.title = arguments.formFields.title>
			<cfif StructKeyExists(arguments.formFields,"name")>
				<cfset data.name = arguments.formFields.name>
			</cfif>
			<cfset data.content = arguments.formFields.content>
			<cfif structkeyexists(arguments.formFields,"excerpt")>
				<cfset data.excerpt = arguments.formFields.excerpt>
			</cfif>
			<cfset data.postId = arguments.formFields.id>
			
			<cfif structkeyexists(arguments.formFields,"allowComments")>
				<cfset data.allowComments = true />
			<cfelse>
				<cfset data.allowComments = false />
			</cfif>
			
			<cfif arguments.formFields.publish EQ "published">
				<cfset data.publish = true />
			<cfelse>
				<cfset data.publish = false />
			</cfif>
			
			<cfset data.postedOn = arguments.formFields.postedOn />
			
			<!--- add custom fields, make a structure --->
			<cfset data.customFields = structnew() />
			<cfif structkeyexists(arguments.formFields,"totalCustomFields")>
			<cfloop from="1" to="#arguments.formFields.totalCustomFields#" index="i">
				<cfif structkeyexists(arguments.formFields, "customField_#i#") AND
					structkeyexists(arguments.formFields, "customFieldKey_#i#")>
					<cfset key = arguments.formFields["customFieldKey_#i#"] />
					<cfset data.customFields[key] = structnew() />
					<cfset data.customFields[key].key = key />
					<cfset data.customFields[key].name = arguments.formFields["customFieldName_#i#"] />
					<cfset data.customFields[key].value = arguments.formFields["customField_#i#"] />
				</cfif>
			</cfloop>
			</cfif>
			
			<!--- check if there was a set a new categories to add --->
				<cfif structkeyexists(arguments.formFields,"new_category") AND len(arguments.formFields.new_category)>
					<!--- there might be more than one, separated by commas --->
					<cfloop list="#arguments.formFields.new_category#" index="listItem">
						<cfset newCategory = variables.administrator.newCategory(listItem,"",variables.user) />
						<cfif newCategory.message.getStatus() EQ "success">
							<cfset arrayappend(categories, newCategory.newCategory.getId()) />
						</cfif>
					</cfloop>
				</cfif>
			
			<cfset data.rawData = arguments.formFields />
			<cfset data.categories = categories/>
			<cfset result = variables.administrator.editPost(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleDeletePost" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var result = "" />
			<cfset result = variables.administrator.deletePost(arguments.formFields.id) />
		
		<cfreturn result/>
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleAddPage" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			<cfset var key = "" />
			<cfset var i = 0 />
			
			<cfset data.title = arguments.formFields.title>
			<cfif StructKeyExists(arguments.formFields,"name")>
				<cfset data.name = arguments.formFields.name>
			</cfif>
			<cfset data.content = arguments.formFields.content>
			<cfif structkeyexists(arguments.formFields,"excerpt")>
				<cfset data.excerpt = arguments.formFields.excerpt>
			</cfif>
			<cfset data.parentPage = arguments.formFields.parentPage>
			<cfset data.template = arguments.formFields.template>
			<cfset data.sortOrder = val(arguments.formFields.sortOrder) />
			
			<cfif structkeyexists(arguments.formFields,"allowComments")>
				<cfset data.allowComments = true />
			<cfelse>
				<cfset data.allowComments = false />
			</cfif>
			
			<cfif arguments.formFields.publish EQ "published">
				<cfset data.publish = true />
			<cfelse>
				<cfset data.publish = false />
			</cfif>
			
			<!--- add custom fields, make a structure --->
			<cfset data.customFields = structnew() />
			<cfif structkeyexists(arguments.formFields,"totalCustomFields")>
			<cfloop from="1" to="#arguments.formFields.totalCustomFields#" index="i">
				<cfif structkeyexists(arguments.formFields, "customField_#i#") AND
					structkeyexists(arguments.formFields, "customFieldKey_#i#")>
					<cfset key = arguments.formFields["customFieldKey_#i#"] />
					<cfset data.customFields[key] = structnew() />
					<cfset data.customFields[key].key = key />
					<cfset data.customFields[key].name = arguments.formFields["customFieldName_#i#"] />
					<cfset data.customFields[key].value = arguments.formFields["customField_#i#"] />
				</cfif>
			</cfloop>
			</cfif>
			
			<cfset data.authorId = variables.user.getId() />
			<cfset data.rawData = arguments.formFields />
			<cfset result = variables.administrator.newPage(argumentCollection=data) />
		<cfreturn result/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditPage" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			<cfset var key = "" />
			<cfset var i = 0 />

			<cfset data.title = arguments.formFields.title>
			<cfif StructKeyExists(arguments.formFields,"name")>
				<cfset data.name = arguments.formFields.name>
			</cfif>
			<cfset data.content = arguments.formFields.content>
			<cfif structkeyexists(arguments.formFields,"excerpt")>
				<cfset data.excerpt = arguments.formFields.excerpt>
			</cfif>
			<cfset data.parentPage = arguments.formFields.parentPage>
			<cfset data.template = arguments.formFields.template>
			<cfset data.sortOrder = val(arguments.formFields.sortOrder) />
			<cfset data.pageId = arguments.formFields.id>
			
			<cfif structkeyexists(arguments.formFields,"allowComments")>
				<cfset data.allowComments = true />
			<cfelse>
				<cfset data.allowComments = false />
			</cfif>
			
			<cfif arguments.formFields.publish EQ "published">
				<cfset data.publish = true />
			<cfelse>
				<cfset data.publish = false />
			</cfif>
			
			<!--- add custom fields, make a structure --->
			<cfset data.customFields = structnew() />
			<cfif structkeyexists(arguments.formFields,"totalCustomFields")>
			<cfloop from="1" to="#arguments.formFields.totalCustomFields#" index="i">
				<cfif structkeyexists(arguments.formFields, "customField_#i#") AND
					structkeyexists(arguments.formFields, "customFieldKey_#i#")>
					<cfset key = arguments.formFields["customFieldKey_#i#"] />
					<cfset data.customFields[key] = structnew() />
					<cfset data.customFields[key].key = key />
					<cfset data.customFields[key].name = arguments.formFields["customFieldName_#i#"] />
					<cfset data.customFields[key].value = arguments.formFields["customField_#i#"] />
				</cfif>
			</cfloop>
			</cfif>
			<cfset data.rawData = arguments.formFields />
			<cfset result = variables.administrator.editPage(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleDeletePage" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var result = "" />
			<cfset result = variables.administrator.deletePage(arguments.formFields.id) />
		
		<cfreturn result/>
	</cffunction>	
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditBlog" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			<cfset var service = "" />
			
			<cfset data.title = trim(arguments.formFields.title) />
			<cfset data.description = trim(arguments.formFields.description) />
			<cfset data.tagline = trim(arguments.formFields.tagline) />
			<cfset data.url = trim(arguments.formFields.address) />
			<cfset data.user = variables.user />
			<cfset data.locale = arguments.formFields.locale />
					
			<cfset result = variables.administrator.editBlog(argumentCollection=data) />

		<!--- now save admin settings --->
			<cfset variables.administrator.saveSetting( 'system/admin/htmleditor', 'editor', formFields.editor ) />
		<cfset variables.administrator.saveSetting( 'system/admin/posts/fields', 'customfields', structKeyExists( formFields, 'post_customfield' ) ? '1' : '0' ) />
		<cfset variables.administrator.saveSetting( 'system/admin/pages/fields', 'customfields', structKeyExists( formFields, 'page_customfield' ) ? '1' : '0' ) />
		<cfset variables.administrator.saveSetting( 'system/admin/pages/fields', 'name', structKeyExists( formFields, 'page_name' ) ? '1' : '0'  ) />
		<cfset variables.administrator.saveSetting( 'system/admin/posts/fields', 'name', structKeyExists( formFields, 'post_name' ) ? '1' : '0'  ) />

		<cfreturn result/>
	</cffunction>	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditSkin" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			<cfset var service = "" />
			
			<cfset data.action = trim(arguments.formFields.action) />
			<cfset data.skin = trim(arguments.formFields.skin) />
			<cfset data.user = variables.user />
					
			<cfset result = variables.administrator.editSkin(argumentCollection=data) />
			
		<cfreturn result/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleAddAuthor" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			
			<cfif structkeyexists(arguments.formFields,"active")>
				<cfset data.active = true />
			<cfelse>
				<cfset data.active = false />
			</cfif>
			<cfset data.name = arguments.formFields.name>
			<cfset data.username = arguments.formFields.username>
			<cfset data.password = arguments.formFields.password>
			<cfset data.email = arguments.formFields.email>
			<cfset data.description = arguments.formFields.description>
			<cfset data.shortdescription = arguments.formFields.shortdescription />
			<cfset data.role = arguments.formFields.role />
			<cfset data.picture = arguments.formFields.picture />
			
			<cfset result = variables.administrator.newAuthor(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditAuthor" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			
			<cfif structkeyexists(arguments.formFields,"active")>
				<cfset data.active = true />
			<cfelse>
				<cfset data.active = false />
			</cfif>
			<cfset data.id = arguments.formFields.id>
			<cfset data.name = arguments.formFields.name>
			<cfset data.username = arguments.formFields.username>
			<cfset data.password = arguments.formFields.password>
			<cfset data.email = arguments.formFields.email>
			<cfset data.description = arguments.formFields.description>
			<cfset data.shortdescription = arguments.formFields.shortdescription>
			<cfset data.role = arguments.formFields.role>
			<cfset data.picture = arguments.formFields.picture />
			
			<cfset result = variables.administrator.editAuthor(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditProfile" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			<cfset var author = variables.administrator.getAuthor(arguments.formFields.id) />
			
			<cfset data.id = arguments.formFields.id>
			<cfset data.name = arguments.formFields.name>
			<cfset data.username = arguments.formFields.username>
			<cfset data.password = arguments.formFields.password>
			<cfset data.email = arguments.formFields.email>
			<cfset data.description = arguments.formFields.description>
			<cfset data.shortdescription = arguments.formFields.shortdescription>
			<cfset data.picture = arguments.formFields.picture />
			<cfset result = variables.administrator.editAuthor(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>

<!--- Categories --->
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleAddCategory" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			
			<cfset data.title = arguments.formFields.title>
			<cfset data.description = arguments.formFields.description />
			
			<cfset result = variables.administrator.newCategory(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditCategory" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			
			<cfset data.id = arguments.formFields.id>
			<cfset data.title = arguments.formFields.title>
			<cfset data.description = arguments.formFields.description>
			
			<cfset result = variables.administrator.editCategory(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>			


<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleDeleteCategory" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfreturn variables.administrator.deleteCategory(arguments.formFields.id,variables.user) />
		
	</cffunction>	


<!--- Comments --->
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleAddComment" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />

			<cfset data.content = arguments.formFields.content />
			<cfset data.creatorName = variables.user.getName() />
			<cfset data.creatorEmail = variables.user.getEmail() />
			<cfset data.creatorUrl = arguments.formFields.creatorUrl />
			<cfset data.entryId = arguments.formFields.entry_id />
			<cfset data.user = variables.user>
			<cfset data.approved = true />

			<cfset result = variables.administrator.newComment(argumentCollection=data) />
		<cfreturn result/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditComment" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			
			<cfset data.commentId = arguments.formFields.commentId />
			<cfset data.content = arguments.formFields.content />
			<cfset data.creatorName = arguments.formFields.creatorName />
			<cfset data.creatorEmail = arguments.formFields.creatorEmail />
			<cfset data.creatorUrl = arguments.formFields.creatorUrl />
			<cfset data.user = variables.user>
			
			<cfif structkeyexists(arguments.formFields,"approved")>
				<cfset data.approved = true />
			<cfelse>
				<cfset data.approved = false />
			</cfif>

			<cfset result = variables.administrator.editComment(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleDeleteComment" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var result = "" />
			<cfset result = variables.administrator.deleteComment(arguments.formFields.id, variables.user) />
		
		<cfreturn result/>
	</cffunction>	

<!--- Comments --->
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleAddRole" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />

			<cfset data.name = arguments.formFields.name />
			<cfset data.description = arguments.formFields.description />
			<cfset data.preferences = structnew() />
			
			<cfif structkeyexists(arguments.formFields,"permissions")>
				<cfset data.permissions = arguments.formFields.permissions />
			<cfelse>
				<cfset data.permissions =  ""/>
			</cfif>
			<cfif structkeyexists(arguments.formFields,"menuItems")>
				<cfset data.preferences.menuItems = arguments.formFields.menuItems />
			<cfelse>
				<cfset data.preferences.menuItems = '' />
			</cfif>		

			<cfset result = variables.administrator.newRole(argumentCollection=data) />
		<cfreturn result/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditRole" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var data = structnew() />
			<cfset var result = "" />
			
			<cfset data.id = arguments.formFields.id />
			<cfset data.name = arguments.formFields.name />
			<cfset data.description = arguments.formFields.description />
			<cfif structkeyexists(arguments.formFields,"permissions")>
				<cfset data.permissions = arguments.formFields.permissions />
			<cfelse>
				<cfset data.permissions =  ""/>
			</cfif>
			<cfset data.preferences = structnew() />
			<cfif structkeyexists(arguments.formFields,"menuItems")>
				<cfset data.preferences.menuItems = arguments.formFields.menuItems />
			<cfelse>
				<cfset data.preferences.menuItems = '' />
			</cfif>
			
			<cfset result = variables.administrator.editRole(argumentCollection=data) />
		
		<cfreturn result/>
	</cffunction>
	
<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleDeleteRole" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var result = "" />
			<cfset result = variables.administrator.deleteComment(arguments.formFields.id, variables.user) />
		
		<cfreturn result/>
	</cffunction>	
	

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleActivatePlugin" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var result = structnew() />
			
			<cfif arguments.formFields.action EQ "activate">
				<cfset result = variables.administrator.activatePlugin(formfields.name, formfields.id, variables.user) />
			<cfelseif arguments.formFields.action EQ "deactivate">
				<cfset result = variables.administrator.deactivatePlugin(formfields.name, formfields.id, "user") />
			<cfelseif arguments.formFields.action EQ "remove">
				<cfset result = variables.administrator.removePlugin(formfields.name, formfields.id, variables.user) />
			</cfif>
		
		<cfreturn result/>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleDownloadPlugin" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var result = structnew() />
			
			<cfset result = variables.administrator.downloadPlugin(formfields.pluginUrl, variables.user) />
		
		<cfreturn result/>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="downloadSkin" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />
			
			<cfset var result = structnew() />
			
			<cfset result = variables.administrator.downloadSkin(formfields.skin) />
		
		<cfreturn result/>
	</cffunction>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="handleEditSkinSettings" access="public" output="false" returntype="Any">
		<cfargument name="formFields" type="struct" required="false" />

		<cfset var result = {} />
		<cfset var i = "" />

		<cfloop from="1" to="#formFields.total_fields#" index="i">
			<cfif structKeyExists( formFields, 'setting_#i#_path' ) AND structKeyExists( formFields, 'setting_#i#_key' )>
				<!--- save the value --->
			<cfif structKeyExists( formFields, 'setting_#i#_value' ) AND len( formFields[ 'setting_#i#_value' ])>
				<cfset result = variables.administrator.saveSetting( formFields[ 'setting_#i#_path' ],  formFields[ 'setting_#i#_key' ],  formFields[ 'setting_#i#_value' ] ) />
			<cfelseif NOT structKeyExists( formFields, 'setting_#i#_value' ) AND
					formFields[ 'setting_#i#_type' ] EQ "switch">
				<cfset result = variables.administrator.saveSetting( formFields[ 'setting_#i#_path' ],  formFields[ 'setting_#i#_key' ], 0 ) />
			<cfelse>
				<cfset result = variables.administrator.removeSetting( formFields[ 'setting_#i#_path' ],  formFields[ 'setting_#i#_key' ] )>
			</cfif>
			</cfif>
		</cfloop>
		<cfset result.message.setStatus( "success" ) />
		<cfset result.message.setText( "Settings updated" ) />
		<cfreturn result/>
	</cffunction>

	<cfscript>
		// ---------------------------------------------------------
		function handleEditPageBlocks( formFields, delete = ''  ) {

			var pageId = arguments.formFields.id;

			data.rawData = arguments.formFields;
			var blocks = prepareBlocksForSave( formFields, delete );
			var result = variables.administrator.setPageCustomField( pageId, { 'key' = 'blocks',
				name = 'Blocks', value = serializeJSON( blocks )  } );
			result.blocks = blocks;
			return result;
		}

// ---------------------------------------------------------
		function handleEditPageBlocksParsed( pageId, blocks ) {

			return variables.administrator.setPageCustomField( pageId, { 'key' = 'blocks',
				name = 'Blocks', value = serializeJSON( blocks )  } );
		}

		// ---------------------------------------------------------
		function handleEditTemplateBlocks( formFields, delete = '' ) {

			var pageId = arguments.formFields.id;
			data.rawData = arguments.formFields;
			var result = variables.administrator.saveTemplateBlocks( pageId, prepareBlocksForSave( formFields, delete ));
			result.message.setStatus( "success" );
			result.message.setText( "Settings updated" );

			return result;
		}

		//------------------------------------------------
		private function prepareBlocksForSave( formFields, delete = '' ) {

			//add all blocks first, then populate
			var blocks = [];
			var usedBlocks = {};
			for ( var i = 1; i LTE formFields.block_count; i++ ){
				var blockId = formFields[ 'block_' & i & '_id' ];
				var activeName = 'block_' & i & '_active';
				var active = structKeyExists( formFields, activeName ) ? formFields[ activeName ] : false;//really if the form field is there it is active, but we are doing a double check
				var block = { "id": blockId, "values": {}, "active" = active, 'internalId' = i };
				if ( NOT structKeyExists( usedBlocks, blockId )){
					usedBlocks[ blockId ] = 0;
				}
				usedBlocks[ blockId ] = usedBlocks[ blockId ] + 1;
				arrayAppend( blocks, block );
			}

			var allPaths = [];
			for ( var key in formFields ){
				if ( findNoCase( '_path', key )){
					arrayAppend( allPaths, left( key, len( key ) - 5 ) );
				}
			}
			for ( var path in allPaths ){
				var levels = quotedListToArray( formFields[ path & '_path' ] );
				var baseStruct = blocks[ levels[ 1 ]];
				arrayDeleteAt( levels, 1 );
				arrayDeleteAt( levels, 1 );
				if ( NOT structKeyExists( formFields, path & '_value' )){
					formFields[ path & '_value' ] = '';
				}
				var newElement = makeElement( baseStruct.values, levels, formFields[ path & '_value' ], baseStruct.values );
			}

			var orderedBlocks = [];
			//reorder based on order field
			var newIndex = 1;
			for ( var item in formFields[ 'order' ]){
				orderedBlocks[ newIndex ] = blocks[ item ];
				newIndex++;
			}
			for ( var block in orderedBlocks ){
				var hadValues = cleanUpValues( block.values );
				if ( block.internalId EQ delete ){
					arraydelete( orderedBlocks, block );
				}
				structdelete( block, 'internalId' );
			}

			return orderedBlocks;
		}

/**
* Converts elements in a quoted list to an array.
*
* @param theList      The list to parse. (Required)
* @return Returns an array.
* @author Anthony Cooper (ant@outsrc.co.uk)
* @version 1, January 3, 2007
*/
		function quotedListToArray(theList) {
			var items = arrayNew( 1 );
			var i = 1;
			var start = 1;
			var search = structNew();
			var quoteChar = """";

			while(start LT len(theList)) {
				search = reFind('(\#quoteChar#.*?\#quoteChar#)|([0-9\.]*)', theList, start, true );

				if (arrayLen(search.LEN) gt 1) {
					items[i] = mid(theList, search.POS[1], (search.LEN[1])); //Extract string
					items[i] = reReplace(items[i], '^\#quoteChar#|\#quoteChar#$', "", "All" );     //Remove double quote character
					start = search.POS[1] + search.LEN[1] + 1;
					i = i + 1;
				}
				else {
					start = Len( theList );
				}
			}

			return items;
		}

		function makeElement( baseStruct, levels, value ){

			var level = levels[ 1 ];
			var child = {};

			var hasChildren = arraylen( levels ) GT 1;
			if ( hasChildren AND isnumeric( levels[ 2 ] )){
				child = [];
			}

			if ( hasChildren ){
				if ( NOT isnumeric( level ) AND NOT structKeyExists( baseStruct, level )){
					baseStruct[ level ] = child;
				}
				if ( isnumeric( level )){
					if ( isarray(baseStruct) AND arraylen( baseStruct) LT level OR isNull( baseStruct[ level ] ))
						baseStruct[ level ] = child;
				}
				arrayDeleteAt( levels, 1 );

				if ( arraylen( levels )){
					child = makeElement( baseStruct[ level ], levels, value );
				}
			}
			else {
				baseStruct[ level ] = value;
			}
			return baseStruct;
		}

		// ------------------------------------------------------------
		function cleanUpValues( fields ){

			var hasValues = false;
			for ( var key in fields ) {
				if ( NOT isArray( fields[ key ] ) ){
					if ( len( fields[ key ] )){
						hasValues = true;
					}
				}
				else {
					if ( arraylen( fields[ key ] ) GT 0 ){
						for ( var i = arraylen( fields[ key ] ); i GT 0; i--) {

							hasValues = cleanUpValues( fields[ key ][ i ] );
							if ( not hasValues){
								arrayDeleteAt( fields[ key ], i );
							}
						}
					}
				}
			}

			return hasValues;
		}
	</cfscript>

</cfcomponent>