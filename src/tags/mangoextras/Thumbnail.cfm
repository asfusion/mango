<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.src" default="" />
<cfparam name="attributes.width" default="0" />
<cfparam name="attributes.height" default="0" />
<cfparam name="attributes.customField" default="" type="string" />

<cfif thisTag.executionmode is 'start'>
	<cfif NOT structkeyexists(request,"blog")>
		<cfset request.blog = request.blogManager.getBlog()/>
	</cfif>
	<cfif NOT structkeyexists(request, "blog_url")>
		<cfset request.blog_url = request.blog.getUrl() />
	</cfif>
<cfset ancestorlist = getbasetaglist() />
	<cfif len(attributes.src) GT 0 AND findnocase("http", attributes.src) NEQ 1>
		<!--- see if some other tag has stored the current blog skin to avoid making a method call  --->
		<cfif NOT structkeyexists(request, "blog_skin")>
			<cfset request.blog_skin = request.blog.getSkin() />
		</cfif>
		<cfset attributes.src = "#request.blog_url#skins/#request.blog_skin#/#attributes.src#" >	
		
	<cfelseif len(attributes.customField) GT 0>
		<cfif listfindnocase(ancestorlist,"cf_post")>
			<cfset post_data = GetBaseTagData("cf_post")/>
			<cfset post = post_data.currentPost />
		<cfelseif listfindnocase(ancestorlist,"cf_page")>
			<cfset post_data = GetBaseTagData("cf_page")/>
			<cfset post = post_data.currentPage />
		</cfif>
		<cfif post.customFieldExists(attributes.customField)>
			<cfset attributes.src = post.getCustomField(attributes.customField).value />
			<cfif findnocase("http", attributes.src) NEQ 1>
				<!--- add assets path --->
				<cfset attributes.src = request.blog_url & request.blog.getSetting('assets').path & attributes.src />
			</cfif>
		</cfif>
	<cfelseif listfindnocase(ancestorlist,"cf_author")>
		<cfset author_data = GetBaseTagData("cf_author")/>
		<cfset attributes.src = author_data.currentAuthor.getPicture()/>
			<cfif findnocase("http", attributes.src) NEQ 1>
				<!--- add assets path --->
				<cfset attributes.src = request.blog_url & request.blog.getSetting('assets').path & attributes.src />
			</cfif>
	</cfif>
	<cfoutput>#request.blog_url#output.cfm?event=assetManager-getThumb&amp;src=#attributes.src#&amp;w=#attributes.width#&amp;h=#attributes.height#</cfoutput>
</cfif>
<cfsetting enablecfoutputonly="false">