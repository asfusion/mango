<cfif thisTag.executionMode is "start">
<cfimport prefix="mangoAdmin" taglib="tags">
<cfimport prefix="mangoAdminPartials" taglib="partials">
<cfparam name="attributes.page" default=""/>
<cfparam name="attributes.title" default=""/>
<cfparam name="attributes.hierarchy" default="#arraynew()#"/>

<cfset blog = request.blogManager.getBlog() />
<cfset currentAuthor = request.blogManager.getCurrentUser() />

<cfcontent reset="false"><!DOCTYPE html>
	<html lang="#request.i18n.getLocale()#">
	<head><cfoutput>
		<meta http-equiv="Content-Type" content="text/html;charset=#blog.getCharset()#" />
		<!-- Primary Meta Tags -->
		<title>#attributes.title#</title>
	</cfoutput>
		<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

		<!-- Favicon -->
		<link rel="apple-touch-icon" sizes="120x120" href="assets/img/favicon/apple-touch-icon.png">
		<link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicon/favicon-32x32.png">
		<link rel="icon" type="image/png" sizes="16x16" href="assets/img/favicon/favicon-16x16.png">
		<link rel="manifest" href="assets/img/favicon/site.webmanifest">
		<link rel="mask-icon" href="assets/img/favicon/safari-pinned-tab.svg" color="#ffffff">
		<meta name="msapplication-TileColor" content="#ffffff">
		<meta name="theme-color" content="#ffffff">

		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

		<!-- Sweet Alert -->
		<link type="text/css" href="assets/js/vendor/sweetalert2/dist/sweetalert2.min.css" rel="stylesheet">

		<!-- Notyf -->
		<link type="text/css" href="assets/js/vendor/notyf/notyf.min.css" rel="stylesheet">

		<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js" ></script>
		<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.20.0/jquery.validate.min.js" ></script>
		<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.13.2/jquery-ui.min.js"></script>

		<!-- Charts -->
		<script src="assets/js/vendor/chartist/dist/chartist.min.js"></script>
		<script src="assets/js/vendor/chartist-plugin-tooltips/dist/chartist-plugin-tooltip.min.js"></script>

		<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/ionicons/4.5.6/css/ionicons.min.css" integrity="sha512-0/rEDduZGrqo4riUlwqyuHDQzp2D1ZCgH/gFIfjMIL5az8so6ZiXyhf1Rg8i6xsjv+z/Ubc4tt1thLigEcu6Ug==" crossorigin="anonymous" referrerpolicy="no-referrer" />
		<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.13.1/css/all.min.css" integrity="sha256-2XFplPlrFClt0bIdPgpz8H7ojnk10H69xRqd9+uTShA=" crossorigin="anonymous" />

		<!-- Volt CSS -->
		<link type="text/css" href="assets/styles/volt.css" rel="stylesheet">
		<link rel="stylesheet" href="assets/styles/fileexplorer.css">
		<link href="assets/styles/custom.css" rel="stylesheet" type="text/css" />
		<mangoAdmin:Event name="beforeAdminHeaderEnd" />
