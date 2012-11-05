<cfif structkeyexists(form,"Filedata")>
    <cfset CreateObject("component", "MainFileExplorer").getInstance().getFileManager().uploadFile("Filedata", url.path, form.filename)/>
</cfif>