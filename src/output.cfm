<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforeOuputTemplate",request)) />
<cfimport prefix="mango" taglib="tags/mango">
<cfcontent reset="true" /><mango:Message text /><mango:Message data />