<cfoutput>
	<cfif entry.recordcount>
			
	<p>You are subscribed to: #entry.title#</p>

<form method="post" action="#cgi.script_name#">
  <div class="widget">
    <span class="oneChoice">
      <input type="radio" value="unsubscribe" checked="checked" id="unsubscribe" name="subscriptionOption"/>
      <label for="unsubscribe" id="unsubscribe-L" class="postField">Unsubscribe</label>
    </span>
	<cfif variables.scheduled><!--- only show digest mode if we were able to set the scheduled task --->
    <span class="oneChoice">
		<cfif subscription.mode EQ "instant">
    	  <input type="radio" value="digest" id="digest" name="subscriptionOption"/>
	      <label for="digest" id="digest-L" class="postField">Change to digest mode</label>
	     <cfelse>
	     	 <input type="radio" value="instant" id="instant" name="subscriptionOption"/>
	      <label for="instant" id="instant-L" class="postField">Change to instant mode</label>
		</cfif>
	<cfelse>
		 <input type="hidden" value="instant" id="instant" name="subscriptionOption"/>
	</cfif>
    </span>
    <br/>
    <div class="actions">
      <input type="submit" id="subscriptionSettingsSubmitButton" name="submit" value="Submit"/>
    </div>
  </div>

	<input type="hidden" value="event" name="action" />
	<input type="hidden" value="applySubscriptionSettings" name="event" />
	<input type="hidden" name="email"  value="#email#"  />
	<input type="hidden" name="type"  value="#subscription.type#"  />
	<input type="hidden" name="entry"  value="#entryId#"  />	
</form>
<cfelse>
	<!---<p>Entry was not found</p>
 entry not found --->
</cfif>
<cfif arraylen(subscriptionsArray)>
<h4>You are <cfif entry.recordcount>also </cfif>subscribed to: </h4>
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