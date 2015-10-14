(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-radioCheckboxes", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.radioCheckboxes requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	_c.component("radioCheckboxes", {
		boot: function() {
			_c.$doc.on("ready", function() {
				_c.$('input[type="checkbox"]:not([data-switch]), input[type="radio"]').each(function() {
					var ele;
					ele = $(this);
					if(!ele.data("clique.data.radioCheckboxes")) {
						_c.radioCheckboxes(ele);
					}
				});
			});
		},
		init: function() {
			var ele = $(this.element);
			this.type = ele.attr("type");
			if(!ele.closest(".form-" + this.type).length) {
				ele.wrap("<span class='form-" + this.type + "' />");
				ele.after("<span class='form-" + this.type + "-check' />");
			}
			this.updateClasses();
			this.bindListeners();
			this.bindEvents();
		},
		updateClasses: function() {
			var ele = $(this.element);
			var wrapper = ele.closest(".form-" + this.type);
			if(ele.is(":disabled")) {
				wrapper.addClass("disabled");
			} else {
				wrapper.removeClass("disabled");
			}
			if(ele.is(":checked")) {
				wrapper.removeClass("unchecked").addClass("checked");
			} else {
				wrapper.removeClass("checked").addClass("unchecked");
			}
		},
		bindListeners: function() {
			var $this = this;
			this.on("clique." + this.type + ".checked clique." + this.type + ".unchecked", function() {
				$this.updateClasses();
			});
		},
		bindEvents: function() {
			var ele = $(this.element);
			ele.on("change", function() {
				if(ele.is(":checked")) {
					ele.trigger("clique." + this.type + ".checked");
				} else {
					ele.trigger("clique." + this.type + ".unchecked");
				}
			});
		}
	});
});
