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

	<cfset skinSettings = blog.getSetting('skins') />
	<cfset currentSkin = request.administrator.getSkin( skin ) />
	<cfset currentTemplates = request.administrator.getCurrentTemplates() />
	<cfset breadcrumb = [ { 'link' = 'skins.cfm', 'title' = request.i18n.getValue("Design") },
	{ 'title' = request.i18n.getValue("Theme chooser") } ] />
</cfsilent>

<cf_layout page="Themes" title="Design" hierarchy="#breadcrumb#">
<cfoutput>
	<nav class="nav navbar-dashboard navbar-dark flex-column flex-sm-row mb-4">
		<a href="skins.cfm" class="active nav-link">
			<span class="sidebar-icon">
				<i class="bi icon icon-xs"></i>
			</span>
			<span class="sidebar-text">#request.i18n.getValue("Themes")#</span>
		</a>
	<cfif arraylen( currentSkin.settings )>
		<a href="skins_settings.cfm" class="nav-link">
			<span class="sidebar-icon">
				<i class="bi icon icon-xs"></i>
			</span>
			<span class="sidebar-text">#request.i18n.getValue("Theme settings")#</span>
		</a>
	</cfif>
	<cfif arraylen( currentTemplates )>
		
			<cfloop array="#currentTemplates#" item="templateitem">
					<a href="skins_settings.cfm?template=#templateitem.template#" class="nav-link">
					<span class="sidebar-icon">
				<i class="bi icon icon-xs"></i>
			</span>
				<span class="sidebar-text">#request.i18n.getValue("{1} settings", [templateitem.label])#</span>
				</a>
			</cfloop>
		
	</cfif>
		<mangoAdmin:SecondaryMenuEvent name="skinsNav" includewrapper="false" />
	</nav>
	<cfif listfind(currentRole.permissions, "manage_themes") OR listfind(currentRole.permissions, "set_themes")>
		
			<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
			<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>

			<div class="row">
			<cfloop from="1" to="#arraylen(skins)#" index="i">
				<cfif skins[i].id EQ skin>
						<div class="col-xl-3 col-md-6 mb-4" x-data="{ hasUpdate: false, fetch() {
     			 	fetch( 'datasets/downloadableSkins.cfm?action=checkUpdates&skin=#skins[i].id#' )
                            .then((response) => response.json())
                            .then((data) => {
                                this.hasUpdate = data.updated;
                            });
     			 	}
				}" x-init="fetch()">
					<div class="card shadow border-0 text-center p-0">
							<img class="card-img-top rounded-top" src="#request.administrator.getBlog().getUrl()#skins/#skins[i].id#/#skins[i].thumbnail#">
					<div class="card-body">
					<h4 class="card-title h3">#skins[i].name# <cfif len(skins[i].version)><span class="badge bg-info">#skins[i].version#</cfif></h4>
					<template x-if="hasUpdate">
					<div class="alert alert-secondary mt-3">#request.i18n.getValue("There is an update available for this theme.")# <a class="btn btn-outline-primary mt-1" href="#cgi.script_name#?action=download&amp;skin=#skins[i].id#">#request.i18n.getValue("Download")#</a></div>
					</template>
					</div>
						<div class="card-body text-white bg-gray-600 rounded-bottom">#request.i18n.getValue("Current theme")#</div>

					</div>
					</div>
				</cfif>
			</cfloop>
			<cfloop from="1" to="#arraylen(skins)#" index="i">
				<cfif skins[i].id NEQ skin><!--- exclude current skin --->
						<div class="col-xl-3 col-md-6" x-data="{ hasUpdate: false, fetch() {
     			 	fetch( 'datasets/downloadableSkins.cfm?action=checkUpdates&skin=#skins[i].id#' )
                            .then((response) => response.json())
                            .then((data) => {
                                this.hasUpdate = data.updated;
                            });
     			 	}
				}" x-init="fetch()">
					<div class="card shadow border-0 text-center p-0">
						<img class="card-img-top rounded-top" src="#request.administrator.getBlog().getUrl()#skins/#skins[i].id#/#skins[i].thumbnail#">
					<div class="card-body">
					<h4 class="card-title h3">#skins[i].name# <cfif len(skins[i].version)><span class="badge bg-info">#skins[i].version#</cfif></h4>
					</div>
					<div class="card-footer">
							<a href="#cgi.script_name#?action=set&amp;skin=#skins[i].id#" class="btn btn-sm btn-primary d-inline-flex align-items-center me-2">#request.i18n.getValue("Use this theme")#</a>
							<a class="btn btn-sm btn-outline-danger deleteButton" href="#cgi.script_name#?action=delete&amp;skin=#skins[i].id#">#request.i18n.getValue("Delete")#</a>
					<template x-if="hasUpdate">
					<div class="alert alert-secondary mt-3">#request.i18n.getValue("There is an update available for this theme.")# <a class="btn btn-outline-primary mt-1" href="#cgi.script_name#?action=download&amp;skin=#skins[i].id#">#request.i18n.getValue("Download")#</a></div>
					</template>
					</div>
					</div>
					</div>
				</cfif>
			</cfloop>
			</div>

			<cfif listfind(currentRole.permissions, "manage_themes")>
				<hr />
				<h2 class="h4 m-4">#request.i18n.getValue("Download themes")#</h2>
				<div x-data="data()">
					<div class="d-flex justify-content-center">
						<div class="pt-4" x-show="loading">
							<div class="spinner-border" role="status">
							</div>
						</div>
					</div>
					<div class="row" x-show="!loading">
						<template x-for="item in skins" >
							<div class="col-xl-3 col-md-6 ">
								<div class="card shadow border-0 text-center p-0 mb-5">
									<img class="card-img-top rounded-top"  :src="item.thumbnail">
									<div class="card-body">
										<h4 class="card-title h3" x-text="item.name"></h4>
									</div>
									<div class="card-footer">
										<a @click="download( item.id )" class="btn btn-sm btn-primary d-inline-flex align-items-center me-2">#request.i18n.getValue("Download")#</a>
									</div>
								</div>
							</div>
						</template>
					</div>
				</div>
			</cfif>

	<cfelse><!--- not authorized --->
		<div class="alert alert-info" role="alert">#request.i18n.getValue("Your role does not allow editing themes")#</div>
	</cfif>
</cfoutput>
</cf_layout>
<script type="text/javascript">
	function data() {
		return {
			skins: [],
			loading: false,
			init() {
				this.fetchData();
			},
			fetchData( ) {
				this.loading = true;
				fetch(`datasets/downloadableSkins.cfm`)
						.then((res) => res.json())
						.then((data) => {
							this.skins = data;
							this.loading = false;
						});
			},
			download( id ){
				window.location.href = 'skins.cfm?action=download&skin=' + id;
			}
		}
	};
	function updates() {

	}
</script>