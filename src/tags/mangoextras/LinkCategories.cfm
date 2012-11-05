<cfsetting enablecfoutputonly="true">
	
<!--- starting tag --->
<cfif thisTag.executionMode EQ "start">	
	
	<cfset ancestorlist = getbasetaglist() />
	
	<cfset pluginQueue = request.blogManager.getpluginQueue() />
	<cfset event = pluginQueue.createEvent("getFavoriteLinkCategories",attributes) />
	<cfset event = pluginQueue.broadcastEvent(event) />
	<cfset linkCategories = event.getOutputData() />
	
	<cfset counter = 1 />
	<cfset total = 0 />
	<cfset to = 0 />
	
	<cfif isarray(linkCategories)>
		<cfset to = arraylen(linkCategories) />
		<cfset total = arraylen(linkCategories) />
	</cfif>
	
	<cfif counter LTE to AND counter LTE total>
		<cfset currentLinkCategory = linkCategories[counter]>
	<cfelse>
		<cfsetting enablecfoutputonly="false">
		 <cfexit>
	</cfif>

 </cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
    <cfset counter = counter + 1>
	
   <cfif counter LTE to AND counter LTE arraylen(linkCategories)>
	<cfset currentLinkCategory = linkCategories[counter]><cfsetting enablecfoutputonly="false">
      <cfexit method="loop">
   </cfif>
   
</cfif>
<cfsetting enablecfoutputonly="false">