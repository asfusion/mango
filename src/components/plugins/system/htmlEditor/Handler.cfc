<cfcomponent extends="org.mangoblog.plugins.BasePlugin">

	<cfset variables.package = "system/admin/htmleditor"/>
	<cfset variables.editors = structnew() />

	<cfset this.events = [ { 'name' = 'beforeAdminHeaderEnd', 'type' = 'sync', 'priority' = '5' }] />

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
						
			<cfset super.init(arguments.mainManager, arguments.preferences) />
			<cfset initSettings( editor = 'ckeditor', customConfig = '' ) />
			
		<cfreturn this/>
		
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var local = structnew() />
		<cfset var manager = getManager() />
		
		<cfif arguments.event.name EQ "beforeAdminHeaderEnd" AND manager.isCurrentUserLoggedIn()>
			
			<cfset local.blog = manager.getBlog() />
			<cfset local.assetsSettings = local.blog.getSetting('assets') />
			<cfset local.skin = manager.getAdministrator().getSkin( local.blog.getSkin() ) />
			<cfset local.data = '' />
			<cfset local.currentEditor = getSetting( 'editor' ) />
			
			<cfif local.currentEditor EQ "ckeditor" OR local.currentEditor EQ "tinymce">
					<cfset local.host = local.blog.getUrl() />
					<cfset local.basePath = local.blog.getBasePath() />
	
					<cfif findnocase( local.basePath, local.host)>
						<cfset host = left( local.host, len( local.host ) - len( local.basePath )) />		
					</cfif>
					<cfif find("/", local.assetsSettings.path) EQ 1>
						<!--- absolute path, prepend only domain --->
						<cfset local.fileUrl = local.host & local.assetsSettings.path />
					<cfelseif find("http", local.assetsSettings.path) EQ 1>
						<cfset local.fileUrl = local.assetsSettings.path />
					<cfelse>
						<cfset local.fileUrl = local.blog.getUrl() & local.assetsSettings.path />
					</cfif>
			</cfif>
			
			<cfif local.currentEditor EQ "ckeditor">
				<cfif NOT structKeyExists( variables.editors, 'ckeditor' )>
					<cfsavecontent variable="local.data">
	<cfoutput>
		<script src="assets/editors/ckeditor/ckeditor.js"></script>
		<script type="text/javascript">
		$(function() {
			ClassicEditor.create(document.querySelector('.htmlEditor'))
			.then( editor => {
				window.editor = editor;
			<cfif structKeyExists( local.skin, "adminEditorCss") AND len(local.skin.adminEditorCss)>
					editor.config.contentsCss = ['#local.basePath#skins/#local.blog.getSkin()#/#local.skin.adminEditorCss#'];
			</cfif>
			} )
				.catch(error => {
					console.error('There was a problem initializing the editor.', error);
				});
		});
		</script>
	</cfoutput>
				</cfsavecontent>
				<cfelse>
					<cfset local.data = variables.editors['ckeditor'] />
				</cfif>

			<cfelseif local.currentEditor EQ "tinymce">
				<cfif NOT structKeyExists( variables.editors, 'tinymce' )>
					<cfsavecontent variable="local.data">
	<cfoutput>
		<script type="text/javascript" src="assets/editors/tinymce/tinymce.min.js"></script>

		<script type="text/javascript">
tinymce.init({
			selector: '.htmlEditor',
			convert_urls: false,
			relative_urls: false,
            plugins: [ 'table', 'filemanager', 'link', 'code','lists', 'codesample' ],
			menubar: 'edit insert format tools', // exclude 'file'
            toolbar: 'filemanager undo redo blocks bold italic link blockquote ' +
            'bullist numlist table codesample removeformat',
			external_plugins: { "filemanager" : "plugins/filemanager/plugin.min.js"},
			fileManager_path : "assets/editors/tinymce/plugins/FileManager/files.cfm",

			// Control the toolbar that appears when you click a link
			link_context_toolbar: true, // default: true
			link_toolbar: 'openlink unlink | link',

			menu: {
				format: {
					title: 'Format',
					items: 'bold italic underline strikethrough superscript subscript | formats styles blocks | bullist numlist | blockquote removeformat'
				}
			},

			setup: function (editor) {
					editor.on('change', function () {
						tinymce.triggerSave();
					});
				}
			  });
      </script>
	</cfoutput>
			</cfsavecontent>
				<cfelse>
					<cfset local.data = variables.editors['tinymce'] />
				</cfif>
			</cfif>
			<cfset arguments.event.setoutputData( arguments.event.outputData & local.data ) />
		</cfif>
		
		<cfreturn arguments.event />
		
	</cffunction>

</cfcomponent>