
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-utility', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.utility requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	stacks = []

	_c.component 'stackMargin',

		defaults :
			cls : 'margin-small-top'

		boot : ->
			_c.ready (context)->
				$('[data-margin]', context).each ->
					ele = $(@)
					unless ele.data('clique.data.stackMargin')
						obj = _c.stackMargin ele, _c.utils.options(ele.attr('data-margin'))
						return

		init : ->
			$this = @
			@columns = @element.children()
			unless @columns.length
				return
			_c.$win.on 'resize orientationchange', do->
				fn = ->
					$this.process()
				_c.$ ->
					fn()
					_c.$win.on 'load', fn
				_c.utils.debounce fn, 20
			_c.$html.on 'changed.clique.dom', (e)->
				$this.columns = $this.element.children()
				$this.process()

			@on 'display.clique.check', (e)=>
				$this.columns = $this.element.children()
				if @element.is(':visible')
					@process()
			stacks.push @

		process : ->
			_c.utils.stackMargin @columns, @options
			@

		revert : ->
			@columns.removeClass @options.cls
			@

	_c.ready do->

		iframes = []

		check = ->
			iframes.forEach (iframe)->
				unless iframe.is(':visible')
					return
				width = iframe.parent().width()
				iwidth = iframe.data('width')
				ratio = width / iwidth
				height = Math.floor ratio * iframe.data('height')
				iframe.css
					height : if width < iwidth then height else iframe.data('height')

		_c.$win.on 'resize', _c.utils.debounce(check, 15)

		(context)->
			$('iframe.responsive-width', context).each ->
				iframe = $(@)
				if not iframe.data('responsive') and iframe.attr('width') and iframe.attr('height')
					iframe.data 'width', iframe.attr('width')
					iframe.data 'height', iframe.attr('height')
					iframe.data 'responsive', true
					iframes.push iframe
			check()

	_c.utils.stackMargin = (elements, options)->
		options = _c.$.extend
			cls : 'margin-small-top'
		, options
		options.cls = options.cls
		elements = $(elements).removeClass options.cls
		skip = false
		firstvisible = elements.filter ':visible:first'
		offset = if firstvisible.length then firstvisible.position().top + firstvisible.outerHeight() - 1 else false
		if offset is false
			return
		elements.each ->
			column = $(@)
			if column.is(':visible')
				if skip
					column.addClass options.cls
				else
					if column.position().top >= offset
						skip = column.addClass options.cls
						return
	return
