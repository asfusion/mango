<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" default="false">
<cfparam name="attributes.title" default="false">
<cfparam name="attributes.body" default="false">
<cfparam name="attributes.name" default="false">
<cfparam name="attributes.author" default="false">
<cfparam name="attributes.commentcount" default="false">
<cfparam name="attributes.link" default="false">
<cfparam name="attributes.excerpt" default="false">
<cfparam name="attributes.customfield" default="">
<cfparam name="attributes.sortOrder" default="false">
<cfparam name="attributes.ifcommentsallowed" default="false">
<cfparam name="attributes.ifnotcommentsallowed" default="false">
<cfparam name="attributes.format" default="default">
<cfparam name="attributes.includeBasePath" default="true">
<cfparam name="attributes.ifiscurrentpage" default="false">
<cfparam name="attributes.ifisnotcurrentpage" default="false">
<cfparam name="attributes.ifIsAncestorOfCurrentPage" default="false">
<cfparam name="attributes.ifIsNotAncestorOfCurrentPage" default="false">
<cfparam name="attributes.ifIsChildOfCurrentPage" default="false">
<cfparam name="attributes.ifhasExcerpt" default="false">
<cfparam name="attributes.ifnothasExcerpt" default="false">
<cfparam name="attributes.ifHasParent" default="false">
<cfparam name="attributes.ifNotHasParent" default="false">
<cfparam name="attributes.ifCommentCountGT" type="string" default="">
<cfparam name="attributes.ifCommentCountLT" type="string" default="">
<cfparam name="attributes.ifHasCustomField" type="string" default="">
<cfparam name="attributes.ifNotHasCustomField" type="string" default="">

<cfif thisTag.executionmode is 'start'>
<cfif attributes.format EQ "default">
	<cfif attributes.body OR attributes.excerpt OR attributes.link>
		<cfset attributes.format = 'plain' />
	<cfelse>
		<cfset attributes.format = 'escapedHtml' />
	</cfif>
