
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-accordion', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.accordion requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'accordion',
		defaults :
			showfirst : true
			collapse : true
			animate : true
			easing : 'swing'
			duration : 300
			toggle : '.accordion-title'
			containers : '.accordion-content'
			clsactive : 'active'

		boot : ->
			_c.ready (context)->
				setTimeout ->
					_c.$('[data-accordion]', context).each ->
						ele = _c.$(@)
						unless ele.data('clique.data.accordion')
							_c.accordion ele, _c.utils.options(ele.attr('data-accordion'))
				, 0

		init : ->
			$this = @
			@element.on 'click.clique.accordion', @options.toggle, (e)->
				e.preventDefault()
				$this.toggleItem _c.$(@).data('wrapper'), $this.options.animate, $this.options.collapse

			@update()
			if @options.showfirst
				@toggleItem @toggle.eq(0).data('wrapper'), false, false

		getHeight : (ele)->
			$ele = _c.$(ele)
			height = 'auto'
			if $ele.is(':visible')
				height = $ele.outerHeight()
			else
				tmp =
					position : $ele.css('position')
					visibility : $ele.css('visibility')
					display : $ele.css('display')

				height = $ele.css(
					position : 'absolute'
					visibility : 'hidden'
					display : 'block'
				).outerHeight()
				$ele.css tmp
			height

		toggleItem : (wrapper, animated, collapse)->
			$this = @
			wrapper.data('toggle').toggleClass @options.clsactive
			active = wrapper.data('toggle').hasClass(@options.clsactive)
			if collapse
				@toggle.not(wrapper.data('toggle')).removeClass @options.clsactive
				@content.not(wrapper.data('content')).parent().stop().animate(
					height : 0
				,
					easing : @options.easing
					duration : (if animated then @options.duration else 0)
				).attr 'aria-expanded', 'false'
			if animated
				wrapper.stop().animate
					height : (if active then $this.getHeight(wrapper.data('content')) else 0)
				,
					easing : @options.easing
					duration : @options.duration
					complete : ->
						if active
							_c.utils.checkDisplay wrapper.data('content')
							wrapper.height 'auto'
						$this.trigger 'display.clique.check'
			else
				wrapper.stop().height (if active then 'auto' else 0)
				if active
					_c.utils.checkDisplay wrapper.data('content')
				@trigger 'display.clique.check'
			wrapper.attr 'aria-expanded', active
			@element.trigger 'toggle.clique.accordion', [
				active
				wrapper.data('toggle')
				wrapper.data('content')
			]

		update : ->
			$this = @
			@toggle = @find(@options.toggle)
			@content = @find(@options.containers)
			@content.each (index)->
				$content = _c.$(@)
				if $content.parent().data('wrapper')
					$wrapper = $content.parent()
				else
					$wrapper = _c.$(@).wrap('<div data-wrapper="true" style="overflow :hidden;height :0;position :relative;"></div>').parent()
					$wrapper.attr 'aria-expanded', 'false'
				$toggle = $this.toggle.eq(index)
				$wrapper.data 'toggle', $toggle
				$wrapper.data 'content', $content
				$toggle.data 'wrapper', $wrapper
				$content.data 'wrapper', $wrapper

			@element.trigger 'update.clique.accordion', [this]

	_c.accordion
