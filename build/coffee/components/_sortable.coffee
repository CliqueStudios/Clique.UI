((addon)->
	component = addon(Clique)	if window.Clique
	if typeof define is 'function' and define.amd
		define 'clique-sortable', ['clique'], ->
			component or addon(Clique)
	return
) (_c)->

	supportsTouch = 'ontouchstart' of window or window.DocumentTouch and document instanceof DocumentTouch
	draggingPlaceholder = undefined
	moving = undefined
	dragging = undefined
	clickedlink = undefined
	delayIdle = undefined
	supportsDragAndDrop = false

	_c.component 'sortable',

		defaults:
			warp : false,
			animation : 150,
			threshold : 10,
			childClass : 'sortable-item',
			placeholderClass : 'sortable-placeholder',
			overClass : 'sortable-over',
			draggingClass : 'sortable-dragged',
			dragMovingClass : 'sortable-moving',
			dragCustomClass : '',
			handleClass : false,
			stop : ->
			start : ->
			change : ->

		boot: ->
			_c.ready (context)->
				_c.$("[data-sortable]", context).each ->
					ele = _c.$(@)
					if ! ele.data 'clique.data.sortable'
						obj = _c.sortable ele, _c.utils.options(ele.attr("data-sortable"))
						return
				return

			_c.$html.on 'mousemove touchmove', (e)->
				if delayIdle
					src = if e.originalEvent.targetTouches then e.originalEvent.targetTouches[0] else e
					if Math.abs(src.pageX - delayIdle.pos.x) > delayIdle.threshold or Math.abs(src.pageY - delayIdle.pos.y) > delayIdle.threshold
						delayIdle.apply()
				if draggingPlaceholder
					if ! moving
						moving = true
						draggingPlaceholder.show()
						draggingPlaceholder.$current.addClass draggingPlaceholder.$sortable.options.placeholderClass
						draggingPlaceholder.$sortable.element.children().addClass draggingPlaceholder.$sortable.options.childClass
						_c.$html.addClass draggingPlaceholder.$sortable.options.dragMovingClass
					offset = draggingPlaceholder.data('mouse-offset')
					left = parseInt(e.originalEvent.pageX, 10) + offset.left
					top = parseInt(e.originalEvent.pageY, 10) + offset.top
					draggingPlaceholder.css
						left : left
						top : top

					if top < _c.$win.scrollTop()
						_c.$win.scrollTop(_c.$win.scrollTop() - Math.ceil(draggingPlaceholder.height() / 2))
						return
					else if (top + draggingPlaceholder.height()) > (window.innerHeight + _c.$win.scrollTop())
						_c.$win.scrollTop(_c.$win.scrollTop() + Math.ceil(draggingPlaceholder.height() / 2))
						return

			_c.$html.on 'mouseup touchend', ->
				if ! moving and clickedlink
					location.href = clickedlink.attr('href');
				delayIdle = clickedlink = false
				return
			return

		init : ->
			$this = this
			element = this.element[0]
			currentlyDraggingElement = null
			currentlyDraggingTarget = null
			children = []

			Object.keys(this.options).forEach (key)->
				if String($this.options[key]).indexOf('Class') isnt -1
					$this.options[key] = $this.options[key];
					return

			if supportsDragAndDrop
				this.element
					.children()
					.attr "draggable", "true"
			else
				### prevent leaving page after link clicking ###
				### prevent leaving page after link clicking ###
				this.element
					.on 'mousedown touchstart', 'a[href]', (e)->
						### don't break browser shortcuts for click + open in new tab ###
						if ! e.ctrlKey and ! e.metaKey and ! e.shiftKey
							clickedlink = _c.$(this)
							e.preventDefault()
							return
					.on 'click', 'a[href]', (e)->
						if ! e.ctrlKey and ! e.metaKey and ! e.shiftKey
							clickedlink = _c.$(this)
							e.stopImmediatePropagation()
							return false

			handleDragStart = delegate (e)->
				moving = false
				dragging = false
				target = _c.$(e.target)
				children = $this.element.children()
				if ! supportsTouch and e.button is 2
					return;
				if $this.options.handleClass
					handle = if target.hasClass($this.options.handleClass) then target else target.closest('.' + $this.options.handleClass, element)
					if ! handle.length
						### e.preventDefault(); ###
						return;
				### prevent dragging if taget is a form field ###
				if target.is(':input')
					return;
				if e.dataTransfer
					e.dataTransfer.effectAllowed = 'move'
					e.dataTransfer.dropEffect = 'move'
					### Need to set to something or else drag doesn't start ###
					e.dataTransfer.setData('Text', "*")
				currentlyDraggingElement = this
				### init drag placeholder ###
				if draggingPlaceholder
					draggingPlaceholder.remove()
				$current = _c.$(currentlyDraggingElement)
				offset = $current.offset()
				delayIdle =
					pos :
						x : e.pageX
						y : e.pageY
					threshold : $this.options.threshold
					apply : ->
						draggingPlaceholder = _c.$('<div class="' + ([$this.options.draggingClass, $this.options.dragCustomClass].join(' ')) + '"></div>')
							.css
								display : 'none'
								top : offset.top
								left : offset.left
								width : $current.width()
								height : $current.height()
								padding : $current.css('padding')
							.data 'mouse-offset',
								'left': offset.left - parseInt(e.pageX, 10)
								'top': offset.top - parseInt(e.pageY, 10)
							.append $current.html()
							.appendTo 'body'
						draggingPlaceholder.$current = $current
						draggingPlaceholder.$sortable = $this
						addFakeDragHandlers()
						$this.options.start(this, currentlyDraggingElement)
						$this.trigger('start.clique.sortable', [$this, currentlyDraggingElement])
						delayIdle = false
						return
				if ! supportsDragAndDrop
					e.preventDefault();
					return

			handleDragOver = delegate (e)->
				if ! currentlyDraggingElement
					return true
				if e.preventDefault
					e.preventDefault()
				return false

			handleDragEnter = delegate _c.utils.debounce((e)->
				if ! currentlyDraggingElement or currentlyDraggingElement is this
					return true
				### Prevent dragenter on a child from allowing a dragleave on the container ###
				previousCounter = $this.dragenterData(this);
				$this.dragenterData(this, previousCounter + 1);
				if previousCounter is 0
					_c.$(this).addClass($this.options.overClass);
					if ! $this.options.warp
						$this.moveElementNextTo(currentlyDraggingElement, this);
				return false;
			), 40

			handleDragLeave = delegate (e)->
				### Prevent dragenter on a child from allowing a dragleave on the container ###
				previousCounter = $this.dragenterData this
				$this.dragenterData this, previousCounter - 1
				### This is a fix for child elements firing dragenter before the parent fires dragleave ###
				if ! $this.dragenterData(this)
					_c.$(this).removeClass $this.options.overClass
					$this.dragenterData this, false
					return

			handleDrop = delegate (e)->
				if e.type is 'drop'
					if e.stopPropagation
						e.stopPropagation();
					if e.preventDefault
						e.preventDefault();
				if ! dragging and ! $this.options.warp
					return;
				if $this.options.warp
					thisSibling = currentlyDraggingElement.nextSibling;
					this.parentNode.insertBefore(currentlyDraggingElement, this);
					this.parentNode.insertBefore(this, thisSibling);
					_c.utils.checkDisplay($this.element.parent());
				$this.options.change(this, currentlyDraggingElement);
				$this.trigger('change.clique.sortable', [$this, currentlyDraggingElement]);
				return

			handleDragEnd = (e)->
				currentlyDraggingElement = null
				currentlyDraggingTarget = null
				$this.element
					.children()
					.each ->
						if this.nodeType is 1
							_c.$(this)
								.removeClass $this.options.overClass
								.removeClass $this.options.placeholderClass
								.removeClass $this.options.childClass
							$this.dragenterData this, false
							return

				_c.$('html').removeClass $this.options.dragMovingClass
				removeFakeDragHandlers()
				$this.options.stop this
				$this.trigger 'stop.clique.sortable', [$this]
				draggingPlaceholder.remove()
				draggingPlaceholder = null
				return

			handleTouchMove = delegate (e)->
				if ! currentlyDraggingElement or currentlyDraggingElement is this or currentlyDraggingTarget is this
					return true
				$this.element.children().removeClass($this.options.overClass)
				currentlyDraggingTarget = this
				if !$this.options.warp
					$this.moveElementNextTo(currentlyDraggingElement, this)
				else
					_c.$(this).addClass($this.options.overClass)
				return prevent(e)

			# delegate = (fn)->
			# 	(e)->
			# 		touch = (supportsTouch and e.touches and e.touches[0]) or {}
			# 		target = touch.target or e.target
			# 		### Fix event.target for a touch event ###
			# 		if supportsTouch and document.elementFromPoint
			# 			target = document.elementFromPoint(e.pageX - document.body.scrollLeft, e.pageY - document.body.scrollTop)
			# 		if _c.$(target).hasClass $this.options.childClass
			# 			fn.apply target, [e]
			# 			return
			# 		else if target isnt element
			# 			### If a child is initiating the event or ending it, then use the container as context for the callback. ###
			# 			context = moveUpToChildNode element, target
			# 			if context
			# 				fn.apply context, [e]
			# 				return
			`function delegate(fn) {
				return function(e) {
					var touch = (supportsTouch && e.touches && e.touches[0]) || {},
					target = touch.target || e.target;
					/* Fix event.target for a touch event */
					if (supportsTouch && document.elementFromPoint) {
						target = document.elementFromPoint(e.pageX - document.body.scrollLeft, e.pageY - document.body.scrollTop);
					}
					if (_c.$(target).hasClass($this.options.childClass)) {
						fn.apply(target, [e]);
					} else if (target !== element) {
						/* If a child is initiating the event or ending it, then use the container as context for the callback. */
						var context = moveUpToChildNode(element, target);
						if (context) {
							fn.apply(context, [e]);
						}
					}
				};
			}`

			### Opera and mobile devices do not support drag and drop.  http://caniuse.com/dragndrop ###
			### Bind/unbind standard mouse/touch events as a polyfill. ###

			addFakeDragHandlers = ->
				if ! supportsDragAndDrop
					if supportsTouch
						element.addEventListener "touchmove", handleTouchMove, false
					else
						element.addEventListener 'mouseover', handleDragEnter, false
						element.addEventListener 'mouseout', handleDragLeave, false
					element.addEventListener (if supportsTouch then 'touchend' else 'mouseup'), handleDrop, false
					document.addEventListener (if supportsTouch then 'touchend' else 'mouseup'), handleDragEnd, false
					document.addEventListener "selectstart", prevent, false
					return

			removeFakeDragHandlers = ->
				if ! supportsDragAndDrop
					if supportsTouch
						element.removeEventListener "touchmove", handleTouchMove, false
					else
						element.removeEventListener 'mouseover', handleDragEnter, false
						element.removeEventListener 'mouseout', handleDragLeave, false
					element.removeEventListener (if supportsTouch then 'touchend' else 'mouseup'), handleDrop, false
					document.removeEventListener (if supportsTouch then 'touchend' else 'mouseup'), handleDragEnd, false
					document.removeEventListener "selectstart", prevent, false
					return

			if supportsDragAndDrop
				element.addEventListener 'dragstart', handleDragStart, false
				element.addEventListener 'dragenter', handleDragEnter, false
				element.addEventListener 'dragleave', handleDragLeave, false
				element.addEventListener 'drop', handleDrop, false
				element.addEventListener 'dragover', handleDragOver, false
				element.addEventListener 'dragend', handleDragEnd, false
			else
				element.addEventListener (if supportsTouch then 'touchstart' else 'mousedown'), handleDragStart, false
			return

		dragenterData : (element, val)->
			element = _c.$(element);
			if arguments.length is 1
				return parseInt element.attr('data-child-dragenter'), 10 or 0;
			else if ! val
				element.removeAttr 'data-child-dragenter'
				return
			else
				element.attr 'data-child-dragenter', Math.max(0, val)
				return

		moveElementNextTo : (element, elementToMoveNextTo)->
			dragging = true
			$this = this
			list = _c.$(element).parent().css('min-height', '')
			next = if isBelow(element, elementToMoveNextTo) then elementToMoveNextTo else elementToMoveNextTo.nextSibling
			children = list.children()
			count = children.length
			if $this.options.warp or ! $this.options.animation
				elementToMoveNextTo.parentNode.insertBefore(element, next);
				_c.utils.checkDisplay($this.element.parent())
				return
			list.css 'min-height', list.height()
			children
				.stop()
				.each ->
					ele = _c.$(this)
					offset = ele.position()
					offset.width = ele.width()
					ele.data 'offset-before', offset
					return

			elementToMoveNextTo.parentNode.insertBefore(element, next);
			_c.utils.checkDisplay $this.element.parent()
			children = list
				.children()
				.each ->
					ele = _c.$(this)
					ele.data('offset-after', ele.position())
					return
				.each ->
					ele = _c.$(this)
					before = ele.data('offset-before')
					ele.css
						'position' : 'absolute'
						'top' : before.top
						'left' : before.left
						'min-width' : before.width
					return

			children.each ->
				ele = _c.$(this)
				before = ele.data('offset-before')
				offset = ele.data('offset-after')
				ele.css('pointer-events', 'none').width()
				setTimeout ->
					ele
						.animate
							'top': offset.top,
							'left': offset.left
						, $this.options.animation, ->
							ele
								.css
									'position' : '',
									'top' : '',
									'left' : '',
									'min-width' : '',
									'pointer-events' : ''
								.removeClass($this.options.overClass)
								.attr('data-child-dragenter', '')
								count--
								if ! count
									list.css('min-height', '')
									_c.utils.checkDisplay $this.element.parent()
									return
				, 0
				return
			return

		serialize : ->
			data = []
			item = null
			attribute = null
			this.element
				.children()
				.each (j, child)->
					item = {}
					for attribute in attributes
						if attribute.name.indexOf('data-') is 0
							item[attribute.name.substr(5)] = _c.utils.str2json(attribute.value);
					data.push item
					return
			data

	### helpers ###
	isBelow = (el1, el2)->
		parent = el1.parentNode
		if el2.parentNode isnt parent
			return false
		cur = el1.previousSibling
		while cur and cur.nodeType isnt 9
			if cur is el2
				return true
			cur = cur.previousSibling
		return false

	moveUpToChildNode = (parent, child)->
		cur = child
		if cur is parent
			return null
		while cur
			if cur.parentNode is parent
				return cur
			cur = cur.parentNode;
			if ! cur or ! cur.ownerDocument or cur.nodeType is 11
				break
		null

	prevent = (e)->
		if e.stopPropagation
			e.stopPropagation()
		if e.preventDefault
			e.preventDefault()
		e.returnValue = false

	return _c.sortable;
