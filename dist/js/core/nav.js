(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-nav", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.nav requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, getHeight;
	$ = _c.$;
	getHeight = function(ele) {
		var $ele, height, tmp;
		$ele = $(ele);
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
	};
	return _c.component("nav", {
		defaults: {
			toggle: ">li.parent > a[href='#']",
			lists: ">li.parent > ul",
			multiple: false
		},
		boot: function() {
			return _c.ready(function(context) {
				return $("[data-nav]", context).each(function() {
					var nav, obj;
					nav = $(this);
					if(!nav.data("clique.data.nav")) {
						obj = _c.nav(nav, _c.utils.options(nav.attr("data-nav")));
					}
				});
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.on("click.clique.nav", this.options.toggle, function(e) {
				var ele;
				e.preventDefault();
				ele = $(this);
				return $this.open(ele.parent()[0] === $this.element[0] ? ele : ele.parent("li"));
			});
			return this.find(this.options.lists).each(function() {
				var $ele, parent;
				$ele = $(this);
				parent = $ele.parent();
				$ele.wrap('<div style="overflow :hidden;height :0;position :relative;"></div>');
				parent.data("list-container", $ele.parent());
				parent.attr("aria-expanded", parent.hasClass("open"));
				if(parent.hasClass("active") || parent.hasClass("open")) {
					return $this.open(parent, true);
				}
			});
		},
		open: function(li, noAnimation) {
			var $li, $this, element;
			$this = this;
			element = this.element;
			$li = $(li);
			if(!this.options.multiple) {
				element.children(".open").not(li).each(function() {
					var ele;
					ele = $(this);
					if(ele.data("list-container")) {
						return ele.data("list-container").stop().animate({
							height: 0
						}, function() {
							return $(this).parent().removeClass("open");
						});
					}
				});
			}
			$li.toggleClass("open");
			$li.attr("aria-expanded", $li.hasClass("open"));
			if($li.data("list-container")) {
				if(noAnimation) {
					$li.data("list-container").stop().height($li.hasClass("open") ? "auto" : 0);
					return this.trigger("display.clique.check");
				} else {
					return $li.data("list-container").stop().animate({
						height: $li.hasClass("open") ? getHeight($li.data("list-container").find("ul:first")) : 0
					}, function() {
						return $this.trigger("display.clique.check");
					});
				}
			}
		}
	});
});
