
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-autocomplete', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.autocomplete requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	active = null
	_c.component 'autocomplete',
		defaults:
			minLength: 3
			param: 'search'
			method: 'post'
			delay: 300
			loadingClass: 'loading'
			flipDropdown: false
			skipClass: 'skip'
			hoverClass: 'active'
			source: null
			renderer: null
			template: '<ul class="nav nav-autocomplete autocomplete-results">{{~items}}<li data-value="{{$item.value}}"><a>{{$item.value}}</a></li>{{/items}}</ul>'

		visible: false
		value: null
		selected: null

		boot : ->
			_c.$html.on 'focus.autocomplete.clique', '[data-autocomplete]', (e)->
				ele = _c.$(@)
				unless ele.data('clique.data.autocomplete')
					obj = _c.autocomplete ele, _c.utils.options(ele.attr('data-autocomplete'))
					return

			_c.$html.on 'click.autocomplete.clique', (e)->
				if active and e.target isnt active.input[0]
					active.hide()

		init : ->
			$this = @
			select = false
			trigger = _c.utils.debounce (e)->
				if select
					select = false
					return
				$this.handle()
			, @options.delay
			@dropdown = @find('.dropdown')
			@template = @find('script[type="text/autocomplete"]').html()
			@template = _c.utils.template(@template or @options.template)
			@input = @find('input:first').attr('autocomplete', 'off')
			unless @dropdown.length
				@dropdown = _c.$('<div class="dropdown"></div>').appendTo(@element)
			@dropdown.addClass 'dropdown-flip'	if @options.flipDropdown
			@dropdown.attr 'aria-expanded', 'false'
			@input.on
				keydown : (e)->
					if e and e.which and not e.shiftKey
						switch e.which
							when 13
								select = true
								if $this.selected
									e.preventDefault()
									$this.select()
							when 38
								e.preventDefault()
								$this.pick 'prev', true
							when 40
								e.preventDefault()
								$this.pick 'next', true
							when 27, 9
								$this.hide()
							else

				keyup : trigger

			@dropdown.on 'click', '.autocomplete-results > *', ->
				$this.select()

			@dropdown.on 'mouseover', '.autocomplete-results > *', ->
				$this.pick _c.$(@)

			@triggercomplete = trigger
			return

		handle : ->
			$this = @
			old = @value
			@value = @input.val()
			if @value.length < @options.minLength
				return @hide()
			unless @value is old
				$this.request()
			@

		pick : (item, scrollinview)->
			$this = @
			items = _c.$(@dropdown.find('.autocomplete-results').children(':not(.' + @options.skipClass + ')'))
			selected = false
			if typeof item isnt 'string' and not item.hasClass(@options.skipClass)
				selected = item
			else
				if item is 'next' or item is 'prev'
					if @selected
						index = items.index(@selected)
						if item is 'next'
							selected = items.eq((if index + 1 < items.length then index + 1 else 0))
						else
							selected = items.eq((if index - 1 < 0 then items.length - 1 else index - 1))
					else
						selected = items[(if item is 'next' then 'first' else 'last')]()
					selected = _c.$(selected)
			if selected and selected.length
				@selected = selected
				items.removeClass @options.hoverClass
				@selected.addClass @options.hoverClass
				if scrollinview
					top = selected.position().top
					scrollTop = $this.dropdown.scrollTop()
					dpheight = $this.dropdown.height()
					$this.dropdown.scrollTop scrollTop + top	if top > dpheight or top < 0

		select : ->
			unless @selected
				return
			data = @selected.data()
			@trigger 'select.clique.autocomplete', [ data, @ ]
			@input.val(data.value).trigger 'change'	if data.value
			@hide()

		show : ->
			if @visible
				return
			@visible = true
			@element.addClass 'open'
			active = @
			@dropdown.attr 'aria-expanded', 'true'
			@

		hide : ->
			unless @visible
				return
			@visible = false
			@element.removeClass 'open'
			if active is @
				active = false
			@dropdown.attr 'aria-expanded', 'false'
			@

		request : ->
			$this = @
			release = (data)->
				if data
					$this.render data
				$this.element.removeClass $this.options.loadingClass

			@element.addClass @options.loadingClass
			if @options.source
				source = @options.source
				switch typeof @options.source
					when 'function'
						@options.source.apply @, [release]
					when 'object'
						if source.length
							items = []
							source.forEach (item)->
								if item.value and item.value.toLowerCase().indexOf($this.value.toLowerCase()) isnt -1
									items.push item
							release items
					when 'string'
						params = {}
						params[@options.param] = @value
						_c.$.ajax(
							url: @options.source
							data: params
							type: @options.method
							dataType: 'json'
						).done (json)->
							release json or []
							return
					else
						release null
			else
				@element.removeClass $this.options.loadingClass

		render : (data)->
			# $this = @
			@dropdown.empty()
			@selected = false
			if @options.renderer
				@options.renderer.apply @, [data]
			else
				if data and data.length
					@dropdown.append @template(items: data)
					@show()
					@trigger 'show.clique.autocomplete'
			@

	_c.autocomplete
