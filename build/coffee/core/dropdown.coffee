
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-dropdown', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.dropdown requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	active = false
	hoverIdle = null
	_c.component 'dropdown',
		defaults :
			mode : 'hover'
			remaintime : 800
			justify : false
			boundary : _c.$win
			delay : 0

		remainIdle : false

		boot : ->
			triggerevent = if _c.support.touch then 'click' else 'mouseenter'
			_c.$html.on triggerevent + '.dropdown.clique', '[data-dropdown]', (e)->
				ele = $(@)
				unless ele.data('clique.data.dropdown')
					obj = _c.dropdown ele, _c.utils.options(ele.data('dropdown'))
					if triggerevent is 'click' or triggerevent is 'mouseenter' and obj.options.mode is 'hover'
						obj.element.trigger triggerevent
					if obj.element.find('.dropdown').length
						e.preventDefault()

		init : ->
			$this = @
			@dropdown = @find('.dropdown')
			@centered = @dropdown.hasClass('dropdown-center')
			@justified = if @options.justify then $(@options.justify) else false
			@boundary = $(@options.boundary)
			@flipped = @dropdown.hasClass('dropdown-flip')
			unless @boundary.length
				@boundary = _c.$win
			@element.attr 'aria-haspopup', 'true'
			@element.attr 'aria-expanded', @element.hasClass('open')
			if @options.mode is 'click' or _c.support.touch
				@on 'click.clique.dropdown', (e)->
					$target = $(e.target)
					unless $target.parents('.dropdown').length
						if $target.is('a[href=\'#\']') or $target.parent().is('a[href=\'#\']') or $this.dropdown.length and not $this.dropdown.is(':visible')
							e.preventDefault()
						$target.blur()
					unless $this.element.hasClass('open')
						$this.show()
					else
						if $target.is('a:not(.js-prevent)') or $target.is('.dropdown-close') or not $this.dropdown.find(e.target).length
							$this.hide()
			else
				@on('mouseenter', (e)->
					if $this.remainIdle
						clearTimeout $this.remainIdle
					if hoverIdle
						clearTimeout hoverIdle
					hoverIdle = setTimeout($this.show.bind($this), $this.options.delay)
					return
				).on('mouseleave', ->
					if hoverIdle
						clearTimeout hoverIdle
					$this.remainIdle = setTimeout ->
						$this.hide()
					, $this.options.remaintime
					return
				).on 'click', (e)->
					$target = $(e.target)
					if $this.remainIdle
						clearTimeout $this.remainIdle
					if $target.is('a[href=\'#\']') or $target.parent().is('a[href=\'#\']')
						e.preventDefault()
					$this.show()
			return

		show : ->
			_c.$html.off 'click.outer.dropdown'
			if active and active[0] isnt @element[0]
				active.removeClass 'open'
				active.attr 'aria-expanded', 'false'
			if hoverIdle
				clearTimeout hoverIdle
			@checkDimensions()
			@element.addClass 'open'
			@element.attr 'aria-expanded', 'true'
			@trigger 'show.clique.dropdown', [this]
			_c.utils.checkDisplay @dropdown, true
			active = @element
			@registerOuterClick()

		hide : ->
			@element.removeClass 'open'
			@remainIdle = false
			@element.attr 'aria-expanded', 'false'
			@trigger 'hide.clique.dropdown', [this]
			if active and active[0] is @element[0]
				active = false
				return

		registerOuterClick : ->
			$this = @
			_c.$html.off 'click.outer.dropdown'
			setTimeout (->
				_c.$html.on 'click.outer.dropdown', (e)->
					if hoverIdle
						clearTimeout hoverIdle
					$target = $(e.target)
					if active and active[0] is $this.element[0] and ($target.is('a:not(.js-prevent)') or $target.is('.dropdown-close') or not $this.dropdown.find(e.target).length)
						$this.hide()
						_c.$html.off 'click.outer.dropdown'
			), 10

		checkDimensions : ->
			unless @dropdown.length
				return
			if @justified and @justified.length
				@dropdown.css 'min-width', ''
			$this = @
			dropdown = @dropdown.css('margin-' + _c.langdirection, '')
			offset = dropdown.show().offset()
			width = dropdown.outerWidth()
			boundarywidth = @boundary.width()
			boundaryoffset = if @boundary.offset() then @boundary.offset().left else 0
			if @centered
				dropdown.css 'margin-' + _c.langdirection, (parseFloat(width) / 2 - dropdown.parent().width() / 2) * -1
				offset = dropdown.offset()
				if width + offset.left > boundarywidth or offset.left < 0
					dropdown.css 'margin-' + _c.langdirection, ''
					offset = dropdown.offset()
			if @justified and @justified.length
				jwidth = @justified.outerWidth()
				dropdown.css 'min-width', jwidth
				if _c.langdirection is 'right'
					right1 = boundarywidth - (@justified.offset().left + jwidth)
					right2 = boundarywidth - (dropdown.offset().left + dropdown.outerWidth())
					dropdown.css 'margin-right', right1 - right2
				else
					dropdown.css 'margin-left', @justified.offset().left - offset.left
				offset = dropdown.offset()
			if width + (offset.left - boundaryoffset) > boundarywidth
				dropdown.addClass 'dropdown-flip'
				offset = dropdown.offset()
			if offset.left - boundaryoffset < 0
				dropdown.addClass 'dropdown-stack'
				if dropdown.hasClass('dropdown-flip')
					unless @flipped
						dropdown.removeClass 'dropdown-flip'
						offset = dropdown.offset()
						dropdown.addClass 'dropdown-flip'
					setTimeout ->
						if dropdown.offset().left - boundaryoffset < 0 or not $this.flipped and dropdown.outerWidth() + (offset.left - boundaryoffset) < boundarywidth
							dropdown.removeClass 'dropdown-flip'
					, 0
				@trigger 'stack.clique.dropdown', [this]
			dropdown.css 'display', ''
