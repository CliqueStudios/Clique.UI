
((core)->
	if typeof define is 'function' and define.amd
		define 'clique', ->
			clique = window.Clique or core(window, window.jQuery, window.document)
			clique.load = (res, req, onload, config)->
				resources = res.split(',')
				load = []
				base = (if config.config and config.config.clique and config.config.clique.base then config.config.clique.base else '').replace(/\/+$/g, '')
				unless base
					throw new Error('Please define base path to Clique in the requirejs config.')
				i = 0
				while i < resources.length
					resource = resources[i].replace(/\./g, '/')
					load.push base + '/components/' + resource
					i += 1
				req load, ->
					onload clique
					return
				return

			clique
	unless window.jQuery
		throw new Error('Clique requires jQuery')
	if window and window.jQuery
		core window, window.jQuery, window.document
	return
) (global, $, doc)->

	_c = {}
	_cTEMP = window.Clique
	_c.version = '1.0.0'

	_c.noConflict = ->
		if _cTEMP
			window.Clique = _cTEMP
			$.Clique = _cTEMP
			$.fn.clique = _cTEMP.fn
		_c

	_c.prefix = (str)->
		str

	_c.$ = $
	_c.$doc = $(document)
	_c.$win = $(window)
	_c.$html = $('html')

	_c.fn = (command, options)->
		args = arguments
		cmd = command.match(/^([a-z\-]+)(?:\.([a-z]+))?/i)
		component = cmd[1]
		method = cmd[2]
		if ! method and typeof options is 'string'
			method = options
		unless _c[component]
			$.error 'Clique component [' + component + '] does not exist.'
			return @
		@each ->
			$this = $(@)
			data = $this.data component
			if ! data
				$this.data(component, data = _c[component](this, (if method then undefined else options)))
			if method
				data[method].apply data, Array.prototype.slice.call(args, 1)
				return

	_c.support =
		requestAnimationFrame : window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.msRequestAnimationFrame or window.oRequestAnimationFrame or (callback)->
			setTimeout callback, 1e3 / 60
			return

		touch : 'ontouchstart' of window and navigator.userAgent.toLowerCase().match(/mobile|tablet/) or global.DocumentTouch and document instanceof global.DocumentTouch or global.navigator.msPointerEnabled and global.navigator.msMaxTouchPoints > 0 or global.navigator.pointerEnabled and global.navigator.maxTouchPoints > 0 or false

		mutationobserver : global.MutationObserver or global.WebKitMutationObserver or null

	_c.support.transition = do->
		transitionEnd = do->
			element = doc.body or doc.documentElement
			transEndEventNames =
				WebkitTransition : 'webkitTransitionEnd'
				MozTransition : 'transitionend'
				OTransition : 'oTransitionEnd otransitionend'
				transition : 'transitionend'

			for name of transEndEventNames
				if element.style[name] isnt `undefined`
					return transEndEventNames[name]
			return
		transitionEnd and end : transitionEnd

	_c.support.animation = do->
		animationEnd = do->
			element = doc.body or doc.documentElement
			animEndEventNames =
				WebkitAnimation : 'webkitAnimationEnd'
				MozAnimation : 'animationend'
				OAnimation : 'oAnimationEnd oanimationend'
				animation : 'animationend'

			for name of animEndEventNames
				if element.style[name] isnt `undefined`
					return animEndEventNames[name]
			return
		animationEnd and end : animationEnd

	_c.utils =

		now : Date.now or ->
			new Date().getTime()

		isString : (obj)->
				Object.prototype.toString.call(obj) is '[object String]'

		isNumber : (obj)->
			! isNaN(parseFloat(obj)) and isFinite obj

		isDate : (obj)->
			d = new Date obj
			(d isnt "Invalid Date" and d.toString() isnt "Invalid Date" and ! isNaN(d))

		str2json : (str, notevil)->
			try
				if notevil
					return JSON.parse(str.replace(/([\$\w]+)\s* :/g, (_, $1)->
						'"' + $1 + '" :'
					).replace(/'([^']+)'/g, (_, $1)->
						'"' + $1 + '"'
					))
				else
					newFN = Function
					return new newFN('', 'var json = ' + str + '; return JSON.parse(JSON.stringify(json));')()
			catch e
				return false
			return

		debounce : (func, wait, immediate)->
			->
				context = this
				args = arguments
				later = ->
					timeout = null
					unless immediate
						func.apply context, args
					return

				callNow = immediate and not timeout
				clearTimeout timeout
				timeout = setTimeout(later, wait)
				if callNow
					func.apply context, args
				return

		removeCssRules : (selectorRegEx)->
			unless selectorRegEx
				return
			setTimeout ->
				try
					_ref = document.styleSheets
					_i = 0
					_len = _ref.length

					while _i < _len
						stylesheet = _ref[_i]
						idxs = []
						stylesheet.cssRules = stylesheet.cssRules
						idx = _j = 0
						_len1 = stylesheet.cssRules.length

						while _j < _len1
							if stylesheet.cssRules[idx].type is CSSRule.STYLE_RULE and selectorRegEx.test(stylesheet.cssRules[idx].selectorText)
								idxs.unshift idx
							idx = ++_j
						_k = 0
						_len2 = idxs.length

						while _k < _len2
							stylesheet.deleteRule idxs[_k]
							_k++
						_i++
				return
			, 0
			return

		isInView : (element, options)->
			$element = $(element)
			unless $element.is(':visible')
				return false
			window_left = _c.$win.scrollLeft()
			window_top = _c.$win.scrollTop()
			offset = $element.offset()
			left = offset.left
			top = offset.top
			options = $.extend(
				topoffset : 0
				leftoffset : 0
			, options)
			if top + $element.height() >= window_top and top - options.topoffset <= window_top + _c.$win.height() and left + $element.width() >= window_left and left - options.leftoffset <= window_left + _c.$win.width()
				true
			else
				false

		checkDisplay : (context, initanimation)->
			elements = $('[data-margin], [data-row-match], [data-row-margin], [data-check-display]', context or document)
			if context and not elements.length
				elements = $(context)
			elements.trigger 'display.clique.check'
			if initanimation
				unless typeof initanimation is 'string'
					initanimation = '[class*="animation-"]'
				elements.find(initanimation).each ->
					ele = $(@)
					cls = ele.attr('class')
					anim = cls.match(/animation\-(.+)/)
					ele.removeClass(anim[0]).width()
					ele.addClass anim[0]
					return
			elements

		options : (string)->
			if $.isPlainObject(string)
				return string
			start = if string then string.indexOf('{') else -1
			options = {}
			unless start is -1
				try
					options = _c.utils.str2json string.substr(start)
			options

		animate : (element, cls)->
			d = $.Deferred()
			element = $(element)
			cls = cls
			element
				.css('display', 'none')
				.addClass(cls)
				.one _c.support.animation.end, ->
					element.removeClass cls
					d.resolve()
					return
				.width()
			element.css {
				display : ''
			}
			d.promise()

		uid : (prefix)->
			(prefix or 'id') + _c.utils.now() + 'RAND' + Math.ceil(Math.random() * 1e5)

		template : (str, data)->
			tokens = str.replace(/\n/g, "\\n").replace(/\{\{\{\s*(.+?)\s*\}\}\}/g, "{{!$1}}").split(/(\{\{\s*(.+?)\s*\}\})/g)
			i = 0
			output = []
			openblocks = 0
			while i < tokens.length
				toc = tokens[i]
				if toc.match(/\{\{\s*(.+?)\s*\}\}/)
					i = i + 1
					toc = tokens[i]
					cmd = toc[0]
					prop = toc.substring((if toc.match(/^(\^|\#|\!|\~|\:)/) then 1 else 0))
					switch cmd
						when '~'
							output.push 'for(var $i=0;$i<' + prop + '.length;$i++) { var $item = ' + prop + '[$i];'
							openblocks++
						when ' :'
							output.push 'for(var $key in ' + prop + ') { var $val = ' + prop + '[$key];'
							openblocks++
						when '#'
							output.push 'if(' + prop + ') {'
							openblocks++
						when '^'
							output.push 'if(!' + prop + ') {'
							openblocks++
						when '/'
							output.push '}'
							openblocks--
						when '!'
							output.push '__ret.push(' + prop + ');'
						else
							output.push '__ret.push(escape(' + prop + '));'
				else
					output.push '__ret.push(\'' + toc.replace(/\'/g, '\\\'') + '\');'
				i = i + 1

			# fn = ($data)->
			# 	'use strict'
			# 	__ret = []
			# 	try
			# 		with($data)
			# 			__ret = ["Not all blocks are closed correctly."]
			# 	catch e
			# 		# ...

			newFN = Function
			fn = new newFN "$data", [
				"var __ret = [];",
				"try {",
				"with($data){",
				if ! openblocks then output.join("") else '__ret = ["Not all blocks are closed correctly."]',
				"};",
				"}catch(e){__ret = [e.message];}",
				'return __ret.join("").replace(/\\n\\n/g, "\\n");',
				"function escape(html) { return String(html).replace(/&/g, '&amp;').replace(/\"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');}"
			].join("\n")
			return if data then fn(data) else fn

		events :
			click : if _c.support.touch then 'tap' else 'click'

	window.Clique = _c
	$.Clique = _c
	$.fn.clique = _c.fn
	_c.langdirection = if _c.$html.attr('dir') is 'rtl' then 'right' else 'left'
	_c.components = {}

	_c.component = (name, def)->
		fn = (element, options)->
			$this = @
			@Clique = _c
			@element = if element then $(element) else null
			@options = $.extend(true, {}, @defaults, options)
			@plugins = {}
			if @element
				@element.data 'clique.data.' + name, this
			@init()
			(if @options.plugins.length then @options.plugins else Object.keys(fn.plugins)).forEach (plugin)->
				if fn.plugins[plugin].init
					fn.plugins[plugin].init $this
					$this.plugins[plugin] = true
				return

			@trigger 'init.clique.component', [ name, this ]
			this

		fn.plugins = {}
		$.extend true, fn::,
			defaults :
				plugins : []

			boot : ->

			init : ->

			on : (a1, a2, a3)->
				$(@element or this).on a1, a2, a3

			one : (a1, a2, a3)->
				$(@element or this).one a1, a2, a3

			off : (evt)->
				$(@element or this).off evt

			trigger : (evt, params)->
				$(@element or this).trigger evt, params

			find : (selector)->
				$((if @element then @element else [])).find selector

			proxy : (obj, methods)->
				$this = @
				methods.split(' ').forEach (method)->
					unless $this[method]
						$this[method] = ->
							obj[method].apply obj, arguments
					return

				return

			mixin : (obj, methods)->
				$this = @
				methods.split(' ').forEach (method)->
					unless $this[method]
						$this[method] = obj[method].bind($this)
					return

				return

			option : ->
				if arguments.length is 1
					return @options[arguments[0]] or `undefined`
				else
					if arguments.length is 2
						@options[arguments[0]] = arguments[1]
				return
		, def
		@components[name] = fn
		this[name] = ->
			if arguments.length
				switch arguments.length
					when 1
						if typeof arguments[0] is 'string' or arguments[0].nodeType or arguments[0] instanceof jQuery
							element = $(arguments[0])
						else
							options = arguments[0]
					when 2
						element = $(arguments[0])
						options = arguments[1]
			if element and element.data('clique.data.' + name)
				return element.data('clique.data.' + name)
			new _c.components[name](element, options)

		if _c.domready
			_c.component.boot name
		fn

	_c.plugin = (component, name, def)->
		@components[component].plugins[name] = def
		return

	_c.component.boot = (name)->
		if _c.components[name].prototype and _c.components[name].prototype.boot and ! _c.components[name].booted
			_c.components[name].prototype.boot.apply _c, []
			_c.components[name].booted = true
		return

	_c.component.bootComponents = ->
		for component of _c.components
			_c.component.boot component
		return

	_c.domObservers = []
	_c.domready = false

	_c.ready = (fn)->
		_c.domObservers.push fn
		if _c.domready
			fn document
		return

	_c.on = (a1, a2, a3)->
		if a1 and a1.indexOf('ready.clique.dom') > -1 and _c.domready
			a2.apply _c.$doc
		_c.$doc.on a1, a2, a3

	_c.one = (a1, a2, a3)->
		if a1 and a1.indexOf('ready.clique.dom') > -1 and _c.domready
			a2.apply _c.$doc
			return _c.$doc
		_c.$doc.one a1, a2, a3

	_c.trigger = (evt, params)->
		_c.$doc.trigger evt, params

	_c.domObserve = (selector, fn)->
		unless _c.support.mutationobserver
			return
		fn = fn or ->

		$(selector).each ->
			element = this
			$element = $(element)
			if $element.data('observer')
				return
			try
				observer = new _c.support.mutationobserver(_c.utils.debounce((mutations)->
					fn.apply element, []
					$element.trigger 'changed.clique.dom'
					return
				, 50))
				observer.observe element,
					childList : true
					subtree : true

				$element.data 'observer', observer
			return
		return

	_c.delay = (fn, timeout = 0, args)->
		fn = fn or ->
		setTimeout ->
			fn.apply null, args
		, timeout

	_c.on 'domready.clique.dom', ->
		_c.domObservers.forEach (fn)->
			fn document
			return

		if _c.domready
			_c.utils.checkDisplay document
		return

	$ ->
		_c.$body = $('body')
		_c.ready (context)->
			_c.domObserve '[data-observe]'
			return

		_c.on 'changed.clique.dom', (e)->
			ele = e.target
			_c.domObservers.forEach (fn)->
				fn ele
				return

			_c.utils.checkDisplay ele
			return

		_c.trigger 'beforeready.clique.dom'
		_c.component.bootComponents()
		setInterval do->
			memory =
				x : window.pageXOffset
				y : window.pageYOffset

			fn = ->
				if memory.x isnt window.pageXOffset or memory.y isnt window.pageYOffset
					dir =
						x : 0
						y : 0

					unless window.pageXOffset is memory.x
						dir.x = (if window.pageXOffset > memory.x then 1 else -1)
					unless window.pageYOffset is memory.y
						dir.y = (if window.pageYOffset > memory.y then 1 else -1)
					memory =
						dir : dir
						x : window.pageXOffset
						y : window.pageYOffset

					_c.$doc.trigger 'scrolling.clique.dom', [memory]
				return

			if _c.support.touch
				_c.$html.on 'touchmove touchend MSPointerMove MSPointerUp pointermove pointerup', fn
			if memory.x or memory.y
				fn()
			fn
		, 15
		_c.trigger 'domready.clique.dom'
		if _c.support.touch
			if navigator.userAgent.match(/(iPad|iPhone|iPod)/g)
				_c.$win.on 'load orientationchange resize', _c.utils.debounce do->
					fn = ->
						$('.height-viewport').css 'height', window.innerHeight
						fn
					fn()
				, 100
		_c.trigger 'afterready.clique.dom'
		_c.domready = true
		return

	if _c.support.touch
		hoverset = false
		hovercls = 'hover'
		selector = '.overlay, .overlay-hover, .overlay-toggle, .animation-hover, .has-hover'
		_c.$html.on('touchstart MSPointerDown pointerdown', selector, ->
			if hoverset
				$('.' + hovercls).removeClass hovercls
			hoverset = $(@).addClass(hovercls)
			return
		).on 'touchend MSPointerUp pointerup', (e)->
			exclude = $(e.target).parents(selector)
			if hoverset
				hoverset.not(exclude).removeClass hovercls
			return

	# Set custom jQuery properties
	$.expr[':'].on = (obj)->
		return $(obj).prop 'on'

	_c
