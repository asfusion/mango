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
<!---
	tinyMCE.init({
		mode : "specific_textareas",
		editor_selector : "htmlEditor",
		theme : "advanced",
		plugins : "table,save,contextmenu,paste,noneditable,asffileexplorer",
		entity_encoding : "raw",
		theme_advanced_toolbar_location : "top",
		theme_advanced_toolbar_align : "left",
		theme_advanced_path_location : "bottom",
		theme_advanced_buttons1 : "bold,italic,formatselect,styleselect,bullist,numlist,del,separator,outdent,indent,separator,undo,redo,separator,link,unlink,anchor,image,cleanup,removeformat,charmap,code,help",
		theme_advanced_buttons2 : "",
		theme_advanced_buttons3 : "",
		paste_remove_spans: true,
		extended_valid_elements : "span[class|style],code[class]",
		theme_advanced_resize_horizontal : false,
		theme_advanced_resizing : true,
		relative_urls : false,
		remove_linebreaks : false,
		strict_loading_mode: tinymce.isWebKit,
		document_base_url : "#local.basePath#",
		<cfif len( local.skin.adminEditorCss )>
		content_css : "#local.basePath#skins/#local.blog.getSkin()#/#local.skin.adminEditorCss#",
		</cfif>
		#getSetting('customConfig')#
		plugin_asffileexplorer_browseurl : '#local.blog.getSetting('urls').admin#assets/editors/tinymce_3/jscripts/tiny_mce/plugins/asffileexplorer/fileexplorer.cfm',
		plugin_asffileexplorer_assetsUrl:'#local.fileUrl#',
		file_browser_callback : 'ASFFileExplorerPlugin_browse'
		,
		onchange_callback: function(editor) {
			tinyMCE.triggerSave();
			$("##" + editor.id).valid();
		}
	});
--->
tinymce.init({
selector: '.htmlEditor',
            plugins: [ 'table', 'filemanager' ],
            toolbar: 'filemanager undo redo | a11ycheck casechange blocks | bold italic backcolor | alignleft aligncenter alignright alignjustify |' +
            'bullist numlist checklist outdent indent | removeformat | code table help',
			external_plugins: { "filemanager" : "plugins/filemanager/plugin.min.js"},

			fileManager_path : "assets/editors/tinymce/plugins/FileManager/files.cfm",

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