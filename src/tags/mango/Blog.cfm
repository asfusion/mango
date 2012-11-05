<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.title" default="false">
<cfparam name="attributes.url" default="false">
<cfparam name="attributes.description" default="false">
<cfparam name="attributes.tagline" default="false">
<cfparam name="attributes.version" default="false">
<cfparam name="attributes.skinurl" default="false">
<cfparam name="attributes.charset" default="false">
<cfparam name="attributes.basePath" default="false">
<cfparam name="attributes.searchUrl" default="false">
<cfparam name="attributes.atomUrl" default="false">
<cfparam name="attributes.rssUrl" default="false">
<cfparam name="attributes.apiUrl" default="false">
<cfparam name="attributes.host" default="false">
<cfparam name="attributes.id" default="false">
<cfparam name="attributes.languageAbbr" default="false">
<cfparam name="attributes.date" default="false">
<cfparam name="attributes.format" default="plain">
<cfparam name="attributes.dateformat" default="mm/dd/yyyy">
<cfparam name="attributes.fullUrl" default="false">
<cfparam name="attributes.descriptionParagraphFormat" default="false">

<cfif thisTag.executionmode is 'start'>
<cfscript>
/**
 * An &quot;enhanced&quot; version of ParagraphFormat.
 * Added replacement of tab with nonbreaking space char, idea by Mark R Andrachek.
 * Rewrite and multiOS support by Nathan Dintenfas.
 * 
 * @param string 	 The string to format. (Required)
 * @return Returns a string. 
 * @author Ben Forta (ben@forta.com) 
 * @version 3, June 26, 2002 
 */
function ParagraphFormat2(str) {
	//first make Windows style into Unix style
	str = replace(str,chr(13)&chr(10),chr(10),"ALL");
	//now make Macintosh style into Unix style
	str = replace(str,chr(13),chr(10),"ALL");
	//now fix tabs
	str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
	//now return the text formatted in HTML
	return replace(str,chr(10),"<br />","ALL");
}

</cfscript>
	<cfif NOT structkeyexists(request,"blog")>
		<cfset request.blog = request.blogManager.getBlog()/>
	</cfif>
	<cfset blog = request.blog />
	<cfset prop = "" />
	
	<cfif attributes.title>
		<cfset prop = blog.getTitle() />
	</cfif>
	
	<cfif attributes.url>
		<cfset prop = blog.getUrl() />	
	</cfif>
	
	<cfif attributes.skinurl>
		<!--- see if some other tag has stored the current blog skin to avoid making a method call  --->
		<cfif NOT structkeyexists(request, "blog_skin")>
			<cfset request.blog_skin = blog.getSkin() />
		</cfif>
		<cfif NOT structkeyexists(request, "blog_skinbaseurl")>
			<cfset request.blog_skinbaseurl = blog.getSetting('skins').url />
		</cfif>
		<cfset prop = "#request.blog_skinbaseurl##request.blog_skin#/" >	
	</cfif>
	
	<cfif attributes.description>
		<cfset prop = blog.getDescription() />
		<cfif attributes.descriptionParagraphFormat>
			<cfset prop = ParagraphFormat2(prop) />
		</cfif>
	</cfif>
	
	<cfif attributes.tagline>
		<cfset prop = blog.getTagline() />
	</cfif>
	
	<cfif attributes.version>
		<cfset prop = request.blogManager.getVersion() />	
	</cfif>
	
	<cfif attributes.charset>
		<cfset prop = blog.getCharset() />
	</cfif>
	
	<cfif attributes.basePath>
		<cfif NOT structkeyexists(request, "blog_basepath")>
			<cfset request.blog_basepath = blog.getBasePath() />
		</cfif>
		<cfset prop = request.blog_basepath />
	</cfif>
	
	<cfif attributes.searchUrl>
		<cfif NOT structkeyexists(request, "blog_basepath")>
			<cfset request.blog_basepath = blog.getBasePath() />
		</cfif>
		<cfset prop = request.blog_basepath & blog.getSetting("searchUrl") />	
	</cfif>
	
	<cfif attributes.atomUrl>

		<cfif findnocase("http", blog.getSetting("atomUrl")) EQ 1>
			<cfset prop = blog.getSetting("atomUrl") />
		<cfelse>
			<cfset prop = blog.getUrl() & blog.getSetting("atomUrl") />
		</cfif>
	
	</cfif>
	
	<cfif attributes.rssUrl>
		<cfif NOT structkeyexists(request, "blog_url")>
			<cfset request.blog_url = blog.getUrl() />
		</cfif>
		<cfif findnocase("http", blog.getSetting("rssUrl")) EQ 1>
			<cfset prop = blog.getSetting("rssUrl") />
		<cfelse>
			<cfset prop = request.blog_url & blog.getSetting("rssUrl") />
		</cfif>
	
	</cfif>
	
	<cfif attributes.apiUrl>
		<cfif NOT structkeyexists(request, "blog_url")>
			<cfset request.blog_url = blog.getUrl() />
		</cfif>
		<cfset prop = request.blog_url & blog.getSetting("apiUrl") />	
	</cfif>
	
	<cfif attributes.languageAbbr>
		<cfset prop = blog.getSetting("language") />	
	</cfif>
	
	<cfif attributes.host>
		<cfset prop = blog.getHost() />	
	</cfif>
	
	<cfif attributes.date>
		<cfset prop = dateformat(now(),attributes.dateformat) />	
	</cfif>
	
	<cfif attributes.id>
		<cfset prop = blog.getId() />	
	</cfif>
	
	<cfif attributes.format EQ "xml">
		<cfoutput>#xmlformat(prop)#</cfoutput>
	<cfelse>
		<cfoutput>#prop#</cfoutput>
	</cfif>
	
	
</cfif>
<cfsetting enablecfoutputonly="false">