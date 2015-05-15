#Clique.UI - v. 1.0.1

Recently we launched [Clique.UI](http://ui.cliquestudios.com), a lightweight, modular front-end framework for rapid web-interface development. This is the first product that we've publicly released with full-documentation, and couldn't be more excited about it.

After a lot of work and even more testing, we're calling this release version 1.1.0 - and there will be many more to come. What's even more exciting about Clique.UI is that we've decided to open it up to the public, and make it a completely open-source under the [MIT license](http://opensource.org/licenses/MIT) and [hosted on GitHub](https://github.com/CliqueStudios/Clique.UI). We'll be monitoring this repository closely, so if you find any bugs or want to see a new feature, log it in the [repo's issue tracker](https://github.com/CliqueStudios/Clique.UI/issues).

##What's included

Clique.UI comes with **[53 unique components](http://ui.cliquestudios.com/core/)**, ranging from [base styles to normalize the interface](http://ui.cliquestudios.com/core/base); layout modules that include [two grid design-patterns](http://ui.cliquestudios.com/core/grid) and [flex technology](http://ui.cliquestudios.com/core/flexbox); advanced form elements including [customizable select dropdowns](http://ui.cliquestudios.com/core/selects), [radio buttons, and checkboxes](http://ui.cliquestudios.com/core/checkboxes); a library of CSS-based [transitions and animations](http://ui.cliquestudios.com/core/animation); and many, many JavaScript-based widgets like [modal windows](http://ui.cliquestudios.com/core/modal), [dropdowns](http://ui.cliquestudios.com/core/dropdown), [tab navigations](http://ui.cliquestudios.com/core/tab), and [toggle buttons](http://ui.cliquestudios.com/core/toggle). You can check out the full list of core components [here](http://ui.cliquestudios.com/core/).

Of those 53 components is **[17 advanced modules](http://ui.cliquestudios.com/components/)** that are also completely modular. These include [slideshows](http://ui.cliquestudios.com/components/slideshow), [drag-and-drop file uploading](http://ui.cliquestudios.com/components/upload), input [autocomplete](http://ui.cliquestudios.com/components/autocomplete) rendering, [data tables](http://ui.cliquestudios.com/components/datatable), and much, much more. If you'd like to see all advanced components, check out the "[Components](http://ui.cliquestudios.com/components/)" section of the documentation.

To get started with these components or learn how to incorporate them into your website, visit the main [Clique.UI documentation](http://ui.cliquestudios.com/).

##Why create a new framework?

With dozens of existing front-end frameworks, it might be hard to find a reason to spend the time and energy creating a new one from the ground-up. [Clique.UI](http://ui.cliquestudios.com/get-started/about-cliqueui/#what-is-cliqueui) is our solution to the challenges we've faced during the front-end development process, and our attempt to bridge the gap between the needs of large, open-source frameworks like Bootstrap and the needs of our clients.

Our primary goals for creating such a product are:

*	**Modularity**. We needed to be able to have interchange components that don't rely on each other, and very little on a base set of style rules or JavaScript.
*	**Speed**. Page load time and performance are extremely important to us at Clique, as each site has to meet unwavering performance benchmarks.
*	**Responsiveness**. The web is trending toward mobile, with more and more users viewing sites on their mobile and touch-enabled devices. Our sites must react the same to user interaction no matter the device or screen size.
*	**Cross-Browser Compatibility**. Every site that we create must look just as good on the latest version of Chrome as it does in earlier version of Internet Explorer without exception.
*	**Integratability**. Our front-end framework has to work just as easily in a static HTML build as it would in a WordPress or Magento site, or any other CMS or web-framework that our clients require.
*	**Updatability & Source Control**. We need to be able to fully understand and control the code that goes into our websites. A heavy reliance on third-party plugins and frameworks can cause problems if we don't know how or why they were written the way they were.
*	**Full Documentation**. Our code needed to be fully documented with examples, samples, and an understanding of why a component is written the way it is. We also needed to have our documentation available for those clients of ours who have their own development teams that will be performing future updates.

##Compatilibty

Clique.UI is [fully compatible](http://ui.cliquestudios.com/get-started/about-cliqueui/#browser-support) on the following devices and browsers:

* **Desktop** Mac/PC:
	* **Google Chrome** v. 21+
	* **Firefox** v. 20+
	* **Internet Explorer** v. 9+
	* **Safari** v. 3.1+
	* **Opera** v. 12.12+
* **Mobile**
	* **iOS** v. 7+
	* **Android** v. 4.4+
	* **Windows Phone** v. 8.1+

##How Clique.UI Was Created

From the offset of developing Clique.UI we kept the above requirements in mind while taking into account our own development experience and past approaches. We looked at the way other frameworks were built, the tools they used, and the requirements they had as well. We knew that our components, largely a conglomeration of existing third-party plugins wrapped under a single namespace, and would still require the [jQuery JavaScript library](https://jquery.com/). For extendibility and consistency, we decided to write the CSS using [Less](http://lesscss.org/), a pre-compiler for style, and the JavaScript in [CoffeeScript](http://coffeescript.org/), a pre-compiler for JS.

The site was compiled using [Grunt](http://gruntjs.com/), a [Node.js](https://nodejs.org/) based task runner that allows for command-line tasks to executed with ease and simplicity. [Using Grunt](https://github.com/CliqueStudios/Clique.UI/blob/master/Gruntfile.js), we're able to compile the Less and CoffeeScript, lint the source code for any erroneous content (keeping the source as small as possible), clean and minify the code, and run all functional and unit tests.

##Testing

Creating a front-end framework is a huge undertaking, and, as with any product we create at Clique, [testing is of the highest importance to us](http://ui.cliquestudios.com/get-started/tests/). With 53 separate and modular components, recursive testing for eight different platforms can prove a daunting task.

To combat this we created a basic [kitchen sink page](http://ui.cliquestudios.com/tests/overview), [test pages](http://ui.cliquestudios.com/tests/) for each individual component, [layout samples](http://ui.cliquestudios.com/get-started/layouts/), and perform recursive functional testing using [CasperJS](http://casperjs.org/). By centralizing the components we were able to see them in action all at once in action and either run CasperJS to take screenshots of the test page in each browser/platform/device/resolution we've predefined, or view the page online or using [BrowserStack](https://www.browserstack.com/start) and manually confirm or deny that the component is appearing and behaving as expected.

These test and layout pages are public, and we invite you to check them out. If you see any issues, or if something isn't behaving quite right, we'd ask that you [log an issue in GitHub](https://github.com/CliqueStudios/Clique.UI/issues), and we'll get it taken care of as soon as possible.

##Contributing

Because Clique.UI is open-source, we invite any developer interested in contributing to do so. In order to contribute, perform the following steps:

1. If necessary, [install Node.js](https://nodejs.org/) following the steps on their website.
2. Clone the Clique.UI repo: `git clone https://github.com/CliqueStudios/Clique.UI.git`
3. Install the required Node packages: `sudo npm install`
4. Make the changes you'd like in the `.less` or `.coffee` files
5. Compile and build the source files: `grunt build`

##Moving Forward

Clique.UI isn't a one-off project or something that will sit on the back burner. Our client's needs are our highest priority, but maintaining a usable, extensible front-end framework helps us meet those needs.
