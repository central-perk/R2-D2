define(['jquery'], function($) {

	function show_success(msg) {
		$('.alert-success').text(msg)
		$('.alert-success').show()
		$('.alert-success').fadeOut(3000)
	}

	function show_error(msg) {
		$('.alert-danger').text(msg)
		$('.alert-danger').show()
	}

	$('.container').on('click', '.alert-success, .alert-danger', function() {
		$(this).hide()
	});



	return {
		show_success: show_success,
		show_error: show_error
	}
})