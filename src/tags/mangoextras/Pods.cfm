<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.locationId" default="sidebar"><!--- when this tag is used within a pod group, this attribute will be overwritten --->
<cfparam name="attributes.count" default="-1"><!--- defaults to all --->

<cfif thisTag.executionMode EQ "start">
	
	<!--- find what the context is --->
	<cfset ancestorlist = listdeleteat(getbasetaglist(),1) />

	<!--- we need to get the context to help the plugins know where they are --->
	<cfset context = structnew() />
	<cfloop list="#ancestorlist#" index="i">
		<cfif i EQ "cf_post" OR i EQ "cf_posts" OR i EQ "cf_comment" OR i EQ "cf_category" OR i EQ "cf_page" OR  i EQ "cf_postproperty">			
			<cfset context = GetBaseTagData(i)/>
			<cfbreak> 
		</cfif>
	</cfloop>
	
	<!--- this tag should always be inside a pod group, but
	if not, just output it as is --->
	<cfif listfindnocase(ancestorlist,"cf_podgroup")>
		<cfset data = GetBaseTagData("cf_podgroup") />
		<cfset pods = data.templatePods />
		<cfset attributes.locationId = data.locationId />
		<cfset allowedPodIds = data.allowedPodIds />
		<cfset insideGroup = true />
	<cfelse>
		<cfset pods = arraynew(1) />
		<cfset insideGroup = false />
	</cfif>
	
	<cfset eventData = structnew() />
	<cfset eventData.context = context />
	<cfset eventData.request = request />
	<cfset eventData.attributes = attributes />
	<cfset eventData.locationId = attributes.locationId />
	<cfset eventData.pods = pods />
	
	<cfset pluginQueue = request.blogManager.getpluginQueue() />
	
	<cfif NOT insideGroup>
		<cfset event = pluginQueue.createEvent("initializePodGroup", eventData, "Pod") />
		<cfset event = pluginQueue.broadcastEvent(event) />
		<cfset allowedPodIds = event.allowedPodIds />
	</cfif>
	
	<cfset event = pluginQueue.createEvent("getPods", eventData, "Pod") />
	<cfset event.allowedPodIds = allowedPodIds />
	<cfset event = pluginQueue.broadcastEvent(event) />
	<cfset pods = event.getPods() />

	<cfif attributes.count EQ -1 AND isarray(pods)>
		<cfset attributes.count = arraylen(pods) />
	<cfelseif NOT isarray(pods)>
		<cfset attributes.count = 0 />
	</cfif>

	<cfset to = attributes.count />

	<cfset counter = 1 />	
	<cfif counter LTE to AND counter LTE arraylen(pods)>
		<cfset currentPod = pods[counter] />
	<cfelse>
		<cfsetting enablecfoutputonly="false"><cfexit>
	</cfif>

</cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
  <cfset counter = counter + 1>
   <cfif counter LTE to AND counter LTE arraylen(pods)>
		<cfset currentPod = pods[counter] /><cfsetting enablecfoutputonly="false"><cfexit method="loop">
   </cfif>   
</cfif>
<cfsetting enablecfoutputonly="false">
