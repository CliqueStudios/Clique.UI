(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-parallax", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.parallax requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, calcColor, calculateColor, checkParallaxes, colors, initBgImageParallax, parallaxes, parseColor, scrolltop, supports3d, wh;
	$ = _c.$;
	initBgImageParallax = function(obj, prop, opts) {
		var check, element, img, ratio, url;
		img = new Image();
		ratio = null;
		element = obj.element.css({
			"background-size": "cover",
			"background-repeat": "no-repeat"
		});
		url = element.css("background-image").replace(/^url\(/g, "").replace(/\)$/g, "").replace(/("|')/g, "");
		check = function() {
			var h, height, w, width;
			w = element.width();
			h = element.height();
			h += prop === "bg" ? opts.diff : opts.diff / 100 * h;
			if(w / ratio < h) {
				width = Math.ceil(h * ratio);
				height = h;
			} else {
				width = w;
				height = Math.ceil(w / ratio);
				return obj.element.css({
					"background-size": width + "px " + height + "px"
				});
			}
		};
		img.onerror = function() {};
		img.onload = function() {
			var size;
			size = {
				w: img.width,
				height: img.height
			};
			ratio = img.width / img.height;
			_c.$win.on("load resize orientationchange", _c.utils.debounce(function() {
				return check();
			}, 50));
			return check();
		};
		img.src = url;
		return true;
	};
	calcColor = function(start, end, pos) {
		start = parseColor(start);
		end = parseColor(end);
		pos = pos || 0;
		return calculateColor(start, end, pos);
	};
	calculateColor = function(begin, end, pos) {
		var color;
		color = "rgba(" + parseInt(begin[0] + pos * (end[0] - begin[0]), 10) + "," + parseInt(begin[1] + pos * (end[1] - begin[1]), 10) + "," + parseInt(begin[2] + pos * (end[2] - begin[2]), 10) + "," + (begin && end ? parseFloat(begin[3] + pos * (end[3] - begin[3])) : 1);
		color += ")";
		return color;
	};
	parseColor = function(color) {
		var match1, match2, match3, match4, quadruplet;
		match1 = /#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})/.exec(color);
		match2 = /#([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])/.exec(color);
		match3 = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color);
		match4 = /rgba\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9\.]*)\s*\)/.exec(color);
		if(match1) {
			quadruplet = [parseInt(match1[1], 16), parseInt(match1[2], 16), parseInt(match1[3], 16), 1];
		} else {
			if(match2) {
				quadruplet = [parseInt(match2[1], 16) * 17, parseInt(match2[2], 16) * 17, parseInt(match2[3], 16) * 17, 1];
			} else {
				if(match3) {
					quadruplet = [parseInt(match3[1]), parseInt(match3[2]), parseInt(match3[3]), 1];
				} else {
					if(match4) {
						quadruplet = [parseInt(match4[1], 10), parseInt(match4[2], 10), parseInt(match4[3], 10), parseFloat(match4[4])];
					} else {
						quadruplet = colors[color] || [255, 255, 255, 0];
					}
				}
			}
		}
		return quadruplet;
	};
	parallaxes = [];
	supports3d = false;
	scrolltop = 0;
	wh = window.innerHeight;
	checkParallaxes = function() {
		scrolltop = _c.$win.scrollTop();
		return _c.support.requestAnimationFrame.apply(window, [function() {
			var i, _results;
			i = 0;
			_results = [];
			while(i < parallaxes.length) {
				parallaxes[i].process();
				_results.push(i++);
			}
			return _results;
		}]);
	};
	_c.component("parallax", {
		defaults: {
			velocity: .5,
			target: false,
			viewport: false
		},
		boot: function() {
			supports3d = function() {
				var el, has3d, t, transforms;
				el = document.createElement("div");
				transforms = {
					WebkitTransform: "-webkit-transform",
					MSTransform: "-ms-transform",
					MozTransform: "-moz-transform",
					Transform: "transform"
				};
				document.body.insertBefore(el, null);
				for(t in transforms) {
					if(el.style[t] !== void 0) {
						el.style[t] = "translate3d(1px,1px,1px)";
						has3d = window.getComputedStyle(el).getPropertyValue(transforms[t]);
					}
				}
				document.body.removeChild(el);
				return typeof has3d !== "undefined" && has3d.length > 0 && has3d !== "none";
			}();
			_c.$doc.on("scrolling.clique.dom", checkParallaxes);
			_c.$win.on("load resize orientationchange", _c.utils.debounce(function() {
				wh = window.innerHeight;
				checkParallaxes();
			}, 50));
			return _c.ready(function(context) {
				return _c.$("[data-parallax]", context).each(function() {
					var ele, obj;
					ele = _c.$(this);
					if(!ele.data("clique.data.parallax")) {
						obj = _c.parallax(ele, _c.utils.options(ele.attr("data-parallax")));
					}
				});
			});
		},
		init: function() {
			var reserved;
			this.base = this.options.target ? _c.$(this.options.target) : this.element;
			this.props = {};
			this.velocity = this.options.velocity || 1;
			reserved = ["target", "velocity", "viewport", "plugins"];
			Object.keys(this.options).forEach(function(_this) {
				return function(prop) {
					var diff, dir, end, start, startend;
					if(reserved.indexOf(prop) !== -1) {
						return;
					}
					startend = String(_this.options[prop]).split(",");
					if(prop.match(/color/i)) {
						start = startend[1] ? startend[0] : _this._getStartValue(prop);
						end = startend[1] ? startend[1] : startend[0];
						if(!start) {
							start = "rgba(255, 255, 255, 0)";
							return;
						}
					} else {
						start = parseFloat(startend[1] ? startend[0] : _this._getStartValue(prop));
						end = parseFloat(startend[1] ? startend[1] : startend[0]);
						diff = start < end ? end - start : start - end;
						dir = start < end ? 1 : -1;
					}
					_this.props[prop] = {
						start: start,
						end: end,
						dir: dir,
						diff: diff
					};
				};
			}(this));
			return parallaxes.push(this);
		},
		process: function() {
			var percent;
			percent = this.percentageInViewport();
			if(this.options.viewport !== false) {
				percent = this.options.viewport === 0 ? 1 : percent / this.options.viewport;
			}
			return this.update(percent);
		},
		percentageInViewport: function() {
			var distance, height, percent, percentage, top;
			top = this.base.offset().top;
			height = this.base.outerHeight();
			if(top > scrolltop + wh) {
				percent = 0;
			} else {
				if(top + height < scrolltop) {
					percent = 1;
				} else {
					if(top + height < wh) {
						percent = (scrolltop < wh ? scrolltop : scrolltop - wh) / (top + height);
					} else {
						distance = scrolltop + wh - top;
						percentage = Math.round(distance / ((wh + height) / 100));
						percent = percentage / 100;
					}
				}
			}
			return percent;
		},
		update: function(percent) {
			var compercent, css;
			css = {
				transform: ""
			};
			compercent = percent * (1 - (this.velocity - this.velocity * percent));
			if(compercent < 0) {
				compercent = 0;
			}
			if(compercent > 1) {
				compercent = 1;
			}
			if(this._percent !== void 0 && this._percent === compercent) {
				return;
			}
			Object.keys(this.props).forEach(function(_this) {
				return function(prop) {
					var opts, val;
					opts = _this.props[prop];
					if(percent === 0) {
						val = opts.start;
					} else {
						if(percent === 1) {
							val = opts.end;
						} else {
							if(opts.diff !== void 0) {
								val = opts.start + opts.diff * compercent * opts.dir;
							}
						}
					}
					if((prop === "bg" || prop === "bgp") && !_this._bgcover) {
						_this._bgcover = initBgImageParallax(_this, prop, opts);
					}
					switch(prop) {
						case "x":
							css.transform += supports3d ? " translate3d(" + val + "px, 0, 0)" : " translateX(" + val + "px)";
							break;

						case "xp":
							css.transform += supports3d ? " translate3d(" + val + "%, 0, 0)" : " translateX(" + val + "%)";
							break;

						case "y":
							css.transform += supports3d ? " translate3d(0, " + val + "px, 0)" : " translateY(" + val + "px)";
							break;

						case "yp":
							css.transform += supports3d ? " translate3d(0, " + val + "%, 0)" : " translateY(" + val + "%)";
							break;

						case "rotate":
							css.transform += " rotate(" + val + "deg)";
							break;

						case "scale":
							css.transform += " scale(" + val + ")";
							break;

						case "bg":
							css["background-position"] = "50% " + val + "px";
							break;

						case "bgp":
							css["background-position"] = "50% " + val + "%";
							break;

						case "color":
						case "background-color":
						case "border-color":
							css[prop] = calcColor(opts.start, opts.end, compercent);
							break;

						default:
							css[prop] = val;
							break;
					}
				};
			}(this));
			this.element.css(css);
			this._percent = compercent;
		},
		_getStartValue: function(prop) {
			var value;
			value = 0;
			switch(prop) {
				case "scale":
					value = 1;
					break;

				default:
					value = this.element.css(prop);
			}
			return value || 0;
		}
	});
	colors = {
		black: [0, 0, 0, 1],
		blue: [0, 0, 255, 1],
		brown: [165, 42, 42, 1],
		cyan: [0, 255, 255, 1],
		fuchsia: [255, 0, 255, 1],
		gold: [255, 215, 0, 1],
		green: [0, 128, 0, 1],
		indigo: [75, 0, 130, 1],
		khaki: [240, 230, 140, 1],
		lime: [0, 255, 0, 1],
		magenta: [255, 0, 255, 1],
		maroon: [128, 0, 0, 1],
		navy: [0, 0, 128, 1],
		olive: [128, 128, 0, 1],
		orange: [255, 165, 0, 1],
		pink: [255, 192, 203, 1],
		purple: [128, 0, 128, 1],
		violet: [128, 0, 128, 1],
		red: [255, 0, 0, 1],
		silver: [192, 192, 192, 1],
		white: [255, 255, 255, 1],
		yellow: [255, 255, 0, 1],
		transparent: [255, 255, 255, 0]
	};
	return _c.parallax;
});
