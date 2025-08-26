<cfif structkeyexists(form,"submit")>
	<cfset sendResult = request.blogManager.getAuthorizer().sendReset( trim( form.email ))/>
	<cfset request.email = form.email />
	<cfif NOT sendResult.status>
		<cfset request.errormsg = sendResult.msg />
	<cfelse>
		<cfset request.resultMessage = sendResult.msg />
	</cfif>
</cfif>
<cfif NOT structkeyexists(request,"adminLoginForgotTemplate")>
	<cfset request.adminLoginForgotTemplate = "templates/login_forgot.cfm" />
</cfif>
<!--- first check if this page has been defined in the current skin --->
<cfset templates = request.administrator.getAdminPageTemplates()>
<cfif structkeyexists(templates,"login_forgot")>
	<cfset request.adminLoginForgotTemplate = blog.getSetting('skins').path & blog.getSkin() & "/" & templates['login_forgot'].file />
</cfif>
<!--- bradcast post event --->
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforeAdminLoginForgotTemplate",request)) />
<cfcontent reset="true" /><cfinclude template="#request.adminLoginForgotTemplate#">