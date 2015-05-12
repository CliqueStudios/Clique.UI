
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-offcanvas', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.offcanvas requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	scrollpos =
		x : window.scrollX
		y : window.scrollY

	$win = _c.$win
	$doc = _c.$doc
	$html = _c.$html

	Offcanvas =

		show : (element)->
			element = _c.$(element)
			unless element.length
				return
			bar = element.find('.offcanvas-bar').first()
			rtl = _c.langdirection is 'right'
			flip = if bar.hasClass('offcanvas-bar-flip') then -1 else 1
			dir = flip * (if rtl then -1 else 1)
			scrollpos =
				x : window.pageXOffset
				y : window.pageYOffset

			element.addClass 'active'
			_c.$body.css
				width : window.innerWidth
				height : window.innerHeight
			.addClass 'offcanvas-page'
			_c.$body
				.css (if rtl then 'margin-right' else 'margin-left'), (if rtl then -1 else 1) * (bar.outerWidth() * dir)
				.width()
			$html.css 'margin-top', scrollpos.y * -1
			bar.addClass 'offcanvas-bar-show'
			@_initElement element
			$doc.trigger 'show.clique.offcanvas', [ element, bar ]
			element.attr 'aria-hidden', 'false'
			return

		hide : (force)->
			# $body = _c.$('body')
			panel = _c.$('.offcanvas.active')
			rtl = _c.langdirection is 'right'
			bar = panel.find('.offcanvas-bar').first()
			finalize = ->
				_c.$body.removeClass('offcanvas-page').css
					width : ''
					height : ''
					'margin-left' : ''
					'margin-right' : ''

				panel.removeClass 'active'
				bar.removeClass 'offcanvas-bar-show'
				$html.css 'margin-top', ''
				window.scrollTo scrollpos.x, scrollpos.y
				_c.$doc.trigger 'hide.clique.offcanvas', [
					panel
					bar
				]
				panel.attr 'aria-hidden', 'true'

			unless panel.length
				return
			if _c.support.transition and not force
				_c.$body
					.one _c.support.transition.end, ->
						finalize()
					.css (if rtl then 'margin-right' else 'margin-left'), ''
				setTimeout ->
					bar.removeClass 'offcanvas-bar-show'
				, 0
			else
				finalize()

		_initElement : (element)->
			if element.data('OffcanvasInit')
				return
			element.on 'click.clique.offcanvas swipeRight.clique.offcanvas swipeLeft.clique.offcanvas', (e)->
				target = _c.$(e.target)
				unless e.type.match(/swipe/)
					unless target.hasClass('offcanvas-close')
						if target.hasClass('offcanvas-bar')
							return
						if target.parents('.offcanvas-bar').first().length
							return
				e.stopImmediatePropagation()
				Offcanvas.hide()

			element.on 'click', 'a[href^=\'#\']', (e)->
				element = _c.$(@)
				href = element.attr('href')
				if href is '#'
					return
				_c.$doc.one 'hide.clique.offcanvas', ->
					target = _c.$(href)
					unless target.length
						target = _c.$('[name="' + href.replace('#', '') + '"]')
					if _c.utils.scrollToElement and target.length
						_c.utils.scrollToElement target
					else
						window.location.href = href
						return
				Offcanvas.hide()
			element.data 'OffcanvasInit', true

	_c.component 'offcanvasTrigger',
		boot : ->
			$html.on 'click.offcanvas.clique', '[data-offcanvas]', (e)->
				e.preventDefault()
				ele = _c.$(@)
				unless ele.data('clique.data.offcanvasTrigger')
					obj = _c.offcanvasTrigger(ele, _c.utils.options(ele.attr('data-offcanvas')))
					ele.trigger 'click'
			$html.on 'keydown.clique.offcanvas', (e)->
				if e.keyCode is 27
					Offcanvas.hide()

		init : ->
			$this = @
			@options = _c.$.extend
				target : if $this.element.is('a') then $this.element.attr('href') else false
			, @options
			@on 'click', (e)->
				e.preventDefault()
				Offcanvas.show $this.options.target

	_c.offcanvas = Offcanvas
	return
