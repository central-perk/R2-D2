module.exports = function(app, mw, back) {
	app.get('/',function(req, res){
		return res.redirect('/back');
	});

	// 此后不能写back下另外的get请求
	app.get('/back', function(req, res, next) {
		req.requireAuthorization(req, res, next);
	}, back.index);

	// 后台页面
	app.get('/back/*', function(req, res, next) {
		req.requireAuthorization(req, res, next);
	}, back.index);

	// 重启服务
	app.post('/back/restart', back.restart);

	// 取消重启服务
	app.post('/back/restart/cancel', back.cancelRestart);
};
