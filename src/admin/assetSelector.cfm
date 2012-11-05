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
<cfelse>
	<cfset fileUrl = blog.getUrl() & assetsSettings.path />
</cfif>

<cfparam name="url.initialPath" default="/"/>
<cfif left(url.initialPath, len(fileUrl)) eq fileUrl>
	<cfset url.initialPath = right(url.initialPath, len(url.initialPath)-len(fileUrl))/>
	<!---<cfif findnocase('/',url.initialPath) NEQ 1>
		<cfset url.initialPath = "/" & url.initialPath />
	</cfif>--->
</cfif>
<!--- white-list the valid characters -- valid url characters: [space], a-z, 0-9, $&+,/:;=?@ --->
<cfset url.initialPath = urlEncodedFormat(rereplaceNoCase(url.initialPath, "[^a-z0-9 \$\&\+\,\/\:\;\=\?\@]", "", "all")) />

<script type="text/javascript">
	var mango = mango || {}; mango.baseURLAssets = <cfoutput>'#fileurl#'</cfoutput>;
	var FileBrowserDialogue = {
	    selectFile : function (file) {
			if (file.indexOf('/') == 0){
				file = file.substring(1);//drop the first character
			}
	        var URL = mango.baseURLAssets + file;
	        //now set the input value to the selected URL
			mango.assetSelectorCallback(URL);
	    }
	}
</script>

<div id="flashWidget" style="height: 100%;">
<cfoutput>
	<object id="assetSelectorLite" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" height="98%">
	<param name="movie" value="assets/swfs/AssetSelector.swf" />
	<param name="bgcolor" value="##FFFFFF" />
	<param name="flashvars" value="path=#blog.getSetting('urls').admin#com/asfusion/&initialPath=#url.initialPath#" />
	<!--[if !IE]>-->
	<object type="application/x-shockwave-flash" data="assets/swfs/AssetSelector.swf?path=#urlEncodedFormat('#blog.getSetting('urls').admin#com/asfusion/')#" width="100%" height="98%">
		<param name="bgcolor" value="##FFFFFF" />
		<param name="flashvars" value="path=#urlEncodedFormat('#blog.getSetting('urls').admin#com/asfusion/')#&initialPath=#url.initialPath#" />
	<!--<![endif]-->
	<div>
		<p><strong>In order to use the File Explorer, you need Flash Player 9+ support!</strong></p>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p>
	</div>
	<!--[if !IE]>-->
	</object>
	<!--<![endif]-->
</object>
</cfoutput>
</div>