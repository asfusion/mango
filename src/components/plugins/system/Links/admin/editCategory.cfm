<cfoutput><form method="post" action="#cgi.script_name#">
	<fieldset>
		<legend>Category</legend>
		<p>
			<label for="name">Title</label>
			<span class="field"><input type="text" id="name" name="name" value="#category.getName()#" size="30" class="required"/></span>
		</p>
	
		<p>
			<label for="description">Description</label>
			<span class="hint">What this category is about. Whether or not this is shown in the blog depends on the skin used</span>
			<span class="field"><textarea cols="40" rows="4" id="description" name="description">#category.getDescription()#</textarea></span>
		</p>
	</fieldset>
	
	
	<div class="actions">
		<input type="submit" class="primaryAction" value="Save"/>
		<input type="hidden" value="links-editLinkCategorySettings" name="event" />
		<input type="hidden" value="true" name="apply" />
		<input type="hidden" value="Links" name="owner" />
		<input type="hidden" value="links-editLinkCategorySettings" name="selected" />
		<cfif len(category.getId())><input type="hidden" value="#category.getId()#" name="categoryid" /></cfif>
	</div>
</form></cfoutput>