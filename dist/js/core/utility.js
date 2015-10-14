(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-utility", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.utility requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, stacks;
	$ = _c.$;
	stacks = [];
	_c.component("stackMargin", {
		defaults: {
			cls: "margin-small-top"
		},
		boot: function() {
			return _c.ready(function(context) {
				return $("[data-margin]", context).each(function() {
					var ele, obj;
					ele = $(this);
					if(!ele.data("clique.data.stackMargin")) {
						obj = _c.stackMargin(ele, _c.utils.options(ele.attr("data-margin")));
					}
				});
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.columns = this.element.children();
			if(!this.columns.length) {
				return;
			}
			_c.$win.on("resize orientationchange", function() {
				var fn;
				fn = function() {
					return $this.process();
				};
				_c.$(function() {
					fn();
					return _c.$win.on("load", fn);
				});
				return _c.utils.debounce(fn, 20);
			}());
			_c.$html.on("changed.clique.dom", function(e) {
				$this.columns = $this.element.children();
				return $this.process();
			});
			this.on("display.clique.check", function(_this) {
				return function(e) {
					$this.columns = $this.element.children();
					if(_this.element.is(":visible")) {
						return _this.process();
					}
				};
			}(this));
			return stacks.push(this);
		},
		process: function() {
			_c.utils.stackMargin(this.columns, this.options);
			return this;
		},
		revert: function() {
			this.columns.removeClass(this.options.cls);
			return this;
		}
	});
	_c.ready(function() {
		var check, iframes;
		iframes = [];
		check = function() {
			return iframes.forEach(function(iframe) {
				var height, iwidth, ratio, width;
				if(!iframe.is(":visible")) {
					return;
				}
				width = iframe.parent().width();
				iwidth = iframe.data("width");
				ratio = width / iwidth;
				height = Math.floor(ratio * iframe.data("height"));
				return iframe.css({
					height: width < iwidth ? height : iframe.data("height")
				});
			});
		};
		_c.$win.on("resize", _c.utils.debounce(check, 15));
		return function(context) {
			$("iframe.responsive-width", context).each(function() {
				var iframe;
				iframe = $(this);
				if(!iframe.data("responsive") && iframe.attr("width") && iframe.attr("height")) {
					iframe.data("width", iframe.attr("width"));
					iframe.data("height", iframe.attr("height"));
					iframe.data("responsive", true);
					return iframes.push(iframe);
				}
			});
			return check();
		};
	}());
	_c.utils.stackMargin = function(elements, options) {
		var firstvisible, offset, skip;
		options = _c.$.extend({
			cls: "margin-small-top"
		}, options);
		options.cls = options.cls;
		elements = $(elements).removeClass(options.cls);
		skip = false;
		firstvisible = elements.filter(":visible:first");
		offset = firstvisible.length ? firstvisible.position().top + firstvisible.outerHeight() - 1 : false;
		if(offset === false) {
			return;
		}
		return elements.each(function() {
			var column;
			column = $(this);
			if(column.is(":visible")) {
				if(skip) {
					return column.addClass(options.cls);
				} else {
					if(column.position().top >= offset) {
						skip = column.addClass(options.cls);
					}
				}
			}
		});
	};
});
