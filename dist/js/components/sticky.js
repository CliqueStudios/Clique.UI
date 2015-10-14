(function(addon) {
	var component;
	if(window.Clique) {
		component = addon(Clique);
	}
	if(typeof define === "function" && define.amd) {
		define("clique-sticky", ["clique"], function() {
			console.log("something");
			return component || addon(Clique);
		});
	}
})(function(_c) {
	var $;
	$ = _c.$;
	var $win = _c.$win,
		$doc = _c.$doc,
		sticked = [];
	_c.component("sticky", {
		defaults: {
			top: 0,
			bottom: 0,
			animation: "",
			clsinit: "sticky-init",
			clsactive: "active",
			getWidthFrom: "",
			boundary: false,
			media: false,
			target: false,
			disabled: false
		},
		boot: function() {
			_c.$doc.on("scrolling.clique.dom", function() {
				checkscrollposition();
			});
			_c.$win.on("resize orientationchange", _c.utils.debounce(function() {
				if(!sticked.length) {
					return;
				}
				for(var i = 0; i < sticked.length; i++) {
					sticked[i].reset(true);
					sticked[i].self.computeWrapper();
				}
				checkscrollposition();
			}, 100));
			_c.ready(function(context) {
				setTimeout(function() {
					_c.$("[data-sticky]", context).each(function() {
						var ele = $(this);
						if(!ele.data("clique.data.sticky")) {
							_c.sticky(ele, _c.utils.options(ele.attr("data-sticky")));
						}
					});
					checkscrollposition();
				}, 0);
			});
		},
		init: function() {
			var wrapper = _c.$('<div class="sticky-placeholder"></div>'),
				boundary = this.options.boundary,
				boundtoparent;
			this.wrapper = this.element.css("margin", 0).wrap(wrapper).parent();
			this.computeWrapper();
			if(boundary) {
				if(boundary === true) {
					boundary = this.wrapper.parent();
					boundtoparent = true;
				} else {
					if(typeof boundary === "string") {
						boundary = _c.$(boundary);
					}
				}
			}
			this.sticky = {
				self: this,
				options: this.options,
				element: this.element,
				currentTop: null,
				wrapper: this.wrapper,
				init: false,
				getWidthFrom: this.options.getWidthFrom || this.wrapper,
				boundary: boundary,
				boundtoparent: boundtoparent,
				reset: function(force) {
					var finalize = function() {
						this.element.css({
							position: "",
							top: "",
							width: "",
							left: "",
							margin: "0"
						});
						this.element.removeClass([this.options.animation, "animation-reverse", this.options.clsactive].join(" "));
						this.currentTop = null;
						this.animate = false;
					}.bind(this);
					if(!force && this.options.animation && _c.support.animation) {
						this.animate = true;
						this.element.removeClass(this.options.animation).one(_c.support.animation.end, function() {
							finalize();
						}).width();
						this.element.addClass(this.options.animation + " " + "animation-reverse");
					} else {
						finalize();
					}
				},
				check: function() {
					if(this.options.disabled) {
						return false;
					}
					if(this.options.media) {
						switch(typeof this.options.media) {
							case "number":
								if(window.innerWidth < this.options.media) {
									return false;
								}
								break;

							case "string":
								if(window.matchMedia && !window.matchMedia(this.options.media).matches) {
									return false;
								}
								break;
						}
					}
					var scrollTop = $win.scrollTop(),
						documentHeight = $doc.height(),
						dwh = documentHeight - window.innerHeight,
						extra = scrollTop > dwh ? dwh - scrollTop : 0,
						elementTop = this.wrapper.offset().top,
						etse = elementTop - this.options.top - extra;
					return scrollTop >= etse;
				}
			};
			sticked.push(this.sticky);
		},
		update: function() {
			checkscrollposition(this.sticky);
		},
		enable: function() {
			this.options.disabled = false;
			this.update();
		},
		disable: function(force) {
			this.options.disabled = true;
			this.sticky.reset(force);
		},
		computeWrapper: function() {
			this.wrapper.css({
				height: this.element.css("position") !== "absolute" ? this.element.outerHeight() : "",
				float: this.element.css("float") !== "none" ? this.element.css("float") : "",
				margin: this.element.css("margin")
			});
		}
	});

	function checkscrollposition() {
		var stickies = arguments.length ? arguments : sticked;
		if(!stickies.length || $win.scrollTop() < 0) {
			return;
		}
		var scrollTop = $win.scrollTop(),
			documentHeight = $doc.height(),
			windowHeight = $win.height(),
			dwh = documentHeight - windowHeight,
			extra = scrollTop > dwh ? dwh - scrollTop : 0,
			newTop, containerBottom, stickyHeight, sticky;
		for(var i = 0; i < stickies.length; i++) {
			sticky = stickies[i];
			if(!sticky.element.is(":visible") || sticky.animate) {
				continue;
			}
			if(!sticky.check()) {
				if(sticky.currentTop !== null) {
					sticky.reset();
				}
			} else {
				if(sticky.options.top < 0) {
					newTop = 0;
				} else {
					stickyHeight = sticky.element.outerHeight();
					newTop = documentHeight - stickyHeight - sticky.options.top - sticky.options.bottom - scrollTop - extra;
					newTop = newTop < 0 ? newTop + sticky.options.top : sticky.options.top;
				}
				if(sticky.boundary && sticky.boundary.length) {
					var bTop = sticky.boundary.position().top;
					if(sticky.boundtoparent) {
						containerBottom = documentHeight - (bTop + sticky.boundary.outerHeight()) + parseInt(sticky.boundary.css("padding-bottom"));
					} else {
						containerBottom = documentHeight - bTop - parseInt(sticky.boundary.css("margin-top"));
					}
					newTop = scrollTop + stickyHeight > documentHeight - containerBottom - (sticky.options.top < 0 ? 0 : sticky.options.top) ? documentHeight - containerBottom - (scrollTop + stickyHeight) : newTop;
				}
				if(sticky.currentTop !== newTop) {
					sticky.element.css({
						position: "fixed",
						top: newTop,
						width: typeof sticky.getWidthFrom !== "undefined" ? _c.$(sticky.getWidthFrom).width() : sticky.element.width(),
						left: sticky.wrapper.offset().left
					});
					if(!sticky.init) {
						sticky.element.addClass(sticky.options.clsinit);
						if(location.hash && scrollTop > 0 && sticky.options.target) {
							var $target = _c.$(location.hash);
							if($target.length) {
								setTimeout(function($target, sticky) {
									return function() {
										sticky.element.width();
										var offset = $target.offset(),
											maxoffset = offset.top + $target.outerHeight(),
											stickyOffset = sticky.element.offset(),
											stickyHeight = sticky.element.outerHeight(),
											stickyMaxOffset = stickyOffset.top + stickyHeight;
										if(stickyOffset.top < maxoffset && offset.top < stickyMaxOffset) {
											scrollTop = offset.top - stickyHeight - sticky.options.target;
											window.scrollTo(0, scrollTop);
										}
									};
								}($target, sticky), 0);
							}
						}
					}
					sticky.element.addClass(sticky.options.clsactive);
					sticky.element.css("margin", "");
					if(sticky.options.animation && sticky.init) {
						sticky.element.addClass(sticky.options.animation);
					}
					sticky.currentTop = newTop;
				}
			}
			sticky.init = true;
		}
	}
	return _c.sticky;
});
