<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.phrase" default="">
<cfparam name="attributes.variable" default="">

<cfif thisTag.executionmode EQ "start">
	<cfset translationValues = arraynew(1) />
	
<cfelseif thisTag.executionmode EQ "end">
<cfset text = request.i18n.getValue(attributes.phrase, translationValues)/>
<cfif NOT len(attributes.variable)>
<cfoutput>#text#</cfoutput>
<cfelse><cfset caller[attributes.variable] = text />
</cfif>
</cfif>
<cfsetting enablecfoutputonly="false">
