<cfcomponent name="Authorizer">

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
		<cfargument name="settings" required="true" type="struct">

			<cfset variables.mainApp = arguments.mainApp />
			<cfset variables.settings = arguments.settings />
			
		<cfreturn this />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="checkCredentials" access="public" output="false" returntype="boolean">	
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfreturn variables.mainApp.getAuthorsManager().checkCredentials(arguments.username, arguments.password) />
		
	</cffunction>

	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="authorize" access="public" output="false" returntype="boolean">	
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfset var isAuthor = false />
		<cfset var author = "" />
		<cfset var method = "" />
		<cfset var auth = "" />
		<cfset var credential = "" />
		
		<!--- loop over the different types of authentication techniques allowed --->
		<cfloop list="#variables.settings.methods#" index="method">

			<cfif method EQ "native">
				<cfset isAuthor = checkCredentials(arguments.username, arguments.password) />
				<cfif isAuthor>
					<cfset author = variables.mainApp.getAuthorsManager().getAuthorByUsername(arguments.username, true) />
				</cfif>
			</cfif>
			<cfif method EQ "delegated">
				<!--- this is an external cfc handling the authentication --->
				<cfset auth = createObject("component", variables.settings.settings.component) />
				<cfset auth.init(variables.mainApp,variables.settings.settings) />
				<cfset credential = variables.mainApp.getObjectFactory().createCredential() />
				<cfset credential.init(arguments.username, arguments.password) />
				<cfset credential = auth.checkCredentials(credential) />
				<cfset isAuthor = credential.isAuthorized />
				
				<cfif isAuthor>
					<!--- the delegate said it is ok to let the user in, but now we must ensure that
					this author exists in Mango --->
					<cfset author = setupNativeAuthor(credential) />
					<!--- overwrite the permissions with the credentials, unless role was supplied --->
					<cfif NOT len(credential.roleId)>
						<cfset author.getCurrentrole(variables.mainApp.getBlog().getId()).permissions = credential.permissions />
					</cfif>
				</cfif>
			</cfif>
			<cfif isAuthor>
				<cfbreak />
			</cfif>
		</cfloop>
		<cfif isAuthor>
			<cfset author.setPassword(arguments.password) />
			<cfset variables.mainApp.setCurrentUser(author) />
		</cfif>
		
		<cfreturn isAuthor />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="unauthorize" access="public" output="false" returntype="void">	
		<cfset variables.mainApp.removeCurrentUser() />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setupNativeAuthor" access="public" output="false" returntype="any">	
		<cfargument name="authorizedUser" type="any" required="true" hint="This is a model.Credential object" />
		
		<!--- try to find it by username, if they already sent this one, it will be here --->
		<cfset var author = variables.mainApp.getAuthorsManager().getAuthorByUsername(arguments.authorizedUser.username, true) />
		<cfset var role = "" />
		<cfset var roleId = "" />
		<cfset var result = '' />
		<cfset var admin = variables.mainApp.getAdministrator() />
		<cfset var password = arguments.authorizedUser.password />
		
		<cfif len(author.id)>
			<!--- it was found, just return it --->
			<cfset author = updateNativeUser(arguments.authorizedUser, author) />
			<cfreturn author />
		<cfelse>
			<!--- not found, we need to set it up --->
			<cfif NOT len(arguments.authorizedUser.name)>
				<cfset arguments.authorizedUser.name = arguments.authorizedUser.username />
			</cfif>
			<!--- if password is not provided, we'll make up one --->
			<cfif NOT len(password)>
				<cfset password = rand() />
			</cfif>
			<cfif NOT len(arguments.authorizedUser.roleId)>
				<!--- no role defined, use a general role with no permissions --->
				<cfset role = setupExternalRole() />
			<cfelse>
				<!--- make sure passed role actually exists --->
				<cftry>
					<cfset role = variables.mainApp.getRolesManager().getRoleById(arguments.authorizedUser.roleId) />
					<cfcatch type="RoleNotFound">
						<cfset role = setupExternalRole() />
						<!--- clear up the role, since it didn't work --->
						<cfset arguments.authorizedUser.roleId = '' />
					</cfcatch>
				</cftry>
			</cfif>
			<cfset result = admin.newAuthor(arguments.authorizedUser.username,
											password,
											arguments.authorizedUser.name,
											arguments.authorizedUser.email,
											"",
											"",
											"",
											role.id, 
											true) />
			<cfreturn admin.getAuthor(result.newAuthor.id) />
		</cfif>
		
		<cfreturn isAuthor />
	</cffunction>
	
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="updateNativeUser" access="private">
		<cfargument name="authorizedUser" type="any" required="true" hint="This is a model.Credential object" />
		<cfargument name="currentAuthor" type="any" required="true" hint="This is a model.Author object" />
		
		<cfset var result = '' />
		<cfset var password = arguments.authorizedUser.password />
		<cfset var roleId = arguments.authorizedUser.roleId />
		<cfset var email = arguments.authorizedUser.email />
		<cfset var name = arguments.authorizedUser.name />
		<cfset var admin = variables.mainApp.getAdministrator() />
		
		<!--- if password is not provided, we'll make up one --->
		<cfif NOT len(password)>
			<cfset password = rand() />
		</cfif>
		<!--- if no email is provided, keep the old one, if any --->
		<cfif NOT len(email)>
			<cfset email = arguments.currentAuthor.email />
		</cfif>
		<!--- if no name is provided, keep the old one, if any --->
		<cfif NOT len(name)>
			<cfset name = arguments.currentAuthor.name />
		</cfif>
		<cfif len(roleId)>
			<!--- make sure passed role actually exists --->
			<cftry>
				<cfset variables.mainApp.getRolesManager().getRoleById(arguments.authorizedUser.roleId) />
				<cfcatch type="RoleNotFound">
					<cfset roleId = "" />
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfset result = admin.editAuthor(arguments.currentAuthor.id,
											arguments.authorizedUser.username,
											password,
											name,
											email,
											arguments.currentAuthor.getDescription(),
											arguments.currentAuthor.getShortDescription(),
											arguments.currentAuthor.getPicture(),
											roleId, 
											arguments.authorizedUser.isAuthorized) />
		<cfreturn admin.getAuthor(result.author.id) />
		
	</cffunction>
	
	<!--- this function sets up --->
	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="setupExternalRole" access="private">
		<cfset var role = '' />
		<cfset var result = '' />
		<cftry>
			<cfset role = variables.mainApp.getRolesManager().getRoleByPermissions('') />
			<cfcatch type="RoleNotFound">
				<!--- no permissions assigned --->
				<cfset result = variables.mainApp.getAdministrator().newRole("External",
							"Externally Authenticated User - Permissions provided by external authentication system", '') />
				<cfif result.message.getStatus() EQ "success">
					<cfset role = result.newRole />
				</cfif>
			</cfcatch>
		</cftry>
		
		<cfreturn role />
	</cffunction>
</cfcomponent>