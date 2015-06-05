var config = process.g.config,
	utils = process.g.utils,
	filePath = process.g.path;

var logger = utils.getCtrl('logger');

module.exports = function(app, mw, logger) {

	// 创建日志
	app.get('/upload/app/:appID/logname/:logName/token/:token', logger.create);

	// 获取多条日志
	app.get('/logger', logger.list);
};