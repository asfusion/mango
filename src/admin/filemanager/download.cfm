<cfsetting showdebugoutput="No">
<cfparam name="url.path" default=""/>
<cfparam name="url.filename" default=""/>
<cfparam name="mimeType" default="application/x-unknown"/>

<cfif len(url.filename)>
	<cftry>
		<cfset filecontent = CreateObject("component", "MainFileExplorer").getInstance().getFileManager().getFile(url.path, url.filename)/>
		
		<!--- method for getting mime type taken from UDF getFileMimeType() at cflib.org --->
		<cfif len(getPageContext().getServletContext().getMimeType(url.filename))>
			<cfset mimeType = getPageContext().getServletContext().getMimeType(url.filename) />
		</cfif>		
			
	<cfcatch type="Any">
		<cfset filecontent = cfcatch.message />
		<cfheader statuscode="404" statustext="Not Found">
	</cfcatch>
	</cftry>
</cfif>

<cfheader name="Content-Disposition" value='inline; filename="#url.filename#"'>
<cfcontent type="#mimeType#" variable="#filecontent#">  