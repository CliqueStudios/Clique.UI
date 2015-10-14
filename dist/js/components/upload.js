(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-upload", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.upload requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $, matchName, xhrupload;
	$ = _c.$;
	xhrupload = function(files, settings) {
		var allow, complete, count, file, upload, uploaded, _i, _len;
		upload = function(files, settings) {
			var file, formData, i, param, xhr, _i, _len, _ref;
			formData = new FormData();
			xhr = new XMLHttpRequest();
			if(settings.before(settings, files) === false) {
				return;
			}
			for(_i = 0, _len = files.length; _i < _len; _i++) {
				file = files[_i];
				formData.append(settings.params, file);
			}
			_ref = settings.params;
			for(i in _ref) {
				param = _ref[i];
				formData.append(i, param);
			}
			xhr.upload.addEventListener("progress", function(e) {
				var percent;
				percent = e.loaded / e.total * 100;
				return settings.progress(percent, e);
			}, false);
			xhr.addEventListener("loadstart", function(e) {
				return settings.loadstart(e);
			}, false);
			xhr.addEventListener("load", function(e) {
				return settings.load(e);
			}, false);
			xhr.addEventListener("loadend", function(e) {
				return settings.loadend(e);
			}, false);
			xhr.addEventListener("error", function(e) {
				return settings.error(e);
			}, false);
			xhr.addEventListener("abort", function(e) {
				return settings.abort(e);
			}, false);
			xhr.open(settings.method, settings.action, true);
			xhr.onreadystatechange = function() {
				var e, response;
				settings.readystatechange(xhr);
				if(xhr.readyState === 4) {
					response = xhr.responseText;
					if(settings.type === "json") {
						try {
							response = _c.$.parseJSON(response);
						} catch(_error) {
							e = _error;
							response = false;
						}
					}
					return settings.complete(response, xhr);
				}
			};
			settings.beforeSend(xhr);
			return xhr.send(formData);
		};
		if(!_c.support.ajaxupload) {
			return this;
		}
		settings = _c.$.extend({}, xhrupload.defaults, settings);
		if(!files.length) {
			return;
		}
		if(settings.allow !== "*.*") {
			for(_i = 0, _len = files.length; _i < _len; _i++) {
				file = files[_i];
				if(!matchName(settings.allow, file.name)) {
					if(typeof settings.notallowed === "string") {
						alert(settings.notallowed);
					} else {
						settings.notallowed(file, settings);
					}
				}
			}
		}
		complete = settings.complete;
		if(settings.single) {
			count = files.length;
			uploaded = 0;
			allow = true;
			settings.beforeAll(files);
			settings.complete = function(response, xhr) {
				uploaded = uploaded + 1;
				complete(response, xhr);
				if(settings.filelimit && uploaded >= settings.filelimit) {
					allow = false;
				}
				if(allow && uploaded < count) {
					return upload([files[uploaded]], settings);
				} else {
					return settings.allcomplete(response, xhr);
				}
			};
			return upload([files[0]], settings);
		} else {
			settings.complete = function(response, xhr) {
				complete(response, xhr);
				return settings.allcomplete(response, xhr);
			};
			return upload(files, settings);
		}
	};
	matchName = function(pattern, path) {
		var parsedPattern;
		parsedPattern = "^" + pattern.replace(/\//g, "\\/").replace(/\*\*/g, "(\\/[^\\/]+)*").replace(/\*/g, "[^\\/]+").replace(/((?!\\))\?/g, "$1.") + "$";
		parsedPattern = "^" + parsedPattern + "$";
		return path.match(new RegExp(parsedPattern, "i")) !== null;
	};
	_c.component("uploadSelect", {
		init: function() {
			var $this;
			$this = this;
			return this.on("change", function() {
				var twin;
				xhrupload($this.element[0].files, $this.options);
				twin = $this.element.clone(true).data("uploadSelect", $this);
				$this.element.replaceWith(twin);
				$this.element = twin;
			});
		}
	});
	_c.component("uploadDrop", {
		defaults: {
			dragoverClass: "dragover"
		},
		init: function() {
			var $this, hasdragCls;
			$this = this;
			hasdragCls = false;
			return this.on("drop", function(e) {
				if(e.dataTransfer && e.dataTransfer.files) {
					e.stopPropagation();
					e.preventDefault();
					$this.element.removeClass($this.options.dragoverClass);
					$this.element.trigger("dropped.clique.upload", [e.dataTransfer.files]);
					return xhrupload(e.dataTransfer.files, $this.options);
				}
			}).on("dragenter", function(e) {
				e.stopPropagation();
				return e.preventDefault();
			}).on("dragover", function(e) {
				e.stopPropagation();
				e.preventDefault();
				if(!hasdragCls) {
					$this.element.addClass($this.options.dragoverClass);
					hasdragCls = true;
				}
			}).on("dragleave", function(e) {
				e.stopPropagation();
				e.preventDefault();
				$this.element.removeClass($this.options.dragoverClass);
				hasdragCls = false;
			});
		}
	});
	_c.support.ajaxupload = function() {
		var supportAjaxUploadProgressEvents, supportFileAPI, supportFormData;
		supportFileAPI = function() {
			var fi;
			fi = document.createElement("INPUT");
			fi.type = "file";
			return "files" in fi;
		};
		supportAjaxUploadProgressEvents = function() {
			var xhr;
			xhr = new XMLHttpRequest();
			return !!(xhr && "upload" in xhr && "onprogress" in xhr.upload);
		};
		supportFormData = function() {
			return !!window.FormData;
		};
		return supportFileAPI() && supportAjaxUploadProgressEvents() && supportFormData();
	}();
	if(_c.support.ajaxupload) {
		_c.$.event.props.push("dataTransfer");
	}
	xhrupload.defaults = {
		action: "",
		single: true,
		method: "POST",
		param: "files[]",
		params: {},
		allow: "*.*",
		type: "text",
		filelimit: false,
		before: function(o) {},
		beforeSend: function(xhr) {},
		beforeAll: function() {},
		loadstart: function() {},
		load: function() {},
		loadend: function() {},
		error: function() {},
		abort: function() {},
		progress: function() {},
		complete: function() {},
		allcomplete: function() {},
		readystatechange: function() {},
		notallowed: function(file, settings) {
			return alert("Only the following file types are allowed : " + settings.allow);
		}
	};
	_c.utils.xhrupload = xhrupload;
	return xhrupload;
});
