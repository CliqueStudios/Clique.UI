(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-switch", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.switch requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	_c.component("switch", {
		defaults: {
			labels: {
				off: "Off",
				on: "On"
			}
		},
		boot: function() {
			return _c.ready(function(context) {
				return _c.$("[data-switch]", context).each(function() {
					var ele, obj;
					ele = _c.$(this);
					if(!ele.data("clique.data.switch")) {
						obj = _c["switch"](ele, _c.utils.options(ele.attr("data-switch")));
					}
				});
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.create(this.element);
			this.destroy = this.destroy;
			return this.element.data("switch", this);
		},
		create: function($input) {
			var $container, $this, $wrapper, elementArray, i;
			if(typeof $input === "undefined") {
				$input = this.element;
			}
			$this = this;
			$input.wrap('<div class="switch" />');
			$wrapper = this.$wrapper = $input.closest(".switch");
			$wrapper.wrapInner('<div class="switch-container" />');
			$container = $wrapper.children(".switch-container");
			elementArray = ['<div class="switch-handle on"><label>' + this.options.labels.on + "</label></div>", '<div class="switch-label" />', '<div class="switch-handle off"><label>' + this.options.labels.off + "</label></div>"];
			i = 0;
			while(i < elementArray.length) {
				$container.append(elementArray[i]);
				i++;
			}
			this.set("state", $input.is(":checked"));
			this.$wrapper.on("click", function(e) {
				return $this.toggle($this.element);
			});
			return this.element.trigger("init.clique.switch");
		},
		destroy: function() {
			this.$wrapper.find(".switch-handle, .switch-label").remove();
			this.element.unwrap().unwrap();
			return this.element.removeData(["clique.data.switch", "switch"]);
		},
		toggle: function($input) {
			var $this, state;
			if(typeof $input === "undefined") {
				$input = this.element;
			}
			$this = this;
			$input.trigger("willswitch.clique.switch");
			this.$wrapper.one(_c.support.transition.end, function() {
				return $input.trigger("didswitch.clique.switch", [$this.state]);
			});
			state = this.state === "on" ? true : false;
			return this.set("state", !state);
		},
		set: function(prop, val) {
			if(prop === "state") {
				if(_c.utils.isString(val)) {
					if(val.toLowerCase() === "on") {
						val = true;
					} else {
						val = false;
					}
				}
				this.state = val ? "on" : "off";
				this.$wrapper.removeClass("on off");
				this.$wrapper.addClass(this.state);
				this.element.prop("checked", val);
				return this.element.prop("on", val);
			}
		}
	});
	return _c["switch"];
});
