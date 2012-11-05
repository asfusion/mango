<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="">
<cfparam name="attributes.owner" default="">
<cfparam name="selected" default="">

<cfif thisTag.executionmode EQ "start">
<!--- all these events are type template --->
	<cfif structkeyexists(request.externalData,"selected")>
			<cfset selected = request.externalData.selected />
		</cfif>
		
		<cfif structkeyexists(request.externalData,"owner")>
			<cfset attributes.owner = request.externalData.owner />
		</cfif>

	<cfif NOT len(attributes.name)>
		<!--- make the name from the owner --->
		<cfset attributes.name = attributes.owner & "Nav" />
	</cfif>	
	
		<!--- we need to get the context to help the plugins know where they are --->
		<cfset ancestorlist = getbasetaglist() />
		<cfset context = structnew() />
		<cfset args = structnew() />
		<cfset args.context = context />
		<cfset args.request = request />
		<cfset args.attributes = attributes />
		<cfset pluginQueue = request.blogManager.getpluginQueue() />
		<cfset event = pluginQueue.createEvent(attributes.name,args,"AdminMenu") />
		<cfset event = pluginQueue.broadcastEvent(event) />
		<cfset links = event.getLInks() />
		
		
		
		<cfoutput><cfloop from="1" to="#arraylen(links)#" index="i">
			
			<cfif structkeyexists(links[i],"address")>
				<!--- address field has prevalence --->
				<cfset address = links[i].address>
			<cfelse>
				<!--- there must be a page at least --->
				<cfif links[i].page EQ "settings">
					<cfset address = "generic_settings.cfm">
				<cfelseif links[i].page EQ "generic">
					<cfset address = "generic.cfm">
				</cfif>
				
				<!--- check if it has event --->
				<cfif structkeyexists(links[i],"eventName")>
					<cfset address = address & "?event=" & links[i].eventName />
					<cfset address = address & "&amp;owner=" & links[i].owner />
					<cfset address = address & "&amp;selected=" & links[i].eventName />
				</cfif>
			</cfif>
			
			<cfif listfind(selected,links[i].owner) OR 
					(structkeyexists(links[i],"eventName") AND listfind(selected,links[i].eventName)) OR
						links[i].owner EQ attributes.owner>
				<cfset class = ' class="current"'>
			<cfelse>
				<cfset class = '' />
			</cfif>
						
			
			<li#class#><a href="#address#"<cfif structkeyexists(links[i],"icon")> style="background-image:url(#links[i].icon#);"</cfif>#class#>#links[i].title#</a></li>	
		</cfloop></cfoutput>
	 

</cfif>

<cfsetting enablecfoutputonly="false">