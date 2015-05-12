
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-smoothScroll', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.smoothScroll requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	listenForScroll = ->
		_c.$win.on 'mousewheel', ->
			$('html, body').stop true

	scrollToElement = (ele, options)->
		options = _c.$.extend
			duration : 1e3
			transition : 'easeOutExpo'
			offset : 0
			complete : ->
		, options
		target = ele.offset().top - options.offset
		docheight = _c.$doc.height()
		winheight = window.innerHeight
		if target + winheight > docheight
			target = docheight - winheight
		listenForScroll()
		$('html, body').stop().animate(
			scrollTop : target
		, options.duration, options.transition).promise().done ->
			options.complete()
			$('html, body').trigger 'didscroll.clique.smooth-scroll'
			_c.$win.off 'mousewheel'

	_c.component 'smoothScroll',
		boot : ->
			_c.$html.on 'click.smooth-scroll.clique', '[data-smooth-scroll]', (e)->
				e.preventDefault()
				ele = $(@)
				unless ele.data('clique.data.smoothScroll')
					obj = _c.smoothScroll(ele, _c.utils.options(ele.attr('data-smooth-scroll')))
					ele.trigger 'click'

		init : ->
			$this = @
			@on 'click', (e)->
				e.preventDefault()
				$('html, body').trigger 'willscroll.clique.smooth-scroll'
				scrollToElement (if $(@hash).length then $(@hash) else _c.$('body')), $this.options

	_c.utils.scrollToElement = scrollToElement

	unless _c.$.easing.easeOutExpo
		_c.$.easing.easeOutExpo = (x, t, b, c, d)->
			if t is d then b + c else c * (-Math.pow(2, -10 * t / d) + 1) + b
		return
