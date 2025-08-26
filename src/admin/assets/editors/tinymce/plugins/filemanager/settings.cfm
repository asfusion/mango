<cfsilent>
    <cfset blog = request.blogManager.getBlog() />
    <cfset assetsSettings = blog.getSetting('assets') />
    <cfset host = blog.getUrl() />
    <cfset basePath = blog.getBasePath() />

    <cfif findnocase(basePath,host)>
        <cfset host = left(host,len(host) - len(basePath)) />
    </cfif>
    <cfif find("/", assetsSettings.path) EQ 1>
<!--- absolute path, prepend only domain --->
        <cfset fileUrl = host & assetsSettings.path />
    <cfelseif find("http",assetsSettings.path) EQ 1>
        <cfset fileUrl = assetsSettings.path />
        <cfif right( fileUrl, 1 ) EQ '/'>
            <cfset fileUrl = left( fileUrl, len( fileUrl ) - 1 )>
        </cfif>
    <cfelse>
        <cfset fileUrl = blog.getUrl() & assetsSettings.path />
    </cfif>

<!--- absolute path to User's File storage folder  --->
<cfset settings.UserFiles 		= assetsSettings.directory />
<!--- URL to user's file storage folder            --->
<cfset settings.UserFilesURL	= fileUrl />
<!--- image size for thubnail images    --->
<cfset settings.thumbSize		= 120>
<!--- image size for medium size images --->
<cfset settings.middleSize		= 250>
<!--- Permision for linux               --->
<cfset settings.chomd			= "777">
<!--- disallowed file types             --->
<cfset settings.disfiles		= "cfc,exe,php,asp">
</cfsilent>