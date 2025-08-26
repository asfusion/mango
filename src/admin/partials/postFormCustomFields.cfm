<cfparam name="attributes.customFields" default="">
<cfset customFields = attributes.customFields>
<cfif thisTag.executionmode EQ "start"><cfoutput>
    <div class="card card-body border-0 shadow mb-4 mb-xl-0">
    <cfif arraylen( customFields )>
       <h2 class="h5 mb-4">Custom Fields</h2>
        <ul class="list-group list-group-flush">
        <cfloop from="1" to="#arraylen( customFields )#" index="i">
            <cfoutput>
                <li class="list-group-item px-0 border-bottom">
                    <div>
                        <h3 class="h6 mb-1"><label for="customField_#i#">#customFields[i].name# <span>[key: #customFields[i].key#]</span></label></h3>

                        <textarea id="customField_#i#" name="customField_#i#" rows="2" class="form-control" >#htmleditformat(customFields[i].value)#</textarea>
                        <input type="hidden" name="customFieldKey_#i#" value="#htmleditformat(customFields[i].key)#" />
                        <input type="hidden" name="customFieldName_#i#" value="#htmleditformat(customFields[i].name)#" />
                    </div>
                </li>

                <div class="form-text hint">Enter a blank value to delete this custom field</div>
            </cfoutput>
        </cfloop>
        </ul>
    <cfelse>
        <cfset i = 1/>
    </cfif>

        <h2 class="h5 mb-4">New custom field</h2>

        <div class="row">
            <div class="col-md-6 mb-3">
                <div class="form-group">
                    <label for="customFieldName_#i#">Label</label>
                    <input type="text" class="form-control" name="customFieldName_#i#" id="customFieldName_#i#" size="25" class="{required: function(){return $('##customFieldKey_#i#:filled,##customField_#i#:filled').length > 0}}">
                </div>
            </div>
            <div class="col-md-6 mb-3">
                <div class="form-group">
                    <label for="customFieldKey_#i#">Key</label>
                    <input type="text" name="customFieldKey_#i#" id="customFieldKey_#i#" size="20" class="form-control" class="{required: function(){return $('##customFieldName_#i#:filled,##customField_#i#:filled').length > 0}}"/></span>
                </div>
            </div>
        </div>
        <div>
            <label for="customField_#i#">Value</label>
            <textarea id="customField_#i#" name="customField_#i#" rows="2" class="form-control" class="{required: function(){return $('##customFieldName_#i#:filled,##customFieldKey_#i#:filled').length > 0}}"></textarea>

        </div>

    </div><!--card-->
</cfoutput>
</cfif>