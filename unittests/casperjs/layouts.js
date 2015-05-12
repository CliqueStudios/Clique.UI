
var viewports = require('./viewports.js');

var screenshotUrls = [
		'http://cliqueui.dev/get-started/layouts/frontpage/',
		'http://cliqueui.dev/get-started/layouts/portfolio/',
		'http://cliqueui.dev/get-started/layouts/blog/',
		'http://cliqueui.dev/get-started/layouts/post',
		'http://cliqueui.dev/get-started/layouts/documentation/',
		'http://cliqueui.dev/get-started/layouts/contact/',
		'http://cliqueui.dev/get-started/layouts/login/',
	],
	d = new Date(),
	screenshotDateTime = d.getYear() + '-' + d.getMonth() + '-' + d.getDate();

casper.start();
casper.each(screenshotUrls, function(casper, url) {
	casper.each(viewports, function(casper, viewport) {
		this.then(function() {
			this.viewport(viewport.viewport.width, viewport.viewport.height);
			this.userAgent(viewport.useragent);
		});
		this.thenOpen(url, function() {
			this.wait(1000);
		});
		this.then(function() {
			var info = this.getElementInfo('html');
			this.echo('Screenshot for ' + viewport.name + '; UA: ' + info.attributes.class);
			this.capture('unittests/casperjs/results/layouts/' + this.getTitle() + '/' + viewport.name + '-' + viewport.viewport.width + 'x' + viewport.viewport.height + '.png');
		});
	});
});
casper.run();
