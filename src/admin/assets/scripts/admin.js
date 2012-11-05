/*
 * Admin functions for Mango Blog
 * 
 * Dependent on:
 * 
 * jQuery
 * 		http://www.jquery.com
 * 		Usage: http://docs.jquery.com
 * 
 * jQuery Validation plugin
 * 		http://bassistance.de/jquery-plugins/jquery-plugin-validation/
 * 		Usage: http://docs.jquery.com/Plugins/Validation
 * 
 * jQuery Metadata plugin (used for configuring validation rules)
 * 		http://plugins.jquery.com/project/metadata
 */


$(function(){
	
	/*
	 * ==========================================================================
	 * For each field that has a hint, set up a help icon to show/hide the hint;
	 * and hide all hints on page load
	 */
	$('p,li','form').each(function(){
		var label = $(this).children('label');
		var hint = $(this).children('span.hint');
		if (hint.length) {
			hint.hide();
			$('<img src="assets/images/icons/help.png" width="16" height="16" alt="" class="helpicon" />')
				.click(function(){
					hint.toggle();
				})
				.hover(function(){
					$(this).addClass('helpicon-over');
				},function(){
					$(this).removeClass('helpicon-over');					
				})
				.insertAfter(label);
		}
	});
	
	/*
	 * ==========================================================================
	 * Add a "required" text label to all required fields
	 */
	$('.required','form').each(function(){
		var id = $(this).attr('id');
		if (id.length) $('label[for='+id+']').append(' <span>(required)</span>');
	});
	
	/*
	 * ==========================================================================
	 * Set up a button to enable/disable rich text editing (TinyMCE)
	 */
	$('.htmlEditor','form').each(function(){
		var id = $(this).attr('id');
		var button = $('<span> <img src="assets/images/icons/page_edit.png" width="16" height="16" alt="" title="Click to enable/disable the rich text editor" class="helpicon" /></span>')
			.click(function(){
				toggleEditor(id);
			});
		$(this).parents('span.field').siblings('label').after(button);
	});
	
	/*
	 * ==========================================================================
	 * If a form has more than one hint, add a button to show/hide all hints
	 */
	var hints = $('span.hint');
	if (hints.length > 1) {
		$('<span class="allhints"><img src="assets/images/icons/help.png" width="16" height="16" alt="" class="helpicon" /> Show/hide all hints</span>')
		.click(function(){
			var hidden_hints = hints.filter(':hidden');
			if (hidden_hints.length) {
				hints.show();
			} else {
				hints.hide();
			}
		})
		.appendTo($('h2.pageTitle'));
	}
	
	
	/*
	 * ==========================================================================
	 * Set up delete confirmation
	 */
	$('.deleteButton').click(function(){
		return confirm('Are you sure you want to delete this item?');
	});
	
	/*
	 * ==========================================================================
	 * Initialise form validation
	 */
	var validator = $('form').submit(function() {
		// update underlying textarea before submit validation
		tinyMCE.triggerSave();
	}).validate({
		errorPlacement: function(error, element){
			error.appendTo(element.parents('p'));
		}
	});
	
	try {
		validator.focusInvalid = function(){
			// put focus on tinymce on submit validation
			if (this.settings.focusInvalid) {
				try {
					var toFocus = $(this.findLastActive() || this.errorList.length && this.errorList[0].element || []);
					if (toFocus.is("textarea.htmlEditor")) {
						tinyMCE.get(toFocus.attr("id")).focus();
					}
					else {
						toFocus.filter(":visible").focus();
					}
				} 
				catch (e) {
				// ignore IE throwing errors when focusing hidden elements
				}
			}
		}
	} catch (e) {}
	
	/*
	 * ==========================================================================
	 * Additional form validation method for URLs which allows domains such as 'localhost'
	 */
	jQuery.validator.addMethod("url2", function(value, element, param) {
		return this.optional(element) || /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)*(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value); 
	}, jQuery.validator.messages.url);
	
	/*
	 * ==========================================================================
	 * Additional form validation method for URL-safe page title
	 */
	jQuery.validator.addMethod("urlslug", function (value, element, param) { 
	    return this.optional(element) || /^[a-z0-9]+(-[a-z0-9]+)*$/.test(value); 
	}, "Please enter only a-z, 0-9 or -, not starting or ending with a -");
	
	/*
	 * ==========================================================================
	 * Update all form fields so they have a class matching their type, for styling in older browsers (IE6!)
	 */
	$('tr.plugin_head').hover(function(){
		$(this).children('th').addClass('hover');
	}, function(){
		$(this).children('th').removeClass('hover');		
	});
	
	/*
	 * ==========================================================================
	 * Update all form fields so they have a class matching their type, for styling in older browsers (IE6!)
	 */
	$('input','form').each(function(){
		$(this).addClass($(this).attr('type'));
	});
});



/*
 * ==========================================================================
 * Function to enable/disable tinyMCE rich text editing
 */
function toggleEditor(id) {
	if (!tinyMCE.getInstanceById(id))
		tinyMCE.execCommand('mceAddControl', false, id);
	else
		tinyMCE.execCommand('mceRemoveControl', false, id);
}


/*
 * ==========================================================================
 * Function to unobtrusively add onLoad events
 */
function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

/*
 * ==========================================================================
 * Module to handle assetSelector functionality
 */
var mango = mango || {};
	mango.assetSelectorInputName = '';
	mango.dialogDefined = false;

	mango.addAssetSelectors = function(){
		//make sure jQuery is available
		if (typeof(jQuery) == 'undefined'){ alert('mango.addAssetSelectors: Can\'t find jQuery!'); return; }
		//find each occurrence of <input class="assetSelector">
		$("input.assetSelector").each(function(){
			var fldname = $(this)[0].name;
			var newimgid = 'assetSelector_' + fldname;
			$(this).after('<img src="assets/images/icons/folder_explore.png" id="' + newimgid + '" style="border:0;margin:0 0 0 5px;position:relative;top:3px;" />');
			
			$('#' + newimgid).css("cursor", "pointer").click(function(){
				mango.assetSelectorInputName = fldname;
				$("#assetSelector").dialog("open");
				$("#assetSelector").load('assetSelector.cfm?initialPath=' + 
					escape($("input[name=" + fldname + "]")[0].value) + 
					' #flashWidget');
				return false;
			});
			
			//only define the dialog window once, not once per assetSelector on the page
			if (!mango.dialogDefined) {
				$('#assetSelector').dialog({
					autoOpen: false,
					width: 770,
					height: 500,
					title: "Choose a file..."
				});
				mango.dialogDefined = true;
			}

		});
	};
	
	mango.assetSelectorCallback = function(valu){
		$("input[name=" + mango.assetSelectorInputName + "]")[0].value = valu;
		$("#assetSelector").dialog("close");
	};

//add an event to run the assetSelector script on page load 
addLoadEvent(mango.addAssetSelectors);