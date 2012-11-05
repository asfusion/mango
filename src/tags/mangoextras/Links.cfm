<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.category" default="">
<cfparam name="attributes.orderby" default="showOrder,title"><!--- do not put a space between column names --->
<cfparam name="attributes.count" default="-1"><!--- defaults to all --->

<cfif thisTag.executionMode EQ "start">

	<cfset pluginQueue = request.blogManager.getpluginQueue() />
	
	<!--- check that plugin is enabled first --->
	<cfif pluginQueue.pluginExists("org.mangoblog.plugins.links")>
		
		<cfset ancestorlist = listdeleteat(getbasetaglist(),1) />
		<!--- inside a category --->
		<cfif listfindnocase(ancestorlist,"cf_linkcategories")>
							
			<cfset data = GetBaseTagData("cf_linkcategories")/>
			<cfset attributes.category = data.currentLinkCategory.getId()  />
	
		</cfif>
		
		<cfif attributes.category EQ "">
			<cfset event = pluginQueue.createEvent("getFavoriteLinks",attributes) />
		<cfelse>
			<cfset event = pluginQueue.createEvent("getFavoriteLinksByCategory",attributes) />
		</cfif>
		
		<cfset event = pluginQueue.broadcastEvent(event) />
		
		<cfset favoriteLinks = event.getOutputData() />
		
		<cfif attributes.count EQ -1 AND isarray(favoriteLinks)>
			<cfset attributes.count = arraylen(favoriteLinks) />
		<cfelseif NOT isarray(favoriteLinks)>
			<cfset attributes.count = 0 />
		</cfif>
		
		<cfset to = attributes.count>
	
		<cfset counter = 1>	
		<cfif counter LTE to AND counter LTE arraylen(favoriteLinks)>
			<cfset currentFavoriteLink = favoriteLinks[counter]>
		<cfelse>
			<cfsetting enablecfoutputonly="false"><cfexit>
		</cfif>
		
	<cfelse>
		<!--- get out --->
		<cfsetting enablecfoutputonly="false"><cfexit>
	</cfif>

 </cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
  <cfset counter = counter + 1>
   <cfif counter LTE to AND counter LTE arraylen(favoriteLinks)>
	<cfset currentFavoriteLink = favoriteLinks[counter]><cfsetting enablecfoutputonly="false"><cfexit method="loop">
   </cfif>
   
</cfif>
<cfsetting enablecfoutputonly="false">
