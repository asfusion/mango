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
<!DOCTYPE html>
<html lang="en">

<head>
	<title>Administration</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<meta name="title" content="Administration Sign in page" />
	<!-- Favicon -->
	<link rel="apple-touch-icon" sizes="120x120" href="assets/img/favicon/apple-touch-icon.png">
	<link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon/favicon-32x32.png">
	<link rel="icon" type="image/png" sizes="16x16" href="assets/img/favicon/favicon-16x16.png">
	<link rel="manifest" href="../../assets/img/favicon/site.webmanifest">
	<link rel="mask-icon" href="assets/img/favicon/safari-pinned-tab.svg" color="#ffffff">
	<meta name="msapplication-TileColor" content="#ffffff">
	<meta name="theme-color" content="#ffffff">

	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

	<!-- Sweet Alert -->
	<link type="text/css" href="assets/js/vendor/sweetalert2/dist/sweetalert2.min.css" rel="stylesheet">

	<!-- Notyf -->
	<link type="text/css" href="assets/js/vendor/notyf/notyf.min.css" rel="stylesheet">

	<!-- Volt CSS -->
	<link type="text/css" href="assets/styles/volt.css" rel="stylesheet">

	<script type="text/javascript" src="assets/scripts/jquery/jquery-1.3.2.min.js" ></script>
	<script type="text/javascript" src="assets/scripts/jquery/jquery.metadata.min.js" ></script>
	<script type="text/javascript" src="assets/scripts/jquery/jquery.validate.min.js" ></script>
	<script type="text/javascript" src="assets/scripts/jquery/jquery-ui-1.8.min.js"></script>
	<script type='text/javascript' src='assets/scripts/jquery/jquery.countable.min.js'>    </script>
	<script type="text/javascript" src="assets/scripts/admin.js" ></script>

	<link href="assets/styles/custom.css" rel="stylesheet" type="text/css" />


</head>
<body>

<main>

	<!-- Section -->
<section class="vh-lg-100 mt-5 mt-lg-0 bg-soft d-flex align-items-center">
<div class="container">
<div class="row justify-content-center form-bg-image" data-background-lg="assets/img/illustrations/signin.svg">
<div class="col-12 d-flex align-items-center justify-content-center">
<div class="bg-white shadow border-0 rounded border-light p-4 p-lg-5 w-100 fmxw-500">
	<div class="text-center text-md-center mb-4 mt-md-0">
		<h1 class="mb-0 h3">Sign In</h1>
	</div>
<cfoutput>
	<cfif len(request.errormsg)><div class="alert alert-danger" role="alert">#request.errormsg#</div></cfif>
		<form action="#cgi.script_name#?#cgi.query_string#" method="post" class="mt-4">
		<!-- Form -->
	<div class="form-group mb-4">
		<label for="username">Your Email</label>
	<div class="input-group">
		<span class="input-group-text" id="basic-addon1">
			<svg class="icon icon-xs text-gray-600" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z"></path><path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z"></path></svg>
		</span>
<!---<input type="email" class="form-control" placeholder="example@company.com" id="email" autofocus required>--->
		<input type="text" name="username" id="username" maxlength="40" value="#request.username#" class="form-control" placeholder="example@company.com"  autofocus required/>
	</div>
	</div>
		<!-- End of Form -->
		<div class="form-group">
			<!-- Form -->
			<div class="form-group mb-4">
				<label for="password">Your Password</label>
				<div class="input-group">
					<span class="input-group-text" id="basic-addon2">
						<svg class="icon icon-xs text-gray-600" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"></path></svg>
					</span>
					<input type="password" placeholder="Password" class="form-control" id="password" name="password" required>
				</div>
			</div>
			<!-- End of Form -->
			<div class="d-flex justify-content-between align-items-top mb-4">
				<div class="form-check">
					<input class="form-check-input" type="checkbox" value="1" id="remember" name="remember">
					<label class="form-check-label mb-0" for="remember">
						Remember me
					</label>
				</div>
				<div><a href="login_forgot.cfm" class="small text-right">Lost password?</a></div>
			</div>
		</div>
		<div class="d-grid">
			<button type="submit" class="btn btn-gray-800">Sign in</button>
			<input type="hidden" name="login" id="submit" value="Login" />
		</div>
	</form>
</cfoutput>
	<div class="mt-4 mb-4 text-center"><a href="http://www.mangoblog.org" id="mangolink"><span>Powered by Mango Blog</span></a>
	</div>
</div>
</div>
</div>
</div>
</section>
</main>


<!-- Core -->
<script src="assets/js/vendor/@popperjs/core/dist/umd/popper.min.js"></script>
<script src="assets/js/vendor/bootstrap/dist/js/bootstrap.min.js"></script>

<!-- Vendor JS -->
<script src="assets/js/vendor/onscreen/dist/on-screen.umd.min.js"></script>

<!-- Slider -->
<script src="assets/js/vendor/nouislider/distribute/nouislider.min.js"></script>

<!-- Smooth scroll -->
<script src="assets/js/vendor/smooth-scroll/dist/smooth-scroll.polyfills.min.js"></script>

<!-- Charts -->
<script src="assets/js/vendor/chartist/dist/chartist.min.js"></script>
<script src="assets/js/vendor/chartist-plugin-tooltips/dist/chartist-plugin-tooltip.min.js"></script>

<!-- Datepicker -->
<script src="../..assets/js/vendor/vanillajs-datepicker/dist/js/datepicker.min.js"></script>

<!-- Sweet Alerts 2 -->
<script src="assets/js/vendor/sweetalert2/dist/sweetalert2.all.min.js"></script>

<!-- Moment JS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.27.0/moment.min.js"></script>

<!-- Vanilla JS Datepicker -->
<script src="assets/js/vendor/vanillajs-datepicker/dist/js/datepicker.min.js"></script>

<!-- Notyf -->
<script src="assets/js/vendor/notyf/notyf.min.js"></script>

<!-- Simplebar -->
<script src="assets/js/vendor/simplebar/dist/simplebar.min.js"></script>

<!-- Volt JS -->
<script src="assets/js/volt.js"></script>


</body>
</html>
