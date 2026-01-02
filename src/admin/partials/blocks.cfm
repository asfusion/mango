<!--- we need an entry and an array of custom form fields --->
<cfparam name="attributes.blocks" default="#arraynew(1)#">
<cfparam name="attributes.startingIndex" default="2">
<cfif thisTag.executionmode EQ "start">
    <cfoutput>
<!--- assign an iternal id to each block --->

        <cfset count = 0 />
        <cfset startOrder = '' />
        <div class="draggable-zone">
        <cfloop array="#attributes.blocks#" item="block">
            <cfset count++>

            <cfset block.__internalid__ = count />
            <cfif NOT structKeyExists( block, 'active' )>
                <cfset block.active = 0 />
            </cfif>
            <cfset blockPrefix = "block_#block.__internalid__#" />

            <input type="hidden" name="block_#block.__internalid__#_id" value="#block.id#"/>
            <!--begin::Card-->
            <div class="card card-bordered mb-2 draggable design-block" data-order-id="#blockPrefix#">
                <div class="card-header border-bottom d-flex align-items-center justify-content-between">
                    <div class="card-title flex-fill align-items-center"><!--- left tools --->
                        <a href="##" class="draggable-handle" data-bs-toggle="tooltip" data-bs-placement="top" title="Drag to re-order"><i class="bi bi-grip-vertical fs-5 px-3"></i></a>
                        <a data-bs-toggle="collapse" href="###blockPrefix#" role="button" aria-expanded="false" aria-controls="#blockPrefix#">
                            <i class="bi bi-chevron-down fs-4 pe-3"></i>
                            <i class="bi bi-chevron-right fs-4 pe-3"></i>
                         </a>
                         <a data-bs-toggle="collapse" href="###blockPrefix#" role="button" aria-expanded="false" aria-controls="#blockPrefix#" class=" flex-fill">
                            <h2 class="card-label fs-5 fw-bold mb-0">#request.i18n.getValue(block.title)#</h2>
                         </a>
                    </div>
                    <!--- right tools --->
                    <div class="card-toolbar align-items-start d-flex align-items-center">
                        <div class="form-check form-switch">
                            <input class="form-check-input" type="checkbox" value="1" id="block_#block.__internalid__#_active"
                                name="block_#block.__internalid__#_active" <cfif block.active EQ 1>checked="checked"</cfif>>
                            <label class="form-check-label mb-0" for="block_#block.__internalid__#_active">Visible </label>
                        </div>
                    <button name="add-block" value="#block.id#*#count#" class="btn btn-primary-outline" data-bs-toggle="tooltip" data-bs-placement="top" title="Add another block of this type"><i class="bi bi-plus-circle fs-5"></i></button>
                    <cfif block.canDelete><button name="remove-block" value="#block.__internalid__#" class="btn btn-primary-outline" data-bs-toggle="tooltip" data-bs-placement="top" title="Delete block"><i class="bi bi-dash-circle fs-5"></i></button>
                    </cfif>
                    </div>
                </div>
                <div class="card-body collapse" id="#blockPrefix#">
                        <!--- start content of block --->
                        <div class="row mb-4">
                            <cfif structKeyExists( block, 'screenshot' )>
                            <div class="mb-3"> <img src="#block.screenshot#" style="max-width: 100%"></div>
                        </cfif>
                        <!--- start fields --->
                        <cf_block_field fields="#block.fields#" blockPrefix="#blockPrefix#">
                        <input type="hidden" name="#blockPrefix#_order" value="#count#"/>
                    </div> <!--- end content of block --->
                </div><!--end::Card-->
           </div><!--end::card-->

            <cfset startOrder = listAppend( startOrder, count )/>
        </cfloop>
        <input type="hidden" name="order" value="#startOrder#"/>
        <input type="hidden" name="block_count" value="#count#"/>
    </cfoutput>
</cfif>