<cfsilent>
<!--- Set Defaults values --->
	<cfparam name="request.email" default="" type="string" />
	<cfparam name="request.errormsg" default="" type="string" />
	<cfparam name="request.resultMessage" default="" type="string" />
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
<cfoutput>
	<!-- Section -->
	<section class="vh-lg-100 mt-5 mt-lg-0 bg-soft d-flex align-items-center">
		<div class="container">
			<div class="row justify-content-center form-bg-image">
				<p class="text-center"><a href="##" onclick="window.history.go(-1); return false;" class="d-flex align-items-center justify-content-center">
					<svg class="icon icon-xs me-2" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M7.707 14.707a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l2.293 2.293a1 1 0 010 1.414z" clip-rule="evenodd"></path></svg>
					Back to log in
				</a>
				</p>
				<div class="col-12 d-flex align-items-center justify-content-center">
					<div class="signin-inner my-3 my-lg-0 bg-white shadow border-0 rounded p-4 p-lg-5 w-100 fmxw-500">
						<h1 class="h3">Forgot your password?</h1>
						<cfif len(request.errormsg)><div class="alert alert-danger" role="alert">#request.errormsg#</div></cfif>
						<cfif len( request.resultMessage )><div class="alert alert-success" role="alert">#request.resultMessage#</div></cfif>
						<form action="#cgi.script_name#?#cgi.query_string#" method="post" class="mt-4">

						<p class="mb-4">Don't fret! Just type in your email and we will send you a code to reset your password!</p>
							<!-- Form -->
							<div class="mb-4">
								<label for="email">Your Email</label>
								<div class="input-group">
									<input type="email" class="form-control" id="email" name="email" value="#request.email#" placeholder="john@company.com" required autofocus>
								</div>
							</div>
							<!-- End of Form -->
							<div class="d-grid">
								<button type="submit" class="btn btn-gray-800">Recover password</button>
							</div>
						<input type="hidden" name="submit" id="submit" value="Login" />
						</form>
					</div>
				</div>
			</div>
		</div>
	</section>
</cfoutput>
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
