<cfimport prefix="mangoAdminPartials" taglib="partials">
<cfparam name="customFormFields" default="#arraynew(1)#">
<cfparam name="showFields" default="title,content,excerpt,comments_allowed,status,name,categories,customFields,posted_on">
<cfset currentAuthor = request.blogManager.getCurrentUser() />
<cfoutput>
	<input type="hidden" name="id" value="#id#">
	<input type="hidden" name="panel" value="#panel#">
	<input type="hidden" name="owner" value="#panel#" />

	<div class="row">
		<div class="col-12 col-xl-8">
			<mangoAdminPartials:postFormBasics showFields="#showFields#" title="#title#" name="#name#" excerpt="#excerpt#" content="#content#"></mangoAdminPartials:postFormBasics>
		<!---<div class="mt-3">
			<button class="btn btn-gray-800 mt-2 animate-up-2" type="submit">Save all</button>
		</div>--->

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

			<!--- fields with meta data that are shown in different ways --->
			<cf_customFormFields entry="#post#" customFormFields="#customFormFields#" startingIndex="#customFieldStartingIndex#">
		</div><!--- END LEFT COLUMN --->

		<!--- START RIGHT COLUMN --->
		<div class="col-12 col-xl-4">
			<cfif listfind(showFields,'posted_on') OR listfind(showFields,'status')>
		<div class="card card-body border-0 shadow mb-4">
			<h2 class="h5 mb-4">#request.i18n.getValue("Publish status")#</h2>

		<cfif listfind(showFields,'status')>
					<div class="form-check">
						<input class="form-check-input" type="radio" value="published" id="published" name="publish" <cfif publish EQ "published">checked="checked"</cfif>>
						<label class="form-check-label" for="published">#request.i18n.getValue("Published")#</label>
					</div>
					<div class="form-check">
						<input class="form-check-input" type="radio" value="draft" id="draft" name="publish" <cfif publish EQ "draft">checked="checked"</cfif>>
						<label class="form-check-label" for="draft">#request.i18n.getValue("Draft")#</label>
					</div>
					<!-- End of Radio -->
		<cfelse>
				<input type="hidden" name="publish" value="#publish#" />
		</cfif>
		<cfif listfind(showFields,'posted_on')>
				<label for="postedOn">#request.i18n.getValue("Publishing date")#</label>
				<input type="text" id="postedOn" name="postedOn" value="#postedOn#" size="18" class="date form-control" />
	<cfelse>
				<input type="hidden" name="postedOn" value="#postedOn#" />
		</cfif>
	</div>
	<cfelse>
	<input type="hidden" name="postedOn" value="#postedOn#" />
	<input type="hidden" name="publish" value="#publish#" />
	</cfif>
			<cfif listfind(showFields,'categories')>
	<div class="col-12">
		<div class="card card-body border-0 shadow mb-4">
			<h2 class="h5 mb-4">#request.i18n.getValue("Categories")#</h2>
			<p class="form-text">#request.i18n.getValue("File this post under:")#</p>

		<cfloop from="1" to="#arraylen(categories)#" index="i">
			<div class="form-check">
				<input class="form-check-input" type="checkbox" value="#categories[i].getId()#" id="category_#i#" name="category" <cfif listfind(categoriesList,categories[i].getId())>checked="checked"</cfif> />
				<label class="form-check-label" for="category_#i#">
			#htmleditformat(categories[i].getTitle())#
				</label>
			</div>
		</cfloop>

		<div>
			<label for="new_category">#request.i18n.getValue("New category")#</label>
			<input class="form-control" type="text" name="new_category" id="newcategory" />
		</div>


		</div>
	</div>
	<cfelse>
		<input type="hidden" name="category" value="#categoriesList#" />
	</cfif>
			<!--- COMMENTS --->
			<cfif listfind(showFields,'comments_allowed')>
				<div class="col-12">
				<div class="card card-body border-0 shadow mb-4">
					<h2 class="h5 mb-4">#request.i18n.getValue("Comments")#</h2>

					<div class="form-check form-switch">
							<input class="form-check-input" type="checkbox" value="yes" id="allowComments" name="allowComments" <cfif allowComments>checked="checked"</cfif>/>
						<label class="form-check-label" for="allowComments">#request.i18n.getValue("Allow comments")#</label>
					</div>

				<p class="form-text">#request.i18n.getValue("Should reader comments be permitted on this post?")#</p>
			</div>
				</div>
		<cfelse>
				<input type="hidden" name="allowComments" value="#allowComments#" />
		</cfif>
		</div>

	<cfif listfind(showFields,'title') OR listfind(showFields,'content') OR listfind(showFields,'excerpt')>
	<cfelse>
	<input type="hidden" name="title" value="#htmleditformat(title)#" />
	<input type="hidden" name="content" value="#htmleditformat(content)#" />
	<input type="hidden" name="excerpt" value="#htmleditformat(excerpt)#" />
	</cfif>

	<input type="hidden" name="totalCustomFields" value="#totalCustomFields#" />
</div>
	<div class="row">
		<cfoutput>#tostring(event.getOutputData())#</cfoutput>
	</div>

	<div class="row">
		<div class="col-4 col-md-2">
			<input type="submit" class="btn btn-primary d-inline-flex align-items-center my-3 animate-up-2" name="submit" value="#request.i18n.getValue("Save")#" />
		</div>
	</div>
</cfoutput>