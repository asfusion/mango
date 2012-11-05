<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.from" type="numeric" default="1">
<cfparam name="attributes.count" type="numeric" default="-1">
<cfparam name="attributes.ifCountGT" type="string" default="">
<cfparam name="attributes.ifCountLT" type="string" default="">
<cfparam name="parentlist" type="string" default="" />

<!--- starting tag --->
<cfif thisTag.executionMode EQ "start">
	<cfset recordsFrom = attributes.from />
	
<!---	<cfif attributes.parentPage EQ ""> --->
		<cfset ancestorlist = listdeleteat(getbasetaglist(),1) />
		<!--- inside a page --->
		<cfif listfindnocase(ancestorlist,"cf_page")>
						
			<cfset data = GetBaseTagData("cf_page")/>
			<cfset parentlist = data.currentPage.getHierarchy()  />
		
		<cfelseif listfindnocase(ancestorlist,"cf_pages")>
						
			<cfset data = GetBaseTagData("cf_pages")/>
			<cfset parentlist = data.currentPage.getHierarchy()  />

		</cfif>
<!---	</cfif> --->
	
	<cfif attributes.count EQ -1>
		<cfset attributes.count =  listlen(parentlist,"/") />
	</cfif>
	
	<cfset parentpages = arraynew(1) />
	<cfset page = "" />
	<cfif listlen(parentlist)>
		<cfset manager = request.blogManager.getPagesManager() />
		<cfset i = 0 />
		<cfloop list="#parentlist#" delimiters="/" index="thisParent">
			<cfset i = i + 1 />
			<cfif i GTE attributes.from AND i LTE (attributes.count + attributes.from)>
				<cfset page = manager.getPageById(thisParent) />
				<cfset arrayappend(parentpages,page) />
			</cfif>
		</cfloop>
	</cfif>
 
<!---
	
	<cfif len(attributes.ifCountGT)>
		<cfif NOT arraylen(posts) GT attributes.ifCountGT>
			<cfsetting enablecfoutputonly="false">
			<cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif len(attributes.ifCountLT)>
		<cfif NOT arraylen(posts) LT attributes.ifCountLT>
			<cfsetting enablecfoutputonly="false">
			<cfexit method="exittag">
		</cfif>
	</cfif>
	 --->
	
	<cfset to = attributes.count>

	<cfset counter = 1>	
	<cfif counter LTE to AND counter LTE arraylen(parentpages)>
		<cfset currentPage = parentpages[counter]>
	<cfelse>
		<cfsetting enablecfoutputonly="false">
		 <cfexit>
	</cfif>
 </cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
  <cfset counter = counter + 1>
   <cfif counter LTE to AND counter LTE arraylen(parentpages)>
	<cfset currentPage = parentpages[counter]><cfsetting enablecfoutputonly="false">
      <cfexit method="loop">
   </cfif>
   
</cfif>
<cfsetting enablecfoutputonly="false">