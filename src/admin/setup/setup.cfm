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
<cfparam name="db_port" default="3306">
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
<cfparam name="adddata" default="none" />

<cfsetting showdebugoutput="false">
<cfset pluginspath = expandPath("../../components/plugins/") />
<cfset setupObj = CreateObject("component", "Setup")/>

<cfset check = setupObj.checkSystem() />
<cfif len( check )>
	<cfset error = check />
</cfif>


<cfflush interval="5">
<cfif isdefined("form.submit")>
	<cfswitch expression="#step#">
		<cfcase value="1">
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
				<cfset dsn.port = form.db_port />
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
						<cfset result = setupObj.addAuthor(form.name, form.password,form.email)/>
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

		<cfcase value="3">
			<cfif adddata NEQ "none">
				<cfset setupObj = CreateObject("component", "Setup").init(blog_address,form.datasource, form.dbType, form.prefix, form.db_username, form.db_password)/>
				<cfset path = expandPath("../../") />
				<cfset result = setupObj.addSampleData( addData, path )/>

				<cfif NOT result.status>
					<cfset error = result.message />
				<cfelse>
					<cfset step = 4 />
				</cfif>
			<cfelse>
				<cfset step = 4 />
			</cfif>

		</cfcase>
	</cfswitch>
</cfif>


<!DOCTYPE html>
<html lang="en">
<head>
	<title>Mango Blog Setup</title>
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<link rel="stylesheet" href="../assets/js/vendor/bootstrap/dist/css/bootstrap-icons.min.css">
	<!-- Sweet Alert -->
	<link type="text/css" href="../assets/js/vendor/sweetalert2/dist/sweetalert2.min.css" rel="stylesheet">

	<script type="text/javascript" src="../assets/scripts/jquery/jquery-1.3.2.min.js"></script>
	<script type="text/javascript" src="../assets/scripts/jquery/jquery.metadata.min.js"></script>
	<script type="text/javascript" src="../assets/scripts/jquery/jquery.validate.min.js"></script>
	<script type="text/javascript" src="setup.js"></script>


	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/ionicons/4.5.6/css/ionicons.min.css" integrity="sha512-0/rEDduZGrqo4riUlwqyuHDQzp2D1ZCgH/gFIfjMIL5az8so6ZiXyhf1Rg8i6xsjv+z/Ubc4tt1thLigEcu6Ug==" crossorigin="anonymous" referrerpolicy="no-referrer" />
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.13.1/css/all.min.css" integrity="sha256-2XFplPlrFClt0bIdPgpz8H7ojnk10H69xRqd9+uTShA=" crossorigin="anonymous" />

	<link type="text/css" href="../assets/styles/volt.css" rel="stylesheet">
	<link type="text/css" href="../assets/styles/custom.css" rel="stylesheet">
	<link href="https://fonts.googleapis.com/css?family=Roboto:300,400,500,700" rel="stylesheet">
	<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
	<style>
#logo {
	background:url("../assets/images/logo.png") top no-repeat;
	height:46px;
	width:189px;
}

#logo span {
	margin:0;
	display:none;
}

div#warning {
	background-color: #fcc;
	border: 1px solid #c99;
}
label {
	width: 100%;
	font-size: 1rem;
}

.card-input-element+.card {
	height: calc(36px + 2*1rem);
}

.card-input-element+.card:hover {
	cursor: pointer;
}

.card-input-element:checked+.card {
	border: 2px solid var(--primary);
	-webkit-transition: border .3s;
	-o-transition: border .3s;
	transition: border .3s;
}

