<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.type" type="string" default="month">
<cfparam name="attributes.from" type="numeric" default="1">
<cfparam name="attributes.count" type="numeric" default="-1">

<!--- starting tag --->
<cfif thisTag.executionMode EQ "start">	
	
	<cfswitch expression="#attributes.type#">
			<cfcase value="month">				
				<cfset items = request.blogManager.getArchivesManager().getMonthlyArchives()/>
				<cfset archiveType = "month" />
			</cfcase>
			<cfcase value="year">				
				<cfset items = request.blogManager.getArchivesManager().getYearlyArchives()/>
				<cfset archiveType = "year" />
			</cfcase>
			<cfcase value="day">				
				<cfset items = request.blogManager.getArchivesManager().getDailyArchives()/>
				<cfset archiveType = "day" />
			</cfcase>
		</cfswitch>
		
	 <cfif attributes.count EQ -1>
		<cfset attributes.count = arraylen(items) />
	</cfif>
	
	<cfset to = attributes.count>
	
	<cfset counter = attributes.from>	
	<cfif counter LTE to AND counter LTE arraylen(items)>
		<cfset currentArchive = items[counter]>
	<cfelse>
		<cfsetting enablecfoutputonly="false">
		 <cfexit>
	</cfif>

 </cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
    <cfset counter = counter + 1>
	
   <cfif counter LTE to AND counter LTE arraylen(items)>
	<cfset currentArchive = items[counter]><cfsetting enablecfoutputonly="false">
      <cfexit method="loop">
   </cfif>
   
</cfif>
<cfsetting enablecfoutputonly="false">