
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-modal', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.modal requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	setContent = (content, modal)->
		unless modal
			return
		if typeof content is 'object'
			content = (if content instanceof jQuery then content else $(content))
			if content.parent().length
				modal.persist = content
				modal.persist.data 'modalPersistParent', content.parent()
		else
			if typeof content is 'string' or typeof content is 'number'
				content = $('<div></div>').html(content)
			else
				content = $('<div></div>').html('Clique.modal Error : Unsupported data type : ' + typeof content)
		content.appendTo modal.element.find('.modal-dialog')
		modal

	active = false

	_c.component 'modal',
		defaults :
			keyboard : true
			bgclose : true
			minScrollHeight : 150
			center : false

		scrollable : false

		transition : false

		init : ->
			$this = @
			@transition = _c.support.transition
			@paddingdir = 'padding-' + if _c.langdirection is 'left' then 'right' else 'left'
			@dialog = @find '.modal-dialog'
			@element.attr 'aria-hidden', @element.hasClass('open')
			@on 'click', '.modal-close', (e)->
				e.preventDefault()
				$this.hide()
			.on 'click', (e)->
				target = $(e.target)
				if target[0] is $this.element[0] and $this.options.bgclose
					$this.hide()

		toggle : ->
			this[(if @isActive() then 'hide' else 'show')]()

		show : ->
			$this = @
			if @isActive()
				return
			if active
				active.hide true
			@element.removeClass('open').show()
			@resize()
			active = this
			_c.$html.addClass('modal-page').height()
			@element.addClass 'open'
			@element.attr 'aria-hidden', 'false'
			@element.trigger 'show.clique.modal'
			_c.utils.checkDisplay @dialog, true
			this

		hide : (force)->
			unless @isActive()
				return
			if ! force and _c.support.transition
				$this = @
				@one _c.support.transition.end, ->
					$this._hide()
				.removeClass 'open'
			else
				@_hide()
			this

		resize : ->
			bodywidth = _c.$body.width()
			@scrollbarwidth = window.innerWidth - bodywidth
			_c.$body.css @paddingdir, @scrollbarwidth
			@element.css 'overflow-y', (if @scrollbarwidth then 'scroll' else 'auto')
			if not @updateScrollable() and @options.center
				dh = @dialog.outerHeight()
				pad = parseInt(@dialog.css('margin-top'), 10) + parseInt(@dialog.css('margin-bottom'), 10)
				if dh + pad < window.innerHeight
					@dialog.css top : window.innerHeight / 2 - dh / 2 - pad
				else
					@dialog.css top : ''

		updateScrollable : ->
			scrollable = @dialog.find('.overflow-container:visible:first')
			if scrollable.length
				scrollable.css 'height', 0
				offset = Math.abs(parseInt(@dialog.css('margin-top'), 10))
				dh = @dialog.outerHeight()
				wh = window.innerHeight
				h = wh - 2 * (if offset < 20 then 20 else offset) - dh
				scrollable.css 'height', (if h < @options.minScrollHeight then '' else h)
				return true
			false

		_hide : ->
			@element.hide().removeClass 'open'
			@element.attr 'aria-hidden', 'true'
			_c.$html.removeClass 'modal-page'
			_c.$body.css @paddingdir, ''
			if active is this
				active = false
			@trigger 'hide.clique.modal'

		isActive : ->
			active is this

	_c.component 'modalTrigger',

		boot : ->
			_c.$html.on 'click.modal.clique', '[data-modal]', (e)->
				ele = $(@)
				if ele.is('a')
					e.preventDefault()
				unless ele.data('clique.data.modalTrigger')
					modal = _c.modalTrigger(ele, _c.utils.options(ele.attr('data-modal')))
					modal.show()

			_c.$html.on 'keydown.modal.clique', (e)->
				if active and e.keyCode is 27 and active.options.keyboard
					e.preventDefault()
					active.hide()

			_c.$win.on 'resize orientationchange', _c.utils.debounce ->
				if active
					active.resize()
			, 150

		init : ->
			$this = @
			@options = _c.$.extend(
				target : (if $this.element.is('a') then $this.element.attr('href') else false)
			, @options)
			@modal = _c.modal @options.target, @options
			@on 'click', (e)->
				e.preventDefault()
				$this.show()

			@proxy @modal, 'show hide isActive'

	_c.modal.dialog = (content, options)->
		modal = _c.modal $(_c.modal.dialog.template).appendTo('body'), options
		modal.on 'hide.clique.modal', ->
			if modal.persist
				modal.persist.appendTo modal.persist.data('modalPersistParent')
				modal.persist = false
			modal.element.remove()
		setContent content, modal
		modal

	_c.modal.dialog.template = '<div class="modal"><div class="modal-dialog" style="min-height :0;"></div></div>'

	_c.modal.alert = (content, options)->
		_c.modal.dialog([
			'<div class="margin modal-content">' + String(content) + '</div>'
			'<div class="modal-footer text-right"><button class="button button-primary modal-close">Ok</button></div>'
		].join(''), _c.$.extend(
			bgclose : false
			keyboard : false
		, options)).show()

	_c.modal.confirm = (content, onconfirm, options)->
		onconfirm = (if _c.$.isFunction(onconfirm) then onconfirm else -> )
		modal = _c.modal.dialog([
			'<div class="margin modal-content">' + String(content) + '</div>'
			'<div class="modal-footer text-right"><button class="button button-primary js-modal-confirm">Ok</button> <button class="button modal-close">Cancel</button></div>'
		].join(''), _c.$.extend(
			bgclose : false
			keyboard : false
		, options))
		modal.element.find('.js-modal-confirm').on 'click', ->
			onconfirm()
			modal.hide()
		modal.show()
	return
