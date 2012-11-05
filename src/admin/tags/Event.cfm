<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="">

<cfif thisTag.executionmode EQ "start">
<!--- all these events are type template --->
	<cfif len(attributes.name)>
		<cfset args = structnew() />
		<cfset args.request = request />
		<cfset args.attributes = attributes />
		<cfset pluginQueue = request.blogManager.getpluginQueue() />
		<cfset event = pluginQueue.createEvent(attributes.name,args,"Template") />
		<cfset event = pluginQueue.broadcastEvent(event) />
		<cfoutput>#tostring(event.getOutputData())#</cfoutput>
	</cfif> 

</cfif>

<cfsetting enablecfoutputonly="false">