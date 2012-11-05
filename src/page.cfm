<cfif NOT structkeyexists(request,"pageTemplate")>
	<cfset request.pageTemplate = "page.cfm" />
</cfif>
<!--- check for entry query string --->
<cfif structkeyexists(request.externalData,"entry")><!--- for individual pages, we only need id/name --->
	<cfset request.externalData.pageName = listlast(request.externalData.entry,"/") />
<cfelseif arraylen(request.externalData.raw)>
	<!--- put variables into the request scope --->
	<cfset request.externalData.pageName = request.externalData.raw[arraylen(request.externalData.raw)] />
<cfelse>
	<!--- unknown post --->
	<cfset request.externalData.pageName =  "" />
</cfif>
<cfset isAuthor = false />
<cfif structkeyexists(request.externalData,"preview")>
	<cfset isAuthor = request.blogManager.isCurrentUserLoggedIn() />
</cfif>
<cfif structkeyexists(request.externalData,"preview") and isValid("UUID",request.externalData.pageName)>
	<cfset template = request.blogManager.getPagesManager().getPageById(request.externalData.pageName,isAuthor,true).getTemplate() />
<cfelse>
	<cfset template = request.blogManager.getPagesManager().getPageByName(request.externalData.pageName,isAuthor,true).getTemplate() />
</cfif>
<cfif len(template)>
	<cfset request.pageTemplate = template />
</cfif>
<cfset blog = request.blogManager.getBlog() />
<cfset request.skin = blog.getSkin() />
<!--- broadcast post event --->
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforePageTemplate",request)) />

<cfcontent reset="true" /><cftry><cfinclude template="#blog.getSetting('skins').path##request.skin#/#request.pageTemplate#"><cfcatch type="missinginclude"><cfinclude template="#blog.getSetting('skins').path##request.skin#/page.cfm"></cfcatch></cftry>