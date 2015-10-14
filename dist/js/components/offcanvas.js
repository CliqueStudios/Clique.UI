(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-offcanvas", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.offcanvas requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, $doc, $html, $win, Offcanvas, scrollpos;
	$ = _c.$;
	scrollpos = {
		x: window.scrollX,
		y: window.scrollY
	};
	$win = _c.$win;
	$doc = _c.$doc;
	$html = _c.$html;
	Offcanvas = {
		show: function(element) {
			var bar, dir, flip, rtl;
			element = _c.$(element);
			if(!element.length) {
				return;
			}
			bar = element.find(".offcanvas-bar").first();
			rtl = _c.langdirection === "right";
			flip = bar.hasClass("offcanvas-bar-flip") ? -1 : 1;
			dir = flip * (rtl ? -1 : 1);
			scrollpos = {
				x: window.pageXOffset,
				y: window.pageYOffset
			};
			element.addClass("active");
			_c.$body.css({
				width: window.innerWidth,
				height: window.innerHeight
			}).addClass("offcanvas-page");
			_c.$body.css(rtl ? "margin-right" : "margin-left", (rtl ? -1 : 1) * (bar.outerWidth() * dir)).width();
			$html.css("margin-top", scrollpos.y * -1);
			bar.addClass("offcanvas-bar-show");
			this._initElement(element);
			$doc.trigger("show.clique.offcanvas", [element, bar]);
			element.attr("aria-hidden", "false");
		},
		hide: function(force) {
			var bar, finalize, panel, rtl;
			panel = _c.$(".offcanvas.active");
			rtl = _c.langdirection === "right";
			bar = panel.find(".offcanvas-bar").first();
			finalize = function() {
				_c.$body.removeClass("offcanvas-page").css({
					width: "",
					height: "",
					"margin-left": "",
					"margin-right": ""
				});
				panel.removeClass("active");
				bar.removeClass("offcanvas-bar-show");
				$html.css("margin-top", "");
				window.scrollTo(scrollpos.x, scrollpos.y);
				_c.$doc.trigger("hide.clique.offcanvas", [panel, bar]);
				return panel.attr("aria-hidden", "true");
			};
			if(!panel.length) {
				return;
			}
			if(_c.support.transition && !force) {
				_c.$body.one(_c.support.transition.end, function() {
					return finalize();
				}).css(rtl ? "margin-right" : "margin-left", "");
				return setTimeout(function() {
					return bar.removeClass("offcanvas-bar-show");
				}, 0);
			} else {
				return finalize();
			}
		},
		_initElement: function(element) {
			if(element.data("OffcanvasInit")) {
				return;
			}
			element.on("click.clique.offcanvas swipeRight.clique.offcanvas swipeLeft.clique.offcanvas", function(e) {
				var target;
				target = _c.$(e.target);
				if(!e.type.match(/swipe/)) {
					if(!target.hasClass("offcanvas-close")) {
						if(target.hasClass("offcanvas-bar")) {
							return;
						}
						if(target.parents(".offcanvas-bar").first().length) {
							return;
						}
					}
				}
				e.stopImmediatePropagation();
				return Offcanvas.hide();
			});
			element.on("click", "a[href^='#']", function(e) {
				var href;
				element = _c.$(this);
				href = element.attr("href");
				if(href === "#") {
					return;
				}
				_c.$doc.one("hide.clique.offcanvas", function() {
					var target;
					target = _c.$(href);
					if(!target.length) {
						target = _c.$('[name="' + href.replace("#", "") + '"]');
					}
					if(_c.utils.scrollToElement && target.length) {
						return _c.utils.scrollToElement(target);
					} else {
						window.location.href = href;
					}
				});
				return Offcanvas.hide();
			});
			return element.data("OffcanvasInit", true);
		}
	};
	_c.component("offcanvasTrigger", {
		boot: function() {
			$html.on("click.offcanvas.clique", "[data-offcanvas]", function(e) {
				var ele, obj;
				e.preventDefault();
				ele = _c.$(this);
				if(!ele.data("clique.data.offcanvasTrigger")) {
					obj = _c.offcanvasTrigger(ele, _c.utils.options(ele.attr("data-offcanvas")));
					return ele.trigger("click");
				}
			});
			return $html.on("keydown.clique.offcanvas", function(e) {
				if(e.keyCode === 27) {
					return Offcanvas.hide();
				}
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.options = _c.$.extend({
				target: $this.element.is("a") ? $this.element.attr("href") : false
			}, this.options);
			return this.on("click", function(e) {
				e.preventDefault();
				return Offcanvas.show($this.options.target);
			});
		}
	});
	_c.offcanvas = Offcanvas;
});
