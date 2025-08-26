<cfimport prefix="mangoAdmin" taglib="tags">
<cfparam name="page" default="">
<cfparam name="title" default="#request.message.getTitle()#">
<cfif structkeyexists(request.externaldata,"owner")>
	<cfset page = request.externaldata.owner />
</cfif>
<cfset breadcrumb = request.message.getHierarchy() />
<cf_layout page="#page#" title="#title#" hierarchy="#breadcrumb#">
	<mangoAdmin:SecondaryMenuEvent />
	<!-- END INNER NAV IF NEEDED -->
	<h4 class="h4"><mangoAdmin:Message title /></h4>
	<cfoutput>
		<mangoAdmin:Message ifMessageExists type="generic" status="success">
			<div class="alert alert-success" role="alert"><mangoAdmin:Message text /></div>
		</mangoAdmin:Message>
		<mangoAdmin:Message ifMessageExists type="generic" status="error">
			<div class="alert alert-danger" role="alert"><mangoAdmin:Message text /></div>
		</mangoAdmin:Message>

		<mangoAdmin:Message data />
	</cfoutput>
</cf_layout>