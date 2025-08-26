<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" type="string" default="" />

<cfif thisTag.executionmode is "start">

	<cfset localData = {} />
	<cfset localData.ancestorlist = listdeleteat(getbasetaglist(),1) />
	<cfset localData.count = 0 />
	<cfset localData.internalId = attributes.id />

	<cfset settings = { 'settings' = {} } />
	<cfset counter = 1 />
	<cfset currentSetting = settings />
	<cfset localData.baseSetting = settings />

	<!--- this tag should always be inside a pod group, but if not, just output it as is --->
	<cfif listfindnocase( localData.ancestorlist,"cf_blockgroup")>
		<cfset localData.data = GetBaseTagData("cf_blockgroup") />
<!--- check whether this pod id is allowed, then let the template
pod be output or exit if not to prevent pod code to be executed --->
		<cfif localData.data.allowedBlocks NEQ "*" AND NOT listfindnocase(localData.data.allowedBlocks, attributes.id)>
			<cfsetting enablecfoutputonly="false"><cfexit>
		</cfif>
	</cfif>

<!--- find current setting based on id --->
	<cfif structKeyExists( localData.data.settings, attributes.id )>
		<cfset settings = localData.data.settings[ attributes.id ] />
		<cfif NOT isArray( settings )>
			<cfif structKeyExists( 	settings, 'mango_block_internalid' )>
				<cfset localData.internalId = settings.mango_block_internalid />
			</cfif>
			<cfset currentSetting = settings />
			<cfset localData.count = 0 />
		<cfelse>
			<cfset localData.count = arraylen( settings ) />
			<!--- mutiple instances of this template --->
			<cfset currentSetting = settings[ counter ] />
			<cfif structKeyExists( 	currentSetting, 'mango_block_internalid' )>
				<cfset localData.internalId = currentSetting.mango_block_internalid />
			</cfif>
		</cfif>
	</cfif>

</cfif>

<!--- ending tag --->
<cfif thisTag.executionmode is "end">
<!--- save the output as a pod, and remove the actual output.
if and when the Pods tag is run, this pod will appear there --->
	<cfset block = structnew() />
	<cfset block.id = attributes.id />
	<cfset block.internalId = localData.internalId />
	<cfset block.content = thisTag.GeneratedContent />
	<cfset arrayappend( localData.data.blocks, block ) />
	<cfset thisTag.GeneratedContent = '' />

	<cfset counter = counter + 1>
	<cfif counter LTE localData.count>
		<cfset currentSetting = settings[ counter ] />
		<cfif structKeyExists( currentSetting, 'mango_block_internalid' )>
			<cfset localData.internalId = currentSetting.mango_block_internalid />
		</cfif>
		<cfsetting enablecfoutputonly="false"><cfexit method="loop">
	</cfif>
	<cfsetting enablecfoutputonly="false">
</cfif>
<cfsetting enablecfoutputonly="false">