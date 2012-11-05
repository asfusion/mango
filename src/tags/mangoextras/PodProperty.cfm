<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" default="false">
<cfparam name="attributes.title" default="false">
<cfparam name="attributes.content" default="false">
<cfparam name="attributes.ifNotHasTitle" default="false">
<cfparam name="attributes.ifHasTitle" default="false">
<cfparam name="attributes.format" default="default">
<cfparam name="attributes.currentCount" default="false">

<cfif thisTag.executionmode is 'start'>
<cfif attributes.format EQ "default">
	<cfif attributes.content>
		<cfset attributes.format = 'plain' />
	<cfelse>
		<cfset attributes.format = 'escapedHtml' />
	</cfif>
</cfif>
<cfset data = GetBaseTagData("cf_pod")/>
<cfset currentPod = data.currentPod />
<cfset currentItemCount = data.currentItemCount />
<cfset prop = "" />

<cfif attributes.ifHasTitle AND NOT len(currentPod.title)>
	<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
</cfif>

<cfif attributes.ifNotHasTitle AND len(currentPod.title)>
	<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
</cfif>

<cfif attributes.title>
	<cfset prop = currentPod.title />
</cfif>

<cfif attributes.content>
	<cfset prop = currentPod.content />
</cfif>

<cfif attributes.id>
	<cfset prop = currentPod.id />
</cfif>
<cfif attributes.currentCount>
	<cfset prop = currentItemCount />
</cfif>
	
<cfif attributes.format EQ "escapedHtml">
	<cfset prop = htmleditformat(prop) />
<cfelseif attributes.format EQ "xml">
	<cfset prop = xmlformat(prop)>
</cfif>
<cfoutput>#prop#</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false">