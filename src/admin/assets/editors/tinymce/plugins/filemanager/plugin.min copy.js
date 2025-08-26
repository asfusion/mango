/**
 * ColdFusion File Manager Plugin for TinyMCE 4
 *
 * Saman W Jayasekara sam@cflove.org
 * Twitter : cfloveorg 
 *
 */

tinymce.PluginManager.add('filemanager', function(editor, url) {

	if (typeof fileManager != 'undefined') {
		var fileManager = editor.settings.fileManager_path;
	} else {
		var fileManager = 'plugins/filemanager/files.cfm'
	}
	
	// Add a button that opens a window
	editor.addButton('filemanager', {
		tooltip: 'Insert From My Files',
		icon: 'browse',
		onclick: showDialog
	});

	function showDialog() {
			editor.windowManager.open({ 
				url: fileManager,
				title: 'My Files Home',
				width: Number($(window).innerWidth()) - 40,
				height: Number($(window).innerHeight()) - 80  
			});

	}
	// Adds a menu item to the tools menu
	editor.addMenuItem('filemanager', {
		text: 'My Files',
		context: 'insert',
		icon: 'browse',
		onclick: showDialog
	});
});