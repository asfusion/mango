<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.size" default="80">
<cfparam name="attributes.rating" default="R">
<cfparam name="attributes.defaultimg" default="">
<cfparam name="attributes.border" default="">
<cfparam name="attributes.imgtag" default="true">
<cfparam name="attributes.class" default="">

<cfif thisTag.executionmode is 'start'>
	<cfset ancestorlist = getbasetaglist() />
	
	<cfset name = '' />
	<cfset email = '' />
	<cfset blog = request.blogManager.getBlog() />
	<cfset gravatar_class = "" />
	
	<cfif listfindnocase(ancestorlist,"cf_comments")>
		<cfset gravatar_data = GetBaseTagData("cf_comments")/>
		<cfset gravatar_currentComment = gravatar_data.currentComment />
		<cfset name = gravatar_currentComment.getCreatorName() />
		<cfset email = gravatar_currentComment.getCreatorEmail() />
	
	<cfelseif listfindnocase(ancestorlist,"cf_post")>
		<!--- use post author --->
		<cfset gravatar_data = GetBaseTagData("cf_post")/>
		<cfset name = gravatar_data.currentPost.getAuthor() />
		<cfset gravatar_currentAuthorID = gravatar_data.currentPost.getAuthorID() />
		<cfset email = request.blogManager.getAuthorsManager().getAuthorById(gravatar_currentAuthorID).email />
	<cfelseif listfindnocase(ancestorlist,"cf_author")>
		<!--- use post author --->
		<cfset gravatar_data = GetBaseTagData("cf_author")/>
		<cfset author = gravatar_data.currentAuthor />
		<cfset name = author.getName() />
		<cfset email = author.getEmail() />
	</cfif>
	
	<cfif len(email)>
		<cfset gravatar_url = 
			"http://www.gravatar.com/avatar.php?gravatar_id=#LCase(hash(LCase(email)))#&amp;rating=#attributes.rating#&amp;size=#attributes.size#"/>
		
		<cfif len(attributes.defaultimg)>
			<cfif not findnocase("http://",attributes.defaultimg)>
				<cfset attributes.defaultimg = blog.getUrl() & "skins/#blog.getSkin()#/" & attributes.defaultimg />
			</cfif>
			<cfset gravatar_url = gravatar_url & "&amp;default=" & URLEncodedFormat(attributes.defaultimg) />
		</cfif>
		
		<cfif len(attributes.border)>
			<cfset gravatar_url = gravatar_url & "&amp;border=" & attributes.border />
		</cfif>
			
		<cfif len(attributes.class)>
			<cfset gravatar_class = 'class="#attributes.class#"'/>
		</cfif>
		
		<cfif attributes.imgtag>
			<cfoutput><img alt="#name#" src="#gravatar_url#" title="#name#" width="#attributes.size#"  height="#attributes.size#" #gravatar_class# /></cfoutput>		
		<cfelse>
			<cfoutput>#gravatar_url#</cfoutput>
		</cfif>
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false">