</cfif>

	<cfset data = GetBaseTagData("cf_page",1)/>
	<cfset currentPage = data.currentPage />
	<cfset prop = "" />
	
	<cfif attributes.ifiscurrentpage>
		<cfif NOT structkeyexists(request.externalData,"pageName") OR request.externalData.pageName NEQ currentPage.getName()>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifisnotcurrentpage>
		<cfif structkeyexists(request.externalData,"pageName") AND request.externalData.pageName EQ currentPage.getName()>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifIsAncestorOfCurrentPage>
		<cfif structkeyexists(request.externalData,"pageName")>
			<cftry>
				<cfset isAuthor = structkeyexists(request.externalData,"preview") and request.blogManager.isCurrentUserLoggedIn() />
				<cfif structkeyexists(request.externalData,"preview") and isValid("UUID",request.externalData.pageName)>
					<cfset parents = request.blogManager.getPagesManager().getPageById(request.externalData.pageName,isAuthor,true).getHierarchy() />
				<cfelse>
					<cfset parents = request.blogManager.getPagesManager().getPageByName(request.externalData.pageName,isAuthor,true).getHierarchy() />
				</cfif>
			<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<cfif NOT structkeyexists(request.externalData,"pageName") OR NOT listfind(parents,currentPage.getId(),"/")>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>

	<cfif attributes.ifIsNotAncestorOfCurrentPage>
		<cfif structkeyexists(request.externalData,"pageName")>
			<cftry>
				<cfset isAuthor = structkeyexists(request.externalData,"preview") and request.blogManager.isCurrentUserLoggedIn() />
				<cfif structkeyexists(request.externalData,"preview") and isValid("UUID",request.externalData.pageName)>
					<cfset parents = request.blogManager.getPagesManager().getPageById(request.externalData.pageName,isAuthor,true).getHierarchy() />
				<cfelse>
					<cfset parents = request.blogManager.getPagesManager().getPageByName(request.externalData.pageName,isAuthor,true).getHierarchy() />
				</cfif>
			<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>			
		<cfif NOT structkeyexists(request.externalData,"pageName") OR listfind(parents,currentPage.getId(),"/")>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifIsChildOfCurrentPage>
		<cfif structkeyexists(request.externalData,"pageName")>
			<cftry>
				<cfset isAuthor = structkeyexists(request.externalData,"preview") and request.blogManager.isCurrentUserLoggedIn() />
				<cfif structkeyexists(request.externalData,"preview") and isValid("UUID",request.externalData.pageName)>
					<cfset parents = request.blogManager.getPagesManager().getPageById(request.externalData.pageName,isAuthor,true).getId() />
				<cfelse>
					<cfset parents = request.blogManager.getPagesManager().getPageByName(request.externalData.pageName,isAuthor,true).getId() />
				</cfif>
			<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>			
		<cfif NOT structkeyexists(request.externalData,"pageName") OR currentPage.getParentPageId() NEQ parents>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>	
	
	<cfif attributes.ifcommentsallowed>
		<cfif NOT currentPage.getCommentsAllowed()>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifnotcommentsallowed>
		<cfif currentPage.getCommentsAllowed()>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifhasExcerpt>
		<cfif NOT len(currentPage.getExcerpt())>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifnothasExcerpt>
		<cfif len(currentPage.getExcerpt())>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifHasParent>
		<cfif NOT len(currentPage.getParentPageId())>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifNotHasParent>
		<cfif len(currentPage.getParentPageId())>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif len(attributes.ifCommentCountGT) AND currentPage.getCommentCount() LTE attributes.ifCommentCountGT>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif len(attributes.ifCommentCountLT) AND currentPage.getCommentCount() GTE attributes.ifCommentCountLT>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif len(attributes.ifHasCustomField)>
		<cfif NOT currentPage.customFieldExists(attributes.ifHasCustomField)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif len(attributes.ifNotHasCustomField) AND currentPage.customFieldExists(attributes.ifNotHasCustomField)>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	 <cfif attributes.title>
		<cfset prop = currentPage.getTitle() />
	</cfif>
	
	<cfif attributes.body>		
		<cfset prop = currentPage.getContent() />
	</cfif>

	<cfif attributes.author>		
		<cfset prop = currentPage.getAuthor() />
	</cfif>
	
	<cfif attributes.name>		
		<cfset prop = currentPage.getName() />
	</cfif>
	
	<cfif attributes.commentcount>
		<cfset prop = currentPage.getCommentCount() />
	</cfif>
	
	<cfif attributes.id>
		<cfset prop = currentPage.getId() />
	</cfif>
	
	<cfif attributes.excerpt>
		<cfset prop = currentPage.getExcerpt() />
	</cfif>
	
	<cfif attributes.sortOrder>
		<cfset prop = currentPage.getSortOrder() />
	</cfif>
	
	<cfif attributes.link>
		<cfset prop = currentPage.getUrl() />
		<cfif attributes.includeBasePath>
			<cfif NOT structkeyexists(request, "blog_basepath")>
				<cfif NOT structkeyexists(request,"blog")>
					<cfset request.blog = request.blogManager.getBlog()/>
				</cfif>
				<cfset request.blog_basepath = request.blog.getBasePath() />
			</cfif>
			<cfset prop = request.blog_basepath & prop/>
		</cfif>
	</cfif>
	
	<cfif len(attributes.customfield)>
		<cfif currentPage.customFieldExists(attributes.customfield)>
		<cfset prop = currentPage.getCustomField(attributes.customfield).value />
		</cfif>
	</cfif>
	<cfif attributes.format EQ "xml">
		<cfset prop = xmlformat(prop) />
	<cfelseif attributes.format EQ "escapedHtml">
		<cfset prop = htmleditformat(prop)>
	</cfif>
	<cfoutput>#prop#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">