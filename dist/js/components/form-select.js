(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-form.select", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.form.select requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	_c.component("formSelect", {
		defaults: {
			target: ">span:first"
		},
		boot: function() {
			return _c.ready(function(context) {
				return _c.$("[data-form-select]", context).each(function() {
					var ele, obj;
					ele = _c.$(this);
					if(!ele.data("clique.data.formSelect")) {
						obj = _c.formSelect(ele, _c.utils.options(ele.attr("data-form-select")));
					}
				});
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.target = this.find(this.options.target);
			this.select = this.find("select");
			this.select.on("change", function(_this) {
				return function() {
					var fn, select;
					select = _this.select[0];
					fn = function() {
						try {
							this.target.text(select.options[select.selectedIndex].text);
						} catch(_error) {}
						return fn;
					};
					return fn();
				};
			}(this)());
			return this.element.data("formSelect", this);
		}
	});
	return _c.formSelect;
});
