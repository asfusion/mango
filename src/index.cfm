<cfset blog = request.blogManager.getBlog() />
<cfset request.skin = blog.getSkin() />
<cfset skinSettings = blog.getSetting('skins') />
<cfif NOT structkeyexists(request,"indexTemplate")>
	<cfif structKeyExists( skinSettings, "templates" ) AND structKeyExists( skinSettings.templates, "index" )>
		<cfset request.indexTemplate = skinSettings.templates.index />
	<cfelse>
		<cfset request.indexTemplate = "index.cfm" />
	</cfif>
</cfif>
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforeIndexTemplate",request)) />
<cfcontent reset="true" /><cftry><cfinclude template="#blog.getSetting('skins').path##request.skin#/#request.indexTemplate#"><cfcatch type="missinginclude"><cfinclude template="#blog.getSetting('skins').path##request.skin#/index.cfm"></cfcatch></cftry>