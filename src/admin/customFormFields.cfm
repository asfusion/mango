<!--- we need an entry and an array of custom form fields --->
<cfparam name="attributes.customFormFields" default="#arraynew(1)#">
<cfparam name="attributes.entry">
<cfparam name="attributes.startingIndex" default="2">
<cfif thisTag.executionmode EQ "start">
<cfoutput>
	<cfset currentFieldNumber = attributes.startingIndex />
<cfloop from="1" to="#arraylen(attributes.customFormFields)#" index="i">
	<cfset className = "" />
	<cfset currentValue = "" />
	<cfset maxLength = 0 />
	
	<cfif structkeyexists(attributes.customFormFields[i], 'value')>
		<cfset currentValue = attributes.customFormFields[i].value />
	</cfif>
	
	<cfif structkeyexists(attributes.customFormFields[i], 'required') AND attributes.customFormFields[i].required>
		<cfset className = "required" />
	</cfif>
	
	<cfif structkeyexists(attributes.customFormFields[i], 'maxLength') AND attributes.customFormFields[i].maxLength GT 0>
		<cfset maxLength = attributes.customFormFields[i].maxLength />
		<cfset className = listappend(className, 'countable', ' ') />
	</cfif>
	
	<input type="hidden" name="customFieldKey_#currentFieldNumber#" value="#htmleditformat(attributes.customFormFields[i].id)#" />
	<input type="hidden" name="customFieldName_#currentFieldNumber#" value="#htmleditformat(attributes.customFormFields[i].name)#" />
	<cfif attributes.customFormFields[i].inputType EQ "hidden">
		<input type="hidden" name="customField_#currentFieldNumber#" value="#htmleditformat(currentValue)#" />
	<cfelseif attributes.customFormFields[i].inputType EQ "textinput">
	<p>
		<label for="customField_#currentFieldNumber#">#attributes.customFormFields[i].name#</label>
		<span class="field"><input type="text" name="customField_#currentFieldNumber#" id="customField_#currentFieldNumber#" value="#htmleditformat(currentValue)#" 
				size="40" class="#className#" <cfif maxLength GT 0>maxlength='#maxLength#'</cfif> /></span>
	</p>
	<cfelseif attributes.customFormFields[i].inputType EQ "textarea">
	<p>
		<label for="customField_#currentFieldNumber#">#attributes.customFormFields[i].name#</label>
		<span class="field"><textarea name="customField_#currentFieldNumber#" id="customField_#currentFieldNumber#" rows="10" cols="50" 
					class="#className#" style="width:100%" <cfif maxLength GT 0>maxlength='#maxLength#'</cfif>>#htmleditformat(currentValue)#</textarea></span>
	</p>
	<cfelseif attributes.customFormFields[i].inputType EQ "htmlTextarea">
	<p>
		<label for="customField_#currentFieldNumber#">#attributes.customFormFields[i].name#</label>
		<span class="field"><textarea name="customField_#currentFieldNumber#" id="customField_#currentFieldNumber#" 
					class="htmlEditor #className#" rows="10" cols="50" style="width:100%" >#htmleditformat(currentValue)#</textarea></span>
	</p>
	<cfelseif attributes.customFormFields[i].inputType EQ "radioButton">
	<p>
		<label for="customField_#currentFieldNumber#">#attributes.customFormFields[i].name#</label>
		<span class="field">
			<cfloop from="1" to="#arraylen(attributes.customFormFields[i].options)#" index="j">
			<label><input type="radio" value="#attributes.customFormFields[i].options[j].value#" name="customField_#currentFieldNumber#" <cfif attributes.customFormFields[i].options[j].value EQ currentValue>checked="checked"</cfif>/>
				#attributes.customFormFields[i].options[j].label#</label>&nbsp;&nbsp;&nbsp;
			</cfloop>
		</span>
	</p>
	<cfelseif attributes.customFormFields[i].inputType EQ "dropdown">
	<p>
		<label for="customField_#currentFieldNumber#">#attributes.customFormFields[i].name#</label>
		<span class="field">
			<select name="customField_#currentFieldNumber#" class="#className#">		
			<cfloop from="1" to="#arraylen(attributes.customFormFields[i].options)#" index="j">
				<option value="#attributes.customFormFields[i].options[j].value#" <cfif attributes.customFormFields[i].options[j].value EQ currentValue>selected="selected"</cfif>>#attributes.customFormFields[i].options[j].label#</option>
			</cfloop>
			</select>
		</span>
	</p>
	<cfelseif attributes.customFormFields[i].inputType EQ "checkbox">
	<p>
		<label>#attributes.customFormFields[i].name#</label>
		<span class="field">
			<cfloop from="1" to="#arraylen(attributes.customFormFields[i].options)#" index="j">
				<label><input type="checkbox" value="#attributes.customFormFields[i].options[j].value#" name="customField_#currentFieldNumber#" <cfif listfind(currentValue,attributes.customFormFields[i].options[j].value)>checked="checked"</cfif> class="#className#"/>
					#attributes.customFormFields[i].options[j].label#</label>&nbsp;&nbsp;&nbsp;
			</cfloop>
		</span>
	</p>
	<cfelseif attributes.customFormFields[i].inputType EQ "assetSelector">
	<p>
		<label for="customField_#currentFieldNumber#">#attributes.customFormFields[i].name#</label>
		<span class="field"><input type="text" name="customField_#currentFieldNumber#" id="customField_#currentFieldNumber#" value="#htmleditformat(currentValue)#" size="40" class="assetSelector #className#" /></span>
	</p>
	<cfelseif attributes.customFormFields[i].inputType EQ "fileUpload">
	<p>
		<label for="customField_#currentFieldNumber#">#attributes.customFormFields[i].name#</label>
		<span class="field">
			<input type="file" name="customField_#currentFieldNumber#" id="customField_#currentFieldNumber#" size="40" class="#className#" /></span>
		<cfif len(currentValue)>Current value: #htmlEditFormat(currentValue)#</cfif>
	</p>
	</cfif>
	<cfset currentFieldNumber = currentFieldNumber + 1 />
</cfloop>
</cfoutput>
</cfif>