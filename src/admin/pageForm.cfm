<cfparam name="customFormFields" default="#arraynew(1)#">
<cfparam name="showFields" default="title,content,excerpt,comments_allowed,status,template,parent,name,customFields,sortOrder">
<cfoutput><form method="post" action="#cgi.SCRIPT_NAME#" name="pageForm" id="pageForm">
<table class="formTable">
<tr>
<td>
<cfif listfind(showFields,'title') OR listfind(showFields,'content') OR listfind(showFields,'excerpt')>
	<fieldset>
		<legend>Page</legend>
		<cfif listfind(showFields,'title')>
			<p>
				<label for="title">Title</label>
				<span class="field"><input type="text" id="title" name="title" value="#htmleditformat(title)#" size="50" class="required"/></span>
			</p>
		<cfelse>
			<input type="hidden" name="title" value="#htmleditformat(title)#" />
		</cfif>
		<cfif listfind(showFields,'content')>
			<p>
				<label for="contentField">Content</label>
				<span class="field"><textarea cols="50" rows="20" id="contentField" name="content" class="htmlEditor required">#htmleditformat(content)#</textarea></span>
			</p>
		<cfelse>
			<input type="hidden" name="content" value="#htmleditformat(content)#" />
		</cfif>
		<cfif listfind(showFields,'excerpt')>
			<p>
				<label for="excerpt">Excerpt</label>
				<span class="hint">A short summary describing post</span>
				<span class="field"><textarea cols="50" rows="5" id="excerpt" name="excerpt" class="htmlEditor">#htmleditformat(excerpt)#</textarea></span>
			</p>   
		<cfelse>
			<input type="hidden" name="excerpt" value="#htmleditformat(excerpt)#" />
		</cfif>
		<cfif listfind(showFields,'name')>
			<cfif not len(name) or not REFind("^[a-z0-9]+(-[a-z0-9]+)*$",name)>
			<p>
				<label for="name">URL-safe title</label>
				<span class="hint">Define your own URL. Will be auto-generated when published if left blank.</span>
				<span class="field"><input type="text" id="name" name="name" value="#htmleditformat(name)#" size="50" class="{urlslug:true}"/></span>
			</p>
			</cfif>
		<cfelse>
			<input type="hidden" name="name" value="#htmleditformat(name)#" />
		</cfif>
	</fieldset>
<cfelse>
	<input type="hidden" name="title" value="#htmleditformat(title)#" />
	<input type="hidden" name="content" value="#htmleditformat(content)#" />
	<input type="hidden" name="excerpt" value="#htmleditformat(excerpt)#" />
</cfif>

<cfif listfind(showFields,'customFields')>
	<cfif arraylen(customFields)>
		<fieldset id="customFieldsFieldset" class="">
		<legend>Custom Fields</legend>
		<cfloop from="1" to="#arraylen(customFields)#" index="i">
			<p>
				<label for="customField_#i#">#customFields[i].name# <span>[key: #customFields[i].key#]</span></label>
				<span class="hint">Enter a blank value to delete this custom field</span>
				<span class="field">
					<textarea id="customField_#i#" name="customField_#i#" rows="2" cols="50">#htmleditformat(customFields[i].value)#</textarea>
					<input type="hidden" name="customFieldKey_#i#" value="#htmleditformat(customFields[i].key)#" />
					<input type="hidden" name="customFieldName_#i#" value="#htmleditformat(customFields[i].name)#" />
				</span>
			</p>
		</cfloop>
		</fieldset>
	<cfelse>
		<cfset i = 1 />
	</cfif>
		
		<fieldset id="addCustomFieldsFieldset" class="">
			<legend>New custom field</legend>
			<p style="float:left;margin-bottom:0.5em;">
				<label for="customFieldName_#i#">Label</label>
				<span class="field"><input type="text" name="customFieldName_#i#" id="customFieldName_#i#" size="25" class="{required: function(){return $('##customFieldKey_#i#:filled,##customField_#i#:filled').length > 0}}"/></span>
			</p>
			<p style="float:left;margin-left:2em;margin-bottom:0.5em;">
				<label for="customFieldKey_#i#">Key</label>
				<span class="field"><input type="text" name="customFieldKey_#i#" id="customFieldKey_#i#" size="20" class="{required: function(){return $('##customFieldName_#i#:filled,##customField_#i#:filled').length > 0}}"/></span>
			</p>
			<p style="clear:left;margin:0.5em 0;">
				<label for="customField_#i#">Value</label>
				<span class="field"><textarea id="customField_#i#" name="customField_#i#" rows="2" cols="50" class="{required: function(){return $('##customFieldName_#i#:filled,##customFieldKey_#i#:filled').length > 0}}"></textarea></span>
			</p>
		</fieldset>
