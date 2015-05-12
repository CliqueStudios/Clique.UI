
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-lightbox', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.lightbox requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	modal = null

	cache = {}

	_c.component 'lightbox',

		defaults :
			group : false
			duration : 400
			keyboard : true

		index: 0

		items: false

		boot : ->
			_c.$html.on 'click', '[data-lightbox]', (e)->
				e.preventDefault()
				link = _c.$(@)
				unless link.data('clique.data.lightbox')
					_c.lightbox link, _c.utils.options(link.attr('data-lightbox'))
				link.data('clique.data.lightbox').show link

			_c.$doc.on 'keyup', (e)->
				if modal and modal.is(':visible') and modal.lightbox.options.keyboard
					e.preventDefault()
					switch e.keyCode
						when 37
							modal.lightbox.previous()
						when 39
							modal.lightbox.next()

		init : ->
			$this = @
			siblings = []
			@index = 0
			@siblings = []
			if @element and @element.length
				domSiblings = (if @options.group then _c.$([
					'[data-lightbox*="' + @options.group + '"]'
					'[data-lightbox*=\'' + @options.group + '\']'
				].join(',')) else @element)
				domSiblings.each ->
					ele = _c.$(@)
					siblings.push
						source : ele.attr('href')
						title : ele.attr('title')
						type : ele.attr('data-lightbox-type') or 'auto'
						link : ele
				@index = domSiblings.index(@element)
				@siblings = siblings
			else
				@siblings = @options.group	if @options.group and @options.group.length
			@trigger 'lightbox-init', [this]

		show : (index)->
			@modal = getModal(@)
			@modal.dialog.stop()
			@modal.content.stop()
			$this = @
			promise = _c.$.Deferred()
			data = null
			item = null
			index = index or 0
			if typeof index is 'object'
				@siblings.forEach (s, idx)->
					if index[0] is s.link[0]
						index = idx
						return
			if index < 0
				index = @siblings.length - index
			else
				unless @siblings[index]
					index = 0
			item = @siblings[index]
			data =
				lightbox : $this
				source : item.source
				type : item.type
				index : index
				promise : promise
				title : item.title
				item : item
				meta :
					content : ''
					width : null
					height : null
			@index = index
			@modal.content.empty()
			unless @modal.is(':visible')
				@modal.content
					.css
						width : ''
						height : ''
					.empty()
				@modal.modal.show()
			@modal.loader.removeClass 'hidden'
			promise
				.promise()
				.done ->
					$this.data = data
					$this.fitSize data
				.fail ->
					alert 'Loading resource failed!'
			$this.trigger 'showitem.clique.lightbox', [data]

		fitSize : ->
			$this = @
			data = @data
			pad = @modal.dialog.outerWidth() - @modal.dialog.width()
			dpadTop = parseInt(@modal.dialog.css('margin-top'), 10)
			dpadBot = parseInt(@modal.dialog.css('margin-bottom'), 10)
			dpad = dpadTop + dpadBot
			content = data.meta.content
			duration = $this.options.duration
			if @siblings.length > 1
				content = [ content, '<a href="#" class="slidenav slidenav-contrast slidenav-previous hidden-touch" data-lightbox-previous></a>', '<a href="#" class="slidenav slidenav-contrast slidenav-next hidden-touch" data-lightbox-next></a>' ].join('')
			tmp = _c.$('<div>&nbsp;</div>').css
				opacity: 0
				position: 'absolute'
				top: 0
				left: 0
				width: '100%'
				'max-width': $this.modal.dialog.css('max-width')
				padding: $this.modal.dialog.css('padding')
				margin: $this.modal.dialog.css('margin')

			maxwidth = null
			maxheight = null
			w = data.meta.width
			h = data.meta.height
			tmp.appendTo('body').width()
			maxwidth = tmp.width()
			maxheight = window.innerHeight - dpad
			tmp.remove()
			@modal.dialog.find('.modal-caption').remove()
			if data.title
				@modal.dialog.append '<div class="modal-caption">' + data.title + '</div>'
				maxheight -= @modal.dialog.find('.modal-caption').outerHeight()
			if maxwidth < data.meta.width
				h = Math.floor(h * (maxwidth / w))
				w = maxwidth
			if maxheight < h
				h = Math.floor(maxheight)
				w = Math.ceil(data.meta.width * (maxheight / data.meta.height))
			@modal.content.css('opacity', 0).width(w).html content
			@modal.content.find('iframe:first').height h	if data.type is 'iframe'
			dh = h + pad
			t = Math.floor(window.innerHeight / 2 - dh / 2) - dpad
			t = 0	if t < 0
			@modal.closer.addClass 'hidden'
			duration = 0	if $this.modal.data('mwidth') is w and $this.modal.data('mheight') is h
			@modal.dialog.animate
				width : w + pad
				height : h + pad
				top : t
			, duration, 'swing', ->
				$this.modal.loader.addClass 'hidden'
				$this.modal.content.css(width: '').animate
					opacity : 1
				, ->
					$this.modal.closer.removeClass 'hidden'
				$this.modal.data
					mwidth : w
					mheight : h

		next : ->
			@show (if @siblings[@index + 1] then @index + 1 else 0)

		previous : ->
			@show (if @siblings[@index - 1] then @index - 1 else @siblings.length - 1)

	_c.plugin 'lightbox', 'image',
		init : (lightbox)->
			lightbox.on 'showitem.clique.lightbox', (e, data)->
				if data.type is 'image' or data.source and data.source.match(/\.(jpg|jpeg|png|gif|svg)$/)
					resolve = (source, width, height)->
						data.meta =
							content : '<img class="responsive-width" width="' + width + '" height="' + height + '" src ="' + source + '">'
							width : width
							height : height
						data.type = 'image'
						data.promise.resolve()
					unless cache[data.source]
						img = new Image()
						img.onerror = ->
							data.promise.reject 'Loading image failed'
						img.onload = ->
							cache[data.source] =
								width : img.width
								height : img.height
							resolve data.source, cache[data.source].width, cache[data.source].height
						img.src = data.source
						return
					else
						resolve data.source, cache[data.source].width, cache[data.source].height

	_c.plugin 'lightbox', 'youtube',
		init : (lightbox)->
			youtubeRegExp = /(\/\/.*?youtube\.[a-z]+)\/watch\?v=([^&]+)&?(.*)/
			youtubeRegExpShort = /youtu\.be\/(.*)/
			lightbox.on 'showitem.clique.lightbox', (e, data)->
				id = null
				matches = null
				resolve = (id, width, height)->
					data.meta =
						content : '<iframe src="//www.youtube.com/embed/' + id + '" width="' + width + '" height="' + height + '" style="max-width:100%;"></iframe>'
						width : width
						height : height
					data.type = 'iframe'
					data.promise.resolve()
				matches = data.source.match(youtubeRegExp)
				if matches
					id = matches[2]
				if matches
					id = matches[1]
				if id
					unless cache[id]
						img = new Image()
						img.onerror = ->
							cache[id] =
								width : 640
								height : 320
							resolve id, cache[id].width, cache[id].height
						img.onload = ->
							cache[id] =
								width : img.width
								height : img.height
							resolve id, img.width, img.height
						img.src = '//img.youtube.com/vi/' + id + '/0.jpg'
					else
						resolve id, cache[id].width, cache[id].height
					e.stopImmediatePropagation()

	_c.plugin 'lightbox', 'vimeo',
		init : (lightbox)->
			regex = /(\/\/.*?)vimeo\.[a-z]+\/([0-9]+).*?/
			matches = null
			lightbox.on 'showitem.clique.lightbox', (e, data)->
				id = null
				resolve = (id, width, height)->
					data.meta =
						content : '<iframe src="//player.vimeo.com/video/' + id + '" width="' + width + '" height="' + height + '" style="width:100%;box-sizing:border-box;"></iframe>'
						width : width
						height : height
					data.type = 'iframe'
					data.promise.resolve()
				matches = data.source.match(regex)
				if matches
					id = matches[2]
					unless cache[id]
						_c.$.ajax
							type : 'GET'
							url : 'http://vimeo.com/api/oembed.json?url=' + encodeURI(data.source)
							jsonp : 'callback'
							dataType : 'jsonp'
							success : (data)->
								cache[id] =
									width: data.width
									height: data.height
								resolve id, cache[id].width, cache[id].height
					else
						resolve id, cache[id].width, cache[id].height
					e.stopImmediatePropagation()

	_c.plugin 'lightbox', 'video',
		init : (lightbox)->
			lightbox.on 'showitem.clique.lightbox', (e, data)->
				resolve = (source, width, height)->
					data.meta =
						content : '<video class="responsive-width" src="' + source + '" width="' + width + '" height="' + height + '" controls></video>'
						width : width
						height : height
					data.type = 'video'
					data.promise.resolve()
				if data.type is 'video' or data.source.match(/\.(mp4|webm|ogv)$/)
					unless cache[data.source]
						vid = _c.$('<video style="position:fixed;visibility:hidden;top:-10000px;"></video>').attr('src', data.source).appendTo('body')
						idle = setInterval ->
							if vid[0].videoWidth
								clearInterval idle
								cache[data.source] =
									width: vid[0].videoWidth
									height: vid[0].videoHeight

								resolve data.source, cache[data.source].width, cache[data.source].height
								vid.remove()
						, 20
						return
					else
						resolve data.source, cache[data.source].width, cache[data.source].height

	getModal = (lightbox)->
		if modal
			modal.lightbox = lightbox
			return modal
		modal = _c.$([
			'<div class="modal">'
			'<div class="modal-dialog modal-dialog-lightbox slidenav-position" style="margin-left:auto;margin-right:auto;width:200px;height:200px;top:' + Math.abs(window.innerHeight / 2 - 200) + 'px;">'
			'<a href="#" class="modal-close close close-alt"></a>'
			'<div class="lightbox-content"></div>'
			'<div class="modal-spinner hidden"></div>'
			'</div>'
			'</div>'
		].join('')).appendTo('body')
		modal.dialog = modal.find('.modal-dialog:first')
		modal.content = modal.find('.lightbox-content:first')
		modal.loader = modal.find('.modal-spinner:first')
		modal.closer = modal.find('.close.close-alt')
		modal.modal = _c.modal(modal)
		modal.on('swipeRight swipeLeft', (e)->
			modal.lightbox[(if e.type is 'swipeLeft' then 'next' else 'previous')]()
		).on 'click', '[data-lightbox-previous], [data-lightbox-next]', (e)->
			e.preventDefault()
			modal.lightbox[(if _c.$(@).is('[data-lightbox-next]') then 'next' else 'previous')]()
		modal.on 'hide.clique.modal', (e)->
			modal.content.html ''
		_c.$win.on 'load resize orientationchange', _c.utils.debounce =>
			if modal.is(':visible')
				modal.lightbox.fitSize()
		, 100
		modal.lightbox = lightbox
		modal

	_c.lightbox.create = (items, options)->
		unless items
			return
		group = []
		o = null
		items.forEach (item)->
			group.push _c.$.extend(
				source: ''
				title: ''
				type: 'auto'
				link: false
			, (if typeof item is 'string' then source: item else item))
		o = _c.lightbox _c.$.extend {}, options,
			group: group
		o

	_c.lightbox
