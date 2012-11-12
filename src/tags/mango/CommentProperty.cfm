<cfsetting enablecfoutputonly="true">
<cfparam name="attributes.id" default="false">
<cfparam name="attributes.name" default="false">
<cfparam name="attributes.email" default="false">
<cfparam name="attributes.url" default="false">
<cfparam name="attributes.parent" default="false">
<cfparam name="attributes.content" default="false">
<cfparam name="attributes.date" default="false">
<cfparam name="attributes.dateformat" default="medium">
<cfparam name="attributes.time" default="false">
<cfparam name="attributes.timeformat" default="short">
<cfparam name="attributes.entryLink" default="false">
<cfparam name="attributes.excerptChars" type="string" default="">
<cfparam name="attributes.ifhasurl" default="false">
<cfparam name="attributes.ifNothasurl" default="false">
<cfparam name="attributes.ifIsAuthor" default="false">
<cfparam name="attributes.ifNotIsAuthor" default="false">
<cfparam name="attributes.ifCurrentIsOdd" type="boolean" default="false">
<cfparam name="attributes.ifCurrentIsEven" type="boolean" default="false">
<cfparam name="attributes.currentCount" default="false">
<cfparam name="attributes.format" default="default">

<cfsilent>
<cfscript>
/**
* An enhanced version of left() that doesn't cut words off in the middle.
* Minor edits by Rob Brooks-Bilson (rbils@amkor.com) and Raymond Camden (rbils@amkor.comray@camdenfamily.com)
* 
* Updates for version 2 include fixes where count was very short, and when count+1 was a space. Done by RCamden.
* 
* @param str      String to be checked. 
* @param count      Number of characters from the left to return. 
* @return Returns a string. 
* @author Marc Esher (rbils@amkor.comray@camdenfamily.comjonnycattt@aol.com) 
* @version 2, April 16, 2002 
*/
function fullLeft(str, count) {
    if (not refind("[[:space:]]", str) or (count gte len(str)))
        return Left(str, count);
    else if(reFind("[[:space:]]",mid(str,count+1,1))) {
         return left(str,count);
    } else { 
        if(count-refind("[[:space:]]", reverse(mid(str,1,count)))) return Left(str, (count-refind("[[:space:]]", reverse(mid(str,1,count))))); 
        else return(left(str,1));
    }
}
</cfscript>
</cfsilent>

<cfif thisTag.executionmode is 'start'>
<cfif attributes.format EQ "default">
	<cfif attributes.content OR attributes.entryLink>
		<cfset attributes.format = 'plain' />
	<cfelse>
		<cfset attributes.format = 'escapedHtml' />
	</cfif>
</cfif>
	<cfset prop = "" />
	<cfset data = GetBaseTagData("cf_comment")/>
	<cfset currentComment = data.currentComment />
	<cfset currentCommentCount = data.currentCommentCount />
	
	<cfif attributes.ifCurrentIsOdd AND NOT currentCommentCount mod 2>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>
	
	<cfif attributes.ifCurrentIsEven AND currentCommentCount mod 2>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
	</cfif>

	<cfif attributes.ifIsAuthor>
		<cfif NOT len(currentComment.getAuthorId())>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifNotIsAuthor>
		<cfif len(currentComment.getAuthorId())>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	
	<cfif attributes.ifhasurl>
		<cfif NOT len(currentComment.getCreatorUrl())>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>
	<cfif attributes.ifNothasurl>
		<cfif len(currentComment.getCreatorUrl())>
			<cfsetting enablecfoutputonly="false"><cfexit method="exittag">
		</cfif>
	</cfif>

<cfif attributes.currentCount>
	<cfset prop = currentCommentCount />	
</cfif>

<cfif attributes.name>
	<cfset prop = currentComment.getCreatorName() />
</cfif>

<cfif attributes.email>
	<cfset prop = currentComment.getCreatorEmail() />
</cfif>

<cfif attributes.content>
	<cfset prop = currentComment.getContent() />
</cfif>

<cfif len(attributes.excerptChars) AND isnumeric(attributes.excerptChars)>
	<cfset excerpt = rereplace(currentComment.getContent(), "<.*?>", "", "all") />
	<cfif len(excerpt) gt attributes.excerptChars>
	<cfset excerpt = fullLeft(excerpt, attributes.excerptChars)>
		<cfset excerpt = excerpt & "...">
	</cfif>
	<cfset prop = excerpt />
</cfif>

<cfif attributes.date>
	<cfset prop = lsdateformat(currentComment.getCreatedOn(),attributes.dateformat) />	
</cfif>

<cfif attributes.time>
	<cfset prop = lstimeformat(currentComment.getCreatedOn(),attributes.timeformat) />	
</cfif>

<cfif attributes.url>
	<cfset prop = currentComment.getCreatorUrl() />
</cfif>

<cfif attributes.entryLink>
	<cfset entry = currentComment.getEntry() />
	<cfif NOT isvalid("string", entry)>
		<cfif NOT structkeyexists(request, "blog_basepath")>
			<cfif NOT structkeyexists(request,"blog")>
				<cfset request.blog = request.blogManager.getBlog()/>
			</cfif>
			<cfset request.blog_basepath = request.blog.getBasePath() />
		</cfif>
		<cfset prop = request.blog_basepath & entry.getUrl() />
	</cfif>	
</cfif>

<cfif attributes.id>
	<cfset prop = currentComment.getId() />
</cfif>

<cfif attributes.parent>
	<cfset prop = currentComment.getParentCommentId() />
</cfif>
<cfif attributes.format EQ "xml">
	<cfset prop = xmlformat(prop) />
<cfelseif attributes.format EQ "escapedHtml">
	<cfset prop = htmleditformat(prop)>
</cfif>
	<cfoutput>#prop#</cfoutput>

</cfif>
<cfsetting enablecfoutputonly="false">