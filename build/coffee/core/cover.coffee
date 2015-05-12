
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-cover', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.cover requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'cover',
		defaults :
			automute : true

		boot : ->
			_c.ready (context)->
				$('[data-cover]', context).each ->
					ele = $(@)
					unless ele.data('clique.data.cover')
						obj = _c.cover ele, _c.utils.options(ele.attr('data-cover'))
						return

		init : ->
			@parent = @element.parent()
			_c.$win.on 'load resize orientationchange', _c.utils.debounce =>
				@check()
			, 100
			@on 'display.clique.check', (e)=>
				if @is(':visible')
					@check()
			@check()
			if @element.is('iframe') and @options.automute
				src = @element.attr('src')
				@element
					.attr 'src', ''
					.on 'load', ->
						@contentWindow.postMessage '{ "event" : "command", "func" : "mute", "method" :"setVolume", "value" :0}', '*'
					.attr 'src', [
						src
						if src.indexOf('?') > -1 then '&' else '?'
						'enablejsapi=1&api=1'
					].join('')

		check : ->
			@element.css
				width : ''
				height : ''

			@dimension =
				w : @element.width()
				h : @element.height()

			if @element.attr('width') and not isNaN(@element.attr('width'))
				@dimension.w = @element.attr('width')
			if @element.attr('height') and not isNaN(@element.attr('height'))
				@dimension.h = @element.attr('height')
			@ratio = @dimension.w / @dimension.h
			w = @parent.width()
			h = @parent.height()
			if w / @ratio < h
				width = Math.ceil(h * @ratio)
				height = h
			else
				width = w
				height = Math.ceil(w / @ratio)
			@element.css
				width : width
				height : height
