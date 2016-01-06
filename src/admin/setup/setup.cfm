<cfparam name="step" default="1">
<cfparam name="datasourceExists" default="" />
<cfparam name="message" default="">
<cfparam name="error" default="">
<cfparam name="dbType" default="">
<cfparam name="prefix" default="">
<cfparam name="prefix_new" default="">
<cfparam name="dbtype_new" default="">
<cfparam name="datasource_new" default="">
<cfparam name="password_new" default="">
<cfparam name="username_new" default="">
<cfparam name="database_new" default="">
<cfparam name="db_username" default="">
<cfparam name="db_password" default="">
<cfparam name="server_new" default="">
<cfparam name="datasource" default="">
<cfparam name="blog_address" default="http://#cgi.HTTP_HOST##replacenocase(cgi.script_name,'admin/setup/setup.cfm','')#">
<cfparam name="blog_address_blogcfc" default="http://#cgi.HTTP_HOST##replacenocase(cgi.script_name,'admin/setup/setup.cfm','')#">
<cfparam name="blog_address_wordpress" default="http://#cgi.HTTP_HOST##replacenocase(cgi.script_name,'admin/setup/setup.cfm','')#">
<cfparam name="blog_address_blogger" default="http://#cgi.HTTP_HOST##replacenocase(cgi.script_name,'admin/setup/setup.cfm','')#">
<cfparam name="blog_title" default="My Mango Blog">
<cfparam name="email" default="">
<cfparam name="email_wordpress" default="">
<cfparam name="email_blogger" default="">
<cfparam name="blogcfcini" default="">
<cfparam name="mangoConfig" default="">
<cfsetting showdebugoutput="false">
<cfset pluginspath = expandPath("../../components/plugins/") />

<cfflush interval="5">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Mango Blog Setup</title>
<link href="../assets/styles/tiger.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="../assets/scripts/jquery/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="../assets/scripts/jquery/jquery.metadata.min.js"></script>
<script type="text/javascript" src="../assets/scripts/jquery/jquery.validate.min.js"></script>
<script type="text/javascript" src="setup.js"></script>

<style type="text/css">
body {background: #fff;}
#logo {
	background:url("../assets/images/logo.png") top right no-repeat;
	height:46px;
	width:189px;
}

#logo span {
	margin:0;
	display:none;
}
div#setup {
	margin:0 15px;
}
div#warning {
	background-color: #fcc;
	border: 1px solid #c99;
}
</style>


</head>
<body>


<h1 id="logo"><span>Mango</span></h1>

<h2>Setup Wizard</h2>

<cfif isdefined("form.submit")>
<cfswitch expression="#step#">
<cfcase value="1">
	<cfset setupObj = CreateObject("component", "Setup")/>
	<cfif form.datasourceExists>
		<!--- use an already created datasource --->
		<cfset setupObj.init(blog_address,form.datasource, form.dbType, form.prefix, form.db_username, form.db_password)/>
		<cfset result = setupObj.setupDatabase()/>
	<cfelse>
		<!--- create it --->
		<cfset dsn = structnew() />
		<cfset dsn.cfadminpassword = form.cfadminpassword_new/>
		<cfset dsn.datasourcename =  form.datasource_new/>
		<cfset dsn.dbName = form.database_new />
		<cfset dsn.host = form.server_new />
		<cfset dsn.dbType = form.dbtype_new  />
		<cfset dsn.username = form.username_new />
		<cfset dsn.password = form.password_new />
		<cfset result = setupObj.addCFDatasource(argumentcollection=dsn)/>
			<cfif result.status>
				<cfset setupObj.init(blog_address,form.datasource_new, form.dbtype_new, form.prefix_new)/>
				<cfset result = setupObj.setupDatabase()/>
				<cfset datasource = datasource_new />
				<cfset dbType = dbtype_new />
				<cfset prefix = prefix_new />
			</cfif>
	</cfif>
	<cfif result.status>
		<cfset step = 2 />

	<cfelse>
		<cfset error = result.message />
	</cfif>
