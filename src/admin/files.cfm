<cfhtmlhead text='<script type="text/javascript" src="assets/scripts/swfobject/swfobject.js"></script>
<script type="text/javascript">
	swfobject.registerObject("fileExplorerLite", "9.0.115", "assets/scripts/swfobject/expressInstall.swf");
</script>'>
<!--- 
COPYRIGHT
This version of the File Explorer cannot be used outside MangoBlog
We'll have a commercial version at AsFusion.com that removes the link and can be used 
in any project.
Thanks!
 --->
<cfset currentAuthor = request.blogManager.getCurrentUser() />
<cfset currentBlog = request.blogManager.getBlog() />
<cfset currentRole = currentAuthor.getCurrentRole(currentBlog.getId())/>
<cf_layout page="File Explorer" title="Files">
	 <style type="text/css">
            /* hide from ie on mac \*/
            html {
                height: 100%;
                overflow: hidden;
            }			
			#wrapper {
				height: 90%;
			}			
			#container {
				height: 90%;
			}
            /* end hide */
            body {
                height: 100%;
                margin: 0;
                padding: 0;
                background-color: #FFFFFF;
            }
        </style>
<div id="wrapper">
<cfif listfind(currentRole.permissions, "manage_files")>
	<div id="content">	
		<h2 class="pageTitle">File Explorer</h2>
		
		<cfoutput>
			<object id="fileExplorerLite" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" height="100%">
			<param name="movie" value="assets/swfs/FileExplorerLite.swf" />
			<param name="bgcolor" value="##FFFFFF" />
			<param name="flashvars" value="path=#currentBlog.getSetting('urls').admin#com/asfusion/" />
        	<!--[if !IE]>-->
			<object type="application/x-shockwave-flash" data="assets/swfs/FileExplorerLite.swf" width="100%" height="100%">
				<param name="bgcolor" value="##FFFFFF" />
				<param name="flashvars" value="path=#currentBlog.getSetting('urls').admin#com/asfusion/" />
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
	<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow you to edit files</p>
</div></div>
</cfif>
</div>
</cf_layout>