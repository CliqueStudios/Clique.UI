
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-tab', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.tab requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'tab',
		defaults :
			target : '> li:not(.tab-responsive, .disabled)'
			connect : false
			active : 0
			animation : false
			duration : 200

		boot : ->
			_c.ready (context)->
				$('[data-tab]', context).each ->
					tab = $(@)
					unless tab.data('clique.data.tab')
						obj = _c.tab tab, _c.utils.options(tab.attr('data-tab'))
						return

		init : ->
			$this = @
			@on 'click.clique.tab', @options.target, (e)->
				e.preventDefault()
				if $this.switcher and $this.switcher.animating
					return
				current = $this.find($this.options.target).not(@)
				current.removeClass('active').blur()
				$this.trigger 'change.clique.tab', [$(@).addClass('active')]
				unless $this.options.connect
					current.attr 'aria-expanded', 'false'
					$(@).attr 'aria-expanded', 'true'

			if @options.connect
				@connect = $(@options.connect)
			@responsivetab = $('<li class="tab-responsive active"><a></a></li>').append('<div class="dropdown dropdown-small"><ul class="nav nav-dropdown"></ul><div>')
			@responsivetab.dropdown = @responsivetab.find('.dropdown')
			@responsivetab.lst = @responsivetab.dropdown.find('ul')
			@responsivetab.caption = @responsivetab.find('a:first')
			if @element.hasClass('tab-bottom')
				@responsivetab.dropdown.addClass 'dropdown-up'
			@responsivetab.lst.on 'click.clique.tab', 'a', (e)->
				e.preventDefault()
				e.stopPropagation()
				link = $(@)
				$this.element.children(':not(.tab-responsive)').eq(link.data('index')).trigger 'click'

			@on 'show.clique.switcher change.clique.tab', (e, tab)->
				$this.responsivetab.caption.html tab.text()

			@element.append @responsivetab
			if @options.connect
				@switcher = _c.switcher @element,
					toggle : '> li:not(.tab-responsive)'
					connect : @options.connect
					active : @options.active
					animation : @options.animation
					duration : @options.duration
			_c.dropdown @responsivetab,
				mode : 'click'

			$this.trigger 'change.clique.tab', [@element.find(@options.target).filter('.active')]
			@check()
			_c.$win.on 'resize orientationchange', _c.utils.debounce ->
				if $this.element.is ':visible'
					$this.check()
			, 100
			@on 'display.clique.check', ->
				if $this.element.is ':visible'
					$this.check()

		check : ->
			children = @element.children(':not(.tab-responsive)').removeClass('hidden')
			unless children.length
				return
			top = children.eq(0).offset().top + Math.ceil(children.eq(0).height() / 2)
			doresponsive = false
			@responsivetab.lst.empty()
			children.each ->
				if $(@).offset().top > top
					doresponsive = true
					return

			if doresponsive
				i = 0

				while i < children.length
					item = $(children.eq(i))
					link = item.find('a')
					if item.css('float') isnt 'none' and not item.attr('dropdown')
						item.addClass 'hidden'
						@responsivetab.lst.append '<li><a href="' + link.attr('href') + '" data-index="' + i + '">' + link.html() + '</a></li>'	unless item.hasClass('disabled')
					i++
			@responsivetab[(if @responsivetab.lst.children().length then 'removeClass' else 'addClass')] 'hidden'