</cfcase>

<cfcase value="2">
	<cfset setupObj = CreateObject("component", "Setup").init(blog_address,form.datasource, form.dbType, form.prefix, form.db_username, form.db_password)/>
		<cfset path = expandPath("../../") />


	<!--- new blog --->
	<cfif form.isblognew>
		<cfset result = setupObj.saveConfig(path,email)/>

		<cfif result.status>
			<cfset result = setupObj.addBlog(form.blog_title, form.blog_address)/>
				<cfif result.status>
					<cfset result = setupObj.addAuthor(form.name, form.username, form.password,form.email)/>
					<cfif result.status>
						<cfset result = setupObj.addData() />
					</cfif>

					<cfif NOT result.status>
						<cfset error = result.message />
					<cfelse>
						<cfset step = 3 />
						<cfset setupObj.setupPlugins() />
					</cfif>
				<cfelse>
					<cfset error = result.message />
				</cfif>

		<cfelse>
			<cfset error = result.message />
		</cfif>

	<cfelseif NOT form.isblognew>
	<!--- import --->
		<cfswitch expression="#form.blogengine#">

		<!--- wordpress --->

		<cfcase value="blogCFC">
			<!--- blogCFC --->
			<cftry>
				<div class="message">
					<cfset importObj = CreateObject("component", "Importer_BlogCFC_5x").init(blog_address,path,form.blogcfcini,form.datasource, form.dbType, form.prefix, form.db_username, form.db_password)/>
					<cfset result = importObj.import(form.blog_address_blogcfc) />

				</div>
				<cfif NOT result.status>
					<cfset error = result.message />
				<cfelse>
					<cfset setupObj.setupPlugins() />
					<cfset step = 3/>
				</cfif>
				<cfcatch type="any">
					</div>
					<cfset error = cfcatch.message & ": " & cfcatch.detail />
				</cfcatch>
			</cftry>
		</cfcase>

		<cfcase value="wordpress">
			<!--- Upload exported file --->
			<cftry>
				<cffile action="upload" destination="#expandPath('.')#" filefield="datafile_wordpress" nameconflict="overwrite">
				<cfif cffile.fileWasSaved>

					<cftry>
						<div class="message">
							<cfset importObj = CreateObject("component", "Importer_Wordpress").init(blog_address,path,cffile.ServerDirectory & "/" & CFFILE.ServerFile,
									form.datasource, form.dbType, form.prefix,pluginspath, form.db_username, form.db_password)/>
							<cfset result = importObj.import(form.blog_address_wordpress, form.email_wordpress) />

						</div>
						<cfif NOT result.status>
							<cfset error = result.message />
						<cfelse>
							<cfset setupObj.setupPlugins() />
							<cfset step = 3/>
						</cfif>
						<cfcatch type="any">
							</div>
							<cfset error = cfcatch.message & ": " & cfcatch.detail />
						</cfcatch>
					</cftry>

				<cfelse>
					<cfset error = "File could not be saved">
				</cfif>
				<cfcatch type="any">
					<cfset error = cfcatch.message & ": " & cfcatch.detail />
				</cfcatch>
			</cftry>

		</cfcase>
		
		<cfcase value="blogger">
			<!--- Upload exported file --->
			<cftry>
				<cffile action="upload" destination="#expandPath('.')#" filefield="datafile_blogger" nameconflict="overwrite">
				<cfif cffile.fileWasSaved>
					
					<cftry>
						<div class="message">
							<cfset importObj = CreateObject("component", "Importer_Blogger").init(blog_address,path,cffile.ServerDirectory & "/" & CFFILE.ServerFile,
									form.datasource, form.dbType, form.prefix,pluginspath, form.db_username, form.db_password)/>
							<cfset result = importObj.import(form.blog_address_blogger, form.email_blogger) />
							
						</div>
						<cfif NOT result.status>
							<cfset error = result.message />
						<cfelse>
							<cfset setupObj.setupPlugins() />
							<cfset step = 3/>
						</cfif>
						<cfcatch type="any">
							</div>
							<cfset error = cfcatch.message & ": " & cfcatch.detail />
						</cfcatch>
					</cftry>
					
				<cfelse>
					<cfset error = "File could not be saved">	
				</cfif>
				<cfcatch type="any">
					<cfset error = cfcatch.message & ": " & cfcatch.detail />
				</cfcatch>
			</cftry>
			
		</cfcase>
		<!--- <cfcase value="mango">
			<!--- Mango --->
			<cftry>
				<div class="message">
					<cfset importObj = CreateObject("component", "Importer_Mango").init(path,form.mangoConfig,form.datasource, form.dbType, form.prefix,pluginspath)/>
					<cfset result = importObj.import(form.blog_address_blogcfc) />

				</div>
				<cfif NOT result.status>
					<cfset error = result.message />
				<cfelse>
					<cfset setupObj.setupPlugins() />
					<cfset step = 3/>
				</cfif>
				<cfcatch type="any">
					</div>
					<cfset error = cfcatch.message & ": " & cfcatch.detail />
				</cfcatch>
			</cftry>
		</cfcase> --->
		</cfswitch>
	<cfelse>
			<cfset error = result.message />
	</cfif>
