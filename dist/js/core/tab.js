(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-tab", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.tab requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	return _c.component("tab", {
		defaults: {
			target: "> li:not(.tab-responsive, .disabled)",
			connect: false,
			active: 0,
			animation: false,
			duration: 200
		},
		boot: function() {
			return _c.ready(function(context) {
				return $("[data-tab]", context).each(function() {
					var obj, tab;
					tab = $(this);
					if(!tab.data("clique.data.tab")) {
						obj = _c.tab(tab, _c.utils.options(tab.attr("data-tab")));
					}
				});
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.on("click.clique.tab", this.options.target, function(e) {
				var current;
				e.preventDefault();
				if($this.switcher && $this.switcher.animating) {
					return;
				}
				current = $this.find($this.options.target).not(this);
				current.removeClass("active").blur();
				$this.trigger("change.clique.tab", [$(this).addClass("active")]);
				if(!$this.options.connect) {
					current.attr("aria-expanded", "false");
					return $(this).attr("aria-expanded", "true");
				}
			});
			if(this.options.connect) {
				this.connect = $(this.options.connect);
			}
			this.responsivetab = $('<li class="tab-responsive active"><a></a></li>').append('<div class="dropdown dropdown-small"><ul class="nav nav-dropdown"></ul><div>');
			this.responsivetab.dropdown = this.responsivetab.find(".dropdown");
			this.responsivetab.lst = this.responsivetab.dropdown.find("ul");
			this.responsivetab.caption = this.responsivetab.find("a:first");
			if(this.element.hasClass("tab-bottom")) {
				this.responsivetab.dropdown.addClass("dropdown-up");
			}
			this.responsivetab.lst.on("click.clique.tab", "a", function(e) {
				var link;
				e.preventDefault();
				e.stopPropagation();
				link = $(this);
				return $this.element.children(":not(.tab-responsive)").eq(link.data("index")).trigger("click");
			});
			this.on("show.clique.switcher change.clique.tab", function(e, tab) {
				return $this.responsivetab.caption.html(tab.text());
			});
			this.element.append(this.responsivetab);
			if(this.options.connect) {
				this.switcher = _c.switcher(this.element, {
					toggle: "> li:not(.tab-responsive)",
					connect: this.options.connect,
					active: this.options.active,
					animation: this.options.animation,
					duration: this.options.duration
				});
			}
			_c.dropdown(this.responsivetab, {
				mode: "click"
			});
			$this.trigger("change.clique.tab", [this.element.find(this.options.target).filter(".active")]);
			this.check();
			_c.$win.on("resize orientationchange", _c.utils.debounce(function() {
				if($this.element.is(":visible")) {
					return $this.check();
				}
			}, 100));
			return this.on("display.clique.check", function() {
				if($this.element.is(":visible")) {
					return $this.check();
				}
			});
		},
		check: function() {
			var children, doresponsive, i, item, link, top;
			children = this.element.children(":not(.tab-responsive)").removeClass("hidden");
			if(!children.length) {
				return;
			}
			top = children.eq(0).offset().top + Math.ceil(children.eq(0).height() / 2);
			doresponsive = false;
			this.responsivetab.lst.empty();
			children.each(function() {
				if($(this).offset().top > top) {
					doresponsive = true;
				}
			});
			if(doresponsive) {
				i = 0;
				while(i < children.length) {
					item = $(children.eq(i));
					link = item.find("a");
					if(item.css("float") !== "none" && !item.attr("dropdown")) {
						item.addClass("hidden");
						if(!item.hasClass("disabled")) {
							this.responsivetab.lst.append('<li><a href="' + link.attr("href") + '" data-index="' + i + '">' + link.html() + "</a></li>");
						}
					}
					i++;
				}
			}
			return this.responsivetab[this.responsivetab.lst.children().length ? "removeClass" : "addClass"]("hidden");
		}
	});
});
