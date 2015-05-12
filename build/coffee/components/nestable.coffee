
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-nestable', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.nestable requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	hasTouch = false
	html = _c.$html
	touchedlists = []
	$win = _c.$win
	draggingElement = undefined
	dragSource = undefined

	hasPointerEvents = do ->
		el = document.createElement('div')
		docEl = document.documentElement
		if ! ('pointerEvents' of el.style)
			return false
		el.style.pointerEvents = 'auto'
		el.style.pointerEvents = 'x'
		docEl.appendChild el
		supports = window.getComputedStyle and window.getComputedStyle(el, '').pointerEvents is 'auto'
		docEl.removeChild el
		!! supports

	eStart = if hasTouch then 'touchstart' else 'mousedown'
	eMove = if hasTouch then 'touchmove' else 'mousemove'
	eEnd = if hasTouch then 'touchend' else 'mouseup'
	eCancel = if hasTouch then 'touchcancel' else 'mouseup'
	_c.component 'nestable',
		defaults:
			prefix: ''
			listNodeName: 'ul'
			itemNodeName: 'li'
			listBaseClass: '{prefix}nestable'
			listClass: '{prefix}nestable-list'
			listitemClass: '{prefix}nestable-list-item'
			itemClass: '{prefix}nestable-item'
			dragClass: '{prefix}nestable-list-dragged'
			movingClass: '{prefix}nestable-moving'
			handleClass: '{prefix}nestable-handle'
			collapsedClass: '{prefix}collapsed'
			placeClass: '{prefix}nestable-placeholder'
			noDragClass: '{prefix}nestable-nodrag'
			emptyClass: '{prefix}nestable-empty'
			group: 0
			maxDepth: 10
			threshold: 20

		boot : ->
			_c.$html.on 'mousemove touchmove', (e)->
				if draggingElement
					top = draggingElement.offset().top
					if top < _c.$win.scrollTop()
						_c.$win.scrollTop _c.$win.scrollTop() - Math.ceil(draggingElement.height() / 2)
					else if top + draggingElement.height() > window.innerHeight + _c.$win.scrollTop()
						_c.$win.scrollTop _c.$win.scrollTop() + Math.ceil(draggingElement.height() / 2)
			_c.ready (context)->
				_c.$('[data-nestable]', context).each ->
					ele = _c.$(@)
					unless ele.data('clique.data.nestable')
						obj = _c.nestable ele, _c.utils.options(ele.attr('data-nestable'))
						return

		init : ->
			$this = @
			_c.$doc.on 'updated.browser.clique', ->
				browser = _c.$doc.data('clique.data.browser')
				hasTouch = browser.screen.touch
				return
			Object.keys(@options).forEach (key)->
				if String($this.options[key]).indexOf('{prefix}') isnt -1
					$this.options[key] = $this.options[key].replace('{prefix}', $this.options.prefix)
				return
			@tplempty = '<div class="' + @options.emptyClass + '"/>'
			@find('>' + @options.itemNodeName).addClass(@options.listitemClass).end().find('ul:not(.ignore-list)').addClass(@options.listClass).find('>li').addClass @options.listitemClass
			if ! @element.children(@options.itemNodeName).length
				@element.append @tplempty
			@element.data 'nestable-id', 'ID' + (new Date()).getTime() + 'RAND' + Math.ceil(Math.random() * 100000)
			@reset()
			@element.data 'nestable-group', @options.group
			@placeEl = _c.$('<div class="' + @options.placeClass + '"/>')
			@find(@options.itemNodeName).each ->
				$this.setParent _c.$(@)
			@on 'click', '[data-nestable-action]', (e)->
				if $this.dragEl or ! hasTouch and e.button isnt 0
					return
				e.preventDefault()
				target = _c.$(e.currentTarget)
				action = target.data('nestableAction')
				item = target.closest($this.options.itemNodeName)
				if action is 'collapse'
					$this.collapseItem item
				if action is 'expand'
					$this.expandItem item
				if action is 'toggle'
					$this.toggleItem item
				return

			onStartEvent = (e)->
				handle = _c.$(e.target)
				if ! handle.hasClass($this.options.handleClass)
					if handle.closest('.' + $this.options.noDragClass).length
						return
					handle = handle.closest('.' + $this.options.handleClass)
				if ! handle.length or $this.dragEl or ! hasTouch and e.button isnt 0 or hasTouch and e.touches.length isnt 1
					return
				e.preventDefault()
				$this.dragStart if hasTouch then e.touches[0] else e
				$this.trigger 'start.uk.nestable', [ $this ]
				return

			onMoveEvent = (e)->
				if $this.dragEl
					e.preventDefault()
					$this.dragMove if hasTouch then e.touches[0] else e
					$this.trigger 'move.uk.nestable', [ $this ]

			onEndEvent = (e)->
				if $this.dragEl
					e.preventDefault()
					$this.dragStop if hasTouch then e.touches[0] else e
				draggingElement = false
				return

			if hasTouch
				@element[0].addEventListener eStart, onStartEvent, false
				window.addEventListener eMove, onMoveEvent, false
				window.addEventListener eEnd, onEndEvent, false
				window.addEventListener eCancel, onEndEvent, false
			else
				@on eStart, onStartEvent
				$win.on eMove, onMoveEvent
				$win.on eEnd, onEndEvent

		serialize : ->
			data = undefined
			depth = 0
			list = this

			step = (level, depth)->
				array = []
				items = level.children(list.options.itemNodeName)
				items.each ->
					li = _c.$(@)
					item = {}
					attribute = undefined
					sub = li.children(list.options.listNodeName)
					i = 0
					while i < li[0].attributes.length
						attribute = li[0].attributes[i]
						if attribute.name.indexOf('data-') is 0
							item[attribute.name.substr(5)] = _c.utils.str2json(attribute.value)
						i++
					if sub.length
						item.children = step(sub, depth + 1)
					array.push item
				array

			data = step(list.element, depth)
			data

		list: (options)->
			data = []
			list = this
			depth = 0

			step = (level, depth, parent)->
				items = level.children(options.itemNodeName)
				items.each (index)->
					li = _c.$(@)
					item = _c.$.extend({
						parent_id: if parent then parent else null
						depth: depth
						order: index
					}, li.data())
					sub = li.children(options.listNodeName)
					data.push item
					if sub.length
						step sub, depth + 1, li.data(options.idProperty or 'id')

			options = _c.$.extend({}, list.options, options)
			step list.element, depth
			data

		reset: ->
			@mouse =
				offsetX : 0
				offsetY : 0
				startX : 0
				startY : 0
				lastX : 0
				lastY : 0
				nowX : 0
				nowY : 0
				distX : 0
				distY : 0
				dirAx : 0
				dirX : 0
				dirY : 0
				lastDirX : 0
				lastDirY : 0
				distAxX : 0
				distAxY : 0
			@moving = false
			@dragEl = null
			@dragRootEl = null
			@dragDepth = 0
			@hasNewRoot = false
			@pointEl = null
			i = 0
			while i < touchedlists.length
				@checkEmptyList touchedlists[i]
				i++
			touchedlists = []
			return

		toggleItem: (li)->
			@[if li.hasClass(@options.collapsedClass) then 'expandItem' else 'collapseItem'] li

		expandItem: (li)->
			li.removeClass @options.collapsedClass

		collapseItem: (li)->
			lists = li.children(@options.listNodeName)
			if lists.length
				li.addClass @options.collapsedClass

		expandAll: ->
			list = this
			@find(list.options.itemNodeName).each ->
				list.expandItem _c.$(@)

		collapseAll: ->
			list = this
			@find(list.options.itemNodeName).each ->
				list.collapseItem _c.$(@)

		setParent: (li)->
			if li.children(@options.listNodeName).length
				li.addClass 'parent'

		unsetParent: (li)->
			li.removeClass 'parent ' + @options.collapsedClass
			li.children(@options.listNodeName).remove()

		dragStart: (e)->
			mouse = @mouse
			target = _c.$(e.target)
			dragItem = target.closest(@options.itemNodeName)
			offset = dragItem.offset()
			@placeEl.css 'height', dragItem.height()
			mouse.offsetX = e.pageX - offset.left
			mouse.offsetY = e.pageY - offset.top
			mouse.startX = mouse.lastX = offset.left
			mouse.startY = mouse.lastY = offset.top
			@dragRootEl = @element
			@dragEl = _c.$(document.createElement(@options.listNodeName)).addClass(@options.listClass + ' ' + @options.dragClass)
			@dragEl.css 'width', dragItem.width()
			draggingElement = @dragEl
			@tmpDragOnSiblings = [
				dragItem[0].previousSibling
				dragItem[0].nextSibling
			]
			dragItem.after @placeEl
			dragItem[0].parentNode.removeChild dragItem[0]
			dragItem.appendTo @dragEl
			_c.$body.append @dragEl
			@dragEl.css
				left: offset.left
				top: offset.top
			i = undefined
			depth = undefined
			items = @dragEl.find(@options.itemNodeName)
			i = 0
			while i < items.length
				depth = _c.$(items[i]).parents(@options.listNodeName).length
				if depth > @dragDepth
					@dragDepth = depth
				i++
			html.addClass @options.movingClass

		dragStop: (e)->
			el = @dragEl.children(@options.itemNodeName).first()
			root = @placeEl.parents('.' + @options.listBaseClass + ':first')
			el[0].parentNode.removeChild el[0]
			@placeEl.replaceWith el
			@dragEl.remove()
			if @element[0] isnt root[0]
				root.trigger 'change.uk.nestable', [ el, 'added', root, root.data('nestable') ]
				@element.trigger 'change.uk.nestable', [ el, 'removed', @element, this ]
			else
				@element.trigger 'change.uk.nestable', [ el, 'moved', @element, this ]
			@trigger 'stop.uk.nestable', [ this, el ]
			@reset()
			html.removeClass @options.movingClass

		dragMove: (e)->
			list = undefined
			parent = undefined
			prev = undefined
			next = undefined
			depth = undefined
			opt = @options
			mouse = @mouse
			@dragEl.css
				left: e.pageX - mouse.offsetX
				top: e.pageY - mouse.offsetY
			mouse.lastX = mouse.nowX
			mouse.lastY = mouse.nowY
			mouse.nowX = e.pageX
			mouse.nowY = e.pageY
			mouse.distX = mouse.nowX - mouse.lastX
			mouse.distY = mouse.nowY - mouse.lastY
			mouse.lastDirX = mouse.dirX
			mouse.lastDirY = mouse.dirY
			mouse.dirX = if mouse.distX is 0 then 0 else if mouse.distX > 0 then 1 else -1
			mouse.dirY = if mouse.distY is 0 then 0 else if mouse.distY > 0 then 1 else -1
			newAx = if Math.abs(mouse.distX) > Math.abs(mouse.distY) then 1 else 0
			if ! mouse.moving
				mouse.dirAx = newAx
				mouse.moving = true
				return
			if mouse.dirAx isnt newAx
				mouse.distAxX = 0
				mouse.distAxY = 0
			else
				mouse.distAxX += Math.abs(mouse.distX)
				if mouse.dirX isnt 0 and mouse.dirX isnt mouse.lastDirX
					mouse.distAxX = 0
				mouse.distAxY += Math.abs(mouse.distY)
				if mouse.dirY isnt 0 and mouse.dirY isnt mouse.lastDirY
					mouse.distAxY = 0
			mouse.dirAx = newAx

			if mouse.dirAx and mouse.distAxX >= opt.threshold
				mouse.distAxX = 0
				prev = @placeEl.prev(opt.itemNodeName)
				if mouse.distX > 0 and prev.length and ! prev.hasClass(opt.collapsedClass)
					list = prev.find(opt.listNodeName).last()
					depth = @placeEl.parents(opt.listNodeName).length
					if depth + @dragDepth <= opt.maxDepth
						if ! list.length
							list = _c.$('<' + opt.listNodeName + '/>').addClass(opt.listClass)
							list.append @placeEl
							prev.append list
							@setParent prev
						else
							list = prev.children(opt.listNodeName).last()
							list.append @placeEl
				if mouse.distX < 0
					next = @placeEl.next(opt.itemNodeName)
					if ! next.length
						parent = @placeEl.parent()
						@placeEl.closest(opt.itemNodeName).after @placeEl
						if ! parent.children().length
							@unsetParent parent.parent()
			isEmpty = false
			if ! hasPointerEvents
				@dragEl[0].style.visibility = 'hidden'
			@pointEl = _c.$(document.elementFromPoint(e.pageX - document.body.scrollLeft, e.pageY - (window.pageYOffset or document.documentElement.scrollTop)))
			if ! hasPointerEvents
				@dragEl[0].style.visibility = 'visible'
			if @pointEl.hasClass(opt.handleClass)
				@pointEl = @pointEl.closest(opt.itemNodeName)
			else
				nestableitem = @pointEl.closest('.' + opt.itemClass)
				if nestableitem.length
					@pointEl = nestableitem.closest(opt.itemNodeName)
			if @pointEl.hasClass(opt.emptyClass)
				isEmpty = true
			else if @pointEl.data('nestable') and ! @pointEl.children().length
				isEmpty = true
				@pointEl = _c.$(@tplempty).appendTo(@pointEl)
			else if ! @pointEl.length or ! @pointEl.hasClass(opt.listitemClass)
				return
			pointElRoot = @element
			tmpRoot = @pointEl.closest('.' + @options.listBaseClass)
			isNewRoot = pointElRoot[0] isnt @pointEl.closest('.' + @options.listBaseClass)[0]

			if ! mouse.dirAx or isNewRoot or isEmpty
				if isNewRoot and opt.group isnt tmpRoot.data('nestable-group')
					return
				else
					touchedlists.push pointElRoot
				depth = @dragDepth - 1 + @pointEl.parents(opt.listNodeName).length
				if depth > opt.maxDepth
					return
				before = e.pageY < @pointEl.offset().top + @pointEl.height() / 2
				parent = @placeEl.parent()
				if isEmpty
					@pointEl.replaceWith @placeEl
				else if before
					@pointEl.before @placeEl
				else
					@pointEl.after @placeEl
				if ! parent.children().length
					if ! parent.data 'clique.data.nestable'
						@unsetParent parent.parent()
				@checkEmptyList @dragRootEl
				@checkEmptyList pointElRoot
				if isNewRoot
					@dragRootEl = tmpRoot
					@hasNewRoot = @element[0] isnt @dragRootEl[0]
					return

		checkEmptyList: (list)->
			list = if list then _c.$(list) else @element
			if ! list.children().length
				list.find('.' + @options.emptyClass).remove().end().append @tplempty

	_c.nestable