</cfcase>

</cfswitch>
</cfif>

<cfswitch expression="#step#">
<cfcase value="1">


<div id="setup">

<p class="infomessage">
	You are about to install Mango Blog.<br />
	You will need to have a database (MS SQL, MySQL, or H2) already created (it can be an empty database).
</p>

<cfif len(error)>
	<p class="error">
		<cfoutput>#error#</cfoutput>
	</p>
</cfif>

<cfoutput><form method="post" action="setup.cfm">

	<h3>Step 1</h3>

	<p>
		<strong>Do you already have a datasource set up for you?</strong>
		<span class="field">
		<label class="option"><input type="radio" value="yes" name="datasourceExists" class="required switch group-a activate-a" <cfif datasourceExists EQ "yes">checked="checked"</cfif> /> Yes</label>
		<label class="option"><input type="radio" value="no" name="datasourceExists" class="required switch group-a activate-b" <cfif datasourceExists EQ "no">checked="checked"</cfif> /> No</label>
		</span>
	</p>


	<fieldset class="switched group-a active-a">
		<legend>Datasource information</legend>

		<p>
			Fill this if you already have a datasource set up in the ColdFusion
			administrator (or your hosting provider creates them for you):
		</p>

		<p>
			<label for="datasource">Datasource name</label>
			<span class="hint">The name of the datasource as entered in the ColdFusion administrator</span>
			<span class="field"><input type="text" id="datasource" name="datasource" value="#datasource#" size="30" class="alphanumeric required"/></span>
		</p>

		<p>
			<strong>Database type</strong>
			<span class="field">
			<label class="option"><input type="radio" value="mssql" name="dbtype" <cfif dbType EQ "mssql">checked="checked"</cfif> class="required" /> MS SQL 2000</label>
			<label class="option"><input type="radio" value="mssql_2005" name="dbtype" <cfif dbType EQ "mssql_2005">checked="checked"</cfif> class="required" /> MS SQL 2005</label>
			<label class="option"><input type="radio" value="mysql" name="dbtype" <cfif dbType EQ "mysql">checked="checked"</cfif> class="required" /> MySQL</label>
			<label class="option"><input type="radio" value="h2db" name="dbtype" <cfif dbType EQ "h2db">checked="checked"</cfif> class="required" /> H2 Database</label>
			</span>
		</p>

		<p>
			<label for="prefix">Table prefix</label>
			<span class="hint">Fill this if your database is not empty or you have another Mango installation in the same database</span>
			<span class="field"><input type="text" id="prefix" name="prefix" value="#prefix#" size="20" class="alphanumeric"/></span>
		</p>

		<p>
			If your hosting provider requires you to supply username and password every
			time you need to access your database, fill out these fields:
		</p>

		<p>
			<label for="db_username">Username</label>
			<span class="hint">Username to access your database</span>
			<span class="field"><input type="text" id="db_username" name="db_username" value="#db_username#" size="30"/></span>
		</p>

		<p>
			<label for="db_password">Password</label>
			<span class="hint">Your database password</span>
			<span class="field"><input type="password" id="db_password" name="db_password" value="#db_password#" size="20"/></span>
		</p>

    </fieldset>

	<fieldset class="switched group-a active-b">
		<legend>New datasource</legend>

		<p>
			<label for="cfadminpassword_new">ColdFusion Administrator password</label>
			<span class="field"><input type="password" id="cfadminpassword_new" name="cfadminpassword_new" value="" size="20" class="required"/></span>
		</p>

		<p>
			<label for="datasource_new">Datasource name</label>
			<span class="field"><input type="text" id="datasource_new" name="datasource_new" value="#datasource_new#" size="30" class="alphanumeric required"/></span>
		</p>

		<p>
			<strong>Database type</strong>
			<span class="field">
			<label class="option"><input type="radio" value="mssql" name="dbtype_new" <cfif dbtype_new EQ "mssql">checked="checked"</cfif> class="required" /> MS SQL 2000</label>
			<label class="option"><input type="radio" value="mssql_2005" name="dbtype_new" <cfif dbtype_new EQ "mssql_2005">checked="checked"</cfif> class="required" /> MS SQL 2005</label>
			<label class="option"><input type="radio" value="mysql" name="dbtype_new" <cfif dbtype_new EQ "mysql">checked="checked"</cfif> class="required" /> MySQL</label>
			</span>
		</p>

		<p>
			<label for="server_new">Server</label>
			<span class="hint">Your database host address (i.e.: localhost, an ip address or url)</span>
			<span class="field"><input type="text" id="server_new" name="server_new" value="#server_new#" size="30" class="required" /></span>
		</p>

		<p>
			<label for="database_new">Database name</label>
			<span class="hint">The name of your database</span>
			<span class="field"><input type="text" id="database_new" name="database_new" value="#database_new#" size="30" class="alphanumeric required" /></span>
		</p>

		<p>
			<label for="username_new">Username</label>
			<span class="hint">Username to access your database</span>
			<span class="field"><input type="text" id="username_new" name="username_new" value="#username_new#" size="30" class="required" /></span>
		</p>

		<p>
			<label for="password_new">Password</label>
			<span class="hint">Your database password</span>
			<span class="field"><input type="password" id="password_new" name="password_new" value="#password_new#" size="20" /></span>
		</p>

		<p>
			<label for="prefix_new">Table prefix</label>
			<span class="hint">Fill this if your database is not empty or you have another Mango installation in the same database</span>
			<span class="field"><input type="text" id="prefix_new" name="prefix_new" value="#prefix_new#" size="20" class="alphanumeric"/></span>
		</p>

    </fieldset>

	<div class="actions">
		<input type="submit" class="primaryAction" id="submit" name="submit" value="Next"/>
	</div>

