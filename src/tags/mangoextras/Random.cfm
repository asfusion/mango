<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.items" default="">
<cfparam name="attributes.delimiter" default=",">

<cfif thisTag.executionmode is 'start'>
<cfoutput>#listgetat(attributes.items,randrange(1,listlen(attributes.items,attributes.delimiter)),attributes.delimiter)#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false">