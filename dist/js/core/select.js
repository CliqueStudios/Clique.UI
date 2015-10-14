(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-select", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.select requires Clique.core");
	}
	if(!window.Clique.dropdown) {
		throw new Error("Clique.select requires the Clique.dropdown component");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	_c.component("select", {
		defaults: {
			inheritClasses: true
		},
		boot: function() {
			_c.$doc.on("ready", function() {
				$("[data-select]").each(function() {
					var ele, obj;
					ele = $(this);
					if(!ele.is("select")) {
						ele.find("select").each(function() {
							var obj;
							if(!ele.data("clique.data.select")) {
								obj = _c.select(ele);
							}
						});
					} else {
						if(!ele.data("clique.data.select")) {
							obj = _c.select(ele);
						}
					}
				});
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.element.on("clique.select.change", function(e, idx, obj) {
				return $this.updateSelect(idx, obj);
			});
			this.selectOptions = [];
			this.element.children("option").each(function(i) {
				return $this.selectOptions.push({
					text: $(this).text(),
					value: $(this).val()
				});
			});
			this.template();
			this.bindSelect();
			return setTimeout(function() {
				return $this.select.find(".nav-dropdown li:first-child a").trigger("click");
			}, 0);
		},
		template: function() {
			var $this, classes, cls, firstOption, width;
			cls = [];
			if(this.options.inheritClasses && this.element.attr("class")) {
				classes = this.element.attr("class").split(" ");
				$.each(classes, function(i) {
					return cls.push(classes[i]);
				});
			}
			cls.push("select");
			width = this.element.width() + 23;
			this.select = $('<div class="' + cls.join(" ") + '" data-dropdown="{mode:\'click\'}" style="width:' + width + 'px;" />');
			firstOption = this.element.children("option").first();
			this.select.append($('<a href="#" class="select-link"></a>'));
			this.select.append($('<div class="dropdown dropdown-scrollable"><ul class="nav nav-dropdown nav-side" /></div>'));
			$this = this;
			$.each(this.selectOptions, function(i, v) {
				var option;
				option = $('<li><a href="#">' + v.text + "</a></li>");
				return $this.select.find(".nav-dropdown").append(option);
			});
			this.element.before(this.select);
			return this.element.hide();
		},
		bindSelect: function() {
			var $this;
			$this = this;
			return this.select.on("click", ".nav-dropdown a", function(e) {
				var idx, obj, option;
				e.preventDefault();
				idx = $(this).parent("li").index();
				option = $this.selectOptions[idx];
				obj = {
					value: option.value,
					text: option.text
				};
				return $this.element.trigger("clique.select.change", [idx, obj]);
			});
		},
		updateSelect: function(idx, obj) {
			var li;
			this.select.find(".nav-dropdown li").removeClass("active");
			li = this.select.find(".nav-dropdown li").eq(idx);
			li.addClass("active");
			this.select.children(".select-link").text(obj.text);
			this.element.val(obj.value);
			return this.trigger("change");
		}
	});
	return _c.select;
});
