<cfimport prefix="mangoAdminPartials" taglib="partials">
<cfparam name="customFormFields" default="#arraynew(1)#">
<cfparam name="showFields" default="title,content,excerpt,comments_allowed,status,template,parent,name,customFields,sortOrder">
<cfoutput>
		<input type="hidden" name="panel" value="#panel#" />
		<input type="hidden" name="owner" value="#panel#" />
		<input type="hidden" name="id" value="#id#"/>

<div class="row">
<div class="col-12 col-xl-8">
<cfif listfind(showFields,'title') OR listfind(showFields,'content') OR listfind(showFields,'excerpt') OR listfind(showFields,'name')>
		<mangoAdminPartials:postFormBasics showFields="#showFields#" title="#title#" name="#name#" excerpt="#excerpt#" content="#content#"></mangoAdminPartials:postFormBasics>
<cfelse>
	<input type="hidden" name="title" value="#htmleditformat(title)#" />
	<input type="hidden" name="content" value="#htmleditformat(content)#" />
	<input type="hidden" name="excerpt" value="#htmleditformat(excerpt)#" />
		<input type="hidden" name="name" value="#htmleditformat( name )#" />
</cfif>

<!--- CUSTOM FIELDS CARD --->
	<cfset customFieldStartingIndex = arraylen( customFields ) + 1 />
	<cfif listfind(showFields,'customFields')><!--- regular fields ---->
		<mangoAdminPartials:postFormCustomFields customFields="#customFields#">
		<cfset customFieldStartingIndex += 1>
	<cfelse>
		<cfloop from="1" to="#arraylen(customFields)#" index="i">
			<input type="hidden" name="customField_#i#" value="#htmleditformat(customFields[i].value)#" />
				<input type="hidden" name="customFieldKey_#i#" value="#htmleditformat(customFields[i].key)#" />
				<input type="hidden" name="customFieldName_#i#" value="#htmleditformat(customFields[i].name)#" />
		</cfloop>
	</cfif>
<!--- END CUSTOM FIELDS CARD --->

	<cf_customFormFields entry="#page#" customFormFields="#customFormFields#" startingIndex="#customFieldStartingIndex#">
</div>

	<!--- START RIGHT COLUMN --->
	<div class="col-12 col-xl-4">
		<cfif listfind(showFields,'parent') OR listfind(showFields,'template') OR listfind(showFields,"sortOrder")>
		<div class="card card-body border-0 shadow mb-4">
			<h2 class="h5 mb-4">#request.i18n.getValue("Settings")#</h2>

			<cfif listfind(showFields,'parent')>
				<div class="mb-3">
					<label for="parentPage">#request.i18n.getValue("Parent Page")#</label>
					<select class="form-select mb-0" name="parentPage" id="parentPage">
						<option value="">#request.i18n.getValue("None")#</option>
				<cfloop from="1" to="#arraylen(pages)#" index="i">
						<option value="#pages[i].getId()#" <cfif parent EQ pages[i].getId()>selected="selected"</cfif>>#xmlformat(pages[i].getTitle())#</option></cfloop>
				</select>
				</div>
			<cfelse>
				<input type="hidden" name="parentPage" value="#parent#" />
			</cfif>
			<cfif arraylen(templates) AND listfind(showFields,'template')>
				<div class="mb-3">
					<label for="template">#request.i18n.getValue("Skin template")#</label>
					<select class="form-select mb-0"  id="template" name="template">
						<option value="" <cfif template EQ "">selected="selected"</cfif>>#request.i18n.getValue("Regular page")#</option>
						<cfloop from="1" to="#arraylen(templates)#" index="i">
						<option value="#templates[i].file#" <cfif templates[i].file EQ template>selected="selected"</cfif>>#xmlformat(templates[i].name)#</option></cfloop>
					</select>
					</div>
			<cfelse>
				<input type="hidden" name="template" value="#template#" />
			</cfif>
			<cfif listfind(showFields,'sortOrder')>
				<div class="mb-3">
					<label for="sortOrder">#request.i18n.getValue("Sort order")#</label>
					<input type="text" id="sortOrder" name="sortOrder" value="#sortOrder#" size="2" class="form-control"/></span>
				</div>
			<cfelse>
				<input type="hidden" name="sortOrder" value="#sortOrder#" />
			</cfif>
			</div>
	<cfelse>
		<input type="hidden" name="parentPage" value="#parent#" />
		<input type="hidden" name="template" value="#template#" />
		<input type="hidden" name="sortOrder" value="#sortOrder#" />
	</cfif>
		<cfif listfind(showFields,'comments_allowed')>
	<!--- COMMENTS --->
		<cfif listfind(showFields,'comments_allowed')>
				<div class="card card-body border-0 shadow mb-4">
					<h2 class="h5 mb-4">#request.i18n.getValue("Comments")#</h2>

				<div class="form-check form-switch">
						<input class="form-check-input" type="checkbox" value="yes" id="allowComments" name="allowComments" <cfif allowComments>checked="checked"</cfif>/>
				<label class="form-check-label" for="allowComments">#request.i18n.getValue("Allow comments")#</label>
			</div>

				<p class="form-text">#request.i18n.getValue("Should reader comments be permitted on this post?")#</p>
			</div>
		<cfelse>
				<input type="hidden" name="allowComments" value="#allowComments#" />
		</cfif>
	<cfelse>
		<input type="hidden" name="allowComments" value="#allowComments#" />
	</cfif>
		<cfif listfind(showFields,'status')>
			<div class="card card-body border-0 shadow mb-4">
				<h2 class="h5 mb-4">#request.i18n.getValue("Publish status")#</h2>

				<div class="form-check">
						<input class="form-check-input" type="radio" value="published" id="published" name="publish" <cfif publish EQ "published">checked="checked"</cfif>>
				<label class="form-check-label" for="published">#request.i18n.getValue("Published")#</label>
			</div>
			<div class="form-check">
					<input class="form-check-input" type="radio" value="draft" id="draft" name="publish" <cfif publish EQ "draft">checked="checked"</cfif>>
					<label class="form-check-label" for="draft">#request.i18n.getValue("Draft")#</label>
			</div>
			<!-- End of Radio -->
			</div>
		<cfelse>
				<input type="hidden" name="publish" value="#publish#" />
		</cfif>
	</div>
</div>

	<cfoutput>#tostring(event.getOutputData())#</cfoutput>

	<input type="hidden" name="totalCustomFields" value="#totalCustomFields#" />

	<div class="row">
		<div class="col-4 col-md-2">
			<input type="submit" class="btn btn-primary d-inline-flex align-items-center my-3 animate-up-2" name="submit" value="Save" />
		</div>
	<div>

</cfoutput>