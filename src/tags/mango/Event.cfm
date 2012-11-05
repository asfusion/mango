<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="">

<cfif thisTag.executionmode EQ "start">
<!--- all these events are type template --->
	<cfif len(attributes.name)>		
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
		<cfset pluginQueue = request.blogManager.getpluginQueue() />
		<cfset event = pluginQueue.createEvent(attributes.name,args,"Template") />
		<cfset event = pluginQueue.broadcastEvent(event) />
		<cfoutput>#tostring(event.getOutputData())#</cfoutput>
	</cfif> 

</cfif>

<cfsetting enablecfoutputonly="false">