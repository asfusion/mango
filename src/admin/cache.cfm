<cfhtmlhead text='<script type="text/javascript" src="assets/scripts/swfobject/swfobject.js"></script>
<script type="text/javascript">
	swfobject.registerObject("cacheManager", "9.0.115", "assets/scripts/swfobject/expressInstall.swf");
</script>'>
<cfset currentAuthor = request.blogManager.getCurrentUser() />
<cfset currentBlog = request.blogManager.getBlog() />
<cfset currentRole = currentAuthor.getCurrentRole(currentBlog.getId())/>

<cf_layout page="Cache" title="Cache">
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
	<div id="content">
		<cfif listfind(currentRole.permissions, "manage_system")>
		<h2 class="pageTitle">Cache Manager</h2>
		
		<p>The cache helps make your website faster by remembering the content of your posts and pages. If you would like to remove some entries from memory, click on "Remove this entry" or "Clear All" to remove all posts and pages</p>
		
		<cfoutput>
			<object id="cacheManager" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" height="100%">
			<param name="movie" value="assets/swfs/CacheManager.swf" />
			<param name="bgcolor" value="##FFFFFF" />
			<param name="flashvars" value="username=&amp;password=" />
        	<!--[if !IE]>-->
			<object type="application/x-shockwave-flash" data="assets/swfs/CacheManager.swf" width="100%" height="100%">
				<param name="bgcolor" value="##FFFFFF" />
				<param name="flashvars" value="username=&amp;password=" />
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
	<cfelse>
	<div id="innercontent">
		<p class="infomessage">Your role does not allow you to access the cache</p>
	</div>
	</cfif>
	</div>
</div>
</cf_layout>