<cfif NOT structkeyexists(request,"archivesTemplate")>
	<cfset request.archivesTemplate = "archives.cfm" />
</cfif>
<cfset blog = request.blogManager.getBlog() />
<cfset request.skin = blog.getSkin() />

<!--- @TODO redo this file, it looks really nasty :( --->
<cfset data = structnew()>

<cfif arraylen(request.externaldata.raw)>
	<cfset archiveType = request.externalData.raw[1] />
	
		<cfswitch expression="#archiveType#">
			<cfcase value="category">				
				<cfif arraylen(request.externalData.raw) GTE 2>
					<cfset data.name = request.externalData.raw[2]>
					<cfset request.externalData.categoryName = request.externalData.raw[2] />
					<!--- are there pages? --->
					<cfif arraylen(request.externalData.raw) GTE 3 AND request.externalData.raw[3] EQ "page">
						<cfif arraylen(request.externalData.raw) GTE 4>
							<cfset request.currentPageNumber = request.externalData.raw[4]>
						</cfif>						
					</cfif>
				<cfelse>
					<!--- no category name, just show most recent --->
					<cfset archiveType = "recent" />
				</cfif>
				
			</cfcase>
						
			<cfcase value="date">
				<cfif arraylen(request.externalData.raw) GTE 2>
					
					<!--- year --->
					<cfset data.year = request.externalData.raw[2]>
					
					<cfif arraylen(request.externalData.raw) GTE 3>
						<cfif request.externalData.raw[3] NEQ "page">
							<!--- month --->
							<cfset data.month = request.externalData.raw[3]>
						<cfelse>
							<!--- this is a page --->
							<cfset request.currentPageNumber = request.externalData.raw[4]>
						</cfif>
					</cfif>
					<cfif arraylen(request.externalData.raw) GTE 4>
						<cfif request.externalData.raw[4] NEQ "page">
							<cfset data.day = request.externalData.raw[4]>
						<cfelse>
							<!--- this is a page --->
							<cfset request.currentPageNumber = request.externalData.raw[5]>
						</cfif>
					</cfif>
					<!--- are there pages? --->
					<cfif arraylen(request.externalData.raw) GTE 5 AND request.externalData.raw[5] EQ "page">
						<cfif arraylen(request.externalData.raw) GTE 6>
							<cfset request.currentPageNumber = request.externalData.raw[6]>
						</cfif>						
					</cfif>
					
				<cfelse>
					<!--- no date, just show most recent --->
					<cfset archiveType = "recent" />
				</cfif>
			</cfcase>
						
			<cfcase value="author">
				<cfif arraylen(request.externalData.raw) GTE 2>
					<cfset data.id = request.externalData.raw[2]>
					<!--- are there pages? --->
					<cfif arraylen(request.externalData.raw) GTE 3 AND request.externalData.raw[3] EQ "page">
						<cfif arraylen(request.externalData.raw) GTE 4>
							<cfset request.currentPageNumber = request.externalData.raw[4]>
						</cfif>						
					</cfif>
					
				<cfelse>
					<!--- no author, just show most recent --->
					<cfset archiveType = "recent" />
				</cfif>
			</cfcase>
			
			<cfcase value="search">				
				<!--- check to see if there is term --->
				<cfif structkeyexists(request.externalData,"term")>
					<cfset data.keyword = request.externalData.term />
				<cfelse>
					<!--- look for the term in the second item after search --->
					<cfif arraylen(request.externalData.raw) GTE 2 AND request.externalData.raw[2] NEQ "page">
						<cfset data.keyword = request.externalData.raw[2] />
					</cfif>
				</cfif>
				
				<!--- are there pages? --->
					<cfif arraylen(request.externalData.raw) GTE 3 AND request.externalData.raw[3] EQ "page">
						<cfif arraylen(request.externalData.raw) GTE 4>
							<cfset request.currentPageNumber = request.externalData.raw[4]>
						</cfif>						
					</cfif>
			</cfcase>
			
			<cfdefaultcase>
				<!--- in the case of a page number only (for recent posts --->				
				<cfif isnumeric(archiveType)>
					<cfset request.currentPageNumber = archiveType />
				<cfelseif request.externalData.raw[1] EQ "page" AND arraylen(request.externalData.raw) GTE 2>
					<cfset request.currentPageNumber = val(request.externalData.raw[2])>
				</cfif>
				<cfset archiveType = "recent" />		
			</cfdefaultcase>
			
		</cfswitch>
<cfelse>
		<!--- unknown type --->
	<cfset archiveType = 'unknown' />
</cfif>

<cfif structkeyexists(request.externalData,"category")>
<!--- try to see if maybe the friednly urls are not used and query string is used instead--->
	<cfset archiveType = "category" />
	<cfset data.name = request.externalData.category />

<cfelseif structkeyexists(request.externalData,"term")>
<!--- try to see if maybe the friednly urls are not used and query string is used instead--->
	<cfset archiveType = "search" />
	<cfset termArray = listtoarray(request.externalData.term,"/") />
	<cfif arraylen(termArray) GT 0>
		<cfset data.keyword = termArray[1] />
	</cfif>
	<!--- set pages in case --->
	<cfif arraylen(termArray) GT 2 AND termArray[2] EQ "page">
		<cfset request.currentPageNumber = val(termArray[3])>
	</cfif>
<cfelseif structkeyexists(request.externalData,"author")>
	<cfset archiveType = "author" />
	<cfset data.id = request.externalData.author />
<cfelseif structkeyexists(request.externalData,"date")>
<!--- try to see if maybe the friendly urls are not used and query string is used instead--->
	<cfset archiveType = "date" />
	<cfset dateArray = listtoarray(request.externalData.date,"/")>
	<cfif arraylen(dateArray) AND dateArray[1] EQ "date"><!--- just get rid of this portion --->
		<cfset arraydeleteat(dateArray,1) />
	</cfif>
	<cfif arraylen(dateArray)>
		<!--- year --->
		<cfset data.year = dateArray[1]>
					
		<cfif arraylen(dateArray) GTE 2>
			<cfif dateArray[2] NEQ "page">
				<!--- month --->
				<cfset data.month = dateArray[2]>
			<cfelse>
				<!--- this is a page --->
				<cfset request.currentPageNumber = dateArray[3]>
			</cfif>
		</cfif>
		<cfif arraylen(dateArray) GTE 3>
			<cfif dateArray[3] NEQ "page">
				<cfset data.day = dateArray[3]>
			<cfelse>
				<!--- this is a page --->
				<cfset request.currentPageNumber = dateArray[4]>
			</cfif>
		</cfif>
		<!--- are there pages? --->
		<cfif arraylen(dateArray) GTE 4 AND dateArray[4] EQ "page">
			<cfif arraylen(dateArray) GTE 5>
				<cfset request.currentPageNumber = dateArray[5]>
			</cfif>						
		</cfif>
	</cfif>

</cfif>

<!--- current page might be passed as query string --->
<cfif structkeyexists(request.externalData,"page")>
	<cfset request.currentPageNumber = request.externalData.page />
</cfif>
<cfset request.archive = request.blogManager.getArchivesManager().getArchive(archiveType,data)>
<cfset pluginQueue = request.blogManager.getPluginQueue() />
<cfset pluginQueue.broadcastEvent(pluginQueue.createEvent("beforeArchivesTemplate",request)) />
<cfcontent reset="true" /><cfinclude template="#blog.getSetting('skins').path##request.skin#/#request.archivesTemplate#">