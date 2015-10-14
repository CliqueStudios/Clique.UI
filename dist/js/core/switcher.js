(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-switcher", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.switcher requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, Animations, coreAnimation;
	$ = _c.$;
	coreAnimation = function(cls, current, next) {
		var clsIn, clsOut, d, release;
		d = _c.$.Deferred();
		clsIn = cls;
		clsOut = cls;
		if(next[0] === current[0]) {
			d.resolve();
			return d.promise();
		}
		if(typeof cls === "object") {
			clsIn = cls[0];
			clsOut = cls[1] || cls[0];
		}
		release = function() {
			if(current) {
				current.hide().removeClass("active " + clsOut + " animation-reverse");
			}
			return next.addClass(clsIn).one(_c.support.animation.end, function(_this) {
				return function() {
					next.removeClass("" + clsIn + "").css({
						opacity: "",
						display: ""
					});
					d.resolve();
					if(current) {
						return current.css({
							opacity: "",
							display: ""
						});
					}
				};
			}(this)).show();
		};
		next.css("animation-duration", this.options.duration + "ms");
		if(current && current.length) {
			current.css("animation-duration", this.options.duration + "ms");
			current.css("display", "none").addClass(clsOut + " animation-reverse").one(_c.support.animation.end, function(_this) {
				return function() {
					return release();
				};
			}(this)).css("display", "");
		} else {
			next.addClass("active");
			release();
		}
		return d.promise();
	};
	_c.component("switcher", {
		defaults: {
			connect: false,
			toggle: ">*",
			active: 0,
			animation: false,
			duration: 200
		},
		animating: false,
		boot: function() {
			return _c.ready(function(context) {
				return $("[data-switcher]", context).each(function() {
					var obj, switcher;
					switcher = $(this);
					if(!switcher.data("clique.data.switcher")) {
						obj = _c.switcher(switcher, _c.utils.options(switcher.attr("data-switcher")));
					}
				});
			});
		},
		init: function() {
			var $this, active, toggles;
			$this = this;
			this.on("click.clique.switcher", this.options.toggle, function(e) {
				e.preventDefault();
				return $this.show(this);
			});
			if(this.options.connect) {
				this.connect = $(this.options.connect);
				this.connect.find(".active").removeClass(".active");
				if(this.connect.length) {
					this.connect.children().attr("aria-hidden", "true");
					this.connect.on("click", "[data-switcher-item]", function(e) {
						var item;
						e.preventDefault();
						item = $(this).attr("data-switcher-item");
						if($this.index === item) {
							return;
						}
						switch(item) {
							case "next":
							case "previous":
								return $this.show($this.index + (item === "next" ? 1 : -1));

							default:
								return $this.show(parseInt(item, 10));
						}
					}).on("swipeRight swipeLeft", function(e) {
						e.preventDefault();
						return $this.show($this.index + (e.type === "swipeLeft" ? 1 : -1));
					});
				}
				toggles = this.find(this.options.toggle);
				active = toggles.filter(".active");
				if(active.length) {
					this.show(active, false);
				} else {
					if(this.options.active === false) {
						return;
					}
					active = toggles.eq(this.options.active);
					this.show(active.length ? active : toggles.eq(0), false);
				}
				toggles.not(active).attr("aria-expanded", "false");
				active.attr("aria-expanded", "true");
				return this.on("changed.clique.dom", function() {
					$this.connect = $($this.options.connect);
				});
			}
		},
		show: function(tab, animate) {
			var $this, active, animation, toggles;
			if(this.animating) {
				return;
			}
			if(isNaN(tab)) {
				tab = $(tab);
			} else {
				toggles = this.find(this.options.toggle);
				tab = tab < 0 ? toggles.length - 1 : tab;
				tab = toggles.eq(toggles[tab] ? tab : 0);
			}
			$this = this;
			toggles = this.find(this.options.toggle);
			active = $(tab);
			animation = Animations[this.options.animation] || function(current, next) {
				var anim;
				if(!$this.options.animation) {
					return Animations.none.apply($this);
				}
				anim = $this.options.animation.split(",");
				if(anim.length === 1) {
					anim[1] = anim[0];
				}
				anim[0] = anim[0].trim();
				anim[1] = anim[1].trim();
				return coreAnimation.apply($this, [anim, current, next]);
			};
			if(animate === false || !_c.support.animation) {
				animation = Animations.none;
			}
			if(active.hasClass("disabled")) {
				return;
			}
			toggles.attr("aria-expanded", "false");
			active.attr("aria-expanded", "true");
			toggles.filter(".active").removeClass("active");
			active.addClass("active");
			if(this.options.connect && this.connect.length) {
				this.index = this.find(this.options.toggle).index(active);
				if(this.index === -1) {
					this.index = 0;
				}
				this.connect.each(function() {
					var children, container, current, next;
					container = $(this);
					children = $(container.children());
					current = $(children.filter(".active"));
					next = $(children.eq($this.index));
					$this.animating = true;
					return animation.apply($this, [current, next]).then(function() {
						current.removeClass("active");
						next.addClass("active");
						current.attr("aria-hidden", "true");
						next.attr("aria-hidden", "false");
						_c.utils.checkDisplay(next, true);
						$this.animating = false;
					});
				});
			}
			return this.trigger("show.clique.switcher", [active]);
		}
	});
	Animations = {
		none: function() {
			var d;
			d = _c.$.Deferred();
			d.resolve();
			return d.promise();
		},
		fade: function(current, next) {
			return coreAnimation.apply(this, ["animation-fade", current, next]);
		},
		"slide-bottom": function(current, next) {
			return coreAnimation.apply(this, ["animation-slide-bottom", current, next]);
		},
		"slide-top": function(current, next) {
			return coreAnimation.apply(this, ["animation-slide-top", current, next]);
		},
		"slide-vertical": function(current, next, dir) {
			var anim;
			anim = ["animation-slide-top", "animation-slide-bottom"];
			if(current && current.index() > next.index()) {
				anim.reverse();
			}
			return coreAnimation.apply(this, [anim, current, next]);
		},
		"slide-left": function(current, next) {
			return coreAnimation.apply(this, ["animation-slide-left", current, next]);
		},
		"slide-right": function(current, next) {
			return coreAnimation.apply(this, ["animation-slide-right", current, next]);
		},
		"slide-horizontal": function(current, next, dir) {
			var anim;
			anim = ["animation-slide-right", "animation-slide-left"];
			if(current && current.index() > next.index()) {
				anim.reverse();
			}
			return coreAnimation.apply(this, [anim, current, next]);
		},
		scale: function(current, next) {
			return coreAnimation.apply(this, ["animation-scale-up", current, next]);
		}
	};
	_c.switcher.animations = Animations;
});