</form></cfoutput>

</div>
</cfcase>
<cfcase value="2">

<div id="setup">

<cfif len(error)>
	<p class="error"><cfoutput>#error#</cfoutput></p>
</cfif>	<cfoutput>

	<h3>Step 2</h3>

	<form method="post" action="setup.cfm" enctype="multipart/form-data">

		<p>
			<strong>Is this blog new?</strong>
			<span class="field">
			<label class="option"><input type="radio" name="isblognew" value="yes" class="required switch group-a activate-a" checked="checked" /> Yes</label>
			<label class="option"><input type="radio" name="isblognew" value="no" class="required switch group-a activate-b" /> No, I want to import data from another blog</label>
			</span>
		</p>



		<fieldset class="switched group-a active-a">
			<legend>Author information</legend>
			<p>
				<label for="name">Name</label>
				<span class="field"><input type="text" id="name" name="name" value="" size="30" class="required"/></span>
			</p>

			<p>
				<label for="username">Username</label>
				<span class="field"><input type="text" id="username" name="username" value="admin" size="30" class="alphanumeric required"/></span>
			</p>

			<p>
				<label for="password">Password</label>
				<span class="field"><input type="password" id="password" name="password" value="" size="30" class="required"/></span>
			</p>

			<p>
				<label for="email">Email</label>
				<span class="hint">Email address where password will be sent if forgotten. This address also identifies the author when writing comments in posts.</span>
				<span class="field"><input type="text" id="email" name="email" value="#email#" size="50" class="email required"/></span>
			</p>

		</fieldset>


		<fieldset class="switched group-a active-a">
			<legend>Blog information</legend>
			<p>
				<label for="blog_title">Title</label>
				<span class="field"><input type="text" id="blog_title" name="blog_title" value="#blog_title#" size="50" class="required"/></span>
			</p>

			<p>
				<label for="blog_address">Address</label>
				<span class="field"><input type="text" id="blog_address" name="blog_address" value="#blog_address#" size="50" class="url2 required"/></span>
			</p>

		</fieldset>


		<fieldset class="switched group-a active-b">
			<legend>Blog import</legend>
			<p>
				<strong>Blog engine</strong>
				<span class="field">
				<label class="option"><input type="radio" value="wordpress" name="blogengine" class="required switch group-b activate-c" /> Wordpress</label>
				<label class="option"><input type="radio" value="BlogCFC" name="blogengine" class="required switch group-b activate-d" /> BlogCFC 5.x</label>
				<label class="option"><input type="radio" value="Blogger" name="blogengine" class="required switch group-b activate-e" /> Blogger</label>
				<!--- <label class="option"><input type="radio" value="BlogCFM" name="blogengine" class="required" /> BlogCFM</label>
				<label class="option"><input type="radio" value="MovableType" name="blogengine" class="required" /> Movable Type</label> --->
				</span>
			</p>

			<div class="switched group-b active-c">
				<p>
					To export Wordpress content, go to your Wordpress admin, click Manage &gt; Import. Save the file to your computer.
				</p>

				<p>
					<label for="datafile_wordpress">Exported data file</label>
					<span class="hint">File that you saved with Wordpress content</span>
					<span class="field"><input type="file" id="datafile_wordpress" name="datafile_wordpress" value="" class="required"/></span>
				</p>

				<p>
					<label for="blog_address_wordpress">Blog address</label>
					<span class="hint">Leave blank to use URL from Wordpress file</span>
					<span class="field"><input type="text" id="blog_address_wordpress" name="blog_address_wordpress" value="#blog_address_wordpress#" size="50" class="url2"/></span>
				</p>

				<p>
					<label for="email_wordpress">Email address</label>
					<span class="hint">Main address to use when sending email</span>
					<span class="field"><input type="text" id="email_wordpress" name="email_wordpress" value="#email_wordpress#" size="50" class="email required"/></span>
				</p>

				<p class="warning">
					Important: All authors will be set a temporary password: "password".<br />
					Their email address will be set to the main blog email address.<br />
					If you have more than one author, you will need to update the author settings
					in your administrator once the blog is setup.
				</p>

			</div>


			<div class="switched group-b active-d">

				<p>
					<label for="blogcfcini">Configuration file</label>
					<span class="hint">Full path of the location of your blog.ini.cfm file (e.g. c:\inetpub\wwwroot\myblog\blog.ini.cfm)</span>
					<span class="field"><input type="text" id="blogcfcini" name="blogcfcini" value="#blogcfcini#" size="50" class="required"/></span>
				</p>

				<p>
					<label for="blog_address_blogcfc">Blog address</label>
					<span class="hint">Leave blank to use URL from configuration file</span>
					<span class="field"><input type="text" id="blog_address_blogcfc" name="blog_address_blogcfc" value="#blog_address_blogcfc#" size="50" class=""/></span>
				</p>

			</div>
			
			<div class="switched group-b active-e">
				<p>
					To export Blogger content, go to your Blogger admin, click Manage &gt; Import. Save the file to your computer.
				</p>
			
				<p>
					<label for="datafile_blogger">Exported data file</label>
					<span class="hint">File that you saved with Blogger content</span>
					<span class="field"><input type="file" id="datafile_blogger" name="datafile_blogger" value="" class="required"/></span>
				</p>	
			
				<p>
					<label for="blog_address_wordpress">Blog address</label>
					<span class="hint">Leave blank to use URL from Blogger file</span>
					<span class="field"><input type="text" id="blog_address_blogger" name="blog_address_blogger" value="#blog_address_blogger#" size="50" class="url2"/></span>
				</p>
			
				<p>
					<label for="email_wordpress">Email address</label>
					<span class="hint">Main address to use when sending email</span>
					<span class="field"><input type="text" id="email_blogger" name="email_blogger" value="#email_blogger#" size="50" class="email required"/></span>
				</p>
			
				<p class="warning">
					Important: All authors will be set a temporary password: "password".<br />
					Their email address will be set to the main blog email address.<br />
					If you have more than one author, you will need to update the author settings
					in your administrator once the blog is setup.
				</p>
		
			</div>
			
			<!--- <div>

				<p>
					<label for="mangoConfig">Blog address</label>
					<span class="hint">Full path of the location of your config.cfm file (e.g. c:\inetpub\wwwroot\myblog\config.cfm)</span>
					<span class="field"><input type="text" id="mangoConfig" name="mangoConfig" value="#mangoConfig#" size="50" class="required"/></span>
				</p>

			</div> --->

		</fieldset>


    <div class="actions">
		<input type="submit" class="primaryAction" id="tfa_submit" name="submit" value="Submit"/>
		<input type="hidden" name="step" value="2"/>
		<input type="hidden" name="prefix" value="#prefix#" />
		<input type="hidden" name="datasource" value="#datasource#" />
		<input type="hidden" name="dbtype" value="#dbtype#" />
		<input type="hidden" name="db_username" value="#db_username#" />
		<input type="hidden" name="db_password" value="#db_password#" />
    </div>

