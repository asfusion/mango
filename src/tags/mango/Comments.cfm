<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.from" type="numeric" default="1">
<cfparam name="attributes.count" type="numeric" default="0">
<cfparam name="attributes.recent" type="boolean" default="false">
<cfparam name="attributes.sortOrder" default="ascending"><!--- or descending --->

<!--- check to see if we are inside a post tag for post-specific comments --->
<cfset ancestorlist = getbasetaglist() />

<!--- starting tag --->
<cfif thisTag.executionMode EQ "start">
	<cfif attributes.sortOrder EQ "ascending">
		<cfset sortBy = "DATE-ASC" />
	<cfelse>
		<cfset sortBy = "DATE-DESC" />
	</cfif>
	
	<cfset counter = 1 />
	
	<cfif NOT attributes.recent AND listfindnocase(ancestorlist,"cf_post")>
		<cfset data = GetBaseTagData("cf_post")/>
		<cfset currentPost = data.currentPost />
		<cfset items = request.blogManager.getCommentsManager().getCommentsByPost(currentPost.getId(), attributes.from, attributes.count, false, true, sortBy)/>
		
	<cfelseif NOT attributes.recent AND listfindnocase(ancestorlist,"cf_page")>
		<cfset data = GetBaseTagData("cf_page")/>
		<cfset currentPage = data.currentPage />
		<cfset items = request.blogManager.getCommentsManager().getCommentsByPost(currentPage.getId(), attributes.from, attributes.count, false, true, sortBy)/>
	<cfelse>
		<cfif attributes.count EQ 0>
			<!--- give a default for recent --->
			<cfset attributes.count = 5 />
		</cfif>
		<!--- since we are possibly getting from than we if the from attribute is not 1, then we need to adjust the counter --->
		<cfset attributes.count = attributes.count + attributes.from - 1>
		<cfset items = request.blogManager.getCommentsManager().getRecentComments(attributes.count)/>
		<cfset counter = attributes.from>
	</cfif>
	
	<cfif attributes.count EQ 0 OR attributes.count GT arraylen(items)>
		<cfset attributes.count = arraylen(items) />
	</cfif>
	<cfset to = attributes.count />
	
	<cfif counter LTE to AND counter LTE arraylen(items)>
		<cfif attributes.sortOrder EQ "ascending" OR NOT attributes.recent>
			<cfset currentComment = items[counter]>
		<cfelse>
			<cfset currentComment = items[to - counter + 1]>
		</cfif>
	<cfelse>
		<cfsetting enablecfoutputonly="false">
		 <cfexit>
	</cfif>
 </cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
    <cfset counter = counter + 1>
	
   <cfif counter LTE to AND counter LTE arraylen(items)>
	<cfif attributes.sortOrder EQ "ascending" OR NOT attributes.recent>
			<cfset currentComment = items[counter]>
		<cfelse>
			<cfset currentComment = items[to - counter + 1]>
		</cfif><cfsetting enablecfoutputonly="false">
      <cfexit method="loop">
   </cfif>
   
</cfif>
<cfsetting enablecfoutputonly="false">