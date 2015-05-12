
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-toggle', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.toggle requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	toggles = []

	_c.component 'toggle',

		defaults :
			target : false
			cls : 'hidden'
			animation : false
			duration : 400

		boot : ->
			_c.ready (context)->
				$('[data-toggle]', context).each ->
					ele = $(@)
					unless ele.data('clique.data.toggle')
						obj = _c.toggle ele, _c.utils.options(ele.attr('data-toggle'))
						return

				setTimeout ->
					toggles.forEach (toggle)->
						toggle.getToggles()
				, 0

		init : ->
			$this = @
			@aria = @options.cls.indexOf('hidden') isnt -1
			@getToggles()
			@on 'click', (e)->
				if $this.element.is('a[href="#"]')
					e.preventDefault()
				$this.toggle()

			toggles.push @

		toggle : ->
			unless @totoggle.length
				return
			if @options.animation and _c.support.animation
				$this = @
				animations = @options.animation.split(',')
				if animations.length is 1
					animations[1] = animations[0]
				animations[0] = animations[0].trim()
				animations[1] = animations[1].trim()
				@totoggle.css 'animation-duration', @options.duration + 'ms'
				if @totoggle.hasClass(@options.cls)
					@totoggle.toggleClass @options.cls
					@totoggle.each ->
						_c.utils.animate(this, animations[0]).then ->
							$(@).css 'animation-duration', ''
							_c.utils.checkDisplay this
				else
					@totoggle.each ->
						_c.utils
							.animate(@, animations[1] + ' animation-reverse')
							.then =>
								$(@).toggleClass($this.options.cls).css 'animation-duration', ''
								_c.utils.checkDisplay @
			else
				@totoggle.toggleClass @options.cls
				evt = _c.$.Event
					type : 'toggle.clique'
					relatedTarget : @element
				@totoggle.trigger evt
				_c.utils.checkDisplay @totoggle
			@updateAria()

		getToggles : ->
			@totoggle = if @options.target then $(@options.target) else []
			@updateAria()

		updateAria : ->
			if @aria and @totoggle.length
				@totoggle.each ->
					$(@).attr 'aria-hidden', $(@).hasClass('hidden')
