
var viewports = require('./lib/viewports.js').tests;

var links = [],
	utils = require('utils');

function getLinks() {
	var links = document.querySelectorAll('a');
	return Array.prototype.map.call(links, function(e) {
		return e.getAttribute('href');
	});
}

casper.start('http://cliqueui.dev/tests/', function() {
	links = this.evaluate(getLinks);
});

casper.then(function() {
	this.echo(links.length + ' links found');
	casper.each(links, function(casper, url) {
		casper.each(viewports, function(casper, viewport) {
			this.then(function() {
				this.viewport(viewport.viewport.width, viewport.viewport.height);
				this.userAgent(viewport.useragent);
			});
			this.thenOpen(url, function() {
				this.wait(1000);
			});
			this.then(function() {
				// var info = this.getElementInfo('html');
				this.echo('Screenshot for `' + this.getTitle() + '`');
				this.capture('unittests/casperjs/results/tests/' + this.getTitle() + '/' + viewport.name + '-' + viewport.viewport.width + 'x' + viewport.viewport.height + '.png');
			});
		});
	});
});
casper.run();
