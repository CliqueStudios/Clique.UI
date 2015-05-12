
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

	grids = []

	_c.component 'rowMatchHeight',
		defaults :
			target : false
			row : true

		boot : ->
			_c.ready (context)->
				$('[data-row-match]', context).each ->
					grid = $(@)
					unless grid.data('rowMatchHeight')
						obj = _c.rowMatchHeight grid, _c.utils.options(grid.attr('data-row-match'))
						return

		init : ->
			$this = @
			@columns = @element.children()
			@elements = if @options.target then @find @options.target else @columns
			unless @columns.length
				return
			_c.$win.on 'load resize orientationchange', do->
				fn = ->
					$this.match()
				_c.$ ->
					fn()
				_c.utils.debounce fn, 50

			_c.$html.on 'changed.clique.dom', (e)->
				$this.columns = $this.element.children()
				$this.elements = if $this.options.target then $this.find $this.options.target else $this.columns
				$this.match()

			@on 'display.clique.check', (e)=>
				if @element.is(':visible')
					@match()
			grids.push @

		match : ->
			firstvisible = @columns.filter(':visible:first')
			unless firstvisible.length
				return
			stacked = Math.ceil(100 * parseFloat(firstvisible.css('width')) / parseFloat(firstvisible.parent().css('width'))) >= 100
			if stacked
				@revert()
			else
				_c.utils.matchHeights @elements, @options
			@

		revert : ->
			@elements.css 'min-height', ''
			@

	_c.component 'rowMargin',
		defaults :
			cls : 'row-margin'

		boot : ->
			_c.ready (context)->
				$('[data-row-margin]', context).each ->
					grid = $(@)
					unless grid.data('rowMargin')
						obj = _c.rowMargin grid, _c.utils.options(grid.attr('data-row-margin'))
						return

		init : ->
			stackMargin = _c.stackMargin(@element, @options)
			@element.trigger 'init.clique.grid'

	_c.utils.matchHeights = (elements, options)->

		elements = $(elements).css('min-height', '')
		options = _c.$.extend
			row : true
		, options

		matchHeights = (group)->
			if group.length < 2
				return
			max = 0
			group
				.each ->
					max = Math.max max, $(@).outerHeight()
					return
				.each ->
					$(@).css 'min-height', max

		if options.row
			elements.first().width()
			setTimeout ->
				lastoffset = false
				group = []
				elements.each ->
					ele = $(@)
					offset = ele.offset().top
					if offset isnt lastoffset and group.length
						matchHeights $(group)
						group = []
						offset = ele.offset().top
					group.push ele
					lastoffset = offset
					return
				if group.length
					matchHeights $(group)
			, 0
		else
			matchHeights elements
	return
