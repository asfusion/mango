<cfsetting enablecfoutputonly="true">

<cfif thisTag.executionmode EQ "end">
	<cfset data = GetBaseTagData("cf_translation") />
	<cfset arrayappend(data.translationValues, thisTag.GeneratedContent) />
	<cfset thisTag.GeneratedContent = '' />
</cfif>
<cfsetting enablecfoutputonly="false">