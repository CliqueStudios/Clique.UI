(function(addon) {
	if(typeof define === 'function' && define.amd) {
		define('clique-smoothScroll', ['clique'], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error('Clique.smoothScroll requires Clique.core');
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, listenForScroll, scrollToElement;
	$ = _c.$;
	listenForScroll = function() {
		return _c.$win.on('mousewheel', function() {
			return $('html, body').stop(true);
		});
	};
	scrollToElement = function(ele, options) {
		var docheight, target, winheight;
		options = _c.$.extend({
			duration: 1e3,
			transition: 'easeOutExpo',
			offset: 0,
			complete: function() {}
		}, options);
		target = ele.offset().top - options.offset;
		docheight = _c.$doc.height();
		winheight = window.innerHeight;
		if(target + winheight > docheight) {
			target = docheight - winheight;
		}
		listenForScroll();
		return $('html, body').stop().animate({
			scrollTop: target
		}, options.duration, options.transition).promise().done(function() {
			options.complete();
			$('html, body').trigger('didscroll.clique.smooth-scroll');
			return _c.$win.off('mousewheel');
		});
	};
	_c.component('smoothScroll', {
		boot: function() {
			return _c.$html.on('click.smooth-scroll.clique', '[data-smooth-scroll]', function(e) {
				var ele, obj;
				e.preventDefault();
				ele = $(this);
				if(!ele.data('clique.data.smoothScroll')) {
					obj = _c.smoothScroll(ele, _c.utils.options(ele.attr('data-smooth-scroll')));
					return ele.trigger('click');
				}
			});
		},
		init: function() {
			var $this;
			$this = this;
			return this.on('click', function(e) {
				e.preventDefault();
				$('html, body').trigger('willscroll.clique.smooth-scroll');
				return scrollToElement(($(this.hash).length ? $(this.hash) : _c.$('body')), $this.options);
			});
		}
	});
	_c.utils.scrollToElement = scrollToElement;
	if(!_c.$.easing.easeOutExpo) {
		_c.$.easing.easeOutExpo = function(x, t, b, c, d) {
			if(t === d) {
				return b + c;
			} else {
				return c * (-Math.pow(2, -10 * t / d) + 1) + b;
			}
		};
	}
});
