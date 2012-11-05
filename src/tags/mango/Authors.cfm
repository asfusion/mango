<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.from" type="numeric" default="1">
<cfparam name="attributes.count" type="numeric" default="-1">

<!--- starting tag --->
<cfif thisTag.executionMode EQ "start">
	<cfset recordsFrom = attributes.from />
	
	<cfset authors = request.blogManager.getAuthorsManager().getAuthors() />
	 <cfif attributes.count EQ -1>
		<cfset attributes.count = arraylen(authors) />
	</cfif>
	
	<cfset to = attributes.count>

	<cfset counter = 1>	
	<cfif counter LTE to AND counter LTE arraylen(authors)>
		<cfset currentAuthor = authors[counter]>
	<cfelse>
		<cfsetting enablecfoutputonly="false">
		 <cfexit>
	</cfif>
 </cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
  <cfset counter = counter + 1>
   <cfif counter LTE to AND counter LTE arraylen(authors)>
	<cfset currentAuthor = authors[counter]><cfsetting enablecfoutputonly="false">
      <cfexit method="loop">
   </cfif>
   
</cfif>
<cfsetting enablecfoutputonly="false">