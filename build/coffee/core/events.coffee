
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-events', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.events requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	dispatch = $.event.dispatch or $.event.handle

	_c.events = {}

	_c.events.scrollstart =
		setup : (data)->
			uid = _c.utils.uid('scrollstart')
			$(@).data 'clique.event.scrollstart.uid', uid
			_data = $.extend(
				latency : $.event.special.scrollstop.latency
			, data)
			timer = null
			handler = (e)->
				_self = @
				_args = arguments
				if timer
					clearTimeout timer
				else
					e.type = 'scrollstart.clique.dom'
					$(e.target).trigger 'scrollstart.clique.dom', e
				timer = setTimeout ->
					timer = null
					return
				, _data.latency
				return

			$(@)
				.on 'scroll', _c.utils.debounce(handler, 100)
				.data uid, handler

		teardown : ->
			uid = $(@).data 'clique.event.scrollstart.uid'
			$(@).off 'scroll', $(@).data(uid)
			$(@).removeData uid
			$(@).removeData 'clique.event.scrollstart.uid'

	_c.events.scrollstop =
		latency : 150

		setup : (data)->
			uid = _c.utils.uid('scrollstop')
			$(@).data 'clique.event.scrolltop.uid', uid
			_data = $.extend(
				latency : $.event.special.scrollstop.latency
			, data)
			timer = null
			handler = (e)->
				_self = @
				_args = arguments
				if timer
					clearTimeout timer
				timer = setTimeout ->
					timer = null
					e.type = 'scrollstop.clique.dom'
					$(e.target).trigger 'scrollstop.clique.dom', e
					return
				, _data.latency
				return

			$(@)
				.on 'scroll', _c.utils.debounce(handler, 100)
				.data uid, handler
			return

		teardown : ->
			uid = $(@).data 'clique.event.scrolltop.uid'
			$(@).off 'scroll', $(@).data(uid)
			$(@).removeData uid
			$(@).removeData 'clique.event.scrolltop.uid'

	_c.events.resizeend =
		latency : 250

		setup : (data)->
			uid = _c.utils.uid('resizeend')
			$(@).data 'clique.event.resizeend.uid', uid
			_data = $.extend
				latency : $.event.special.resizeend.latency
			, data
			timer = _data
			handler = (e)->
				_self = @
				_args = arguments
				if timer
					clearTimeout timer
				timer = setTimeout ->
					timer = null
					e.type = 'resizeend.clique.dom'
					$(e.target).trigger 'resizeend.clique.dom', e
				, _data.latency
				return
			$(@)
				.on 'resize', _c.utils.debounce(handler, 100)
				.data uid, handler

		teardown : ->
			uid = $(@).data 'clique.event.resizeend.uid'
			$(@).off 'resize', $(@).data(uid)
			$(@).removeData uid
			$(@).removeData 'clique.event.resizeend.uid'

	evt = (fn)->
		if fn then @on(k, fn) else @trigger(k)

	for k, v of _c.events
		if typeof v is 'object'
			$.event.special[k] = v
			$.fn[k] = evt
			# $.fn[k] = (fn)->
			# 	if fn then @on(k, fn) else @trigger(k)

	return
