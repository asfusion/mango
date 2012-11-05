<cfset archiveType = "recent" />
<cfset data = structnew()>
<cfif structkeyexists(request.externalData,"category")>
	<cfset data.name = request.externalData.category />
<cfelseif arraylen(request.externaldata.raw) GT 1 AND request.externaldata.raw[1] EQ "category">
	<cfset data.name = request.externaldata.raw[2] />
</cfif>
<cfif structkeyexists(data,"name") AND listlen(data.name) GT 1>
	<cfset archiveType = "multicategory" />
<cfelseif structkeyexists(data,"name")>
	<cfset archiveType = "category" />
</cfif>
<cfset request.archive = request.blogManager.getArchivesManager().getArchive(archiveType,data)>
<cfsetting showdebugoutput="false">
<cfimport prefix="mango" taglib="../tags/mango">
<cfcontent type="application/rss+xml; charset=utf-8" reset="yes"><?xml version="1.0" encoding="<mango:Blog charset />"?>
<rss version="2.0"  xmlns:atom="http://www.w3.org/2005/Atom">
	<channel>
	<title><mango:Blog title format="xml" /></title>
	<link><mango:Blog url format="xml" /></link>
	<description><mango:Blog description format="xml" /></description>
	<generator>Mango <mango:Blog version /></generator>
	<atom:link href="<mango:Blog rssUrl format='xml' />" rel="self" type="application/rss+xml" />
	<mango:Archive>
	<mango:Posts count="15">	<mango:Post>
      <item>
         <title><mango:PostProperty title format="xml"></title>
         <description><mango:PostProperty body format="xml"></description>
         <link><mango:Blog url format="xml"><mango:PostProperty link format="xml" includeBasePath="false"></link>
         <guid><mango:Blog url format="xml"><mango:PostProperty link format="xml" includeBasePath="false"></guid>
         <mango:Categories><category><mango:Category><mango:CategoryProperty title format="xml"></mango:Category></category></mango:Categories>
         <pubDate><mango:PostProperty date dateformat="utc" /></pubDate>
      </item></mango:Post></mango:Posts>
	</mango:Archive>
   </channel>
</rss>