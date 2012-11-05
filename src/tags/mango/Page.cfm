<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.name" type="string" default="">
<cfparam name="attributes.ifCurrentIsOdd" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsEven" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsFirst" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsLast" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsNotFirst" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsNotLast" type="boolean" default="false">
<cfparam name="attributes.ifCurrentCountIsMultiple" type="string" default="">

<cfif thisTag.executionmode is "start">
	<cfset ancestorlist = getbasetaglist() />

	<cfif listfindnocase(ancestorlist,"cf_pages")>
		<cfset data = GetBaseTagData("cf_pages")/> 
		<cfset currentPage = data.currentPage />
		<cfset currentItemCount = data.counter />
		<cfset total = data.to />
	<cfelseif listfindnocase(ancestorlist,"cf_parentpages")>
		<cfset data = GetBaseTagData("cf_parentpages")/> 
		<cfset currentPage = data.currentPage />
		<cfset currentItemCount = data.counter />
		<cfset total = data.to />
	<cfelseif len(attributes.name)>
		<cfset currentPage = request.blogManager.getPagesManager().getPageByName(attributes.name) />
		<cfset currentItemCount = 1 />
		<cfset total = 1 />
	<cfelse>
		<!--- this boolean parameter will allow previewing a draft page --->
		<cfset isAuthor = false />
		<cfif structkeyexists(request.externalData,"preview")>
			<cfset isAuthor = request.blogManager.isCurrentUserLoggedIn() />
		</cfif>
		<cfif structkeyexists(request.externalData,"preview") and isValid("UUID",request.externalData.pageName)>
			<cfset currentPage = request.blogManager.getPagesManager().getPageById(request.externalData.pageName,isAuthor,true) />
		<cfelse>
			<cfset currentPage = request.blogManager.getPagesManager().getPageByName(request.externalData.pageName,isAuthor,true) />
		</cfif>
		<cfset currentItemCount = 1 />
		<cfset total = 1 />
	</cfif>
	
	<cfif attributes.ifCurrentIsOdd AND NOT currentItemCount mod 2>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsEven AND currentItemCount mod 2>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsFirst AND currentItemCount NEQ 1>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif len(attributes.ifCurrentCountIsMultiple) AND currentItemCount mod attributes.ifCurrentCountIsMultiple NEQ 0>
		<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsLast AND currentItemCount NEQ total>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsNotFirst AND currentItemCount EQ 1>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsNotLast AND currentItemCount EQ total>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">