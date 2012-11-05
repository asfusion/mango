<cfoutput>

<form method="post" action="#cgi.script_name#">
	<p>
		<label for="mailFrom">Send email from address:</label>
		<span class="hint">The email address that subscription emails will be sent from</span>
		<span class="field"><input type="text" id="mailFrom" name="mailFrom" value="#email#" size="50" class="required {email:true}"/></span>
	</p>

	<fieldset>
		<legend>New Comment Email</legend>
    	<p>This email is sent when a new comment is made.</p>

		<p>
			<label for="normal_subject">Subject</label>
			<span class="hint">Available variables:<br />
				{postTitle}<br />
				{blogTitle}</span>
			<span class="field"><input type="text" id="normal_subject" name="normal_subject" value="#templates["normal"]["subject"]#" size="60" class="required"/></span>
		</p>
		
		<p>
			<label for="normal_body">Email content</label>
			<span class="hint">Available variables:<br />
				{postTitle}<br />
				{postLink}<br />
				{postId}<br />
				{commentContent}<br />
				{commentCreatorEmail}<br />
				{commentCreatorName}<br />
				{commentCreatorWebsite}<br />
				{settingsLink}: link to change individual subscription settings<br />
				{commentId}<br />
				{blogUrl}</span>
			<span class="field"><textarea id="normal_body" name="normal_body" cols="100" rows="12" class="required">#templates["normal"]["body"]#</textarea></span>
		</p>
	</fieldset>

	<fieldset>
		<legend>Digest Mode Email</legend>
    	<p>This is email is sent to readers subscribed in "digest mode". It is sent every day with all the new comments made during the day to which they are subscribed.</p>

		<p>
			<label for="digest_subject">Subject</label>
			<span class="hint">Available variables:<br />
				{postTitle}<br />
				{blogTitle}</span>
			<span class="field"><input type="text" id="digest_subject" name="digest_subject" value="#templates["digest"]["subject"]#" size="60" class="required"/></span>
		</p>
		
		<p>
			<label for="digest_header">Email content heading</label>
			<span class="hint">Available variables:<br />
				{postTitle}<br />
				{blogTitle}<br />
				{settingsLink}: link to change individual subscription settings</span>
			<span class="field"><textarea id="digest_header" name="digest_header" cols="100" rows="4" class="required">#templates["digest"]["header"]#</textarea></span>
		</p>
		
		<p>
			<label for="digest_repeat">Email content repeated for each comment</label>
			<span class="hint">Available variables:<br />
				{postTitle}
				{postLink}<br />
				{commentContent}<br />
				{commentCreatedOn}: Date and time of comment<br />
				{commentCreatorEmail}<br />
				{commentCreatorName}</span>
			<span class="field"><textarea id="digest_repeat" name="digest_repeat" cols="100" rows="12" class="required">#templates["digest"]["repeat"]#</textarea></span>
		</p>
		
		<p>
			<label for="digest_footer">Email footer</label>
			<span class="hint">Available variables:<br />
				{postTitle}<br />
				{blogTitle}<br />
				{settingsLink}: link to change individual subscription settings</span>
			<span class="field"><textarea id="digest_footer" name="digest_footer" cols="100" rows="4" class="required">#templates["digest"]["footer"]#</textarea></span>
		</p>
	</fieldset>

	<fieldset>
		<legend>Email sent to post author</legend>
    	<p>This email is sent to post author when a new comment is posted.</p>

		<p>
			<label for="owner_subject">Subject</label>
			<span class="hint">Available variables:<br />
				{postTitle}<br />
				{blogTitle}</span>
			<span class="field"><input type="text" id="owner_subject" name="owner_subject" value="#templates["owner"]["subject"]#" size="60" class="required"/></span>
		</p>
		
		<p>
			<label for="owner_body">Email content</label>
			<span class="hint">Available variables:<br />
				{postTitle}<br />
				{postLink}<br />
				{postId}<br />
				{commentContent}<br />
				{commentCreatorEmail}<br />
				{commentCreatorName}<br />
				{commentCreatorWebsite}<br />
				{settingsLink}: link to change individual subscription settings<br />
				{commentId}<br />
				{adminUrl}<br />
				{blogUrl}</span>
			<span class="field"><textarea id="owner_body" name="owner_body" cols="100" rows="12" class="required">#templates["owner"]["body"]#</textarea></span>
		</p>
	</fieldset>

	<div class="actions">
		<input type="submit" class="primaryAction" value="Save changes"/>
		<input type="hidden" name="owner" value="SubscriptionHandler" />
		<input type="hidden" value="showSubscriptionsHandlerSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="SubscriptionHandler" name="selected" />
	</div>

</form>



</cfoutput>