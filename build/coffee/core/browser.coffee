
((addon)->

	if typeof define is 'function' and define.amd
		define 'clique-browser', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.browser requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c)->

	$ = _c.$

	_c.component 'browser',

		defaults :
			addClasses: true
			detectDevice : true
			detectScreen : true
			detectOS : true
			detectBrowser : true
			detectLanguage : true
			detectPlugins : true
			detectSupport : ['flex', 'animation']

		device :
			type : ''
			model : ''
			orientation : ''

		browser :
			engine: ''
			major: ''
			minor: ''
			name: ''
			patch: ''
			version: ''

		screen :
			size : ''
			touch : false

		deviceTypes : [ 'tv', 'tablet', 'mobile', 'desktop' ]

		screens :
			mini : 0
			small : 480
			medium : 768
			large : 960
			xlarge : 1220

		browserLanguage :
			direction : ''
			code : ''

		boot : ->
			_c.ready (context)->
				ele = _c.$doc
				unless ele.data 'clique.data.browser'
					obj = _c.browser ele
					return

		init : ->
			@getProperties()
			$this = @
			_c.$win.on 'resize orientationchange', _c.utils.debounce ->
				$this.getProperties()
			, 250

		getProperties : ->
			win = _c.$win[0]
			@userAgent = (win.navigator.userAgent or win.navigator.vendor or win.opera).toLowerCase()
			if !!@options.detectDevice
				@detectDevice()
			if !!@options.detectScreen
				@detectScreen()
			if !!@options.detectOS
				@detectOS()
			if !!@options.detectBrowser
				@detectBrowser()
			if !!@options.detectPlugins
				@detectPlugins()
			if !!@options.detectLanguage
				@detectLanguage()
			if !!@options.detectSupport
				@detectSupport()
			setTimeout =>
				if @options.addClasses
					@addClasses()
				@trigger 'updated.browser.clique'
			, 0

		test : (rgx)->
			rgx.test @userAgent

		exec : (rgx)->
			rgx.exec @userAgent

		uamatches : (key)->
			@userAgent.indexOf(key) > -1

		version : (versionType, versionFull)->
			versionType.version = versionFull
			versionArray = versionFull.split('.')
			if versionArray.length > 0
				versionArray = versionArray.reverse()
				versionType.major = versionArray.pop()
				if versionArray.length > 0
					versionType.minor = versionArray.pop()
					if versionArray.length > 0
						versionArray = versionArray.reverse()
						versionType.patch = versionArray.join('.')
						return
					else
						versionType.patch = '0'
						return
				else
					versionType.minor = '0'
					return
			else
				versionType.major = '0'
				return

		detectDevice : ->
			device = @device
			if @test(/googletv|smarttv|smart-tv|internet.tv|netcast|nettv|appletv|boxee|kylo|roku|dlnadoc|roku|pov_tv|hbbtv|ce\-html/)
				device.type = @deviceTypes[0]
				device.model = 'smarttv'
			else if @test(/xbox|playstation.3|wii/)
				device.type = @deviceTypes[0]
				device.model = 'console'
			else if @test(/ip(a|ro)d/)
				device.type = @deviceTypes[1]
				device.model = 'ipad'
			else if (@test(/tablet/) and not @test(/rx-34/)) or @test(/folio/)
				device.type = @deviceTypes[1]
				device.model = String(@exec(/playbook/) or '')
			else if @test(/linux/) and @test(/android/) and not @test(/fennec|mobi|htc.magic|htcX06ht|nexus.one|sc-02b|fone.945/)
				device.type = @deviceTypes[1]
				device.model = 'android'
			else if @test(/kindle/) or (@test(/mac.os/) and @test(/silk/))
				device.type = @deviceTypes[1]
				device.model = 'kindle'
			else if @test(/gt-p10|sc-01c|shw-m180s|sgh-t849|sch-i800|shw-m180l|sph-p100|sgh-i987|zt180|htc(.flyer|\_flyer)|sprint.atp51|viewpad7|pandigital(sprnova|nova)|ideos.s7|dell.streak.7|advent.vega|a101it|a70bht|mid7015|next2|nook/) or (@test(/mb511/) and @test(/rutem/))
				device.type = @deviceTypes[1]
				device.model = 'android'
			else if @test(/bb10/)
				device.type = @deviceTypes[1]
				device.model = 'blackberry'
			else
				device.model = @exec(/iphone|ipod|android|blackberry|opera mini|opera mobi|skyfire|maemo|windows phone|palm|iemobile|symbian|symbianos|fennec|j2me/)
				if device.model isnt null
					device.type = @deviceTypes[2]
					device.model = String(device.model)
				else
					device.model = ''
					if @test(/bolt|fennec|iris|maemo|minimo|mobi|mowser|netfront|novarra|prism|rx-34|skyfire|tear|xv6875|xv6975|google.wireless.transcoder/)
						device.type = @deviceTypes[2]
					else if @test(/opera/) and @test(/windows.nt.5/) and @test(/htc|xda|mini|vario|samsung\-gt\-i8000|samsung\-sgh\-i9/)
						device.type = @deviceTypes[2]
					else if (@test(/windows.(nt|xp|me|9)/) and not @test(/phone/)) or @test(/win(9|.9|nt)/) or @test(/\(windows 8\)/)
						device.type = @deviceTypes[3]
					else if @test(/macintosh|powerpc/) and not @test(/silk/)
						device.type = @deviceTypes[3]
						device.model = 'mac'
					else if @test(/linux/) and @test(/x11/)
						device.type = @deviceTypes[3]
					else if @test(/solaris|sunos|bsd/)
						device.type = @deviceTypes[3]
					else if @test(/cros/)
						device.type = @deviceTypes[3]
					else if @test(/bot|crawler|spider|yahoo|ia_archiver|covario-ids|findlinks|dataparksearch|larbin|mediapartners-google|ng-search|snappy|teoma|jeeves|tineye/) and not @test(/mobile/)
						device.type = @deviceTypes[3]
						device.model = 'crawler'
					else
						device.type = @deviceTypes[3]
			if device.type isnt 'desktop' and device.type isnt 'tv'
				w = _c.$win.outerWidth()
				h = _c.$win.outerHeight()
				device.orientation = 'landscape'
				if h > w
					device.orientation = 'portrait'
			@device = device
			return

		detectScreen : ->
			w = _c.$win.width()
			for k, v of @screens
				if w > (v - 1)
					@screen.size = k
			@detectTouch()
			return

		detectTouch : ->
			win = _c.$win[0]
			doc = _c.$doc[0]
			touch = 'ontouchstart' of win and win.navigator.userAgent.toLowerCase().match(/mobile|tablet/) or win.DocumentTouch and doc instanceof win.DocumentTouch or win.navigator.msPointerEnabled and win.navigator.msMaxTouchPoints > 0 or win.navigator.pointerEnabled and win.navigator.maxTouchPoints > 0 or false
			@screen.touch = !!touch
			return

		detectOS : ->
			device = @device
			os = {}
			if device.model isnt ''
				if device.model is 'ipad' or device.model is 'iphone' or device.model is 'ipod'
					os.name = 'ios'
					@version os, (if @test(/os\s([\d_]+)/) then RegExp.$1 else '').replace(/_/g, '.')
				else if device.model is 'android'
					os.name = 'android'
					@version os, (if @test(/android\s([\d\.]+)/) then RegExp.$1 else '')
				else if device.model is 'blackberry'
					os.name = 'blackberry'
					@version os, (if @test(/version\/([^\s]+)/) then RegExp.$1 else '')
				else if device.model is 'playbook'
					os.name = 'blackberry'
					@version os, (if @test(/os ([^\s]+)/) then RegExp.$1.replace(';', '') else '')
			unless os.name
				if @uamatches('win') or @uamatches('16bit')
					os.name = 'windows'
					if @uamatches('windows nt 6.3')
						@version os, '8.1'
					else if @uamatches('windows nt 6.2') or @test(/\(windows 8\)/)
						@version os, '8'
					else if @uamatches('windows nt 6.1')
						@version os, '7'
					else if @uamatches('windows nt 6.0')
						@version os, 'vista'
					else if @uamatches('windows nt 5.2') or @uamatches('windows nt 5.1') or @uamatches('windows xp')
						@version os, 'xp'
					else if @uamatches('windows nt 5.0') or @uamatches('windows 2000')
						@version os, '2k'
					else if @uamatches('winnt') or @uamatches('windows nt')
						@version os, 'nt'
					else if @uamatches('win98') or @uamatches('windows 98')
						@version os, '98'
					else @version os, '95'	if @uamatches('win95') or @uamatches('windows 95')
				else if @uamatches('mac') or @uamatches('darwin')
					os.name = 'mac os'
					if @uamatches('68k') or @uamatches('68000')
						@version os, '68k'
					else if @uamatches('ppc') or @uamatches('powerpc')
						@version os, 'ppc'
					else @version os, (if @test(/os\sx\s([\d_]+)/) then RegExp.$1 else 'os x').replace(/_/g, '.')	if @uamatches('os x')
				else if @uamatches('webtv')
					os.name = 'webtv'
				else if @uamatches('x11') or @uamatches('inux')
					os.name = 'linux'
				else if @uamatches('sunos')
					os.name = 'sun'
				else if @uamatches('irix')
					os.name = 'irix'
				else if @uamatches('freebsd')
					os.name = 'freebsd'
				else os.name = 'bsd'	if @uamatches('bsd')
			if @test(/\sx64|\sx86|\swin64|\swow64|\samd64/)
				os.addressRegisterSize = '64bit'
			else
				os.addressRegisterSize = '32bit'
			@operatingSystem = os
			return

		detectBrowser : ->
			browser = {}
			if not @test(/opera|webtv/) and (@test(/msie\s([\d\w\.]+)/) or @uamatches('trident'))
				browser.engine = 'trident'
				browser.name = 'ie'
				if not window.addEventListener and document.documentMode and document.documentMode is 7
					@version browser, '8.compat'
				else if @test(/trident.*rv[ :](\d+)\./)
					@version browser, RegExp.$1
				else
					@version browser, (if @test(/trident\/4\.0/) then '8' else RegExp.$1)
			else if @uamatches('firefox')
				browser.engine = 'gecko'
				browser.name = 'firefox'
				@version browser, (if @test(/firefox\/([\d\w\.]+)/) then RegExp.$1 else '')
			else if @uamatches('gecko/')
				browser.engine = 'gecko'
			else if @uamatches('opera') or @uamatches('opr')
				browser.name = 'opera'
				browser.engine = 'presto'
				@version browser, (if @test(/version\/([\d\.]+)/) then RegExp.$1 else (if @test(/opera(\s|\/)([\d\.]+)/) then RegExp.$2 else ''))
			else if @uamatches('konqueror')
				browser.name = 'konqueror'
			else if @uamatches('chrome')
				browser.engine = 'webkit'
				browser.name = 'chrome'
				@version browser, (if @test(/chrome\/([\d\.]+)/) then RegExp.$1 else '')
			else if @uamatches('iron')
				browser.engine = 'webkit'
				browser.name = 'iron'
			else if @uamatches('crios')
				browser.name = 'chrome'
				browser.engine = 'webkit'
				@version browser, (if @test(/crios\/([\d\.]+)/) then RegExp.$1 else '')
			else if @uamatches('applewebkit/')
				browser.name = 'safari'
				browser.engine = 'webkit'
				@version browser, (if @test(/version\/([\d\.]+)/) then RegExp.$1 else '')
			else browser.engine = 'gecko'	if @uamatches('mozilla/')
			@browser = browser
			return

		detectLanguage : ->
			body = _c.$body[0]
			win = _c.$win[0]
			@browserLanguage.direction = win.getComputedStyle(body).direction or 'ltr'
			@browserLanguage.code = win.navigator.userLanguage or win.navigator.language
			return

		detectPlugins : ->
			@plugins = []
			if typeof window.navigator.plugins isnt 'undefined'
				for plugin in window.navigator.plugins
					@plugins.push plugin.name

		detectSupport : ->
			supports = do->
				div = _c.$doc[0].createElement('div')
				vendors = 'Khtml Ms ms O Moz Webkit'.split(' ')
				(prop)->
					if typeof div.style[prop] isnt 'undefined'
						return true
					prop = prop.replace /^[a-z]/, (val)->
						val.toUpperCase()
					for vendor in vendors
						if typeof div.style[vendor + prop] isnt 'undefined'
							return true
					false
			if ! @css
				@css = {}
			for check in @options.detectSupport
				@css[check] = supports check
				return

		addClasses : ->
			@removeClasses()
			if @browser.name
				nameClass = @browser.name
				if nameClass is 'ie'
					nameClass += " ie#{@browser.major}"
				@classes.push nameClass
				_c.$html.addClass nameClass
			if @device.type
				typeClass = @device.type
				@classes.push typeClass
				_c.$html.addClass typeClass
			if @device.model
				modelClass = @device.model
				@classes.push modelClass
				_c.$html.addClass modelClass
			if @device.orientation
				orientationClass = @device.orientation
				@classes.push orientationClass
				_c.$html.addClass orientationClass
			if @screen.size
				sizeClass = "screen-#{@screen.size}"
				@classes.push sizeClass
				_c.$html.addClass sizeClass
			for k, v of @css
				if ! v
					supportClass = "no#{k}"
					@classes.push supportClass
					_c.$html.addClass supportClass
			touchClass = if @screen.touch then 'touch' else 'notouch'
			@classes.push touchClass
			_c.$html.addClass touchClass
			if @browserLanguage.direction
				_c.$html.attr 'dir', @browserLanguage.direction
			if @browserLanguage.code
				_c.$html.attr 'lang', @browserLanguage.code

		removeClasses : ->
			if ! @classes
				@classes = []
			$.each @classes, (idx, selector)->
				_c.$html.removeClass selector
			@classes = []
			return
