/*!
 *  CliqueUI - v1.0.4 - 2015-10-14
 *  http://ui.cliquestudios.com
 *  Copyright (c) 2015 Clique Studios;
 */

(function(core) {
	if(typeof define === "function" && define.amd) {
		define("clique", function() {
			var clique;
			clique = window.Clique || core(window, window.jQuery, window.document);
			clique.load = function(res, req, onload, config) {
				var base, i, load, resource, resources;
				resources = res.split(",");
				load = [];
				base = (config.config && config.config.clique && config.config.clique.base ? config.config.clique.base : "").replace(/\/+$/g, "");
				if(!base) {
					throw new Error("Please define base path to Clique in the requirejs config.");
				}
				i = 0;
				while(i < resources.length) {
					resource = resources[i].replace(/\./g, "/");
					load.push(base + "/components/" + resource);
					i += 1;
				}
				req(load, function() {
					onload(clique);
				});
			};
			return clique;
		});
	}
	if(!window.jQuery) {
		throw new Error("Clique requires jQuery");
	}
	if(window && window.jQuery) {
		core(window, window.jQuery, window.document);
	}
})(function(global, $, doc) {
	var hovercls, hoverset, selector, _c, _cTEMP;
	_c = {};
	_cTEMP = window.Clique;
	_c.version = "1.0.4";
	_c.noConflict = function() {
		if(_cTEMP) {
			window.Clique = _cTEMP;
			$.Clique = _cTEMP;
			$.fn.clique = _cTEMP.fn;
		}
		return _c;
	};
	_c.prefix = function(str) {
		return str;
	};
	_c.$ = $;
	_c.$doc = $(document);
	_c.$win = $(window);
	_c.$html = $("html");
	_c.fn = function(command, options) {
		var args, cmd, component, method;
		args = arguments;
		cmd = command.match(/^([a-z\-]+)(?:\.([a-z]+))?/i);
		component = cmd[1];
		method = cmd[2];
		if(!method && typeof options === "string") {
			method = options;
		}
		if(!_c[component]) {
			$.error("Clique component [" + component + "] does not exist.");
			return this;
		}
		return this.each(function() {
			var $this, data;
			$this = $(this);
			data = $this.data(component);
			if(!data) {
				$this.data(component, data = _c[component](this, method ? void 0 : options));
			}
			if(method) {
				data[method].apply(data, Array.prototype.slice.call(args, 1));
			}
		});
	};
	_c.support = {
		requestAnimationFrame: window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.msRequestAnimationFrame || window.oRequestAnimationFrame || function(callback) {
			setTimeout(callback, 1e3 / 60);
		},
		touch: "ontouchstart" in window && navigator.userAgent.toLowerCase().match(/mobile|tablet/) || global.DocumentTouch && document instanceof global.DocumentTouch || global.navigator.msPointerEnabled && global.navigator.msMaxTouchPoints > 0 || global.navigator.pointerEnabled && global.navigator.maxTouchPoints > 0 || false,
		mutationobserver: global.MutationObserver || global.WebKitMutationObserver || null
	};
	_c.support.transition = function() {
		var transitionEnd;
		transitionEnd = function() {
			var element, name, transEndEventNames;
			element = doc.body || doc.documentElement;
			transEndEventNames = {
				WebkitTransition: "webkitTransitionEnd",
				MozTransition: "transitionend",
				OTransition: "oTransitionEnd otransitionend",
				transition: "transitionend"
			};
			for(name in transEndEventNames) {
				if(element.style[name] !== undefined) {
					return transEndEventNames[name];
				}
			}
		}();
		return transitionEnd && {
			end: transitionEnd
		};
	}();
	_c.support.animation = function() {
		var animationEnd;
		animationEnd = function() {
			var animEndEventNames, element, name;
			element = doc.body || doc.documentElement;
			animEndEventNames = {
				WebkitAnimation: "webkitAnimationEnd",
				MozAnimation: "animationend",
				OAnimation: "oAnimationEnd oanimationend",
				animation: "animationend"
			};
			for(name in animEndEventNames) {
				if(element.style[name] !== undefined) {
					return animEndEventNames[name];
				}
			}
		}();
		return animationEnd && {
			end: animationEnd
		};
	}();
	_c.utils = {
		now: Date.now || function() {
			return new Date().getTime();
		},
		isString: function(obj) {
			return Object.prototype.toString.call(obj) === "[object String]";
		},
		isNumber: function(obj) {
			return !isNaN(parseFloat(obj)) && isFinite(obj);
		},
		isDate: function(obj) {
			var d;
			d = new Date(obj);
			return d !== "Invalid Date" && d.toString() !== "Invalid Date" && !isNaN(d);
		},
		str2json: function(str, notevil) {
			var e, newFN;
			try {
				if(notevil) {
					return JSON.parse(str.replace(/([\$\w]+)\s* :/g, function(_, $1) {
						return '"' + $1 + '" :';
					}).replace(/'([^']+)'/g, function(_, $1) {
						return '"' + $1 + '"';
					}));
				} else {
					newFN = Function;
					return new newFN("", "var json = " + str + "; return JSON.parse(JSON.stringify(json));")();
				}
			} catch(_error) {
				e = _error;
				return false;
			}
		},
		debounce: function(func, wait, immediate) {
			return function() {
				var args, callNow, context, later, timeout;
				context = this;
				args = arguments;
				later = function() {
					var timeout;
					timeout = null;
					if(!immediate) {
						func.apply(context, args);
					}
				};
				callNow = immediate && !timeout;
				clearTimeout(timeout);
				timeout = setTimeout(later, wait);
				if(callNow) {
					func.apply(context, args);
				}
			};
		},
		removeCssRules: function(selectorRegEx) {
			if(!selectorRegEx) {
				return;
			}
			setTimeout(function() {
				var idx, idxs, stylesheet, _i, _j, _k, _len, _len1, _len2, _ref;
				try {
					_ref = document.styleSheets;
					_i = 0;
					_len = _ref.length;
					while(_i < _len) {
						stylesheet = _ref[_i];
						idxs = [];
						stylesheet.cssRules = stylesheet.cssRules;
						idx = _j = 0;
						_len1 = stylesheet.cssRules.length;
						while(_j < _len1) {
							if(stylesheet.cssRules[idx].type === CSSRule.STYLE_RULE && selectorRegEx.test(stylesheet.cssRules[idx].selectorText)) {
								idxs.unshift(idx);
							}
							idx = ++_j;
						}
						_k = 0;
						_len2 = idxs.length;
						while(_k < _len2) {
							stylesheet.deleteRule(idxs[_k]);
							_k++;
						}
						_i++;
					}
				} catch(_error) {}
			}, 0);
		},
		isInView: function(element, options) {
			var $element, left, offset, top, window_left, window_top;
			$element = $(element);
			if(!$element.is(":visible")) {
				return false;
			}
			window_left = _c.$win.scrollLeft();
			window_top = _c.$win.scrollTop();
			offset = $element.offset();
			left = offset.left;
			top = offset.top;
			options = $.extend({
				topoffset: 0,
				leftoffset: 0
			}, options);
			if(top + $element.height() >= window_top && top - options.topoffset <= window_top + _c.$win.height() && left + $element.width() >= window_left && left - options.leftoffset <= window_left + _c.$win.width()) {
				return true;
			} else {
				return false;
			}
		},
		checkDisplay: function(context, initanimation) {
			var elements;
			elements = $("[data-margin], [data-row-match], [data-row-margin], [data-check-display]", context || document);
			if(context && !elements.length) {
				elements = $(context);
			}
			elements.trigger("display.clique.check");
			if(initanimation) {
				if(typeof initanimation !== "string") {
					initanimation = '[class*="animation-"]';
				}
				elements.find(initanimation).each(function() {
					var anim, cls, ele;
					ele = $(this);
					cls = ele.attr("class");
					anim = cls.match(/animation\-(.+)/);
					ele.removeClass(anim[0]).width();
					ele.addClass(anim[0]);
				});
			}
			return elements;
		},
		options: function(string) {
			var options, start;
			if($.isPlainObject(string)) {
				return string;
			}
			start = string ? string.indexOf("{") : -1;
			options = {};
			if(start !== -1) {
				try {
					options = _c.utils.str2json(string.substr(start));
				} catch(_error) {}
			}
			return options;
		},
		animate: function(element, cls) {
			var d;
			d = $.Deferred();
			element = $(element);
			cls = cls;
			element.css("display", "none").addClass(cls).one(_c.support.animation.end, function() {
				element.removeClass(cls);
				d.resolve();
			}).width();
			element.css({
				display: ""
			});
			return d.promise();
		},
		uid: function(prefix) {
			return(prefix || "id") + _c.utils.now() + "RAND" + Math.ceil(Math.random() * 1e5);
		},
		template: function(str, data) {
			var cmd, fn, i, newFN, openblocks, output, prop, toc, tokens;
			tokens = str.replace(/\n/g, "\\n").replace(/\{\{\{\s*(.+?)\s*\}\}\}/g, "{{!$1}}").split(/(\{\{\s*(.+?)\s*\}\})/g);
			i = 0;
			output = [];
			openblocks = 0;
			while(i < tokens.length) {
				toc = tokens[i];
				if(toc.match(/\{\{\s*(.+?)\s*\}\}/)) {
					i = i + 1;
					toc = tokens[i];
					cmd = toc[0];
					prop = toc.substring(toc.match(/^(\^|\#|\!|\~|\:)/) ? 1 : 0);
					switch(cmd) {
						case "~":
							output.push("for(var $i = 0; $i < " + prop + ".length; $i++) { var $item = " + prop + "[$i];");
							openblocks++;
							break;

						case ":":
							output.push("for(var $key in " + prop + ") { var $val = " + prop + "[$key];");
							openblocks++;
							break;

						case "#":
							output.push("if(" + prop + ") {");
							openblocks++;
							break;

						case "^":
							output.push("if(!" + prop + ") {");
							openblocks++;
							break;

						case "/":
							output.push("}");
							openblocks--;
							break;

						case "!":
							output.push("__ret.push(" + prop + ");");
							break;

						default:
							output.push("__ret.push(escape(" + prop + "));");
					}
				} else {
					output.push("__ret.push('" + toc.replace(/\'/g, "\\'") + "');");
				}
				i = i + 1;
			}
			newFN = Function;
			fn = new newFN("$data", ["var __ret = [];", "try {", "with($data){", !openblocks ? output.join("") : '__ret = ["Not all blocks are closed correctly."]', "};", "}catch(e){__ret = [e.message];}", 'return __ret.join("").replace(/\\n\\n/g, "\\n");', "function escape(html) { return String(html).replace(/&/g, '&amp;').replace(/\"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');}"].join("\n"));
			if(data) {
				return fn(data);
			} else {
				return fn;
			}
		},
		events: {
			click: _c.support.touch ? "tap" : "click"
		}
	};
	window.Clique = _c;
	$.Clique = _c;
	$.fn.clique = _c.fn;
	_c.langdirection = _c.$html.attr("dir") === "rtl" ? "right" : "left";
	_c.components = {};
	_c.component = function(name, def) {
		var fn;
		fn = function(element, options) {
			var $this;
			$this = this;
			this.Clique = _c;
			this.element = element ? $(element) : null;
			this.options = $.extend(true, {}, this.defaults, options);
			this.plugins = {};
			if(this.element) {
				this.element.data("clique.data." + name, this);
			}
			this.init();
			(this.options.plugins.length ? this.options.plugins : Object.keys(fn.plugins)).forEach(function(plugin) {
				if(fn.plugins[plugin].init) {
					fn.plugins[plugin].init($this);
					$this.plugins[plugin] = true;
				}
			});
			this.trigger("init.clique.component", [name, this]);
			return this;
		};
		fn.plugins = {};
		$.extend(true, fn.prototype, {
			defaults: {
				plugins: []
			},
			boot: function() {},
			init: function() {},
			on: function(a1, a2, a3) {
				return $(this.element || this).on(a1, a2, a3);
			},
			one: function(a1, a2, a3) {
				return $(this.element || this).one(a1, a2, a3);
			},
			off: function(evt) {
				return $(this.element || this).off(evt);
			},
			trigger: function(evt, params) {
				return $(this.element || this).trigger(evt, params);
			},
			find: function(selector) {
				return $(this.element ? this.element : []).find(selector);
			},
			proxy: function(obj, methods) {
				var $this;
				$this = this;
				methods.split(" ").forEach(function(method) {
					if(!$this[method]) {
						$this[method] = function() {
							return obj[method].apply(obj, arguments);
						};
					}
				});
			},
			mixin: function(obj, methods) {
				var $this;
				$this = this;
				methods.split(" ").forEach(function(method) {
					if(!$this[method]) {
						$this[method] = obj[method].bind($this);
					}
				});
			},
			option: function() {
				if(arguments.length === 1) {
					return this.options[arguments[0]] || undefined;
				} else {
					if(arguments.length === 2) {
						this.options[arguments[0]] = arguments[1];
					}
				}
			}
		}, def);
		this.components[name] = fn;
		this[name] = function() {
			var element, options;
			if(arguments.length) {
				switch(arguments.length) {
					case 1:
						if(typeof arguments[0] === "string" || arguments[0].nodeType || arguments[0] instanceof jQuery) {
							element = $(arguments[0]);
						} else {
							options = arguments[0];
						}
						break;

					case 2:
						element = $(arguments[0]);
						options = arguments[1];
				}
			}
			if(element && element.data("clique.data." + name)) {
				return element.data("clique.data." + name);
			}
			return new _c.components[name](element, options);
		};
		if(_c.domready) {
			_c.component.boot(name);
		}
		return fn;
	};
	_c.plugin = function(component, name, def) {
		this.components[component].plugins[name] = def;
	};
	_c.component.boot = function(name) {
		if(_c.components[name].prototype && _c.components[name].prototype.boot && !_c.components[name].booted) {
			_c.components[name].prototype.boot.apply(_c, []);
			_c.components[name].booted = true;
		}
	};
	_c.component.bootComponents = function() {
		var component;
		for(component in _c.components) {
			_c.component.boot(component);
		}
	};
	_c.domObservers = [];
	_c.domready = false;
	_c.ready = function(fn) {
		_c.domObservers.push(fn);
		if(_c.domready) {
			fn(document);
		}
	};
	_c.on = function(a1, a2, a3) {
		if(a1 && a1.indexOf("ready.clique.dom") > -1 && _c.domready) {
			a2.apply(_c.$doc);
		}
		return _c.$doc.on(a1, a2, a3);
	};
	_c.one = function(a1, a2, a3) {
		if(a1 && a1.indexOf("ready.clique.dom") > -1 && _c.domready) {
			a2.apply(_c.$doc);
			return _c.$doc;
		}
		return _c.$doc.one(a1, a2, a3);
	};
	_c.trigger = function(evt, params) {
		return _c.$doc.trigger(evt, params);
	};
	_c.domObserve = function(selector, fn) {
		if(!_c.support.mutationobserver) {
			return;
		}
		fn = fn || function() {};
		$(selector).each(function() {
			var $element, element, observer;
			element = this;
			$element = $(element);
			if($element.data("observer")) {
				return;
			}
			try {
				observer = new _c.support.mutationobserver(_c.utils.debounce(function(mutations) {
					fn.apply(element, []);
					$element.trigger("changed.clique.dom");
				}, 50));
				observer.observe(element, {
					childList: true,
					subtree: true
				});
				$element.data("observer", observer);
			} catch(_error) {}
		});
	};
	_c.delay = function(fn, timeout, args) {
		if(timeout == null) {
			timeout = 0;
		}
		fn = fn || function() {};
		return setTimeout(function() {
			return fn.apply(null, args);
		}, timeout);
	};
	_c.on("domready.clique.dom", function() {
		_c.domObservers.forEach(function(fn) {
			fn(document);
		});
		if(_c.domready) {
			_c.utils.checkDisplay(document);
		}
	});
	$(function() {
		_c.$body = $("body");
		_c.ready(function(context) {
			_c.domObserve("[data-observe]");
		});
		_c.on("changed.clique.dom", function(e) {
			var ele;
			ele = e.target;
			_c.domObservers.forEach(function(fn) {
				fn(ele);
			});
			_c.utils.checkDisplay(ele);
		});
		_c.trigger("beforeready.clique.dom");
		_c.component.bootComponents();
		setInterval(function() {
			var fn, memory;
			memory = {
				x: window.pageXOffset,
				y: window.pageYOffset
			};
			fn = function() {
				var dir;
				if(memory.x !== window.pageXOffset || memory.y !== window.pageYOffset) {
					dir = {
						x: 0,
						y: 0
					};
					if(window.pageXOffset !== memory.x) {
						dir.x = window.pageXOffset > memory.x ? 1 : -1;
					}
					if(window.pageYOffset !== memory.y) {
						dir.y = window.pageYOffset > memory.y ? 1 : -1;
					}
					memory = {
						dir: dir,
						x: window.pageXOffset,
						y: window.pageYOffset
					};
					_c.$doc.trigger("scrolling.clique.dom", [memory]);
				}
			};
			if(_c.support.touch) {
				_c.$html.on("touchmove touchend MSPointerMove MSPointerUp pointermove pointerup", fn);
			}
			if(memory.x || memory.y) {
				fn();
			}
			return fn;
		}(), 15);
		_c.trigger("domready.clique.dom");
		if(_c.support.touch) {
			if(navigator.userAgent.match(/(iPad|iPhone|iPod)/g)) {
				_c.$win.on("load orientationchange resize", _c.utils.debounce(function() {
					var fn;
					fn = function() {
						$(".height-viewport").css("height", window.innerHeight);
						return fn;
					};
					return fn();
				}(), 100));
			}
		}
		_c.trigger("afterready.clique.dom");
		_c.domready = true;
	});
	if(_c.support.touch) {
		hoverset = false;
		hovercls = "hover";
		selector = ".overlay, .overlay-hover, .overlay-toggle, .animation-hover, .has-hover";
		_c.$html.on("touchstart MSPointerDown pointerdown", selector, function() {
			if(hoverset) {
				$("." + hovercls).removeClass(hovercls);
			}
			hoverset = $(this).addClass(hovercls);
		}).on("touchend MSPointerUp pointerup", function(e) {
			var exclude;
			exclude = $(e.target).parents(selector);
			if(hoverset) {
				hoverset.not(exclude).removeClass(hovercls);
			}
		});
	}
	$.expr[":"].on = function(obj) {
		return $(obj).prop("on");
	};
	return _c;
});
(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-events", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.events requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, dispatch, evt, k, v, _ref;
	$ = _c.$;
	dispatch = $.event.dispatch || $.event.handle;
	_c.events = {};
	_c.events.scrollstart = {
		setup: function(data) {
			var handler, timer, uid, _data;
			uid = _c.utils.uid("scrollstart");
			$(this).data("clique.event.scrollstart.uid", uid);
			_data = $.extend({
				latency: $.event.special.scrollstop.latency
			}, data);
			timer = null;
			handler = function(e) {
				var _args, _self;
				_self = this;
				_args = arguments;
				if(timer) {
					clearTimeout(timer);
				} else {
					e.type = "scrollstart.clique.dom";
					$(e.target).trigger("scrollstart.clique.dom", e);
				}
				timer = setTimeout(function() {
					timer = null;
				}, _data.latency);
			};
			return $(this).on("scroll", _c.utils.debounce(handler, 100)).data(uid, handler);
		},
		teardown: function() {
			var uid;
			uid = $(this).data("clique.event.scrollstart.uid");
			$(this).off("scroll", $(this).data(uid));
			$(this).removeData(uid);
			return $(this).removeData("clique.event.scrollstart.uid");
		}
	};
	_c.events.scrollstop = {
		latency: 150,
		setup: function(data) {
			var handler, timer, uid, _data;
			uid = _c.utils.uid("scrollstop");
			$(this).data("clique.event.scrolltop.uid", uid);
			_data = $.extend({
				latency: $.event.special.scrollstop.latency
			}, data);
			timer = null;
			handler = function(e) {
				var _args, _self;
				_self = this;
				_args = arguments;
				if(timer) {
					clearTimeout(timer);
				}
				timer = setTimeout(function() {
					timer = null;
					e.type = "scrollstop.clique.dom";
					$(e.target).trigger("scrollstop.clique.dom", e);
				}, _data.latency);
			};
			$(this).on("scroll", _c.utils.debounce(handler, 100)).data(uid, handler);
		},
		teardown: function() {
			var uid;
			uid = $(this).data("clique.event.scrolltop.uid");
			$(this).off("scroll", $(this).data(uid));
			$(this).removeData(uid);
			return $(this).removeData("clique.event.scrolltop.uid");
		}
	};
	_c.events.resizeend = {
		latency: 250,
		setup: function(data) {
			var handler, timer, uid, _data;
			uid = _c.utils.uid("resizeend");
			$(this).data("clique.event.resizeend.uid", uid);
			_data = $.extend({
				latency: $.event.special.resizeend.latency
			}, data);
			timer = _data;
			handler = function(e) {
				var _args, _self;
				_self = this;
				_args = arguments;
				if(timer) {
					clearTimeout(timer);
				}
				timer = setTimeout(function() {
					timer = null;
					e.type = "resizeend.clique.dom";
					return $(e.target).trigger("resizeend.clique.dom", e);
				}, _data.latency);
			};
			return $(this).on("resize", _c.utils.debounce(handler, 100)).data(uid, handler);
		},
		teardown: function() {
			var uid;
			uid = $(this).data("clique.event.resizeend.uid");
			$(this).off("resize", $(this).data(uid));
			$(this).removeData(uid);
			return $(this).removeData("clique.event.resizeend.uid");
		}
	};
	evt = function(fn) {
		if(fn) {
			return this.on(k, fn);
		} else {
			return this.trigger(k);
		}
	};
	_ref = _c.events;
	for(k in _ref) {
		v = _ref[k];
		if(typeof v === "object") {
			$.event.special[k] = v;
			$.fn[k] = evt;
		}
	}
});
(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-browser", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.browser requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	return _c.component("browser", {
		defaults: {
			addClasses: true,
			detectDevice: true,
			detectScreen: true,
			detectOS: true,
			detectBrowser: true,
			detectLanguage: true,
			detectPlugins: true,
			detectSupport: ["flex", "animation"]
		},
		device: {
			type: "",
			model: "",
			orientation: ""
		},
		browser: {
			engine: "",
			major: "",
			minor: "",
			name: "",
			patch: "",
			version: ""
		},
		screen: {
			size: "",
			touch: false
		},
		deviceTypes: ["tv", "tablet", "mobile", "desktop"],
		screens: {
			mini: 0,
			small: 480,
			medium: 768,
			large: 960,
			xlarge: 1220
		},
		browserLanguage: {
			direction: "",
			code: ""
		},
		boot: function() {
			return _c.ready(function(context) {
				var ele, obj;
				ele = _c.$doc;
				if(!ele.data("clique.data.browser")) {
					obj = _c.browser(ele);
				}
			});
		},
		init: function() {
			this.getProperties();
			return _c.$win.on("resize orientationchange", _c.utils.debounce(function(_this) {
				return function() {
					return _this.getProperties();
				};
			}(this), 250));
		},
		getProperties: function() {
			var win;
			win = _c.$win[0];
			this.userAgent = (win.navigator.userAgent || win.navigator.vendor || win.opera).toLowerCase();
			if(!!this.options.detectDevice) {
				this.detectDevice();
			}
			if(!!this.options.detectScreen) {
				this.detectScreen();
			}
			if(!!this.options.detectOS) {
				this.detectOS();
			}
			if(!!this.options.detectBrowser) {
				this.detectBrowser();
			}
			if(!!this.options.detectPlugins) {
				this.detectPlugins();
			}
			if(!!this.options.detectLanguage) {
				this.detectLanguage();
			}
			if(!!this.options.detectSupport) {
				this.detectSupport();
			}
			return setTimeout(function(_this) {
				return function() {
					if(_this.options.addClasses) {
						_this.addClasses();
					}
					return _this.trigger("updated.browser.clique");
				};
			}(this), 0);
		},
		test: function(rgx) {
			return rgx.test(this.userAgent);
		},
		exec: function(rgx) {
			return rgx.exec(this.userAgent);
		},
		uamatches: function(key) {
			return this.userAgent.indexOf(key) > -1;
		},
		version: function(versionType, versionFull) {
			var versionArray;
			versionType.version = versionFull;
			versionArray = versionFull.split(".");
			if(versionArray.length > 0) {
				versionArray = versionArray.reverse();
				versionType.major = versionArray.pop();
				if(versionArray.length > 0) {
					versionType.minor = versionArray.pop();
					if(versionArray.length > 0) {
						versionArray = versionArray.reverse();
						versionType.patch = versionArray.join(".");
					} else {
						versionType.patch = "0";
					}
				} else {
					versionType.minor = "0";
				}
			} else {
				versionType.major = "0";
			}
		},
		detectDevice: function() {
			var device, h, w;
			device = this.device;
			if(this.test(/googletv|smarttv|smart-tv|internet.tv|netcast|nettv|appletv|boxee|kylo|roku|dlnadoc|roku|pov_tv|hbbtv|ce\-html/)) {
				device.type = this.deviceTypes[0];
				device.model = "smarttv";
			} else {
				if(this.test(/xbox|playstation.3|wii/)) {
					device.type = this.deviceTypes[0];
					device.model = "console";
				} else {
					if(this.test(/ip(a|ro)d/)) {
						device.type = this.deviceTypes[1];
						device.model = "ipad";
					} else {
						if(this.test(/tablet/) && !this.test(/rx-34/) || this.test(/folio/)) {
							device.type = this.deviceTypes[1];
							device.model = String(this.exec(/playbook/) || "");
						} else {
							if(this.test(/linux/) && this.test(/android/) && !this.test(/fennec|mobi|htc.magic|htcX06ht|nexus.one|sc-02b|fone.945/)) {
								device.type = this.deviceTypes[1];
								device.model = "android";
							} else {
								if(this.test(/kindle/) || this.test(/mac.os/) && this.test(/silk/)) {
									device.type = this.deviceTypes[1];
									device.model = "kindle";
								} else {
									if(this.test(/gt-p10|sc-01c|shw-m180s|sgh-t849|sch-i800|shw-m180l|sph-p100|sgh-i987|zt180|htc(.flyer|\_flyer)|sprint.atp51|viewpad7|pandigital(sprnova|nova)|ideos.s7|dell.streak.7|advent.vega|a101it|a70bht|mid7015|next2|nook/) || this.test(/mb511/) && this.test(/rutem/)) {
										device.type = this.deviceTypes[1];
										device.model = "android";
									} else {
										if(this.test(/bb10/)) {
											device.type = this.deviceTypes[1];
											device.model = "blackberry";
										} else {
											device.model = this.exec(/iphone|ipod|android|blackberry|opera mini|opera mobi|skyfire|maemo|windows phone|palm|iemobile|symbian|symbianos|fennec|j2me/);
											if(device.model !== null) {
												device.type = this.deviceTypes[2];
												device.model = String(device.model);
											} else {
												device.model = "";
												if(this.test(/bolt|fennec|iris|maemo|minimo|mobi|mowser|netfront|novarra|prism|rx-34|skyfire|tear|xv6875|xv6975|google.wireless.transcoder/)) {
													device.type = this.deviceTypes[2];
												} else {
													if(this.test(/opera/) && this.test(/windows.nt.5/) && this.test(/htc|xda|mini|vario|samsung\-gt\-i8000|samsung\-sgh\-i9/)) {
														device.type = this.deviceTypes[2];
													} else {
														if(this.test(/windows.(nt|xp|me|9)/) && !this.test(/phone/) || this.test(/win(9|.9|nt)/) || this.test(/\(windows 8\)/)) {
															device.type = this.deviceTypes[3];
														} else {
															if(this.test(/macintosh|powerpc/) && !this.test(/silk/)) {
																device.type = this.deviceTypes[3];
																device.model = "mac";
															} else {
																if(this.test(/linux/) && this.test(/x11/)) {
																	device.type = this.deviceTypes[3];
																} else {
																	if(this.test(/solaris|sunos|bsd/)) {
																		device.type = this.deviceTypes[3];
																	} else {
																		if(this.test(/cros/)) {
																			device.type = this.deviceTypes[3];
																		} else {
																			if(this.test(/bot|crawler|spider|yahoo|ia_archiver|covario-ids|findlinks|dataparksearch|larbin|mediapartners-google|ng-search|snappy|teoma|jeeves|tineye/) && !this.test(/mobile/)) {
																				device.type = this.deviceTypes[3];
																				device.model = "crawler";
																			} else {
																				device.type = this.deviceTypes[3];
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
			if(device.type !== "desktop" && device.type !== "tv") {
				w = _c.$win.outerWidth();
				h = _c.$win.outerHeight();
				device.orientation = "landscape";
				if(h > w) {
					device.orientation = "portrait";
				}
			}
			this.device = device;
		},
		detectScreen: function() {
			var k, v, w, _ref;
			w = _c.$win.width();
			_ref = this.screens;
			for(k in _ref) {
				v = _ref[k];
				if(w > v - 1) {
					this.screen.size = k;
				}
			}
			this.detectTouch();
		},
		detectTouch: function() {
			var doc, touch, win;
			win = _c.$win[0];
			doc = _c.$doc[0];
			touch = "ontouchstart" in win && win.navigator.userAgent.toLowerCase().match(/mobile|tablet/) || win.DocumentTouch && doc instanceof win.DocumentTouch || win.navigator.msPointerEnabled && win.navigator.msMaxTouchPoints > 0 || win.navigator.pointerEnabled && win.navigator.maxTouchPoints > 0 || false;
			this.screen.touch = !!touch;
		},
		detectOS: function() {
			var device, os;
			device = this.device;
			os = {};
			if(device.model !== "") {
				if(device.model === "ipad" || device.model === "iphone" || device.model === "ipod") {
					os.name = "ios";
					this.version(os, (this.test(/os\s([\d_]+)/) ? RegExp.$1 : "").replace(/_/g, "."));
				} else {
					if(device.model === "android") {
						os.name = "android";
						this.version(os, this.test(/android\s([\d\.]+)/) ? RegExp.$1 : "");
					} else {
						if(device.model === "blackberry") {
							os.name = "blackberry";
							this.version(os, this.test(/version\/([^\s]+)/) ? RegExp.$1 : "");
						} else {
							if(device.model === "playbook") {
								os.name = "blackberry";
								this.version(os, this.test(/os ([^\s]+)/) ? RegExp.$1.replace(";", "") : "");
							}
						}
					}
				}
			}
			if(!os.name) {
				if(this.uamatches("win") || this.uamatches("16bit")) {
					os.name = "windows";
					if(this.uamatches("windows nt 6.3")) {
						this.version(os, "8.1");
					} else {
						if(this.uamatches("windows nt 6.2") || this.test(/\(windows 8\)/)) {
							this.version(os, "8");
						} else {
							if(this.uamatches("windows nt 6.1")) {
								this.version(os, "7");
							} else {
								if(this.uamatches("windows nt 6.0")) {
									this.version(os, "vista");
								} else {
									if(this.uamatches("windows nt 5.2") || this.uamatches("windows nt 5.1") || this.uamatches("windows xp")) {
										this.version(os, "xp");
									} else {
										if(this.uamatches("windows nt 5.0") || this.uamatches("windows 2000")) {
											this.version(os, "2k");
										} else {
											if(this.uamatches("winnt") || this.uamatches("windows nt")) {
												this.version(os, "nt");
											} else {
												if(this.uamatches("win98") || this.uamatches("windows 98")) {
													this.version(os, "98");
												} else {
													if(this.uamatches("win95") || this.uamatches("windows 95")) {
														this.version(os, "95");
													}
												}
											}
										}
									}
								}
							}
						}
					}
				} else {
					if(this.uamatches("mac") || this.uamatches("darwin")) {
						os.name = "mac os";
						if(this.uamatches("68k") || this.uamatches("68000")) {
							this.version(os, "68k");
						} else {
							if(this.uamatches("ppc") || this.uamatches("powerpc")) {
								this.version(os, "ppc");
							} else {
								if(this.uamatches("os x")) {
									this.version(os, (this.test(/os\sx\s([\d_]+)/) ? RegExp.$1 : "os x").replace(/_/g, "."));
								}
							}
						}
					} else {
						if(this.uamatches("webtv")) {
							os.name = "webtv";
						} else {
							if(this.uamatches("x11") || this.uamatches("inux")) {
								os.name = "linux";
							} else {
								if(this.uamatches("sunos")) {
									os.name = "sun";
								} else {
									if(this.uamatches("irix")) {
										os.name = "irix";
									} else {
										if(this.uamatches("freebsd")) {
											os.name = "freebsd";
										} else {
											if(this.uamatches("bsd")) {
												os.name = "bsd";
											}
										}
									}
								}
							}
						}
					}
				}
			}
			if(this.test(/\sx64|\sx86|\swin64|\swow64|\samd64/)) {
				os.addressRegisterSize = "64bit";
			} else {
				os.addressRegisterSize = "32bit";
			}
			this.operatingSystem = os;
		},
		detectBrowser: function() {
			var browser;
			browser = {};
			if(!this.test(/opera|webtv/) && (this.test(/msie\s([\d\w\.]+)/) || this.uamatches("trident"))) {
				browser.engine = "trident";
				browser.name = "ie";
				if(!window.addEventListener && document.documentMode && document.documentMode === 7) {
					this.version(browser, "8.compat");
				} else {
					if(this.test(/trident.*rv[ :](\d+)\./)) {
						this.version(browser, RegExp.$1);
					} else {
						this.version(browser, this.test(/trident\/4\.0/) ? "8" : RegExp.$1);
					}
				}
			} else {
				if(this.uamatches("firefox")) {
					browser.engine = "gecko";
					browser.name = "firefox";
					this.version(browser, this.test(/firefox\/([\d\w\.]+)/) ? RegExp.$1 : "");
				} else {
					if(this.uamatches("gecko/")) {
						browser.engine = "gecko";
					} else {
						if(this.uamatches("opera") || this.uamatches("opr")) {
							browser.name = "opera";
							browser.engine = "presto";
							this.version(browser, this.test(/version\/([\d\.]+)/) ? RegExp.$1 : this.test(/opera(\s|\/)([\d\.]+)/) ? RegExp.$2 : "");
						} else {
							if(this.uamatches("konqueror")) {
								browser.name = "konqueror";
							} else {
								if(this.uamatches("chrome")) {
									browser.engine = "webkit";
									browser.name = "chrome";
									this.version(browser, this.test(/chrome\/([\d\.]+)/) ? RegExp.$1 : "");
								} else {
									if(this.uamatches("iron")) {
										browser.engine = "webkit";
										browser.name = "iron";
									} else {
										if(this.uamatches("crios")) {
											browser.name = "chrome";
											browser.engine = "webkit";
											this.version(browser, this.test(/crios\/([\d\.]+)/) ? RegExp.$1 : "");
										} else {
											if(this.uamatches("applewebkit/")) {
												browser.name = "safari";
												browser.engine = "webkit";
												this.version(browser, this.test(/version\/([\d\.]+)/) ? RegExp.$1 : "");
											} else {
												if(this.uamatches("mozilla/")) {
													browser.engine = "gecko";
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
			this.browser = browser;
		},
		detectLanguage: function() {
			var body, win;
			body = _c.$body[0];
			win = _c.$win[0];
			this.browserLanguage.direction = win.getComputedStyle(body).direction || "ltr";
			this.browserLanguage.code = win.navigator.userLanguage || win.navigator.language;
		},
		detectPlugins: function() {
			var plugin, _i, _len, _ref, _results;
			this.plugins = [];
			if(typeof window.navigator.plugins !== "undefined") {
				_ref = window.navigator.plugins;
				_results = [];
				for(_i = 0, _len = _ref.length; _i < _len; _i++) {
					plugin = _ref[_i];
					_results.push(this.plugins.push(plugin.name));
				}
				return _results;
			}
		},
		detectSupport: function() {
			var check, supports, _i, _len, _ref;
			supports = function() {
				var div, vendors;
				div = _c.$doc[0].createElement("div");
				vendors = "Khtml Ms ms O Moz Webkit".split(" ");
				return function(prop) {
					var vendor, _i, _len;
					if(typeof div.style[prop] !== "undefined") {
						return true;
					}
					prop = prop.replace(/^[a-z]/, function(val) {
						return val.toUpperCase();
					});
					for(_i = 0, _len = vendors.length; _i < _len; _i++) {
						vendor = vendors[_i];
						if(typeof div.style[vendor + prop] !== "undefined") {
							return true;
						}
					}
					return false;
				};
			}();
			if(!this.css) {
				this.css = {};
			}
			_ref = this.options.detectSupport;
			for(_i = 0, _len = _ref.length; _i < _len; _i++) {
				check = _ref[_i];
				this.css[check] = supports(check);
				return;
			}
		},
		addClasses: function() {
			var k, modelClass, nameClass, orientationClass, sizeClass, supportClass, touchClass, typeClass, v, _ref;
			this.removeClasses();
			if(this.browser.name) {
				nameClass = this.browser.name;
				if(nameClass === "ie") {
					nameClass += " ie" + this.browser.major;
				}
				this.classes.push(nameClass);
				_c.$html.addClass(nameClass);
			}
			if(this.device.type) {
				typeClass = this.device.type;
				this.classes.push(typeClass);
				_c.$html.addClass(typeClass);
			}
			if(this.device.model) {
				modelClass = this.device.model;
				this.classes.push(modelClass);
				_c.$html.addClass(modelClass);
			}
			if(this.device.orientation) {
				orientationClass = this.device.orientation;
				this.classes.push(orientationClass);
				_c.$html.addClass(orientationClass);
			}
			if(this.screen.size) {
				sizeClass = "screen-" + this.screen.size;
				this.classes.push(sizeClass);
				_c.$html.addClass(sizeClass);
			}
			_ref = this.css;
			for(k in _ref) {
				v = _ref[k];
				if(!v) {
					supportClass = "no" + k;
					this.classes.push(supportClass);
					_c.$html.addClass(supportClass);
				}
			}
			touchClass = this.screen.touch ? "touch" : "notouch";
			this.classes.push(touchClass);
			_c.$html.addClass(touchClass);
			if(this.browserLanguage.direction) {
				_c.$html.attr("dir", this.browserLanguage.direction);
			}
			if(this.browserLanguage.code) {
				return _c.$html.attr("lang", this.browserLanguage.code);
			}
		},
		removeClasses: function() {
			if(!this.classes) {
				this.classes = [];
			}
			$.each(this.classes, function(idx, selector) {
				return _c.$html.removeClass(selector);
			});
			this.classes = [];
		}
	});
});
