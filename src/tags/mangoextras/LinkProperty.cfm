<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" default="false">
<cfparam name="attributes.title" default="false">
<cfparam name="attributes.description" default="false">
<cfparam name="attributes.address" default="false">
<cfparam name="attributes.categoryId" default="false">
<cfparam name="attributes.format" default="default">

<cfif thisTag.executionmode is 'start'>
<cfif attributes.format EQ "default">
	<cfif attributes.description>
		<cfset attributes.format = 'plain' />
	<cfelse>
		<cfset attributes.format = 'escapedHtml' />
	</cfif>
</cfif>

<cfset data = GetBaseTagData("cf_link")/>
<cfset currentFavoriteLink = data.currentFavoriteLink />
<cfset prop = "" />

<cfif attributes.title>
	<cfset prop = currentFavoriteLink.getTitle() />
</cfif>

<cfif attributes.description>
	<cfset prop = currentFavoriteLink.getDescription() />
</cfif>

<cfif attributes.id>
	<cfset prop = currentFavoriteLink.getId() />
</cfif>

<cfif attributes.address>
	<cfset prop = currentFavoriteLink.getAddress() />
</cfif>

<cfif attributes.categoryId>
	<cfset prop = currentFavoriteLink.getCategoryId() />
</cfif>

<cfif attributes.format EQ "xml">
	<cfset prop = xmlformat(prop) />
<cfelseif attributes.format EQ "escapedHtml">
	<cfset prop = htmleditformat(prop)>
</cfif>
	<cfoutput>#prop#</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false">