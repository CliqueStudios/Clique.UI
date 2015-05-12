
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-upload', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.upload requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	xhrupload = (files, settings)->

		upload = (files, settings)->

			formData = new FormData()
			xhr = new XMLHttpRequest()
			if settings.before(settings, files) is false
				return
			for file in files
				formData.append settings.params, file
			for i, param of settings.params
				formData.append i, param
			xhr.upload.addEventListener 'progress', (e)->
				percent = e.loaded / e.total * 100
				settings.progress percent, e
			, false
			xhr.addEventListener 'loadstart', (e)->
				settings.loadstart e
			, false
			xhr.addEventListener 'load', (e)->
				settings.load e
			, false
			xhr.addEventListener 'loadend', (e)->
				settings.loadend e
			, false
			xhr.addEventListener 'error', (e)->
				settings.error e
			, false
			xhr.addEventListener 'abort', (e)->
				settings.abort e
			, false
			xhr.open settings.method, settings.action, true
			xhr.onreadystatechange = ->
				settings.readystatechange xhr
				if xhr.readyState is 4
					response = xhr.responseText
					if settings.type is 'json'
						try
							response = _c.$.parseJSON(response)
						catch e
							response = false
					settings.complete response, xhr

			settings.beforeSend xhr
			xhr.send formData
		unless _c.support.ajaxupload
			return @
		settings = _c.$.extend({}, xhrupload.defaults, settings)
		unless files.length
			return
		if settings.allow isnt '*.*'
			for file in files
				unless matchName(settings.allow, file.name)
					if typeof settings.notallowed is 'string'
						alert settings.notallowed
					else
						settings.notallowed file, settings
		complete = settings.complete
		if settings.single
			count = files.length
			uploaded = 0
			allow = true
			settings.beforeAll files
			settings.complete = (response, xhr)->
				uploaded = uploaded + 1
				complete response, xhr
				allow = false	if settings.filelimit and uploaded >= settings.filelimit
				if allow and uploaded < count
					upload [files[uploaded]], settings
				else
					settings.allcomplete response, xhr

			upload [files[0]], settings
		else
			settings.complete = (response, xhr)->
				complete response, xhr
				settings.allcomplete response, xhr

			upload files, settings

	matchName = (pattern, path)->
		parsedPattern = '^' + pattern.replace(/\//g, '\\/').replace(/\*\*/g, '(\\/[^\\/]+)*').replace(/\*/g, '[^\\/]+').replace(/((?!\\))\?/g, '$1.') + '$'
		parsedPattern = '^' + parsedPattern + '$'
		path.match(new RegExp(parsedPattern, 'i')) isnt null

	_c.component 'uploadSelect',
		init : ->
			$this = @
			@on 'change', ->
				xhrupload $this.element[0].files, $this.options
				twin = $this.element.clone(true).data('uploadSelect', $this)
				$this.element.replaceWith twin
				$this.element = twin
				return

	_c.component 'uploadDrop',
		defaults :
			dragoverClass : 'dragover'

		init : ->
			$this = @
			hasdragCls = false
			@on('drop', (e)->
				if e.dataTransfer and e.dataTransfer.files
					e.stopPropagation()
					e.preventDefault()
					$this.element.removeClass $this.options.dragoverClass
					$this.element.trigger 'dropped.clique.upload', [e.dataTransfer.files]
					xhrupload e.dataTransfer.files, $this.options
			).on('dragenter', (e)->
				e.stopPropagation()
				e.preventDefault()
			).on('dragover', (e)->
				e.stopPropagation()
				e.preventDefault()
				unless hasdragCls
					$this.element.addClass $this.options.dragoverClass
					hasdragCls = true
					return
			).on 'dragleave', (e)->
				e.stopPropagation()
				e.preventDefault()
				$this.element.removeClass $this.options.dragoverClass
				hasdragCls = false
				return

	_c.support.ajaxupload = do->
		supportFileAPI = ->
			fi = document.createElement('INPUT')
			fi.type = 'file'
			'files' of fi
		supportAjaxUploadProgressEvents = ->
			xhr = new XMLHttpRequest()
			!!(xhr and 'upload' of xhr and 'onprogress' of xhr.upload)
		supportFormData = ->
			!!window.FormData
		supportFileAPI() and supportAjaxUploadProgressEvents() and supportFormData()

	if _c.support.ajaxupload
		_c.$.event.props.push 'dataTransfer'
	xhrupload.defaults =
		action : ''
		single : true
		method : 'POST'
		param : 'files[]'
		params : {}
		allow : '*.*'
		type : 'text'
		filelimit : false
		before : (o)->
		beforeSend : (xhr)->
		beforeAll : ->
		loadstart : ->
		load : ->
		loadend : ->
		error : ->
		abort : ->
		progress : ->
		complete : ->
		allcomplete : ->
		readystatechange : ->
		notallowed : (file, settings)->
			alert 'Only the following file types are allowed : ' + settings.allow

	_c.utils.xhrupload = xhrupload
	xhrupload

