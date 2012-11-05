<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.path" default="">

<cfif thisTag.executionmode is "start">
	<!--- use default path for themes if nothing was passed --->
	<cfif NOT len(attributes.path) AND structkeyexists(request,"settingtag_defaultpath")>
		<cfset attributes.path = request.settingtag_defaultpath />
	<cfelseif NOT len(attributes.path)>
		<!--- create a new one --->
		<!--- see if some other tag has stored the current blog skin to avoid making a method call  --->
		<cfif NOT structkeyexists(request, "blog_skin")>
			<cfset request.blog_skin = request.blogManager.getBlog().getSkin() >
		</cfif>
		<cfset attributes.path = "theme/" & request.blog_skin />
	</cfif>
	
	<cfset currentSetting = request.blogManager.getSettingsManager().exportSubtreeAsStruct(attributes.path) />
	
</cfif>

<cfsetting enablecfoutputonly="false">