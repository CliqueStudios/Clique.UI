(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-autocomplete", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.autocomplete requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, active;
	$ = _c.$;
	active = null;
	_c.component("autocomplete", {
		defaults: {
			minLength: 3,
			param: "search",
			method: "post",
			delay: 300,
			loadingClass: "loading",
			flipDropdown: false,
			skipClass: "skip",
			hoverClass: "active",
			source: null,
			renderer: null,
			template: '<ul class="nav nav-autocomplete autocomplete-results">{{~items}}<li data-value="{{$item.value}}"><a>{{$item.value}}</a></li>{{/items}}</ul>'
		},
		visible: false,
		value: null,
		selected: null,
		boot: function() {
			_c.$html.on("focus.autocomplete.clique", "[data-autocomplete]", function(e) {
				var ele, obj;
				ele = _c.$(this);
				if(!ele.data("clique.data.autocomplete")) {
					obj = _c.autocomplete(ele, _c.utils.options(ele.attr("data-autocomplete")));
				}
			});
			return _c.$html.on("click.autocomplete.clique", function(e) {
				if(active && e.target !== active.input[0]) {
					return active.hide();
				}
			});
		},
		init: function() {
			var $this, select, trigger;
			$this = this;
			select = false;
			trigger = _c.utils.debounce(function(e) {
				if(select) {
					select = false;
					return;
				}
				return $this.handle();
			}, this.options.delay);
			this.dropdown = this.find(".dropdown");
			this.template = this.find('script[type="text/autocomplete"]').html();
			this.template = _c.utils.template(this.template || this.options.template);
			this.input = this.find("input:first").attr("autocomplete", "off");
			if(!this.dropdown.length) {
				this.dropdown = _c.$('<div class="dropdown"></div>').appendTo(this.element);
			}
			if(this.options.flipDropdown) {
				this.dropdown.addClass("dropdown-flip");
			}
			this.dropdown.attr("aria-expanded", "false");
			this.input.on({
				keydown: function(e) {
					if(e && e.which && !e.shiftKey) {
						switch(e.which) {
							case 13:
								select = true;
								if($this.selected) {
									e.preventDefault();
									return $this.select();
								}
								break;

							case 38:
								e.preventDefault();
								return $this.pick("prev", true);

							case 40:
								e.preventDefault();
								return $this.pick("next", true);

							case 27:
							case 9:
								return $this.hide();
						}
					}
				},
				keyup: trigger
			});
			this.dropdown.on("click", ".autocomplete-results > *", function() {
				return $this.select();
			});
			this.dropdown.on("mouseover", ".autocomplete-results > *", function() {
				return $this.pick(_c.$(this));
			});
			this.triggercomplete = trigger;
		},
		handle: function() {
			var $this, old;
			$this = this;
			old = this.value;
			this.value = this.input.val();
			if(this.value.length < this.options.minLength) {
				return this.hide();
			}
			if(this.value !== old) {
				$this.request();
			}
			return this;
		},
		pick: function(item, scrollinview) {
			var $this, dpheight, index, items, scrollTop, selected, top;
			$this = this;
			items = _c.$(this.dropdown.find(".autocomplete-results").children(":not(." + this.options.skipClass + ")"));
			selected = false;
			if(typeof item !== "string" && !item.hasClass(this.options.skipClass)) {
				selected = item;
			} else {
				if(item === "next" || item === "prev") {
					if(this.selected) {
						index = items.index(this.selected);
						if(item === "next") {
							selected = items.eq(index + 1 < items.length ? index + 1 : 0);
						} else {
							selected = items.eq(index - 1 < 0 ? items.length - 1 : index - 1);
						}
					} else {
						selected = items[item === "next" ? "first" : "last"]();
					}
					selected = _c.$(selected);
				}
			}
			if(selected && selected.length) {
				this.selected = selected;
				items.removeClass(this.options.hoverClass);
				this.selected.addClass(this.options.hoverClass);
				if(scrollinview) {
					top = selected.position().top;
					scrollTop = $this.dropdown.scrollTop();
					dpheight = $this.dropdown.height();
					if(top > dpheight || top < 0) {
						return $this.dropdown.scrollTop(scrollTop + top);
					}
				}
			}
		},
		select: function() {
			var data;
			if(!this.selected) {
				return;
			}
			data = this.selected.data();
			this.trigger("select.clique.autocomplete", [data, this]);
			if(data.value) {
				this.input.val(data.value).trigger("change");
			}
			return this.hide();
		},
		show: function() {
			if(this.visible) {
				return;
			}
			this.visible = true;
			this.element.addClass("open");
			active = this;
			this.dropdown.attr("aria-expanded", "true");
			return this;
		},
		hide: function() {
			if(!this.visible) {
				return;
			}
			this.visible = false;
			this.element.removeClass("open");
			if(active === this) {
				active = false;
			}
			this.dropdown.attr("aria-expanded", "false");
			return this;
		},
		request: function() {
			var $this, items, params, release, source;
			$this = this;
			release = function(data) {
				if(data) {
					$this.render(data);
				}
				return $this.element.removeClass($this.options.loadingClass);
			};
			this.element.addClass(this.options.loadingClass);
			if(this.options.source) {
				source = this.options.source;
				switch(typeof this.options.source) {
					case "function":
						return this.options.source.apply(this, [release]);

					case "object":
						if(source.length) {
							items = [];
							source.forEach(function(item) {
								if(item.value && item.value.toLowerCase().indexOf($this.value.toLowerCase()) !== -1) {
									return items.push(item);
								}
							});
							return release(items);
						}
						break;

					case "string":
						params = {};
						params[this.options.param] = this.value;
						return _c.$.ajax({
							url: this.options.source,
							data: params,
							type: this.options.method,
							dataType: "json"
						}).done(function(json) {
							release(json || []);
						});

					default:
						return release(null);
				}
			} else {
				return this.element.removeClass($this.options.loadingClass);
			}
		},
		render: function(data) {
			this.dropdown.empty();
			this.selected = false;
			if(this.options.renderer) {
				this.options.renderer.apply(this, [data]);
			} else {
				if(data && data.length) {
					this.dropdown.append(this.template({
						items: data
					}));
					this.show();
					this.trigger("show.clique.autocomplete");
				}
			}
			return this;
		}
	});
	return _c.autocomplete;
});
