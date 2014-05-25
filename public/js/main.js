require.config({
	paths: {
		jquery: '/libs/jquery/dist/jquery.min',
		bootstrap: '/libs/bootstrap/dist/js/bootstrap.min',
		hbs: '/libs/require-handlebars-plugin/hbs',
		moment: '/libs/momentjs/moment',
		zeroclipboard: '/libs/zeroclipboard/ZeroClipboard.min'
	},
	shim: {
		bootstrap: {
			deps: ['jquery']
		}
	}
});
require(['jquery', 'zeroclipboard', 'base', 'bootstrap', 'auth', 'logmodel'], function($, zeroclipboard, base) {
	zeroclipboard.config({
		moviePath: '/libs/zeroclipboard/ZeroClipboard.swf'
	});



	if (location.hash) {
		$('.bs-sidenav li').removeClass('active');
		$('.bs-sidenav li a[href="' + location.hash + '"]').parent('li').addClass('active');

		var module = location.hash.slice(1)
		getContent(module)
	}

	$('.bs-sidenav>li>a, .bs-sidenav>li>ul>li>a').on('click', function() {

		var self = $(this),
			module = self.attr('href').slice(1);
		$('.bs-sidenav li').removeClass('active');
		self.parent('li').addClass('active');
		getContent(module)
	})


	function getContent(module) {
		$.get('/back/' + module, function(content_html) {
			$('.content').empty();
			$('.content').append(content_html);
			var client = new zeroclipboard($('.copy'));
			client.on("load", function(client) {
				client.on("complete", function(client, args) {
					base.show_success('复制成功')
				});
			});
		});
	}

	$('.container').on('click', '.pre', function() {
		var module = location.hash.slice(1)
		var page = Number($('.page').text()) - 1;
		$.get('/back/' + module + '?page=' + page, function(content_html) {
			$('.content').empty();
			$('.content').append(content_html);
			var client = new zeroclipboard($('.copy'));
			client.on("load", function(client) {
				client.on("complete", function(client, args) {
					base.show_success('复制成功')
				});
			});
		});
	});
	$('.container').on('click', '.next', function() {
		var module = location.hash.slice(1)
		var page = Number($('.page').text()) + 1;
		$.get('/back/' + module + '?page=' + page, function(content_html) {
			$('.content').empty();
			$('.content').append(content_html);
			var client = new zeroclipboard($('.copy'));
			client.on("load", function(client) {
				client.on("complete", function(client, args) {
					base.show_success('复制成功')
				});
			});
		});
	});


});