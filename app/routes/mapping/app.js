module.exports = function(app, mw, App) {
	// 创建应用
	app.post('/app', App.create);

	// 获取应用列表
	app.get('/app', App.list);
};