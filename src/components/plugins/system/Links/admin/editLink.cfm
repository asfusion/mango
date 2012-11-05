<cfoutput>
<form method="post" action="#cgi.script_name#">
	<fieldset id="link" class="">
		<legend>Link</legend>
		<p>
			<label for="title">Title</label>
			<span class="field"><input type="text" id="title" name="title" value="#link.getTitle()#" size="30" class="required"/></span>
		</p>

		<p>
			<label for="address">URL</label>
			<span class="field"><input type="text" id="address" name="address" value="#link.getAddress()#" size="50" class="required url"/></span>
		</p>

		<p>
			<label for="description">Description</label>
			<span class="field"><textarea id="description" name="description" cols="40" rows="4">#link.getDescription()#</textarea></span>
		</p>

		<p>
			<label for="category">Category</label>
			<span class="field"><select id="category" name="category" class="required">
				<cfloop from="1" to="#arraylen(categories)#" index="i">
				<option value="#categories[i].getId()#" <cfif categories[i].getId() EQ link.getCategoryId()>selected="selected"</cfif>>#categories[i].getName()#</option>
				</cfloop>
			</select></span>
		</p>

		<p>
			<label for="order">Order</label>
			<span class="field"><input type="text" id="order" name="order" value="#link.getShowOrder()#" size="3"/></span>
		</p>

	</fieldset>

	<div class="actions">
		<input type="submit" class="primaryAction" id="submit-" value="Submit"/>
		<input type="hidden" name="selected" value="links-editLinkSettings" />
		<input type="hidden" name="event" value="links-editLinkSettings" />
		<input type="hidden" name="apply" value="true"  />
		<input type="hidden" name="owner" value="Links" />
		<cfif len(link.getId())><input type="hidden" value="#link.getId()#" name="linkid" /></cfif>
	</div>
</form>
</cfoutput>