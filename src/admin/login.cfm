<cfif NOT structkeyexists(request,"adminLoginTemplate")>
	<cfset request.adminLoginTemplate = "templates/login.cfm" />
</cfif>
<cfset blog = request.blogManager.getBlog() />
<!--- first check if this page has been defined in the current skin --->
<cfset templates = request.administrator.getAdminPageTemplates()>
<cfif structkeyexists(templates,"login")>
	<cfset request.adminLoginTemplate = blog.getSetting('skins').path & blog.getSkin() & "/" & templates['login'].file />
</cfif>
<!--- bradcast post event --->
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforeAdminLoginTemplate",request)) />
<cfcontent reset="true" /><cfinclude template="#request.adminLoginTemplate#">