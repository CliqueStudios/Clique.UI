
do($ = jQuery)->

	touch = {}
	touchTimeout = null
	tapTimeout = null
	swipeTimeout = null
	longTapTimeout = null
	gesture = null
	longTapDelay = 750

	swipeDirection = (x1, x2, y1, y2)->
		if Math.abs(x1 - x2) >= Math.abs(y1 - y2) then (if x1 - x2 > 0 then 'Left' else 'Right') else (if y1 - y2 > 0 then 'Up' else 'Down')

	longTap = ->
		longTapTimeout = null
		if touch.last
			touch.el.trigger 'longTap'
			touch = {}
		return

	cancelLongTap = ->
		if longTapTimeout
			clearTimeout longTapTimeout
		longTapTimeout = null
		return

	cancelAll = ->
		if touchTimeout
			clearTimeout touchTimeout
		if tapTimeout
			clearTimeout tapTimeout
		if swipeTimeout
			clearTimeout swipeTimeout
		if longTapTimeout
			clearTimeout longTapTimeout
		touchTimeout = tapTimeout = swipeTimeout = longTapTimeout = null
		touch = {}
		return

	isPrimaryTouch = (event)->
		event.pointerType is event.MSPOINTER_TYPE_TOUCH and event.isPrimary

	if $.fn.swipeLeft
		return

	touch = {}
	longTapDelay = 750
	$ ->
		deltaX = 0
		deltaY = 0
		if 'MSGesture' of window
			gesture = new MSGesture()
			gesture.target = document.body
		$(document).on('MSGestureEnd gestureend', (e)->
			swipeDirectionFromVelocity = if e.originalEvent.velocityX > 1 then 'Right' else (if e.originalEvent.velocityX < -1 then 'Left' else (if e.originalEvent.velocityY > 1 then 'Down' else (if e.originalEvent.velocityY < -1 then 'Up' else null)))
			if swipeDirectionFromVelocity
				touch.el.trigger 'swipe'
				touch.el.trigger 'swipe' + swipeDirectionFromVelocity
			return
		).on('touchstart MSPointerDown pointerdown', (e)->
			if e.type is 'MSPointerDown' and not isPrimaryTouch(e.originalEvent)
				return
			firstTouch = if e.type is 'MSPointerDown' or e.type is 'pointerdown' then e else e.originalEvent.touches[0]
			now = Date.now()
			delta = now - (touch.last or now)
			touch.el = $((if 'tagName' of firstTouch.target then firstTouch.target else firstTouch.target.parentNode))
			if touchTimeout
				clearTimeout touchTimeout
			touch.x1 = firstTouch.pageX
			touch.y1 = firstTouch.pageY
			if delta > 0 and delta <= 250
				touch.isDoubleTap = true
			touch.last = now
			longTapTimeout = setTimeout(longTap, longTapDelay)
			if gesture and (e.type is 'MSPointerDown' or e.type is 'pointerdown' or e.type is 'touchstart')
				gesture.addPointer e.originalEvent.pointerId
			return
		).on('touchmove MSPointerMove pointermove', (e)->
			if e.type is 'MSPointerMove' and not isPrimaryTouch(e.originalEvent)
				return
			firstTouch = (if e.type is 'MSPointerMove' or e.type is 'pointermove' then e else e.originalEvent.touches[0])
			cancelLongTap()
			touch.x2 = firstTouch.pageX
			touch.y2 = firstTouch.pageY
			deltaX += Math.abs(touch.x1 - touch.x2)
			deltaY += Math.abs(touch.y1 - touch.y2)
			return
		).on('touchend MSPointerUp pointerup', (e)->
			if e.type is 'MSPointerUp' and not isPrimaryTouch(e.originalEvent)
				return
			cancelLongTap()
			if touch.x2 and Math.abs(touch.x1 - touch.x2) > 30 or touch.y2 and Math.abs(touch.y1 - touch.y2) > 30
				swipeTimeout = setTimeout ->
					touch.el.trigger 'swipe'
					touch.el.trigger 'swipe' + swipeDirection(touch.x1, touch.x2, touch.y1, touch.y2)
					touch = {}
					return
				, 0
			else
				if 'last' of touch
					if isNaN(deltaX) or deltaX < 30 and deltaY < 30
						tapTimeout = setTimeout ->
							event = $.Event('tap')
							event.cancelTouch = cancelAll
							touch.el.trigger event
							if touch.isDoubleTap
								touch.el.trigger 'doubleTap'
								touch = {}
							else
								touchTimeout = setTimeout ->
									touchTimeout = null
									touch.el.trigger 'singleTap'
									touch = {}
									return
								, 250
							return
						, 0
					else
						touch = {}
					deltaX = deltaY = 0
			return
		).on 'touchcancel MSPointerCancel', cancelAll
		$(window).on 'scroll', cancelAll
		return

	[
		'swipe'
		'swipeLeft'
		'swipeRight'
		'swipeUp'
		'swipeDown'
		'doubleTap'
		'tap'
		'singleTap'
		'longTap'
	].forEach (eventName)->
		$.fn[eventName] = (callback)->
			$(@).on eventName, callback
		return
	return