.card-input-element:checked+.card::after {
	content: '\e5ca';
	color: #1db515;
	font-family: 'Material Icons';
	font-size: 40px;
	-webkit-animation-name: fadeInCheckbox;
	animation-name: fadeInCheckbox;
	-webkit-animation-duration: .5s;
	animation-duration: .5s;
	-webkit-animation-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
	animation-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

@-webkit-keyframes fadeInCheckbox {
	from {
		opacity: 0;
		-webkit-transform: rotateZ(-20deg);
	}
	to {
		opacity: 1;
		-webkit-transform: rotateZ(0deg);
	}
}

@keyframes fadeInCheckbox {
	from {
		opacity: 0;
		transform: rotateZ(-20deg);
	}
	to {
		opacity: 1;
		transform: rotateZ(0deg);
	}
}

	</style>
</head>
<body>

<main>

	<!-- Section -->
<section class="">
<div class="container">
	<h1 id="logo" class="mt-3"><span>Mango</span></h1>

<div class="row justify-content-center">
<div class="col-12 d-flex">
<div class="bg-white shadow border-0 rounded border-light p-4 p-lg-5 w-100">
<cfoutput>

	<cfswitch expression="#step#">
		<cfcase value="1">

				<div id="setup">
				<div class="alert alert-info" role="alert">
						You are about to install Mango Blog.<br />
						You will need to have a database (MS SQL or MySQL) already created (it can be an empty database).
				</div>

				<cfif len(error)>
					<div class="alert alert-danger" role="alert">
					<cfoutput>#error#</cfoutput>
					</div>
				</cfif>

				<cfoutput><form method="post" action="setup.cfm">
					<h3>Step 1</h3>
				<p>
					<label>Do you already have a datasource set up for you?</label>
					<div class="field ">
					<label class="option"><input type="radio" value="yes" name="datasourceExists" class="required switch group-a activate-a form-check-input" <cfif datasourceExists EQ "yes">checked="checked"</cfif> /> Yes</label>
					<label class="option"><input type="radio" value="no" name="datasourceExists" class="required switch group-a activate-b form-check-input" <cfif datasourceExists EQ "no">checked="checked"</cfif> /> No</label>
					</div>
				</p>

				<fieldset class="switched group-a active-a">
					<legend>Datasource information</legend>
					<div class="alert alert-secondary" role="alert">
						Fill this if you already have a datasource set up in the ColdFusion
						administrator (or your hosting provider creates them for you):
					</div>

					<div class="field-container mb-5">
						<label for="datasource">Datasource name</label>
						<p class="hint small pe-4">The name of the datasource as entered in the ColdFusion administrator</p>
						<div class="col-sm-9 ">
							<input type="text" id="datasource" name="datasource" value="#datasource#" size="30" class="alphanumeric required form-control"/>
						</div>
					</div>

					<div class="field-container mb-5">
						<label>Database type</label>
						<div class="form-check">
							<label class="option"><input type="radio" value="mssql" name="dbtype" <cfif dbType EQ "mssql">checked="checked"</cfif> class="required" /> MS SQL 2000</label>
							<br/>
							<label class="option"><input type="radio" value="mssql_2005" name="dbtype" <cfif dbType EQ "mssql_2005">checked="checked"</cfif> class="required" /> MS SQL 2005</label>
							<br/>
							<label class="option"><input type="radio" value="mysql" name="dbtype" <cfif dbType EQ "mysql">checked="checked"</cfif> class="required" /> MySQL</label>
						</div>
					</div>

				<div class="field-container mb-5">
					<label for="prefix">Table prefix</label>
					<p class="hint small pe-4">Fill this if your database is not empty or you have another Mango installation in the same database</p>
					<span class="field"><input type="text" id="prefix" name="prefix" value="#prefix#" size="20" class="alphanumeric form-control"/></span>
				</div>

					<p>
						If your hosting provider requires you to supply username and password every
						time you need to access your database, fill out these fields:
					</p>

				<p>
					<label for="db_username">Username</label>
					<span class="hint">Username to access your database</span>
				<span class="field"><input type="text" id="db_username" name="db_username" value="#db_username#" size="30" class="form-control"/></span>
				</p>

				<p>
					<label for="db_password">Password</label>
					<span class="hint">Your database password</span>
					<span class="field">
						<input type="text" id="db_password" name="db_password" value="#db_password#" size="20" class="form-control"/>
				</span>
				</p>

				</fieldset>
				<fieldset class="switched group-a active-b">
					<legend>New datasource</legend>
					<p>
						<label for="cfadminpassword_new">ColdFusion Administrator password</label>
						<span class="field"><input type="text" id="cfadminpassword_new" name="cfadminpassword_new" value="" size="20" class="required form-control" autocomplete="off"  /></span>
					</p>
				<p>
					<label for="datasource_new">Datasource name</label>
				<span class="field"><input type="text" id="datasource_new" name="datasource_new" value="#datasource_new#" size="30" class="alphanumeric required form-control"/></span>
				</p>
				<div class="field-container mb-5">
					<label>Database type</label>
				<div class="form-check">
				<label class="option"><input type="radio" value="mssql" name="dbtype_new" <cfif dbType EQ "mssql">checked="checked"</cfif> class="required" /> MS SQL 2000</label>
					<br/>
				<label class="option"><input type="radio" value="mssql_2005" name="dbtype_new" <cfif dbType EQ "mssql_2005">checked="checked"</cfif> class="required" /> MS SQL 2005</label>
					<br/>
				<label class="option"><input type="radio" value="mysql" name="dbtype_new" <cfif dbType EQ "mysql">checked="checked"</cfif> class="required" /> MySQL</label>
				</div>
				</div>


				<p>
					<label for="server_new">Server</label>
					<span class="hint">Your database host address (i.e.: localhost, an ip address or url)</span>
				<span class="field"><input type="text" id="server_new" name="server_new" value="#server_new#" size="30" class="required form-control" /></span>
				</p>
				<p>
					<label for="db_port">Port</label>
					<span class="hint">Your database port. In mySql, it defaults to 3306</span>
				<span class="field"><input type="text" id="db_port" name="db_port" value="#db_port#" size="30" class="required form-control" /></span>
				</p>

				<p>
					<label for="database_new">Database name</label>
					<span class="hint">The name of your database</span>
				<span class="field"><input type="text" id="database_new" name="database_new" value="#database_new#" size="30" class="alphanumeric required form-control" /></span>
				</p>

				<p>
					<label for="username_new">Username</label>
					<span class="hint">Username to access your database</span>
				<span class="field"><input type="text" id="username_new" name="username_new" value="#username_new#" size="30" class="required form-control" /></span>
				</p>

				<p>
					<label for="password_new">Password</label>
					<span class="hint">Your database password</span>
				<span class="field"><input type="text" id="password_new" name="password_new" value="#password_new#" size="20" autocomplete="off" class="form-control" /></span>
				</p>

				<p>
					<label for="prefix_new">Table prefix</label>
					<span class="hint">Fill this if your database is not empty or you have another Mango installation in the same database</span>
				<span class="field"><input type="text" id="prefix_new" name="prefix_new" value="#prefix_new#" size="20" class="alphanumeric form-control"/></span>
				</p>

				</fieldset>
					<div class="actions">
						<input type="submit" class="btn btn-primary" id="submit" name="submit" value="Next"/>
					</div>
				</form></cfoutput>

				</div>
		</cfcase>
		<cfcase value="2">

			<div id="setup">
			<cfif len(error)>
					<div class="alert alert-danger" role="alert">
					<cfoutput>#error#</cfoutput>
					</div>
			</cfif>
			<cfoutput>
				<h3>Step 2</h3>
				<form method="post" action="setup.cfm" enctype="multipart/form-data">
					<input type="hidden" name="isblognew" value="yes" />
				<!---- <p>
					<strong>Is this blog new?</strong>
					<span class="field">
			<label class="option"><input type="radio" name="isblognew" value="yes" class="required switch group-a activate-a" checked="checked" /> Yes</label>
			<label class="option"><input type="radio" name="isblognew" value="no" class="required switch group-a activate-b" /> No, I want to import data from another blog</label>
			</span>
				</p>
--->
			<fieldset class=" group-a active-a">
				<legend>Author information</legend>
				<p>
					<label for="name">Name</label>
					<span class="field"><input type="text" id="name" name="name" value="" size="30" class="required form-control"/></span>
				</p>
			<p>
				<label for="email">Email</label>
					<input type="text" id="email" name="email" value="#email#" size="50" class="email required form-control" required/>
					<div class="alert alert-primary" role="alert">
						Email will be used for logging in and where password reset will be sent if forgotten.
						This address also identifies the author when writing comments in posts.</div>
			</p>
				<p>
					<label for="password">Password</label>
					<span class="field"><input type="password" id="password" name="password" value="" size="30" class="required form-control" autocomplete="off" required /></span>
				</p>
			</fieldset>

			<fieldset class=" group-a active-a">
				<legend>Blog information</legend>
			<p>
				<label for="blog_title">Title</label>
			<span class="field"><input type="text" id="blog_title" name="blog_title" value="#blog_title#" size="50" class="required form-control"/></span>
			</p>

			<p>
				<label for="blog_address">Address</label>
			<span class="field"><input type="text" id="blog_address" name="blog_address" value="#blog_address#" size="50" class="url2 required form-control"/></span>
			</p>
			</fieldset>

			<fieldset class="switched group-a active-b">
				<legend>Blog import</legend>
			<p>
				<strong>Blog engine</strong>
			<span class="field">
				<label class="option"><input type="radio" value="wordpress" name="blogengine" class="required switch group-b activate-c" /> Wordpress</label>
				<label class="option"><input type="radio" value="Blogger" name="blogengine" class="required switch group-b activate-e" /> Blogger</label>
			</span>
			</p>

			<div class="switched group-b active-c">
				<p>
					To export Wordpress content, go to your Wordpress admin, click Manage &gt; Import. Save the file to your computer.
				</p>

				<p>
					<label for="datafile_wordpress">Exported data file</label>
					<span class="hint">File that you saved with Wordpress content</span>
					<span class="field"><input type="file" id="datafile_wordpress" name="datafile_wordpress" value="" class="required form-control"/></span>
				</p>

			<p>
				<label for="blog_address_wordpress">Blog address</label>
				<span class="hint">Leave blank to use URL from Wordpress file</span>
			<span class="field"><input type="text" id="blog_address_wordpress" name="blog_address_wordpress" value="#blog_address_wordpress#" size="50" class="url2 form-control"/></span>
			</p>

			<p>
				<label for="email_wordpress">Email address</label>
				<span class="hint">Main address to use when sending email</span>
			<span class="field"><input type="text" id="email_wordpress" name="email_wordpress" value="#email_wordpress#" size="50" class="email required form-control"/></span>
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
			<span class="field"><input type="text" id="blogcfcini" name="blogcfcini" value="#blogcfcini#" size="50" class="required form-control"/></span>
			</p>

			<p>
				<label for="blog_address_blogcfc">Blog address</label>
				<span class="hint">Leave blank to use URL from configuration file</span>
				<span class="field"><input type="text" id="blog_address_blogcfc" name="blog_address_blogcfc" value="#blog_address_blogcfc#" size="50" class="form-control"/></span>
			</p>
			</div>

			<div class="switched group-b active-e">
				<p>To export Blogger content, go to your Blogger admin, click Manage &gt; Import. Save the file to your computer.
				</p>
				<p>
					<label for="datafile_blogger">Exported data file</label>
					<span class="hint">File that you saved with Blogger content</span>
					<span class="field"><input type="file" id="datafile_blogger" name="datafile_blogger" value="" class="required form-control"/></span>
				</p>

			<p>
				<label for="blog_address_wordpress">Blog address</label>
				<span class="hint">Leave blank to use URL from Blogger file</span>
			<span class="field"><input type="text" id="blog_address_blogger" name="blog_address_blogger" value="#blog_address_blogger#" size="50" class="url2 form-control"/></span>
			</p>

			<p>
				<label for="email_wordpress">Email address</label>
				<span class="hint">Main address to use when sending email</span>
			<span class="field"><input type="text" id="email_blogger" name="email_blogger" value="#email_blogger#" size="50" class="email required form-control"/></span>
			</p>

				<p class="warning">
					Important: All authors will be set a temporary password: "password".<br />
					Their email address will be set to the main blog email address.<br />
					If you have more than one author, you will need to update the author settings
					in your administrator once the blog is setup.
				</p>

			</div>
			</fieldset>

			<div class="actions">
				<input type="submit" class="btn btn-primary" id="tfa_submit" name="submit" value="Submit"/>
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

				<cfoutput>
					<form method="post" action="setup.cfm" >
					<p>You can choose to populate this website with sample data</p>
						<div class="row">
							<div class="col-xl-3 col-md-6 mb-8">
							<label class="">
								<input type="radio" name="adddata" class="card-input-element d-none" value="none" checked>

								<div class="card shadow border-0 text-center p-0">
									<img class="card-img-top rounded-top"    src="data/massively.png">
									<div class="card-body text-white bg-gray-600 rounded-bottom">No sample data</div>
								</div>
							</label>
							</div>

						<div class="col-xl-3 col-md-6 mb-4">
							<label>
								<input type="radio" name="adddata" class="card-input-element d-none" value="massively" >
								<div class="card shadow border-0 text-center p-0">
									<img class="card-img-top rounded-top"    src="data/massively.png">
									<div class="card-body text-white bg-gray-600 rounded-bottom">Massively</div>
								</div>
							</label>
						</div>
						<div class="col-xl-3 col-md-6 mb-4">
							<label>
								<input type="radio" name="adddata" class="card-input-element d-none" value="ecohosting" >
								<div class="card shadow border-0 text-center p-0">
									<img class="card-img-top rounded-top" src="data/ecohosting.jpg">
									<div class="card-body text-white bg-gray-600 rounded-bottom">Ecohosting</div>
								</div>
							</label>
						</div>
						<div class="col-xl-3 col-md-6 mb-4">
							<label >
								<input type="radio" name="adddata" class="card-input-element d-none" value="monica" >
								<div class="card shadow border-0 text-center p-0">
									<img class="card-img-top rounded-top" src="data/monica.jpg">
									<div class="card-body text-white bg-gray-600 rounded-bottom">Monica</div>
								</div>
							</label>
						</div>
						<div class="col-xl-3 col-md-6 mb-4">
							<label >
								<input type="radio" name="adddata" class="card-input-element d-none" value="augustine" >
								<div class="card shadow border-0 text-center p-0">
									<img class="card-img-top rounded-top" src="data/augustine.jpg">
									<div class="card-body text-white bg-gray-600 rounded-bottom">Augustine</div>
								</div>
							</label>
						</div>
					</div>

					<div class="mt-7">
						<input type="submit" class="btn btn-primary" name="submit" value="Submit"/>
						<input type="hidden" name="step" value="3"/>
							<input type="hidden" name="prefix" value="#prefix#" />
							<input type="hidden" name="datasource" value="#datasource#" />
							<input type="hidden" name="dbtype" value="#dbtype#" />
							<input type="hidden" name="db_username" value="#db_username#" />
							<input type="hidden" name="db_password" value="#db_password#" />
					</div>
					</form>
				</cfoutput>
				</div>

		</cfcase>

		<cfcase value="4">
				<div id="setup">
					<h3>Step 4</h3>
				<cfoutput>
						<div class="alert alert-secondary" role="alert">
							<p>	Your website is ready!
								<a href="#blog_address#" target="_blank"><button class="btn btn-secondary">View home page</button></a>
							</p>
						<p>You can now start posting from your administration at: <a href="#blog_address#admin/index.cfm?first=1"  target="_blank">#blog_address#admin/</a></p>
						</div>

				<form method="post" action="setup.cfm" >
					<p>Look at the website and decide whether you want to try a different sample</p>
					<div class="row">
						<div class="col-xl-3 col-md-6 mb-4">
							<label>
								<input type="radio" name="adddata" class="card-input-element d-none" value="massively" <cfif adddata EQ "massively">checked</cfif>>
								<div class="card shadow border-0 text-center p-0">
									<img class="card-img-top rounded-top"    src="data/massively.png">
									<div class="card-body text-white bg-gray-600 rounded-bottom">Massively</div>
								</div>
							</label>
						</div>
						<div class="col-xl-3 col-md-6 mb-4">
							<label>
								<input type="radio" name="adddata" class="card-input-element d-none" value="ecohosting"  <cfif adddata EQ "ecohosting">checked</cfif>>
								<div class="card shadow border-0 text-center p-0">
									<img class="card-img-top rounded-top" src="data/ecohosting.jpg">
									<div class="card-body text-white bg-gray-600 rounded-bottom">Ecohosting</div>
								</div>
							</label>
						</div>
						<div class="col-xl-3 col-md-6 mb-4">
							<label >
								<input type="radio" name="adddata" class="card-input-element d-none" value="monica"  <cfif adddata EQ "monica">checked</cfif>>
								<div class="card shadow border-0 text-center p-0">
									<img class="card-img-top rounded-top" src="data/monica.jpg">
									<div class="card-body text-white bg-gray-600 rounded-bottom">Monica</div>
								</div>
							</label>
						</div>
				<div class="col-xl-3 col-md-6 mb-4">
				<label >
						<input type="radio" name="adddata" class="card-input-element d-none" value="augustine"  <cfif adddata EQ "augustine">checked</cfif>>
					<div class="card shadow border-0 text-center p-0">
						<img class="card-img-top rounded-top" src="data/augustine.jpg">
						<div class="card-body text-white bg-gray-600 rounded-bottom">Augustine</div>
					</div>
				</label>
				</div>
					</div>

				<div class="mt-7">
					<input type="submit" class="btn btn-primary" name="submit" value="Submit"/>
					<input type="hidden" name="step" value="3"/>
						<input type="hidden" name="prefix" value="#prefix#" />
						<input type="hidden" name="datasource" value="#datasource#" />
						<input type="hidden" name="dbtype" value="#dbtype#" />
						<input type="hidden" name="db_username" value="#db_username#" />
						<input type="hidden" name="db_password" value="#db_password#" />
				</div>
				</form>

				<p>
					<div class="warning">
						Now that installation is complete, it is strongly recommended that you delete the "setup" folder. Leaving it intact poses a security
						risk to this site. Once you have verified that installation was successful and that you no longer need the setup folder, you should delete
						it. If you would like, we can delete that for you right now.

						<div class="mt-3">
						<form action="setup.cfm" method="post">
							<input type="hidden" name="step" value="4"/>
							<input type="submit" class="btn btn-outline-danger" value="Please delete the 'setup' folder for me" />
						</form>
						</div>
					</div>
				</cfoutput>
				</div>

		</cfcase>

		<cfcase value="5">

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

	</form>
</cfoutput>

</div>
</div>
</div>
</div>
</section>
</main>


<!-- Core -->
<script src="../assets/js/vendor/@popperjs/core/dist/umd/popper.min.js"></script>
<script src="../assets/js/vendor/bootstrap/dist/js/bootstrap.min.js"></script>

<!-- Vendor JS -->
<script src="../assets/js/vendor/onscreen/dist/on-screen.umd.min.js"></script>

<!-- Slider -->
<script src="../assets/js/vendor/nouislider/distribute/nouislider.min.js"></script>

<!-- Smooth scroll -->
<script src="../assets/js/vendor/smooth-scroll/dist/smooth-scroll.polyfills.min.js"></script>

<!-- Sweet Alerts 2 -->
<script src="../assets/js/vendor/sweetalert2/dist/sweetalert2.all.min.js"></script>


<!-- Notyf -->
<script src="../assets/js/vendor/notyf/notyf.min.js"></script>

<!-- Simplebar -->
<script src="../assets/js/vendor/simplebar/dist/simplebar.min.js"></script>

<!-- Volt JS -->
<script src="../assets/js/volt.js"></script>

</body>
</html>
