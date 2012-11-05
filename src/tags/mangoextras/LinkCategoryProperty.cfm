<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" default="false">
<cfparam name="attributes.description" default="false">
<cfparam name="attributes.format" default="default">

<cfif thisTag.executionmode is 'start'>
<cfif attributes.format EQ "default">
	<cfif attributes.description>
		<cfset attributes.format = 'plain' />
	<cfelse>
		<cfset attributes.format = 'escapedHtml' />
	</cfif>
</cfif>

<cfset data = GetBaseTagData("cf_linkCategory")/>
<cfset currentLinkCategory = data.currentLinkCategory />
<cfset prop = "" />

<cfif attributes.name>
	<cfset prop = currentLinkCategory.getName() />
</cfif>

<cfif attributes.description>
	<cfset prop = currentLinkCategory.getDescription() />
</cfif>

<cfif attributes.format EQ "xml">
	<cfset prop = xmlformat(prop) />
<cfelseif attributes.format EQ "escapedHtml">
	<cfset prop = htmleditformat(prop)>
</cfif>
	<cfoutput>#prop#</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false">