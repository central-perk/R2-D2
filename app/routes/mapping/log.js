module.exports = function(app, mw, log) {
	
	// 创建日志
	app.post('/log', log.create);
	
	// 获取日志列表
	app.get('/log', log.list);
	
	// 获取更新日志
	app.put('/log/:logID', log.update);

	// 获取根据应用分类的日志列表

	app.get('/log/group/app', log.groupApp);

}