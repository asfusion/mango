<cfsilent>
	<cfparam name="error" default="">
	<cfparam name="message" default="">
	
	<cfset currentAuthor = request.blogManager.getCurrentUser() />
	<cfset currentRole = currentAuthor.getCurrentRole(request.blogManager.getBlog().getId())/>
	
	<cfif listfind(currentRole.permissions, "manage_plugins") AND structkeyexists(form,"pluginUrl") and isvalid("url",form.pluginUrl)>
		<cfset result = request.formHandler.handleDownloadPlugin(form) />
		<cfif result.message.getStatus() EQ "success">
			<cfset message = result.message.getText() />
		<cfelse>
			<cfset error = result.message.getText() />
		</cfif>
		<cfelseif structkeyexists(form,"pluginUrl") and NOT isvalid("url",form.pluginUrl) >
		<cfset error = "Download URL is not valid" />
	<cfelseif structkeyexists(url,"action")>
		<cfif url.action NEQ "remove" OR listfind(currentRole.permissions, "manage_plugins")>
			<cfset result = request.formHandler.handleActivatePlugin(url) />
			<cfif result.message.getStatus() EQ "success">
				<cfset message = result.message.getText() />
			<cfelse>
				<cfset error = result.message.getText() />
			</cfif>
		</cfif>
	</cfif>
	
	<cfset plugins = request.administrator.getPlugins() />
	<cfset inactivePlugins = arraynew(1) />
	<cfset activePlugins = arraynew(1) />
	
	<cfloop from="1" to="#arraylen(plugins)#" index="i">
		<cfif plugins[i].active>
			<cfset arrayappend(activePlugins,plugins[i]) />
		<cfelse>
			<cfset arrayappend(inactivePlugins,plugins[i]) />
		</cfif>
	</cfloop>
	
</cfsilent>
<cf_layout page="Plugins" title="Plugins">
	<cfif listfind(currentRole.permissions, "manage_plugins") OR listfind(currentRole.permissions, "set_plugins")>
		<h2 class="h4">Plugins</h2>

		<cfoutput>
		<cfif len(message)><div class="alert alert-success" role="alert">#message#</div></cfif>
		<cfif len(error)><div class="alert alert-danger" role="alert">#error#</div></cfif>
			<cfif listfind(currentRole.permissions, "manage_plugins")>
			<button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="##downloadModal">Download new or update</button>
			</cfif>
<cfif arraylen(activeplugins)>

<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
<div class="card card-body border-0 shadow table-wrapper table-responsive">
<table class="table table-hover">
	<thead>
	<tr>
		<th class="border-gray-200">#request.i18n.getValue("Name")#</th>
		<th class="border-gray-200">#request.i18n.getValue("Description")#</th>
		<th class="border-gray-200">#request.i18n.getValue("Actions")#</th>
	</tr>
	</thead>
<tbody>
<cfloop from="1" to="#arraylen(activePlugins)#" index="i">
	<tr>
		<td>#activePlugins[i].name# <i>#activePlugins[i].version#</i></td>
		<td>#activePlugins[i].description#</td>
	<cfif listfind(currentRole.permissions, "manage_plugins")>
		<td style="white-space: nowrap;">
		<a href="addons.cfm?action=deactivate&amp;id=#activePlugins[i].id#&amp;name=#listgetat(activePlugins[i].class,1,'.')#"><button class="btn btn-outline-gray-500 btn-sm" type="button">De-activate</button></a>
		</td></cfif>
	</tr>
</cfloop>
	</tbody>
</table>
</div>
</div>
</cfif>

<cfif arraylen(inactiveplugins)>
<h2 class="h4">Not Active</h2>

<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center py-4">
<div class="card card-body border-0 shadow table-wrapper table-responsive">
<table class="table table-hover">
	<thead>
	<tr>
		<th class="border-gray-200">Name</th>
		<th class="border-gray-200">Decription</th>
		<th class="border-gray-200">Actions</th>
	</tr>
	</thead>
<tbody>
	<cfloop from="1" to="#arraylen(inactivePlugins)#" index="i">
		<tr>
		<td>#inactivePlugins[i].name# <i>#inactivePlugins[i].version#</i></td>
		<td>#inactivePlugins[i].description#</td>
		<td style="white-space: nowrap;"><cfif listfind(currentRole.permissions, "manage_plugins")>
			<a href="addons.cfm?action=activate&amp;id=#inactivePlugins[i].id#&amp;name=#listgetat(inactivePlugins[i].class,1,'.')#"><button class="btn btn-outline-success btn-sm" type="button">Activate</button></a>
		<a href="addons.cfm?action=remove&amp;id=#inactivePlugins[i].id#&amp;name=#listgetat(inactivePlugins[i].class,1,'.')#" class="deleteButton"><button class="btn btn-outline-danger btn-sm" type="button">Delete</button></a>
	</cfif>
	</td>
	</tr>

	</cfloop>
	</tbody>
	</table>
	</div>
	</div>
</cfif>

	<cfif listfind(currentRole.permissions, "manage_plugins")>
		<!-- Modal -->
		<div class="modal fade" id="downloadModal" tabindex="-1" role="dialog">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title">Install or Update Plugin</h5>
						<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
					</div>
					<form action="" method="post" role="form">
						<div class="modal-body">
							<div class="mb-3">
								<label for="pluginUrl">URL of plugin to download</label>
								<span class="form-text hint">Enter the full URL of the plugin - this should be a .zip file.<br />
If the plugin is already installed, it will be updated with the new version.</span>
								<input type="text" class="form-control" name="pluginUrl" id="pluginUrl" size="60" />
							</div>
						</div>
						<div class="modal-footer">
							<input type="submit" value="Download plugin" class="btn btn-primary" />
						</div>
					</form>
				</div>
			</div>

		</div>
	</cfif>
</cfoutput>

<cfelse><!--- not authorized --->
	<div class="alert alert-info" role="alert">Your role does not allow managing plugins</div>
</cfif>
</cf_layout>