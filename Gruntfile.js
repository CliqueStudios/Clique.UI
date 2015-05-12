/*global module:false*/
module.exports = function(grunt) {

	// Project configuration.
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
		'<%= grunt.template.today("yyyy-mm-dd") %>\n' +
		'<%= pkg.homepage ? " *  " + pkg.homepage + "\\n" : "" %>' +
		' *  Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;\n' +
		' */\n\n',
		less: {
			options: {
				sourceMap: true,
				sourceMapFileInline: true
			},
			docs: {
				files: {
					"docs/css/docs.css" : ["docs/build/less/docs.less"]
				}
			},
			concat : {
				files : {
					"dist/css/clique.css" : ["build/less/clique.less"],
					"dist/css/clique.full.css" : ["build/less/clique.full.less"],
				}
			},
			core : {
				files: [{
					expand: true,
					cwd: 'build/less/core',
					src: ['*.less', '!_*.less'],
					dest: 'dist/css/core',
					ext: '.css',
					extDot : 'last'
				}]
			},
			components : {
				files: [{
					expand: true,
					cwd: 'build/less/components',
					src: ['*.less', '!_*.less'],
					dest: 'dist/css/components',
					ext: '.css',
					extDot : 'last'
				}]
			},
		},
		watch: {
			coffee: {
				files: [ 'build/coffee/**/*.coffee', 'docs/build/coffee/**/*.coffee', 'Gruntfile.js' ],
				tasks: [ 'build-js' ]
			},
			less: {
				files: [ 'build/less/**/*.less', 'docs/build/less/*.less', 'Gruntfile.js' ],
				tasks: [ 'build-css' ]
			}
		},
		concat : {
			options : {
				stripBanners : {
					block : true,
					line : true
				}
			},
			core : {
				src: [
					'dist/js/core/core.js',
					'dist/js/core/touch.js',
					'dist/js/core/events.js',
					'dist/js/core/browser.js',
					'dist/js/core/utility.js',
					'dist/js/core/smooth-scroll.js',
					'dist/js/core/scrollspy.js',
					'dist/js/core/toggle.js',
					'dist/js/core/alert.js',
					'dist/js/core/button.js',
					'dist/js/core/dropdown.js',
					'dist/js/core/form.js',
					'dist/js/core/grid.js',
					'dist/js/core/modal.js',
					'dist/js/core/nav.js',
					'dist/js/core/switcher.js',
					'dist/js/core/select.js',
					'dist/js/core/tab.js',
					'dist/js/core/cover.js',
					'dist/js/core/password.js',
				],
				dest: 'dist/js/clique.js',
			},
			components : {
				src: [
					'dist/js/clique.js',
					'dist/js/components/accordion.js',
					'dist/js/components/autocomplete.js',
					'dist/js/components/datatable.js',
					'dist/js/components/datepicker.js',
					'dist/js/components/form-select.js',
					'dist/js/components/grid.js',
					'dist/js/components/htmleditor.js',
					'dist/js/components/lightbox.js',
					'dist/js/components/nestable.js',
					'dist/js/components/offcanvas.js',
					'dist/js/components/parallax.js',
					'dist/js/components/pagination.js',
					'dist/js/components/slideshow.js',
					'dist/js/components/sortable.js',
					'dist/js/components/sticky.js',
					'dist/js/components/timepicker.js',
					'dist/js/components/upload.js',
					'dist/js/components/switch.js'
				],
				dest: 'docs/js/clique.full.js',
			},
		},
		cssmin : {
			combine: {
				options : {
					compatibility : '*',
					keepBreaks : true,
					keepSpecialComments : 0,
					restructuring : false
				},
				files : {
					'dist/css/clique.css': ['dist/css/clique.css'],
					'dist/css/clique.full.css': ['dist/css/clique.full.css'],
					'docs/css/docs.css': ['docs/css/docs.css']
				}
			}
		},
		uglify: {
			options : {
				preserveComments : false,
				mangle : false,
				compress : false,
				screwIE8 : true,
				beautify : {
					beautify : true,
					bracketize : true
				}
			},
			dist : {
				files: [{
					expand: true,
					cwd: 'docs/js',
					src: '**/*.js',
					dest: 'docs/js'
				}]
			},
			new: {
				files: [{
					expand: true,
					cwd: 'dist/js',
					src: '**/*.js',
					dest: 'dist/js'
				}]
			}
		},
		jsbeautifier: {
			options: {
				html: {
					fileTypes: [".php"],
					braceStyle: "collapse",
					indentChar: "\t",
					indentSize: 1,
					maxPreserveNewlines: 10,
					preserveNewlines: true,
					unformatted: ["a", "sub", "sup", "b", "u", "pre", "code"],
					wrapLineLength: 0
				},
				css: {
					fileTypes: [".less"],
					indentChar: "\t",
					indentSize: 1
				},
				js: {
					braceStyle: "collapse",
					breakChainedMethods: false,
					e4x: false,
					evalCode: false,
					indentLevel: 0,
					indentWithTabs: true,
					jslintHappy: false,
					keepArrayIndentation: false,
					keepFunctionIndentation: false,
					spaceAfterAnonFunction: false,
					maxPreserveNewlines: 10,
					preserveNewlines: true,
					spaceBeforeConditional: false,
					spaceInParen: false,
					unescapeStrings: false,
					wrapLineLength: 0,
					endWithNewline: true
				}
			},
			all : {
				src: [
					"dist/js/**/*.js",
					"dist/css/**/*.css",
					"docs/js/**/*.js",
					"docs/css/**/*.css"
				],
			},
			css : {
				src: [
					"dist/css/**/*.css",
					"docs/css/**/*.css"
				],
			},
			js : {
				src: [
					"dist/js/**/*.js",
					"docs/js/**/*.js"
				],
			}
		},
		coffee: {
			options: {
				join: false,
				bare: true
			},
			core: {
				files: [{
					expand: true,
					cwd: 'build/coffee/core',
					src: ['*.coffee', '!_*.coffee'],
					dest: 'dist/js/core',
					ext: '.js',
					extDot : 'last'
				}]
			},
			components: {
				files: [{
					expand: true,
					cwd: 'build/coffee/components',
					src: ['*.coffee', '!_*.coffee'],
					dest: 'dist/js/components',
					ext: '.js',
					extDot : 'last'
				}]
			},
			docs: {
				files: [{
					expand: true,
					cwd: 'docs/build/coffee',
					src: ['*.coffee', '!_*.coffee'],
					dest: 'docs/js',
					ext: '.js',
					extDot : 'last'
				}]
			},
		},
		csscomb: {
			options: {
				config: '.csscomb.json'
			},
			docs: {
				files: {
					'docs/css/docs.css': ['docs/css/docs.css'],
				}
			},
			dist: {
				expand: true,
				cwd: 'dist/css',
				src: ['**/*.css'],
				dest: 'dist/css',
				ext: '.css'
			},
		},
		jshint: {
			options : {
				jshintrc : 'unittests/jshint/.jshintrc',
				reporter: require('jshint-html-reporter'),
				reporterOutput: 'unittests/jshint/results/jshint-report.html',
				force: true
			},
			all : ['dist/js/**/*.js', '!dist/js/clique.js']
		},
		casperjs: {
			options: {
				async: {
					parallel: false
				}
			},
			files: ['unittests/casperjs/*.js', '!unittests/casperjs/viewports.js']
		},
		clean: {
			css: ['dist/css'],
			results: ['unittests/**/results'],
		},
		cleaner_css: {
			dist: {
				files : {
					'dist/css/clique.css': ['dist/css/clique.css'],
					'dist/css/clique.full.css': ['dist/css/clique.full.css'],
				}
			},
		},
		changelog: {
			options : {
				dest : 'CHANGELOG.md'
			}
		}
	});

	// Development Tasks
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-less');
	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-csscomb');
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-cleaner-css');

	// Build Tasks
	grunt.loadNpmTasks('grunt-shell');

	// Linting Tasks
	grunt.loadNpmTasks("grunt-jsbeautifier");

	// Testing Tasks
	grunt.loadNpmTasks('grunt-casperjs');
	grunt.loadNpmTasks('grunt-contrib-jshint');

	// Production Build Tasks
	grunt.loadNpmTasks('grunt-contrib-concat');
	grunt.loadNpmTasks('grunt-contrib-cssmin');
	grunt.loadNpmTasks('grunt-contrib-uglify');
	grunt.loadNpmTasks('grunt-conventional-changelog');

	// Default task.

	grunt.registerTask(
		'build-css',
		'Builds, cleans, and optmiizes the CSS from .less files',
		['clean:css', 'less', 'cleaner_css', 'cssmin', 'csscomb', 'jsbeautifier:css']
	);
	grunt.registerTask(
		'build-js',
		'Builds, cleans, and optmiizes the JS from .coffee files',
		['coffee', 'concat', 'uglify', 'jsbeautifier:js']
	);
	grunt.registerTask(
		'autotest',
		'Runs all automated tests',
		['clean:results', 'jshint', 'casperjs']
	);

	grunt.registerTask( 'build', [ 'build-css', 'build-js' ] );
	grunt.registerTask( 'dev', [ 'less', 'coffee' ] );
	grunt.registerTask( 'default', [ 'watch' ] );

};
