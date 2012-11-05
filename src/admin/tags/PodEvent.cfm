<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="">

<cfif thisTag.executionmode EQ "start">
<!--- all these events are type template --->
	<!--- we need to get the context to help the plugins know where they are --->
		<cfset ancestorlist = getbasetaglist() />
		<cfset context = structnew() />
		<cfset args = structnew() />
		<cfset args.context = context />
		<cfset args.request = request />
		<cfset args.attributes = attributes />
		<cfset pluginQueue = request.blogManager.getpluginQueue() />
		<cfset event = pluginQueue.createEvent(attributes.name,args,"Pod") />
		<cfset event = pluginQueue.broadcastEvent(event) />
		<cfset pods = event.getPods() />		
		
		<cfoutput><cfloop from="1" to="#arraylen(pods)#" index="i">
			<div class="pod">
				<cfif structkeyexists(pods[i],"title") AND len(pods[i].title)><div class="podtitle"><h4>#pods[i].title#</h3></div></cfif>
				<div class="podcontent">#pods[i].content#</div>
			</div>
		</cfloop></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">