<cfelse>
	<cfloop from="1" to="#arraylen(customFields)#" index="i">
		<input type="hidden" name="customField_#i#" value="#htmleditformat(customFields[i].value)#" />
		<input type="hidden" name="customFieldKey_#i#" value="#htmleditformat(customFields[i].key)#" />
		<input type="hidden" name="customFieldName_#i#" value="#htmleditformat(customFields[i].name)#" />
	</cfloop>
</cfif>
<cf_customFormFields entry="#page#" customFormFields="#customFormFields#" startingIndex="#i+1#">
<cfoutput>#tostring(event.getOutputData())#</cfoutput>

	<div class="actions">
		<input type="hidden" name="totalCustomFields" value="#totalCustomFields#" />
		<input type="hidden" name="panel" value="#panel#" />
		<input type="hidden" name="owner" value="#panel#" />
		<input type="hidden" name="id" value="#id#"/>
		<input type="submit" class="primaryAction button" id="tfa_submit" name="submit" value="submit"/>
	</div>
</td>
<td>

<cfif listfind(showFields,'parent') OR listfind(showFields,'template') OR listfind(showFields,"sortOrder")>
	<fieldset class="sidebox">
		<legend>Settings</legend>
		<cfif listfind(showFields,'parent')>
			<p>
				<label for="parentPage">Parent Page</label>
				<span class="field"><select name="parentPage" id="parentPage">
					<option value="">None</option>
					<cfloop from="1" to="#arraylen(pages)#" index="i">
					<option value="#pages[i].getId()#" <cfif parent EQ pages[i].getId()>selected="selected"</cfif>>#xmlformat(pages[i].getTitle())#</option></cfloop>
				</select></span>
			</p>
		<cfelse>
			<input type="hidden" name="parentPage" value="#parent#" />
		</cfif>
		<cfif arraylen(templates) AND listfind(showFields,'template')>
			<p>
				<label for="template">Skin template</label>
				<span class="field"><select id="template" name="template">
					<option value="" <cfif template EQ "">selected="selected"</cfif>>default</option>
					<cfloop from="1" to="#arraylen(templates)#" index="i">
					<option value="#templates[i].file#" <cfif templates[i].file EQ template>selected="selected"</cfif>>#xmlformat(templates[i].name)#</option></cfloop>
				</select></span>
			</p>
		<cfelse>
			<input type="hidden" name="template" value="#template#" />
		</cfif>
		<cfif listfind(showFields,'sortOrder')>
			<p>
				<label for="sortOrder">Sort order</label>
				<span class="field"><input type="text" id="sortOrder" name="sortOrder" value="#sortOrder#" size="2"/></span>
			</p>
		<cfelse>
			<input type="hidden" name="sortOrder" value="#sortOrder#" />
		</cfif>
	</fieldset>
<cfelse>
	<input type="hidden" name="parentPage" value="#parent#" />
	<input type="hidden" name="template" value="#template#" />
	<input type="hidden" name="sortOrder" value="#sortOrder#" />
</cfif>
<cfif listfind(showFields,'comments_allowed')>
	<fieldset class="sidebox">
		<legend>Comments</legend>
		<p>
			<input type="checkbox" value="yes" id="allowComments" name="allowComments" <cfif allowComments>checked="checked"</cfif>/>
			<label for="allowComments">Allow comments</label>
			<span class="hint">Should reader comments be permitted on this page?</span>
		</p>
	</fieldset>
<cfelse>
	<input type="hidden" name="allowComments" value="#allowComments#" />
</cfif>
<cfif listfind(showFields,'status')>
	<fieldset class="sidebox">
		<legend>Publish status</legend>
		<p>
			<input type="radio" value="published" id="published" name="publish" <cfif publish EQ "published">checked="checked"</cfif>/>
			<label for="published">Published</label><br />
			
			<input type="radio" value="draft" id="draft" name="publish" <cfif publish EQ "draft">checked="checked"</cfif>/>
			<label for="draft">Draft</label>
		</p>
	</fieldset>
<cfelse>
	<input type="hidden" name="publish" value="#publish#" />
</cfif>
</td>
</tr>
</table>

</form></cfoutput>