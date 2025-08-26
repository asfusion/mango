<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" default="false">
<cfparam name="attributes.content" default="false">
<cfparam name="attributes.currentCount" default="false">

<cfif thisTag.executionmode is 'start'>
	<cfset data = GetBaseTagData("cf_block")/>
	<cfset currentBlock = data.currentBlock />
	<cfset currentItemCount = data.currentItemCount />
	<cfset prop = "" />

	<cfif attributes.content>
		<cfset prop = currentBlock.content />
	</cfif>

	<cfif attributes.id>
		<cfset prop = currentBlock.id />
	</cfif>
	<cfif attributes.currentCount>
		<cfset prop = currentItemCount />
	</cfif>

	<cfoutput>#prop#</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false">