<cfparam name="attributes.type" default="smalltext"> <!--- text, htmltext, swtich, radio, hidden, image, file/fileUpload --->
<cfparam name="attributes.id" default="" >
<cfparam name="attributes.value" default="">
<cfparam name="attributes.placeholder" default="">
<cfparam name="attributes.size" default="fluid">
<cfparam name="attributes.label" default="">
<cfparam name="attributes.options" default="">
<cfparam name="attributes.hint" default="">
<cfparam name="attributes.required" default="false">
<cfparam name="attributes.checkvalue" default="">

<cfif thisTag.executionmode EQ "start">
<cfif attributes.size EQ "xx-small">
    <cfset size = "-1" >
<cfelseif attributes.size EQ "x-small">
    <cfset size = "-2">
    <cfelseif attributes.size EQ "small">
    <cfset size = "-3">
<cfelseif attributes.size EQ 'medium'>
    <cfset size = "-4">
<cfelseif attributes.size EQ 'large'>
    <cfset size = "-5">
<cfelseif attributes.size EQ 'xlarge'>
    <cfset size = "-6">
<cfelseif isNumeric( attributes.size)>
    <cfset size = '-' & attributes.size />
    <cfelse>
    <cfset size = '' />
</cfif>
<cfoutput>
<cfif attributes.type NEQ "hidden"><div class="mb-3 col#size#"></cfif>

    <cfif attributes.type EQ "smalltext">
        <label for="#attributes.id#">#attributes.label#</label>
        <input class="form-control" id="title" type="#attributes.id#" name="#attributes.id#"
                            value="#htmleditformat( attributes.value )#" placeholder="#attributes.placeholder#" <cfif attributes.required>required</cfif>>
    <cfelseif attributes.type EQ "text" OR attributes.type EQ "htmltext">
        <label for="#attributes.id#">#attributes.label#</label>
        <textarea class="form-control <cfif attributes.type EQ "htmltext">htmlEditor </cfif>" name="#attributes.id#" <cfif attributes.required>required</cfif>>#htmleditformat( attributes.value )#</textarea>

    <cfelseif attributes.type EQ "switch" OR attributes.type EQ "checkbox">
           <div class="form-check <cfif attributes.type EQ "switch">form-switch</cfif>">
              <input value="#htmleditformat( attributes.checkvalue )#" id="#attributes.id#"
                    name="#attributes.id#" <cfif listfind( attributes.value, attributes.checkvalue )>checked="checked"</cfif> class="form-check-input checkbox" type="checkbox" />
                <label class="form-check-label" for="#attributes.id#">#attributes.label#</label>
            </div>
    <cfelseif attributes.type EQ "switchgroup" OR attributes.type EQ "checkboxgroup">
            <label for="title">#attributes.label#</label>
        <cfloop from="1" to="#arraylen(attributes.options)#" index="j">
                <div class="form-check <cfif attributes.type EQ "switch">form-switch</cfif>">
                    <input value="#htmleditformat( attributes.options[j].value )#" id="#attributes.options[j].id#"
                           name="#attributes.options[j].id#" <cfif listfind( attributes.value, attributes.options[j].value )>checked="checked"</cfif> class="form-check-input checkbox" type="checkbox" />
                <label class="form-check-label" for="#attributes.options[j].id#">#attributes.options[j].label#</label>
            </div>
        </cfloop>
    <cfelseif attributes.type EQ "singlechoice" OR attributes.type EQ "radio" OR attributes.type EQ "dropdown">

        <cfif ( arraylen( attributes.options ) LTE 2 AND attributes.type NEQ "dropdown" ) OR attributes.type EQ "radio">
            <fieldset>
                <legend class="h6">#attributes.label#</legend>
            <cfloop from="1" to="#arraylen(attributes.options)#" index="j">
                <input class="form-check-input" type="radio" name="#attributes.id#" id="#attributes.id#_#j#" value="#htmleditformat( attributes.options[j].id )#" <cfif attributes.options[j].id EQ attributes.value>checked</cfif>>
                <label class="form-check-label" for="#attributes.id#_#j#">#attributes.options[j].label#</label>
            </cfloop>
                </fieldset>
        <cfelse>
            <label for="#attributes.id#">#attributes.label#</label>
            <select class="form-select" name="#attributes.id#" id="#attributes.id#">
            <option value=""></option>
            <cfloop from="1" to="#arraylen(attributes.options)#" index="j">
                    <option value="#htmleditformat( attributes.options[j].id )#" <cfif attributes.options[j].id EQ attributes.value>selected="selected"</cfif>>#attributes.options[j].label#</option>
            </cfloop>
            </select>
        </cfif>

        <!--- asset selector --->
   <cfelseif attributes.type EQ "assetSelector" OR attributes.type EQ "asset">
        <label for="#attributes.id#">#attributes.label#</label>
        <div class="input-group">
            <input type="text" class="form-control assetSelector" name="#attributes.id#" id="#attributes.id#" value="#htmleditformat( attributes.value )#" placeholder="" <cfif attributes.required>required</cfif>>
        </div>

     <cfelseif attributes.type EQ "hidden">
           <input type="hidden" name="#attributes.id#" value="#htmleditformat( attributes.value )#" />
    </cfif>
    <cfif len( attributes.hint )>
        <small class="form-text text-muted">#attributes.hint#</small>
    </cfif>
    <cfif attributes.type NEQ "hidden"></div></cfif>
</cfoutput>
</cfif>