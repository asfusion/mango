<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.from" type="numeric" default="1">
<cfparam name="attributes.count" type="numeric" default="-1">
<cfparam name="attributes.parentPage" type="string" default="-1">
<cfparam name="attributes.ifCountGT" type="string" default="">
<cfparam name="attributes.ifCountLT" type="string" default="">
<cfparam name="attributes.recurse" type="boolean" default="true">
<cfparam name="request.currentPageNumber" default="0">

<!--- starting tag --->
<cfif thisTag.executionMode EQ "start">
	<cfset ancestorlist = listdeleteat(getbasetaglist(),1) />
	<cfif attributes.parentPage EQ "-1">
		<!--- inside a page, just look for children --->
		<cfif listfindnocase(ancestorlist,"cf_page")>
						
			<cfset data = GetBaseTagData("cf_page")/>
			<cfset attributes.parentPage = data.currentPage.getId()  />
		<cfelse>
			<cfset attributes.parentPage = "" />
		</cfif>
	<cfelseif attributes.parentPage EQ "firstParent" AND listfindnocase(ancestorlist,"cf_page")>
		<cfset data = GetBaseTagData("cf_page")/>
		<cfset currentPage = data.currentPage />
		<cfset parents = currentPage.getHierarchy() />
		<cfif len(parents)>
			<cfset attributes.parentPage = listgetat(parents,1,"/") />		
		<cfelse>
			<cfset attributes.parentPage = currentPage.getId() />
		</cfif>
	</cfif>
	
	<cfset pages = request.blogManager.getPagesManager().getPagesByParent(attributes.parentPage) />
	 <cfif attributes.count EQ -1>
		<cfset attributes.count = arraylen(pages) />
	</cfif>

	<cfif len(attributes.ifCountGT)>
		<cfif NOT (arraylen(pages) GT attributes.ifCountGT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif len(attributes.ifCountLT)>
		<cfif NOT (arraylen(pages) LT attributes.ifCountLT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>

	<cfset to = attributes.count>

	<cfset counter = attributes.from />	
	<cfif counter LTE to AND counter LTE arraylen(pages)>
		<cfset currentPage = pages[counter]>
	<cfelse>
		<cfsetting enablecfoutputonly="false"><cfexit>
	</cfif>
 </cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
  <cfset counter = counter + 1>
   <cfif counter LTE to AND counter LTE arraylen(pages)>
	<cfset currentPage = pages[counter]><cfsetting enablecfoutputonly="false"><cfexit method="loop">
   </cfif>
   
</cfif>
<cfsetting enablecfoutputonly="false">