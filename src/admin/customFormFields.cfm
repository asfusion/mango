<!--- we need an entry and an array of custom form fields --->
<cfimport prefix="partials" taglib="partials">
<cfparam name="attributes.customFormFields" default="#arraynew(1)#">
<cfparam name="attributes.entry">
<cfparam name="attributes.startingIndex" default="2">
<cfif thisTag.executionmode EQ "start">
	<cfif arraylen(attributes.customFormFields) GT 0>
		<cfoutput>
	<div class="card card-body border-0 shadow mb-4 mb-xl-0">
	<cfset currentFieldNumber = attributes.startingIndex />
<cfloop from="1" to="#arraylen(attributes.customFormFields)#" index="i">
	<cfset required = false />
	<cfset currentValue = "" />
	<cfset maxLength = 0 />
	<cfset options = [] />

	<cfif structkeyexists(attributes.customFormFields[i], 'value')>
		<cfset currentValue = attributes.customFormFields[i].value />
	</cfif>

	<cfif structkeyexists(attributes.customFormFields[i], 'required') AND attributes.customFormFields[i].required>
		<cfset required = true />
	</cfif>

	<cfif structkeyexists( attributes.customFormFields[i], 'options')>
		<cfset options = attributes.customFormFields[i].options />
	</cfif>

	<cfif structkeyexists(attributes.customFormFields[i], 'maxLength') AND attributes.customFormFields[i].maxLength GT 0>
		<cfset maxLength = attributes.customFormFields[i].maxLength />
		<!---<cfset className = listappend(className, 'countable', ' ') />
		<cfif maxLength GT 0>maxlength='#maxLength#'</cfif>
		--->
	</cfif>

	<cfset checkValue = ''/>
	<cfif structKeyExists( attributes.customFormFields[i], 'checkValue' )>
		<cfset checkValue = attributes.customFormFields[i].checkValue />
	</cfif>
	<cfset hint = ''/>
	<cfif structKeyExists( attributes.customFormFields[i], 'hint' )>
		<cfset hint = attributes.customFormFields[i].hint />
	</cfif>
	<partials:form_field id="customField_#currentFieldNumber#" type="#attributes.customFormFields[i].inputType#" options="#options#"
		label="#attributes.customFormFields[i].name#" value="#currentValue#" required="#required#" checkValue="#checkValue#" hint="#hint#" />

		<input type="hidden" name="customFieldKey_#currentFieldNumber#" value="#htmleditformat(attributes.customFormFields[i].id)#" />
		<input type="hidden" name="customFieldName_#currentFieldNumber#" value="#htmleditformat(attributes.customFormFields[i].name)#" />

	<cfset currentFieldNumber = currentFieldNumber + 1 />
</cfloop>
	</div>
</cfoutput>
</cfif>
</cfif>