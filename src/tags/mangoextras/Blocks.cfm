<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" default=""><!--- when this tag is used within a block group, this attribute will be overwritten --->
<cfparam name="attributes.count" default="-1"><!--- defaults to all --->
<cfparam name="attributes.ifCountGT" default="">
<cfparam name="attributes.ifCountLT" default="">

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

	<!--- this tag should always be inside a block group, but
	if not, just output it as is --->
	<cfif listfindnocase(ancestorlist,"cf_blockgroup")>
		<cfset data = GetBaseTagData("cf_blockgroup") />
		<cfset blocks = data.blocks />
		<cfset attributes.id = data.id />
		<cfset allowedBlocks = data.allowedBlocks />
		<cfset orderedBlockIds = data.orderedBlockIds />
		<cfset insideGroup = true />
	<cfelse>
		<cfset blocks = arraynew() />
		<cfset insideGroup = false />
	</cfif>

	<cfset eventData = structnew() />
	<cfset eventData.context = context />
	<cfset eventData.request = request />
	<cfset eventData.attributes = attributes />
	<cfset eventData.id = attributes.id />
	<cfset eventData.blocks = blocks />

	<cfset pluginQueue = request.blogManager.getpluginQueue() />

	<cfif NOT insideGroup>
		<cfset event = pluginQueue.createEvent("initializeBlockGroup", eventData, "Block") />
		<cfset event = pluginQueue.broadcastEvent(event) />
		<cfset allowedBlocks = event.allowedBlocks />
	</cfif>

	<!--- order the blocks and then allow plugins to make changes --->
<cfif allowedBlocks NEQ "*">
	<cfset tempData = {} />
	<cfloop from="1" to="#arraylen( blocks )#" index="i">
		<cfset tempData[ blocks[i].id ] = blocks[ i ] />
		<cfset tempData[ blocks[i].internalId ] = blocks[ i ] />
	</cfloop>

	<cfset blocks = [] />
	<cfloop array="#orderedBlockIds#" item="thisblock">
		<cfif structkeyexists( tempData, thisblock.mango_block_internalid )>
			<cfset arrayappend( blocks, tempData[ thisblock.mango_block_internalid ]) />
		<cfelseif structkeyexists( tempData, thisblock.id )>
			<cfset arrayappend( blocks, tempData[ thisblock.id ]) />
		</cfif>
	</cfloop>
</cfif>
<cfset eventData = structnew() />
<cfset eventData.context = context />
<cfset eventData.request = request />
<cfset eventData.attributes = attributes />
<cfset eventData.id = attributes.id />
<cfset eventData.blocks = blocks />

<cfif attributes.count EQ -1 AND isarray( blocks )>
    <cfset attributes.count = arraylen( blocks ) />
<cfelseif NOT isarray( blocks )>
    <cfset attributes.count = 0 />
</cfif>
	<cfif len(attributes.ifCountGT)>
		<cfif NOT (arraylen(blocks) GT attributes.ifCountGT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>

	<cfif len(attributes.ifCountLT)>
		<cfif NOT (arraylen(blocks) LT attributes.ifCountLT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
<cfset to = attributes.count />

<cfset counter = 1 />
<cfif counter LTE to AND counter LTE arraylen( blocks )>
    <cfset currentBlock = blocks[ counter ] />
<cfelse>
    <cfsetting enablecfoutputonly="false"><cfexit>
</cfif>

</cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
<cfset counter = counter + 1>
<cfif counter LTE to AND counter LTE arraylen( blocks )>
    <cfset currentBlock = blocks[ counter ] /><cfsetting enablecfoutputonly="false"><cfexit method="loop">
</cfif>
</cfif>
<cfsetting enablecfoutputonly="false">