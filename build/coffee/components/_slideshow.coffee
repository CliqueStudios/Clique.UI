
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-slideshow', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.slideshow requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	playerId = 0
	Animations = null
	_c.component 'slideshow',
		defaults :
			animation : 'fade'
			duration : 500
			height : 'auto'
			start : 0
			autoplay : false
			autoplayInterval : 7e3
			videoautoplay : true
			videomute : true
			kenburns : false
			slices : 15
			pauseOnHover : true

		current : false
		interval : null
		hovering : false
		boot : ->
			_c.ready (context)->
				_c.$('[data-slideshow]', context).each ->
					slideshow = _c.$(@)
					unless slideshow.data('clique.data.slideshow')
						obj = _c.slideshow slideshow, _c.utils.options(slideshow.attr('data-slideshow'))
						return

		init : ->
			$this = @
			@container = (if @element.hasClass('slideshow') then @element else _c.$(@find('.slideshow')))
			@slides = @container.children()
			@slidesCount = @slides.length
			@current = @options.start
			@animating = false
			@triggers = @find('[data-slideshow-item]')
			@fixFullscreen = navigator.userAgent.match(/(iPad|iPhone|iPod)/g) and @container.hasClass('slideshow-fullscreen')
			@slides.each (index)->
				slide = _c.$(@)
				media = slide.children('img, video, iframe')[0]
				slide.data 'media', media
				slide.data 'sizer', media
				if media.length
					switch media[0].nodeName
						when 'IMG'
							cover = _c.$('<div class="cover-background position-cover"></div>').css('background-image' : 'url(' + media.attr('src') + ')')
							media.css
								width : '100%'
								height : 'auto'
							slide.prepend(cover).data 'cover', cover
						when 'IFRAME'
							src = media[0].src
							iframeId = 'sw-' + playerId++
							media
								.attr 'src', ''
								.on 'load', ->
									if index isnt $this.current or index is $this.current and not $this.options.videoautoplay
										$this.pausemedia media
									if $this.options.videomute
										$this.mutemedia media
										`var inv = setInterval((function(ic) {
                                            return function() {
                                                $this.mutemedia(media);
                                                if (++ic >= 4) {
                                                	clearInterval(inv);
                                                }
                                            };
                                        })(0), 250)`
										# inv = setInterval(((ic)->
										# 	->
										# 		$this.mutemedia media
										# 		if ++ic >= 4
										# 			clearInterval inv
										# ), `(0)`, 250)
										return
								.data 'slideshow', $this
								.attr 'data-player-id', iframeId
								.attr 'src', [ src, (if src.indexOf('?') > -1 then '&' else '?'), 'enablejsapi=1&api=1&player_id=' + iframeId, ].join('')
								.addClass 'position-absolute'
							unless _c.support.touch
								media.css 'pointer-events', 'none'
							placeholder = true
							if _c.cover
								_c.cover media
								media.attr 'data-cover', '{}'
						when 'VIDEO'
							media.addClass 'cover-object position-absolute'
							placeholder = true
							if $this.options.videomute
								$this.mutemedia media
					if placeholder
						canvas = _c.$('<canvas></canvas>').attr(
							width : media[0].width
							height : media[0].height
						)
						img = _c.$('<img style="width :100%;height :auto;">').attr('src', canvas[0].toDataURL())
						slide.prepend img
						slide.data 'sizer', img
				else
					slide.data 'sizer', slide

			@on 'click.clique.slideshow', '[data-slideshow-item]', (e)->
				e.preventDefault()
				slide = _c.$(@).attr('data-slideshow-item')
				if $this.current is slide
					return
				switch slide
					when 'next', 'previous'
						$this[(if slide is 'next' then 'next' else 'previous')]()
					else
						$this.show parseInt(slide, 10)
				$this.stop()

			@slides.attr('aria-hidden', 'true').eq(@current).addClass('active').attr 'aria-hidden', 'false'
			@triggers.filter('[data-slideshow-item="' + @current + '"]').addClass 'active'
			_c.$win.on 'resize load', _c.utils.debounce ->
				$this.resize()
				if $this.fixFullscreen
					$this.container.css 'height', window.innerHeight
					$this.slides.css 'height', window.innerHeight
			, 100
			@resize()
			if @options.autoplay
				@start()
			if @options.videoautoplay and @slides.eq(@current).data('media')
				@playmedia @slides.eq(@current).data('media')
			if @options.kenburns
				@applyKenBurns @slides.eq(@current)
			@container.on
				mouseenter : ->
					if $this.options.pauseOnHover
						$this.hovering = true
						return

				mouseleave : ->
					$this.hovering = false
					return

			@on 'swipeRight swipeLeft', (e)->
				$this[(if e.type is 'swipeLeft' then 'next' else 'previous')]()

			@on 'display.clique.check', ->
				if $this.element.is(':visible')
					$this.resize()
					if $this.fixFullscreen
						$this.container.css 'height', window.innerHeight
						$this.slides.css 'height', window.innerHeight

		resize : ->
			if @container.hasClass('slideshow-fullscreen')
				return
			$this = @
			height = @options.height
			if @options.height is 'auto'
				height = 0
				@slides.css('height', '').each ->
					height = Math.max(height, _c.$(@).height())
					return
			@container.css 'height', height
			@slides.css 'height', height

		show : (index, direction)->
			if @animating
				return
			@animating = true
			$this = @
			current = @slides.eq(@current)
			next = @slides.eq(index)
			dir = (if direction then direction else (if @current < index then -1 else 1))
			currentmedia = current.data('media')
			animation = (if Animations[@options.animation] then @options.animation else 'fade')
			nextmedia = next.data('media')
			finalize = ->
				unless $this.animating
					return
				if currentmedia and currentmedia.is('video,iframe')
					$this.pausemedia currentmedia
				if nextmedia and nextmedia.is('video,iframe')
					$this.playmedia nextmedia
				next.addClass('active').attr 'aria-hidden', 'false'
				current.removeClass('active').attr 'aria-hidden', 'true'
				$this.animating = false
				$this.current = index
				_c.utils.checkDisplay next, '[class*="animation-"]:not(.cover-background.position-cover)'
				$this.trigger 'show.clique.slideshow', [next]

			$this.applyKenBurns next
			unless _c.support.animation
				animation = 'none'
			current = _c.$(current)
			next = _c.$(next)
			Animations[animation].apply(this, [
				current
				next
				dir
			]).then finalize
			$this.triggers.removeClass 'active'
			$this.triggers.filter('[data-slideshow-item="' + index + '"]').addClass 'active'

		applyKenBurns : (slide)->
			unless @hasKenBurns(slide)
				return
			animations = [
				'animation-middle-left'
				'animation-top-right'
				'animation-bottom-left'
				'animation-top-center'
				''
				'animation-bottom-right'
			]
			index = @kbindex or 0
			slide.data('cover').attr('class', 'cover-background position-cover').width()
			slide.data('cover').addClass [ 'animation-scale', 'animation-reverse', 'animation-15', animations[index] ].join(' ')
			@kbindex = (if animations[index + 1] then index + 1 else 0)
			return

		hasKenBurns : (slide)->
			@options.kenburns and slide.data('cover')

		next : ->
			@show (if @slides[@current + 1] then @current + 1 else 0)

		previous : ->
			@show (if @slides[@current - 1] then @current - 1 else @slides.length - 1)

		start : ->
			@stop()
			$this = @
			@interval = setInterval ->
				unless $this.hovering
					$this.show $this.options.start, $this.next()
			, @options.autoplayInterval
			return

		stop : ->
			if @interval
				clearInterval @interval

		playmedia : (media)->
			unless media and media[0]
				return
			switch media[0].nodeName
				when 'VIDEO'
					unless @options.videomute
						media[0].muted = false
					media[0].play()
				when 'IFRAME'
					media[0].contentWindow.postMessage '{ "event" : "command", "func" : "unmute", "method" :"setVolume", "value" :1}', '*'	unless @options.videomute
					media[0].contentWindow.postMessage '{ "event" : "command", "func" : "playVideo", "method" :"play"}', '*'

		pausemedia : (media)->
			switch media[0].nodeName
				when 'VIDEO'
					media[0].pause()
				when 'IFRAME'
					media[0].contentWindow.postMessage '{ "event" : "command", "func" : "pauseVideo", "method" :"pause"}', '*'

		mutemedia : (media)->
			switch media[0].nodeName
				when 'VIDEO'
					media[0].muted = true
					return
				when 'IFRAME'
					media[0].contentWindow.postMessage '{ "event" : "command", "func" : "mute", "method" :"setVolume", "value" :0}', '*'

	Animations =
		none : ->
			d = _c.$.Deferred()
			d.resolve()
			d.promise()

		scroll : (current, next, dir)->
			d = _c.$.Deferred()
			current.css 'animation-duration', @options.duration + 'ms'
			next.css 'animation-duration', @options.duration + 'ms'
			next
				.css('opacity', 1)
				.one _c.support.animation.end, =>
					current.removeClass (if dir is 1 then 'slideshow-scroll-backward-out' else 'slideshow-scroll-forward-out')
					next.css('opacity', '').removeClass (if dir is 1 then 'slideshow-scroll-backward-in' else 'slideshow-scroll-forward-in')
					d.resolve()
			current.addClass (if dir is 1 then 'slideshow-scroll-backward-out' else 'slideshow-scroll-forward-out')
			next.addClass (if dir is 1 then 'slideshow-scroll-backward-in' else 'slideshow-scroll-forward-in')
			next.width()
			d.promise()

		swipe : (current, next, dir)->
			d = _c.$.Deferred()
			current.css 'animation-duration', @options.duration + 'ms'
			next.css 'animation-duration', @options.duration + 'ms'
			next
				.css('opacity', 1)
				.one _c.support.animation.end, =>
					current.removeClass (if dir is 1 then 'slideshow-swipe-backward-out' else 'slideshow-swipe-forward-out')
					next.css('opacity', '').removeClass (if dir is 1 then 'slideshow-swipe-backward-in' else 'slideshow-swipe-forward-in')
					d.resolve()
			current.addClass (if dir is 1 then 'slideshow-swipe-backward-out' else 'slideshow-swipe-forward-out')
			next.addClass (if dir is 1 then 'slideshow-swipe-backward-in' else 'slideshow-swipe-forward-in')
			next.width()
			d.promise()

		scale : (current, next, dir)->
			d = _c.$.Deferred()
			current.css 'animation-duration', @options.duration + 'ms'
			next.css 'animation-duration', @options.duration + 'ms'
			next.css 'opacity', 1
			current.one _c.support.animation.end, =>
				current.removeClass 'slideshow-scale-out'
				next.css 'opacity', ''
				d.resolve()
			current.addClass 'slideshow-scale-out'
			current.width()
			d.promise()

		fade : (current, next, dir)->
			d = _c.$.Deferred()
			current.css 'animation-duration', @options.duration + 'ms'
			next.css 'animation-duration', @options.duration + 'ms'
			next.css 'opacity', 1
			current.one _c.support.animation.end, =>
				current.removeClass 'slideshow-fade-out'
				next.css 'opacity', ''
				d.resolve()
			current.addClass 'slideshow-fade-out'
			current.width()
			d.promise()

	_c.slideshow.animations = Animations
	window.addEventListener 'message', onMessageReceived = (e)->
		data = JSON.parse(e.data)
		if e.origin and e.origin.indexOf('vimeo') > -1 and data.event is 'ready' and data.player_id
			iframe = _c.$('[data-player-id="' + data.player_id + '"]')
			if iframe.length
				iframe.data('slideshow').mutemedia iframe
	, false
