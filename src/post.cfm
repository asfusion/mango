<cfif NOT structkeyexists(request,"postTemplate")>
	<cfset request.postTemplate = "post.cfm" />
</cfif>
<!--- for individual posts, we only need id/name --->
<cfif structkeyexists(request.externalData,"entry")>
	<!--- query string vars have priority --->
	<cfset request.externalData.postName = request.externalData.entry />
<cfelseif arraylen(request.externalData.raw)>
	<!--- put variables into the request scope --->
	<cfset request.externalData.postName = request.externalData.raw[1] />
<cfelse>
		<!--- unknown post --->
		<cfset request.externalData.postName =  "" />
</cfif>
<cfset blog = request.blogManager.getBlog() />
<cfset request.skin = blog.getSkin() />
<!--- bradcast post event --->
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforePostTemplate",request)) />
<cfcontent reset="true" /><cfinclude template="#blog.getSetting('skins').path##request.skin#/#request.postTemplate#">