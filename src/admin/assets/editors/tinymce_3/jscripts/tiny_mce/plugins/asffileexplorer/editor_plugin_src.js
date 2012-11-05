/**
 * File Explorer plugin cannot be used outside MangoBlog. Please visit asfusion.com 
 * to get a commercial version
 *
 * @author AsFusion
 * @copyright Copyright ©2008, AsFusion, All rights reserved.
 */

function ASFFileExplorerPlugin_browse(field_name, current_url, type, win) {

	var url = tinyMCE.activeEditor.getParam('plugin_asffileexplorer_browseurl') + "?type=" + type;

	tinyMCE.activeEditor.windowManager.open({
        file : url,
        title : 'File Browser',
        width : 600, 
        height : 450,
        resizable : "yes",
        inline : "yes",  // This parameter only has an effect if you use the inlinepopups plugin!
        close_previous : "no"
    }, {
        window : win,
        input : field_name
    });
    return false;
};