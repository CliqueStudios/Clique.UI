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
