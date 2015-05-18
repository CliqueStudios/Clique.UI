(function(addon) {
	if(typeof define === 'function' && define.amd) {
		define('clique-form', ['clique'], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error('Clique.form requires Clique.core');
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	_c.component('checkbox', {
		boot: function() {
			return _c.on('ready', function(context) {
				return $('input[type="checkbox"]:not([data-switch])').each(function() {
					var ele;
					ele = $(this);
					if(!$(this).data('clique.data.checkbox')) {
						return _c.checkbox(ele);
					}
				});
			});
		},
		init: function() {
			if(!$(this.element).closest('.form-checkbox').length) {
				$(this.element).wrap("<span class='form-checkbox' />");
				$(this.element).after("<span />");
			}
			return this.triggerEvents();
		},
		triggerEvents: function() {
			return $(this.element).on('change', function(e) {
				if($(this.element).is(':checked')) {
					return $(this.element).trigger('clique.checkbox.checked');
				} else {
					return $(this.element).trigger('clique.checkbox.unchecked');
				}
			});
		}
	});
	return _c.component('radio', {
		boot: function() {
			return _c.on('ready', function(context) {
				return $('input[type="radio"]').each(function() {
					var ele;
					ele = $(this);
					if(!$(this).data('clique.data.radio')) {
						return _c.radio(ele);
					}
				});
			});
		},
		init: function() {
			if(!$(this.element).closest('.form-radio').length) {
				$(this.element).wrap("<span class='form-radio' />");
				$(this.element).after("<span />");
			}
			return this.triggerEvents();
		},
		triggerEvents: function() {
			return $(this.element).on('change', function(e) {
				if($(this.element).is(':checked')) {
					return $(this.element).trigger('clique.radio.checked');
				} else {
					return $(this.element).trigger('clique.radio.unchecked');
				}
			});
		}
	});
});
