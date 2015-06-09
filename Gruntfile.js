
/*global module:false*/
module.exports = function(grunt) {

	// ========================================================================
	// Grunt modules
	// ========================================================================

	require('load-grunt-tasks')(grunt);

	// Core & Component JS Files -
	//   Returns an ordered array of all `.js` files in
	//   the 'dist/js/core' directory
	// ========================================================================

	var coreJS = function() {
		return [
			'dist/js/core/core.js',
			'dist/js/core/events.js',
			'dist/js/core/browser.js',
		];
	};

	var componentJS = function() {
		var dir = 'dist/js';
		var subdirs = ['core', 'components'];
		var output = coreJS();
		var callback = function(abspath) {
			console.log(abspath);
			if(output.indexOf(abspath) < 0 && abspath.indexOf('.min.') < 0) {
				output.push(abspath);
			}
		};
		for(var i = 0; i < subdirs.length; i++) {
			var subdir = subdirs[i];
			grunt.file.recurse(dir, callback, subdir);
		}
		return output;
	};

	// Project configuration.
	grunt.initConfig({
		// Static variables
		pkg: grunt.file.readJSON('package.json'),
		banner: '/*!\n' +
		' *  <%= pkg.title || pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %>\n' +
		'<%= pkg.homepage ? " *  " + pkg.homepage + "\\n" : "" %>' +
		' *  Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;\n' +
		' */\n\n',

		// Compile
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
		coffee: {
			options: {
				join: false,
				bare: true
			},
		},
		watch: {
			coffee: {
				files: [ 'docs/build/coffee/**/*.coffee', 'Gruntfile.js' ],
				tasks: [ 'newer:coffee', 'concat' ]
			},
			js: {
				files: [ 'build/js/**/*.js', 'Gruntfile.js' ],
				tasks: [ 'newer:uglify:build', 'concat:docs' ]
			},
			less: {
				files: [ 'build/less/**/*.less', 'docs/build/less/**/*.less', 'Gruntfile.js' ],
				tasks: [ 'less' ]
			},
		},
		clean: {
			css: ['dist/css'],
			js: ['dist/js'],
			casper: ['unittests/casperjs/results'],
			results: ['unittests/**/results'],
			minify: ['dist/**/*.min.js', 'dist/**/*.min.css'],
		},

		// Build
		uglify: {
			build: {
				options: {
					preserveComments : false,
					mangle : false,
					compress : false,
					screwIE8 : true,
					beautify : {
						beautify : true,
						bracketize : true
					},
				},
				files: [{
					expand: true,
					cwd: 'build/js',
					src: '**/*.js',
					dest: 'dist/js'
				}]
			},
			dist: {
				options: {
					banner: '<%= banner %>',
					mangle : {},
					beautify : false,
					compress: {
						warnings: false
					},
					beautify: false,
					expression: false,
					maxLineLen: 32000,
					ASCIIOnly: false
				},
				files: [{
					expand: true,
					cwd: 'dist/js',
					src: ['**/*.js', '!**/*.min.js'],
					dest: 'dist/js',
					ext: '.min.js',
					extDot : 'last'
				}]
			}
		},
		concat: {
			options : {
				banner: '<%= banner %>',
				stripBanners : {
					block : true,
					line : true
				}
			},
			core: {
				src: coreJS(),
				dest: 'dist/js/clique.js',
			},
		},
		cssmin: {
			dist : {
				options: {
					restructuring : false
				},
				files: [{
					expand: true,
					cwd: 'dist/css',
					src: ['**/*.css', '!**/*.min.css'],
					dest: 'dist/css',
					ext: '.min.css'
				}]
			}
		},

		// Beautifying
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
			},
			html : {
				src: [
					"php/pages/tests/core/grid.php"
				],
			}
		},
		cleaner_css: {
			options : {
				min : {
					restructuring : false
				},
				comb : {
					config : '.csscomb.json'
				}
			},
			dist: {
				files: [{
					expand: true,
					cwd: 'dist/css',
					src: ['**/*.css'],
					dest: 'dist/css',
					ext: '.css',
					extDot : 'last'
				}]
			},
		},

		// Linting
		cliqueui_clean_less: {
			options : {
				searchIn : 'build/less',
				log : 'unittests/linting-reports/unused-less-vars.txt',
				logRepeating : 'unittests/linting-reports/repeating-less-vars.json',
				displayOutput : false
			},
			default : {
				files: [{
					expand: true,
					cwd: 'build/less',
					src: ['**/*.less', '!mixins/*.less'],
				}]
			}
		},
		csslint: {
			options: {
				csslintrc: '.csslintrc',
				quiet: true,
				formatters: [{
					id: 'text',
					dest: 'unittests/linting-reports/csslint.txt'
				}]
			},
			dist: {
				src: ['dist/**/*.css', '!dist/css/clique.css', '!dist/**/*.min.css']
			}
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

		// Test
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
		pagespeed: {
			options: {
				nokey: true,
				url: "https://developers.google.com"
			},
			prod: {
				options: {
					url: "https://developers.google.com/speed/docs/insights/v1/getting_started",
					locale: "en_GB",
					strategy: "desktop",
					threshold: 80
				}
			},
			paths: {
				options: {
					paths: ["/speed/docs/insights/v1/getting_started", "/speed/docs/about"],
					locale: "en_GB",
					strategy: "desktop",
					threshold: 80
				}
			}
		},
	});

	// Custom Tasks
	grunt.registerTask(
		'build-css',
		'Builds, cleans, and optmiizes the CSS from .less files',
		['clean:css', 'less', 'cleaner_css', 'cssmin:dist']
	);
	grunt.registerTask(
		'lint-css',
		'Lints all CSS & Less files, looking for possible improvements',
		['build-css', 'cliqueui_clean_less', 'csslint']
	);
	grunt.registerTask(
		'build-js',
		'Builds, cleans, and optmiizes the JS from .coffee files',
		['clean:js', 'uglify:build', 'concat', 'jsbeautifier:js', 'uglify:dist']
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

	grunt.registerTask( 'build', [ 'build-css', 'build-js' ] );
	grunt.registerTask( 'dev', [ 'less', 'coffee' ] );
	grunt.registerTask( 'default', [ 'watch' ] );

};
