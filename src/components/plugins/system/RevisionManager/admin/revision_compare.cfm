<cfoutput>
<p>
	<a href="generic.cfm?event=versioner-restoreRevision&amp;owner=versioner&amp;selected=versioner&amp;revision=#local.revision.id#" class="button">Restore</a>&nbsp; 
Revision created on #lsdateformat(local.revision.last_modified,'medium')# at #lstimeformat(local.revision.last_modified,'short')#</a> by #local.revision.author#</p>	
<table>
	<tr><th>&nbsp;</th><th style="width:50%">Revision</th><th style="width:50%">Current entry</th></tr>
<tr>
<td><strong>Title</strong></td><td>#local.revision.title#</td><td>#local.entry.title#</td>
</tr>
<tr>
<td><strong>Content</strong></td><td>#htmleditformat(local.revision.content)#</td>
<td>#htmleditformat(local.entry.content)#</td>
</tr>
<tr>
<td><strong>Excerpt</strong></td><td>#htmleditformat(local.revision.excerpt)#</td>
<td>#htmleditformat(local.entry.excerpt)#</td>
</tr>
</table>
</cfoutput>
<h2>All revisions</h2>
<cfinclude template="revisions_table.cfm">
</table>