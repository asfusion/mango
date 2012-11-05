<cfoutput>
	<h3>Category: #category.getName()# [<a href="#cgi.script_name#?event=links-editLinkCategorySettings&amp;owner=Links&categoryid=#category.getId()#">Edit</a>] [<a href="#cgi.script_name#?event=links-deleteLinkCategory&amp;owner=Links&categoryid=#category.getId()#&amp;selected=links-showLinksSettings" class="deleteButton">Delete</a>]</h3>
	<table cellspacing="0">
		<tr><th>Edit</th><th>Title</th><th>Address</th><th>Delete</th></tr>
		<cfloop from="1" to="#arraylen(links)#" index="i">
			<tr>
				<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="#cgi.script_name#?action=event&amp;event=links-editLinkSettings&amp;owner=Links&linkid=#links[i].getId()#" class="editButton">Edit</a></td>
				<td <cfif NOT i mod 2>class="alternate"</cfif>>#links[i].getTitle()#</td>
				<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="#links[i].getAddress()#">#links[i].getAddress()#</a></td>
				<td <cfif NOT i mod 2>class="alternate"</cfif>><a href="#cgi.script_name#?event=links-deleteLink&amp;owner=Links&linkid=#links[i].getId()#&amp;selected=links-showLinksSettings" class="button deleteButton">Delete</a></td>
				
			</tr>
		</cfloop>
	</table>
</cfoutput>