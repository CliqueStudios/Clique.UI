
var helpers = require('./lib/helpers');

var currentVersion = '1.0.3';

describe('Clique.core', function(){
	var _c = window.Clique;

	describe('#properties', function() {
		it('Version property exists', function() {
			_c.should.have.property('version');
		});
		it('Version is correct (' + currentVersion + ')', function() {
			_c.version.should.equal(currentVersion);
		});
	});

	describe('#support', function() {

		// requestAnimationFrame
		describe('#requestAnimationFrame', function() {
			it('core.support.requestAnimationFrame is type `function`', function() {
				var type = typeof _c.support.requestAnimationFrame;
				(type === 'function').should.be.true;
			});
		});

		// touch
		describe('#touch', function() {
			it('core.support.touch is type `boolean`', function() {
				var type = typeof _c.support.touch;
				(type === 'boolean').should.be.true;
			});
		});

		// mutationobserver
		describe('#mutationobserver', function() {
			it('core.support.mutationobserver is type `function`', function() {
				var type = typeof _c.support.mutationobserver;
				(type === 'function').should.be.true;
			});
		});
	});

	describe('#utils', function() {

		// now
		describe('#now', function() {
			it('core.utils.now is type `function`', function() {
				var type = typeof _c.utils.now;
				(type === 'function').should.be.true;
			});
			it('core.utils.now is returning correct time', function() {
				_c.utils.now().should.equal(new Date().getTime());
			});
		});

		// isString
		describe('#isString', function() {
			it('core.utils.isString is type `function`', function() {
				var type = typeof _c.utils.isString;
				(type === 'function').should.be.true;
			});
			it('core.utils.isString should pass', function() {
				_c.utils.isString('String').should.be.true;
			});
			it('core.utils.isString should fail', function() {
				_c.utils.isString(1234).should.not.be.true;
			});
		});

		// isNumber
		describe('#isNumber', function() {
			it('core.utils.isNumber is type `function`', function() {
				var type = typeof _c.utils.isNumber;
				(type === 'function').should.be.true;
			});
			it('core.utils.isNumber should pass w/ integer', function() {
				_c.utils.isNumber(1234).should.be.true;
			});
			it('core.utils.isNumber should pass w/ string', function() {
				_c.utils.isNumber('1234').should.be.true;
			});
			it('core.utils.isNumber should fail', function() {
				_c.utils.isNumber('String').should.not.be.true;
			});
		});

		// isDate
		describe('#isDate', function() {
			it('core.utils.isDate is type `function`', function() {
				var type = typeof _c.utils.isDate;
				(type === 'function').should.be.true;
			});
			it('core.utils.isDate should pass', function() {
				_c.utils.isDate('May 14, 2015').should.be.true;
			});
			it('core.utils.isDate should fail', function() {
				_c.utils.isDate('String').should.not.be.true;
			});
		});

		// str2json
		describe('#str2json', function() {
			it('core.utils.str2json is type `function`', function() {
				var type = typeof _c.utils.str2json;
				(type === 'function').should.be.true;
			});
			it('core.utils.str2json should return json (notevil)', function() {
				var str = "{key:'value'}";
				_c.utils.str2json(str).should.be.json;
			});
			it('core.utils.str2json should return json (evil)', function() {
				var str = "{key:'value'}";
				_c.utils.str2json(str, true).should.be.json;
			});
		});

		// debounce
		describe('#debounce', function() {
			it('core.utils.debounce is type `function`', function() {
				var type = typeof _c.utils.debounce;
				(type === 'function').should.be.true;
			});
		});

		// removeCssRules
		describe('#removeCssRules', function() {
			it('core.utils.removeCssRules is type `function`', function() {
				var type = typeof _c.utils.removeCssRules;
				(type === 'function').should.be.true;
			});
		});

		// isInView
		describe('#isInView', function() {
			it('core.utils.isInView is type `function`', function() {
				var type = typeof _c.utils.isInView;
				(type === 'function').should.be.true;
			});
		});

		// checkDisplay
		describe('#checkDisplay', function() {
			it('core.utils.checkDisplay is type `function`', function() {
				var type = typeof _c.utils.checkDisplay;
				(type === 'function').should.be.true;
			});
		});

		// options
		describe('#options', function() {
			it('core.utils.options is type `function`', function() {
				var type = typeof _c.utils.options;
				(type === 'function').should.be.true;
			});
		});

		// animate
		describe('#animate', function() {
			it('core.utils.animate is type `function`', function() {
				var type = typeof _c.utils.animate;
				(type === 'function').should.be.true;
			});
		});

		// uid
		describe('#uid', function() {
			it('core.utils.uid is type `function`', function() {
				var type = typeof _c.utils.uid;
				(type === 'function').should.be.true;
			});
			it('core.utils.uid returns string', function() {
				var type = typeof _c.utils.uid();
				(type === 'string').should.be.true;
			});
			it('core.utils.uid accepts prefix', function() {
				var prefix = 'clique_';
				var uid = _c.utils.uid(prefix);
				uid.should.startWith(prefix);
			});
		});

		// template
		describe('#template', function() {
			it('core.utils.template is type `function`', function() {
				var type = typeof _c.utils.template;
				(type === 'function').should.be.true;
			});
		});

		// events
		describe('#events', function() {
			it('core.utils.events is type `object`', function() {
				var type = typeof _c.utils.events;
				(type === 'object').should.be.true;
			});
			it('core.utils.events.click is either "click" or "tap"', function() {
				var evt = _c.utils.events.click;
				(evt === 'click' || evt === 'tap').should.be.true;
			});
		});
	});

	describe('#methods', function() {

		// component
		describe('#component', function() {
			it('core.now is type `function`', function() {
				var type = typeof _c.component;
				(type === 'function').should.be.true;
			});
			// check for parameters
		});

		// plugin
		describe('#plugin', function() {
			it('core.plugin is type `function`', function() {
				var type = typeof _c.plugin;
				(type === 'function').should.be.true;
			});
			// check for parameters
		});

		// ready
		describe('#ready', function() {
			it('core.ready is type `function`', function() {
				var type = typeof _c.ready;
				console.log(helpers.getParamNames(_c.ready));
				(type === 'function').should.be.true;
			});
			// check for parameters
		});

		// on
		describe('#on', function() {
			it('core.on is type `function`', function() {
				var type = typeof _c.on;
				(type === 'function').should.be.true;
			});
			// check for parameters
		});

		// one
		describe('#one', function() {
			it('core.one is type `function`', function() {
				var type = typeof _c.one;
				(type === 'function').should.be.true;
			});
			// check for parameters
		});

		// trigger
		describe('#trigger', function() {
			it('core.trigger is type `function`', function() {
				var type = typeof _c.trigger;
				(type === 'function').should.be.true;
			});
			// check for parameters
		});

		// domObserve
		describe('#domObserve', function() {
			it('core.domObserve is type `function`', function() {
				var type = typeof _c.domObserve;
				(type === 'function').should.be.true;
			});
			// check for parameters
		});

		// delay
		describe('#delay', function() {
			it('core.delay is type `function`', function() {
				var type = typeof _c.delay;
				(type === 'function').should.be.true;
			});
			// check for parameters
		});
	});
});
