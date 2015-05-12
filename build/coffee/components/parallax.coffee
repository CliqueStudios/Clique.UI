
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-parallax', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.parallax requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	initBgImageParallax = (obj, prop, opts)->
		img = new Image()
		ratio = null
		element = obj.element.css
			'background-size': 'cover'
			'background-repeat': 'no-repeat'
		url = element.css('background-image').replace(/^url\(/g, '').replace(/\)$/g, '').replace(/("|')/g, '')

		check = ->
			w = element.width()
			h = element.height()
			h += if prop is 'bg' then opts.diff else opts.diff / 100 * h
			if w / ratio < h
				width = Math.ceil(h * ratio)
				height = h
				return
			else
				width = w
				height = Math.ceil(w / ratio)
				obj.element.css 'background-size': width + 'px ' + height + 'px'

		img.onerror = ->
			return

		img.onload = ->
			size =
				w: img.width
				height: img.height
			ratio = img.width / img.height
			_c.$win.on 'load resize orientationchange', _c.utils.debounce ->
				check()
			, 50
			check()

		img.src = url
		true

	calcColor = (start, end, pos)->
		start = parseColor(start)
		end = parseColor(end)
		pos = pos or 0
		calculateColor start, end, pos

	calculateColor = (begin, end, pos)->
		color = 'rgba(' + parseInt(begin[0] + pos * (end[0] - begin[0]), 10) + ',' + parseInt(begin[1] + pos * (end[1] - begin[1]), 10) + ',' + parseInt(begin[2] + pos * (end[2] - begin[2]), 10) + ',' + (if begin and end then parseFloat(begin[3] + pos * (end[3] - begin[3])) else 1)
		color += ')'
		color

	parseColor = (color)->
		match1 = /#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})/.exec(color)
		match2 = /#([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])/.exec(color)
		match3 = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(color)
		match4 = /rgba\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9\.]*)\s*\)/.exec(color)
		if match1
			quadruplet = [ parseInt(match1[1], 16), parseInt(match1[2], 16), parseInt(match1[3], 16), 1 ]
		else if match2
			quadruplet = [ parseInt(match2[1], 16) * 17, parseInt(match2[2], 16) * 17, parseInt(match2[3], 16) * 17, 1 ]
		else if match3
			quadruplet = [ parseInt(match3[1]), parseInt(match3[2]), parseInt(match3[3]), 1 ]
		else if match4
			quadruplet = [ parseInt(match4[1], 10), parseInt(match4[2], 10), parseInt(match4[3], 10), parseFloat(match4[4]) ]
		else
			quadruplet = colors[color] or [ 255, 255, 255, 0 ]
		quadruplet

	parallaxes = []
	supports3d = false
	scrolltop = 0
	wh = window.innerHeight

	checkParallaxes = ->
		scrolltop = _c.$win.scrollTop()
		_c.support.requestAnimationFrame.apply window, [ ->
			i = 0
			while i < parallaxes.length
				parallaxes[i].process()
				i++
			]

	_c.component 'parallax',

		defaults:
			velocity : 0.5
			target : false
			viewport : false

		boot : ->
			supports3d = do ->
				el = document.createElement('div')
				transforms =
					'WebkitTransform' : '-webkit-transform'
					'MSTransform' : '-ms-transform'
					'MozTransform' : '-moz-transform'
					'Transform' : 'transform'
				document.body.insertBefore el, null
				for t of transforms
					if el.style[t] isnt undefined
						el.style[t] = 'translate3d(1px,1px,1px)'
						has3d = window.getComputedStyle(el).getPropertyValue(transforms[t])
				document.body.removeChild el
				typeof has3d isnt 'undefined' and has3d.length > 0 and has3d isnt 'none'

			_c.$doc.on 'scrolling.clique.dom', checkParallaxes

			_c.$win.on 'load resize orientationchange', _c.utils.debounce (->
				wh = window.innerHeight
				checkParallaxes()
				return
			), 50

			_c.ready (context)->
				_c.$('[data-parallax]', context).each ->
					ele = _c.$(@)
					if ! ele.data('clique.data.parallax')
						obj = _c.parallax ele, _c.utils.options(ele.attr('data-parallax'))
						return

		init : ->
			@base = if @options.target then _c.$(@options.target) else @element
			@props = {}
			@velocity = @options.velocity or 1
			reserved = [ 'target', 'velocity', 'viewport', 'plugins' ]
			Object.keys(@options).forEach (prop)=>
				if reserved.indexOf(prop) isnt -1
					return
				startend = String(@options[prop]).split(',')
				if prop.match(/color/i)
					start = if startend[1] then startend[0] else @_getStartValue(prop)
					end = if startend[1] then startend[1] else startend[0]
					if ! start
						start = 'rgba(255, 255, 255, 0)'
						return
				else
					start = parseFloat(if startend[1] then startend[0] else @_getStartValue(prop))
					end = parseFloat(if startend[1] then startend[1] else startend[0])
					diff = if start < end then end - start else start - end
					dir = if start < end then 1 else -1
				@props[prop] =
					start : start
					end : end
					dir : dir
					diff : diff
				return
			parallaxes.push this

		process : ->
			percent = @percentageInViewport()
			if @options.viewport isnt false
				percent = if @options.viewport is 0 then 1 else percent / @options.viewport
			@update percent

		percentageInViewport : ->
			top = @base.offset().top
			height = @base.outerHeight()
			if top > scrolltop + wh
				percent = 0
			else if top + height < scrolltop
				percent = 1
			else
				if top + height < wh
					percent = (if scrolltop < wh then scrolltop else scrolltop - wh) / (top + height)
				else
					distance = scrolltop + wh - top
					percentage = Math.round(distance / ((wh + height) / 100))
					percent = percentage / 100
			percent

		update : (percent)->
			css = 'transform': ''
			compercent = percent * (1 - (@velocity - @velocity * percent))
			# opts = undefined
			# val = undefined
			if compercent < 0
				compercent = 0
			if compercent > 1
				compercent = 1
			if @_percent isnt undefined and @_percent is compercent
				return
			Object.keys(@props).forEach (prop)=>
				opts = @props[prop]
				if percent is 0
					val = opts.start
				else if percent is 1
					val = opts.end
				else if opts.diff isnt undefined
					val = opts.start + opts.diff * compercent * opts.dir
				if (prop is 'bg' or prop is 'bgp') and !@_bgcover
					@_bgcover = initBgImageParallax(this, prop, opts)
				switch prop
					when 'x'
						css.transform += if supports3d then ' translate3d(' + val + 'px, 0, 0)' else ' translateX(' + val + 'px)'
						break
					when 'xp'
						css.transform += if supports3d then ' translate3d(' + val + '%, 0, 0)' else ' translateX(' + val + '%)'
						break
					when 'y'
						css.transform += if supports3d then ' translate3d(0, ' + val + 'px, 0)' else ' translateY(' + val + 'px)'
						break
					when 'yp'
						css.transform += if supports3d then ' translate3d(0, ' + val + '%, 0)' else ' translateY(' + val + '%)'
						break
					when 'rotate'
						css.transform += ' rotate(' + val + 'deg)'
						break
					when 'scale'
						css.transform += ' scale(' + val + ')'
						break
					when 'bg'
						css['background-position'] = '50% ' + val + 'px'
						break
					when 'bgp'
						css['background-position'] = '50% ' + val + '%'
						break
					when 'color', 'background-color', 'border-color'
						css[prop] = calcColor(opts.start, opts.end, compercent)
						break
					else
						css[prop] = val
						break
			@element.css css
			@_percent = compercent
			return

		_getStartValue: (prop)->
			value = 0
			switch prop
				when 'scale'
					value = 1
				else
					value = @element.css(prop)
			value or 0

	colors =
		black : [ 0, 0, 0, 1 ]
		blue : [ 0, 0, 255, 1 ]
		brown : [ 165, 42, 42, 1 ]
		cyan : [ 0, 255, 255, 1 ]
		fuchsia : [ 255, 0, 255, 1 ]
		gold : [ 255, 215, 0, 1 ]
		green : [ 0, 128, 0, 1 ]
		indigo : [ 75, 0, 130, 1 ]
		khaki : [ 240, 230, 140, 1 ]
		lime : [ 0, 255, 0, 1 ]
		magenta : [ 255, 0, 255, 1 ]
		maroon : [ 128, 0, 0, 1 ]
		navy : [ 0, 0, 128, 1 ]
		olive : [ 128, 128, 0, 1 ]
		orange : [ 255, 165, 0, 1 ]
		pink : [ 255, 192, 203, 1 ]
		purple : [ 128, 0, 128, 1 ]
		violet : [ 128, 0, 128, 1 ]
		red : [ 255, 0, 0, 1 ]
		silver : [ 192, 192, 192, 1 ]
		white : [ 255, 255, 255, 1 ]
		yellow : [ 255, 255, 0, 1 ]
		transparent : [ 255, 255, 255, 0 ]

	_c.parallax
