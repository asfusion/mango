<cfsilent>
	 <!--- Set Defaults values --->
	<cfparam name="request.username" default="" type="string" />
	<cfparam name="request.password" default="" type="string" />
	<cfparam name="request.errormsg" default="" type="string" />
	<cfset currentBlogId = request.blogManager.getBlog().getId() />
	<cfif request.blogManager.isCurrentUserLoggedIn() AND NOT ListFind(request.blogManager.getCurrentUser().getCurrentRole(currentBlogId).permissions, "access_admin")>
		<cfset request.errormsg = "You do not have permission to access the admin area." />
	</cfif>
</cfsilent>
 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
 <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title>Administration</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

	<link href="assets/styles/tiger.css" rel="stylesheet" type="text/css" />	
	<link href="assets/styles/login.css" rel="stylesheet" type="text/css" />
	<!--[if lte IE 6]>
<link href='assets/styles/tiger_ie.css' rel="stylesheet"  type='text/css' media='screen'>
<![endif]-->
</head>
<body>
	<div id="container">
		<div id="header">
			<h1>Administration</h1>			
		</div>
	
	
			<div id="login"><h2>Login</h2>
				<cfif len(request.errormsg)><cfoutput><p class="error">#request.errormsg#</p></cfoutput></cfif>
				<cfoutput><form action="#cgi.script_name#?#cgi.query_string#" method="post">
						<div>
							<label id="usernameLabel" for="username">Username: <input type="text" name="username" id="username" maxlength="40" value="#request.username#" /></label>
							<label id="passwordLabel" for="password">Password: <input type="password" name="password" id="password" maxlength="40" value="" /></label>
							<input type="submit" name="login" id="submit" value="Login" />
						</div>
				</form></cfoutput>
				<div class="clear"></div>			
		</div>
		<div id="footer"><a href="http://www.mangoblog.org" id="mangolink"><span>Powered by Mango Blog></span></a></div>
	</div>
</body>
</html>
