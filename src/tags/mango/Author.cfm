<cfsetting enablecfoutputonly="true">

<cfif thisTag.executionmode is "start">
	<cfset ancestorlist = getbasetaglist() />

	<cfif listfindnocase(ancestorlist,"cf_authors")>
		<cfset data = GetBaseTagData("cf_authors")/> 
		<cfset currentAuthor = data.currentAuthor />
	<cfelseif listfindnocase(ancestorlist,"cf_post")>
		<cfset data = GetBaseTagData("cf_post")/> 
		<cfset authorId = data.currentPost.getAuthorId()>
		<cfset currentAuthor = request.blogManager.getAuthorsManager().getAuthorById(authorId) />
	<cfelse>
		<cfset currentAuthor = request.blogManager.getAuthorsManager().getAuthorByAlias(request.externalData.authorAlias) />
	</cfif>

</cfif>

<cfsetting enablecfoutputonly="false">