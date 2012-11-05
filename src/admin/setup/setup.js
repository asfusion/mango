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
	
	$('.switched').hide();
	$('.switch').each(function(){
		var $this = $(this);
		var group = $this.attr('class').replace(/.*group-(.).*/,"$1");
		var activate = $this.attr('class').replace(/.*activate-(.).*/,"$1");
		if ($this.is(':checked')) $('.switched').filter('.active-'+activate).show();
		$this.click(function(){
			//console.log(group + ',' + activate);
			$('.switched').filter('.group-'+group).hide();
			if (activate.length == 1) $('.switched').filter('.active-'+activate).show();
		});
	});
	
	
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
			$('<img src="../assets/images/icons/help.png" width="16" height="16" alt="" class="helpicon" />')
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
	 * Initialise form validation
	 */
	var validator = $('form').validate({
		ignore: ":hidden :input",
		errorPlacement: function(error, element){
			error.appendTo(element.parents('p'));
		}
	});
	
	/*
	 * ==========================================================================
	 * Additional form validation method for URLs which allows domains such as 'localhost'
	 */
	jQuery.validator.addMethod("url2", function(value, element, param) {
		return this.optional(element) || /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)*(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value); 
	}, jQuery.validator.messages.url);
	
	jQuery.validator.addMethod("alphanumeric", function(value, element) {
		return this.optional(element) || /^\w+$/i.test(value);
	}, "Letters, numbers or underscores only please");
	/*
	 * ==========================================================================
	 * Update all form fields so they have a class matching their type, for styling in older browsers (IE6!)
	 */
	$('input','form').each(function(){
		$(this).addClass($(this).attr('type'));
	});
});
