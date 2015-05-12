
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-form', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.form requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'checkbox',

		boot : ->
			_c.on 'ready', (context)->
				$('input[type="checkbox"]:not([data-switch])').each ->
					ele = $(@)
					unless $(@).data('clique.data.checkbox')
						_c.checkbox ele

		init : ->
			if ! $(@element).closest('.form-checkbox').length
				$(@element).wrap "<span class='form-checkbox' />"
				$(@element).after "<span />"
			@triggerEvents()

		triggerEvents : ->
			$(@element).on 'change', (e)->
				if $(@element).is(':checked')
					$(@element).trigger 'clique.checkbox.checked'
				else
					$(@element).trigger 'clique.checkbox.unchecked'


	_c.component 'radio',

		boot : ->
			_c.on 'ready', (context)->
				$('input[type="radio"]').each ->
					ele = $(@)
					unless $(@).data('clique.data.radio')
						_c.radio ele

		init : ->
			if ! $(@element).closest('.form-radio').length
				$(@element).wrap "<span class='form-radio' />"
				$(@element).after "<span />"
			@triggerEvents()

		triggerEvents : ->
			$(@element).on 'change', (e)->
				if $(@element).is(':checked')
					$(@element).trigger 'clique.radio.checked'
				else
					$(@element).trigger 'clique.radio.unchecked'
