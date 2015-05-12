
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-alert', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.alert requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'alert',
		defaults :
			fade : true
			duration : 400
			trigger : '.alert-close'

		boot : ->
			_c.$html.on 'click.alert.clique', '[data-alert]', (e)->
				ele = $(@)
				unless ele.data('clique.data.alert')
					obj = _c.alert(ele, _c.utils.options(ele.attr('data-alert')))
					if $(e.target).is(obj.options.trigger)
						e.preventDefault()
						obj.close()

		init : ->
			@on 'click', @options.trigger, (e)=>
				e.preventDefault()
				@close()

		close : ->
			element = @trigger 'close.clique.alert'
			removeElement = =>
				@trigger('closed.clique.alert').remove()
			if @options.fade
				element
					.css
						overflow : 'hidden'
						'max-height' : element.height()
					.animate
						height : 0
						opacity : 0
						'padding-top' : 0
						'padding-bottom' : 0
						'margin-top' : 0
						'margin-bottom' : 0
					, @options.duration, removeElement
			else
				removeElement()
