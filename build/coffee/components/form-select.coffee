
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-form.select', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.form.select requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'formSelect',
		defaults :
			target : '>span:first'

		boot : ->
			_c.ready (context)->
				_c.$('[data-form-select]', context).each ->
					ele = _c.$(@)
					unless ele.data('clique.data.formSelect')
						obj = _c.formSelect ele, _c.utils.options(ele.attr('data-form-select'))
						return

		init : ->
			$this = @
			@target = @find(@options.target)
			@select = @find('select')
			@select.on 'change', do=>
				select = @select[0]
				fn = ->
					try
						@target.text select.options[select.selectedIndex].text
					fn
				fn()
			@element.data 'formSelect', @

	_c.formSelect
