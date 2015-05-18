
describe('Clique.alert', function(){
	var _c = window.Clique;

	describe('#loaded', function() {
		it('Alert is saved as a component', function() {
			_c.components.should.have.property('alert');
		});
	});

	describe('#instatiation', function() {
		it('Alert is booted', function() {
			_c.components.alert.booted.should.be.true;
		});
	});

	describe('#methods', function() {
		it('Should have method `boot`', function() {
			var obj = _c.components.alert;
			obj.prototype.boot.should.be.a.Function;
		});
		it('Should have method `init`', function() {
			var obj = _c.components.alert;
			obj.prototype.init.should.be.a.Function;
		});
		it('Should have method `close`', function() {
			var obj = _c.components.alert;
			obj.prototype.close.should.be.a.Function;
		});
	});

});
