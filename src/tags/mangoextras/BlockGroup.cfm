<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" default="" />
<cfparam name="attributes.ifCountGT" default="">
<cfparam name="attributes.ifCountLT" default="">
<cfparam name="attributes.list" default=""><!--- force showing certain blocks even if not listed in the settings --->

<cfif thisTag.executionmode is "start">
	<cfset localData = {} />
	<cfset id = attributes.id />

	<cfset pluginQueue = request.blogManager.getpluginQueue() />
	<!--- this event would allow this group to determine whether some 
	of the template pod should be shown or not, it is only a preparation step --->
	<!--- we need to get the context to help the plugins know where they are --->
	<cfset localData.ancestorlist = getbasetaglist() />
	<cfset context = structnew() />
	<cfset localData.foundContext = false />
	<cfloop list="#localData.ancestorlist#" index="i">
		<cfif i EQ "cf_post" OR i EQ "cf_page">
			<cfset context = getBaseTagData( i )/>
			<cfset localData.foundContext = true />
			<cfbreak>
		</cfif>
	</cfloop>
	<cfset blocks = arraynew() />
	<cfset orderedBlockIds = arraynew() />
	<cfset allowedBlocks = '*'/>
	<cfset settings = {} />
<!--- allow all --->
	<cfset groupsetting = '' />
	<cfset activeCount = 0 />

	<!--- get settings --->
	<cfif localData.foundContext>
		<cfset currentEntry = context.currentEntry />
		<cfif currentEntry.customFieldExists( 'blocks' )>
			<cfset groupsetting = currentEntry.getCustomField( 'blocks' ).value />
			
			<cfif isjson( groupsetting )>
				<cfset groupsetting = deserializeJSON( groupsetting )/>
			</cfif>
		</cfif>
	<cfelse>
		<cfset groupsetting = request.blogManager.getSettingsManager().get( 'blocks', id, '' ) />
	</cfif>

	<cfif isArray( groupsetting )>
		<cfset allowedBlocks = ''/>
		<cfset count = 1 />
		<cfloop array="#groupsetting#" index="item">
			<cfif isstruct( item )>
				<cfif NOT structKeyExists( item, 'active' ) OR ( structKeyExists( item, 'active' ) AND item.active ) OR listFindNoCase(attributes.list, item.id )>
					<cfif NOT structKeyExists( item, 'active' ) OR ( structKeyExists( item, 'active' ) AND item.active )>
						<cfset activeCount++>
					</cfif>
					<cfset item.values[ 'mango_block_internalid' ] = item.id & "---" & count />
					<cfset item[ 'mango_block_internalid' ] = item.id & "---" & count />
					<cfif structKeyExists( settings, item.id ) and isArray( settings[ item.id ] )><!-- already there, so transform to array
							<cfset arrayAppend( settings[ item.id ], item.values )>
						<cfelseif structKeyExists( settings, item.id )>
						<cfset settings[ item.id ] = [ settings[ item.id ], item.values ] />
					<cfelse>
						<cfset settings[ item.id ] = item.values />
					</cfif>
					<cfset allowedBlocks = listAppend( allowedBlocks, item.id )/>
					<cfset arrayAppend( orderedBlockIds, item )>
					<cfset count++ />
				</cfif>
			</cfif>

		</cfloop>
	</cfif>

	<!--- allow plugins to modify what's shown --->
	<cfset args = structnew() />
	<cfset args.context = context />
	<cfset args.id = attributes.id />
	<cfset args.blocks = blocks />
	<cfset args.request = request />
	<cfset event = pluginQueue.createEvent( "initializeBlockGroup", args, "Block" ) />
	<cfset event.attributes = attributes />
	<cfset event.settings = groupsetting />
	<cfset event.orderedBlockIds = orderedBlockIds />
	<cfset event.allowedBlocks = allowedBlocks />

	<cfset event = pluginQueue.broadcastEvent( event ) />

	<!--- receive new blocks from event --->
	<cfset allowedBlocks = event.allowedBlocks />
	<cfset orderedBlockIds = event.orderedBlockIds />
	<cfset id = attributes.id />
	<cfif len(attributes.ifCountGT)>
		<cfif NOT ( activeCount GT attributes.ifCountGT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>

	<cfif len(attributes.ifCountLT)>
		<cfif NOT ( activeCount LT attributes.ifCountLT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">