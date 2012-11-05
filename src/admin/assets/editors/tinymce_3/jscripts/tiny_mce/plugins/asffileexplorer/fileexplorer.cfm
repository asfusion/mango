<cfset basePath = request.blogManager.getBlog().getSetting('urls').admin />
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
	<cfoutput><script type="text/javascript" src="#basepath#assets/scripts/swfobject/swfobject.js"></script>
	</cfoutput>
	        <script type="text/javascript">
<cfoutput>
var flashvars = {
  path: "#urlEncodedFormat('#basepath#com/asfusion/')#"
};

swfobject.embedSWF("#basepath#assets/swfs/AssetSelector.swf", "content", "100%", "100%", "9.0.115","#basepath#assets/scripts/swfobject/expressInstall.swf", flashvars,{bgcolor:"##FFFFFF"});
</cfoutput>
</script>
	<script language="javascript" src="../../tiny_mce_popup.js"></script>
	<script language="javascript" >
	var FileBrowserDialogue = {
    init : function () {
        // Here goes your code for setting your custom things onLoad.
    },
    selectFile : function (file) {
  		var baseURLAssets = tinyMCE.activeEditor.getParam('plugin_asffileexplorer_assetsUrl');
  		if (file.indexOf('/') == 0){
				file = file.substring(1);//drop the first character
			}
        var URL = baseURLAssets + file;
        var win = tinyMCEPopup.getWindowArg("window");

        // insert information now
        win.document.getElementById(tinyMCEPopup.getWindowArg("input")).value = URL;

        // for image browsers: update image dimensions
        if (win.ImageDialog){
        	if (win.ImageDialog.getImageData) win.ImageDialog.getImageData();
        	if (win.ImageDialog.showPreviewImage) win.ImageDialog.showPreviewImage(URL);
		}
        // close popup window
        tinyMCEPopup.close();
    }
}

tinyMCEPopup.onInit.add(FileBrowserDialogue.init, FileBrowserDialogue);
	</script>

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
