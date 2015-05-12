
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-switcher', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.switcher requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	coreAnimation = (cls, current, next)->
		d = _c.$.Deferred()
		clsIn = cls
		clsOut = cls
		if next[0] is current[0]
			d.resolve()
			return d.promise()
		if typeof cls is 'object'
			clsIn = cls[0]
			clsOut = cls[1] or cls[0]

		release = ->
			if current
				current.hide().removeClass 'active ' + clsOut + ' animation-reverse'
			next
				.addClass(clsIn)
				.one _c.support.animation.end, =>
					next.removeClass('' + clsIn + '').css
						opacity : ''
						display : ''
					d.resolve()
					if current
						current.css
							opacity : ''
							display : ''
				.show()

		next.css 'animation-duration', @options.duration + 'ms'
		if current and current.length
			current.css 'animation-duration', @options.duration + 'ms'
			current
				.css 'display', 'none'
				.addClass clsOut + ' animation-reverse'
				.one _c.support.animation.end, =>
					release()
				.css 'display', ''
		else
			next.addClass 'active'
			release()
		d.promise()

	_c.component 'switcher',
		defaults :
			connect : false
			toggle : '>*'
			active : 0
			animation : false
			duration : 200

		animating : false
		boot : ->
			_c.ready (context)->
				$('[data-switcher]', context).each ->
					switcher = $(@)
					unless switcher.data('clique.data.switcher')
						obj = _c.switcher switcher, _c.utils.options(switcher.attr('data-switcher'))
						return

		init : ->
			$this = @
			@on 'click.clique.switcher', @options.toggle, (e)->
				e.preventDefault()
				$this.show this

			if @options.connect
				@connect = $(@options.connect)
				@connect.find('.active').removeClass '.active'
				if @connect.length
					@connect.children().attr 'aria-hidden', 'true'
					@connect.on('click', '[data-switcher-item]', (e)->
						e.preventDefault()
						item = $(@).attr('data-switcher-item')
						if $this.index is item
							return
						switch item
							when 'next', 'previous'
								$this.show $this.index + (if item is 'next' then 1 else -1)
							else
								$this.show parseInt(item, 10)
					).on 'swipeRight swipeLeft', (e)->
						e.preventDefault()
						$this.show $this.index + (if e.type is 'swipeLeft' then 1 else -1)
				toggles = @find(@options.toggle)
				active = toggles.filter('.active')
				if active.length
					@show active, false
				else
					if @options.active is false
						return
					active = toggles.eq(@options.active)
					@show (if active.length then active else toggles.eq(0)), false
				toggles.not(active).attr 'aria-expanded', 'false'
				active.attr 'aria-expanded', 'true'
				@on 'changed.clique.dom', ->
					$this.connect = $($this.options.connect)
					return

		show : (tab, animate)->
			if @animating
				return
			if isNaN(tab)
				tab = $(tab)
			else
				toggles = @find(@options.toggle)
				tab = (if tab < 0 then toggles.length - 1 else tab)
				tab = toggles.eq((if toggles[tab] then tab else 0))
			$this = @
			toggles = @find(@options.toggle)
			active = $(tab)
			animation = Animations[@options.animation] or (current, next)->
				return Animations.none.apply($this)	unless $this.options.animation
				anim = $this.options.animation.split(',')
				if anim.length is 1
					anim[1] = anim[0]
				anim[0] = anim[0].trim()
				anim[1] = anim[1].trim()
				coreAnimation.apply $this, [ anim, current, next ]

			animation = Animations.none	if animate is false or not _c.support.animation
			if active.hasClass 'disabled'
				return
			toggles.attr 'aria-expanded', 'false'
			active.attr 'aria-expanded', 'true'
			toggles.filter('.active').removeClass 'active'
			active.addClass 'active'
			if @options.connect and @connect.length
				@index = @find(@options.toggle).index(active)
				if @index is -1
					@index = 0
				@connect.each ->
					container = $(@)
					children = $(container.children())
					current = $(children.filter('.active'))
					next = $(children.eq($this.index))
					$this.animating = true
					animation.apply($this, [ current, next ]).then ->
						current.removeClass 'active'
						next.addClass 'active'
						current.attr 'aria-hidden', 'true'
						next.attr 'aria-hidden', 'false'
						_c.utils.checkDisplay next, true
						$this.animating = false
						return
			@trigger 'show.clique.switcher', [active]

	Animations =
		none : ->
			d = _c.$.Deferred()
			d.resolve()
			d.promise()

		fade : (current, next)->
			coreAnimation.apply @, [ 'animation-fade', current, next ]

		'slide-bottom' : (current, next)->
			coreAnimation.apply @, [ 'animation-slide-bottom', current, next ]

		'slide-top' : (current, next)->
			coreAnimation.apply @, [ 'animation-slide-top', current, next ]

		'slide-vertical' : (current, next, dir)->
			anim = [ 'animation-slide-top', 'animation-slide-bottom' ]
			if current and current.index() > next.index()
				anim.reverse()
			coreAnimation.apply @, [ anim, current, next ]

		'slide-left' : (current, next)->
			coreAnimation.apply @, [ 'animation-slide-left', current, next ]

		'slide-right' : (current, next)->
			coreAnimation.apply @, [ 'animation-slide-right', current, next ]

		'slide-horizontal' : (current, next, dir)->
			anim = [ 'animation-slide-right', 'animation-slide-left' ]
			if current and current.index() > next.index()
				anim.reverse()
			coreAnimation.apply @, [ anim, current, next ]

		scale : (current, next)->
			coreAnimation.apply @, [ 'animation-scale-up', current, next ]

	_c.switcher.animations = Animations
	return
