(function(addon) {
	if(typeof define === "function" && define.amd) {
		define("clique-datatable", ["clique"], function() {
			return addon(Clique);
		});
	}
	if(!window.Clique) {
		throw new Error("Clique.datatable requires Clique.core");
	}
	if(window.Clique) {
		addon(Clique);
	}
})(function(_c) {
	var $;
	$ = _c.$;
	_c.component("datatableSearch", {
		defaults: {
			table: ""
		},
		boot: function() {
			return _c.ready(function(context) {
				return $("[data-datatable-search]", context).each(function() {
					var ele, obj;
					ele = $(this);
					if(!ele.data("clique.data.datatableSearch")) {
						obj = _c.datatableSearch(ele, _c.utils.options(ele.attr("data-datatable-search")));
					}
				});
			});
		},
		init: function() {
			var table;
			table = _c.$(this.options.table);
			return this.element.on("keyup", function(e) {
				var datatable, val;
				val = $(this).val();
				datatable = table.data("clique.data.datatable");
				return datatable.searchString(val);
			});
		}
	});
	_c.component("datatablePrevious", {
		defaults: {
			table: ""
		},
		boot: function() {
			return _c.ready(function(context) {
				return $("[data-datatable-previous]", context).each(function() {
					var ele, obj;
					ele = $(this);
					if(!ele.data("clique.data.datatablePrevious")) {
						obj = _c.datatablePrevious(ele, _c.utils.options(ele.attr("data-datatable-previous")));
					}
				});
			});
		},
		init: function() {
			this.table = _c.$(this.options.table);
			this.tableInitHandler();
			this.showPageListener();
			return this.bindClick();
		},
		tableInitHandler: function() {
			var $this;
			$this = this;
			return this.table.on("init.datatable.clique", function(e) {
				$this.datatable = $(this).data("clique.data.datatable");
				$this.datatable.previousButton = $(this.element);
			});
		},
		showPageListener: function() {
			var $this;
			$this = this;
			return this.table.on("didshowpage.datatable.clique", function() {
				if($this.datatable.disablePrevious) {
					return $this.element.addClass("disabled");
				} else {
					return $this.element.removeClass("disabled");
				}
			});
		},
		bindClick: function() {
			var $this;
			$this = this;
			return this.on("click", function(e) {
				e.preventDefault();
				if($(this).hasClass("disabled") || $(this).attr("disabled")) {
					return false;
				}
				return $this.table.trigger("previous.datatable.clique");
			});
		}
	});
	_c.component("datatableNext", {
		defaults: {
			table: ""
		},
		boot: function() {
			return _c.ready(function(context) {
				return $("[data-datatable-next]", context).each(function() {
					var ele, obj;
					ele = $(this);
					if(!ele.data("clique.data.datatableNext")) {
						obj = _c.datatableNext(ele, _c.utils.options(ele.attr("data-datatable-next")));
					}
				});
			});
		},
		init: function() {
			this.table = _c.$(this.options.table);
			this.tableInitHandler();
			this.showPageListener();
			return this.bindClick();
		},
		tableInitHandler: function() {
			var $this;
			$this = this;
			return this.table.on("init.datatable.clique", function() {
				$this.datatable = $(this).data("clique.data.datatable");
				$this.datatable.nextButton = $(this.element);
			});
		},
		showPageListener: function() {
			var $this;
			$this = this;
			return this.table.on("didshowpage.datatable.clique", function() {
				if($this.datatable.disableNext) {
					return $this.element.addClass("disabled");
				} else {
					return $this.element.removeClass("disabled");
				}
			});
		},
		bindClick: function() {
			var $this;
			$this = this;
			return this.on("click", function(e) {
				e.preventDefault();
				if($(this).hasClass("disabled") || $(this).attr("disabled")) {
					return false;
				}
				return $this.table.trigger("next.datatable.cliquet");
			});
		}
	});
	return _c.component("datatable", {
		defaults: {
			paginationWrapper: ".datatable-pagination",
			perPage: 10,
			infoWrapper: ".datatable-info",
			infoString: "Showing rows #{start} through #{end} of #{total}",
			sortColumn: 0,
			sortOrder: "asc"
		},
		currentPage: 0,
		columns: [],
		elements: {},
		boot: function() {
			_c.ready(function(context) {
				$("[data-datatable]", context).each(function() {
					var ele, obj;
					ele = $(this);
					if(!ele.data("clique.data.datatable")) {
						obj = _c.datatable(ele, _c.utils.options(ele.attr("data-datatable")));
					}
				});
			});
		},
		init: function() {
			this.setProperties();
			this.bindListeners();
			this.bindEvents();
			this.addObserver();
			if(!this.observerIsTriggered) {
				this.observerCallback();
			}
			return setTimeout(function(_this) {
				return function() {
					return _this.trigger("init.datatable.clique", [_this.options]);
				};
			}(this), 0);
		},
		findElement: function(root, selector) {
			var output, parents;
			if(selector[0] === "#") {
				return $(selector);
			}
			parents = root.parents();
			output = null;
			parents.each(function() {
				if($(this).find(selector).length) {
					output = $(this).find(selector);
					return false;
				}
			});
			return output;
		},
		setProperties: function() {
			this.elements.tbody = this.find("> tbody");
			this.elements.thead = this.find("> thead");
			this.elements.th = this.elements.thead.find("> tr > th");
			if(this.options.paginationWrapper) {
				this.elements.pagination = this.findElement(this.element, this.options.paginationWrapper);
			}
			if(this.options.infoWrapper) {
				this.elements.infoWrapper = this.findElement(this.element, this.options.infoWrapper);
			}
			return this.setColumns();
		},
		setColumns: function() {
			var columns;
			columns = [];
			this.elements.th.each(function(i) {
				var html, th, _html;
				th = $(this);
				html = th.html();
				_html = $("<div></div>");
				_html.append(html);
				_html.children().each(function() {
					return $(this).remove();
				});
				$(this).width($(this).outerWidth());
				return columns.push({
					index: i,
					title: _html.text().trim(),
					width: $(this).outerWidth()
				});
			});
			this.columns = columns;
		},
		setDataProperties: function(data) {
			this.data = data;
			if(!this.originalData && this.data.length) {
				this.originalData = this.data;
			}
			this.dataLength = this.data.length;
			if(!this.options.paginationWrapper) {
				this.options.perPage = this.dataLength;
			}
			this.pages = Math.ceil(this.dataLength / this.options.perPage) - 1;
		},
		buildPagination: function() {
			var $this, hasPaginationClass, html, i, parents, selector;
			selector = this.options.paginationWrapper;
			$this = this;
			if(!this.pagination || !this.pagination.length) {
				parents = this.element.parents();
				parents.each(function() {
					if($(this).find(selector).length) {
						$this.pagination = $(this).find(selector);
						return false;
					}
				});
			}
			console.log(this.pagination);
			if(this.pagination.length && !this.pagination.find("> *").length) {
				console.log(this.pagination);
				hasPaginationClass = this.pagination.hasClass("pagination");
				i = 0;
				html = "";
				while(i < this.pages + 1) {
					if(i === this.pages) {
						html += "<span>...</span>";
					}
					html += hasPaginationClass ? "<li><a href='#' data-datatable-page='" + i + "'>" + (i + 1) + "</a></li>" : "<a href='#' data-datatable-page='" + i + "'>" + (i + 1) + "</a>";
					if(i === 0) {
						html += "<span>...</span>";
					}
					i++;
				}
				this.pagination.append(html);
				return setTimeout(function(_this) {
					return function() {
						return _this.bindPaginationEvents();
					};
				}(this), 0);
			}
		},
		buildComplexPagination: function() {
			var i, pages;
			i = 0;
			if(this.currentPage < 3) {
				this.pagination.find("> span").first().hide();
				this.pagination.find("> span").last().css("display", "inline-block");
				pages = [0, 1, 2, 3, this.pages];
			} else {
				if(this.currentPage > this.pages - 3) {
					this.pagination.find("> span").first().css("display", "inline-block");
					this.pagination.find("> span").last().hide();
					pages = [0, this.pages - 3, this.pages - 2, this.pages - 1, this.pages];
				} else {
					this.pagination.find("> span").css("display", "inline-block");
					pages = [0, this.currentPage - 1, this.currentPage, this.currentPage + 1, this.pages];
				}
			}
			return this.pagination.find("> [data-datatable-page]").each(function() {
				var page;
				page = $(this).data("datatable-page");
				if(pages.indexOf(page) < 0) {
					return $(this).hide();
				} else {
					return $(this).show();
				}
			});
		},
		updatePaginationVisibility: function() {
			var i, link, _results;
			i = 0;
			this.pagination.find("[data-datatable-page]").hide();
			_results = [];
			while(i < this.pages + 1) {
				link = this.pagination.find("[data-datatable-page='" + i + "']");
				link.css("display", "inline-block");
				_results.push(i++);
			}
			return _results;
		},
		bindPaginationEvents: function() {
			return this.pagination.on("click", "[data-datatable-page]", function(_this) {
				return function(e) {
					var idx;
					e.preventDefault();
					idx = $(e.target).data("datatable-page");
					return _this.trigger("showpage.datatable.clique", [idx]);
				};
			}(this));
		},
		updatePagination: function() {
			if(!this.options.paginationWrapper || !this.elements.pagination || !this.elements.pagination.length) {
				return;
			}
			this.buildPagination();
			if(this.pages > 6) {
				this.buildComplexPagination();
			} else {
				this.updatePaginationVisibility();
			}
			if(this.pagination && this.pagination.length) {
				if(this.pagination.hasClass("pagination")) {
					this.pagination.find("[data-datatable-page]").parent().removeClass("active");
					return this.pagination.find("[data-datatable-page='" + this.currentPage + "']").parent().addClass("active");
				} else {
					this.pagination.find("[data-datatable-page]").removeClass("active");
					return this.pagination.find("[data-datatable-page='" + this.currentPage + "']").addClass("active");
				}
			}
		},
		bindEvents: function() {
			return this.elements.thead.on("click", ".datatable-sort", function(_this) {
				return function(e) {
					var idx;
					e.preventDefault();
					idx = $(e.target).closest("th").index();
					return _this.sortEventHandler(idx);
				};
			}(this));
		},
		sortEventHandler: function(idx) {
			if(this.options.sortColumn === idx) {
				if(this.options.sortOrder === "desc") {
					this.options.sortColumn = -1;
				}
				this.options.sortOrder = this.options.sortOrder === "asc" ? "desc" : "asc";
			} else {
				this.options.sortColumn = idx;
				this.options.sortOrder = "asc";
			}
			return this.trigger("sort.datatable.clique", [this.options.sortColumn, this.options.sortOrder]);
		},
		bindListeners: function() {
			this.on("showpage.datatable.clique", function(_this) {
				return function(e, pageIndex) {
					return _this.showPage(pageIndex);
				};
			}(this));
			this.on("didshowpage.datatable.clique", function(_this) {
				return function(e, currentPage, start, end, dataLength) {
					return _this.didShowPage(currentPage, start, end, dataLength);
				};
			}(this));
			this.on("next.datatable.clique", function(_this) {
				return function() {
					return _this.showNextPage();
				};
			}(this));
			this.on("previous.datatable.clique", function(_this) {
				return function() {
					return _this.showPreviousPage();
				};
			}(this));
			return this.on("sort.datatable.clique", function(_this) {
				return function(e, columnIndex, sortOrder) {
					return _this.sortByColumn(columnIndex, sortOrder);
				};
			}(this));
		},
		didShowPage: function(currentPage, start, end, dataLength) {
			if(this.elements.paginationWrapper && !this.elements.paginationWrapper.find("> *").length) {
				console.log(this.elements);
				return this.buildPagination();
			}
		},
		addObserver: function() {
			var tbody;
			tbody = this.elements.tbody;
			return _c.domObserve(tbody[0], function(_this) {
				return function() {
					return _this.observerCallback();
				};
			}(this));
		},
		removeObserver: function() {
			var observer, tbody;
			tbody = this.elements.tbody;
			observer = tbody.data("observer");
			return observer.disconnect();
		},
		observerCallback: function() {
			var tbody;
			this.observerIsTriggered = true;
			tbody = this.elements.tbody;
			this.hasRows = !!tbody.find("> tr").length;
			this.cacheData();
			if(this.options.sortColumn > -1) {
				setTimeout(function(_this) {
					return function() {
						return _this.trigger("sort.datatable.clique", [_this.options.sortColumn, _this.options.sortOrder]);
					};
				}(this), 0);
			}
			if(this.options.paginate && this.options.sortColumn < 0) {
				setTimeout(function(_this) {
					return function() {
						return _this.trigger("showpage.datatable.clique", [_this.currentPage]);
					};
				}(this), 0);
			}
			return setTimeout(function(_this) {
				return function() {
					_this.observerIsTriggered = false;
				};
			}(this), 0);
		},
		cacheData: function() {
			var $this, columns, data, isDate, isNumber, tbody;
			tbody = this.elements.tbody;
			if(!this.hasRows) {
				return;
			}
			data = [];
			columns = this.columns;
			isNumber = _c.utils.isNumber;
			isDate = _c.utils.isDate;
			tbody.find("> tr").each(function() {
				var rowData;
				rowData = [];
				$(this).find("> *").each(function(i) {
					var cell, html, text, value;
					text = $(this).text();
					html = $(this).html();
					if(isNumber(text)) {
						value = parseFloat(text);
					} else {
						if(isDate(text)) {
							value = new Date(text);
						} else {
							value = text;
						}
					}
					cell = {
						index: i,
						key: columns[i].title,
						value: value,
						text: text,
						html: html
					};
					return rowData.push(cell);
				});
				return data.push(rowData);
			});
			$this = this;
			return setTimeout(function() {
				return $this.setDataProperties(data);
			}, 0);
		},
		sortByColumn: function(columnIndex, sortOrder) {
			var cellData, columnData, compare, newData, sortedData, _i, _len;
			if(sortOrder == null) {
				sortOrder = "asc";
			}
			columnIndex = parseInt(columnIndex, 10);
			if(columnIndex < 0) {
				this.printOriginalData();
				return;
			}
			sortOrder = sortOrder.toLowerCase();
			if(sortOrder !== "asc" && sortOrder !== "desc") {
				sortOrder = "asc";
			}
			columnData = this.getDataForColumn(columnIndex);
			compare = function(a, b) {
				if(sortOrder === "asc") {
					if(a.value < b.value) {
						return -1;
					}
					if(a.value > b.value) {
						return 1;
					}
				} else {
					if(a.value > b.value) {
						return -1;
					}
					if(a.value < b.value) {
						return 1;
					}
				}
				return 0;
			};
			sortedData = columnData.sort(compare);
			newData = [];
			for(_i = 0, _len = sortedData.length; _i < _len; _i++) {
				cellData = sortedData[_i];
				newData.push(this.data[cellData.index]);
			}
			this.setDataProperties(newData);
			this.addSortClass(columnIndex, sortOrder);
			return this.trigger("showpage.datatable.clique", [this.currentPage]);
		},
		printOriginalData: function() {
			this.setDataProperties(this.originalData);
			this.removeSortClass();
			return this.trigger("showpage.datatable.clique", [this.currentPage]);
		},
		addSortClass: function(columnIndex, sortOrder) {
			this.removeSortClass();
			return this.elements.th.eq(columnIndex).find(".datatable-sort").addClass("datatable-sort-active datatable-sort-" + sortOrder);
		},
		removeSortClass: function() {
			return this.elements.th.find(".datatable-sort").removeClass("datatable-sort-active datatable-sort-asc datatable-sort-desc");
		},
		showNextPage: function() {
			var pageIndex;
			pageIndex = this.currentPage + 1;
			pageIndex = pageIndex > this.pages ? this.pages : pageIndex;
			return this.showPage(pageIndex);
		},
		showPreviousPage: function() {
			var pageIndex;
			pageIndex = this.currentPage - 1;
			pageIndex = pageIndex < 0 ? 0 : pageIndex;
			return this.showPage(pageIndex);
		},
		showPage: function(pageIndex) {
			var $this, data, end, rowData, start, table, _i, _len;
			if(!this.hasRows || !this.dataLength) {
				return;
			}
			this.removeObserver();
			this.removeAllRows();
			start = this.options.perPage * pageIndex;
			end = start + this.options.perPage;
			end = end > this.dataLength ? this.dataLength : end;
			data = this.getDataForRange(start, end);
			for(_i = 0, _len = data.length; _i < _len; _i++) {
				rowData = data[_i];
				this.addRow(rowData);
			}
			$this = this;
			table = this.element;
			return setTimeout(function() {
				$this.currentPage = pageIndex;
				$this.disablePrevious = start === 0 ? true : false;
				$this.disableNext = $this.currentPage === $this.pages ? true : false;
				$this.updatePagination();
				table.trigger("didshowpage.datatable.clique", [$this.currentPage, start === 0 ? 1 : start, end, $this.dataLength]);
				return $this.addObserver();
			}, 0);
		},
		addRow: function(rowData) {
			var cellData, content, td, tr, _i, _len;
			tr = $("<tr />");
			for(_i = 0, _len = rowData.length; _i < _len; _i++) {
				cellData = rowData[_i];
				content = cellData.text;
				td = $("<td>" + content + "</td>");
				tr.append(td);
			}
			return this.elements.tbody.append(tr);
		},
		removeAllRows: function() {
			var tbody;
			tbody = this.elements.tbody;
			return tbody.find("> *").remove();
		},
		getDataForRange: function(start, end) {
			var i, output;
			i = start;
			output = [];
			while(i < end) {
				output.push(this.data[i]);
				i++;
			}
			return output;
		},
		getDataForColumn: function(columnIndex) {
			var columnData, i, output, rowData, _ref;
			if(!this.data || !this.dataLength) {
				return [];
			}
			output = [];
			_ref = this.data;
			for(i in _ref) {
				rowData = _ref[i];
				columnData = rowData[columnIndex];
				output.push({
					index: parseInt(i, 10),
					value: columnData.value
				});
			}
			return output;
		},
		columnInfo: function(columnIndex) {
			if(!this.data || !this.dataLength) {
				return {};
			}
			return {
				title: this.data[0][columnIndex].key,
				index: columnIndex
			};
		},
		searchString: function(string, columnIndexes) {
			var cellData, column, columnIndex, i, output, rowData, rowString, _i, _j, _len, _len1, _ref;
			if(columnIndexes == null) {
				columnIndexes = [];
			}
			string = string.trim();
			if(!string || !string.length) {
				this.printOriginalData();
				return;
			}
			if(!columnIndexes.length) {
				_ref = this.columns;
				for(_i = 0, _len = _ref.length; _i < _len; _i++) {
					column = _ref[_i];
					if(this.options.hidden.indexOf(column.index) < 0) {
						columnIndexes.push(column.index);
					}
				}
			}
			output = [];
			i = 0;
			while(i < this.originalData.length) {
				rowData = this.originalData[i];
				rowString = "";
				for(_j = 0, _len1 = columnIndexes.length; _j < _len1; _j++) {
					columnIndex = columnIndexes[_j];
					cellData = rowData[columnIndex];
					rowString += " " + cellData.html;
				}
				rowString = rowString.trim();
				if(rowString.indexOf(string) > -1) {
					output.push(rowData);
				}
				i++;
			}
			this.setDataProperties(output);
			return this.showPage(0);
		},
		destroy: function() {
			this.restoreOriginalRows();
			this.removePagination();
			this.unbindEvents();
			this.removeStyle();
			this.removeData();
			return setTimeout(function(_this) {
				return function() {
					return _this.trigger("destroy.datatable.clique");
				};
			}(this), 0);
		},
		restoreOriginalRows: function() {
			var rowData, _i, _len, _ref, _results;
			this.removeAllRows();
			_ref = this.originalData;
			_results = [];
			for(_i = 0, _len = _ref.length; _i < _len; _i++) {
				rowData = _ref[_i];
				_results.push(this.addRow(rowData));
			}
			return _results;
		},
		removePagination: function() {
			return this.pagination.find("> *").remove();
		},
		unbindEvents: function() {
			this.find(".datatable-sort").off("click");
			this.previousButton.off("click");
			return this.nextButton.off("click");
		},
		removeStyle: function() {
			this.elements.th.removeAttr("style");
			return this.elements.tbody.find("td").removeAttr("style");
		},
		removeData: function() {
			return this.element.removeData("clique.data.datatable");
		}
	});
});
