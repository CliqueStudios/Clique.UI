
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-select', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.select requires Clique.core')

	unless window.Clique.dropdown
		throw new Error('Clique.select requires the Clique.dropdown component')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'select',

		defaults :
			inheritClasses : true

		boot : ->
			_c.on 'ready', (context)->
				$('[data-select]', context).each ->
					ele = $(@)
					if ! ele.is('select')
						ele.find('select').each ->
							unless ele.data('clique.data.select')
								obj = _c.select ele
								return
					else
						unless ele.data('clique.data.select')
							obj = _c.select ele
							return

		init : ->
			$this = @
			@element.on 'clique.select.change', (e, idx, obj)->
				$this.updateSelect idx, obj
			@selectOptions = []
			@element.children('option').each (i)->
				$this.selectOptions.push {
					text : $(@).text()
					value : $(@).val()
				}
			@template()
			@bindSelect()
			setTimeout ->
				$this.select.find('.nav-dropdown li:first-child a').trigger 'click'
			, 0

		template : ->
			cls = []
			if @options.inheritClasses and @element.attr('class')
				classes = @element.attr('class').split(' ')
				$.each classes, (i)->
					cls.push classes[i]
			cls.push 'select'
			width = @element.width() + 23
			@select = $('<div class="' + cls.join(' ') + '" data-dropdown="{mode:\'click\'}" style="width:' + width + 'px;" />')
			firstOption = @element.children('option').first()
			@select.append $('<a href="#" class="select-link"></a>')
			@select.append $('<div class="dropdown dropdown-scrollable"><ul class="nav nav-dropdown nav-side" /></div>')
			$this = @
			$.each @selectOptions, (i, v)->
				option = $('<li><a href="#">' + v.text + '</a></li>')
				$this.select.find('.nav-dropdown').append option
			@element.before @select
			@element.hide()

		bindSelect : ->
			$this = @
			@select.on 'click', '.nav-dropdown a', (e)->
				e.preventDefault()
				idx = $(@).parent('li').index()
				option = $this.selectOptions[idx]
				obj =
					value : option.value
					text : option.text
				$this.element.trigger 'clique.select.change', [ idx, obj ]

		updateSelect : (idx, obj)->
			@select.find('.nav-dropdown li').removeClass 'active'
			li = @select.find('.nav-dropdown li').eq(idx)
			li.addClass 'active'
			@select.children('.select-link').text obj.text
			@element.val obj.value
			@trigger 'change'

	_c.select

