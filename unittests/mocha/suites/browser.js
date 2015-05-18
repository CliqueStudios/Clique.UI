
describe('Clique.browser', function(){
	var _c = window.Clique;

	describe('#loaded', function() {
		it('Browser is saved as a component', function() {
			_c.components.should.have.property('browser');
		});
	});

	describe('#instatiation', function() {
		it('Browser is booted', function() {
			console.log(_c.components);
			_c.components.browser.booted.should.be.true;
		});
	});

	describe('#methods', function() {
		it('Should have method `boot`', function() {
			var obj = _c.components.browser;
			obj.prototype.boot.should.be.a.Function;
		});
		it('Should have method `init`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `getProperties`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `test`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `exec`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `uamatches`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `version`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `detectDevice`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `detectScreen`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `detectTouch`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `detectOS`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `detectBrowser`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `detectLanguage`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `detectPlugins`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `detectSupport`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `addClasses`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `removeClasses`', function() {
			var obj = _c.components.browser;
			obj.prototype.init.should.be.a.Function;
		});
	});

});
