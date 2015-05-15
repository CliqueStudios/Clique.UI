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
			main : {
				files : {
					"dist/css/clique.css" : ["build/less/clique.less"],
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
				files: [ 'build/coffee/**/*.coffee', 'Gruntfile.js' ],
				tasks: [ 'newer:coffee', 'concat' ]
			},
			less: {
				files: [ 'build/less/**/*.less', 'Gruntfile.js' ],
				tasks: [ 'less' ]
			},
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
				],
			},
			css : {
				src: [
					"dist/css/**/*.css",
				],
			},
			js : {
				src: [
					"dist/js/**/*.js",
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
		},
		csscomb: {
			options: {
				config: '.csscomb.json'
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
			options : {
				async: {
					parallel: true
				}
			},
			all : {
				src : ['unittests/casperjs/*.js']
			},
			tests : {
				src: ['unittests/casperjs/tests.js'],
			},
			layouts : {
				src: ['unittests/casperjs/layouts.js'],
			}
		},
		clean: {
			css: ['dist/css'],
			casper: ['unittests/casperjs/results'],
			results: ['unittests/**/results'],
		},
		cleaner_css: {
			dist: {
				files : {
					'dist/css/clique.css': ['dist/css/clique.css'],
					'dist/css/clique.css': ['dist/css/clique.css'],
				}
			},
		},
		changelog: {
			options : {
				dest : 'CHANGELOG.md'
			}
		},
		mocha: {
			options : {
				run : true
			},
			test: {
				src: ['unittests/mocha/*.html'],
			},
		},
		browserify: {
			tests: {
				files: {
					'unittests/mocha/suites/core.js': ['unittests/mocha/suites/core.js'],
				}
			}
		}
	});

	// Development Tasks
	grunt.loadNpmTasks('grunt-newer');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-less');
	grunt.loadNpmTasks('grunt-contrib-coffee');

	// Build Tasks
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-newer');
	grunt.loadNpmTasks("grunt-jsbeautifier");

	// Linting Tasks
	grunt.loadNpmTasks('grunt-csscomb');
	grunt.loadNpmTasks('grunt-cleaner-css');
	grunt.loadNpmTasks('grunt-contrib-jshint');

	// Testing Tasks
	grunt.loadNpmTasks('grunt-casperjs');
	grunt.loadNpmTasks('grunt-mocha');
	grunt.loadNpmTasks('grunt-browserify');

	// Production Build Tasks
	grunt.loadNpmTasks('grunt-contrib-concat');
	grunt.loadNpmTasks('grunt-contrib-cssmin');
	grunt.loadNpmTasks('grunt-contrib-uglify');
	grunt.loadNpmTasks('grunt-conventional-changelog');

	// Custom Tasks
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
		'casper',
		'Runs casper.js tests',
		['clean:casper', 'casperjs:all']
	);
	grunt.registerTask(
		'autotest',
		'Runs all automated tests',
		['clean:results', 'jshint', 'casper']
	);
	grunt.registerTask(
		'release',
		'Runs both the `build-css` and `build-js` commands',
		['build']
	);

	grunt.registerTask( 'build', [ 'build-css', 'build-js' ] );
	grunt.registerTask( 'dev', [ 'less', 'coffee' ] );
	grunt.registerTask( 'default', [ 'watch' ] );

};
