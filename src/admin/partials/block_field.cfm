<cfparam name="attributes.fields" default="#arraynew()#">
<cfparam name="attributes.blockPrefix" default="">
<cfparam name="attributes.startingIndex" default="2">
<cfif thisTag.executionmode EQ "start">

    <!--- assign an iternal id to each block --->
    <cfset count = 0 />
    <cfset fieldcount = 0 /><cfoutput>
    <cfloop array="#attributes.fields#" item="field">
        <cfset fieldcount++ >

        <cfif NOT structKeyExists( field, 'size')><cfset field.size = 'fluid' /></cfif>
        <cfif NOT structKeyExists( field, 'hint')><cfset field.hint = '' /></cfif>
        <cfif NOT structKeyExists( field, 'checkvalue')><cfset field.checkvalue = '' /></cfif>
        <cfif NOT structKeyExists( field, 'value')><cfset field.value = structKeyExists( field, 'default') ? field.default : '' /></cfif>
        <cfif NOT structKeyExists( field, 'options')><cfset field.options = [] /></cfif>

        <cfif field.type NEQ 'array'>
            <input type="hidden" name="#field.form_id#_id" value="#field.id#"/>
            <input type="hidden" name="#field.form_id#_path" value='#field.path#'/>
                <input type="hidden" name="#field.form_id#_basepath" value='#field.basepath#'/>
            <cf_form_field id="#field.form_id#_value" type="#field.type#" options="#field.options#"
                    label="#request.i18n.getValue(field.name)#" size="#field.size#" hint="#field.hint#" value="#field.value#" checkvalue="#field.checkvalue#">
        <cfelse>
            <fieldset class="mb-3">
                <legend class="h5 my-4">#request.i18n.getValue(field.name)#</legend>
                <ol class="list-group list-group-numbered list-group-flush">
                <cfset fielditemcount = 0 />
                <cfloop array="#field.fields#" item="fieldset">
                    <li class="list-group-item d-flex justify-content-between align-items-start">
                    <div class="ms-2 me-auto w-100 ">
                    <div class="row">
                    <cfset fielditemcount++ >
                     <cf_block_field fields="#fieldset#" />
                    </div>
                    </div>
                    </li>
                </cfloop>
                </ol>
            </fieldset>
        </cfif> <!--- array or simple field --->


    </cfloop>
<input type="hidden" name="#attributes.blockPrefix#_fieldcount" value="#fieldcount#"/>
</cfoutput>
</cfif>