<cfimport prefix="mangoAdmin" taglib="tags">
<cfparam name="page" default="#request.message.getTitle()#">
<cfif structkeyexists(request.externaldata,"owner")><cfset page = request.externaldata.owner />
</cfif>
<cf_layout page="#page#" title="#page#">
<div id="wrapper">

	<div id="submenucontainer">
		<ul id="submenu">
			<mangoAdmin:MenuEvent />
		</ul>
	</div>
	
	<div id="content">
		<h2 class="pageTitle"><mangoAdmin:Message title /></h2>
		
		<div id="innercontent">
		<cfoutput>
			<mangoAdmin:Message ifMessageExists type="generic" status="error">
				<p class="error"><mangoAdmin:Message text /></p>
			</mangoAdmin:Message>
			<mangoAdmin:Message ifMessageExists type="generic" status="success">
				<p class="message"><mangoAdmin:Message text /></p>
			</mangoAdmin:Message>

			<mangoAdmin:Message data />
		</cfoutput>
		</div>
	</div>
</div>
</cf_layout>