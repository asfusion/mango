	<cfparam name="url.action" default="getDownloads">
	<cfparam name="url.skin" default="">
	<cfsetting enablecfoutputonly="yes" showdebugoutput="false">
	<cfset outputData = [] />

<cfif url.action EQ "getDownloads">
	<cfset currentSkins = request.administrator.getSkins() />
	<cfset currentSkinsList = "">
	<cfloop from="1" to="#arraylen(currentSkins)#" index="i">
		<cfset currentSkinsList = listappend(currentSkinsList, currentSkins[i].id)>
	</cfloop>
		<cfset downloadableSkins = [] />
		<cfset skins = [] />
		<cftry>
			<cfhttp url="https://services.mangoblog.org/skins/?engineVersion=#request.blogManager.getVersion()#" method="get" result="result" charset="utf-8" />
			<cfset content = result.filecontent>
			<cfset data = deserializeJSON( content ) />
			<cfset skins = data.data />
			<cfcatch type="any"><cfoutput>#serializeJSON( cfcatch )#</cfoutput></cfcatch>
		</cftry>

		<cfloop from="1" to="#arraylen(skins)#" index="i"><!--- discard those we already have --->
			<cfif NOT listfind(currentSkinsList, skins[i].id)>
				<cfset arrayAppend( downloadableSkins, skins[ i ])>
			</cfif>
		</cfloop>
	<cfset outputData = downloadableSkins />

<cfelseif url.action EQ "checkUpdates" AND len(url.skin)>
	<cftry>
	<cfset skinInfo = request.administrator.getSkin(url.skin) />
		<cftry>
			<cfhttp url="https://services.mangoblog.org/skins/#url.skin#/updates?engineVersion=#request.blogManager.getVersion()#&skinVersion=#skinInfo.version#" method="get" result="result" charset="utf-8" />
			<cfset content = result.filecontent>
			<cfset data = deserializeJSON( content ) />
			<cfset updateInfo = data.data />
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfset outputData = updateInfo />

	<cfcatch type="any"></cfcatch>
	</cftry>
</cfif>

	<!--- Send the headers--->
	<cfheader name="Content-type" value="text/xml">
	<cfheader name="Pragma" value="public">
	<cfheader name="Cache-control" value="private">
	<cfheader name="Expires" value="-1">
	<cfsetting enablecfoutputonly="no">
	<cfcontent reset="true" />
	<cfoutput>#serializeJSON( outputData )#</cfoutput>