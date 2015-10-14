(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-password", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.password requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	_c.component("password", {
		defaults: {
			lblShow: "Show",
			lblHide: "Hide"
		},
		boot: function() {
			return _c.$html.on("click.password.clique", "[data-password]", function(e) {
				var ele, obj;
				ele = _c.$(this);
				if(!ele.data("clique.data.password")) {
					e.preventDefault();
					obj = _c.password(ele, _c.utils.options(ele.attr("data-password")));
					return ele.trigger("click");
				}
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.on("click", function(_this) {
				return function(e) {
					var type;
					e.preventDefault();
					if(_this.input.length) {
						type = _this.input.attr("type");
						_this.input.attr("type", type === "text" ? "password" : "text");
						return _this.element.text(_this.options[type === "text" ? "lblShow" : "lblHide"]);
					}
				};
			}(this));
			this.input = this.element.next("input").length ? this.element.next("input") : this.element.prev("input");
			this.element.text(this.options[this.input.is("[type='password']") ? "lblShow" : "lblHide"]);
			return this.element.data("password", this);
		}
	});
	return _c.password;
});
