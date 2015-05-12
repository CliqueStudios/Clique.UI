
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-switch', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.switch requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'switch',
		defaults:
			labels:
				off: 'Off'
				on: 'On'

		boot : ->
			_c.ready (context)->
				_c.$('[data-switch]', context).each ->
					ele = _c.$(@)
					unless ele.data('clique.data.switch')
						obj = _c.switch ele, _c.utils.options(ele.attr('data-switch'))
						return

		init: ->
			$this = @
			@create @element
			@destroy = @destroy
			@element.data 'switch', this

		create : ($input)->
			if typeof $input is 'undefined'
				$input = @element
			$this = @
			$input.wrap '<div class="switch" />'
			$wrapper = @$wrapper = $input.closest('.switch')
			$wrapper.wrapInner '<div class="switch-container" />'
			$container = $wrapper.children('.switch-container')
			elementArray = [
				'<div class="switch-handle on"><label>' + @options.labels.on + '</label></div>'
				'<div class="switch-label" />'
				'<div class="switch-handle off"><label>' + @options.labels.off + '</label></div>'
			]
			i = 0
			while i < elementArray.length
				$container.append elementArray[i]
				i++
			@set 'state', $input.is(':checked')
			@$wrapper.on 'click', (e)->
				$this.toggle $this.element
			@element.trigger 'init.clique.switch'

		destroy : ->
			@$wrapper.find('.switch-handle, .switch-label').remove()
			@element.unwrap().unwrap()
			@element.removeData ['clique.data.switch', 'switch']

		toggle : ($input)->
			if typeof $input is 'undefined'
				$input = @element
			$this = @
			$input.trigger 'willswitch.clique.switch'
			# @$wrapper.off _c.support.transition.end
			@$wrapper.one _c.support.transition.end, ->
				$input.trigger 'didswitch.clique.switch', [$this.state]
			state = if @state is 'on' then true else false
			@set 'state', not state

		set : (prop, val)->
			if prop is 'state'
				if _c.utils.isString(val)
					if val.toLowerCase() is 'on'
						val = true
					else
						val = false
				@state = if val then 'on' else 'off'
				@$wrapper.removeClass 'on off'
				@$wrapper.addClass @state
				@element.prop 'checked', val
				@element.prop 'on', val

	_c.switch
