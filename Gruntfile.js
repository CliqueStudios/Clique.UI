
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
					"dist/css/clique.css" : ["src/less/clique.less"],
				}
			},
			dist : {
				files: [{
					expand: true,
					cwd: 'src/less',
					src: ['**/*.less', '!_**/*.less', '!mixins/*.less', '!variables/*.less'],
					dest: 'dist/css',
					ext: '.css',
					extDot : 'last'
				}]
			},
		},
		watch: {
			js: {
				files: [ 'src/js/**/*.js', 'Gruntfile.js' ],
				tasks: [ 'newer:uglify:build' ]
			},
			less: {
				files: [ 'src/less/**/*.less', 'docs/build/less/**/*.less', 'Gruntfile.js' ],
				tasks: [ 'less' ]
			},
		},
		// newer: {
		// 	options: {
		// 		override: function(details, include) {
		// 			if (details.task === 'less') {
		// 				checkForNewerImports(details.path, details.time, include);
		// 			} else {
		// 				include(false);
		// 			}
		// 		}
		// 	}
		// },
		clean: {
			css: ['dist/css'],
			js: ['dist/js'],
			casper: ['test/casperjs/results'],
			results: ['test/**/results'],
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
					cwd: 'src/js',
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
		copy: {
			fonts: {
				files: [{
					expand: true,
					src: ['src/fonts/*'],
					dest: 'dist/fonts/',
				}],
			},
		},

		// Find/Replace Within Files
		autoprefixer: {
			options: {
				browsers: [ '> 1%', 'last 5 versions', 'ie 9' ]
			},
			dist: {
				files: [{
					expand: true,
					cwd: 'dist',
					src: ['**/*.css', '!**/*.min.css'],
					dest: 'dist',
					ext: '.css'
				}]
			},
		},

		// Beautifying
		jsbeautifier : {
			options : {
				js : {
					indentChar: "\t",
					indentLevel : 0,
					indentSize: 1,
					indentWithTabs : true,
					maxPreserveNewlines : 2,
					spaceAfterAnonFunction : false,
					spaceBeforeConditional : false,
				},
				css: {
					fileTypes: [".less"],
					indentChar: "\t",
					indentSize: 1
				},
			},
			js : {
				files: [{
					expand: true,
					cwd: 'dist',
					src: ['**/*.js', '!**/*.min.js'],
					dest: 'dist',
					ext : '.js',
				}]
			},
			css : {
				files: [{
					expand: true,
					cwd: 'dist',
					src: ['**/*.css', '!**/*.min.css'],
					dest: 'dist',
					ext : '.css',
				}]
			},
		},
		csscomb: {
			options: {
				config: '.csscomb.json'
			},
			css: {
				files: [{
					expand: true,
					cwd: 'dist',
					src: ['**/*.css', '!**/*.min.css'],
					dest: 'dist',
					ext : '.css',
				}]
			},
		},

		// Linting
		cliqueui_clean_less: {
			options : {
				searchIn : 'src/less',
				log : 'test/linting-reports/unused-less-vars.txt',
				logRepeating : 'test/reports/less.json',
				displayOutput : false
			},
			default : {
				files: [{
					expand: true,
					cwd: 'src/less',
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
					dest: 'test/reports/csslint.txt'
				}]
			},
			dist: {
				src: ['dist/**/*.css', '!dist/css/clique.css', '!dist/**/*.min.css']
			}
		},
		jshint: {
			options : {
				jshintrc : '.jshintrc',
				reporter: require('jshint-html-reporter'),
				reporterOutput: 'test/results/jshint.html',
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
				src : ['test/casperjs/*.js']
			},
			tests : {
				src: ['test/casperjs/tests.js'],
			},
			layouts : {
				src: ['test/casperjs/layouts.js'],
			}
		},
	});

	// functions
	function checkForNewerImports(lessFile, mTime, include) {
		var fs = require('fs'),
			path = require('path');

		fs.readFile(lessFile, 'utf8', function(err, data) {
			var lessDir = path.dirname(lessFile),
				regex = /@import "(.+?)(\.less)?";/g,
				shouldInclude = false,
				match;

			while ((match = regex.exec(data)) !== null) {
				var importFile = lessDir + '/' + match[1] + '.less';
				if (fs.existsSync(importFile)) {
					var stat = fs.statSync(importFile);
					if (stat.mtime > mTime) {
						shouldInclude = true;
						break;
					}
				}
			}

			include(shouldInclude);
		});
	}

	// Custom Tasks
	grunt.registerTask(
		'build-css',
		'Builds, cleans, and optmiizes the CSS from .less files',
		['clean:css', 'less', 'autoprefixer', 'jsbeautifier:css', 'csscomb', 'cssmin']
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
