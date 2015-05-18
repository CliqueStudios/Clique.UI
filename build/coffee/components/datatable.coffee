
((addon) ->

	if typeof define is 'function' and define.amd
		define 'clique-datatable', ['clique'], ->
			return addon(Clique)

	unless window.Clique
		throw new Error('Clique.datatable requires Clique.core')

	if window.Clique
		addon(Clique)
	return

) (_c) ->

	$ = _c.$

	_c.component 'datatableSearch',

		defaults :
			table : '' # Table selector [string]

		boot : ->
			_c.ready (context)->
				$('[data-datatable-search]', context).each ->
					ele = $(@)
					unless ele.data('clique.data.datatableSearch')
						obj = _c.datatableSearch(ele, _c.utils.options(ele.attr('data-datatable-search')))
						return

		init : ->
			table = _c.$(@options.table)
			@element.on 'keyup', (e)->
				val = $(@).val()
				datatable = table.data('clique.data.datatable')
				datatable.searchString val

	_c.component 'datatablePrevious',

		defaults :
			table : '' # Table selector [string]

		boot : ->
			_c.ready (context)->
				$('[data-datatable-previous]', context).each ->
					ele = $(@)
					unless ele.data('clique.data.datatablePrevious')
						obj = _c.datatablePrevious(ele, _c.utils.options(ele.attr('data-datatable-previous')))
						return

		init : ->
			@table = _c.$(@options.table)
			@tableInitHandler()
			@showPageListener()
			@bindClick()

		tableInitHandler : ->
			$this = @
			@table.on 'init.datatable.clique', (e)->
				$this.datatable = $(@).data('clique.data.datatable')
				$this.datatable.previousButton = $(@element)
				return

		showPageListener : ->
			$this = @
			@table.on 'didshow.page', ->
				if $this.datatable.disablePrevious
					$this.element.addClass 'disabled'
				else
					$this.element.removeClass 'disabled'

		bindClick : ->
			$this = @
			@on 'click', (e)->
				e.preventDefault()
				if $(@).hasClass('disabled') or $(@).attr('disabled')
					return false
				$this.table.trigger 'show.previous'


	_c.component 'datatableNext',

		defaults :
			table : '' # Table selector [string]

		boot : ->
			_c.ready (context)->
				$('[data-datatable-next]', context).each ->
					ele = $(@)
					unless ele.data('clique.data.datatableNext')
						obj = _c.datatableNext(ele, _c.utils.options(ele.attr('data-datatable-next')))
						return

		init : ->
			@table = _c.$(@options.table)
			@tableInitHandler()
			@showPageListener()
			@bindClick()

		tableInitHandler : ->
			$this = @
			@table.on 'init.datatable.clique', ->
				$this.datatable = $(@).data('clique.data.datatable')
				$this.datatable.nextButton = $(@element)
				return

		showPageListener : ->
			$this = @
			@table.on 'didshow.page', ->
				if $this.datatable.disableNext
					$this.element.addClass 'disabled'
				else
					$this.element.removeClass 'disabled'

		bindClick : ->
			$this = @
			@on 'click', (e)->
				e.preventDefault()
				if $(@).hasClass('disabled') or $(@).attr('disabled')
					return false
				$this.table.trigger 'show.next'

	_c.component 'datatable',

		defaults :
			paginationWrapper : '.datatable-pagination'
			perPage : 10
			infoWrapper : '.datatable-info'
			infoString : 'Showing rows #{start} through #{end} of #{total}'
			sortColumn : 0
			sortOrder : 'asc'

		currentPage : 0
		columns : []
		elements : {}

		boot : ->
			_c.ready (context)->
				$('[data-datatable]', context).each ->
					ele = $(@)
					unless ele.data('clique.data.datatable')
						obj = _c.datatable ele, _c.utils.options(ele.attr('data-datatable'))
						return
				return
			return

		init : ->
			@setProperties()
			@bindListeners()
			@bindEvents()
			@addObserver()
			if ! @observerIsTriggered
				@observerCallback()
			setTimeout =>
				@trigger 'init.datatable.clique', [ @options ]
			, 0

		findElement : (root, selector)->
			if selector[0] is '#'
				return $ selector
			parents = root.parents()
			output = null
			parents.each ->
				if $(@).find(selector).length
					output = $(@).find(selector)
					return false
			return output

		setProperties : ->
			@elements.tbody = @find '> tbody'
			@elements.thead = @find '> thead'
			@elements.th = @elements.thead.find '> tr > th'
			if @options.paginationWrapper
				@elements.pagination = @findElement @element, @options.paginationWrapper
			@setColumns()

		setColumns : ->
			columns = []
			@elements.th.each (i)->
				th = $(@)
				html = th.html()
				_html = $('<div></div>')
				_html.append html
				_html.children().each ->
					$(@).remove()
				$(@).width $(@).outerWidth()
				columns.push {
					index : i
					title : _html.text().trim()
					width : $(@).outerWidth()
				}
			@columns = columns
			return

		setDataProperties : (data)->
			@data = data
			if ! @originalData and @data.length
				@originalData = @data
			@dataLength = @data.length
			if ! @options.paginationWrapper
				@options.perPage = @dataLength
			@pages = Math.ceil(@dataLength / @options.perPage) - 1
			return

		buildPagination : ->
			selector = @options.paginationWrapper
			$this = @
			if ! @pagination or ! @pagination.length
				parents = @element.parents()
				parents.each ->
					if $(@).find(selector).length
						$this.pagination = $(@).find(selector)
						return false
			if @pagination.length and ! @pagination.find('> *').length
				i = 0
				html = '';
				while i < @pages + 1
					if i is @pages
						html += "<span>...</span>"
					html += "<a href='#' data-datatable-page='#{i}'>#{(i + 1)}</a>"
					if i is 0
						html += "<span>...</span>"
					i++
				@pagination.append html
				setTimeout =>
					@bindPaginationEvents()
				, 0

		buildComplexPagination : ->
			i = 0
			if @currentPage < 3
				@pagination.find('> span').first().hide()
				@pagination.find('> span').last().css('display', 'inline-block')
				pages = [0, 1, 2, 3, @pages]
			else if @currentPage > @pages - 3
				@pagination.find('> span').first().css('display', 'inline-block')
				@pagination.find('> span').last().hide()
				pages = [0, @pages - 3, @pages - 2, @pages - 1, @pages]
			else
				@pagination.find('> span').css('display', 'inline-block')
				pages = [0, @currentPage - 1, @currentPage, @currentPage + 1, @pages]
			@pagination.find('> [data-datatable-page]').each ->
				page = $(@).data 'datatable-page'
				if pages.indexOf(page) < 0
					$(@).hide()
				else
					$(@).show()

		updatePaginationVisibility : ->
			i = 0
			@pagination.find('> a, > span').hide()
			while i < @pages + 1
				@pagination.find("> [data-datatable-page='#{i}']").css('display', 'inline-block')
				i++

		bindPaginationEvents : ->
			$this = @
			@pagination.on 'click', '> a', (e)->
				e.preventDefault()
				idx = $(@).data 'datatable-page'
				$this.showPage idx

		updatePagination : ->
			if ! @options.paginate
				return
			@buildPagination()
			if @pages > 6
				@buildComplexPagination()
			else
				@updatePaginationVisibility()
			if @pagination and @pagination.length
				@pagination.find('> a').removeClass 'current'
				@pagination.find("> [data-datatable-page='#{@currentPage}']").addClass 'current'

		bindEvents : ->
			$this = @
			@elements.thead.on 'click', '[data-datatable-sort]', (e)->
				e.preventDefault()
				idx = $(@).closest('th').index()
				$this.sortEventHandler idx
			@elements.thead.on 'click', '[data-datatable-hide]', (e)->
				e.preventDefault()
				idx = $(@).closest('th').index()
				$this.hideEventHandler idx

		sortEventHandler : (idx)->
			if @options.sortColumn is idx
				if @options.sortOrder is 'desc'
					@options.sortColumn = -1
				@options.sortOrder = if @options.sortOrder is 'asc' then 'desc' else 'asc'
			else
				@options.sortColumn = idx
				@options.sortOrder = 'asc'
			@trigger 'sort', [ @options.sortColumn, @options.sortOrder ]

		hideEventHandler : (idx)->
			if @options.hidden.indexOf(idx) > -1
				return
			info = @columnInfo idx
			@trigger 'hide.column', [ info ]

		bindListeners : ->
			$this = @
			@on 'show.page', (e, pageIndex)->
				$this.showPage pageIndex
			@on 'show.next', ->
				$this.showNextPage()
			@on 'show.previous', ->
				$this.showPreviousPage()
			@on 'sort', (e, columnIndex, sortOrder)->
				$this.sortByColumn columnIndex, sortOrder
			@on 'hide.column', (e, columnInfo)->
				$this.hideColumn columnInfo
			@on 'hide.columns', (e, columnIndexes)->
				$this.hideColumns columnIndexes
			@on 'show.column', (e, columnIndex)->
				$this.showColumn columnIndex

		addObserver : ->
			tbody = @elements.tbody
			_c.domObserve tbody[0], =>
				@observerCallback()

		removeObserver : ->
			tbody = @elements.tbody
			observer = tbody.data 'observer'
			observer.disconnect()

		observerCallback : ->
			@observerIsTriggered = true
			tbody = @elements.tbody
			@hasRows = !!tbody.find('> tr').length
			@cacheData()
			# $this = @
			if @options.sortColumn > -1
				setTimeout =>
					@trigger 'sort', [ @options.sortColumn, @options.sortOrder ]
				, 0
			if @options.paginate and @options.sortColumn < 0
				setTimeout =>
					@trigger 'show.page', [ @currentPage ]
				, 0
			if @options.hidden.length
				setTimeout =>
					@trigger 'hide.columns', [ @options.hidden ]
				, 0
			setTimeout =>
				@observerIsTriggered = false
				return
			, 0

		cacheData : ->
			tbody = @elements.tbody
			if ! @hasRows
				return
			data = []
			columns = @columns
			isNumber = _c.utils.isNumber
			isDate = _c.utils.isDate
			tbody.find('> tr').each ->
				rowData = []
				$(@).find('> *').each (i)->
					text = $(@).text()
					html = $(@).html()
					if isNumber text
						value = parseFloat text
					else if isDate text
						value = new Date(text)
					else
						value = text
					cell =
						index : i
						key : columns[i].title
						value : value
						text : text
						html : html
					rowData.push cell
				data.push rowData
			$this = @
			setTimeout ->
				$this.setDataProperties data
			, 0

		sortByColumn : (columnIndex, sortOrder = 'asc')->
			columnIndex = parseInt columnIndex, 10
			if columnIndex < 0
				@printOriginalData()
				return
			sortOrder = sortOrder.toLowerCase()
			if sortOrder isnt 'asc' and sortOrder isnt 'desc'
				sortOrder = 'asc'
			columnData = @getDataForColumn columnIndex
			compare = (a, b)->
				if sortOrder is 'asc'
					if (a.value < b.value)
						return -1
					if (a.value > b.value)
						return 1
				else
					if (a.value > b.value)
						return -1
					if (a.value < b.value)
						return 1
				0
			sortedData = columnData.sort compare
			newData = []
			for cellData in sortedData
				newData.push @data[cellData.index]
			@setDataProperties newData
			@addSortClass columnIndex, sortOrder
			@trigger 'show.page', [ @currentPage ]

		printOriginalData : ->
			@setDataProperties @originalData
			@removeSortClass()
			@trigger 'show.page', [ @currentPage ]

		addSortClass : (columnIndex, sortOrder)->
			@removeSortClass()
			@elements.th.eq(columnIndex).addClass "sort-#{sortOrder}"

		removeSortClass : ->
			@elements.th.removeClass 'sort-asc sort-desc'

		hideColumns : (columnIndexes)->
			for idx in columnIndexes
				info = @columnInfo idx
				@trigger 'hide.column', [ info ]

		hideColumn : (columnInfo)->
			@find('> * > tr').each ->
				$(@).find('> *').eq(columnInfo.index).hide()
			hidden = @options.hidden
			hidden.push columnInfo.index
			hidden = $.unique hidden
			@options.hidden = hidden
			return

		showColumn : (columnIndex)->
			hidden = @options.hidden
			optionIndex = hidden.indexOf columnIndex
			if optionIndex > -1
				@find('> * > tr').each ->
					$(@).find('> *').eq(columnIndex).show()
				hidden.splice optionIndex, 1
				hidden = $.unique hidden
				@options.hidden = hidden
				return

		showNextPage : ->
			pageIndex = @currentPage + 1
			pageIndex = if pageIndex > @pages then @pages else pageIndex
			@showPage pageIndex

		showPreviousPage : ->
			pageIndex = @currentPage - 1
			pageIndex = if pageIndex < 0 then 0 else pageIndex
			@showPage pageIndex

		showPage : (pageIndex)->
			if ! @hasRows or ! @dataLength
				return
			@removeObserver()
			@removeAllRows()
			start = @options.perPage * pageIndex
			end = start + @options.perPage
			end = if end > @dataLength then @dataLength else end
			data = @getDataForRange start, end
			for rowData in data
				@addRow rowData
			$this = @
			table = @element
			setTimeout ->
				$this.currentPage = pageIndex
				$this.disablePrevious = if start is 0 then true else false
				$this.disableNext = if $this.currentPage is $this.pages then true else false
				$this.updatePagination()
				table.trigger 'didshow.page', [ $this.currentPage, (if start is 0 then 1 else start), end, $this.dataLength ]
				$this.addObserver()
			, 0

		addRow : (rowData)->
			tr = $('<tr />')
			hidden = @options.hidden
			setHidden = !!hidden.length
			for cellData in rowData
				content = cellData.text
				if setHidden and hidden.indexOf(cellData.index) > -1
					td = $("<td style='display:none;'>#{content}</td>")
				else
					td = $("<td>#{content}</td>")
				tr.append td
			@elements.tbody.append tr

		removeAllRows : ->
			tbody = @elements.tbody
			tbody.find('> *').remove()

		getDataForRange : (start, end)->
			i = start
			output = []
			while i < end
				output.push @data[i]
				i++
			output

		getDataForColumn : (columnIndex)->
			if ! @data or ! @dataLength
				return []
			output = []
			for i, rowData of @data
				columnData = rowData[columnIndex]
				output.push {
					index : parseInt i, 10
					value : columnData.value
				}
			output

		columnInfo : (columnIndex)->
			if ! @data or ! @dataLength
				return {}
			return {
				title : @data[0][columnIndex].key
				index : columnIndex
			}

		searchString : (string, columnIndexes = [])->
			string = string.trim()
			if ! string or ! string.length
				@printOriginalData()
				return
			if ! columnIndexes.length
				for column in @columns
					if @options.hidden.indexOf(column.index) < 0
						columnIndexes.push column.index
			output = []
			i = 0
			while i < @originalData.length
				rowData = @originalData[i]
				rowString = ''
				for columnIndex in columnIndexes
					cellData = rowData[columnIndex]
					rowString += ' ' + cellData.html
				rowString = rowString.trim()
				if rowString.indexOf(string) > -1
					output.push rowData
				i++
			@setDataProperties output
			@showPage 0

		destroy : ->
			@restoreOriginalRows()
			@removePagination()
			@unbindEvents()
			@removeStyle()
			@removeData()
			setTimeout =>
				@trigger 'destroy.datatable.clique'
			, 0

		restoreOriginalRows : ->
			@removeAllRows()
			for rowData in @originalData
				@addRow rowData

		removePagination : ->
			@pagination.find('> *').remove()

		unbindEvents : ->
			@find('[data-datatable-hide]').off 'click'
			@find('[data-datatable-sort]').off 'click'
			@previousButton.off 'click'
			@nextButton.off 'click'

		removeStyle : ->
			@elements.th.removeAttr 'style'
			@elements.tbody.find('td').removeAttr 'style'

		removeData : ->
			@element.removeData 'clique.data.datatable'

