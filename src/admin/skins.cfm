<cfsilent>
	<cfimport prefix="mangoAdmin" taglib="tags">
	<cfparam name="error" default="">
	<cfparam name="message" default="">

	<cfif structkeyexists(url,"action")>
		<cfif action EQ "download">
			<cfset result = request.formHandler.downloadSkin(url) />
		<cfelse>
			<cfset result = request.formHandler.handleEditSkin(url) />
		</cfif>
		
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelseif result.message.getStatus() EQ "ftp_error">
			<!--- attempt simple download --->
			<cflocation url="#result.message.getText()#" addtoken="false">
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
	</cfif>
	<cfset blog = request.administrator.getBlog() />
	<cfset skin = blog.getSkin() />
	<cfset skins = request.administrator.getSkins() />
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentRole = currentAuthor.getCurrentRole(blog.getId())/>
</cfsilent>
<cf_layout page="Themes" title="Themes">
	<div id="wrapper">
		<cfif listfind(currentRole.permissions, "manage_themes")
				OR listfind(currentRole.permissions, "set_themes")>
		<div id="submenucontainer">
		
		</div>
	
		<div id="content">
		<h2 class="pageTitle">Current theme</h2>
		
			<div id="innercontent">
			<cfif len(error)>
				<p class="error"><cfoutput>#error#</cfoutput></p>
			</cfif>
			<cfif len(message)>
				<p class="message"><cfoutput>#message#</cfoutput></p>
			</cfif>

<cfoutput>
<table>
<cfloop from="1" to="#arraylen(skins)#" index="i">
<script type="text/javascript">
var skinUpdate#i# = new Spry.Data.XMLDataSet("datasets/downloadableSkins.cfm?action=checkUpdates&skin=#skins[i].id#", "skin");
</script>
	<cfif skins[i].id EQ skin>
	<tr><th colspan="2">#skins[i].name#</th></tr>
	<tr><td><img src="#request.administrator.getBlog().getUrl()#skins/#skins[i].id#/#skins[i].thumbnail#"></td><td><p>#skins[i].description#</p>
	<ul><li><strong>Author</strong>: 
		<cfif len(skins[i].authorUrl)><a href="#skins[i].authorUrl#">#skins[i].author#</a>
		<cfelse>#skins[i].author#</cfif></li>
		<cfif len(skins[i].designAuthor)><li><strong>Designer</strong>: <cfif len(skins[i].designAuthorUrl)><a href="#skins[i].designAuthorUrl#">#skins[i].designAuthor#</a>
		<cfelse>#skins[i].designAuthor#</cfif></li></cfif>
		<cfif len(skins[i].license)><li><strong>License: </strong>#skins[i].license#</li></cfif>
		<cfif len(skins[i].version)><li><strong>Version: </strong>#skins[i].version#</li></cfif>
	</ul>
	
	<div spry:region="skinUpdate#i#">
		<div spry:state="error"></div>
		<div spry:state="ready" spry:repeat="skinUpdate#i#">
			<p class="warning" spry:if="'{hasupdates}' == 1">There is an update available for this theme. <a href="{downloadUrl}">Download</a></p></div>
	</div>
	</td></tr>
	</cfif>
</cfloop>  
</table>

<h2 class="sectionTitle">Available themes</h2>

<table>
<cfloop from="1" to="#arraylen(skins)#" index="i">	
	<cfif skins[i].id NEQ skin><!--- exclude current skin --->
	<tr><th>#skins[i].name#</th><th><a href="#cgi.script_name#?action=set&amp;skin=#skins[i].id#">Use this theme</a></th></tr><tr><td><img src="#request.administrator.getBlog().getUrl()#skins/#skins[i].id#/#skins[i].thumbnail#"></td><td><p>#skins[i].description#</p>
	<ul><li><strong>Author</strong>: 
		<cfif len(skins[i].authorUrl)><a href="#skins[i].authorUrl#">#skins[i].author#</a>
		<cfelse>#skins[i].author#</cfif></li>
		<cfif len(skins[i].designAuthor)><li><strong>Designer</strong>: <cfif len(skins[i].designAuthorUrl)><a href="#skins[i].designAuthorUrl#">#skins[i].designAuthor#</a>
		<cfelse>#skins[i].designAuthor#</cfif></li></cfif>
		<cfif len(skins[i].license)><li><strong>License: </strong>#skins[i].license#</li></cfif>
		<cfif len(skins[i].version)><li><strong>Version: </strong>#skins[i].version#</li></cfif>
	</ul>
	<br />
	<div spry:region="skinUpdate#i#">
		<div spry:state="error"></div>
		<div spry:state="ready" spry:repeat="skinUpdate#i#">
			<p class="warning" spry:if="'{hasupdates}' == 1">There is an update available for this theme. <a href="{downloadUrl}">Download</a></p></div>
	</div>
	
	<a href="#cgi.script_name#?action=delete&amp;skin=#skins[i].id#" class="deleteButton">Delete this theme</a>
	</td></tr>
	<tr><td colspan="2">&nbsp;</td></tr>
</cfif>
</cfloop>  
</table>

<cfif listfind(currentRole.permissions, "manage_themes")>
<h2 class="sectionTitle">Download themes</h2>
<script type="text/javascript">
var dsDownloadSkins = new Spry.Data.XMLDataSet("datasets/downloadableSkins.cfm", "skins/skin");
</script>

<div id="downloadSkins" spry:region="dsDownloadSkins">
	<div spry:state="loading">Gettings themes...</div>
	<div class="skinBox" spry:state="ready" spry:repeat="dsDownloadSkins">
		<h3>{name}</h3>
		<img src="{thumbnail}"><br />
		<span class="download"><a href="#cgi.script_name#?action=download&amp;skin={id}">Download</a></span> | <a href="http://www.mangoblog.org/demo/?skin={id}" _target="_blank">Demo</a>
	</div>
</div>
</cfif>
<br />

</cfoutput>

</div>
</div>
<cfelse><!--- not authorized --->
<div id="content"><div id="innercontent">
<p class="infomessage">Your role does not allow editing themes</p>
</div></div>
</cfif>
</div>
</cf_layout>