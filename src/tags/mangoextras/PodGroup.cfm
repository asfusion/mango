<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.locationId" default="sidebar" />

<cfif thisTag.executionmode is "start">

	<cfset pluginQueue = request.blogManager.getpluginQueue() />
	<!--- this event would allow this group to determine whether some 
	of the template pod should be shown or not, it is only a preparation step --->
	<!--- we need to get the context to help the plugins know where they are --->
	<cfset ancestorlist = getbasetaglist() />
	<cfset context = structnew() />
	<cfloop list="#ancestorlist#" index="i">
		<cfif i EQ "cf_post" OR i EQ "cf_posts" OR i EQ "cf_comment" OR i EQ "cf_category" OR i EQ "cf_page" OR  i EQ "cf_postproperty">			
			<cfset context = GetBaseTagData(i)/>
			<cfbreak> 
		</cfif>
	</cfloop>
	<cfset args = structnew() />
	<cfset args.context = context />
	<cfset args.request = request />
	<cfset args.attributes = attributes />
	<cfset args.locationId = attributes.locationId />
		
	<cfset event = pluginQueue.createEvent("initializePodGroup", args, "Pod") />
	<cfset event = pluginQueue.broadcastEvent(event) />
	<cfset allowedPodIds = event.allowedPodIds />
	<cfset templatePods = arraynew(1) />
	<cfset locationId = attributes.locationId />
</cfif>
<cfif thisTag.executionMode is "end">
	
</cfif>

<cfsetting enablecfoutputonly="false">