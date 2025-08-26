<cfoutput>

	<div class="row">
<form method="post" action="#cgi.script_name#">
<div class="card card-body border-0 shadow mb-4">
		<label for="mailFrom">Send email from address:</label>
		<input type="text" id="mailFrom" name="mailFrom" value="#email#" size="50" class="required {email:true} form-control"/>
</div>

<div class="card card-body border-0 shadow mb-4">
		<legend>New Comment Email</legend>
    	<p>This email is sent when a new comment is made.</p>

<div class="mb-3 row">
	<div class="col-md-8 col-12">
		<label for="normal_subject">Subject</label>
		<input type="text" id="normal_subject" name="normal_subject" value="#templates["normal"]["subject"]#" size="60" class="required form-control"/>
	</div>
	<div class="col-md-4 col-12">
		<div class="form-text hint">Available variables for subject:<br />
				{postTitle}<br />
				{blogTitle}</div>
	</div>
</div>

<div class="mb-3 row">
	<div class="col-md-8 col-12">
			<label for="normal_body">Email content</label>
			<textarea id="normal_body" name="normal_body" cols="100" rows="12" class="required form-control">#templates["normal"]["body"]#</textarea>
	</div>
	<div class="form-text hint col-md-4 col-12">Available variables:<br />
		{postTitle}<br />
		{postLink}<br />
		{postId}<br />
		{commentContent}<br />
		{commentCreatorEmail}<br />
		{commentCreatorName}<br />
		{commentCreatorWebsite}<br />
		{settingsLink}: link to change individual subscription settings<br />
		{commentId}<br />
		{blogUrl}</div>
</div>
</div>

<div class="card card-body border-0 shadow mb-4">
	<legend>Digest Mode Email</legend>
    <p>This is email is sent to readers subscribed in "digest mode". It is sent every day with all the new comments made during the day to which they are subscribed.</p>

	<div class="mb-3 row">
		<div class="col-md-8 col-12">
			<label for="digest_subject">Subject</label>
				<input type="text" id="digest_subject" name="digest_subject" value="#templates["digest"]["subject"]#" size="60" class="required form-control"/>
		</div>
		<div class="form-text hint col-md-4 col-12">Available variables:<br />
					{postTitle}<br />
					{blogTitle}
		</div>
	</div>
	<div class="mb-3 row">
		<div class="col-md-8 col-12">
			<label for="digest_header">Email content heading</label>
			<textarea id="digest_header" name="digest_header" cols="100" rows="4" class="required form-control">#templates["digest"]["header"]#</textarea>
		</div>
		<div class="form-text hint col-md-4 col-12">Available variables:<br />
					{postTitle}<br />
					{blogTitle}<br />
					{settingsLink}: link to change individual subscription settings
		</div>
	</div>
	<div class="mb-3 row">
		<div class="col-md-8 col-12">
			<label for="digest_repeat">Email content repeated for each comment</label>
			<textarea id="digest_repeat" name="digest_repeat" cols="100" rows="12" class="required form-control">#templates["digest"]["repeat"]#</textarea>
		</div>
		<div class="form-text hint col-md-4 col-12">Available variables:<br />
					{postTitle}
					{postLink}<br />
					{commentContent}<br />
					{commentCreatedOn}: Date and time of comment<br />
					{commentCreatorEmail}<br />
					{commentCreatorName}
		</div>
	</div>
	<div class="mb-3 row">
		<div class="col-md-8 col-12">
			<label for="digest_footer">Email footer</label>
			<textarea id="digest_footer" name="digest_footer" cols="100" rows="4" class="required form-control">#templates["digest"]["footer"]#</textarea></span>
		</div>
		<div class="form-text hint col-md-4 col-12">Available variables:<br />
					{postTitle}<br />
					{blogTitle}<br />
					{settingsLink}: link to change individual subscription settings
		</div>
	</div>
</div>

<div class="card card-body border-0 shadow mb-4">
	<legend>Email sent to post author</legend>
	<p>This email is sent to post author when a new comment is posted.</p>

	<div class="mb-3 row">
	<div class="col-md-8 col-12">
		<label for="owner_subject">Subject</label>
		<input type="text" id="owner_subject" name="owner_subject" value="#templates["owner"]["subject"]#" size="60" class="required form-control"/>
	</div>
	<div class="form-text hint col-md-4 col-12">Available variables:<br />
				{postTitle}<br />
				{blogTitle}
	</div>
</div>
	<div class="mb-3 row">
	<div class="col-md-8 col-12">
		<label for="owner_body">Email content</label>
		<textarea id="owner_body" name="owner_body" cols="100" rows="12" class="required form-control">#templates["owner"]["body"]#</textarea>
	</div>
	<div class="form-text hint col-md-4 col-12">Available variables:<br />
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
				{blogUrl}
	</div>
</div>

</div>
	<div class="actions">
		<input type="submit" class="btn btn-primary" value="Save changes"/>
		<input type="hidden" name="owner" value="SubscriptionHandler" />
		<input type="hidden" value="showSubscriptionsHandlerSettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="SubscriptionHandler" name="selected" />
	</div>

</form>

</div>

</cfoutput>