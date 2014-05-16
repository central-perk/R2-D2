require.config({
	paths: {
		jquery: '/libs/jquery/dist/jquery.min',
		handlebars: '/libs/handlebars/handlebars.min'
	},
	shim: {
		'handlebars': {
			exports: 'handlebars'
		}
	}
});
define(['jquery', 'handlebars'], function($, handlebars) {
	$().ready(function() {
		function init_content() {
			if (location.hash) {
				$('.bs-sidenav>li').removeClass('active');
				$('.bs-sidenav>li>a[href="' + location.hash + '"]').parent('li').addClass('active');
			}
			var module = $('.bs-sidenav>li.active>a').attr('href').slice(1);
			$.get('/api/' + module, function(content_html) {
				if (content_html) {
					$('.content').append(content_html)
				}
			})
		}
		init_content();

		$('.bs-sidenav>li>a').on('click', function() {
			var self = $(this),
				module = self.attr('href').slice(1);
			$('.bs-sidenav>li').removeClass('active');
			self.parent('li').addClass('active');
			$.get('/api/' + module, function(content_html) {
				if (content_html) {
					$('.content').empty();
					$('.content').append(content_html);
				}
			})
		})
	});
});