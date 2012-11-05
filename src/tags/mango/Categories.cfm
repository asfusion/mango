<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.from" type="numeric" default="1">
<cfparam name="attributes.ifCountGT" type="string" default="">
<cfparam name="attributes.ifCountLT" type="string" default="">
<cfparam name="attributes.parent" type="string" default="post">
<cfparam name="attributes.loopAtLeastOnce" type="boolean" default="false">

<!--- starting tag --->
<cfif thisTag.executionMode EQ "start">	
	<!--- check to see if we are inside a post tag for post-specific categories --->
	<cfset ancestorlist = getbasetaglist() />

	<cfif attributes.parent EQ "post" AND listfindnocase(ancestorlist,"cf_post")>
		<cfset data = GetBaseTagData("cf_post")/>
		<cfset currentPost = data.currentPost />
		<cfset items = currentPost.getCategories() />

	<cfelse>
		<cfset items = request.blogManager.getCategoriesManager().getCategories()/>
	</cfif>
	
	<cfparam name="attributes.count" type="numeric" default="#arraylen(items)#">
	
	<cfset counter = attributes.from>
	
	<cfif len(attributes.ifCountGT)>
		<cfif NOT (arraylen(items) GT attributes.ifCountGT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif len(attributes.ifCountLT)>
		<cfif NOT (arraylen(items) LT attributes.ifCountLT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfset to = arraylen(items) />
	
	<cfif counter LTE attributes.count AND counter LTE arraylen(items)>
		<cfset currentCategory = items[counter]>
	<cfelseif counter EQ 1 AND attributes.loopAtLeastOnce>
	<cfelse>
		<cfsetting enablecfoutputonly="false"><cfexit>
	</cfif>

 </cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
    <cfset counter = counter + 1>
	
   <cfif counter LTE attributes.count AND counter LTE arraylen(items)>
	<cfset currentCategory = items[counter]><cfsetting enablecfoutputonly="false"><cfexit method="loop">
   </cfif>
   
</cfif>
<cfsetting enablecfoutputonly="false">