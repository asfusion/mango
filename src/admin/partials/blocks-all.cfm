<!--- we need an entry and an array of custom form fields --->
<cfparam name="attributes.blocks" default="#arraynew(1)#">
<cfparam name="attributes.entry">
<cfparam name="attributes.startingIndex" default="2">
<cfif thisTag.executionmode EQ "start">

    <!--- assign an iternal id to each block --->
    <cfset count = 0 />
    <div class="row draggable-zone"><cfoutput>
        <cfloop array="#attributes.blocks#" item="block">
            <cfset count++>

            <cfset block.__internalid__ = count />
            <cfif NOT structKeyExists( block, 'active' )>
                <cfset block.active = 0 />
            </cfif>

            <input type="hidden" name="block_#block.__internalid__#_id" value="#block.id#"/>
        <div class="draggable mb-2" tabindex="0">
            <!--begin::Card-->
            <div class="card card-bordered">
                <div class="card-header border-bottom d-flex align-items-center justify-content-between">
                    <div class="card-title">
                        <h2 class="card-label fs-5 fw-bold mb-0">#block.title#</h2>
                    </div>
                    <div class="card-toolbar">

                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" value="1" id="block_#block.__internalid__#_active"
                        name="block_#block.__internalid__#_active" <cfif block.active EQ 1>checked="checked"</cfif>>
                    <label class="form-check-label" for="block_#block.__internalid__#_active">Show / hide </label>
                </div>
                    <a href="##" class="draggable-handle"><i class="bi bi-grip-horizontal icon-xxl"></i></a></div>
                </div>
                <div class="card-body">
        <div class="row mb-4">
                <cfif structKeyExists( block, 'screenshot' )>
                    <div class="mb-3"> <img src="#block.screenshot#" style="max-width: 100%"></div>
                </cfif>
<cfset fieldcount = 1 />
<cfloop array="#block.fields#" item="field">
    <cfif NOT structKeyExists( field, 'size')><cfset field.size = 'medium' /></cfif>
    <cfif NOT structKeyExists( field, 'hint')><cfset field.hint = '' /></cfif>
    <cfif NOT structKeyExists( field, 'value')><cfset field.value = field.default /></cfif>
    <cfset blockPrefix = "block_#block.__internalid__#" />

    <cfif field.type NEQ 'array'>
        <input type="hidden" name="#field.form_id#_id" value="#field.id#"/>
        <cf_form_field id="#field.form_id#_value" type="#field.type#"
                label="#field.name#" size="#field.size#" hint="#field.hint#" value="#field.value#">
        <cfelse>
        <fieldset class="mb-3">
            <legend class="h5 my-4">#field.name#</legend>
            <ol class="list-group list-group-numbered list-group-flush">
            <cfset fielditemcount = 0 />
            <cfloop array="#field.items#" item="fieldset">
                <cfset fielditemcount++ >

                    <li class="list-group-item d-flex justify-content-between align-items-start">
                        <div class="ms-2 me-auto w-100 ">
                            <div class="row">
                            <cfset arrayFieldCount = 0 />
                            <cfloop array="#fieldset#" item="fielditem">
                             <cfset arrayFieldCount++ >
                                <input type="hidden" name="#field.form_id#_id" value="#fielditem.id#"/>
                                <cfif NOT structKeyExists( fieldItem, 'size')><cfset fieldItem.size = 'medium' /></cfif>
                                <cfif NOT structKeyExists( fieldItem, 'hint')><cfset fieldItem.hint = '' /></cfif>
                                <cfif NOT structKeyExists( fieldItem, 'options')><cfset fieldItem.options = [] /></cfif>
                                <cf_form_field id="#field.form_id#_value" type="#fieldItem.type#" label="#fieldItem.name#"
                                    size="#fieldItem.size#" hint="#fieldItem.hint#" options="#fieldItem.options#"  value="#fielditem.value#">
                </cfloop>
                </div>
                </div>
                </li>
            </cfloop>

            </ol>
            </fieldset>
                </cfif>
                <cfset fieldcount++ >
            </cfloop>
            <input type="hidden" name="#blockPrefix#_fieldcount" value="#fieldcount#"/>
            </div>
            </div>
            </div>
            <!--end::Card-->
        </div>

      </cfloop>
        <input type="hidden" name="block_count" value="#count#"/>
</cfoutput>
    </div>

</cfif>