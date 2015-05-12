
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-button', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.button requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	# Private variables
	_target = '.btn, button'

	_c.component 'buttonRadio',
		defaults :
			target : '.btn'

		boot : ->
			_c.$html.on 'click.buttonRadio.clique', '[data-button-radio]', (e)->
				ele = $(@)
				unless ele.data('clique.data.buttonRadio')
					obj = _c.buttonRadio(ele, _c.utils.options(ele.attr('data-button-radio')))
					target = $ e.target
					if target.hasClass(obj.options.target) or target.is('button')
						target.trigger 'click'

		init : ->
			$this = @
			@find(_target).attr('aria-checked', 'false').filter('.active').attr 'aria-checked', 'true'
			@on 'click', _target, (e)->
				ele = $(@)
				if ele.is('a[href="#"]')
					e.preventDefault()
				$this.find(_target).not(ele).removeClass('active').blur()
				ele.addClass 'active'
				$this.find(_target).not(ele).attr 'aria-checked', 'false'
				ele.attr 'aria-checked', 'true'
				$this.trigger 'change.clique.btn', [ele]

		getSelected : ->
			@find '.active'

	_c.component 'buttonCheckbox',
		defaults :
			target : '.btn'

		boot : ->
			_c.$html.on 'click.buttonCheckbox.clique', '[data-button-checkbox]', (e)->
				ele = $(@)
				unless ele.data('clique.data.buttonCheckbox')
					obj = _c.buttonCheckbox(ele, _c.utils.options(ele.attr('data-button-checkbox')))
					target = $(e.target)
					if target.hasClass(obj.options.target) or target.is('button')
						target.trigger 'click'

		init : ->
			$this = @
			@find(_target)
				.attr 'aria-checked', 'false'
				.filter '.active'
				.attr 'aria-checked', 'true'
			@on 'click', _target, (e)->
				ele = $(@)
				if ele.is('a[href="#"]')
					e.preventDefault()
				ele.toggleClass('active').blur()
				ele.attr 'aria-checked', ele.hasClass('active')
				$this.trigger 'change.clique.btn', [ele]

		getSelected : ->
			@find '.active'

	_c.component 'button',
		defaults : {}
		boot : ->
			_c.$html.on 'click.btn.clique', '[data-button]', (e)->
				ele = $(@)
				unless ele.data('clique.data.button')
					obj = _c.button(ele, _c.utils.options(ele.attr('data-button')))
					ele.trigger 'click'

		init : ->
			$this = @
			@element.attr 'aria-pressed', @element.hasClass('active')
			@on 'click', (e)->
				if $this.element.is 'a[href="#"]'
					e.preventDefault()
				$this.toggle()
				$this.trigger 'change.clique.btn', [$this.element.blur().hasClass('active')]

		toggle : ->
			@element.toggleClass 'active'
			@element.attr 'aria-pressed', @element.hasClass('active')
