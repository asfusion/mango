<table>
	<tr><th></th><th>Date created</th><th>Author</th><th>&nbsp;</th></tr>
	<cfoutput query="local.revisions">
		<tr><td>#recordcount-currentrow+1#</td>
		<cfif local.revision.id NEQ id>
		<td><a href="generic.cfm?event=versioner-showRevision&amp;owner=versioner&amp;selected=versioner&amp;revision=#id#">
				#lsdateformat(last_modified,'medium')# at #lstimeformat(last_modified,'short')#</a></td>
		<cfelse>
			<td>#lsdateformat(last_modified,'medium')# at #lstimeformat(last_modified,'short')#</td>
		</cfif>
		<td>#author#</td>
		<td>
			<cfif local.revision.id NEQ id><a href="generic.cfm?event=versioner-restoreRevision&amp;owner=versioner&amp;selected=versioner&amp;revision=#id#" class="button">Restore</a>
		</cfif>
		</td>
		</tr>
	</cfoutput>
</table>