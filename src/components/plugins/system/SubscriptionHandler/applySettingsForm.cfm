<cfoutput>
	
	<p>#result.message#</p>
	
<cfif arraylen(subscriptionsArray)>
<h4>You are subscribed to: </h4>
<table>
	<tr><th>Entry</th><th>Mode</th><th>Subscribed to</th><th>Edit</th></tr>
<cfloop from="1" to="#arraylen(subscriptionsArray)#" index="i">
	<tr><td><a href="#subscriptionsArray[i][1].getUrl()#">#subscriptionsArray[i][1].getTitle()#</a></td>
	<td>#subscriptionsArray[i][3]#</td>
	<td><cfif subscriptionsArray[i][2] EQ "comments">Comments<cfelse>Updates</cfif></td>
	<td><a href="?action=event&amp;event=subscriptionSettings&amp;entry=#subscriptionsArray[i][1].getId()#&amp;email=#email#&amp;type=#subscriptionsArray[i][2]#">Edit </a></td>
	</tr>
</cfloop>
</table>
</cfif>
</cfoutput>