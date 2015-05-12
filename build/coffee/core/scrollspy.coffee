
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-scrollspy', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.scrollspy requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	$win = _c.$win
	$doc = _c.$doc
	scrollspies = []
	checkScrollSpy = ->
		i = 0
		while i < scrollspies.length
			_c.support.requestAnimationFrame.apply window, [scrollspies[i].check]
			i++

	_c.component 'scrollspy',
		defaults :
			target : false
			cls : 'scrollspy-inview'
			initcls : 'scrollspy-init-inview'
			topoffset : 0
			leftoffset : 0
			repeat : false
			delay : 0

		boot : ->
			$doc.on 'scrolling.clique.dom', _c.utils.debounce(checkScrollSpy, 150)
			$win.on 'load resize orientationchange', _c.utils.debounce(checkScrollSpy, 150)
			_c.ready (context)->
				$('[data-scrollspy]', context).each ->
					element = $(@)
					unless element.data('clique.data.scrollspy')
						obj = _c.scrollspy element, _c.utils.options(element.attr('data-scrollspy'))
						return

		init : ->
			$this = @
			togglecls = @options.cls.split(/,/)
			fn = ->
				elements = if $this.options.target then $this.element.find($this.options.target) else $this.element
				delayIdx = if elements.length is 1 then 1 else 0
				toggleclsIdx = 0
				elements.each (idx)->
					element = $(@)
					inviewstate = element.data('inviewstate')
					inview = _c.utils.isInView(element, $this.options)
					toggle = element.data('cliqueScrollspyCls') or togglecls[toggleclsIdx].trim()
					if inview and not inviewstate and not element.data('scrollspy-idle')
						unless initinview
							element.addClass $this.options.initcls
							$this.offset = element.offset()
							initinview = true
							element.trigger 'init.clique.scrollspy'
						element.data 'scrollspy-idle', setTimeout ->
							element.addClass('scrollspy-inview').toggleClass(toggle).width()
							element.trigger 'inview.clique.scrollspy'
							element.data 'scrollspy-idle', false
							element.data 'inviewstate', true
						, $this.options.delay * delayIdx
						delayIdx++
					if not inview and inviewstate and $this.options.repeat
						if element.data('scrollspy-idle')
							clearTimeout element.data('scrollspy-idle')
						element.removeClass('scrollspy-inview').toggleClass toggle
						element.data 'inviewstate', false
						element.trigger 'outview.clique.scrollspy'
					toggleclsIdx = if togglecls[toggleclsIdx + 1] then toggleclsIdx + 1 else 0
					return
			fn()
			@check = fn
			scrollspies.push @

	scrollspynavs = []
	checkScrollSpyNavs = ->
		i = 0
		while i < scrollspynavs.length
			_c.support.requestAnimationFrame.apply window, [scrollspynavs[i].check]
			i++

	_c.component 'scrollspynav',
		defaults :
			cls : 'active'
			closest : false
			topoffset : 0
			leftoffset : 0
			smoothscroll : false

		boot : ->
			$doc.on 'scrolling.clique.dom', checkScrollSpyNavs
			$win.on 'resize orientationchange', _c.utils.debounce(checkScrollSpyNavs, 50)
			_c.ready (context)->
				$('[data-scrollspy-nav]', context).each ->
					element = $(@)
					unless element.data('scrollspynav')
						obj = _c.scrollspynav element, _c.utils.options(element.attr('data-scrollspy-nav'))
						return

		init : ->
			ids = []
			links = @find('a[href^=\'#\']').each ->
				ids.push $(@).attr('href')

			targets = $(ids.join(','))
			clsActive = @options.cls
			clsClosest = @options.closest or @options.closest
			$this = @
			fn = ->
				inviews = []
				i = 0

				while i < targets.length
					if _c.utils.isInView(targets.eq(i), $this.options)
						inviews.push targets.eq(i)
					i++
				if inviews.length
					scrollTop = $win.scrollTop()
					target = do->
						i = 0

						while i < inviews.length
							if inviews[i].offset().top >= scrollTop
								return inviews[i]
							i++

					unless target
						return
					if $this.options.closest
						links.closest(clsClosest).removeClass clsActive
						navitems = links.filter('a[href=\'#' + target.attr('id') + '\']').closest(clsClosest).addClass(clsActive)
					else
						navitems = links.removeClass(clsActive).filter('a[href=\'#' + target.attr('id') + '\']').addClass(clsActive)
					$this.element.trigger 'inview.clique.scrollspynav', [
						target
						navitems
					]

			if @options.smoothscroll and _c.smoothScroll
				links.each ->
					_c.smoothScroll @, $this.options.smoothscroll
			fn()
			@element.data 'scrollspynav', @
			@check = fn
			scrollspynavs.push @
