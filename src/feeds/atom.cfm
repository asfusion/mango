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
<cfcontent type="application/atom+xml; charset=utf-8" reset="yes"><?xml version="1.0" encoding="<mango:Blog charset />"?>
<feed xmlns="http://www.w3.org/2005/Atom">
    <title><mango:Blog title format="xml" /></title>
    <link rel="alternate" type="text/html" href="<mango:Blog url format="xml" />" />
    <link rel="self" type="application/atom+xml" href="<mango:Blog atomUrl format="xml" />" />
	<id>tag:<mango:Blog host format="xml" />,<mango:Blog date dateformat="yyyy" format="xml" />:<mango:Blog basePath format="xml" /></id>
    <link rel="service.post" type="application/atom+xml" href="<mango:Blog apiurl format="xml" />" title="<mango:Blog title format="xml" />" />
    <subtitle><mango:Blog description format="xml" /></subtitle>
    <generator uri="http://www.mangoblog.org/">Mango <mango:Blog version /></generator>
<mango:Archive>
<mango:Posts from="1" count="15">
	<mango:Post>
<entry>
    <title><mango:PostProperty title format="xml" /></title>
    <link rel="alternate" type="text/html" href="<mango:Blog url format="xml"/><mango:PostProperty link format="xml" includeBasePath="false" />" />
    <id>urn:uuid:<mango:PostProperty id /></id>
    
    <published><mango:PostProperty date dateformat="yyyy-mm-ddThh:mm:ssZ" /></published>
    <updated><mango:PostProperty datemodified dateformat="yyyy-mm-ddThh:mm:ssZ" /></updated>
    
    <summary><mango:PostProperty excerpt format="xml" /></summary>
    <author>
        <name><mango:PostProperty author format="xml" /></name>
   </author>
    <mango:Categories><mango:Category>
        <category term="<mango:CategoryProperty title format="xml">" /></mango:Category>
	</mango:Categories>
    <content type="html" xml:lang="<mango:Blog languageAbbr format="xml" />" xml:base="<mango:Blog url format="xml">">
        <mango:PostProperty body format="xml" />
    </content>
</entry>
</mango:Post>
</mango:Posts>
</mango:Archive>
</feed>