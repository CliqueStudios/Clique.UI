(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-alert", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.alert requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	return _c.component("alert", {
		defaults: {
			fade: true,
			duration: 400,
			trigger: ".alert-close"
		},
		boot: function() {
			return _c.$html.on("click.alert.clique", "[data-alert]", function(e) {
				var ele, obj;
				ele = $(this);
				if(!ele.data("clique.data.alert")) {
					obj = _c.alert(ele, _c.utils.options(ele.attr("data-alert")));
					if($(e.target).is(obj.options.trigger)) {
						e.preventDefault();
						return obj.close();
					}
				}
			});
		},
		init: function() {
			return this.on("click", this.options.trigger, function(_this) {
				return function(e) {
					e.preventDefault();
					return _this.close();
				};
			}(this));
		},
		close: function() {
			var element, removeElement;
			element = this.trigger("close.clique.alert");
			removeElement = function(_this) {
				return function() {
					return _this.trigger("closed.clique.alert").remove();
				};
			}(this);
			if(this.options.fade) {
				return element.css({
					overflow: "hidden",
					"max-height": element.height()
				}).animate({
					height: 0,
					opacity: 0,
					"padding-top": 0,
					"padding-bottom": 0,
					"margin-top": 0,
					"margin-bottom": 0
				}, this.options.duration, removeElement);
			} else {
				return removeElement();
			}
		}
	});
});
