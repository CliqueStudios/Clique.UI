(function(addon) {
	if(typeof define === 'function' && define.amd) {
		define('clique-dropdown', ['clique'], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error('Clique.dropdown requires Clique.core');
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, active, hoverIdle;
	$ = _c.$;
	active = false;
	hoverIdle = null;
	return _c.component('dropdown', {
		defaults: {
			mode: 'hover',
			remaintime: 800,
			justify: false,
			boundary: _c.$win,
			delay: 0
		},
		remainIdle: false,
		boot: function() {
			var triggerevent;
			triggerevent = _c.support.touch ? 'click' : 'mouseenter';
			return _c.$html.on(triggerevent + '.dropdown.clique', '[data-dropdown]', function(e) {
				var ele, obj;
				ele = $(this);
				if(!ele.data('clique.data.dropdown')) {
					obj = _c.dropdown(ele, _c.utils.options(ele.data('dropdown')));
					if(triggerevent === 'click' || triggerevent === 'mouseenter' && obj.options.mode === 'hover') {
						obj.element.trigger(triggerevent);
					}
					if(obj.element.find('.dropdown').length) {
						return e.preventDefault();
					}
				}
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.dropdown = this.find('.dropdown');
			this.centered = this.dropdown.hasClass('dropdown-center');
			this.justified = this.options.justify ? $(this.options.justify) : false;
			this.boundary = $(this.options.boundary);
			this.flipped = this.dropdown.hasClass('dropdown-flip');
			if(!this.boundary.length) {
				this.boundary = _c.$win;
			}
			this.element.attr('aria-haspopup', 'true');
			this.element.attr('aria-expanded', this.element.hasClass('open'));
			if(this.options.mode === 'click' || _c.support.touch) {
				this.on('click.clique.dropdown', function(e) {
					var $target;
					$target = $(e.target);
					if(!$target.parents('.dropdown').length) {
						if($target.is('a[href=\'#\']') || $target.parent().is('a[href=\'#\']') || $this.dropdown.length && !$this.dropdown.is(':visible')) {
							e.preventDefault();
						}
						$target.blur();
					}
					if(!$this.element.hasClass('open')) {
						return $this.show();
					} else {
						if($target.is('a:not(.js-prevent)') || $target.is('.dropdown-close') || !$this.dropdown.find(e.target).length) {
							return $this.hide();
						}
					}
				});
			} else {
				this.on('mouseenter', function(e) {
					if($this.remainIdle) {
						clearTimeout($this.remainIdle);
					}
					if(hoverIdle) {
						clearTimeout(hoverIdle);
					}
					hoverIdle = setTimeout($this.show.bind($this), $this.options.delay);
				}).on('mouseleave', function() {
					if(hoverIdle) {
						clearTimeout(hoverIdle);
					}
					$this.remainIdle = setTimeout(function() {
						return $this.hide();
					}, $this.options.remaintime);
				}).on('click', function(e) {
					var $target;
					$target = $(e.target);
					if($this.remainIdle) {
						clearTimeout($this.remainIdle);
					}
					if($target.is('a[href=\'#\']') || $target.parent().is('a[href=\'#\']')) {
						e.preventDefault();
					}
					return $this.show();
				});
			}
		},
		show: function() {
			_c.$html.off('click.outer.dropdown');
			if(active && active[0] !== this.element[0]) {
				active.removeClass('open');
				active.attr('aria-expanded', 'false');
			}
			if(hoverIdle) {
				clearTimeout(hoverIdle);
			}
			this.checkDimensions();
			this.element.addClass('open');
			this.element.attr('aria-expanded', 'true');
			this.trigger('show.clique.dropdown', [this]);
			_c.utils.checkDisplay(this.dropdown, true);
			active = this.element;
			return this.registerOuterClick();
		},
		hide: function() {
			this.element.removeClass('open');
			this.remainIdle = false;
			this.element.attr('aria-expanded', 'false');
			this.trigger('hide.clique.dropdown', [this]);
			if(active && active[0] === this.element[0]) {
				active = false;
			}
		},
		registerOuterClick: function() {
			var $this;
			$this = this;
			_c.$html.off('click.outer.dropdown');
			return setTimeout((function() {
				return _c.$html.on('click.outer.dropdown', function(e) {
					var $target;
					if(hoverIdle) {
						clearTimeout(hoverIdle);
					}
					$target = $(e.target);
					if(active && active[0] === $this.element[0] && ($target.is('a:not(.js-prevent)') || $target.is('.dropdown-close') || !$this.dropdown.find(e.target).length)) {
						$this.hide();
						return _c.$html.off('click.outer.dropdown');
					}
				});
			}), 10);
		},
		checkDimensions: function() {
			var $this, boundaryoffset, boundarywidth, dropdown, jwidth, offset, right1, right2, width;
			if(!this.dropdown.length) {
				return;
			}
			if(this.justified && this.justified.length) {
				this.dropdown.css('min-width', '');
			}
			$this = this;
			dropdown = this.dropdown.css('margin-' + _c.langdirection, '');
			offset = dropdown.show().offset();
			width = dropdown.outerWidth();
			boundarywidth = this.boundary.width();
			boundaryoffset = this.boundary.offset() ? this.boundary.offset().left : 0;
			if(this.centered) {
				dropdown.css('margin-' + _c.langdirection, (parseFloat(width) / 2 - dropdown.parent().width() / 2) * -1);
				offset = dropdown.offset();
				if(width + offset.left > boundarywidth || offset.left < 0) {
					dropdown.css('margin-' + _c.langdirection, '');
					offset = dropdown.offset();
				}
			}
			if(this.justified && this.justified.length) {
				jwidth = this.justified.outerWidth();
				dropdown.css('min-width', jwidth);
				if(_c.langdirection === 'right') {
					right1 = boundarywidth - (this.justified.offset().left + jwidth);
					right2 = boundarywidth - (dropdown.offset().left + dropdown.outerWidth());
					dropdown.css('margin-right', right1 - right2);
				} else {
					dropdown.css('margin-left', this.justified.offset().left - offset.left);
				}
				offset = dropdown.offset();
			}
			if(width + (offset.left - boundaryoffset) > boundarywidth) {
				dropdown.addClass('dropdown-flip');
				offset = dropdown.offset();
			}
			if(offset.left - boundaryoffset < 0) {
				dropdown.addClass('dropdown-stack');
				if(dropdown.hasClass('dropdown-flip')) {
					if(!this.flipped) {
						dropdown.removeClass('dropdown-flip');
						offset = dropdown.offset();
						dropdown.addClass('dropdown-flip');
					}
					setTimeout(function() {
						if(dropdown.offset().left - boundaryoffset < 0 || !$this.flipped && dropdown.outerWidth() + (offset.left - boundaryoffset) < boundarywidth) {
							return dropdown.removeClass('dropdown-flip');
						}
					}, 0);
				}
				this.trigger('stack.clique.dropdown', [this]);
			}
			return dropdown.css('display', '');
		}
	});
});
