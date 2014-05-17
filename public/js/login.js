define(['jquery', 'hbs!/modules/login', 'moment'], function($, loginListTpl, moment) {
	$('.container').on('click', '.login.create', function() {
		var url = location.origin + '?_type=openLogin&timestamp=' + (new Date()).getTime() + '&openID=12345';
		$.get(url, function(data) {
			getLoginList();
			// alert(data.message);
		})
	});
	$('.container').on('click', '.login.storage', function() {
		var url = location.origin + '/storage';
		$.post(url, function(data) {
			getLoginList();
			// alert(data.message);
		})
	});

	function getLoginList() {
		var url = location.origin + '/login';
		$.get(url, function(data) {
			var loginListData = data.message.logins;
			$('.login_list').empty();
			$('.login_list').append(loginListTpl(loginListData));
		})
	}


})