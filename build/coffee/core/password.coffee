
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-form.password', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.form.password requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'formPassword',
		defaults :
			lblShow : 'Show'
			lblHide : 'Hide'

		boot : ->
			_c.$html.on 'click.formpassword.clique', '[data-form-password]', (e)->
				ele = _c.$(@)
				unless ele.data('clique.data.formPassword')
					e.preventDefault()
					obj = _c.formPassword ele, _c.utils.options(ele.attr('data-form-password'))
					ele.trigger 'click'

		init : ->
			$this = @
			@on 'click', (e)=>
				e.preventDefault()
				if @input.length
					type = @input.attr('type')
					@input.attr 'type', (if type is 'text' then 'password' else 'text')
					@element.text @options[(if type is 'text' then 'lblShow' else 'lblHide')]

			@input = (if @element.next('input').length then @element.next('input') else @element.prev('input'))
			@element.text @options[(if @input.is('[type=\'password\']') then 'lblShow' else 'lblHide')]
			@element.data 'formPassword', @

	_c.formPassword
