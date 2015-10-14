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
