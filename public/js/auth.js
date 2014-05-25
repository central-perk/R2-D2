define(['jquery', 'base'], function($, base) {
	// 创建授权
	$('.container').on('click', '.create_auth', function() {
		if (confirm('确定授权该应用？')) {
			var url = '/auth';
			var appName = $('#appName').val();
			$.post(url, {
				appName: appName
			}, function(data) {
				if (data.status) {
					base.show_success('授权成功')
					setTimeout(function() {
						location.reload()
					}, 100)
				} else {
					base.show_error(data.message)
				}
			});
		}

	});
	$('.container').on('click', '.show_auth_form', function() {
		$('.auth_form').slideToggle();
	});
})