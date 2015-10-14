(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-modal", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.modal requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, active, setContent;
	$ = _c.$;
	setContent = function(content, modal) {
		if(!modal) {
			return;
		}
		if(typeof content === "object") {
			content = content instanceof jQuery ? content : $(content);
			if(content.parent().length) {
				modal.persist = content;
				modal.persist.data("modalPersistParent", content.parent());
			}
		} else {
			if(typeof content === "string" || typeof content === "number") {
				content = $("<div></div>").html(content);
			} else {
				content = $("<div></div>").html("Clique.modal Error : Unsupported data type : " + typeof content);
			}
		}
		content.appendTo(modal.element.find(".modal-dialog"));
		return modal;
	};
	active = false;
	_c.component("modal", {
		scrollable: false,
		transition: false,
		defaults: {
			keyboard: true,
			bgclose: true,
			minScrollHeight: 150,
			center: false
		},
		init: function() {
			var $this;
			$this = this;
			this.transition = _c.support.transition;
			this.paddingdir = "padding-" + (_c.langdirection === "left" ? "right" : "left");
			this.dialog = this.find(".modal-dialog");
			this.element.attr("aria-hidden", this.element.hasClass("open"));
			return this.on("click", ".modal-close", function(e) {
				e.preventDefault();
				return $this.hide();
			}).on("click", function(e) {
				var target;
				target = $(e.target);
				if(target[0] === $this.element[0] && $this.options.bgclose) {
					return $this.hide();
				}
			});
		},
		toggle: function() {
			return this[this.isActive() ? "hide" : "show"]();
		},
		show: function() {
			var $this;
			$this = this;
			if(this.isActive()) {
				return;
			}
			if(active) {
				active.hide(true);
			}
			this.element.removeClass("open").show();
			this.resize();
			active = this;
			_c.$html.addClass("modal-page").height();
			this.element.addClass("open");
			this.element.attr("aria-hidden", "false");
			this.element.trigger("show.clique.modal");
			_c.utils.checkDisplay(this.dialog, true);
			return this;
		},
		hide: function(force) {
			var $this;
			if(!this.isActive()) {
				return;
			}
			if(!force && _c.support.transition) {
				$this = this;
				this.one(_c.support.transition.end, function() {
					return $this._hide();
				}).removeClass("open");
			} else {
				this._hide();
			}
			return this;
		},
		resize: function() {
			var bodywidth, dh, pad;
			bodywidth = _c.$body.width();
			this.scrollbarwidth = window.innerWidth - bodywidth;
			_c.$body.css(this.paddingdir, this.scrollbarwidth);
			this.element.css("overflow-y", this.scrollbarwidth ? "scroll" : "auto");
			if(!this.updateScrollable() && this.options.center) {
				dh = this.dialog.outerHeight();
				pad = parseInt(this.dialog.css("margin-top"), 10) + parseInt(this.dialog.css("margin-bottom"), 10);
				if(dh + pad < window.innerHeight) {
					return this.dialog.css({
						top: window.innerHeight / 2 - dh / 2 - pad
					});
				} else {
					return this.dialog.css({
						top: ""
					});
				}
			}
		},
		updateScrollable: function() {
			var dh, h, offset, scrollable, wh;
			scrollable = this.dialog.find(".overflow-container:visible:first");
			if(scrollable.length) {
				scrollable.css("height", 0);
				offset = Math.abs(parseInt(this.dialog.css("margin-top"), 10));
				dh = this.dialog.outerHeight();
				wh = window.innerHeight;
				h = wh - 2 * (offset < 20 ? 20 : offset) - dh;
				scrollable.css("height", h < this.options.minScrollHeight ? "" : h);
				return true;
			}
			return false;
		},
		_hide: function() {
			this.element.hide().removeClass("open");
			this.element.attr("aria-hidden", "true");
			_c.$html.removeClass("modal-page");
			_c.$body.css(this.paddingdir, "");
			if(active === this) {
				active = false;
			}
			return this.trigger("hide.clique.modal");
		},
		isActive: function() {
			return active === this;
		}
	});
	_c.component("modalTrigger", {
		boot: function() {
			_c.$html.on("click.modal.clique", "[data-modal]", function(e) {
				var ele, modal;
				ele = $(this);
				if(ele.is("a")) {
					e.preventDefault();
				}
				if(!ele.data("clique.data.modalTrigger")) {
					modal = _c.modalTrigger(ele, _c.utils.options(ele.attr("data-modal")));
					return modal.show();
				}
			});
			_c.$html.on("keydown.modal.clique", function(e) {
				if(active && e.keyCode === 27 && active.options.keyboard) {
					e.preventDefault();
					return active.hide();
				}
			});
			return _c.$win.on("resize orientationchange", _c.utils.debounce(function() {
				if(active) {
					return active.resize();
				}
			}, 150));
		},
		init: function() {
			var $this;
			$this = this;
			this.options = _c.$.extend({
				target: $this.element.is("a") ? $this.element.attr("href") : false
			}, this.options);
			this.modal = _c.modal(this.options.target, this.options);
			this.on("click", function(e) {
				e.preventDefault();
				return $this.show();
			});
			return this.proxy(this.modal, "show hide isActive");
		}
	});
	_c.modal.dialog = function(content, options) {
		var modal;
		modal = _c.modal($(_c.modal.dialog.template).appendTo("body"), options);
		modal.on("hide.clique.modal", function() {
			if(modal.persist) {
				modal.persist.appendTo(modal.persist.data("modalPersistParent"));
				modal.persist = false;
			}
			return modal.element.remove();
		});
		setContent(content, modal);
		return modal;
	};
	_c.modal.dialog.template = '<div class="modal"><div class="modal-dialog" style="min-height :0;"></div></div>';
	_c.modal.alert = function(content, options) {
		return _c.modal.dialog(['<div class="margin modal-content">' + String(content) + "</div>", '<div class="modal-footer text-right"><button class="button button-primary modal-close">Ok</button></div>'].join(""), _c.$.extend({
			bgclose: false,
			keyboard: false
		}, options)).show();
	};
	_c.modal.confirm = function(content, onconfirm, options) {
		var modal;
		onconfirm = _c.$.isFunction(onconfirm) ? onconfirm : function() {};
		modal = _c.modal.dialog(['<div class="margin modal-content">' + String(content) + "</div>", '<div class="modal-footer text-right"><button class="button button-primary js-modal-confirm">Ok</button> <button class="button modal-close">Cancel</button></div>'].join(""), _c.$.extend({
			bgclose: false,
			keyboard: false
		}, options));
		modal.element.find(".js-modal-confirm").on("click", function() {
			onconfirm();
			return modal.hide();
		});
		return modal.show();
	};
});
