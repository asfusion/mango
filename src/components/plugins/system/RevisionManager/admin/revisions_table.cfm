<table class="table">
	<cfoutput><tr><th></th><th>#i18.getValue("revision-Date created")#</th><th>#i18.getValue("revision-Author")#</th><th>&nbsp;</th></tr></cfoutput>
	<cfoutput query="local.revisions">
		<tr><td>#recordcount-currentrow+1#</td>
		<cfif local.revision.id NEQ id>
		<td><a href="generic.cfm?event=versioner-showRevision&amp;owner=versioner&amp;selected=versioner&amp;revision=#id#">
				#lsdatetimeformat(last_modified,'medium')#</a></td>
		<cfelse>
			<td>#lsdatetimeformat(last_modified,'medium')#</td>
		</cfif>
		<td>#author#</td>
		<td>
			<cfif local.revision.id NEQ id><a href="generic.cfm?event=versioner-restoreRevision&amp;owner=versioner&amp;selected=versioner&amp;revision=#id#"><button class="btn btn-outline-success">#i18.getValue("revision-Restore")#</button> </a>
		</cfif>
		</td>
		</tr>
	</cfoutput>
</table>