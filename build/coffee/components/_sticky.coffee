((addon)->
  component = undefined
  if window.UIkit
    component = addon(UIkit)
  if typeof define == 'function' and define.amd
    define 'clique-sticky', [ 'clique' ], ->
      component or addon(UIkit)
  return
) (UI)->

  checkscrollposition = ->
    stickies = if arguments.length then arguments else sticked
    if !stickies.length or $win.scrollTop() < 0
      return
    scrollTop = $win.scrollTop()
    documentHeight = $doc.height()
    windowHeight = $win.height()
    dwh = documentHeight - windowHeight
    extra = if scrollTop > dwh then dwh - scrollTop else 0
    newTop = undefined
    containerBottom = undefined
    stickyHeight = undefined
    sticky = undefined
    i = 0
    while i < stickies.length
      sticky = stickies[i]
      if !sticky.element.is(':visible') or sticky.animate
                i++
        continue
      if !sticky.check()
        if sticky.currentTop != null
          sticky.reset()
      else
        if sticky.options.top < 0
          newTop = 0
        else
          stickyHeight = sticky.element.outerHeight()
          newTop = documentHeight - stickyHeight - sticky.options.top - sticky.options.bottom - scrollTop - extra
          newTop = if newTop < 0 then newTop + sticky.options.top else sticky.options.top
        if sticky.boundary and sticky.boundary.length
          bTop = sticky.boundary.position().top
          if sticky.boundtoparent
            containerBottom = documentHeight - bTop + sticky.boundary.outerHeight() + parseInt(sticky.boundary.css('padding-bottom'))
          else
            containerBottom = documentHeight - bTop - parseInt(sticky.boundary.css('margin-top'))
          newTop = if scrollTop + stickyHeight > documentHeight - containerBottom - (if sticky.options.top < 0 then 0 else sticky.options.top) then documentHeight - containerBottom - scrollTop + stickyHeight else newTop
        if sticky.currentTop != newTop
          sticky.element.css
            'position': 'fixed'
            'top': newTop
            'width': if typeof sticky.getWidthFrom != 'undefined' then UI.$(sticky.getWidthFrom).width() else sticky.element.width()
            'left': sticky.wrapper.offset().left
          if !sticky.init
            sticky.element.addClass sticky.options.clsinit
            if location.hash and scrollTop > 0 and sticky.options.target
              $target = UI.$(location.hash)
              if $target.length
                setTimeout do ($target, sticky)->
                  ->
                    `var stickyHeight`
                    sticky.element.width()
                    # force redraw
                    offset = $target.offset()
                    maxoffset = offset.top + $target.outerHeight()
                    stickyOffset = sticky.element.offset()
                    stickyHeight = sticky.element.outerHeight()
                    stickyMaxOffset = stickyOffset.top + stickyHeight
                    if stickyOffset.top < maxoffset and offset.top < stickyMaxOffset
                      scrollTop = offset.top - stickyHeight - sticky.options.target
                      window.scrollTo 0, scrollTop
                    return
				, 0
          sticky.element.addClass sticky.options.clsactive
          sticky.element.css 'margin', ''
          if sticky.options.animation and sticky.init
            sticky.element.addClass sticky.options.animation
          sticky.currentTop = newTop
      sticky.init = true
      i++
    return

  'use strict'
  $win = UI.$win
  $doc = UI.$doc
  sticked = []
  UI.component 'sticky',
    defaults:
      top: 0
      bottom: 0
      animation: ''
      clsinit: 'uk-sticky-init'
      clsactive: 'uk-active'
      getWidthFrom: ''
      boundary: false
      media: false
      target: false
      disabled: false
    boot: ->
      # should be more efficient than using $win.scroll(checkscrollposition):
      UI.$doc.on 'scrolling.uk.document', ->
        checkscrollposition()
        return
      UI.$win.on 'resize orientationchange', UI.Utils.debounce((->
        if !sticked.length
          return
        i = 0
        while i < sticked.length
          sticked[i].reset true
          sticked[i].self.computeWrapper()
          i++
        checkscrollposition()
        return
      ), 100)
      # init code
      UI.ready (context)->
        setTimeout (->
          UI.$('[data-uk-sticky]', context).each ->
            $ele = UI.$(this)
            if !$ele.data('sticky')
              UI.sticky $ele, UI.Utils.options($ele.attr('data-uk-sticky'))
            return
          checkscrollposition()
          return
        ), 0
        return
      return
    init: ->
      wrapper = UI.$('<div class="uk-sticky-placeholder"></div>')
      boundary = @options.boundary
      boundtoparent = undefined
      @wrapper = @element.css('margin', 0).wrap(wrapper).parent()
      @computeWrapper()
      if boundary
        if boundary == true
          boundary = @wrapper.parent()
          boundtoparent = true
        else if typeof boundary == 'string'
          boundary = UI.$(boundary)
      @sticky =
        self: this
        options: @options
        element: @element
        currentTop: null
        wrapper: @wrapper
        init: false
        getWidthFrom: @options.getWidthFrom or @wrapper
        boundary: boundary
        boundtoparent: boundtoparent
        reset: (force)->
          finalize = (->
            @element.css
              'position': ''
              'top': ''
              'width': ''
              'left': ''
              'margin': '0'
            @element.removeClass [
              @options.animation
              'uk-animation-reverse'
              @options.clsactive
            ].join(' ')
            @currentTop = null
            @animate = false
            return
          ).bind(this)
          if !force and @options.animation and UI.support.animation
            @animate = true
            @element.removeClass(@options.animation).one(UI.support.animation.end, ->
              finalize()
              return
            ).width()
            # force redraw
            @element.addClass @options.animation + ' ' + 'uk-animation-reverse'
          else
            finalize()
          return
        check: ->
          if @options.disabled
            return false
          if @options.media
            switch typeof @options.media
              when 'number'
                if window.innerWidth < @options.media
                  return false
              when 'string'
                if window.matchMedia and !window.matchMedia(@options.media).matches
                  return false
          scrollTop = $win.scrollTop()
          documentHeight = $doc.height()
          dwh = documentHeight - window.innerHeight
          extra = if scrollTop > dwh then dwh - scrollTop else 0
          elementTop = @wrapper.offset().top
          etse = elementTop - @options.top - extra
          scrollTop >= etse
      sticked.push @sticky
      return
    update: ->
      checkscrollposition @sticky
      return
    enable: ->
      @options.disabled = false
      @update()
      return
    disable: (force)->
      @options.disabled = true
      @sticky.reset force
      return
    computeWrapper: ->
      @wrapper.css
        'height': if @element.css('position') != 'absolute' then @element.outerHeight() else ''
        'float': if @element.css('float') != 'none' then @element.css('float') else ''
        'margin': @element.css('margin')
      return
  UI.sticky

# ---
# generated by js2coffee 2.0.3
