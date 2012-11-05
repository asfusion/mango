<cfif NOT structkeyexists(request,"indexTemplate")>
	<cfset request.indexTemplate = "index.cfm" />
</cfif>
<cfset blog = request.blogManager.getBlog() />
<cfset request.skin = blog.getSkin() />
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforeIndexTemplate",request)) />
<cfcontent reset="true" /><cftry><cfinclude template="#blog.getSetting('skins').path##request.skin#/#request.indexTemplate#"><cfcatch type="missinginclude"><cfinclude template="#blog.getSetting('skins').path##request.skin#/index.cfm"></cfcatch></cftry>