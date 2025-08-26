<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.aliasFromSetting" default="" />

<cfif thisTag.executionmode is "start">
	<cfset ancestorlist = getbasetaglist() />

	<cfif listfindnocase(ancestorlist,"cf_authors")>
		<cfset data = GetBaseTagData("cf_authors")/> 
		<cfset currentAuthor = data.currentAuthor />
	<cfelseif listfindnocase(ancestorlist,"cf_post")>
		<cfset data = GetBaseTagData("cf_post")/> 
		<cfset authorId = data.currentPost.getAuthorId()>
		<cfset currentAuthor = request.blogManager.getAuthorsManager().getAuthorById(authorId) />
	<cfelseif len( attributes.aliasFromSetting )>
		<cfset data = getBaseTagData("cf_setting") />
		<cfif structKeyExists( data.currentSetting, attributes.aliasFromSetting )>
			<cfset currentAuthor = request.blogManager.getAuthorsManager().getAuthorByAlias( data.currentSetting[ attributes.aliasFromSetting ] ) />
			<cfif currentAuthor.getId() EQ "">
				<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
			</cfif>
		</cfif>

	<cfelse>
		<cfset currentAuthor = request.blogManager.getAuthorsManager().getAuthorByAlias(request.externalData.authorAlias) />
	</cfif>

</cfif>

<cfsetting enablecfoutputonly="false">