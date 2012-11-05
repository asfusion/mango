<cfif NOT structkeyexists(request,"authorTemplate")>
	<cfset request.authorTemplate = "author.cfm" />
</cfif>

<cfif structkeyexists(request.externalData,"alias")>
	<!--- query string vars have priority --->
	<cfset request.externalData.authorAlias = request.externalData.alias />
<cfelseif arraylen(request.externalData.raw)>
	<!--- put variables into the request scope --->
	<cfset request.externalData.authorAlias = request.externalData.raw[1] />
<cfelse>
		<!--- unknown post --->
		<cfset request.externalData.authorAlias =  "" />
</cfif>
<cfset blog = request.blogManager.getBlog() />
<cfset request.skin = blog.getSkin() />
<!--- bradcast post event --->
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforeAuthorTemplate",request)) />
<cfcontent reset="true" /><cfinclude template="#blog.getSetting('skins').path##request.skin#/#request.authorTemplate#">