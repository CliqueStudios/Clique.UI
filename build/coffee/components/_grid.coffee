
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-grid', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.grid requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	getElementSize = (ele)->
		_getSize ele

	_c.component 'grid',
		defaults:
			colwidth: 'auto'
			animation: true
			duration: 300
			gutter: 0
			controls: false

		boot : ->
			_c.ready (context)->
				_c.$('[data-grid]', context).each ->
					ele = _c.$(@)
					unless ele.data('clique.data.grid')
						obj = _c.grid ele, _c.utils.options(ele.attr('data-grid'))
						return

		init : ->
			$this = @
			@element.css position: 'relative'
			if @options.controls
				controls = _c.$(@options.controls)
				activeCls = 'active'
				controls.on 'click', '[data-filter]', (e)->
					e.preventDefault()
					$this.filter _c.$(@).data('filter')
					controls.find('[data-filter]').removeClass(activeCls).filter(@).addClass activeCls

				controls.on 'click', '[data-sort]', (e)->
					e.preventDefault()
					cmd = _c.$(@).attr('data-sort').split(':')
					$this.sort cmd[0], cmd[1]
					controls.find('[data-sort]').removeClass(activeCls).filter(@).addClass activeCls
			_c.$win.on 'load resize orientationchange', _c.utils.debounce =>
				@updateLayout()
			, 100
			@updateLayout()
			@on 'display.clique.check', ->
				if $this.element.is(':visible')
					$this.updateLayout()

			_c.$html.on 'changed.clique.dom', (e)->
				$this.updateLayout()

		_prepareElements : ->
			children = @element.children(':not([data-grid-prepared])')
			css = null
			unless children.length
				return
			css =
				position: 'absolute'
				'box-sizing': 'border-box'
				width: if @options.colwidth is 'auto' then '' else @options.colwidth

			if @options.gutter
				css['padding-left'] = @options.gutter
				css['padding-bottom'] = @options.gutter
				@element.css 'margin-left', @options.gutter * -1
			children.attr('data-grid-prepared', 'true').css css

		updateLayout : (elements)->
			@_prepareElements()
			elements = elements or @element.children(':visible')
			$this = @
			gutter = @options.gutter
			children = elements
			maxwidth = @element.width() + 2 * gutter + 2
			left = 0
			top = 0
			positions = []
			item = null
			width = null
			height = null
			pos = null
			aX = null
			aY = null
			i = null
			z = null
			max = null
			size = null
			@trigger 'beforeupdate.clique.grid', [children]
			children.each (index)->
				size = getElementSize(@)
				item = _c.$(@)
				width = size.outerWidth
				height = size.outerHeight
				left = 0
				top = 0
				i = 0
				max = positions.length

				while i < max
					pos = positions[i]
					if left <= pos.aX
						left = pos.aX
					if maxwidth < left + width
						left = 0
					if top <= pos.aY
						top = pos.aY
					i++
				positions.push
					ele: item
					top: top
					left: left
					width: width
					height: height
					aY: top + height
					aX: left + width

			posPrev = null
			maxHeight = 0
			i = 0
			max = positions.length

			while i < max
				pos = positions[i]
				top = 0
				z = 0
				while z < i
					posPrev = positions[z]
					if pos.left < posPrev.aX and posPrev.left + 1 < pos.aX
						top = posPrev.aY
					z++
				pos.top = top
				pos.aY = top + pos.height
				maxHeight = Math.max(maxHeight, pos.aY)
				i++
			maxHeight = maxHeight - gutter
			if @options.animation
				@element.stop().animate
					height: maxHeight
				, 100
				positions.forEach (pos)=>
					pos.ele.stop().animate
						top: pos.top
						left: pos.left
						opacity: 1
					, @options.duration
			else
				@element.css 'height', maxHeight
				positions.forEach (pos)=>
					pos.ele.css
						top: pos.top
						left: pos.left
						opacity: 1
			setTimeout ->
				_c.$doc.trigger 'scrolling.clique.dom'
			, 2 * @options.duration * (if @options.animation then 1 else 0)
			@trigger 'afterupdate.clique.grid', [children]

		filter: (filter)->
			filter = filter or []
			if typeof filter is 'string'
				filter = filter.split(/,/).map((item)->
					item.trim()
				)
			$this = @
			children = @element.children()
			elements =
				visible: []
				hidden: []

			visible = null
			hidden = null
			children.each (index)->
				ele = _c.$(@)
				f = ele.attr('data-filter')
				infilter = if filter.length then false else true
				if f
					f = f.split(/,/).map((item)->
						item.trim()
					)
					filter.forEach (item)->
						if f.indexOf(item) > -1
							infilter = true
						return
				elements[(if infilter then 'visible' else 'hidden')].push ele

			elements.hidden = _c.$(elements.hidden).map ->
				this[0]
			elements.visible = _c.$(elements.visible).map ->
				this[0]
			elements.hidden.attr('aria-hidden', 'true').filter(':visible').fadeOut @options.duration
			elements.visible.attr('aria-hidden', 'false').filter(':hidden').css('opacity', 0).show()
			$this.updateLayout elements.visible

		sort: (by_, order)->
			order = order or 1
			if typeof order is 'string'
				order = if order.toLowerCase() is 'desc' then -1 else 1
			elements = @element.children()
			elements.sort((a, b)->
				a = _c.$(a)
				b = _c.$(b)
				(if (b.data(by_) or '') < (a.data(by_) or '') then order else order * -1)
			).appendTo @element
			@updateLayout elements.filter(':visible')

	_getSize = do->

		getStyleProperty = (propName)->
			unless propName
				return
			if typeof docElemStyle[propName] is 'string'
				return propName
			propName = propName.charAt(0).toUpperCase() + propName.slice(1)
			prefixed = null
			i = 0
			len = prefixes.length

			while i < len
				prefixed = prefixes[i] + propName
				if typeof docElemStyle[prefixed] is 'string'
					return prefixed
				i++
			return

		getStyleSize = (value)->
			num = parseFloat(value)
			isValid = value.indexOf('%') is -1 and not isNaN(num)
			isValid and num

		noop = ->

		getZeroSize = ->
			size =
				width: 0
				height: 0
				innerWidth: 0
				innerHeight: 0
				outerWidth: 0
				outerHeight: 0

			i = 0
			len = measurements.length

			while i < len
				measurement = measurements[i]
				size[measurement] = 0
				i++
			size

		isSetup = false
		getStyle = null
		boxSizingProp = null
		isBoxSizeOuter = null

		setup = ->
			if isSetup
				return
			isSetup = true
			getComputedStyle = window.getComputedStyle
			getStyle = do->
				getStyleFn = if getComputedStyle then (elem)-> getComputedStyle(elem, null) else (elem)-> elem.currentStyle
				getStyle = (elem)->
					style = getStyleFn(elem)
					unless style
						logError 'Style returned ' + style + '. Are you running this code in a hidden iframe on Firefox? ' + 'See http://bit.ly/getsizebug1'
					style
				return

			boxSizingProp = getStyleProperty('boxSizing')
			if boxSizingProp
				div = document.createElement('div')
				div.style.width = '200px'
				div.style.padding = '1px 2px 3px 4px'
				div.style.borderStyle = 'solid'
				div.style.borderWidth = '1px 2px 3px 4px'
				div.style[boxSizingProp] = 'border-box'
				body = document.body or document.documentElement
				body.appendChild div
				style = getStyle(div)
				isBoxSizeOuter = getStyleSize(style.width) is 200
				body.removeChild div

		getSize = (elem)->
			setup()
			if typeof elem is 'string'
				elem = document.querySelector(elem)
			if not elem or typeof elem isnt 'object' or not elem.nodeType
				return
			style = getStyle(elem)
			if style.display is 'none'
				return getZeroSize()
			size = {}
			size.width = elem.offsetWidth
			size.height = elem.offsetHeight
			isBorderBox = size.isBorderBox = !!(boxSizingProp and style[boxSizingProp] and style[boxSizingProp] is 'border-box')
			i = 0
			len = measurements.length

			while i < len
				measurement = measurements[i]
				value = style[measurement]
				num = parseFloat(value)
				size[measurement] = if not isNaN(num) then num else 0
				i++
			paddingWidth = size.paddingLeft + size.paddingRight
			paddingHeight = size.paddingTop + size.paddingBottom
			marginWidth = size.marginLeft + size.marginRight
			marginHeight = size.marginTop + size.marginBottom
			borderWidth = size.borderLeftWidth + size.borderRightWidth
			borderHeight = size.borderTopWidth + size.borderBottomWidth
			isBorderBoxSizeOuter = isBorderBox and isBoxSizeOuter
			styleWidth = getStyleSize(style.width)
			if styleWidth isnt false
				size.width = styleWidth + (if isBorderBoxSizeOuter then 0 else paddingWidth + borderWidth)
			styleHeight = getStyleSize(style.height)
			if styleHeight isnt false
				size.height = styleHeight + (if isBorderBoxSizeOuter then 0 else paddingHeight + borderHeight)
			size.innerWidth = size.width - (paddingWidth + borderWidth)
			size.innerHeight = size.height - (paddingHeight + borderHeight)
			size.outerWidth = size.width + marginWidth
			size.outerHeight = size.height + marginHeight
			size

		prefixes = 'Webkit Moz ms Ms O'.split(' ')
		docElemStyle = document.documentElement.style
		logError = (if typeof console is 'undefined' then noop else (message)->
			console.error message
		)
		measurements = [
			'paddingLeft'
			'paddingRight'
			'paddingTop'
			'paddingBottom'
			'marginLeft'
			'marginRight'
			'marginTop'
			'marginBottom'
			'borderLeftWidth'
			'borderRightWidth'
			'borderTopWidth'
			'borderBottomWidth'
		]
		isSetup = false
		getStyle = null
		boxSizingProp = null
		isBoxSizeOuter = null
		getSize

	return
