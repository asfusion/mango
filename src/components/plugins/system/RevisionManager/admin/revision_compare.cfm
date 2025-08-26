<cfoutput>
<div><a href="generic.cfm?event=versioner-restoreRevision&amp;owner=versioner&amp;selected=versioner&amp;revision=#local.revision.id#"><button class="btn btn-outline-success">#variables.mainManager.getInternationalizer().getValue("revision-Restore")#</button></a>&nbsp;
	#i18.getValue("revision-created-label", [ lsdatetimeformat(local.revision.last_modified,'medium'), local.revision.author ])#

<table class="table">
	<tr><th>&nbsp;</th><th style="width:50%">Revision</th><th style="width:50%">Current entry</th></tr>
<tr>
<td><strong>#i18.getValue("Title")#</strong></td><td>#local.revision.title#</td><td>#local.entry.title#</td>
</tr>
<tr>
<td><strong>#i18.getValue("Content")#</strong></td><td>#htmleditformat(local.revision.content)#</td>
<td>#htmleditformat(local.entry.content)#</td>
</tr>
<tr>
<td><strong>#i18.getValue("Excerpt")#</strong></td><td>#htmleditformat(local.revision.excerpt)#</td>
<td>#htmleditformat(local.entry.excerpt)#</td>
</tr>
</table>
</cfoutput>
<h4>All revisions</h4>
<cfinclude template="revisions_table.cfm">
</table>