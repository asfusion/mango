<cfparam name="url.code" default="" />
<cfparam name="request.email" default="" />
<cfparam name="request.errormsg" default="" type="string" />
<cfparam name="request.resultMessage" default="" type="string" />
<cfset blog = request.blogManager.getBlog() />

<cfif structkeyexists( form, "code" ) AND structKeyExists( form, "submit" )>
	<cfset authorizer = request.blogManager.getAuthorizer() />
	<cfset codecheck = authorizer.validatePasswordCode( form.code )/>
	<cfif NOT codecheck.status>
		<cfif codecheck.code EQ "EXPIRED">
			<cfset request.errormsg = 'Reset code has expired, please send a new one.' />
			<cfelseif codecheck.code EQ "INVALID">
			<cfset request.errormsg = 'Reset code is not valid' />
		</cfif>
	<cfelse>
		<cfset result = authorizer.resetPassword( form.code, form.password )/>
		<cfif result.status>
			<cflocation addtoken="false" url="#blog.getSetting('urls').admin#" />
		</cfif>
	</cfif>

<cfelseif structkeyexists( url, "code" )>
	<cfset codecheck = request.blogManager.getAuthorizer().validatePasswordCode( url.code )/>
	<cfif NOT codecheck.status>
		<cfif codecheck.code EQ "EXPIRED">
			<cfset request.errormsg = 'Reset code has expired, please send a new one.' />
		<cfelseif codecheck.code EQ "INVALID">
			<cfset request.errormsg = 'Reset code is not valid' />
		</cfif>
	<cfelse>
		<cfset author = request.administrator.getAuthor( codecheck.user_id ) />
		<cfset request.email = author.getEmail() />
	</cfif>
</cfif>
<cfif NOT structkeyexists(request,"adminLoginResetTemplate")>
	<cfset request.adminLoginTemplate = "templates/login_reset.cfm" />
</cfif>
<!--- first check if this page has been defined in the current skin --->
<cfset templates = request.administrator.getAdminPageTemplates()>
<cfif structkeyexists(templates,"login")>
	<cfset request.adminLoginTemplate = blog.getSetting('skins').path & blog.getSkin() & "/" & templates['login'].file />
</cfif>
<!--- bradcast post event --->
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforeAdminLoginTemplate",request)) />
<cfcontent reset="true" /><cfinclude template="#request.adminLoginTemplate#">