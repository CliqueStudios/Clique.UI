
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-datepicker', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.datepicker requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	active = false
	dropdown = null
	moment = null
	_c.component 'datepicker',
		defaults:
			mobile: false
			weekstart: 1
			i18n:
				months: [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ]
				weekdays: [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ]

			format: 'MM/DD/YYYY'
			offsettop: 5
			maxDate: false
			minDate: false
			template: (data, opts)->
				content = ''
				maxDate = null
				minDate = null
				i = null
				if opts.maxDate isnt false
					maxDate = if isNaN(opts.maxDate) then moment(opts.maxDate, opts.format) else moment().add(opts.maxDate, 'days')
				if opts.minDate isnt false
					minDate = if isNaN(opts.minDate) then moment(opts.minDate, opts.format) else moment().add(opts.minDate - 1, 'days')
				content += '<div class="datepicker-nav">'
				content += '<a href="" class="datepicker-previous"></a>'
				content += '<a href="" class="datepicker-next"></a>'
				if _c.formSelect
					currentyear = new Date().getFullYear()
					options = []
					months = null
					years = null
					minYear = null
					maxYear = null
					i = 0
					while i < opts.i18n.months.length
						if i is data.month
							options.push '<option value="' + i + '" selected>' + opts.i18n.months[i] + '</option>'
						else
							options.push '<option value="' + i + '">' + opts.i18n.months[i] + '</option>'
						i++
					months = '<span class="form-select">' + opts.i18n.months[data.month] + '<select class="update-picker-month">' + options.join('') + '</select></span>'
					options = []
					minYear = (if minDate then minDate.year() else currentyear - 50)
					maxYear = (if maxDate then maxDate.year() else currentyear + 20)
					i = minYear
					while i <= maxYear
						if i is data.year
							options.push '<option value="' + i + '" selected>' + i + '</option>'
						else
							options.push '<option value="' + i + '">' + i + '</option>'
						i++
					years = '<span class="form-select">' + data.year + '<select class="update-picker-year">' + options.join('') + '</select></span>'
					content += '<div class="datepicker-heading">' + months + ' ' + years + '</div>'
				else
					content += '<div class="datepicker-heading">' + opts.i18n.months[data.month] + ' ' + data.year + '</div>'
				content += '</div>'
				content += '<table class="datepicker-table">'
				content += '<thead>'
				i = 0
				while i < data.weekdays.length
					if data.weekdays[i]
						content += '<th>' + data.weekdays[i] + '</th>'
					i++
				content += '</thead>'
				content += '<tbody>'
				i = 0
				while i < data.days.length
					if data.days[i] and data.days[i].length
						content += '<tr>'
						d = 0

						while d < data.days[i].length
							if data.days[i][d]
								day = data.days[i][d]
								cls = []
								unless day.inmonth
									cls.push 'datepicker-table-muted'
								if day.selected
									cls.push 'active'
								if maxDate and day.day > maxDate
									cls.push 'datepicker-date-disabled datepicker-table-muted'
								if minDate and minDate > day.day
									cls.push 'datepicker-date-disabled datepicker-table-muted'
								content += '<td><a href="" class="' + cls.join(' ') + '" data-date="' + day.day.format() + '">' + day.day.format('D') + '</a></td>'
							d++
						content += '</tr>'
					i++
				content += '</tbody>'
				content += '</table>'
				content

		boot : ->
			_c.$win.on 'resize orientationchange', ->
				if active
					active.hide()

			_c.$html.on 'focus.datepicker.clique', '[data-datepicker]', (e)->
				ele = _c.$(@)
				unless ele.data('clique.data.datepicker')
					e.preventDefault()
					obj = _c.datepicker(ele, _c.utils.options(ele.attr('data-datepicker')))
					ele.trigger 'focus'

			_c.$html.on 'click.datepicker.clique', (e)->
				target = _c.$(e.target)
				if active and target[0] isnt dropdown[0] and not target.data('datepicker') and not target.parents('.datepicker:first').length
					active.hide()

		init : ->
			if _c.support.touch and @element.attr('type') is 'date' and not @options.mobile
				return
			$this = @
			@current = if @element.val() then moment(@element.val(), @options.format) else moment()
			@on
				click : ->
					if active isnt $this
						$this.pick @value
				change : ->
					if $this.element.val() and not moment($this.element.val(), $this.options.format).isValid()
						$this.element.val moment().format($this.options.format)
			unless dropdown
				dropdown = _c.$('<div class="dropdown datepicker"></div>')
				dropdown.on 'click', '.datepicker-next, .datepicker-previous, [data-date]', (e)->
					e.stopPropagation()
					e.preventDefault()
					ele = _c.$(@)
					if ele.hasClass('datepicker-date-disabled')
						return false
					if ele.is('[data-date]')
						active.element.val(moment(ele.data('date')).format(active.options.format)).trigger 'change'
						dropdown.hide()
						active = false
						return
					else
						active.add 1 * (if ele.hasClass('datepicker-next') then 1 else -1), 'months'
				dropdown.on 'change', '.update-picker-month, .update-picker-year', ->
					select = _c.$(@)
					active[(if select.is('.update-picker-year') then 'setYear' else 'setMonth')] Number(select.val())
				dropdown.appendTo 'body'

		pick : (initdate)->
			offset = @element.offset()
			css =
				top: offset.top + @element.outerHeight() + @options.offsettop
				left: offset.left
				right: ''
			@current = if initdate then moment(initdate, @options.format) else moment()
			@initdate = @current.format('YYYY-MM-DD')
			@update()
			if _c.langdirection is 'right'
				css.right = window.innerWidth - (css.left + @element.outerWidth())
				css.left = ''
			dropdown.css(css).show()
			@trigger 'show.clique.datepicker'
			active = this
			return

		add : (unit, value)->
			@current.add unit, value
			@update()

		setMonth : (month)->
			@current.month month
			@update()

		setYear : (year)->
			@current.year year
			@update()

		update : ->
			data = @getRows(@current.year(), @current.month())
			tpl = @options.template(data, @options)
			dropdown.html tpl
			@trigger 'update.clique.datepicker'

		getRows : (year, month)->
			opts = @options
			now = moment().format('YYYY-MM-DD')
			days = [ 31, (if year % 4 is 0 and year % 100 isnt 0 or year % 400 is 0 then 29 else 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ][month]
			before = new Date(year, month, 1).getDay()
			data =
				month : month
				year : year
				weekdays : []
				days : []
			row = []
			data.weekdays = do->
				i = 0
				arr = []
				while i < 7
					day = i + (opts.weekstart or 0)
					while day >= 7
						day -= 7
					arr.push opts.i18n.weekdays[day]
					i++
				arr
			if opts.weekstart and opts.weekstart > 0
				before -= opts.weekstart
				if before < 0
					before += 7
			cells = days + before
			after = cells
			while after > 7
				after -= 7
			cells += 7 - after
			day = null
			isDisabled = null
			isSelected = null
			isToday = null
			isInMonth = null
			i = 0
			r = 0
			while i < cells
				day = new Date(year, month, 1 + (i - before))
				isDisabled = opts.mindate and day < opts.mindate or opts.maxdate and day > opts.maxdate
				isInMonth = not (i < before or i >= days + before)
				day = moment(day)
				isSelected = @initdate is day.format('YYYY-MM-DD')
				isToday = now is day.format('YYYY-MM-DD')
				row.push
					selected: isSelected
					today: isToday
					disabled: isDisabled
					day: day
					inmonth: isInMonth
				if ++r is 7
					data.days.push row
					row = []
					r = 0
				i++
			data

		hide : ->
			if active and active is this
				dropdown.hide()
				active = false
				@trigger 'hide.clique.datepicker'

	moment = ((undefined_)->

		dfl = (a, b, c)->
			switch arguments.length
				when 2
					return if a? then a else b
					break
				when 3
					return if a? then a else (if b? then b else c)
					break
				else
					throw new Error('Implement me')

		hasOwnProp = (a, b)->
			hasOwnProperty.call a, b

		defaultParsingFlags = ->
				empty: false
				unusedTokens: []
				unusedInput: []
				overflow: -2
				charsLeftOver: 0
				nullInput: false
				invalidMonth: null
				invalidFormat: false
				userInvalidated: false
				iso: false

		printMsg = (msg)->
			if moment.suppressDeprecationWarnings is false and typeof console isnt 'undefined' and console.warn
				console.warn 'Deprecation warning: ' + msg

		deprecate = (msg, fn)->
			firstTime = true
			extend (->
				if firstTime
					printMsg msg
					firstTime = false
				fn.apply this, arguments
			), fn

		deprecateSimple = (name, msg)->
			unless deprecations[name]
				printMsg msg
				deprecations[name] = true
				return

		padToken = (func, count)->
			(a)->
				leftZeroFill func.call(this, a), count

		ordinalizeToken = (func, period)->
			(a)->
				@localeData().ordinal func.call(this, a), period

		Locale = ->

		Moment = (config, skipOverflow)->
			if skipOverflow isnt false
				checkOverflow config
			copyConfig this, config
			@_d = new Date(+config._d)
			return

		Duration = (duration)->
			normalizedInput = normalizeObjectUnits(duration)
			years = normalizedInput.year or 0
			quarters = normalizedInput.quarter or 0
			months = normalizedInput.month or 0
			weeks = normalizedInput.week or 0
			days = normalizedInput.day or 0
			hours = normalizedInput.hour or 0
			minutes = normalizedInput.minute or 0
			seconds = normalizedInput.second or 0
			milliseconds = normalizedInput.millisecond or 0
			@_milliseconds = +milliseconds + seconds * 1e3 + minutes * 6e4 + hours * 36e5
			@_days = +days + weeks * 7
			@_months = +months + quarters * 3 + years * 12
			@_data = {}
			@_locale = moment.localeData()
			@_bubble()

		extend = (a, b)->
			for i of b
				if hasOwnProp(b, i)
					a[i] = b[i]
			if hasOwnProp(b, 'toString')
				a.toString = b.toString
			if hasOwnProp(b, 'valueOf')
				a.valueOf = b.valueOf
			a

		copyConfig = (to, from)->
			i = null
			prop = null
			val = null
			if typeof from._isAMomentObject isnt 'undefined'
				to._isAMomentObject = from._isAMomentObject
			if typeof from._i isnt 'undefined'
				to._i = from._i
			if typeof from._f isnt 'undefined'
				to._f = from._f
			if typeof from._l isnt 'undefined'
				to._l = from._l
			if typeof from._strict isnt 'undefined'
				to._strict = from._strict
			if typeof from._tzm isnt 'undefined'
				to._tzm = from._tzm
			if typeof from._isUTC isnt 'undefined'
				to._isUTC = from._isUTC
			if typeof from._offset isnt 'undefined'
				to._offset = from._offset
			if typeof from._pf isnt 'undefined'
				to._pf = from._pf
			if typeof from._locale isnt 'undefined'
				to._locale = from._locale
			if momentProperties.length > 0
				for i of momentProperties
					prop = momentProperties[i]
					val = from[prop]
					if typeof val isnt 'undefined'
						to[prop] = val
			to

		absRound = (number)->
			if number < 0
				Math.ceil number
			else
				Math.floor number

		leftZeroFill = (number, targetLength, forceSign)->
			output = '' + Math.abs(number)
			sign = number >= 0
			while output.length < targetLength
				output = '0' + output
			(if sign then (if forceSign then '+' else '') else '-') + output

		positiveMomentsDifference = (base, other)->
			res =
				milliseconds: 0
				months: 0

			res.months = other.month() - base.month() + (other.year() - base.year()) * 12
			if base.clone().add(res.months, 'M').isAfter(other)
				--res.months
			res.milliseconds = +other - +base.clone().add(res.months, 'M')
			res

		momentsDifference = (base, other)->
			res = null
			other = makeAs(other, base)
			if base.isBefore(other)
				res = positiveMomentsDifference(base, other)
			else
				res = positiveMomentsDifference(other, base)
				res.milliseconds = -res.milliseconds
				res.months = -res.months
			res

		createAdder = (direction, name)->
			(val, period)->
				dur = null
				tmp = null
				if period isnt null and not isNaN(+period)
					deprecateSimple name, 'moment().' + name + '(period, number) is deprecated. Please use moment().' + name + '(number, period).'
					tmp = val
					val = period
					period = tmp
				val = (if typeof val is 'string' then +val else val)
				dur = moment.duration(val, period)
				addOrSubtractDurationFromMoment this, dur, direction
				this

		addOrSubtractDurationFromMoment = (mom, duration, isAdding, updateOffset)->
			milliseconds = duration._milliseconds
			days = duration._days
			months = duration._months
			updateOffset = (if not updateOffset? then true else updateOffset)
			if milliseconds
				mom._d.setTime +mom._d + milliseconds * isAdding
			if days
				rawSetter mom, 'Date', rawGetter(mom, 'Date') + days * isAdding
			if months
				rawMonthSetter mom, rawGetter(mom, 'Month') + months * isAdding
			if updateOffset
				moment.updateOffset mom, days or months
			return

		isArray = (input)->
			Object::toString.call(input) is '[object Array]'

		isDate = (input)->
			Object::toString.call(input) is '[object Date]' or input instanceof Date

		compareArrays = (array1, array2, dontConvert)->
			len = Math.min(array1.length, array2.length)
			lengthDiff = Math.abs(array1.length - array2.length)
			diffs = 0
			i = null
			i = 0
			while i < len
				if dontConvert and array1[i] isnt array2[i] or not dontConvert and toInt(array1[i]) isnt toInt(array2[i])
					diffs++
				i++
			diffs + lengthDiff

		normalizeUnits = (units)->
			if units
				lowered = units.toLowerCase().replace(/(.)s$/, '$1')
				units = unitAliases[units] or camelFunctions[lowered] or lowered
			units

		normalizeObjectUnits = (inputObject)->
			normalizedInput = {}
			normalizedProp = null
			prop = null
			for prop of inputObject
				if hasOwnProp(inputObject, prop)
					normalizedProp = normalizeUnits(prop)
					if normalizedProp
						normalizedInput[normalizedProp] = inputObject[prop]
			normalizedInput

		makeList = (field)->
			count = null
			setter = null
			if field.indexOf('week') is 0
				count = 7
				setter = 'day'
			else
				if field.indexOf('month') is 0
					count = 12
					setter = 'month'
				else
					return
			moment[field] = (format, index)->
				i = null
				getter = null
				method = moment._locale[field]
				results = []
				if typeof format is 'number'
					index = format
					format = `undefined`
				getter = (i)->
					m = moment().utc().set(setter, i)
					method.call moment._locale, m, format or ''

				if index?
					getter index
				else
					i = 0
					while i < count
						results.push getter(i)
						i++
					results

			return

		toInt = (argumentForCoercion)->
			coercedNumber = +argumentForCoercion
			value = 0
			if coercedNumber isnt 0 and isFinite(coercedNumber)
				if coercedNumber >= 0
					value = Math.floor(coercedNumber)
				else
					value = Math.ceil(coercedNumber)
			value

		daysInMonth = (year, month)->
			new Date(Date.UTC(year, month + 1, 0)).getUTCDate()

		weeksInYear = (year, dow, doy)->
			weekOfYear(moment([
				year
				11
				31 + dow - doy
			]), dow, doy).week

		daysInYear = (year)->
			(if isLeapYear(year) then 366 else 365)

		isLeapYear = (year)->
			year % 4 is 0 and year % 100 isnt 0 or year % 400 is 0

		checkOverflow = (m)->
			overflow = null
			if m._a and m._pf.overflow is -2
				overflow = (if m._a[MONTH] < 0 or m._a[MONTH] > 11 then MONTH else (if m._a[DATE] < 1 or m._a[DATE] > daysInMonth(m._a[YEAR], m._a[MONTH]) then DATE else (if m._a[HOUR] < 0 or m._a[HOUR] > 23 then HOUR else (if m._a[MINUTE] < 0 or m._a[MINUTE] > 59 then MINUTE else (if m._a[SECOND] < 0 or m._a[SECOND] > 59 then SECOND else (if m._a[MILLISECOND] < 0 or m._a[MILLISECOND] > 999 then MILLISECOND else -1))))))
				if m._pf._overflowDayOfYear and (overflow < YEAR or overflow > DATE)
					overflow = DATE
				m._pf.overflow = overflow
			return

		isValid = (m)->
			unless m._isValid?
				m._isValid = not isNaN(m._d.getTime()) and m._pf.overflow < 0 and not m._pf.empty and not m._pf.invalidMonth and not m._pf.nullInput and not m._pf.invalidFormat and not m._pf.userInvalidated
				if m._strict
					m._isValid = m._isValid and m._pf.charsLeftOver is 0 and m._pf.unusedTokens.length is 0
			m._isValid

		normalizeLocale = (key)->
			(if key then key.toLowerCase().replace('_', '-') else key)

		chooseLocale = (names)->
			i = 0
			j = null
			next = null
			locale = null
			split = null
			while i < names.length
				split = normalizeLocale(names[i]).split('-')
				j = split.length
				next = normalizeLocale(names[i + 1])
				next = (if next then next.split('-') else null)
				while j > 0
					locale = loadLocale(split.slice(0, j).join('-'))
					if locale
						return locale
					if next and next.length >= j and compareArrays(split, next, true) >= j - 1
						break
					j--
				i++
			null

		loadLocale = (name)->
			oldLocale = null
			if not locales[name] and hasModule
				try
					oldLocale = moment.locale()
					require './locale/' + name
					moment.locale oldLocale
			locales[name]

		makeAs = (input, model)->
			(if model._isUTC then moment(input).zone(model._offset or 0) else moment(input).local())

		removeFormattingTokens = (input)->
			if input.match(/\[[\s\S]/)
				return input.replace(/^\[|\]$/g, '')
			input.replace /\\/g, ''

		makeFormatFunction = (format)->
			array = format.match(formattingTokens)
			i = null
			length = null
			i = 0
			length = array.length

			while i < length
				if formatTokenFunctions[array[i]]
					array[i] = formatTokenFunctions[array[i]]
				else
					array[i] = removeFormattingTokens(array[i])
				i++
			(mom)->
				output = ''
				i = 0
				while i < length
					output += (if array[i] instanceof Function then array[i].call(mom, format) else array[i])
					i++
				output

		formatMoment = (m, format)->
			unless m.isValid()
				return m.localeData().invalidDate()
			format = expandFormat(format, m.localeData())
			unless formatFunctions[format]
				formatFunctions[format] = makeFormatFunction(format)
			formatFunctions[format] m

		expandFormat = (format, locale)->
			replaceLongDateFormatTokens = (input)->
				locale.longDateFormat(input) or input
			i = 5
			localFormattingTokens.lastIndex = 0
			while i >= 0 and localFormattingTokens.test(format)
				format = format.replace(localFormattingTokens, replaceLongDateFormatTokens)
				localFormattingTokens.lastIndex = 0
				i -= 1
			format

		getParseRegexForToken = (token, config)->
			a = null
			strict = config._strict
			switch token
				when 'Q'
					return parseTokenOneDigit
					# break
				when 'DDDD'
					return parseTokenThreeDigits
					# break
				when 'YYYY', 'GGGG', 'gggg'
					if strict
						return parseTokenFourDigits
					else
						return parseTokenOneToFourDigits
					# break
				when 'Y', 'G', 'g'
					return parseTokenSignedNumber
					# break
				when 'YYYYYY', 'YYYYY', 'GGGGG', 'ggggg'
					if strict
						return parseTokenSixDigits
					else
						return parseTokenOneToSixDigits
					# break
				when 'S'
					if strict
						return parseTokenOneDigit
					break
				when 'SS'
					if strict
						return parseTokenTwoDigits
					break
				when 'SSS'
					if strict
						return parseTokenThreeDigits
					break
				when 'DDD'
					return parseTokenOneToThreeDigits
					# break
				when 'MMM', 'MMMM', 'dd', 'ddd', 'dddd'
					return parseTokenWord
					# break
				when 'a', 'A'
					return config._locale._meridiemParse
					# break
				when 'X'
					return parseTokenTimestampMs
					# break
				when 'Z', 'ZZ'
					return parseTokenTimezone
					# break
				when 'T'
					return parseTokenT
					# break
				when 'SSSS'
					return parseTokenDigits
					# break
				when 'MM', 'DD', 'YY', 'GG', 'gg', 'HH', 'hh', 'mm', 'ss', 'ww', 'WW'
					# (if strict then parseTokenTwoDigits else parseTokenOneOrTwoDigits)
					if strict
						return parseTokenTwoDigits
					else
						return parseTokenOneOrTwoDigits
					break
				when 'M', 'D', 'd', 'H', 'h', 'm', 's', 'w', 'W', 'e', 'E'
					return parseTokenOneOrTwoDigits
					# break
				when 'Do'
					return parseTokenOrdinal
				else
					a = new RegExp(regexpEscape(unescapeFormat(token.replace("\\", "")), "i"))
					a

		timezoneMinutesFromString = (string)->
			string = string or ''
			possibleTzMatches = string.match(parseTokenTimezone) or []
			tzChunk = possibleTzMatches[possibleTzMatches.length - 1] or []
			parts = (tzChunk + '').match(parseTimezoneChunker) or [
				'-'
				0
				0
			]
			minutes = +(parts[1] * 60) + toInt(parts[2])
			(if parts[0] is '+' then -minutes else minutes)

		addTimeToArrayFromToken = (token, input, config)->
			a = null
			datePartArray = config._a
			switch token
				when 'Q'
					if input?
						datePartArray[MONTH] = (toInt(input) - 1) * 3
				when 'M', 'MM'
					if input?
						datePartArray[MONTH] = toInt(input) - 1
				when 'MMM', 'MMMM'
					a = config._locale.monthsParse(input)
					if a?
						datePartArray[MONTH] = a
					else
						config._pf.invalidMonth = input
				when 'D', 'DD'
					if input?
						datePartArray[DATE] = toInt(input)
				when 'Do'
					if input?
						datePartArray[DATE] = toInt(parseInt(input, 10))
				when 'DDD', 'DDDD'
					if input?
						config._dayOfYear = toInt(input)
				when 'YY'
					datePartArray[YEAR] = moment.parseTwoDigitYear(input)
				when 'YYYY', 'YYYYY', 'YYYYYY'
					datePartArray[YEAR] = toInt(input)
				when 'a', 'A'
					config._isPm = config._locale.isPM(input)
				when 'H', 'HH', 'h', 'hh'
					datePartArray[HOUR] = toInt(input)
				when 'm', 'mm'
					datePartArray[MINUTE] = toInt(input)
				when 's', 'ss'
					datePartArray[SECOND] = toInt(input)
				when 'S', 'SS', 'SSS', 'SSSS'
					datePartArray[MILLISECOND] = toInt(('0.' + input) * 1e3)
				when 'X'
					config._d = new Date(parseFloat(input) * 1e3)
				when 'Z', 'ZZ'
					config._useUTC = true
					config._tzm = timezoneMinutesFromString(input)
				when 'dd', 'ddd', 'dddd'
					a = config._locale.weekdaysParse(input)
					if a?
						config._w = config._w or {}
						config._w.d = a
						return
					else
						config._pf.invalidWeekday = input
				when 'w', 'ww', 'W', 'WW', 'd', 'e', 'E'
					token = token.substr(0, 1)
				when 'gggg', 'GGGG', 'GGGGG'
					token = token.substr(0, 2)
					if input
						config._w = config._w or {}
						config._w[token] = toInt(input)
				when 'gg', 'GG'
					config._w = config._w or {}
					config._w[token] = moment.parseTwoDigitYear(input)
			return

		dayOfYearFromWeekInfo = (config)->
			w = null
			weekYear = null
			week = null
			weekday = null
			dow = null
			doy = null
			temp = null
			w = config._w
			if w.GG? or w.W? or w.E?
				dow = 1
				doy = 4
				weekYear = dfl(w.GG, config._a[YEAR], weekOfYear(moment(), 1, 4).year)
				week = dfl(w.W, 1)
				weekday = dfl(w.E, 1)
			else
				dow = config._locale._week.dow
				doy = config._locale._week.doy
				weekYear = dfl(w.gg, config._a[YEAR], weekOfYear(moment(), dow, doy).year)
				week = dfl(w.w, 1)
				if w.d?
					weekday = w.d
					if weekday < dow
						++week
				else
					if w.e?
						weekday = w.e + dow
					else
						weekday = dow
			temp = dayOfYearFromWeeks(weekYear, week, weekday, doy, dow)
			config._a[YEAR] = temp.year
			config._dayOfYear = temp.dayOfYear
			return

		dateFromConfig = (config)->
			i = null
			date = null
			input = []
			currentDate = null
			yearToUse = null
			if config._d
				return
			currentDate = currentDateArray(config)
			if config._w and not config._a[DATE]? and not config._a[MONTH]?
				dayOfYearFromWeekInfo config
			if config._dayOfYear
				yearToUse = dfl(config._a[YEAR], currentDate[YEAR])
				if config._dayOfYear > daysInYear(yearToUse)
					config._pf._overflowDayOfYear = true
				date = makeUTCDate(yearToUse, 0, config._dayOfYear)
				config._a[MONTH] = date.getUTCMonth()
				config._a[DATE] = date.getUTCDate()
			i = 0
			while i < 3 and not config._a[i]?
				config._a[i] = input[i] = currentDate[i]
				++i
			while i < 7
				config._a[i] = input[i] = (if not config._a[i]? then (if i is 2 then 1 else 0) else config._a[i])
				i++
			config._d = (if config._useUTC then makeUTCDate else makeDate).apply(null, input)
			if config._tzm?
				config._d.setUTCMinutes config._d.getUTCMinutes() + config._tzm
			return

		dateFromObject = (config)->
			normalizedInput = null
			if config._d
				return
			normalizedInput = normalizeObjectUnits(config._i)
			config._a = [
				normalizedInput.year
				normalizedInput.month
				normalizedInput.day
				normalizedInput.hour
				normalizedInput.minute
				normalizedInput.second
				normalizedInput.millisecond
			]
			dateFromConfig config
			return

		currentDateArray = (config)->
			now = new Date()
			if config._useUTC
				[
					now.getUTCFullYear()
					now.getUTCMonth()
					now.getUTCDate()
				]
			else
				[
					now.getFullYear()
					now.getMonth()
					now.getDate()
				]

		makeDateFromStringAndFormat = (config)->
			if config._f is moment.ISO_8601
				parseISO config
				return
			config._a = []
			config._pf.empty = true
			string = '' + config._i
			i = null
			parsedInput = null
			tokens = null
			token = null
			skipped = null
			stringLength = string.length
			totalParsedInputLength = 0
			tokens = expandFormat(config._f, config._locale).match(formattingTokens) or []
			i = 0
			while i < tokens.length
				token = tokens[i]
				parsedInput = (string.match(getParseRegexForToken(token, config)) or [])[0]
				if parsedInput
					skipped = string.substr(0, string.indexOf(parsedInput))
					if skipped.length > 0
						config._pf.unusedInput.push skipped
					string = string.slice(string.indexOf(parsedInput) + parsedInput.length)
					totalParsedInputLength += parsedInput.length
				if formatTokenFunctions[token]
					if parsedInput
						config._pf.empty = false
					else
						config._pf.unusedTokens.push token
					addTimeToArrayFromToken token, parsedInput, config
				else
					if config._strict and not parsedInput
						config._pf.unusedTokens.push token
				i++
			config._pf.charsLeftOver = stringLength - totalParsedInputLength
			if string.length > 0
				config._pf.unusedInput.push string
			if config._isPm and config._a[HOUR] < 12
				config._a[HOUR] += 12
			if config._isPm is false and config._a[HOUR] is 12
				config._a[HOUR] = 0
			dateFromConfig config
			checkOverflow config
			return

		unescapeFormat = (s)->
			s.replace /\\(\[)|\\(\])|\[([^\]\[]*)\]|\\(.)/g, (matched, p1, p2, p3, p4)->
				p1 or p2 or p3 or p4

		regexpEscape = (s)->
			s.replace /[-\/\\^$*+?.()|[\]{}]/g, '\\$&'

		makeDateFromStringAndArray = (config)->
			tempConfig = null
			bestMoment = null
			scoreToBeat = null
			i = null
			currentScore = null
			if config._f.length is 0
				config._pf.invalidFormat = true
				config._d = new Date(NaN)
				return
			i = 0
			while i < config._f.length
				currentScore = 0
				tempConfig = copyConfig({}, config)
				if config._useUTC?
					tempConfig._useUTC = config._useUTC
				tempConfig._pf = defaultParsingFlags()
				tempConfig._f = config._f[i]
				makeDateFromStringAndFormat tempConfig
				unless isValid(tempConfig)
					continue
				currentScore += tempConfig._pf.charsLeftOver
				currentScore += tempConfig._pf.unusedTokens.length * 10
				tempConfig._pf.score = currentScore
				if not scoreToBeat? or currentScore < scoreToBeat
					scoreToBeat = currentScore
					bestMoment = tempConfig
				i++
			extend config, bestMoment or tempConfig
			return

		parseISO = (config)->
			i = null
			l = null
			string = config._i
			match = isoRegex.exec(string)
			if match
				config._pf.iso = true
				i = 0
				l = isoDates.length

				while i < l
					if isoDates[i][1].exec(string)
						config._f = isoDates[i][0] + (match[6] or ' ')
						break
					i++
				i = 0
				l = isoTimes.length

				while i < l
					if isoTimes[i][1].exec(string)
						config._f += isoTimes[i][0]
						break
					i++
				if string.match(parseTokenTimezone)
					config._f += 'Z'
				makeDateFromStringAndFormat config
			else
				config._isValid = false
			return

		makeDateFromString = (config)->
			parseISO config
			if config._isValid is false
				delete config._isValid

				moment.createFromInputFallback config
			return

		map = (arr, fn)->
			res = []
			i = null
			i = 0
			while i < arr.length
				res.push fn(arr[i], i)
				++i
			res

		makeDateFromInput = (config)->
			input = config._i
			matched = null
			if input is `undefined`
				config._d = new Date()
			else
				if isDate(input)
					config._d = new Date(+input)
				else
					if (matched = aspNetJsonRegex.exec(input)) isnt null
						config._d = new Date(+matched[1])
					else
						if typeof input is 'string'
							makeDateFromString config
						else
							if isArray(input)
								config._a = map(input.slice(0), (obj)->
									parseInt obj, 10
								)
								dateFromConfig config
							else
								if typeof input is 'object'
									dateFromObject config
								else
									if typeof input is 'number'
										config._d = new Date(input)
									else
										moment.createFromInputFallback config
			return

		makeDate = (y, m, d, h, M, s, ms)->
			date = new Date(y, m, d, h, M, s, ms)
			if y < 1970
				date.setFullYear y
			date

		makeUTCDate = (y)->
			date = new Date(Date.UTC.apply(null, arguments))
			if y < 1970
				date.setUTCFullYear y
			date

		parseWeekday = (input, locale)->
			if typeof input is 'string'
				unless isNaN(input)
					input = parseInt(input, 10)
				else
					input = locale.weekdaysParse(input)
					if typeof input isnt 'number'
						return null
			input

		substituteTimeAgo = (string, number, withoutSuffix, isFuture, locale)->
			locale.relativeTime number or 1, !!withoutSuffix, string, isFuture

		relativeTime = (posNegDuration, withoutSuffix, locale)->
			duration = moment.duration(posNegDuration).abs()
			seconds = round(duration.as('s'))
			minutes = round(duration.as('m'))
			hours = round(duration.as('h'))
			days = round(duration.as('d'))
			months = round(duration.as('M'))
			years = round(duration.as('y'))
			args = seconds < relativeTimeThresholds.s and [
				's'
				seconds
			] or minutes is 1 and ['m'] or minutes < relativeTimeThresholds.m and [
				'mm'
				minutes
			] or hours is 1 and ['h'] or hours < relativeTimeThresholds.h and [
				'hh'
				hours
			] or days is 1 and ['d'] or days < relativeTimeThresholds.d and [
				'dd'
				days
			] or months is 1 and ['M'] or months < relativeTimeThresholds.M and [
				'MM'
				months
			] or years is 1 and ['y'] or [
				'yy'
				years
			]
			args[2] = withoutSuffix
			args[3] = +posNegDuration > 0
			args[4] = locale
			substituteTimeAgo.apply {}, args

		weekOfYear = (mom, firstDayOfWeek, firstDayOfWeekOfYear)->
			end = firstDayOfWeekOfYear - firstDayOfWeek
			daysToDayOfWeek = firstDayOfWeekOfYear - mom.day()
			adjustedMoment = null
			if daysToDayOfWeek > end
				daysToDayOfWeek -= 7
			if daysToDayOfWeek < end - 7
				daysToDayOfWeek += 7
			adjustedMoment = moment(mom).add(daysToDayOfWeek, 'd')
				week: Math.ceil(adjustedMoment.dayOfYear() / 7)
				year: adjustedMoment.year()
			return

		dayOfYearFromWeeks = (year, week, weekday, firstDayOfWeekOfYear, firstDayOfWeek)->
			d = makeUTCDate(year, 0, 1).getUTCDay()
			daysToAdd = null
			dayOfYear = null
			d = (if d is 0 then 7 else d)
			weekday = (if weekday? then weekday else firstDayOfWeek)
			daysToAdd = firstDayOfWeek - d + (if d > firstDayOfWeekOfYear then 7 else 0) - (if d < firstDayOfWeek then 7 else 0)
			dayOfYear = 7 * (week - 1) + (weekday - firstDayOfWeek) + daysToAdd + 1
			{
				year: (if dayOfYear > 0 then year else year - 1)
				dayOfYear: (if dayOfYear > 0 then dayOfYear else daysInYear(year - 1) + dayOfYear)
			}

		makeMoment = (config)->
			input = config._i
			format = config._f
			config._locale = config._locale or moment.localeData(config._l)
			if input is null or format is `undefined` and input is ''
				return moment.invalid(nullInput: true)
			if typeof input is 'string'
				config._i = input = config._locale.preparse(input)
			if moment.isMoment(input)
				return new Moment(input, true)
			else
				if format
					if isArray(format)
						makeDateFromStringAndArray config
					else
						makeDateFromStringAndFormat config
				else
					makeDateFromInput config
			new Moment(config)

		pickBy = (fn, moments)->
			res = null
			i = null
			if moments.length is 1 and isArray(moments[0])
				moments = moments[0]
			return moment()	unless moments.length
			res = moments[0]
			i = 1
			while i < moments.length
				if moments[i][fn](res)
					res = moments[i]
				++i
			res

		rawMonthSetter = (mom, value)->
			dayOfMonth = null
			if typeof value is 'string'
				value = mom.localeData().monthsParse(value)
				if typeof value isnt 'number'
					return mom
			dayOfMonth = Math.min(mom.date(), daysInMonth(mom.year(), value))
			mom._d['set' + (if mom._isUTC then 'UTC' else '') + 'Month'] value, dayOfMonth
			mom

		rawGetter = (mom, unit)->
			mom._d['get' + (if mom._isUTC then 'UTC' else '') + unit]()

		rawSetter = (mom, unit, value)->
			if unit is 'Month'
				rawMonthSetter mom, value
			else
				mom._d['set' + (if mom._isUTC then 'UTC' else '') + unit] value

		makeAccessor = (unit, keepTime)->
			(value)->
				if value?
					rawSetter this, unit, value
					moment.updateOffset this, keepTime
					this
				else
					rawGetter this, unit

		daysToYears = (days)->
			days * 400 / 146097

		yearsToDays = (years)->
			years * 146097 / 400

		makeDurationGetter = (name)->
			moment.duration.fn[name] = ->
				@_data[name]

			return
		moment = null
		VERSION = '2.8.3'
		globalScope = if typeof global isnt 'undefined' then global else this
		oldGlobalMoment = null
		round = Math.round
		hasOwnProperty = Object::hasOwnProperty
		i = null
		YEAR = 0
		MONTH = 1
		DATE = 2
		HOUR = 3
		MINUTE = 4
		SECOND = 5
		MILLISECOND = 6
		locales = {}
		momentProperties = []
		hasModule = typeof module isnt 'undefined' and module.exports
		aspNetJsonRegex = /^\/?Date\((\-?\d+)/i
		aspNetTimeSpanJsonRegex = /(\-)?(?:(\d*)\.)?(\d+)\:(\d+)(?:\:(\d+)\.?(\d{3})?)?/
		isoDurationRegex = /^(-)?P(?:(?:([0-9,.]*)Y)?(?:([0-9,.]*)M)?(?:([0-9,.]*)D)?(?:T(?:([0-9,.]*)H)?(?:([0-9,.]*)M)?(?:([0-9,.]*)S)?)?|([0-9,.]*)W)$/
		formattingTokens = /(\[[^\[]*\])|(\\)?(Mo|MM?M?M?|Do|DDDo|DD?D?D?|ddd?d?|do?|w[o|w]?|W[o|W]?|Q|YYYYYY|YYYYY|YYYY|YY|gg(ggg?)?|GG(GGG?)?|e|E|a|A|hh?|HH?|mm?|ss?|S{1,4}|X|zz?|ZZ?|.)/g
		localFormattingTokens = /(\[[^\[]*\])|(\\)?(LT|LL?L?L?|l{1,4})/g
		parseTokenOneOrTwoDigits = /\d\d?/
		parseTokenOneToThreeDigits = /\d{1,3}/
		parseTokenOneToFourDigits = /\d{1,4}/
		parseTokenOneToSixDigits = /[+\-]?\d{1,6}/
		parseTokenDigits = /\d+/
		parseTokenWord = /[0-9]*['a-z\u00A0-\u05FF\u0700-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+|[\u0600-\u06FF\/]+(\s*?[\u0600-\u06FF]+){1,2}/i
		parseTokenTimezone = /Z|[\+\-]\d\d:?\d\d/g
		parseTokenT = /T/i
		parseTokenTimestampMs = /[\+\-]?\d+(\.\d{1,3})?/
		parseTokenOrdinal = /\d{1,2}/
		parseTokenOneDigit = /\d/
		parseTokenTwoDigits = /\d\d/
		parseTokenThreeDigits = /\d{3}/
		parseTokenFourDigits = /\d{4}/
		parseTokenSixDigits = /[+-]?\d{6}/
		parseTokenSignedNumber = /[+-]?\d+/
		isoRegex = /^\s*(?:[+-]\d{6}|\d{4})-(?:(\d\d-\d\d)|(W\d\d$)|(W\d\d-\d)|(\d\d\d))((T| )(\d\d(:\d\d(:\d\d(\.\d+)?)?)?)?([\+\-]\d\d(?::?\d\d)?|\s*Z)?)?$/
		isoFormat = 'YYYY-MM-DDTHH:mm:ssZ'
		isoDates = [
			[ 'YYYYYY-MM-DD', /[+-]\d{6}-\d{2}-\d{2}/ ]
			[ 'YYYY-MM-DD', /\d{4}-\d{2}-\d{2}/ ]
			[ 'GGGG-[W]WW-E', /\d{4}-W\d{2}-\d/ ]
			[ 'GGGG-[W]WW', /\d{4}-W\d{2}/ ]
			[ 'YYYY-DDD', /\d{4}-\d{3}/ ]
		]
		isoTimes = [
			[ 'HH:mm:ss.SSSS', /(T| )\d\d:\d\d:\d\d\.\d+/ ]
			[ 'HH:mm:ss', /(T| )\d\d:\d\d:\d\d/ ]
			[ 'HH:mm', /(T| )\d\d:\d\d/ ]
			[ 'HH', /(T| )\d\d/ ]
		]
		parseTimezoneChunker = /([\+\-]|\d\d)/g
		proxyGettersAndSetters = 'Date|Hours|Minutes|Seconds|Milliseconds'.split('|')
		unitMillisecondFactors =
			Milliseconds: 1
			Seconds: 1e3
			Minutes: 6e4
			Hours: 36e5
			Days: 864e5
			Months: 2592e6
			Years: 31536e6

		unitAliases =
			ms: 'millisecond'
			s: 'second'
			m: 'minute'
			h: 'hour'
			d: 'day'
			D: 'date'
			w: 'week'
			W: 'isoWeek'
			M: 'month'
			Q: 'quarter'
			y: 'year'
			DDD: 'dayOfYear'
			e: 'weekday'
			E: 'isoWeekday'
			gg: 'weekYear'
			GG: 'isoWeekYear'

		camelFunctions =
			dayofyear: 'dayOfYear'
			isoweekday: 'isoWeekday'
			isoweek: 'isoWeek'
			weekyear: 'weekYear'
			isoweekyear: 'isoWeekYear'

		formatFunctions = {}
		relativeTimeThresholds =
			s: 45
			m: 45
			h: 22
			d: 26
			M: 11

		ordinalizeTokens = 'DDD w W M D d'.split(' ')
		paddedTokens = 'M D H h m s w W'.split(' ')
		formatTokenFunctions =
			M: ->
				@month() + 1

			MMM: (format)->
				@localeData().monthsShort this, format

			MMMM: (format)->
				@localeData().months this, format

			D: ->
				@date()

			DDD: ->
				@dayOfYear()

			d: ->
				@day()

			dd: (format)->
				@localeData().weekdaysMin this, format

			ddd: (format)->
				@localeData().weekdaysShort this, format

			dddd: (format)->
				@localeData().weekdays this, format

			w: ->
				@week()

			W: ->
				@isoWeek()

			YY: ->
				leftZeroFill @year() % 100, 2

			YYYY: ->
				leftZeroFill @year(), 4

			YYYYY: ->
				leftZeroFill @year(), 5

			YYYYYY: ->
				y = @year()
				sign = (if y >= 0 then '+' else '-')
				sign + leftZeroFill(Math.abs(y), 6)

			gg: ->
				leftZeroFill @weekYear() % 100, 2

			gggg: ->
				leftZeroFill @weekYear(), 4

			ggggg: ->
				leftZeroFill @weekYear(), 5

			GG: ->
				leftZeroFill @isoWeekYear() % 100, 2

			GGGG: ->
				leftZeroFill @isoWeekYear(), 4

			GGGGG: ->
				leftZeroFill @isoWeekYear(), 5

			e: ->
				@weekday()

			E: ->
				@isoWeekday()

			a: ->
				@localeData().meridiem @hours(), @minutes(), true

			A: ->
				@localeData().meridiem @hours(), @minutes(), false

			H: ->
				@hours()

			h: ->
				@hours() % 12 or 12

			m: ->
				@minutes()

			s: ->
				@seconds()

			S: ->
				toInt @milliseconds() / 100

			SS: ->
				leftZeroFill toInt(@milliseconds() / 10), 2

			SSS: ->
				leftZeroFill @milliseconds(), 3

			SSSS: ->
				leftZeroFill @milliseconds(), 3

			Z: ->
				a = -@zone()
				b = '+'
				if a < 0
					a = -a
					b = '-'
				b + leftZeroFill(toInt(a / 60), 2) + ':' + leftZeroFill(toInt(a) % 60, 2)

			ZZ: ->
				a = -@zone()
				b = '+'
				if a < 0
					a = -a
					b = '-'
				b + leftZeroFill(toInt(a / 60), 2) + leftZeroFill(toInt(a) % 60, 2)

			z: ->
				@zoneAbbr()

			zz: ->
				@zoneName()

			X: ->
				@unix()

			Q: ->
				@quarter()

		deprecations = {}
		lists = [ 'months', 'monthsShort', 'weekdays', 'weekdaysShort', 'weekdaysMin' ]
		while ordinalizeTokens.length
			i = ordinalizeTokens.pop()
			formatTokenFunctions[i + 'o'] = ordinalizeToken(formatTokenFunctions[i], i)
		while paddedTokens.length
			i = paddedTokens.pop()
			formatTokenFunctions[i + i] = padToken(formatTokenFunctions[i], 2)
		formatTokenFunctions.DDDD = padToken(formatTokenFunctions.DDD, 3)
		extend Locale::,
			set: (config)->
				prop = null
				i = null
				for i of config
					prop = config[i]
					if typeof prop is 'function'
						this[i] = prop
					else
						this['_' + i] = prop
				return

			_months: 'January_February_March_April_May_June_July_August_September_October_November_December'.split('_')
			months: (m)->
				@_months[m.month()]

			_monthsShort: 'Jan_Feb_Mar_Apr_May_Jun_Jul_Aug_Sep_Oct_Nov_Dec'.split('_')
			monthsShort: (m)->
				@_monthsShort[m.month()]

			monthsParse: (monthName)->
				i = null
				mom = null
				regex = null
				unless @_monthsParse
					@_monthsParse = []
				i = 0
				while i < 12
					unless @_monthsParse[i]
						mom = moment.utc([
							2e3
							i
						])
						regex = '^' + @months(mom, '') + '|^' + @monthsShort(mom, '')
						@_monthsParse[i] = new RegExp(regex.replace('.', ''), 'i')
					if @_monthsParse[i].test(monthName)
						return i
					i++
				return

			_weekdays: 'Sunday_Monday_Tuesday_Wednesday_Thursday_Friday_Saturday'.split('_')
			weekdays: (m)->
				@_weekdays[m.day()]

			_weekdaysShort: 'Sun_Mon_Tue_Wed_Thu_Fri_Sat'.split('_')
			weekdaysShort: (m)->
				@_weekdaysShort[m.day()]

			_weekdaysMin: 'Su_Mo_Tu_We_Th_Fr_Sa'.split('_')
			weekdaysMin: (m)->
				@_weekdaysMin[m.day()]

			weekdaysParse: (weekdayName)->
				i = null
				mom = null
				regex = null
				unless @_weekdaysParse
					@_weekdaysParse = []
				i = 0
				while i < 7
					unless @_weekdaysParse[i]
						mom = moment([
							2e3
							1
						]).day(i)
						regex = '^' + @weekdays(mom, '') + '|^' + @weekdaysShort(mom, '') + '|^' + @weekdaysMin(mom, '')
						@_weekdaysParse[i] = new RegExp(regex.replace('.', ''), 'i')
					if @_weekdaysParse[i].test(weekdayName)
						return i
					i++
				return

			_longDateFormat:
				LT: 'h:mm A'
				L: 'MM/DD/YYYY'
				LL: 'MMMM D, YYYY'
				LLL: 'MMMM D, YYYY LT'
				LLLL: 'dddd, MMMM D, YYYY LT'

			longDateFormat: (key)->
				output = @_longDateFormat[key]
				if not output and @_longDateFormat[key.toUpperCase()]
					output = @_longDateFormat[key.toUpperCase()].replace(/MMMM|MM|DD|dddd/g, (val)->
						val.slice 1
					)
					@_longDateFormat[key] = output
				output

			isPM: (input)->
				(input + '').toLowerCase().charAt(0) is 'p'

			_meridiemParse: /[ap]\.?m?\.?/i
			meridiem: (hours, minutes, isLower)->
				if hours > 11
					(if isLower then 'pm' else 'PM')
				else
					(if isLower then 'am' else 'AM')

			_calendar:
				sameDay: '[Today at] LT'
				nextDay: '[Tomorrow at] LT'
				nextWeek: 'dddd [at] LT'
				lastDay: '[Yesterday at] LT'
				lastWeek: '[Last] dddd [at] LT'
				sameElse: 'L'

			calendar: (key, mom)->
				output = @_calendar[key]
				(if typeof output is 'function' then output.apply(mom) else output)

			_relativeTime:
				future: 'in %s'
				past: '%s ago'
				s: 'a few seconds'
				m: 'a minute'
				mm: '%d minutes'
				h: 'an hour'
				hh: '%d hours'
				d: 'a day'
				dd: '%d days'
				M: 'a month'
				MM: '%d months'
				y: 'a year'
				yy: '%d years'

			relativeTime: (number, withoutSuffix, string, isFuture)->
				output = @_relativeTime[string]
				(if typeof output is 'function' then output(number, withoutSuffix, string, isFuture) else output.replace(/%d/i, number))

			pastFuture: (diff, output)->
				format = @_relativeTime[(if diff > 0 then 'future' else 'past')]
				(if typeof format is 'function' then format(output) else format.replace(/%s/i, output))

			ordinal: (number)->
				@_ordinal.replace '%d', number

			_ordinal: '%d'
			preparse: (string)->
				string

			postformat: (string)->
				string

			week: (mom)->
				weekOfYear(mom, @_week.dow, @_week.doy).week

			_week:
				dow: 0
				doy: 6

			_invalidDate: 'Invalid date'
			invalidDate: ->
				@_invalidDate

		moment = (input, format, locale, strict)->
			c = null
			if typeof locale is 'boolean'
				strict = locale
				locale = `undefined`
			c = {}
			c._isAMomentObject = true
			c._i = input
			c._f = format
			c._l = locale
			c._strict = strict
			c._isUTC = false
			c._pf = defaultParsingFlags()
			makeMoment c

		moment.suppressDeprecationWarnings = false
		moment.createFromInputFallback = deprecate 'moment construction falls back to js Date. This is ' + 'discouraged and will be removed in upcoming major ' + 'release. Please refer to ' + 'https://github.com/moment/moment/issues/1407 for more info.', (config)->
			config._d = new Date(config._i)
			return

		moment.min = ->
			args = [].slice.call(arguments, 0)
			pickBy 'isBefore', args

		moment.max = ->
			args = [].slice.call(arguments, 0)
			pickBy 'isAfter', args

		moment.utc = (input, format, locale, strict)->
			c = null
			if typeof locale is 'boolean'
				strict = locale
				locale = `undefined`
			c = {}
			c._isAMomentObject = true
			c._useUTC = true
			c._isUTC = true
			c._l = locale
			c._i = input
			c._f = format
			c._strict = strict
			c._pf = defaultParsingFlags()
			makeMoment(c).utc()

		moment.unix = (input)->
			moment input * 1e3

		moment.duration = (input, key)->
			duration = input
			match = null
			sign = null
			ret = null
			parseIso = null
			diffRes = null
			if moment.isDuration(input)
				duration =
					ms: input._milliseconds
					d: input._days
					M: input._months
			else
				if typeof input is 'number'
					duration = {}
					if key
						duration[key] = input
					else
						duration.milliseconds = input
				else
					unless not (match = aspNetTimeSpanJsonRegex.exec(input))
						sign = (if match[1] is '-' then -1 else 1)
						duration =
							y: 0
							d: toInt(match[DATE]) * sign
							h: toInt(match[HOUR]) * sign
							m: toInt(match[MINUTE]) * sign
							s: toInt(match[SECOND]) * sign
							ms: toInt(match[MILLISECOND]) * sign
					else
						unless not (match = isoDurationRegex.exec(input))
							sign = (if match[1] is '-' then -1 else 1)
							parseIso = (inp)->
								res = inp and parseFloat(inp.replace(',', '.'))
								(if isNaN(res) then 0 else res) * sign

							duration =
								y: parseIso(match[2])
								M: parseIso(match[3])
								d: parseIso(match[4])
								h: parseIso(match[5])
								m: parseIso(match[6])
								s: parseIso(match[7])
								w: parseIso(match[8])
						else
							if typeof duration is 'object' and ('from' of duration or 'to' of duration)
								diffRes = momentsDifference(moment(duration.from), moment(duration.to))
								duration = {}
								duration.ms = diffRes.milliseconds
								duration.M = diffRes.months
			ret = new Duration(duration)
			ret._locale = input._locale	if moment.isDuration(input) and hasOwnProp(input, '_locale')
			ret

		moment.version = VERSION

		moment.defaultFormat = isoFormat

		moment.ISO_8601 = ->

		moment.momentProperties = momentProperties

		moment.updateOffset = ->

		moment.relativeTimeThreshold = (threshold, limit)->
			if relativeTimeThresholds[threshold] is `undefined`
				return false
			if limit is `undefined`
				return relativeTimeThresholds[threshold]
			relativeTimeThresholds[threshold] = limit
			true

		moment.lang = deprecate 'moment.lang is deprecated. Use moment.locale instead.', (key, value)->
			moment.locale key, value

		moment.locale = (key, values)->
			data = null
			if key
				if typeof values isnt 'undefined'
					data = moment.defineLocale(key, values)
				else
					data = moment.localeData(key)
				if data
					moment.duration._locale = moment._locale = data
			moment._locale._abbr

		moment.defineLocale = (name, values)->
			if values isnt null
				values.abbr = name
				unless locales[name]
					locales[name] = new Locale()
				locales[name].set values
				moment.locale name
				locales[name]
			else
				delete locales[name]

				null

		moment.langData = deprecate 'moment.langData is deprecated. Use moment.localeData instead.', (key)->
			moment.localeData key

		moment.localeData = (key)->
			locale = null
			if key and key._locale and key._locale._abbr
				key = key._locale._abbr
			unless key
				return moment._locale
			unless isArray(key)
				locale = loadLocale(key)
				if locale
					return locale
				key = [key]
			chooseLocale key

		moment.isMoment = (obj)->
			obj instanceof Moment or obj? and hasOwnProp(obj, '_isAMomentObject')

		moment.isDuration = (obj)->
			obj instanceof Duration

		i = lists.length - 1
		while i >= 0
			makeList lists[i]
			--i
		moment.normalizeUnits = (units)->
			normalizeUnits units

		moment.invalid = (flags)->
			m = moment.utc(NaN)
			if flags?
				extend m._pf, flags
			else
				m._pf.userInvalidated = true
			m

		moment.parseZone = ->
			moment.apply(null, arguments).parseZone()

		moment.parseTwoDigitYear = (input)->
			toInt(input) + (if toInt(input) > 68 then 1900 else 2e3)

		extend moment.fn = Moment::,
			clone : ->
				moment this

			valueOf : ->
				+@_d + (@_offset or 0) * 6e4

			unix : ->
				Math.floor +this / 1e3

			toString : ->
				@clone().locale('en').format 'ddd MMM DD YYYY HH:mm:ss [GMT]ZZ'

			toDate : ->
				(if @_offset then new Date(+this) else @_d)

			toISOString : ->
				m = moment(@).utc()
				if 0 < m.year() and m.year() <= 9999
					formatMoment m, 'YYYY-MM-DD[T]HH:mm:ss.SSS[Z]'
				else
					formatMoment m, 'YYYYYY-MM-DD[T]HH:mm:ss.SSS[Z]'

			toArray : ->
				m = @
				[ m.year(), m.month(), m.date(), m.hours(), m.minutes(), m.seconds(), m.milliseconds() ]

			isValid : ->
				isValid @

			isDSTShifted : ->
				if @_a
					return @isValid() and compareArrays(@_a, (if @_isUTC then moment.utc(@_a) else moment(@_a)).toArray()) > 0
				false

			parsingFlags : ->
				extend {}, @_pf

			invalidAt : ->
				@_pf.overflow

			utc : (keepLocalTime)->
				@zone 0, keepLocalTime

			local : (keepLocalTime)->
				if @_isUTC
					@zone 0, keepLocalTime
					@_isUTC = false
					if keepLocalTime
						@add @_dateTzOffset(), 'm'
				this

			format : (inputString)->
				output = formatMoment(this, inputString or moment.defaultFormat)
				@localeData().postformat output

			add : createAdder(1, 'add')

			subtract : createAdder(-1, 'subtract')

			diff : (input, units, asFloat)->
				that = makeAs(input, this)
				zoneDiff = (@zone() - that.zone()) * 6e4
				diff = null
				output = null
				daysAdjust = null
				units = normalizeUnits(units)
				if units is 'year' or units is 'month'
					diff = (@daysInMonth() + that.daysInMonth()) * 432e5
					output = (@year() - that.year()) * 12 + (@month() - that.month())
					daysAdjust = this - moment(@).startOf('month') - (that - moment(that).startOf('month'))
					daysAdjust -= (@zone() - moment(@).startOf('month').zone() - (that.zone() - moment(that).startOf('month').zone())) * 6e4
					output += daysAdjust / diff
					if units is 'year'
						output = output / 12
				else
					diff = this - that
					output = (if units is 'second' then diff / 1e3 else (if units is 'minute' then diff / 6e4 else (if units is 'hour' then diff / 36e5 else (if units is 'day' then (diff - zoneDiff) / 864e5 else (if units is 'week' then (diff - zoneDiff) / 6048e5 else diff)))))
				(if asFloat then output else absRound(output))

			from : (time, withoutSuffix)->
				moment.duration(
					to: this
					from: time
				).locale(@locale()).humanize not withoutSuffix

			fromNow : (withoutSuffix)->
				@from moment(), withoutSuffix

			calendar : (time)->
				now = time or moment()
				sod = makeAs(now, this).startOf('day')
				diff = @diff(sod, 'days', true)
				format = (if diff < -6 then 'sameElse' else (if diff < -1 then 'lastWeek' else (if diff < 0 then 'lastDay' else (if diff < 1 then 'sameDay' else (if diff < 2 then 'nextDay' else (if diff < 7 then 'nextWeek' else 'sameElse'))))))
				@format @localeData().calendar(format, this)

			isLeapYear : ->
				isLeapYear @year()

			isDST : ->
				@zone() < @clone().month(0).zone() or @zone() < @clone().month(5).zone()

			day : (input)->
				day = (if @_isUTC then @_d.getUTCDay() else @_d.getDay())
				if input?
					input = parseWeekday(input, @localeData())
					@add input - day, 'd'
				else
					day

			month : makeAccessor('Month', true)

			startOf : (units)->
				units = normalizeUnits(units)
				switch units
					when 'year'
						@month 0
						break
					when 'quarter', 'month'
						@date 1
						break
					when 'week', 'isoWeek', 'day'
						@hours 0
						break
					when 'hour'
						@minutes 0
						break
					when 'minute'
						@seconds 0
						break
					when 'second'
						@milliseconds 0
						break
				if units is 'week'
					@weekday 0
				else
					@isoWeekday 1	if units is 'isoWeek'
				if units is 'quarter'
					@month Math.floor(@month() / 3) * 3
				@

			endOf : (units)->
				units = normalizeUnits(units)
				@startOf(units).add(1, (if units is 'isoWeek' then 'week' else units)).subtract 1, 'ms'

			isAfter : (input, units)->
				units = normalizeUnits((if typeof units isnt 'undefined' then units else 'millisecond'))
				if units is 'millisecond'
					input = (if moment.isMoment(input) then input else moment(input))
					+this > +input
				else
					+@clone().startOf(units) > +moment(input).startOf(units)

			isBefore : (input, units)->
				units = normalizeUnits((if typeof units isnt 'undefined' then units else 'millisecond'))
				if units is 'millisecond'
					input = (if moment.isMoment(input) then input else moment(input))
					+this < +input
				else
					+@clone().startOf(units) < +moment(input).startOf(units)

			isSame : (input, units)->
				units = normalizeUnits(units or 'millisecond')
				if units is 'millisecond'
					input = (if moment.isMoment(input) then input else moment(input))
					+this is +input
				else
					+@clone().startOf(units) is +makeAs(input, this).startOf(units)

			min : deprecate 'moment().min is deprecated, use moment.min instead. https://github.com/moment/moment/issues/1548', (other)->
				other = moment.apply(null, arguments)
				(if other < this then this else other)

			max : deprecate 'moment().max is deprecated, use moment.max instead. https://github.com/moment/moment/issues/1548', (other)->
				other = moment.apply(null, arguments)
				(if other > this then this else other)

			zone : (input, keepLocalTime)->
				offset = @_offset or 0
				localAdjust = null
				if input?
					if typeof input is 'string'
						input = timezoneMinutesFromString(input)
					if Math.abs(input) < 16
						input = input * 60
					if not @_isUTC and keepLocalTime
						localAdjust = @_dateTzOffset()
					@_offset = input
					@_isUTC = true
					if localAdjust?
						@subtract localAdjust, 'm'
					if offset isnt input
						if not keepLocalTime or @_changeInProgress
							addOrSubtractDurationFromMoment this, moment.duration(offset - input, 'm'), 1, false
						else
							unless @_changeInProgress
								@_changeInProgress = true
								moment.updateOffset this, true
								@_changeInProgress = null
				else
					return (if @_isUTC then offset else @_dateTzOffset())
				@

			zoneAbbr : ->
				(if @_isUTC then 'UTC' else '')

			zoneName : ->
				(if @_isUTC then 'Coordinated Universal Time' else '')

			parseZone : ->
				if @_tzm
					@zone @_tzm
				else
					if typeof @_i is 'string'
						@zone @_i
				this

			hasAlignedHourOffset : (input)->
				unless input
					input = 0
				else
					input = moment(input).zone()
				(@zone() - input) % 60 is 0

			daysInMonth : ->
				daysInMonth @year(), @month()

			dayOfYear : (input)->
				dayOfYear = round((moment(@).startOf('day') - moment(@).startOf('year')) / 864e5) + 1
				(if not input? then dayOfYear else @add(input - dayOfYear, 'd'))

			quarter : (input)->
				(if not input? then Math.ceil((@month() + 1) / 3) else @month((input - 1) * 3 + @month() % 3))

			weekYear : (input)->
				year = weekOfYear(this, @localeData()._week.dow, @localeData()._week.doy).year
				(if not input? then year else @add(input - year, 'y'))

			isoWeekYear : (input)->
				year = weekOfYear(this, 1, 4).year
				(if not input? then year else @add(input - year, 'y'))

			week : (input)->
				week = @localeData().week(@)
				(if not input? then week else @add((input - week) * 7, 'd'))

			isoWeek : (input)->
				week = weekOfYear(this, 1, 4).week
				(if not input? then week else @add((input - week) * 7, 'd'))

			weekday : (input)->
				weekday = (@day() + 7 - @localeData()._week.dow) % 7
				(if not input? then weekday else @add(input - weekday, 'd'))

			isoWeekday : (input)->
				(if not input? then @day() or 7 else @day((if @day() % 7 then input else input - 7)))

			isoWeeksInYear : ->
				weeksInYear @year(), 1, 4

			weeksInYear : ->
				weekInfo = @localeData()._week
				weeksInYear @year(), weekInfo.dow, weekInfo.doy

			get : (units)->
				units = normalizeUnits units
				@[units]()

			set : (units, value)->
				units = normalizeUnits units
				if typeof @[units] is 'function'
					@[units] value
				@

			locale : (key)->
				newLocaleData = null
				if key is `undefined`
					@_locale._abbr
				else
					newLocaleData = moment.localeData(key)
					if newLocaleData?
						@_locale = newLocaleData
					@

			lang: deprecate 'moment().lang() is deprecated. Use moment().localeData() instead.', (key)->
				if key is `undefined`
					@localeData()
				else
					@locale key

			localeData : ->
				@_locale

			_dateTzOffset : ->
				Math.round(@_d.getTimezoneOffset() / 15) * 15

		moment.fn.millisecond = moment.fn.milliseconds = makeAccessor('Milliseconds', false)
		moment.fn.second = moment.fn.seconds = makeAccessor('Seconds', false)
		moment.fn.minute = moment.fn.minutes = makeAccessor('Minutes', false)
		moment.fn.hour = moment.fn.hours = makeAccessor('Hours', true)
		moment.fn.date = makeAccessor('Date', true)
		moment.fn.dates = deprecate('dates accessor is deprecated. Use date instead.', makeAccessor('Date', true))
		moment.fn.year = makeAccessor('FullYear', true)
		moment.fn.years = deprecate('years accessor is deprecated. Use year instead.', makeAccessor('FullYear', true))
		moment.fn.days = moment.fn.day
		moment.fn.months = moment.fn.month
		moment.fn.weeks = moment.fn.week
		moment.fn.isoWeeks = moment.fn.isoWeek
		moment.fn.quarters = moment.fn.quarter
		moment.fn.toJSON = moment.fn.toISOString
		extend moment.duration.fn = Duration::,
			_bubble : ->
				milliseconds = @_milliseconds
				days = @_days
				months = @_months
				data = @_data
				seconds = null
				minutes = null
				hours = null
				years = 0
				data.milliseconds = milliseconds % 1e3
				seconds = absRound(milliseconds / 1e3)
				data.seconds = seconds % 60
				minutes = absRound(seconds / 60)
				data.minutes = minutes % 60
				hours = absRound(minutes / 60)
				data.hours = hours % 24
				days += absRound(hours / 24)
				years = absRound(daysToYears(days))
				days -= absRound(yearsToDays(years))
				months += absRound(days / 30)
				days %= 30
				years += absRound(months / 12)
				months %= 12
				data.days = days
				data.months = months
				data.years = years
				return

			abs : ->
				@_milliseconds = Math.abs(@_milliseconds)
				@_days = Math.abs(@_days)
				@_months = Math.abs(@_months)
				@_data.milliseconds = Math.abs(@_data.milliseconds)
				@_data.seconds = Math.abs(@_data.seconds)
				@_data.minutes = Math.abs(@_data.minutes)
				@_data.hours = Math.abs(@_data.hours)
				@_data.months = Math.abs(@_data.months)
				@_data.years = Math.abs(@_data.years)
				this

			weeks : ->
				absRound @days() / 7

			valueOf : ->
				@_milliseconds + @_days * 864e5 + @_months % 12 * 2592e6 + toInt(@_months / 12) * 31536e6

			humanize : (withSuffix)->
				output = relativeTime(this, not withSuffix, @localeData())
				if withSuffix
					output = @localeData().pastFuture(+this, output)
				@localeData().postformat output

			add : (input, val)->
				dur = moment.duration(input, val)
				@_milliseconds += dur._milliseconds
				@_days += dur._days
				@_months += dur._months
				@_bubble()
				this

			subtract : (input, val)->
				dur = moment.duration(input, val)
				@_milliseconds -= dur._milliseconds
				@_days -= dur._days
				@_months -= dur._months
				@_bubble()
				this

			get : (units)->
				units = normalizeUnits(units)
				this[units.toLowerCase() + 's']()

			as : (units)->
				days = null
				months = null
				units = normalizeUnits(units)
				if units is 'month' or units is 'year'
					days = @_days + @_milliseconds / 864e5
					months = @_months + daysToYears(days) * 12
					if units is 'month'
						return months
					else
						return months / 12
				else
					days = @_days + yearsToDays(@_months / 12)
					switch units
						when 'week'
							return days / 7 + @_milliseconds / 6048e5
							# break
						when 'day'
							return days + @_milliseconds / 864e5
							# break
						when 'hour'
							return days * 24 + @_milliseconds / 36e5
							# break
						when 'minute'
							return days * 24 * 60 + @_milliseconds / 6e4
							# break
						when 'second'
							return days * 24 * 60 * 60 + @_milliseconds / 1e3
							# break
						when 'millisecond'
							return Math.floor(days * 24 * 60 * 60 * 1e3) + @_milliseconds
							# break
						else
							throw new Error('Unknown unit ' + units)
				return

			lang: moment.fn.lang
			locale: moment.fn.locale
			toIsoString : deprecate('toIsoString() is deprecated. Please use toISOString() instead ' + '(notice the capitals)', ->
				@toISOString()
			)
			toISOString : ->
				years = Math.abs(@years())
				months = Math.abs(@months())
				days = Math.abs(@days())
				hours = Math.abs(@hours())
				minutes = Math.abs(@minutes())
				seconds = Math.abs(@seconds() + @milliseconds() / 1e3)
				unless @asSeconds()
					return 'P0D'
				(if @asSeconds() < 0 then '-' else '') + 'P' + (if years then years + 'Y' else '') + (if months then months + 'M' else '') + (if days then days + 'D' else '') + (if hours or minutes or seconds then 'T' else '') + (if hours then hours + 'H' else '') + (if minutes then minutes + 'M' else '') + (if seconds then seconds + 'S' else '')

			localeData : ->
				@_locale

		moment.duration.fn.toString = moment.duration.fn.toISOString

		for i of unitMillisecondFactors
			if hasOwnProp(unitMillisecondFactors, i)
				makeDurationGetter i.toLowerCase()

		moment.duration.fn.asMilliseconds = ->
			@as 'ms'

		moment.duration.fn.asSeconds = ->
			@as 's'

		moment.duration.fn.asMinutes = ->
			@as 'm'

		moment.duration.fn.asHours = ->
			@as 'h'

		moment.duration.fn.asDays = ->
			@as 'd'

		moment.duration.fn.asWeeks = ->
			@as 'weeks'

		moment.duration.fn.asMonths = ->
			@as 'M'

		moment.duration.fn.asYears = ->
			@as 'y'

		moment.locale 'en',
			ordinal : (number)->
				b = number % 10
				output = (if toInt(number % 100 / 10) is 1 then 'th' else (if b is 1 then 'st' else (if b is 2 then 'nd' else (if b is 3 then 'rd' else 'th'))))
				number + output

		moment
	).call(@)
	_c.utils.moment = moment
	_c.datepicker
