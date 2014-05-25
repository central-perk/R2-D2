define(['jquery', 'hbs!/modules/login', 'moment'], function($, loginListTpl, moment) {
	// 创建日志模型
	$('.container').on('click', '.login.create_model', function() {
		var url = '/logmodel';
		$.post(url, {type: 'login', attributes: [{key: 'openID', value: 'String'}]}, function(data) {
			alert(data.message)
		})
	});
	//显示已有的日志模型
	$('.container').on('click', '.login.list_model', function() {
		var url = '/logmodel';
		$.get(url, function(data) {
			alert(data.message)
		})
	});	
	//获取授权
	$('.container').on('click', '.auth.create_auth', function() {
		var url = '/auth';
		$.post(url, {appName: '易传单'}, function(data) {
			var message = data.message;
			var str = 'appID: ' + message.appID + '\n';
			str += 'token: ' + message.token;
			document.cookie = "appID=" + message.appID;
			document.cookie = "token=" + message.token;
			alert(str)
		})
	});
	//上传日志
	$('.container').on('click', '.login.create_log', function() {
		var sCookie = document.cookie,
			aCookie = sCookie.split(';'),
			appID,token;
		for(var i = 0, len = aCookie.length; i < len; i++){
			var temp = aCookie[i].split('=');
			if(temp[0].indexOf('appID') != -1){
				appID = Number(temp[1])
			}
			if(temp[0].indexOf('token') != -1){		
				token = temp[1]
			}
		}
		var url = location.origin + '?type=login&ts=' + (new Date()).getTime();
		url += '&appID=' + appID;
		url += '&token=' + token;
		url += '&openID=123123';
		$.get(url, function(data) {
			var html = data.message + '<br>';
			$('.create_log_result').append(html)
		});
	});	


	$('.container').on('click', '.login.list', function() {
		getLoginList();
	});


	function getLoginList() {
		var url = location.origin + '/login';
		$.get(url, function(data) {
			var loginListData = data.message;
			$('.login_list').empty();
			$('.login_list').append(loginListTpl(loginListData));
		})
	}


})