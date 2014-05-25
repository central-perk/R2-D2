define(['jquery'], function($) {

	function show_success(message) {
		$('.alert-success').text(message)
		$('.alert-success').show()
		$('.alert-success').fadeOut(3000)
	}

	function show_error(message) {
		$('.alert-danger').text(message)
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