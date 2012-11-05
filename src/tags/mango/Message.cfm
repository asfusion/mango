<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.ifMessageExists" default="false">
<cfparam name="attributes.type" default="">
<cfparam name="attributes.status" default="">
<cfparam name="attributes.text" default="false">
<cfparam name="attributes.title" default="false">
<cfparam name="attributes.data" default="false">
<cfparam name="attributes.format" default="plain">

<cfif thisTag.executionmode is 'start'>
	<cfset prop = "" />
	<cfif attributes.ifMessageExists>
		<cfif len(attributes.type) AND request.message.getType() EQ attributes.type
				AND len(attributes.status) AND request.message.getStatus() EQ attributes.status>
		<cfelse>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	<cfif attributes.text>
		<cfset prop = request.message.getText() />
	</cfif>
	<cfif attributes.title>
		<cfset prop = request.message.getTitle() />
	</cfif>
	<cfif attributes.data>
		<cfset prop = toString(request.message.getData()) />
	</cfif>

<cfif attributes.format EQ "xml">
	<cfset prop = xmlformat(prop) />
<cfelseif attributes.format EQ "escapedHtml">
	<cfset prop = htmleditformat(prop)>
</cfif>

<cfoutput>#prop#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">