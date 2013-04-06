<cfset blog = request.blogManager.getBlog() />
<cfset assetsSettings = blog.getSetting('assets') />
<cfset host = blog.getUrl() />
<cfset basePath = blog.getBasePath() />
<cfset scriptsbasePath = request.blogManager.getBlog().getSetting('urls').admin />
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

<cfcontent reset="true" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!-- 
 * File Explorer plugin cannot be used outside MangoBlog. Please visit asfusion.com 
 * to get a commercial version
 *
 * @author AsFusion
 * @copyright Copyright �2008, AsFusion, All rights reserved.
 * -->
<head>
	<title>File Explorer</title>
	<cfoutput><script type="text/javascript" src="#scriptsbasePath#assets/scripts/swfobject/swfobject.js"></script>
	<script type="text/javascript">
var flashvars = {
  path: "#urlEncodedFormat('#scriptsbasePath#com/asfusion/')#"
};

swfobject.embedSWF("#scriptsbasePath#assets/swfs/AssetSelector.swf", "content", "100%", "100%", "9.0.115","#basepath#assets/scripts/swfobject/expressInstall.swf", flashvars,{bgcolor:"##FFFFFF"});
</script>
<script type="text/javascript">
	var mango = mango || {}; 
	mango.baseURLAssets = <cfoutput>'#fileurl#'</cfoutput>;
	var FileBrowserDialogue = {
	    selectFile : function (file) {
			if (file.indexOf('/') == 0){
				file = file.substring(1);//drop the first character
			}
	        var URL = mango.baseURLAssets + file;
	        //now set the input value to the selected URL
			window.opener.CKEDITOR.tools.callFunction( #CKEditorFuncNum#, URL);
			window.close();
	    }
	}
</script>
</cfoutput>
<style type="text/css">
            /* hide from ie on mac \*/
            html {
                height: 100%;
                overflow: hidden;
            }			
            /* end hide */
            body {
                height: 100%;
                margin: 0;
                padding: 0;
                background-color: #FFFFFF;
            }
        </style>


</head>
<body>
<div id="content">
			<a href="http://www.adobe.com/go/getflashplayer">
				<img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
			</a>
		</div>
</body> 
</html> 
