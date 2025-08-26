<cfparam name="url.path" default=""/>
<cfparam name="url.file" default=""/>
<cftry>
<cfset filecontent = CreateObject("component", "MainFileExplorer").getInstance().getFileManager().getThumbnail(url.path, url.file, true) />
<cfheader name="Content-Disposition" value='inline; filename="#url.file#"'>
<cfcontent variable="#filecontent#">
<cfcatch type="any">
	<cflocation addtoken="false" url="assets/filethumbnails/images/default.png">
</cfcatch>
</cftry>