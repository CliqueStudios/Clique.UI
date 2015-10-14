(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-button", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.button requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, _target;
	$ = _c.$;
	_target = ".button, button";
	_c.component("buttonRadio", {
		defaults: {
			target: ".button"
		},
		boot: function() {
			return _c.$html.on("click.buttonRadio.clique", "[data-button-radio]", function(e) {
				var ele, obj, target;
				ele = $(this);
				if(!ele.data("clique.data.buttonRadio")) {
					obj = _c.buttonRadio(ele, _c.utils.options(ele.attr("data-button-radio")));
					target = $(e.target);
					if(target.hasClass(obj.options.target) || target.is("button")) {
						return target.trigger("click");
					}
				}
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.find(_target).attr("aria-checked", "false").filter(".active").attr("aria-checked", "true");
			return this.on("click", _target, function(e) {
				var ele;
				ele = $(this);
				if(ele.is('a[href="#"]')) {
					e.preventDefault();
				}
				$this.find(_target).not(ele).removeClass("active").blur();
				ele.addClass("active");
				$this.find(_target).not(ele).attr("aria-checked", "false");
				ele.attr("aria-checked", "true");
				return $this.trigger("change.clique.button", [ele]);
			});
		},
		getSelected: function() {
			return this.find(".active");
		}
	});
	_c.component("buttonCheckbox", {
		defaults: {
			target: ".button"
		},
		boot: function() {
			return _c.$html.on("click.buttonCheckbox.clique", "[data-button-checkbox]", function(e) {
				var ele, obj, target;
				ele = $(this);
				if(!ele.data("clique.data.buttonCheckbox")) {
					obj = _c.buttonCheckbox(ele, _c.utils.options(ele.attr("data-button-checkbox")));
					target = $(e.target);
					if(target.hasClass(obj.options.target) || target.is("button")) {
						return target.trigger("click");
					}
				}
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.find(_target).attr("aria-checked", "false").filter(".active").attr("aria-checked", "true");
			return this.on("click", _target, function(e) {
				var ele;
				ele = $(this);
				if(ele.is('a[href="#"]')) {
					e.preventDefault();
				}
				ele.toggleClass("active").blur();
				ele.attr("aria-checked", ele.hasClass("active"));
				return $this.trigger("change.clique.button", [ele]);
			});
		},
		getSelected: function() {
			return this.find(".active");
		}
	});
	return _c.component("button", {
		defaults: {},
		boot: function() {
			return _c.$html.on("click.button.clique", "[data-button]", function(e) {
				var ele, obj;
				ele = $(this);
				if(!ele.data("clique.data.button")) {
					obj = _c.button(ele, _c.utils.options(ele.attr("data-button")));
					return ele.trigger("click");
				}
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.element.attr("aria-pressed", this.element.hasClass("active"));
			return this.on("click", function(e) {
				if($this.element.is('a[href="#"]')) {
					e.preventDefault();
				}
				$this.toggle();
				return $this.trigger("change.clique.button", [$this.element.blur().hasClass("active")]);
			});
		},
		toggle: function() {
			this.element.toggleClass("active");
			return this.element.attr("aria-pressed", this.element.hasClass("active"));
		}
	});
});
