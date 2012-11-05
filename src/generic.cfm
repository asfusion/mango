<cfset blog = request.blogManager.getBlog() />
<cfset request.skin = blog.getSkin() />
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforeGenericTemplate",request)) />
<cfcontent reset="true" /><cfinclude template="#blog.getSetting('skins').path##request.skin#/generic.cfm">