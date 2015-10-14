(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-grid", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.grid requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, grids;
	$ = _c.$;
	grids = [];
	_c.component("rowMatchHeight", {
		defaults: {
			target: false,
			row: true
		},
		boot: function() {
			return _c.ready(function(context) {
				return $("[data-row-match]", context).each(function() {
					var grid, obj;
					grid = $(this);
					if(!grid.data("rowMatchHeight")) {
						obj = _c.rowMatchHeight(grid, _c.utils.options(grid.attr("data-row-match")));
					}
				});
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.columns = this.element.children();
			this.elements = this.options.target ? this.find(this.options.target) : this.columns;
			if(!this.columns.length) {
				return;
			}
			_c.$win.on("load resize orientationchange", function() {
				var fn;
				fn = function() {
					return $this.match();
				};
				_c.$(function() {
					return fn();
				});
				return _c.utils.debounce(fn, 50);
			}());
			_c.$html.on("changed.clique.dom", function(e) {
				$this.columns = $this.element.children();
				$this.elements = $this.options.target ? $this.find($this.options.target) : $this.columns;
				return $this.match();
			});
			this.on("display.clique.check", function(_this) {
				return function(e) {
					if(_this.element.is(":visible")) {
						return _this.match();
					}
				};
			}(this));
			return grids.push(this);
		},
		match: function() {
			var firstvisible, stacked;
			firstvisible = this.columns.filter(":visible:first");
			if(!firstvisible.length) {
				return;
			}
			stacked = Math.ceil(100 * parseFloat(firstvisible.css("width")) / parseFloat(firstvisible.parent().css("width"))) >= 100;
			if(stacked) {
				this.revert();
			} else {
				_c.utils.matchHeights(this.elements, this.options);
			}
			return this;
		},
		revert: function() {
			this.elements.css("min-height", "");
			return this;
		}
	});
	_c.component("rowMargin", {
		defaults: {
			cls: "row-margin"
		},
		boot: function() {
			return _c.ready(function(context) {
				return $("[data-row-margin]", context).each(function() {
					var grid, obj;
					grid = $(this);
					if(!grid.data("rowMargin")) {
						obj = _c.rowMargin(grid, _c.utils.options(grid.attr("data-row-margin")));
					}
				});
			});
		},
		init: function() {
			var firstChild = this.find("> *").first();
			var leftSpacing = parseInt(firstChild.css("padding-left"), 10);
			this.element.css("margin-bottom", -leftSpacing);
			this.find("> *").css("margin-bottom", leftSpacing);
		}
	});
	_c.utils.matchHeights = function(elements, options) {
		var matchHeights;
		elements = $(elements).css("min-height", "");
		options = _c.$.extend({
			row: true
		}, options);
		matchHeights = function(group) {
			var max;
			if(group.length < 2) {
				return;
			}
			max = 0;
			return group.each(function() {
				max = Math.max(max, $(this).outerHeight());
			}).each(function() {
				return $(this).css("min-height", max);
			});
		};
		if(options.row) {
			elements.first().width();
			return setTimeout(function() {
				var group, lastoffset;
				lastoffset = false;
				group = [];
				elements.each(function() {
					var ele, offset;
					ele = $(this);
					offset = ele.offset().top;
					if(offset !== lastoffset && group.length) {
						matchHeights($(group));
						group = [];
						offset = ele.offset().top;
					}
					group.push(ele);
					lastoffset = offset;
				});
				if(group.length) {
					return matchHeights($(group));
				}
			}, 0);
		} else {
			return matchHeights(elements);
		}
	};
});
