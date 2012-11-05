<cfif thisTag.executionMode is "start">
<cfimport prefix="mangoAdmin" taglib="tags">
<cfparam name="attributes.page" default=""/>
<cfparam name="attributes.title" default=""/>
<cfset blog = request.blogManager.getBlog() />
<cfset currentSkin = request.administrator.getSkin(blog.getSkin()) />
<cfcontent reset="true">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:spry="http://ns.adobe.com/spry">
<head><cfoutput>
	<meta http-equiv="Content-Type" content="text/html;charset=#blog.getCharset()#" />
	<title>#attributes.title#</cfoutput></title>
	<script type="text/javascript" src="assets/scripts/jquery/jquery-1.3.2.min.js" ></script>
	<script type="text/javascript" src="assets/scripts/jquery/jquery.metadata.min.js" ></script>
	<script type="text/javascript" src="assets/scripts/jquery/jquery.validate.min.js" ></script>
	<script type="text/javascript" src="assets/scripts/jquery/jquery-ui-1.8.min.js"></script>
	<script type='text/javascript' src='assets/scripts/jquery/jquery.countable.min.js'>    </script>
	<script type="text/javascript" src="assets/scripts/admin.js" ></script>

	<link href="assets/styles/tiger.css" rel="stylesheet" type="text/css" />
	<link href="assets/styles/jqueryui/flick/jquery-ui-1.8.css" rel="stylesheet" type="text/css" />
	<!--[if lte IE 6]>
	<link href='assets/styles/tiger_ie.css' rel="stylesheet"  type='text/css' media='screen'>
	<![endif]-->
	<link href="assets/styles/custom.css" rel="stylesheet" type="text/css" />
	
	<cfinclude template="editorSettings.cfm">
	
	<script type="text/javascript" src="assets/scripts/spry/xpath.js"></script>
	<script type="text/javascript" src="assets/scripts/spry/SpryData.js"></script>
	<mangoAdmin:Event name="beforeAdminHeaderEnd">
</head>		
<body>
<div id="container">
<div id="header">
	<h1><cfoutput>#blog.getTitle()# &gt; #attributes.title#</h1>
		<div id="viewsitelink"><a href="#blog.getUrl()#">Go to site</a></div></cfoutput>
	<div id="logout"><a href="index.cfm?logout=1">Logout</a></div>				
</div>
	<cf_navigation page="#attributes.page#">	
</cfif>	
	
<cfif thisTag.executionMode is "end">
<div id="assetSelector" style="display:none;"><cfinclude template="assetSelector.cfm"/></div>
<div id="footer"><a href="http://www.mangoblog.org" id="mangolink"><span>Powered by Mango Blog></span></a> <span class="footer_version">&nbsp;&nbsp;<cfoutput>#request.blogManager.getVersion()#</cfoutput></span></div>
</div><!--- container --->
</body>
</html>
</cfif>