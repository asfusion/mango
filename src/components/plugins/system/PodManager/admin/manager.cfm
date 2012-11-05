<cfoutput>
<form method="post" action="#cgi.script_name#">
	<fieldset>
		<legend>#locationTitle#</legend>
		<div class="column1">
			<p>
				<label for="pods">Pod order (use ids)</label>
				<span class="field"><textarea cols="30" rows="12" id="pods" name="pods" class="">#newList#</textarea></span>
			</p>
		</div>
		<div class="column2">
			<p>Available theme pods and pods added by plugins:</p>
			#availableLabel#
		</div>

		<div class="actions">
			<input type="hidden" name="locationId" value="#locationId#" />
			<input type="submit" class="primaryAction" value="Save changes"/>
			<input type="hidden" name="owner" value="PodManager" />
			<input type="hidden" value="podManager-showSettings" name="event" />
			<input type="hidden" value="true" name="apply" />
			<input type="hidden" value="PodManager" name="selected" />
		</div>
	</fieldset>
</form>
</cfoutput>