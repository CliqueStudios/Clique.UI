(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-accordion", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.accordion requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	_c.component("accordion", {
		defaults: {
			showfirst: true,
			collapse: true,
			animate: true,
			easing: "swing",
			duration: 300,
			toggle: ".accordion-title",
			containers: ".accordion-content",
			clsactive: "active"
		},
		boot: function() {
			return _c.ready(function(context) {
				return setTimeout(function() {
					return _c.$("[data-accordion]", context).each(function() {
						var ele;
						ele = _c.$(this);
						if(!ele.data("clique.data.accordion")) {
							return _c.accordion(ele, _c.utils.options(ele.attr("data-accordion")));
						}
					});
				}, 0);
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.element.on("click.clique.accordion", this.options.toggle, function(e) {
				e.preventDefault();
				return $this.toggleItem(_c.$(this).data("wrapper"), $this.options.animate, $this.options.collapse);
			});
			this.update();
			if(this.options.showfirst) {
				return this.toggleItem(this.toggle.eq(0).data("wrapper"), false, false);
			}
		},
		getHeight: function(ele) {
			var $ele, height, tmp;
			$ele = _c.$(ele);
			height = "auto";
			if($ele.is(":visible")) {
				height = $ele.outerHeight();
			} else {
				tmp = {
					position: $ele.css("position"),
					visibility: $ele.css("visibility"),
					display: $ele.css("display")
				};
				height = $ele.css({
					position: "absolute",
					visibility: "hidden",
					display: "block"
				}).outerHeight();
				$ele.css(tmp);
			}
			return height;
		},
		toggleItem: function(wrapper, animated, collapse) {
			var $this, active;
			$this = this;
			wrapper.data("toggle").toggleClass(this.options.clsactive);
			active = wrapper.data("toggle").hasClass(this.options.clsactive);
			if(collapse) {
				this.toggle.not(wrapper.data("toggle")).removeClass(this.options.clsactive);
				this.content.not(wrapper.data("content")).parent().stop().animate({
					height: 0
				}, {
					easing: this.options.easing,
					duration: animated ? this.options.duration : 0
				}).attr("aria-expanded", "false");
			}
			if(animated) {
				wrapper.stop().animate({
					height: active ? $this.getHeight(wrapper.data("content")) : 0
				}, {
					easing: this.options.easing,
					duration: this.options.duration,
					complete: function() {
						if(active) {
							_c.utils.checkDisplay(wrapper.data("content"));
							wrapper.height("auto");
						}
						return $this.trigger("display.clique.check");
					}
				});
			} else {
				wrapper.stop().height(active ? "auto" : 0);
				if(active) {
					_c.utils.checkDisplay(wrapper.data("content"));
				}
				this.trigger("display.clique.check");
			}
			wrapper.attr("aria-expanded", active);
			return this.element.trigger("toggle.clique.accordion", [active, wrapper.data("toggle"), wrapper.data("content")]);
		},
		update: function() {
			var $this;
			$this = this;
			this.toggle = this.find(this.options.toggle);
			this.content = this.find(this.options.containers);
			this.content.each(function(index) {
				var $content, $toggle, $wrapper;
				$content = _c.$(this);
				if($content.parent().data("wrapper")) {
					$wrapper = $content.parent();
				} else {
					$wrapper = _c.$(this).wrap('<div data-wrapper="true" style="overflow :hidden;height :0;position :relative;"></div>').parent();
					$wrapper.attr("aria-expanded", "false");
				}
				$toggle = $this.toggle.eq(index);
				$wrapper.data("toggle", $toggle);
				$wrapper.data("content", $content);
				$toggle.data("wrapper", $wrapper);
				return $content.data("wrapper", $wrapper);
			});
			return this.element.trigger("update.clique.accordion", [this]);
		}
	});
	return _c.accordion;
});
