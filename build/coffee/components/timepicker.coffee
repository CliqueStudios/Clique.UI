
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-timepicker', ['clique'], ->
			return addon(Clique)

	if ! window.Clique or ! window.Clique.autocomplete
		throw new Error('Clique.timepicker requires Clique.core and Clique.autocomplete')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	times =
		'12h': []
		'24h': []

	i = 0
	h = ''

	while i < 24
		h = '' + i
		h = '0' + h	if i < 10
		times['24h'].push value: h + ':00'
		times['24h'].push value: h + ':30'
		if i > 0 and i < 13
			times['12h'].push value: h + ':00 AM'
			times['12h'].push value: h + ':30 AM'
		if i > 12
			h = h - 12
			h = '0' + String(h)	if h < 10
			times['12h'].push value: h + ':00 PM'
			times['12h'].push value: h + ':30 PM'
		i++

	_c.component 'timepicker',
		defaults:
			format: '24h'
			delay: 0

		boot : ->
			_c.$html.on 'focus.timepicker.clique', '[data-timepicker]', (e)->
				ele = _c.$(@)
				unless ele.data('clique.data.timepicker')
					obj = _c.timepicker ele, _c.utils.options(ele.attr('data-timepicker'))
					setTimeout (->
						obj.autocomplete.input.focus()
					), 40

		init : ->
			$this = @
			@options.minLength = 0
			@options.template = '<ul class="nav nav-autocomplete autocomplete-results">{{~items}}<li data-value="{{$item.value}}"><a>{{$item.value}}</a></li>{{/items}}</ul>'
			@options.source = (release)->
				release times[$this.options.format] or times['12h']

			@element.wrap '<div class="autocomplete"></div>'
			@autocomplete = _c.autocomplete(@element.parent(), @options)
			@autocomplete.dropdown.addClass 'dropdown-small dropdown-scrollable'
			@autocomplete.on 'show.clique.autocomplete', ->
				selected = $this.autocomplete.dropdown.find('[data-value="' + $this.autocomplete.input.val() + '"]')
				setTimeout (->
					$this.autocomplete.pick selected, true
				), 10

			@autocomplete.input.on
				focus : ->
					$this.autocomplete.value = Math.random()
					$this.autocomplete.triggercomplete()
				blur : ->
					$this.checkTime()

			@element.data 'timepicker', this

		checkTime : ->
			arr = null
			timeArray = null
			meridian = 'AM'
			hour = null
			minute = null
			time = @autocomplete.input.val()
			if @options.format is '12h'
				arr = time.split(' ')
				timeArray = arr[0].split(':')
				meridian = arr[1]
			else
				timeArray = time.split(':')
			hour = parseInt(timeArray[0], 10)
			minute = parseInt(timeArray[1], 10)
			if isNaN(hour)
				hour = 0
			if isNaN(minute)
				minute = 0
			if @options.format is '12h'
				if hour > 12
					hour = 12
				else
					if hour < 0
						hour = 12
				if meridian is 'am' or meridian is 'a'
					meridian = 'AM'
				else
					if meridian is 'pm' or meridian is 'p'
						meridian = 'PM'
				if meridian isnt 'AM' and meridian isnt 'PM'
					meridian = 'AM'
			else
				if hour >= 24
					hour = 23
				else
					if hour < 0
						hour = 0
			if minute < 0
				minute = 0
			else
				if minute >= 60
					minute = 0
			@autocomplete.input.val(@formatTime(hour, minute, meridian)).trigger 'change'

		formatTime : (hour, minute, meridian)->
			hour = if hour < 10 then '0' + hour else hour
			minute = if minute < 10 then '0' + minute else minute
			hour + ':' + minute + (if @options.format is '12h' then ' ' + meridian else '')
