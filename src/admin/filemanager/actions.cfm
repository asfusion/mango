<cfset explorer = request.blogManager.getFileManager()>
<cfset result = { 'status' = false } />
<cfif url.action EQ "DELETE">
    <cfset result = serializeJSON( explorer.removeFile( form.path, form.name )) />
</cfif>
<cfif url.action EQ "UPLOAD">
    <cfset result = serializeJSON( explorer.uploadFile("file", url.path, form.filename)) />
</cfif>
<cfif url.action EQ "FILES">
    <cfset result = explorer.getFiles( url.path, 'JSON' )/>
</cfif>
<cfif url.action EQ "DIRECTORIES">
    <cfset result = explorer.getDirectories( url.path, false, 'JSON' ) />
</cfif>
<cfif url.action EQ "CREATE_DIR">
    <cfset result = serializeJSON( explorer.createFolder( form.path, form.name )) />
</cfif>
<cfif url.action EQ "DELETE_DIR">
    <cfset result = serializeJSON( explorer.removeFolder( form.path )) />
</cfif>
<cfif url.action EQ "RENAME_DIR">
    <cfset result = serializeJSON( explorer.renameFolder( form.path, form.name, form.newname )) />
</cfif>
<cfcontent reset="true">
<cfoutput>#result#</cfoutput>