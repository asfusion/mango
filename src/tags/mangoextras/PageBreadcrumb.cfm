<cfsilent>
<cfimport prefix="mango" taglib="../mango">
<cfparam name="attributes.from" type="numeric" default="1">
<cfparam name="attributes.count" type="numeric" default="-1">
<cfparam name="attributes.separator" type="string" default="&gt;">
<cfparam name="attributes.showWhenIsFirstPage" default="false">
</cfsilent>
<cfif thisTag.executionMode EQ "start">
<mango:ParentPages from="#attributes.from#" count="#attributes.count#"><mango:Page><mango:PageProperty><a href="<mango:PageProperty link/>" title="<mango:PageProperty title />"><mango:PageProperty title /></a> <cfoutput>#attributes.separator#</cfoutput></mango:Page></mango:ParentPages> <mango:PageProperty ifHasParent="#NOT attributes.showWhenIsFirstPage#" title />
</cfif>