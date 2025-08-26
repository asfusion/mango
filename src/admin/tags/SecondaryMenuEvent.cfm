<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="">
<cfparam name="attributes.owner" default="">
<cfparam name="attributes.includewrapper" default="true">
<cfparam name="selected" default="">

<cfif thisTag.executionmode EQ "start">
<!--- all these events are type template --->
	<cfif structkeyexists(request.externalData,"selected")>
		<cfset selected = request.externalData.selected />
	</cfif>

	<cfif structkeyexists(request.externalData,"owner")>
		<cfset attributes.owner = request.externalData.owner />
	</cfif>

	<cfif NOT len( attributes.name )>
		<!--- make the name from the owner --->
		<cfset attributes.name = attributes.owner & "-secondarynav" />
	</cfif>	
	
		<!--- we need to get the context to help the plugins know where they are --->
		<cfset ancestorlist = getbasetaglist() />
		<cfset context = structnew() />
		<cfset args = structnew() />
		<cfset args.context = context />
		<cfset args.request = request />
		<cfset args.attributes = attributes />
		<cfset pluginQueue = request.blogManager.getpluginQueue() />
		<cfset event = pluginQueue.createEvent( attributes.name,args, "AdminMenu" ) />
		<cfset event = pluginQueue.broadcastEvent( event ) />
		<cfset links = event.getLinks() />
		
		<cfif arraylen( links )>
			<cfoutput><cfif attributes.includewrapper><nav class="nav navbar-dashboard navbar-dark flex-column flex-sm-row mb-4"></cfif>
			<cfloop from="1" to="#arraylen(links)#" index="i">
				<cfif structkeyexists(links[i],"address")>
					<!--- address field has prevalence --->
					<cfset address = links[i].address>
				<cfelse>
					<!--- there must be a page at least --->
					<cfif links[i].page EQ "settings">
						<cfset address = "generic_settings.cfm">
					<cfelseif links[i].page EQ "generic">
						<cfset address = "generic.cfm">
					<cfelse>
						<cfset address = "#links[i].page#.cfm">
					</cfif>

					<!--- check if it has event --->
					<cfif structkeyexists(links[i],"eventName")>
						<cfif NOT structkeyexists(links[i],"selected")>
							<cfset links[i].selected = links[i].eventName />
						</cfif>
						<cfset address = address & "?event=" & links[i].eventName />
						<cfset address = address & "&amp;owner=" & links[i].owner />
						<cfset address = address & "&amp;selected=" & links[i].selected />
					</cfif>
				</cfif>

				<cfset class = 'nav-link' />
				<cfif listfind( selected, links[i].id ) OR (structkeyexists(links[i],"eventName") AND listfind(selected,links[i].eventName))>
					<cfset class = class & ' active'>
				</cfif>

				<a href="#address#" class="#class#">
				<span class="sidebar-icon">
						<i class="bi <cfif structkeyexists(links[i],"icon")>#links[i].icon#</cfif> icon icon-xs me-1"></i>
				</span>
				<span class="sidebar-text">#links[i].title#</span>
				</a>
			</cfloop>
				<cfif attributes.includewrapper></nav></cfif>
			</cfoutput>
		</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">