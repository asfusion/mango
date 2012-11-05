<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.ifIsLoggedIn" type="boolean" default="false">
<cfparam name="attributes.ifNotIsLoggedIn" type="boolean" default="false">

<cfif thisTag.executionmode is 'start'>
	<cfset isLoggedIn = request.blogManager.isCurrentUserLoggedIn() />
	
	<cfif attributes.ifIsLoggedIn AND NOT isLoggedIn>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifNotIsLoggedIn AND isLoggedIn>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif isLoggedIn>
		<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfelse>
		<!--- just so that this does not give an error --->
		<cfset currentAuthor = request.blogManager.getObjectFactory().createAuthor() />
	</cfif>
	
</cfif>
<cfsetting enablecfoutputonly="false">