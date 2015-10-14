(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-timepicker", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique || !window.Clique.autocomplete) {
		throw new Error("Clique.timepicker requires Clique.core and Clique.autocomplete");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, h, i, times;
	$ = _c.$;
	times = {
		"12h": [],
		"24h": []
	};
	i = 0;
	h = "";
	while(i < 24) {
		h = "" + i;
		if(i < 10) {
			h = "0" + h;
		}
		times["24h"].push({
			value: h + ":00"
		});
		times["24h"].push({
			value: h + ":30"
		});
		if(i > 0 && i < 13) {
			times["12h"].push({
				value: h + ":00 AM"
			});
			times["12h"].push({
				value: h + ":30 AM"
			});
		}
		if(i > 12) {
			h = h - 12;
			if(h < 10) {
				h = "0" + String(h);
			}
			times["12h"].push({
				value: h + ":00 PM"
			});
			times["12h"].push({
				value: h + ":30 PM"
			});
		}
		i++;
	}
	return _c.component("timepicker", {
		defaults: {
			format: "24h",
			delay: 0
		},
		boot: function() {
			return _c.$html.on("focus.timepicker.clique", "[data-timepicker]", function(e) {
				var ele, obj;
				ele = _c.$(this);
				if(!ele.data("clique.data.timepicker")) {
					obj = _c.timepicker(ele, _c.utils.options(ele.attr("data-timepicker")));
					return setTimeout(function() {
						return obj.autocomplete.input.focus();
					}, 40);
				}
			});
		},
		init: function() {
			var $this;
			$this = this;
			this.options.minLength = 0;
			this.options.template = '<ul class="nav nav-autocomplete autocomplete-results">{{~items}}<li data-value="{{$item.value}}"><a>{{$item.value}}</a></li>{{/items}}</ul>';
			this.options.source = function(release) {
				return release(times[$this.options.format] || times["12h"]);
			};
			this.element.wrap('<div class="autocomplete"></div>');
			this.autocomplete = _c.autocomplete(this.element.parent(), this.options);
			this.autocomplete.dropdown.addClass("dropdown-small dropdown-scrollable");
			this.autocomplete.on("show.clique.autocomplete", function() {
				var selected;
				selected = $this.autocomplete.dropdown.find('[data-value="' + $this.autocomplete.input.val() + '"]');
				return setTimeout(function() {
					return $this.autocomplete.pick(selected, true);
				}, 10);
			});
			this.autocomplete.input.on({
				focus: function() {
					$this.autocomplete.value = Math.random();
					return $this.autocomplete.triggercomplete();
				},
				blur: function() {
					return $this.checkTime();
				}
			});
			return this.element.data("timepicker", this);
		},
		checkTime: function() {
			var arr, hour, meridian, minute, time, timeArray;
			arr = null;
			timeArray = null;
			meridian = "AM";
			hour = null;
			minute = null;
			time = this.autocomplete.input.val();
			if(this.options.format === "12h") {
				arr = time.split(" ");
				timeArray = arr[0].split(":");
				meridian = arr[1];
			} else {
				timeArray = time.split(":");
			}
			hour = parseInt(timeArray[0], 10);
			minute = parseInt(timeArray[1], 10);
			if(isNaN(hour)) {
				hour = 0;
			}
			if(isNaN(minute)) {
				minute = 0;
			}
			if(this.options.format === "12h") {
				if(hour > 12) {
					hour = 12;
				} else {
					if(hour < 0) {
						hour = 12;
					}
				}
				if(meridian === "am" || meridian === "a") {
					meridian = "AM";
				} else {
					if(meridian === "pm" || meridian === "p") {
						meridian = "PM";
					}
				}
				if(meridian !== "AM" && meridian !== "PM") {
					meridian = "AM";
				}
			} else {
				if(hour >= 24) {
					hour = 23;
				} else {
					if(hour < 0) {
						hour = 0;
					}
				}
			}
			if(minute < 0) {
				minute = 0;
			} else {
				if(minute >= 60) {
					minute = 0;
				}
			}
			return this.autocomplete.input.val(this.formatTime(hour, minute, meridian)).trigger("change");
		},
		formatTime: function(hour, minute, meridian) {
			hour = hour < 10 ? "0" + hour : hour;
			minute = minute < 10 ? "0" + minute : minute;
			return hour + ":" + minute + (this.options.format === "12h" ? " " + meridian : "");
		}
	});
});
