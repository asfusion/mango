<cfcomponent name="Authorizer">

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainApp" required="true" type="any">
		<cfargument name="settings" required="true" type="struct">

			<cfset variables.mainApp = arguments.mainApp />
			<cfset variables.settings = arguments.settings />
			<cfset var factory = arguments.mainApp.getDataAccessFactory() />
			<cfset variables.authorDaoObject = factory.getAuthorManager()>
			<cfset variables.authorGateway = factory.getAuthorsGateway() />
			
		<cfreturn this />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="checkCredentials" access="public" output="false" returntype="boolean">	
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		
		<cfreturn variables.mainApp.getAuthorsManager().checkCredentials(arguments.username, arguments.password) />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="checkToken" access="public" output="false">
		<cfif structKeyExists( cookie, 'token') AND NOT variables.mainApp.isCurrentUserLoggedIn()>
			<cfset var tokenQuery = variables.authorDaoObject.getByToken( cookie.token ) />
			<cfif ( tokenQuery.recordcount GT 0 )>
				<cfset var author = variables.mainApp.getAuthorsManager().getAuthorById( tokenQuery.user_id ) />
				<cfif len( author.id ) AND author.active>
					<cfset variables.mainApp.setCurrentUser( author ) />
				<cfelse>
					<cfset structDelete( cookie, 'token' )/>
				</cfif>
			</cfif>
		</cfif>
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="authorize" access="public" output="false" returntype="boolean">	
		<cfargument name="username" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		<cfargument name="remember" default="0" required="false" />
		
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
					<cfif NOT len( author.getId() )>
						<cfset author = variables.mainApp.getAuthorsManager().getAuthorByEmail(arguments.username, true) />
					</cfif>
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
			<cfset var token = createUUID() />
			<cfset author.setPassword(arguments.password) />
			<cfset variables.mainApp.setCurrentUser(author) />
			<cfif arguments.remember EQ 1>
				<cfcookie name="token" value="#token#" expires="365" />
			<cfelse>
				<cfcookie name="token" value="#token#"/>
			</cfif>
			<cfset variables.authorDaoObject.addToken( author.getId(), token, 'AUTHOR' ) />
		</cfif>
		
		<cfreturn isAuthor />
	</cffunction>
	
<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="unauthorize" access="public" output="false" returntype="void">	
		<cfset variables.mainApp.removeCurrentUser() />
		<cfset structDelete( cookie, 'token' )/>
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

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
	<cffunction name="sendReset" access="public" output="false">
		<cfargument name="email" type="string" required="true" />

		<cfset var author = variables.authorGateway.getByEmail( arguments.email, true ) />
		<cfif author.recordcount GT 0>
			<cfset var mailer = variables.mainApp.getMailer() />
			<cfset var title = "Reset your password" />
			<cfset var code = replaceNoCase( createUUID( ), "-", "", "all" ) />
			<cfset var blog = variables.mainApp.getBlog() />
			<cfset var address = blog.getUrl() & "/admin/login_reset.cfm" />
			<cfset var result = variables.authorDaoObject.savePasswordCode( author.id, code ) />
			<cfif NOT result.status>
				<cfreturn result />
			</cfif>

			<cfset var content = "<p>Hi " & author.name & ",<br>Here is the link you requested to reset your password:</p>" &
			'<p><a href="#address#?code=#code#">#address#/?code=#code#</a></p>' &
			'<p>Your <strong>username</strong> is: #email#</p>' />

			<cfsavecontent variable="local.emailContent">
				<html>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

				<body style="margin: 0;padding: 0;width: 100%;">
				<table width="100%" border="0" cellspacing="0" cellpadding="10" id="backgroundTable" style="margin: 0;padding: 0;width: 100%;background: #eaeaea">
				<tr>
				<td align="center" valign="top">
				<table width="610" border="0" cellspacing="0" cellpadding="0">
				<tr>
				<td width="610" height="70" style="color: #FFFFFF; border: none; border-bottom: 6px solid #E96732;font-size: 18px;outline: none;text-decoration: none;text-transform: capitalize;background: #363F44; padding: 20px;">
				<cfoutput>#title#</cfoutput></td>
			</tr>
			<tr>
			<td bgcolor="#FFFFFF">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" style="font-family: 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif; font-size: 14px; background: #fff; margin: 0; padding: 0;">
			<tr>
			<td valign="top" class="bodyContent" style="font: 14px sans-serif;color: #666;">
			<table width="100%" border="0" cellspacing="0" cellpadding="10">
			<tr>
			<td><table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
			<td class="text" style="padding: 20px;color: #666;font: 14px/22px sans-serif;">
				<cfoutput>#content#</cfoutput>
				</td>
				</tr>
				</table>
				</td>
				</tr>
				</table></td>
				</tr>
				</table></td>
				</tr>
					<tr>
						<td class="footer"><p style="padding: 10px 20px;color: #666;font: 12px/20px sans-serif;">Please do not reply to this email, this inbox is not monitored for replies.</p></td>
					</tr>
				</table></td>
				</tr>
				</table>
				</body>
				</html>
			</cfsavecontent>

			<cfset mailer.sendEmail( arguments.email, '', 'Password Reset Requested', local.emailContent, 'html' ) />
			<cfset result.msg = 'Email sent successfully' />
			<cfreturn result />
		</cfif>
		<cfset result.status = false />
		<cfset result.msg = "Email does not belong to an active user" />
		<cfreturn result />
	</cffunction>

	<cfscript>
// _______________________________________________________________________
		public function validatePasswordCode( required code ){

			var codeQuery = variables.authorDaoObject.getPasswordCode( arguments.code );

			if ( codeQuery.recordcount ){
				if ( codeQuery.valid ){
					return { "status" = true, "user_id" = codeQuery.user_id };
				}
				else {
					return {"status" = false, "code" = "EXPIRED" };
				}
			}
			else {
				return { "status" = false, "code" = "INVALID" };
			}
		}

// _______________________________________________________________________
		public function resetPassword( required code, password )
		{

			var result = validatePasswordCode( arguments.code );

			if (result.status) {

				variables.mainApp.getAuthorsManager().updatePassword( result.user_id, password );
				variables.authorDaoObject.usePasswordCode( arguments.code );

				var author = variables.mainApp.getAuthorsManager().getAuthorById( result.user_id );
				if (len(author.id) AND author.active) {
					variables.mainApp.setCurrentUser(author);
					result.msg = 'Password updated';
				}
				return result;
			}
		}

	</cfscript>
</cfcomponent>