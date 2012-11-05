<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" default="false">
<cfparam name="attributes.title" default="false">
<cfparam name="attributes.description" default="false">
<cfparam name="attributes.creationDate" default="false">
<cfparam name="attributes.name" default="false">
<cfparam name="attributes.link" default="false">
<cfparam name="attributes.rssUrl" default="false">
<cfparam name="attributes.atomUrl" default="false">
<cfparam name="attributes.postcount" default="false">
<cfparam name="attributes.ifiscurrentcategory" default="false">
<cfparam name="attributes.ifisnotcurrentcategory" default="false">
<cfparam name="attributes.includeBasePath" default="true">
<cfparam name="attributes.format" default="default">

<cfif thisTag.executionmode is 'start'>
<cfif attributes.format EQ "default">
	<cfif attributes.description>
		<cfset attributes.format = 'plain' />
	<cfelse>
		<cfset attributes.format = 'escapedHtml' />
	</cfif>
</cfif>

<cfset data = GetBaseTagData("cf_category")/>
<cfset currentCategory = data.currentCategory />
<cfset prop = "" />

	<cfif attributes.ifiscurrentcategory>
		<cfif NOT structkeyexists(request.externalData,"categoryName") OR request.externalData.categoryName NEQ currentCategory.getName()>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifisnotcurrentcategory>
		<cfif structkeyexists(request.externalData,"categoryName") AND request.externalData.categoryName EQ currentCategory.getName()>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>

<cfif attributes.title>
	<cfset prop = currentCategory.getTitle() />
</cfif>

<cfif attributes.description>
	<cfset prop = currentCategory.getDescription() />
</cfif>

<cfif attributes.creationDate>
	<cfset prop = dateformat(currentCategory.getCreationDate(),attributes.format) />	
</cfif>

<cfif attributes.name>
	<cfset prop = currentCategory.getName() />
</cfif>

<cfif attributes.id>
	<cfset prop = currentCategory.getId() />
</cfif>

<cfif attributes.postcount>
	<cfset prop = currentCategory.getPostCount() />
</cfif>

<cfif attributes.link>
	<cfset prop = currentCategory.getUrl() />
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

<cfif attributes.rssUrl>
	<cfif NOT structkeyexists(request,"blog")>
		<cfset request.blog = request.blogManager.getBlog()/>
	</cfif>
	<cfset prop = request.blog.getUrl() & request.blog.getSetting("rssUrl") />
	<cfif val(request.blog.getSetting("useFriendlyUrls"))>
		<cfset prop = prop &  "/category/#currentCategory.getName()#" />
	<cfelse>
		<cfif NOT findnocase("?",prop)>
			<cfset prop = prop & "?" />
		</cfif>
		<cfset prop = prop & "&amp;category=#currentCategory.getName()#" />
	</cfif>
</cfif>

<cfif attributes.atomUrl>
	<cfif NOT structkeyexists(request,"blog")>
		<cfset request.blog = request.blogManager.getBlog()/>
	</cfif>
	<cfset prop = request.blog.getUrl() & request.blog.getSetting("atomUrl") />
	<cfif val(request.blog.getSetting("useFriendlyUrls"))>
		<cfset prop = prop &  "/category/#currentCategory.getName()#" />
	<cfelse>
		<cfif NOT findnocase("?",prop)>
			<cfset prop = prop & "?" />
		</cfif>
		<cfset prop = prop & "&amp;category=#currentCategory.getName()#" />
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