<cfsetting enablecfoutputonly="true"><cfsilent>
<cfparam name="attributes.selfUrl" default="false">
</cfsilent><cfif thisTag.executionmode is 'start'><cfif attributes.selfUrl><cfsilent>
		<cfset address = cgi.script_name />
		<cfif len(cgi.path_info) AND cgi.path_info NEQ cgi.script_name>
			<cfset address = address & cgi.path_info />
		</cfif>
		<cfif len(cgi.query_string)>
			<cfset address = address & "?" & cgi.query_string />
		</cfif>
</cfsilent><cfoutput>#address#</cfoutput></cfif></cfif><cfsetting enablecfoutputonly="false">