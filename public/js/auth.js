define(['jquery'], function($) {
	$('.container').on('click', '.create_auth', function() {
		var url = '/auth';
		var appName = $('#appName').val();
		$.post(url, {
			appName: appName
		}, function(data) {
			if (data.status) {
				// alert(data.message)
				console.log(data.message)
				$('.alert-success').text('授权成功')
				$('.alert-success').show()
				$('.alert-success').fadeOut(1000)
				setTimeout(function(){
					location.reload()
				}, 100)
			} else {
				$('.alert-danger').text(data.message)
				$('.alert-danger').show()
				$('.alert-danger').fadeOut(1000)
				// alert(data.message)
			}
		})
	});


	$('.container').on('click', '.show_auth_form', function() {
		$('.auth_form').slideToggle();
	});
})