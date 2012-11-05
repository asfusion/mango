<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.ifExists" default="">
<cfparam name="attributes.name" default="">
<cfparam name="attributes.default" default="">

<cfif thisTag.executionmode EQ "start">
	
	<cfif len(attributes.ifExists)>
		<cfif (structkeyexists(request,"externaldata") AND NOT structkeyexists(request.externaldata,attributes.ifExists))
				OR NOT structkeyexists(request,attributes.ifExists)>
			<cfsetting enablecfoutputonly="false">
			<cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif len(attributes.name) AND structkeyexists(request,"externaldata") AND structkeyexists(request.externaldata,attributes.name)>
		<cfoutput>#request.externaldata[attributes.name].toString()#</cfoutput>
	<cfelseif len(attributes.name) AND structkeyexists(request,attributes.name)>
		<cfoutput>#request[attributes.name].toString()#</cfoutput>
	<cfelse>
		<cfoutput>#attributes.default#</cfoutput>
	</cfif>

</cfif>

<cfsetting enablecfoutputonly="false">