<cfsetting enablecfoutputonly="true">
<!--- source attribute has the highest priority, if it is not  --->
<cfparam name="attributes.source" type="string" default="context">
<cfparam name="attributes.from" type="numeric" default="1">
<cfparam name="attributes.count" type="numeric" default="0">
<cfparam name="attributes.categoryName" type="string" default="">
<cfparam name="attributes.categoryMatch" type="string" default="any">
<cfparam name="attributes.day" type="string" default="0">
<cfparam name="attributes.month" type="string" default="0">
<cfparam name="attributes.year" type="string" default="0">
<cfparam name="attributes.author" type="string" default="">
<cfparam name="attributes.keyword" type="string" default="">
<cfparam name="attributes.customField" type="string" default="">
<cfparam name="attributes.customFieldValue" type="string" default="">
<cfparam name="attributes.ifCountGT" type="string" default="">
<cfparam name="attributes.ifCountLT" type="string" default="">
<cfparam name="attributes.loopAtLeastOnce" type="boolean" default="false">
<!--- at this moment only recent posts support the sorting attribute.
Options are: DATE-DESC (default), DATE-ASC, TITLE-ASC, TITLE-DESC, COMMENTCOUNT-DESC,
COMMENTCOUNT-ASC, COMMENTACTIVITY-DESC, COMMENTACTIVITY-ASC --->
<cfparam name="attributes.sortOrder" type="string" default="DATE-DESC">

<cfparam name="request.postContext" default="recent">
<cfparam name="request.currentPageNumber" default="0">

<!--- starting tag --->
<cfif thisTag.executionMode EQ "start">
<cfset source = attributes.source />
<cfset recordsFrom = attributes.from />

	<cfif source EQ "context">
		<!--- find what the context is --->
		<cfset ancestorlist = listdeleteat(getbasetaglist(),1) />

		<!--- inside a specific category --->
		<cfif listfindnocase(ancestorlist,"cf_category")>
			<cfset source = "category"  />
			
			<cfset data = GetBaseTagData("cf_category")/>
			<cfset attributes.categoryName = data.currentCategory.getName() />
		
		<!--- inside a post list (likely used for ifCount GT )  --->
		<cfelseif listfindnocase(ancestorlist,"cf_posts")>
			<cfset data = GetBaseTagData("cf_posts")/>
			<cfset source = "parent" />
			
		<!--- inside an archive  --->
		<cfelseif listfindnocase(ancestorlist,"cf_archive")>
			<cfset data = GetBaseTagData("cf_archive")/>
			
			<cfset source = data.currentArchive.getType()  />			
			
			<!--- check for page number --->
			<cfif request.currentPageNumber NEQ 0>
				<cfset recordsFrom = attributes.from + data.currentArchive.getPageSize() * request.currentPageNumber />
			</cfif>
			
			<cfswitch expression="#source#">
				<cfcase value="category">
					<cfset attributes.categoryName = data.currentArchive.getCategory().getName() />			
				</cfcase>
				<cfcase value="multicategory">
					<cfset attributes.categoryName = data.currentArchive.category />
					<cfset attributes.categoryMatch = data.currentArchive.match />		
				</cfcase>			
				<cfcase value="date">
					<cfset attributes.year = data.currentArchive.getYear() />
					<cfset attributes.month = data.currentArchive.getMonth() />	
					<cfset attributes.day = data.currentArchive.getDay() />	
				</cfcase>
				<cfcase value="author">
					<cfset attributes.author = data.currentArchive.getAuthor().getId() />
				</cfcase>			
				<cfcase value="search">
					<cfset attributes.keyword = data.currentArchive.getKeyword() />
				</cfcase>
			</cfswitch>
		
		<!--- inside an archive  --->
		<cfelseif listfindnocase(ancestorlist,"cf_author")>
			<cfset data = GetBaseTagData("cf_author")/>
			<cfset source = "author"  />
			<cfset attributes.author = data.currentAuthor.getId() />
		<cfelse>
			<cfset source = request.postContext />
		</cfif>
	</cfif>

	<cfswitch expression="#source#">
		<cfcase value="recent">
			<cfset posts = request.blogManager.getPostsManager().getPosts(from=recordsFrom,count=attributes.count,orderBy=attributes.sortOrder)/>		
		</cfcase>
		<cfcase value="category,multicategory">
			<cftry>
			<cfset posts = request.blogManager.getPostsManager().getPostsByCategory(attributes.categoryName,attributes.categoryMatch,recordsFrom,attributes.count)/>
			<cfcatch type="any"><cfset posts = arraynew(1)/></cfcatch>
			</cftry>
		</cfcase>
		<cfcase value="date">
			<cfset posts = request.blogManager.getPostsManager().getPostsByDate(attributes.year,attributes.month, attributes.day,recordsFrom,attributes.count)/>
		</cfcase>
		<cfcase value="author">			
			<cfset posts = request.blogManager.getPostsManager().getPostsByAuthor(attributes.author,recordsFrom,attributes.count)/>
		</cfcase>
		<cfcase value="search">			
			<cfset posts = request.blogManager.getPostsManager().getPostsByKeyword(attributes.keyword,recordsFrom,attributes.count)/>
		</cfcase>
		<cfcase value="customField">			
			<cfset posts = request.blogManager.getPostsManager().getPostsByCustomField(attributes.customField,attributes.customFieldValue,recordsFrom,attributes.count)/>
		</cfcase>
		<cfcase value="parent">			<!---	
			<cfset posts = data.posts />--->
		</cfcase>
	</cfswitch>
	
	<cfif attributes.count EQ 0 OR attributes.count GT arraylen(posts)>
		<cfset attributes.count = arraylen(posts) />
	</cfif>
	
	<cfif len(attributes.ifCountGT)>
		<cfif NOT (arraylen(posts) GT attributes.ifCountGT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif len(attributes.ifCountLT)>
		<cfif NOT (arraylen(posts) LT attributes.ifCountLT)>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfset to = attributes.count>

	<cfset counter = 1>	
	<cfif counter LTE to AND counter LTE arraylen(posts)>
		<cfset currentPost = posts[counter]>
	<cfelseif counter EQ 1 AND attributes.loopAtLeastOnce>
	<cfelse>
		<cfsetting enablecfoutputonly="false"><cfexit>
	</cfif>
 </cfif>

<!--- ending tag --->
<cfif thisTag.executionMode EQ "end">
    <cfset counter = counter + 1>
   <cfif counter LTE to AND counter LTE arraylen(posts)>
	<cfset currentPost = posts[counter]><cfsetting enablecfoutputonly="false"><cfexit method="loop">
   </cfif>
   
</cfif>
<cfsetting enablecfoutputonly="false">