</form>

</div>

</cfoutput>

</cfcase>

<cfcase value="3">

	<div id="setup">
	<h3>Step 3</h3>

	<p>Done!</p>
<cfoutput>
	<p>You can now start posting from your administration at: <a href="#blog_address#admin/index.cfm?first=1">#blog_address#admin/</a></p>
	<p>Then you can view your blog at: <a href="#blog_address#">#blog_address#</a></p>
	<div class="warning">
		Now that installation is complete, it is strongly recommended that you delete the "setup" folder. Leaving it intact poses a security
		risk to this site. Once you have verified that installation was successful and that you no longer need the setup folder, you should delete
		it. If you would like, we can delete that for you right now.<br/>
		<form action="setup.cfm" method="post">
			<input type="hidden" name="step" value="4"/>
			<input type="submit" value="Please delete the 'setup' folder for me" />
		</form>
	</div>
</cfoutput>
	</div>

</cfcase>

<cfcase value="4">

	<div id="setup">
	<h3>Security Improved!</h3>

	<p>Thank you for deleting the setup folder and securing your site. For your reference, here are the getting started links again:</p>
<cfoutput>
	<p>You can now start posting from your administration at: <a href="#blog_address#admin/index.cfm?first=1">#blog_address#admin/</a></p>
	<p>Then you can view your blog at: <a href="#blog_address#">#blog_address#</a></p>
</cfoutput>
	</div>

	<!--- delete the setup folder --->
	<cfdirectory action="delete" directory="#expandPath('.')#" recurse="true" />

</cfcase>


</cfswitch>
</body>
</html>
