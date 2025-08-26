<cfoutput>
<form method="post" action="#cgi.script_name#">
<div class="row">
<div class="col-12 ">
<div class="card card-body border-0 shadow mb-4">
	<h4>#locationTitle#</h4>
<div class="row">
	<div class="col-6">
	<label for="pods">Pod order (use ids)</label>
	<textarea cols="30" rows="12" id="pods" name="pods" class="form-control">#newList#</textarea>
	</div>
	<div class="col-6">
	<p>Available theme pods and pods added by plugins:</p>
	#availableLabel#
	</div>
</div>

		<div class="actions">
			<input type="hidden" name="locationId" value="#locationId#" />
			<input type="submit" class="btn btn-gray-800 mt-2 animate-up-2" value="Save changes"/>
			<input type="hidden" name="owner" value="PodManager" />
			<input type="hidden" value="podManager-showSettings" name="event" />
			<input type="hidden" value="true" name="apply" />
			<input type="hidden" value="PodManager" name="selected" />
		</div>

</div>
</div>
</div>
</form>
</cfoutput>