</head>
<body>

	<cf_navigation page="#attributes.page#">
	<main class="content">

	<nav class="navbar navbar-top navbar-expand navbar-dashboard ps-0 pe-2 pb-0">
	<div class="container-fluid px-0">
	<div class="d-flex justify-content-between w-100" id="navbarSupportedContent">
		<nav aria-label="#request.i18n.getValue('Breadcrumb')#" class="d-none d-md-inline-block">
			<ol class="breadcrumb breadcrumb-dark breadcrumb-transparent mb-0">
				<li class="breadcrumb-item">
					<a href="index.cfm">
						<i class="bi bi-house-door-fill icon icon-xxs"></i>
					</a>
				</li>
				<cfoutput>
				<cfif arraylen( attributes.hierarchy)>
				<cfloop array="#attributes.hierarchy#" item="i">
					<cfif structKeyExists( i, 'link' )>
						<li class="breadcrumb-item"><a href="#i.link#">#i.title#</a></li>
					<cfelse>
						<li class="breadcrumb-item active" aria-current="page">#i.title#</li>
					</cfif>
				</cfloop>
				<cfelse>
					<li class="breadcrumb-item active" aria-current="page">#attributes.title#</li>
				</cfif>
				</cfoutput>
			</ol>
		</nav>

		<!-- Navbar links -->
		<ul class="navbar-nav align-items-center">
			<li class="nav-item dropdown ms-lg-3">
				<a class="nav-link dropdown-toggle pt-1 px-0" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
					<div class="media d-flex align-items-center">
						<cfif len( currentAuthor.picture )><img class="avatar rounded-circle" alt="Image placeholder" src="#currentAuthor.picture#">
						<cfelse><span class="sidebar-icon"><i class="bi bi-gear-fill icon icon-xs"></i></span>
						</cfif>
						<div class="media-body ms-2 text-dark align-items-center d-none d-lg-block">
							<span class="mb-0 font-small fw-bold text-gray-900"><cfoutput>#currentAuthor.name#</cfoutput></span>
						</div>
					</div>
				</a>
				<div class="dropdown-menu dashboard-dropdown dropdown-menu-end mt-2 py-1">
					<a class="dropdown-item d-flex align-items-center" href="author.cfm?profile=1">
						<svg class="dropdown-icon text-gray-400 me-2" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-6-3a2 2 0 11-4 0 2 2 0 014 0zm-2 4a5 5 0 00-4.546 2.916A5.986 5.986 0 0010 16a5.986 5.986 0 004.546-2.084A5 5 0 0010 11z" clip-rule="evenodd"></path></svg>
						<cfoutput>#request.i18n.getValue("My Profile")#</cfoutput>
					</a>
					<div role="separator" class="dropdown-divider my-1"></div>
					<a class="dropdown-item d-flex align-items-center" href="index.cfm?logout=1">
						<svg class="dropdown-icon text-danger me-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
	<cfoutput>#request.i18n.getValue("Logout")#</cfoutput>
					</a>
				</div>
			</li>
		</ul>
	</div>
	</div>
	</nav>
</cfif>

<cfif thisTag.executionMode is "end">
	<cfoutput>
	<!---<div id="footer"><a href="http://www.mangoblog.org" id="mangolink"><span>Powered by Mango Blog></span></a> <span class="footer_version">&nbsp;&nbsp;<cfoutput>#request.blogManager.getVersion()#</cfoutput></span></div>
--->
	<div class="modal fade" id="filesModal" tabindex="-1" role="dialog" aria-hidden="true">

		<div class="modal-dialog modal-dialog-centered" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<p class="modal-title" id="modalTitleNotify">#request.i18n.getValue("Files")#</p>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="#request.i18n.getValue("Close")#"></button>
				</div>
				<div class="modal-body">
					<p>#request.i18n.getValue("Loading...")#</p>
				</div>
			</div>
		</div>

	</div>
	</cfoutput>
	</main>

<!-- Core -->
<script src="assets/js/vendor/@popperjs/core/dist/umd/popper.min.js"></script>
<script src="assets/js/vendor/bootstrap/dist/js/bootstrap.min.js"></script>

<!-- Vendor JS -->
<script src="assets/js/vendor/onscreen/dist/on-screen.umd.min.js"></script>

<!-- Slider -->
<script src="assets/js/vendor/nouislider/dist/nouislider.min.js"></script>
<!-- Smooth scroll -->
<script src="assets/js/vendor/smooth-scroll/dist/smooth-scroll.polyfills.min.js"></script>

<!-- Datepicker -->
<script src="assets/js/vendor/vanillajs-datepicker/dist/js/datepicker.min.js"></script>

<!-- Sweet Alerts 2 -->
<script src="assets/js/vendor/sweetalert2/dist/sweetalert2.all.min.js"></script>

<!-- Moment JS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.27.0/moment.min.js"></script>

<!-- Notyf -->
<script src="assets/js/vendor/notyf/notyf.min.js"></script>

<!-- Volt JS -->
<script src="assets/js/volt.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/simple-datatables@latest" type="text/javascript"></script>
	<script defer src="assets/js/vendor/fontawesome/all.js"></script>

	<!-- Entire bundle -->
	<script src="https://cdnjs.cloudflare.com/ajax/libs/draggable/1.0.1/draggable.bundle.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/draggable/1.0.1/sortable.min.js"></script>


	<script type="text/javascript" src="assets/scripts/utils.js" ></script>
	<script type="text/javascript" src="assets/scripts/admin.js" ></script>
	<script src="assets/js/vendor/alpinejs/3-13-7.min.js" defer></script>

	<mangoAdmin:Event name="beforeAdminHtmlBodyEnd" page="#attributes.page#" />

</body>

</html>
</cfif>