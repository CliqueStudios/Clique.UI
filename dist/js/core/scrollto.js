(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-scrollto", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.scrollTo requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $ = _c.$;
	_c.component("scrollTo", {
		defaults: {
			duration: 1e3,
			transition: "easeOutExpo",
			offset: 0
		},
		boot: function() {
			return _c.$html.on("click.scrollTo.clique", "[data-scrollto]", function(e) {
				var ele, obj;
				e.preventDefault();
				ele = $(this);
				if(!ele.data("clique.data.scrollTo")) {
					obj = _c.scrollTo(ele, _c.utils.options(ele.attr("data-scrollto")));
					return ele.trigger("click");
				}
			});
		},
		init: function() {
			var $this;
			$this = this;
			return this.on("click", function(e) {
				e.preventDefault();
				$this.trigger("willscroll.clique.scrollTo");
				var top = _c.$win.scrollTop();
				if($this.options.offset) {
					top = _c.$win.scrollTop() + $this.options.offset;
				} else {
					if($(this).attr("href") && $($(this).attr("href")).length) {
						top = $($(this).attr("href")).offset().top;
					}
				}
				return $this.scrollTo(top);
			});
		},
		scrollTo: function(top) {
			var docheight, target, winheight;
			_c.$win.on("mousewheel", function() {
				$("html, body").stop(true);
			});
			var $this = this;
			var options = this.options;
			return $("html, body").stop().animate({
				scrollTop: top
			}, options.duration, options.transition).promise().done(function() {
				$this.trigger("didscroll.clique.scrollTo");
				console.log("complete");
				return _c.$win.off("mousewheel");
			});
		}
	});
	if(!_c.$.easing.easeOutExpo) {
		_c.$.easing.easeOutExpo = function(x, t, b, c, d) {
			if(t === d) {
				return b + c;
			} else {
				return c * (-Math.pow(2, -10 * t / d) + 1) + b;
			}
		};
	}
});
