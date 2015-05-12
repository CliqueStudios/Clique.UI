
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-nav', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.nav requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	getHeight = (ele)->
		$ele = $(ele)
		height = 'auto'
		if $ele.is(':visible')
			height = $ele.outerHeight()
		else
			tmp =
				position : $ele.css('position')
				visibility : $ele.css('visibility')
				display : $ele.css('display')

			height = $ele.css
				position : 'absolute'
				visibility : 'hidden'
				display : 'block'
			.outerHeight()
			$ele.css tmp
		height

	_c.component 'nav',
		defaults :
			toggle : '>li.parent > a[href=\'#\']'
			lists : '>li.parent > ul'
			multiple : false

		boot : ->
			_c.ready (context)->
				$('[data-nav]', context).each ->
					nav = $(@)
					unless nav.data('clique.data.nav')
						obj = _c.nav nav, _c.utils.options(nav.attr('data-nav'))
						return

		init : ->
			$this = @
			@on 'click.clique.nav', @options.toggle, (e)->
				e.preventDefault()
				ele = $(@)
				$this.open (if ele.parent()[0] is $this.element[0] then ele else ele.parent('li'))

			@find(@options.lists).each ->
				$ele = $(@)
				parent = $ele.parent()
				active = parent.hasClass('active')
				$ele.wrap '<div style="overflow :hidden;height :0;position :relative;"></div>'
				parent.data 'list-container', $ele.parent()
				parent.attr 'aria-expanded', parent.hasClass('open')
				if active
					$this.open parent, true

		open : (li, noAnimation)->
			$this = @
			element = @element
			$li = $(li)
			unless @options.multiple
				element.children('.open').not(li).each ->
					ele = $(@)
					if ele.data('list-container')
						ele.data('list-container').stop().animate
							height : 0
						, ->
							$(@).parent().removeClass 'open'
			$li.toggleClass 'open'
			$li.attr 'aria-expanded', $li.hasClass('open')
			if $li.data('list-container')
				if noAnimation
					$li.data('list-container').stop().height (if $li.hasClass('open') then 'auto' else 0)
					@trigger 'display.clique.check'
				else
					$li.data('list-container').stop().animate
						height : if $li.hasClass('open') then getHeight($li.data('list-container').find('ul:first')) else 0
					, ->
						$this.trigger 'display.clique.check'
