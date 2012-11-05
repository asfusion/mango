	<cfparam name="url.action" default="getDownloads">
	<cfparam name="url.skin" default="">
	<cfsetting enablecfoutputonly="yes" showdebugoutput="false">
<cfif url.action EQ "getDownloads">
<cfset currentSkins = request.administrator.getSkins() />
<cfset currentSkinsList = "">
<cfloop from="1" to="#arraylen(currentSkins)#" index="i">
	<cfset currentSkinsList = listappend(currentSkinsList, currentSkins[i].id)>
</cfloop>
<cfinvoke webservice="http://www.mangoblog.org/services/Update.cfc?wsdl" method="getSkins" timeout="5" returnvariable="skins"><cfinvokeargument name="version" value="#request.blogManager.getVersion()#"></cfinvoke>

<!--- Send the headers --->
<cfheader name="Content-type" value="text/xml">
<cfheader name="Pragma" value="public">
<cfheader name="Cache-control" value="private">
<cfheader name="Expires" value="-1">
<cfsetting enablecfoutputonly="no">
<cfcontent reset="true" />
<skins>
	<cfloop from="1" to="#arraylen(skins)#" index="i"><!--- discard those we already have --->
	<cfif NOT listfind(currentSkinsList, skins[i].id)>
	<cfoutput><skin>
		<id>#skins[i].id#</id>
		<name><![CDATA[#skins[i].name#]]></name>
		<thumbnail><![CDATA[#skins[i].thumbnail#]]></thumbnail>
		<description><![CDATA[#skins[i].description#]]></description>
	</skin></cfoutput></cfif>
    </cfloop>
</skins>
<cfelseif url.action EQ "checkUpdates" AND len(url.skin)>
	<cftry>
	<cfset skinInfo = request.administrator.getSkin(url.skin) />
	<cfinvoke webservice="http://www.mangoblog.org/services/Update.cfc?wsdl" method="getSkinUpdatedInformation" timeout="5" returnvariable="updateInfo">
		<cfinvokeargument name="skin" value="#url.skin#">
		<cfinvokeargument name="version" value="#skinInfo.version#">
		<cfinvokeargument name="blogVersion" value="#request.blogManager.getVersion()#">		
	</cfinvoke>
	<cfif updateInfo.updated>
		<cfinvoke webservice="http://www.mangoblog.org/services/Update.cfc?wsdl" method="getSkinInfo" timeout="5" returnvariable="skinInfo">
			<cfinvokeargument name="skin" value="#url.skin#"></cfinvoke>
	</cfif>
	
	<cfoutput><cfcontent reset="true" /><skin><hasupdates><cfif updateInfo.updated>1<cfelse>0</cfif></hasupdates><cfif updateInfo.updated><downloadUrl>#updateInfo.downloadUrl#</downloadUrl></cfif></skin></cfoutput>
	<cfcatch type="any"><skin><hasupdates>0</hasupdates></skin></cfcatch>
	</cftry>
</cfif>